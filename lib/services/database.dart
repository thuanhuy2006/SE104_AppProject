import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

/// Lớp cơ bản đại diện cho người dùng
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String password;
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
  final List<String> purchaseHistory;
  final List<Map<String, dynamic>> currentCart;
  final List<String> discountCodes;

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
  final double revenue;
  final List<String> salesHistory;
  final List<Map<String, dynamic>> itemsSelling;
  final String bankName;
  final String bankAccount;
  final String accountName;

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
    this.bankName = '',
    this.bankAccount = '',
    this.accountName = '',
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
    map['bankName'] = bankName;
    map['bankAccount'] = bankAccount;
    map['accountName'] = accountName;
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
      bankName: map['bankName'] ?? '',
      bankAccount: map['bankAccount'] ?? '',
      accountName: map['accountName'] ?? '',
    );
  }
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER MANAGEMENT
  Future<void> saveBuyer(BuyerModel buyer) async {
    await _db.collection('users').doc(buyer.uid).set(buyer.toMap(), SetOptions(merge: true));
  }

  Future<void> saveSeller(SellerModel seller) async {
    await _db.collection('users').doc(seller.uid).set(seller.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'seller' ? SellerModel.fromMap(data) : BuyerModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ORDER MANAGEMENT
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());

    await _db.collection('users').doc(order.buyerId).update({
      'purchaseHistory': FieldValue.arrayUnion([order.id]),
    });

    try {
      await _db.collection('users').doc(order.sellerId).update({
        'revenue': FieldValue.increment(order.totalAmount),
        'salesHistory': FieldValue.arrayUnion([order.id]),
      });
    } catch (e) {
      print('Firebase Rules blocked writing to seller document: $e');
    }
  }

  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return _db.collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _db.collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Future<void> updateOrderReview(String orderId, Map<String, dynamic> review) async {
    await _db.collection('orders').doc(orderId).update({
      'review': review,
    });
  }

  Future<void> updateOrderStatus(String orderId, String status, Map<String, dynamic> timeline) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'timeline': timeline,
    });
  }

  // --- HÀM MỚI: HỦY ĐƠN HÀNG ---
  Future<void> cancelOrder(String orderId, String sellerId, double totalAmount, Map<String, dynamic> timeline) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'Đã hủy',
      'timeline': timeline,
    });

    try {
      // Trừ lại tiền doanh thu tạm tính của Người bán
      await _db.collection('users').doc(sellerId).update({
        'revenue': FieldValue.increment(-totalAmount),
      });
    } catch (e) {
      print('Firebase Rules blocked writing to seller document during cancellation: $e');
    }
  }

  // PRODUCT MANAGEMENT
  Future<void> saveProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap(), SetOptions(merge: true));
  }

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  // REVIEW MANAGEMENT (ĐÃ SỬA LỖI BAD STATE)
  Future<void> submitReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());

    DocumentReference productRef = _db.collection('products').doc(review.productId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot productDoc = await transaction.get(productRef);
      if (!productDoc.exists) return;

      // SỬA LỖI Ở ĐÂY: Lấy data dưới dạng Map để an toàn kiểm tra dữ liệu null
      Map<String, dynamic>? data = productDoc.data() as Map<String, dynamic>?;

      // Nếu field chưa từng tồn tại (sản phẩm cũ), mặc định lấy là 0.0 và 0
      double currentRating = (data != null && data.containsKey('rating')) ? (data['rating'] ?? 0.0).toDouble() : 0.0;
      int currentCount = (data != null && data.containsKey('reviewCount')) ? (data['reviewCount'] ?? 0).toInt() : 0;

      double newRating = ((currentRating * currentCount) + review.rating) / (currentCount + 1);

      transaction.update(productRef, {
        'rating': newRating,
        'reviewCount': currentCount + 1,
      });
    });
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _db.collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
          reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return reviews;
        });
  }

  // UTILITIES
  Future<void> updateBuyerCart(String uid, List<Map<String, dynamic>> currentCart) async {
    await _db.collection('users').doc(uid).update({'currentCart': currentCart});
  }

  Future<void> addPurchaseHistory(String uid, String orderId) async {
    await _db.collection('users').doc(uid).update({
      'purchaseHistory': FieldValue.arrayUnion([orderId]),
    });
  }

  Future<void> updateSellerSales(String uid, double addedRevenue, String newSaleId) async {
    await _db.collection('users').doc(uid).update({
      'revenue': FieldValue.increment(addedRevenue),
      'salesHistory': FieldValue.arrayUnion([newSaleId]),
    });
  }

  Future<void> addSellingItem(String uid, Map<String, dynamic> newItem) async {
    await _db.collection('users').doc(uid).update({
      'itemsSelling': FieldValue.arrayUnion([newItem]),
    });
  }

  Future<void> updateSellerBankInfo({
    required String uid,
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    await _db.collection('users').doc(uid).update({
      'role': 'seller',
      'bankName': bankName,
      'bankAccount': bankAccount,
      'accountName': accountName,
    });
  }

  Future<Map<String, String>> getSellerBankInfo(String sellerId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(sellerId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'seller') {
          return {
            'bankName': data['bankName'] ?? '',
            'bankAccount': data['bankAccount'] ?? '',
            'accountName': data['accountName'] ?? '',
          };
        }
      }
      return {'bankName': '', 'bankAccount': '', 'accountName': ''};
    } catch (e) {
      print('Error getting seller bank info: $e');
      return {'bankName': '', 'bankAccount': '', 'accountName': ''};
    }
  }

  Future<void> upgradeToSeller(String uid) async {
    await _db.collection('users').doc(uid).update({
      'role': 'seller',
      'revenue': 0.0,
      'salesHistory': [],
      'itemsSelling': [],
    });
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final String chatId = getChatRoomId(senderId, receiverId);
    final timestamp = FieldValue.serverTimestamp();
    final messageData = {'senderId': senderId, 'receiverId': receiverId, 'text': text, 'timestamp': timestamp};
    await _db.collection('chats').doc(chatId).collection('messages').add(messageData);
    await _db.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastUpdated': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String senderId, String receiverId) {
    final String chatId = getChatRoomId(senderId, receiverId);
    return _db.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getChatRooms(String userId) {
    return _db.collection('chats').where('participants', arrayContains: userId).orderBy('lastUpdated', descending: true).snapshots();
  }

  Future<void> requestReturn({
    required String orderId,
    required String reason,
    required List<String> imageUrls,
    required Map<String, dynamic> timeline,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'Yêu cầu trả hàng',
      'timeline': timeline,
      'returnRequest': {
        'reason': reason,
        'images': imageUrls,
        'status': 'Chờ xác nhận',
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  Future<void> handleReturnRequest({
    required String orderId,
    required String sellerId,
    required double totalAmount,
    required bool approve,
    required Map<String, dynamic> timeline,
    required Map<String, dynamic> returnRequestData,
  }) async {
    final String newStatus = approve ? 'Đã trả hàng' : 'Từ chối trả hàng';
    final String newReturnRequestStatus = approve ? 'Đã chấp nhận' : 'Bị từ chối';

    Map<String, dynamic> updatedReturnRequest = Map.from(returnRequestData);
    updatedReturnRequest['status'] = newReturnRequestStatus;

    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'timeline': timeline,
      'returnRequest': updatedReturnRequest,
    });

    if (approve) {
      try {
        // Trừ lại tiền doanh thu của Người bán khi chấp nhận trả hàng
        await _db.collection('users').doc(sellerId).update({
          'revenue': FieldValue.increment(-totalAmount),
        });
      } catch (e) {
        print('Firebase Rules blocked writing to seller document during return refund: $e');
      }
    }
  }

  String getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }
}