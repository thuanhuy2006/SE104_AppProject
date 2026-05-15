import 'package:cloud_firestore/cloud_firestore.dart';

/// Lớp cơ bản đại diện cho người dùng
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String
  password; // Lưu ý: Mật khẩu nên được mã hóa (hashed) trước khi lưu hoặc ưu tiên dùng Firebase Auth
  final String address;
  final String phoneNumber;
  final String bio;
  final String role; // 'buyer' hoặc 'seller'

  String get deliveryAddress => address;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.password,
    required this.address,
    required this.phoneNumber,
    required this.bio,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'password': password,
      'address': address,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      role: map['role'] ?? 'buyer',
    );
  }
}

/// Lớp đại diện cho người mua hàng (Buyer)
class BuyerModel extends UserModel {
  final List<String> purchaseHistory; // Lịch sử mua hàng (các ID đơn hàng)
  final List<Map<String, dynamic>> currentCart; // Giỏ hàng đang chứa
  final List<String> discountCodes; // Mã giảm giá

  BuyerModel({
    required String uid,
    required String email,
    required String name,
    required String password,
    required String address,
    required String phoneNumber,
    required String bio,
    required this.purchaseHistory,
    required this.currentCart,
    required this.discountCodes,
  }) : super(
         uid: uid,
         email: email,
         name: name,
         password: password,
         address: address,
         phoneNumber: phoneNumber,
         bio: bio,
         role: 'buyer',
       );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['purchaseHistory'] = purchaseHistory;
    map['currentCart'] = currentCart;
    map['discountCodes'] = discountCodes;
    return map;
  }

  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      purchaseHistory: List<String>.from(map['purchaseHistory'] ?? []),
      currentCart: List<Map<String, dynamic>>.from(map['currentCart'] ?? []),
      discountCodes: List<String>.from(map['discountCodes'] ?? []),
    );
  }
}

/// Lớp đại diện cho người bán hàng (Seller)
class SellerModel extends UserModel {
  final double revenue; // Doanh thu
  final List<String> salesHistory; // Lịch sử bán hàng (các ID đơn hàng đã bán)
  final List<Map<String, dynamic>>
  itemsSelling; // Thông tin các món hàng đang bán

  SellerModel({
    required String uid,
    required String email,
    required String name,
    required String password,
    required String address,
    required String phoneNumber,
    required String bio,
    required this.revenue,
    required this.salesHistory,
    required this.itemsSelling,
  }) : super(
         uid: uid,
         email: email,
         name: name,
         password: password,
         address: address,
         phoneNumber: phoneNumber,
         bio: bio,
         role: 'seller',
       );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['revenue'] = revenue;
    map['salesHistory'] = salesHistory;
    map['itemsSelling'] = itemsSelling;
    return map;
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      revenue: (map['revenue'] ?? 0).toDouble(),
      salesHistory: List<String>.from(map['salesHistory'] ?? []),
      itemsSelling: List<Map<String, dynamic>>.from(map['itemsSelling'] ?? []),
    );
  }
}

/// Lớp Service xử lý các tác vụ với Firebase Firestore
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LƯU TRỮ VÀ CẬP NHẬT THÔNG TIN

  /// Cập nhật hoặc lưu thông tin Người mua (Buyer)
  Future<void> saveBuyer(BuyerModel buyer) async {
    await _db
        .collection('users')
        .doc(buyer.uid)
        .set(buyer.toMap(), SetOptions(merge: true));
  }

  /// Cập nhật hoặc lưu thông tin Người bán (Seller)
  Future<void> saveSeller(SellerModel seller) async {
    await _db
        .collection('users')
        .doc(seller.uid)
        .set(seller.toMap(), SetOptions(merge: true));
  }

  // LẤY THÔNG TIN

  /// Lấy thông tin user (Buyer hoặc Seller) dựa theo role trong database
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'seller') {
          return SellerModel.fromMap(data);
        } else {
          // Mặc định trả về Buyer
          return BuyerModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // CÁC HÀM TIỆN ÍCH DÀNH CHO BUYER

  /// Cập nhật giỏ hàng cho người mua
  Future<void> updateBuyerCart(
    String uid,
    List<Map<String, dynamic>> currentCart,
  ) async {
    await _db.collection('users').doc(uid).update({'currentCart': currentCart});
  }

  /// Thêm lịch sử mua hàng cho người mua
  Future<void> addPurchaseHistory(String uid, String orderId) async {
    await _db.collection('users').doc(uid).update({
      'purchaseHistory': FieldValue.arrayUnion([orderId]),
    });
  }

  // CÁC HÀM TIỆN ÍCH DÀNH CHO SELLER

  /// Cập nhật doanh thu và thêm lịch sử bán hàng cho người bán
  Future<void> updateSellerSales(
    String uid,
    double addedRevenue,
    String newSaleId,
  ) async {
    await _db.collection('users').doc(uid).update({
      'revenue': FieldValue.increment(addedRevenue),
      'salesHistory': FieldValue.arrayUnion([newSaleId]),
    });
  }

  /// Thêm sản phẩm đang bán cho người bán
  Future<void> addSellingItem(String uid, Map<String, dynamic> newItem) async {
    await _db.collection('users').doc(uid).update({
      'itemsSelling': FieldValue.arrayUnion([newItem]),
    });
  }
}
