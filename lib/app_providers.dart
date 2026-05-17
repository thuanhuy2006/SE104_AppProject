import 'package:flutter/material.dart';
import 'app_models.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  void addItem(String id, String title, int price, String imageUrl) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
    } else {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }
}

class FavoriteProvider with ChangeNotifier {
  final List<String> _favoriteIds = ['p2', 'p4'];
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

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Kiểm tra xem user hiện tại có phải là seller không
  bool get isSeller => _currentUser?.role == 'seller';

  // --- HÀM CẬP NHẬT THÔNG TIN NGÂN HÀNG SEPAY ---
  Future<void> updateSellerBankInfo({
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    if (_currentUser == null) return;

    try {
      // 1. Gọi DatabaseService để cập nhật lên Firestore
      await DatabaseService().updateSellerBankInfo(
        uid: _currentUser!.uid,
        bankName: bankName,
        bankAccount: bankAccount,
        accountName: accountName,
      );

      // 2. Cập nhật lại trạng thái local của _currentUser trong Provider công thức tách biệt (SellerModel)
      // Giữ lại toàn bộ thông tin cũ, chỉ thay đổi thông tin bank và ép role về 'seller'
      _currentUser = SellerModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: _currentUser!.name,
        password: _currentUser!.password,
        address: _currentUser!.address,
        phoneNumber: _currentUser!.phoneNumber,
        bio: _currentUser!.bio,
        revenue: _currentUser is SellerModel ? (_currentUser as SellerModel).revenue : 0.0,
        salesHistory: _currentUser is SellerModel ? (_currentUser as SellerModel).salesHistory : [],
        itemsSelling: _currentUser is SellerModel ? (_currentUser as SellerModel).itemsSelling : [],
        // Data mới nhập vào
        bankName: bankName,
        bankAccount: bankAccount,
        accountName: accountName,
      );

      // 3. Báo cho toàn bộ Widget đang nghe (như YouScreen) vẽ lại giao diện
      notifyListeners();
    } catch (e) {
      print("Lỗi cập nhật Provider: $e");
      rethrow;
    }
  }
}