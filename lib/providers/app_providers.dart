import 'package:flutter/material.dart';
import '../models/app_models.dart';

enum UserRole { buyer, seller }

class User {
  String name;
  final String email;
  final String password;
  String deliveryAddress;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.deliveryAddress = 'Việt Nam',
  });
}

class UserProvider with ChangeNotifier {
  User? _currentUser;
  UserRole _role = UserRole.buyer;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSeller => _role == UserRole.seller;

  final List<User> _registeredUsers = [
    User(name: 'Trần Đình Sang', email: 'sang@gmail.com', password: '123', deliveryAddress: 'Việt Nam'),
  ];

  void toggleRole() {
    _role = _role == UserRole.buyer ? UserRole.seller : UserRole.buyer;
    notifyListeners();
  }

  void updateUserInfo(String newName, String newAddress) {
    if (_currentUser != null) {
      _currentUser!.name = newName;
      _currentUser!.deliveryAddress = newAddress;
      notifyListeners();
    }
  }

  bool login(String email, String password) {
    try {
      final user = _registeredUsers.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void register(String name, String email, String password) {
    final newUser = User(name: name, email: email, password: password, deliveryAddress: 'Việt Nam');
    _registeredUsers.add(newUser);
    _currentUser = newUser;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _role = UserRole.buyer;
    notifyListeners();
  }
}

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [...ProductData.products];
  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;

  int get itemCount {
    int count = 0;
    _items.forEach((key, item) => count += item.quantity);
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  void addItem(String id, String title, int price, String imageUrl) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
    } else {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity - 1));
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
    if (_favoriteIds.contains(id)) _favoriteIds.remove(id);
    else _favoriteIds.add(id);
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String get query => searchController.text.toLowerCase().trim();
  SearchProvider() { searchController.addListener(() => notifyListeners()); }
  void clearSearch() {
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
}
