import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final int price;
  final int? oldPrice;
  final String imageUrl;
  final String category;
  final String description;
  final String sellerId;
  final String sellerName;
  final int stockQuantity;
  final List<String> vouchers;
  final double revenue;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.sellerId,
    this.sellerName = 'Era Store',
    this.stockQuantity = 1,
    this.vouchers = const [],
    this.revenue = 0.0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'stockQuantity': stockQuantity,
      'vouchers': vouchers,
      'revenue': revenue,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      price: map['price']?.toInt() ?? 0,
      oldPrice: map['oldPrice']?.toInt(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Era Store',
      stockQuantity: map['stockQuantity']?.toInt() ?? 1,
      vouchers: List<String>.from(map['vouchers'] ?? []),
      revenue: map['revenue']?.toDouble() ?? 0.0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount']?.toInt() ?? 0,
    );
  }
}

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}

class CartItem {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String category;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.sellerId = '',
    this.sellerName = '',
    this.category = '',
    this.quantity = 1,
    this.isSelected = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      price: map['price']?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity']?.toInt() ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime timestamp;
  final String status;
  final Map<String, dynamic>? review; // { 'rating': double, 'comment': String, 'timestamp': String }
  final Map<String, DateTime?> timeline;
  final Map<String, dynamic>? returnRequest; // { 'reason': String, 'images': List<String>, 'status': String, 'timestamp': String }

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    this.status = 'Đã đặt hàng',
    this.review,
    this.timeline = const {},
    this.returnRequest,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'timestamp': timestamp,
      'status': status,
      'review': review,
      'timeline': timeline.map((key, value) => MapEntry(key, value?.toIso8601String())),
      'returnRequest': returnRequest,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      items: (map['items'] as List?)?.map((i) => CartItem.fromMap(i)).toList() ?? [],
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
      status: map['status'] ?? 'Đã đặt hàng',
      review: map['review'],
      timeline: (map['timeline'] as Map?)?.map((key, value) =>
        MapEntry(key as String, value != null ? DateTime.parse(value as String) : null)) ?? {},
      returnRequest: map['returnRequest'],
    );
  }
}

class SavedAddress {
  final String fullName;
  final String address;
  final String phoneNumber;

  SavedAddress({
    required this.fullName,
    required this.address,
    required this.phoneNumber,
  });
}

class ProductData {
  static final List<Product> products = [];
}

class Voucher {
  final String code; // Mã voucher, ví dụ: "ERA20"
  final String sellerId; // ID người bán tạo ra
  final String sellerName; // Tên shop người bán
  final double minSpend; // Chi tiêu tối thiểu, ví dụ: 1000000.0
  final double discountPercent; // % giảm giá, ví dụ: 20.0
  final List<String> applicableCategories; // Các danh mục áp dụng: ['Quần áo', 'Giày dép'...]

  Voucher({
    required this.code,
    required this.sellerId,
    required this.sellerName,
    required this.minSpend,
    required this.discountPercent,
    required this.applicableCategories,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'minSpend': minSpend,
      'discountPercent': discountPercent,
      'applicableCategories': applicableCategories,
    };
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      code: map['code'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      minSpend: (map['minSpend'] ?? 0.0).toDouble(),
      discountPercent: (map['discountPercent'] ?? 0.0).toDouble(),
      applicableCategories: List<String>.from(map['applicableCategories'] ?? []),
    );
  }
}
