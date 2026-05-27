import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/app_models.dart';
import '../services/database.dart';

enum UserRole { buyer, seller }

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserRole _role = UserRole.buyer;
  bool _isLoggedIn = false;
  bool _isInitializing = true;
  
  List<OrderModel> _myOrders = []; 
  List<OrderModel> _salesOrders = []; 

  StreamSubscription<List<OrderModel>>? _buyerOrdersSubscription;
  StreamSubscription<List<OrderModel>>? _sellerOrdersSubscription;

  UserProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserModel? fetchedUser = await DatabaseService().getUser(currentUser.uid);
      if (fetchedUser != null) {
        _currentUser = fetchedUser;
        _isLoggedIn = true;
        _role = _currentUser?.role == 'seller' ? UserRole.seller : UserRole.buyer;
        _fetchOrders();
      } else {
        await firebase_auth.FirebaseAuth.instance.signOut();
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  void _fetchOrders() {
    if (_currentUser == null) return;
    
    _buyerOrdersSubscription?.cancel();
    _buyerOrdersSubscription = DatabaseService().getBuyerOrders(_currentUser!.uid).listen((orders) {
      _myOrders = orders;
      notifyListeners();
    });

    _sellerOrdersSubscription?.cancel();
    _sellerOrdersSubscription = DatabaseService().getSellerOrders(_currentUser!.uid).listen((orders) {
      _salesOrders = orders;
      notifyListeners();
    });
  }

  // HÀM LÀM MỚI ĐƠN HÀNG
  Future<void> refreshOrders() async {
    _fetchOrders();
    await Future.delayed(const Duration(milliseconds: 500)); // Đợi một chút để UI mượt hơn
  }

  UserModel? get currentUser => _currentUser;
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  bool get isSeller => _role == UserRole.seller;
  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get salesOrders => _salesOrders;

  double get totalRevenue => _salesOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  Map<String, double> get revenueByCategory {
    if (!isSeller) return {};
    Map<String, double> stats = {'Trang sức': 0.0, 'Quần áo': 0.0, 'Phụ kiện': 0.0, 'Giày dép': 0.0};
    for (var order in _salesOrders) {
      for (var item in order.items) {
        if (stats.containsKey(item.category)) {
          stats[item.category] = stats[item.category]! + (item.price * item.quantity);
        }
      }
    }
    return stats;
  }

  List<double> get weeklyRevenueData {
    if (totalRevenue == 0) return [1200000, 850000, 2300000, 1500000, 3000000, 2100000, 4500000];
    return List.filled(7, totalRevenue / 7);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _salesOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _salesOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      newTimeline[newStatus] = DateTime.now();

      // Cập nhật local state ngay lập tức để UI thay đổi tức thì
      _salesOrders[index] = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        sellerId: order.sellerId,
        items: order.items,
        totalAmount: order.totalAmount,
        timestamp: order.timestamp,
        status: newStatus,
        timeline: newTimeline,
        review: order.review,
        returnRequest: order.returnRequest,
      );
      notifyListeners();

      await DatabaseService().updateOrderStatus(orderId, newStatus, newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _myOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _myOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      newTimeline['Đã hủy'] = DateTime.now();

      // Cập nhật local state ngay lập tức
      _myOrders[index] = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        sellerId: order.sellerId,
        items: order.items,
        totalAmount: order.totalAmount,
        timestamp: order.timestamp,
        status: 'Đã hủy',
        timeline: newTimeline,
        review: order.review,
        returnRequest: order.returnRequest,
      );
      notifyListeners();

      await DatabaseService().cancelOrder(
        orderId,
        order.sellerId,
        order.totalAmount,
        newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())),
      );
    }
  }

  Future<void> markAsReceived(String orderId) async {
    final index = _myOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _myOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      newTimeline['Đã giao'] = DateTime.now();

      // Cập nhật local state ngay lập tức
      _myOrders[index] = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        sellerId: order.sellerId,
        items: order.items,
        totalAmount: order.totalAmount,
        timestamp: order.timestamp,
        status: 'Đã giao',
        timeline: newTimeline,
        review: order.review,
        returnRequest: order.returnRequest,
      );
      notifyListeners();

      await DatabaseService().updateOrderStatus(
        orderId,
        'Đã giao',
        newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())),
      );
    }
  }

  Future<void> requestReturn({
    required String orderId,
    required String reason,
    required List<String> imageUrls,
  }) async {
    final index = _myOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _myOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      newTimeline['Yêu cầu trả hàng'] = DateTime.now();

      final returnRequestData = {
        'reason': reason,
        'images': imageUrls,
        'status': 'Chờ xác nhận',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Cập nhật local state ngay lập tức
      _myOrders[index] = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        sellerId: order.sellerId,
        items: order.items,
        totalAmount: order.totalAmount,
        timestamp: order.timestamp,
        status: 'Yêu cầu trả hàng',
        timeline: newTimeline,
        review: order.review,
        returnRequest: returnRequestData,
      );
      notifyListeners();

      await DatabaseService().requestReturn(
        orderId: orderId,
        reason: reason,
        imageUrls: imageUrls,
        timeline: newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())),
      );
    }
  }

  Future<void> handleReturnRequest({
    required String orderId,
    required bool approve,
  }) async {
    final index = _salesOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _salesOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      final String statusKey = approve ? 'Đã trả hàng' : 'Từ chối trả hàng';
      newTimeline[statusKey] = DateTime.now();

      final updatedReturnRequest = Map<String, dynamic>.from(order.returnRequest ?? {});
      updatedReturnRequest['status'] = approve ? 'Đã chấp nhận' : 'Bị từ chối';

      // Cập nhật local state ngay lập tức
      _salesOrders[index] = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        sellerId: order.sellerId,
        items: order.items,
        totalAmount: order.totalAmount,
        timestamp: order.timestamp,
        status: statusKey,
        timeline: newTimeline,
        review: order.review,
        returnRequest: updatedReturnRequest,
      );
      notifyListeners();

      await DatabaseService().handleReturnRequest(
        orderId: orderId,
        sellerId: order.sellerId,
        totalAmount: order.totalAmount,
        approve: approve,
        timeline: newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())),
        returnRequestData: order.returnRequest ?? {},
      );
    }
  }

  Future<void> updateSellerBankInfo({
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    if (_currentUser == null) return;
    await DatabaseService().updateSellerBankInfo(
      uid: _currentUser!.uid,
      bankName: bankName,
      bankAccount: bankAccount,
      accountName: accountName,
    );
    UserModel? fetchedUser = await DatabaseService().getUser(_currentUser!.uid);
    if (fetchedUser != null) {
      _currentUser = fetchedUser;
      notifyListeners();
    }
  }

  Future<void> submitOrderReview({
    required String orderId,
    required double rating,
    required String comment,
    required List<CartItem> items,
  }) async {
    if (_currentUser == null) return;
    final reviewData = {'rating': rating, 'comment': comment, 'timestamp': DateTime.now().toIso8601String()};
    for (var item in items) {
      final review = ReviewModel(
        id: 'REV_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
        productId: item.id,
        userId: _currentUser!.uid,
        userName: _currentUser!.name,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
      );
      await DatabaseService().submitReview(review);
    }
    await DatabaseService().updateOrderReview(orderId, reviewData);
  }

  Future<void> updateUserInfo(String newName, String newPhone, String newAddress) async {
    if (_currentUser == null) return;
    UserModel updatedUser;
    if (_currentUser is BuyerModel) {
      updatedUser = BuyerModel(
        uid: _currentUser!.uid, email: _currentUser!.email, name: newName, password: _currentUser!.password,
        address: newAddress, phoneNumber: newPhone, bio: _currentUser!.bio,
        purchaseHistory: (_currentUser as BuyerModel).purchaseHistory,
        currentCart: (_currentUser as BuyerModel).currentCart,
        discountCodes: (_currentUser as BuyerModel).discountCodes,
      );
      await DatabaseService().saveBuyer(updatedUser as BuyerModel);
    } else {
      SellerModel seller = _currentUser as SellerModel;
      updatedUser = SellerModel(
        uid: seller.uid, email: seller.email, name: newName, password: seller.password,
        address: newAddress, phoneNumber: newPhone, bio: seller.bio,
        revenue: seller.revenue, salesHistory: seller.salesHistory, itemsSelling: seller.itemsSelling,
        bankName: seller.bankName, bankAccount: seller.bankAccount, accountName: seller.accountName,
      );
      await DatabaseService().saveSeller(updatedUser as SellerModel);
    }
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<String> addOrder(List<CartItem> items, double total) async {
    if (_currentUser == null) throw Exception("User not logged in");
    String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final newOrder = OrderModel(
      id: orderId, buyerId: _currentUser!.uid, sellerId: items.first.sellerId, 
      items: items, totalAmount: total, timestamp: DateTime.now(), status: 'Chờ xác nhận',
      timeline: {'Chờ xác nhận': DateTime.now()},
    );
    await DatabaseService().createOrder(newOrder);
    
    return orderId;
  }

  Future<void> syncCartToFirebase(List<CartItem> cartItems) async {
    if (_currentUser != null) {
      List<Map<String, dynamic>> cartData = cartItems.map((item) => item.toMap()).toList();
      await DatabaseService().updateBuyerCart(_currentUser!.uid, cartData);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await _initAuth();
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> register(String name, String email, String password, {bool isSellerRole = false}) async {
    try {
      final cred = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        UserModel newUser = isSellerRole 
          ? SellerModel(uid: cred.user!.uid, email: email, name: name, password: password, address: '', phoneNumber: '', bio: '', revenue: 0.0, salesHistory: [], itemsSelling: [])
          : BuyerModel(uid: cred.user!.uid, email: email, name: name, password: password, address: '', phoneNumber: '', bio: '', purchaseHistory: [], currentCart: [], discountCodes: []);
        if (isSellerRole) {
          await DatabaseService().saveSeller(newUser as SellerModel);
        } else {
          await DatabaseService().saveBuyer(newUser as BuyerModel);
        }
        await _initAuth();
        return null;
      }
      return "Lỗi đăng ký";
    } catch (e) { return e.toString(); }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _buyerOrdersSubscription?.cancel();
    _buyerOrdersSubscription = null;
    _sellerOrdersSubscription?.cancel();
    _sellerOrdersSubscription = null;
    _currentUser = null; _isLoggedIn = false; _role = UserRole.buyer; _myOrders = []; _salesOrders = [];
    notifyListeners();
  }

  void toggleRole() {
    _role = _role == UserRole.buyer ? UserRole.seller : UserRole.buyer;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    if (_currentUser != null) {
      UserModel? fetchedUser = await DatabaseService().getUser(_currentUser!.uid);
      if (fetchedUser != null) {
        _currentUser = fetchedUser;
        notifyListeners();
      }
    }
  }
}

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() { _fetchProducts(); }
  
  Future<void> _fetchProducts() async {
    _isLoading = true; notifyListeners();
    _products = await DatabaseService().getProducts();
    if (_products.isEmpty) {
      _products = [...ProductData.products];
      for (var p in _products) { await DatabaseService().saveProduct(p); }
    }
    _isLoading = false; notifyListeners();
  }

  // HÀM LÀM MỚI SẢN PHẨM
  Future<void> refreshProducts() async {
    await _fetchProducts();
  }

  List<Product> getProductsBySeller(String sellerId) => _products.where((p) => p.sellerId == sellerId).toList();
  Future<void> addProduct(Product product) async { await DatabaseService().saveProduct(product); _products.insert(0, product); notifyListeners(); }
  Future<void> updateProduct(Product product) async { await DatabaseService().saveProduct(product); final i = _products.indexWhere((p) => p.id == product.id); if (i != -1) { _products[i] = product; notifyListeners(); } }
  Future<void> deleteProduct(String id) async { await DatabaseService().deleteProduct(id); _products.removeWhere((p) => p.id == id); notifyListeners(); }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get selectedTotalAmount => _items.values.where((i) => i.isSelected).fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  bool get isAllSelected => _items.isNotEmpty && _items.values.every((item) => item.isSelected);

  void toggleSelection(String id) { if (_items.containsKey(id)) { _items[id]!.isSelected = !_items[id]!.isSelected; notifyListeners(); } }
  void toggleAll(bool value) { _items.forEach((key, item) => item.isSelected = value); notifyListeners(); }

  void addItem(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity++;
    } else {
      _items[p.id] = CartItem(id: p.id, title: p.title, price: p.price, imageUrl: p.imageUrl, sellerId: p.sellerId, sellerName: p.sellerName, category: p.category);
    }
    notifyListeners();
  }

  void incrementQuantity(String id) { if (_items.containsKey(id)) { _items[id]!.quantity++; notifyListeners(); } }
  void removeSingleItem(String id) { if (!_items.containsKey(id)) return; if (_items[id]!.quantity > 1) { _items[id]!.quantity--; } else { _items.remove(id); } notifyListeners(); }
  void removeItem(String id) { _items.remove(id); notifyListeners(); }
  void clearSelectedCart() { _items.removeWhere((key, item) => item.isSelected); notifyListeners(); }

  void updateQuantity(String id, int qty) {
    if (_items.containsKey(id)) {
      if (qty <= 0) {
        _items.remove(id);
      } else {
        _items[id]!.quantity = qty;
      }
      notifyListeners();
    }
  }

  void clearPurchasedItems(List<CartItem> purchasedItems) {
    for (var item in purchasedItems) {
      _items.remove(item.id);
    }
    notifyListeners();
  }
}

class FavoriteProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String get query => searchController.text.toLowerCase().trim();
  SearchProvider() { searchController.addListener(() => notifyListeners()); }
  void clearSearch() { searchController.clear(); FocusManager.instance.primaryFocus?.unfocus(); }
  @override void dispose() { searchController.dispose(); super.dispose(); }
}

class VoucherProvider with ChangeNotifier {
  List<Voucher> _sellerVouchers = [];
  List<Voucher> _buyerVouchers = [];
  bool _isLoading = false;

  List<Voucher> get sellerVouchers => _sellerVouchers;
  List<Voucher> get buyerVouchers => _buyerVouchers;
  bool get isLoading => _isLoading;

  Future<void> fetchSellerVouchers(String sellerId) async {
    _isLoading = true;
    notifyListeners();
    _sellerVouchers = await DatabaseService().getSellerVouchers(sellerId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBuyerVouchers(List<String> codes) async {
    _isLoading = true;
    notifyListeners();
    _buyerVouchers = await DatabaseService().getBuyerVouchers(codes);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveVoucher(Voucher voucher) async {
    await DatabaseService().saveVoucher(voucher);
    final index = _sellerVouchers.indexWhere((v) => v.code == voucher.code);
    if (index != -1) {
      _sellerVouchers[index] = voucher;
    } else {
      _sellerVouchers.insert(0, voucher);
    }
    notifyListeners();
  }

  Future<void> deleteVoucher(String code) async {
    await DatabaseService().deleteVoucher(code);
    _sellerVouchers.removeWhere((v) => v.code == code);
    notifyListeners();
  }

  Future<bool> claimVoucher(String buyerId, String code, UserProvider userProvider) async {
    bool success = await DatabaseService().claimVoucher(buyerId, code);
    if (success) {
      await userProvider.reloadUser();
      // Reload buyer vouchers list
      final user = userProvider.currentUser;
      if (user is BuyerModel) {
        await fetchBuyerVouchers(user.discountCodes);
      }
    }
    return success;
  }
}
