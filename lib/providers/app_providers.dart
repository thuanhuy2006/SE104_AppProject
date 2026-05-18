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
  final List<Map<String, dynamic>> _myOrders = [];

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
        _role = _currentUser?.role == 'seller'
            ? UserRole.seller
            : UserRole.buyer;
      } else {
        await firebase_auth.FirebaseAuth.instance.signOut();
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  UserModel? get currentUser => _currentUser;
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  bool get isSeller => _role == UserRole.seller;
  List<Map<String, dynamic>> get myOrders => _myOrders;

  // Cập nhật đầy đủ 3 thông tin: Tên, SĐT, Địa chỉ
  Future<void> updateUserInfo(
    String newName,
    String newPhone,
    String newAddress,
  ) async {
    if (_currentUser != null) {
      // Cập nhật local
      UserModel updatedUser;
      if (_currentUser is BuyerModel) {
        BuyerModel buyer = _currentUser as BuyerModel;
        updatedUser = BuyerModel(
          uid: buyer.uid,
          email: buyer.email,
          name: newName,
          password: buyer.password,
          address: newAddress,
          phoneNumber: newPhone,
          bio: buyer.bio,
          purchaseHistory: buyer.purchaseHistory,
          currentCart: buyer.currentCart,
          discountCodes: buyer.discountCodes,
        );
        await DatabaseService().saveBuyer(updatedUser as BuyerModel);
      } else if (_currentUser is SellerModel) {
        SellerModel seller = _currentUser as SellerModel;
        updatedUser = SellerModel(
          uid: seller.uid,
          email: seller.email,
          name: newName,
          password: seller.password,
          address: newAddress,
          phoneNumber: newPhone,
          bio: seller.bio,
          revenue: seller.revenue,
          salesHistory: seller.salesHistory,
          itemsSelling: seller.itemsSelling,
          bankName: seller.bankName,
          bankAccount: seller.bankAccount,
          accountName: seller.accountName,
        );
        await DatabaseService().saveSeller(updatedUser as SellerModel);
      } else {
        updatedUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: newName,
          password: _currentUser!.password,
          address: newAddress,
          phoneNumber: newPhone,
          bio: _currentUser!.bio,
          role: _currentUser!.role,
        );
      }
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin ngân hàng cho Seller
  Future<void> updateSellerBankInfo({
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    if (_currentUser != null) {
      // Cập nhật lên Firestore
      await DatabaseService().updateSellerBankInfo(
        uid: _currentUser!.uid,
        bankName: bankName,
        bankAccount: bankAccount,
        accountName: accountName,
      );

      // Cập nhật local state
      if (_currentUser is SellerModel) {
        final seller = _currentUser as SellerModel;
        _currentUser = SellerModel(
          uid: seller.uid,
          email: seller.email,
          name: seller.name,
          password: seller.password,
          address: seller.address,
          phoneNumber: seller.phoneNumber,
          bio: seller.bio,
          revenue: seller.revenue,
          salesHistory: seller.salesHistory,
          itemsSelling: seller.itemsSelling,
          bankName: bankName,
          bankAccount: bankAccount,
          accountName: accountName,
        );
      } else {
        // Nếu user hiện tại đang là Buyer nhưng vừa cấu hình bank (có thể do logic chuyển đổi)
        // Ta chuyển đổi local user sang SellerModel
        _currentUser = SellerModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: _currentUser!.name,
          password: _currentUser!.password,
          address: _currentUser!.address,
          phoneNumber: _currentUser!.phoneNumber,
          bio: _currentUser!.bio,
          revenue: 0.0,
          salesHistory: [],
          itemsSelling: [],
          bankName: bankName,
          bankAccount: bankAccount,
          accountName: accountName,
        );
        _role = UserRole.seller;
      }
      notifyListeners();
    }
  }

  Future<String> addOrder(List<CartItem> items, double total) async {
    String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    _myOrders.insert(0, {
      'id': orderId,
      'date': DateTime.now(),
      'items': [...items],
      'total': total,
      'status': 'Đang chuẩn bị hàng',
    });

    if (_currentUser != null) {
      // Lưu mã đơn hàng vào lịch sử trên Firebase
      await DatabaseService().addPurchaseHistory(_currentUser!.uid, orderId);
    }
    notifyListeners();
    return orderId;
  }

  // Hàm tiện ích để đồng bộ giỏ hàng lên Firebase
  Future<void> syncCartToFirebase(List<CartItem> cartItems) async {
    if (_currentUser != null) {
      List<Map<String, dynamic>> cartData = cartItems
          .map(
            (item) => {
              'id': item.id,
              'title': item.title,
              'price': item.price,
              'imageUrl': item.imageUrl,
              'sellerId': item.sellerId,
              'sellerName': item.sellerName,
              'quantity': item.quantity,
            },
          )
          .toList();
      await DatabaseService().updateBuyerCart(_currentUser!.uid, cartData);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final cred = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        UserModel? fetchedUser = await DatabaseService().getUser(
          cred.user!.uid,
        );

        if (fetchedUser != null) {
          // Chỉ đăng nhập thành công khi tìm thấy dữ liệu trên Firestore
          _currentUser = fetchedUser;
          _isLoggedIn = true;
          _role = _currentUser?.role == 'seller'
              ? UserRole.seller
              : UserRole.buyer;
          notifyListeners();
          return true;
        } else {
          // Bắt trường hợp có tài khoản Auth nhưng mất/không có dữ liệu ở Firestore do Rules hoặc lỗi mạng
          BuyerModel newUser = BuyerModel(
            uid: cred.user!.uid,
            email: email,
            name: email.split('@')[0],
            password: password,
            address: '',
            phoneNumber: '',
            bio: '',
            purchaseHistory: [],
            currentCart: [],
            discountCodes: [],
          );
          try {
            await DatabaseService().saveBuyer(newUser);
            _currentUser = newUser;
            _isLoggedIn = true;
            _role = UserRole.buyer;
            notifyListeners();
            return true;
          } catch (e) {
            print('Login error: Không thể tạo lại dữ liệu trên Firestore: $e');
            await firebase_auth.FirebaseAuth.instance.signOut();
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> register(String name, String email, String password, {bool isSellerRole = false}) async {
    try {
      final cred = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        if (isSellerRole) {
          SellerModel newUser = SellerModel(
            uid: cred.user!.uid,
            email: email,
            name: name,
            password: password,
            address: '',
            phoneNumber: '',
            bio: '',
            revenue: 0.0,
            salesHistory: [],
            itemsSelling: [],
          );
          await DatabaseService().saveSeller(newUser);
          _currentUser = newUser;
          _role = UserRole.seller;
        } else {
          BuyerModel newUser = BuyerModel(
            uid: cred.user!.uid,
            email: email,
            name: name,
            password: password,
            address: '',
            phoneNumber: '',
            bio: '',
            purchaseHistory: [],
            currentCart: [],
            discountCodes: [],
          );
          await DatabaseService().saveBuyer(newUser);
          _currentUser = newUser;
          _role = UserRole.buyer;
        }
        
        _isLoggedIn = true;
        notifyListeners();
        return null;
      }
      return "Không thể tạo tài khoản.";
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Register FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'weak-password':
          return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
        default:
          return 'Đăng ký thất bại: ${e.message}';
      }
    } catch (e) {
      print('Register error: $e');
      return 'Đã xảy ra lỗi: $e';
    }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _currentUser = null;
    _isLoggedIn = false;
    _role = UserRole.buyer;
    _myOrders.clear();
    notifyListeners();
  }
}

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    
    _products = await DatabaseService().getProducts();
    if (_products.isEmpty) {
      // Initialize with mock data if empty
      _products = [...ProductData.products];
      for (var product in _products) {
        try {
          await DatabaseService().saveProduct(product);
        } catch (e) {
          print('Lỗi khi lưu sản phẩm mẫu: $e');
        }
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  List<Product> getProductsBySeller(String sellerId) {
    return _products.where((p) => p.sellerId == sellerId).toList();
  }

  Future<void> addProduct(Product product) async {
    await DatabaseService().saveProduct(product);
    _products.insert(0, product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseService().saveProduct(product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    double total = 0.0;
    _items.forEach(
      (key, cartItem) => total += cartItem.price * cartItem.quantity,
    );
    return total;
  }

  // Tổng tiền chỉ tính những sản phẩm được chọn
  double get selectedTotalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Kiểm tra xem tất cả các món đã được chọn chưa
  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.values.every((item) => item.isSelected);
  }

  void toggleSelection(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.isSelected = !_items[id]!.isSelected;
      notifyListeners();
    }
  }

  void toggleAll(bool value) {
    _items.forEach((key, item) => item.isSelected = value);
    notifyListeners();
  }

  void addItem(String id, String title, int price, String imageUrl, String sellerId, String sellerName) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (ex) => CartItem(
          id: ex.id,
          title: ex.title,
          price: ex.price,
          imageUrl: ex.imageUrl,
          sellerId: ex.sellerId,
          sellerName: ex.sellerName,
          quantity: ex.quantity + 1,
          isSelected: ex.isSelected,
        ),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: id,
          title: title,
          price: price,
          imageUrl: imageUrl,
          sellerId: sellerId,
          sellerName: sellerName,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (ex) => CartItem(
          id: ex.id,
          title: ex.title,
          price: ex.price,
          imageUrl: ex.imageUrl,
          quantity: ex.quantity - 1,
          isSelected: ex.isSelected,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Chỉ xóa các món hàng đã được chọn (sau khi thanh toán)
  void clearSelectedCart() {
    _items.removeWhere((key, item) => item.isSelected);
    notifyListeners();
  }
}

class AddressProvider with ChangeNotifier {
  SavedAddress? _defaultAddress;
  SavedAddress? get defaultAddress => _defaultAddress;
  void saveAddress(SavedAddress address) {
    _defaultAddress = address;
    notifyListeners();
  }
}

class FavoriteProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id))
      _favoriteIds.remove(id);
    else
      _favoriteIds.add(id);
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String get query => searchController.text.toLowerCase().trim();
  SearchProvider() {
    searchController.addListener(() => notifyListeners());
  }
  void clearSearch() {
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
