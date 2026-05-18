import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import '../services/database.dart';

enum UserRole { buyer, seller }

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  double get selectedTotalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      if (item.isSelected) {
        total += item.price * item.quantity;
      }
    });
    return total;
  }

  void addItem(String id, String title, int price, String imageUrl, [String sellerId = '', String sellerName = '']) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(
        id: ex.id,
        title: ex.title,
        price: ex.price,
        imageUrl: ex.imageUrl,
        sellerId: ex.sellerId,
        sellerName: ex.sellerName,
        quantity: ex.quantity + 1,
        isSelected: ex.isSelected,
      ));
    } else {
      _items.putIfAbsent(id, () => CartItem(
        id: id,
        title: title,
        price: price,
        imageUrl: imageUrl,
        sellerId: sellerId,
        sellerName: sellerName,
      ));
    }
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.isSelected = !_items[id]!.isSelected;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void clearSelectedCart() {
    _items.removeWhere((key, item) => item.isSelected);
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

  SearchProvider() {
    searchController.addListener(() => notifyListeners());
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

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  List<Product> getProductsBySeller(String sellerId) {
    return _products.where((p) => p.sellerId == sellerId).toList();
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserRole _role = UserRole.buyer;
  bool _isLoggedIn = false;
  bool _isInitializing = true;

  final List<dynamic> _myOrders = [];
  final List<dynamic> _salesOrders = [];

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

  List<dynamic> get myOrders => _myOrders;
  List<dynamic> get salesOrders => _salesOrders;

  double get totalRevenue {
    return _salesOrders.fold(0.0, (sum, order) {
      if (order is Map) {
        return sum + (order['totalAmount'] ?? order['total'] ?? 0.0);
      }
      try { return sum + order.totalAmount; } catch(_) { return sum; }
    });
  }

  Map<String, double> get revenueByCategory {
    return {'Quần áo': totalRevenue * 0.6, 'Phụ kiện': totalRevenue * 0.4};
  }

  List<double> get weeklyRevenueData {
    return [1000000, 1500000, 800000, 2000000];
  }

  Future<bool> login(String email, String password) async {
    try {
      final cred = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await _initAuth();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<String?> register(String name, String email, String password, {bool isSellerRole = false}) async {
    try {
      final cred = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        String roleStr = isSellerRole ? 'seller' : 'buyer';
        UserModel newUser = UserModel(
            uid: cred.user!.uid,
            email: email,
            name: name,
            password: password,
            address: '',
            phoneNumber: '',
            bio: '',
            role: roleStr
        );

        await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set(newUser.toMap());

        _currentUser = newUser;
        _isLoggedIn = true;
        _role = isSellerRole ? UserRole.seller : UserRole.buyer;
        notifyListeners();
        return null;
      }
      return "Đăng ký thất bại";
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? "Lỗi Firebase Auth";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateUserInfo(String name, String phone, String address) async {
    if (_currentUser != null) {
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: name,
        password: _currentUser!.password,
        address: address,
        phoneNumber: phone,
        bio: _currentUser!.bio,
        role: _currentUser!.role,
      );
      notifyListeners();
    }
  }

  void syncCartToFirebase(List<CartItem> items) {}

  // SỬA LỖI TẠI ĐÂY: Xử lý ghi trực tiếp Firestore tránh lỗi Undefined trên DatabaseService
  Future<void> updateSellerBankInfo({
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'bankName': bankName,
        'bankAccount': bankAccount,
        'accountName': accountName,
        'role': 'seller',
      });

      _role = UserRole.seller;
      await _initAuth();
      notifyListeners();
    } catch (e) {
      print("Lỗi hệ thống khi cập nhật ngân hàng SePay: $e");
    }
  }
}