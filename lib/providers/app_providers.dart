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

  UserProvider() { _initAuth(); }

  Future<void> _initAuth() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserModel? fetchedUser = await DatabaseService().getUser(currentUser.uid);
      if (fetchedUser != null) {
        _currentUser = fetchedUser;
        _isLoggedIn = true;
        _role = _currentUser?.role == 'seller' ? UserRole.seller : UserRole.buyer;
        _fetchOrders();
      } else { await firebase_auth.FirebaseAuth.instance.signOut(); }
    }
    _isInitializing = false;
    notifyListeners();
  }

  void _fetchOrders() {
    if (_currentUser == null) return;
    DatabaseService().getBuyerOrders(_currentUser!.uid).listen((orders) {
      _myOrders = orders;
      notifyListeners();
    });
    if (isSeller) {
      DatabaseService().getSellerOrders(_currentUser!.uid).listen((orders) {
        _salesOrders = orders;
        notifyListeners();
      });
    }
  }

  UserModel? get currentUser => _currentUser;
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  bool get isSeller => _role == UserRole.seller;
  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get salesOrders => _salesOrders;

  // --- CẬP NHẬT THÔNG TIN NGÂN HÀNG (Dùng cho SePay ở YouScreen) ---
  Future<void> updateSellerBankInfo({
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    if (_currentUser != null && isSeller) {
      await DatabaseService().updateSellerBankInfo(
        uid: _currentUser!.uid,
        bankName: bankName,
        bankAccount: bankAccount,
        accountName: accountName,
      );
      await _initAuth(); // Reload lại thông tin user để nhận cấu hình mới
    }
  }

  // --- XÁC NHẬN NHẬN HÀNG (Người mua thực hiện ở PurchasesScreen) ---
  Future<void> markAsReceived(String orderId) async {
    final index = _myOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      Map<String, DateTime?> newTimeline = Map.from(_myOrders[index].timeline);
      newTimeline['Đã giao'] = DateTime.now();
      await DatabaseService().updateOrderStatus(
          orderId,
          'Đã giao',
          newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String()))
      );
      _fetchOrders();
    }
  }

  // --- TIẾN TRÌNH GIAO HÀNG (Seller cập nhật) ---
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _salesOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _salesOrders[index];
      Map<String, DateTime?> newTimeline = Map.from(order.timeline);
      newTimeline[newStatus] = DateTime.now();
      await DatabaseService().updateOrderStatus(orderId, newStatus, newTimeline.map((k, v) => MapEntry(k, v?.toIso8601String())));
    }
  }

  // --- ĐÁNH GIÁ SẢN PHẨM (Buyer thực hiện) ---
  Future<void> submitOrderReview({
    required String orderId,
    required double rating,
    required String comment,
    required List<CartItem> items,
  }) async {
    if (_currentUser == null) return;
    final reviewData = {
      'rating': rating,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
    };

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

  // SỬA LỖI TRẢ VỀ KIỂU STRING ĐỂ KHỚP VỚI CHECKOUT PAGE
  Future<String> addOrder(List<CartItem> items, double total) async {
    if (_currentUser == null) throw Exception("Chưa đăng nhập");
    String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final newOrder = OrderModel(
      id: orderId, buyerId: _currentUser!.uid, sellerId: items.first.sellerId,
      items: items, totalAmount: total, timestamp: DateTime.now(), status: 'Đã đặt hàng',
      timeline: {'Đã đặt hàng': DateTime.now()},
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
        isSellerRole ? await DatabaseService().saveSeller(newUser as SellerModel) : await DatabaseService().saveBuyer(newUser as BuyerModel);
        await _initAuth();
        return null;
      }
      return "Lỗi đăng ký";
    } catch (e) { return e.toString(); }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _currentUser = null; _isLoggedIn = false; _role = UserRole.buyer; _myOrders = [];
    notifyListeners();
  }

  void toggleRole() {
    _role = _role == UserRole.buyer ? UserRole.seller : UserRole.buyer;
    notifyListeners();
  }
}

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  List<Product> get products => _products;
  ProductProvider() { _fetchProducts(); }
  Future<void> _fetchProducts() async {
    _isLoading = true; notifyListeners();
    _products = await DatabaseService().getProducts();
    _isLoading = false; notifyListeners();
  }
  List<Product> getProductsBySeller(String sellerId) => _products.where((p) => p.sellerId == sellerId).toList();
  Future<void> addProduct(Product product) async { await DatabaseService().saveProduct(product); _products.insert(0, product); notifyListeners(); }
  Future<void> updateProduct(Product product) async { await DatabaseService().saveProduct(product); final i = _products.indexWhere((p) => p.id == product.id); if (i != -1) { _products[i] = product; notifyListeners(); } }
  void deleteProduct(String id) { _products.removeWhere((p) => p.id == id); notifyListeners(); }
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

  // CHUẨN HÓA: Chỉ nhận tham số Product object để tránh lỗi mismatch
  void addItem(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity++;
    } else {
      _items[p.id] = CartItem(
          id: p.id, title: p.title, price: p.price, imageUrl: p.imageUrl,
          sellerId: p.sellerId, sellerName: p.sellerName, category: p.category
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String id) { if (_items.containsKey(id)) { _items[id]!.quantity++; notifyListeners(); } }
  void removeSingleItem(String id) { if (!_items.containsKey(id)) return; if (_items[id]!.quantity > 1) { _items[id]!.quantity--; } else { _items.remove(id); } notifyListeners(); }
  void removeItem(String id) { _items.remove(id); notifyListeners(); }
  void clearSelectedCart() { _items.removeWhere((key, item) => item.isSelected); notifyListeners(); }
}

class FavoriteProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) _favoriteIds.remove(id); else _favoriteIds.add(id);
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String get query => searchController.text.toLowerCase().trim();
  SearchProvider() { searchController.addListener(() => notifyListeners()); }
  void clearSearch() { searchController.clear(); FocusManager.instance.primaryFocus?.unfocus(); }
}