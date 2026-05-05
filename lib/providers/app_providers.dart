import 'package:flutter/material.dart';
import '../models/app_models.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // Đếm tổng số lượng (không phải số loại mặt hàng)
  int get itemCount {
    int count = 0;
    _items.forEach((key, item) => count += item.quantity);
    return count;
  }

  // Tính tổng tiền
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Thêm vào giỏ
  void addItem(String id, String title, int price, String imageUrl) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
    } else {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }

  // Giảm số lượng 1 đơn vị
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
            (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity - 1),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Xóa hẳn một món hàng (dù số lượng là bao nhiêu)
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Xóa toàn bộ giỏ (Dùng sau khi thanh toán xong)
  void clearCart() {
    _items.clear();
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
  SearchProvider() { searchController.addListener(() { notifyListeners(); }); }
  void clearSearch() {
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
}