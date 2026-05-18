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
    this.sellerName = 'Etsy Store',
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
      sellerName: map['sellerName'] ?? 'Etsy Store',
      stockQuantity: map['stockQuantity']?.toInt() ?? 1,
      vouchers: List<String>.from(map['vouchers'] ?? []),
      revenue: map['revenue']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount']?.toInt() ?? 0,
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
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.sellerId = '',
    this.sellerName = '',
    this.quantity = 1,
    this.isSelected = true,
  });
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<dynamic> items;
  final double totalAmount;
  final DateTime timestamp;
  final String status;
  final String? review;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    this.status = 'Đã đặt hàng',
    this.review,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      items: map['items'] ?? [],
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
      status: map['status'] ?? 'Đã đặt hàng',
      review: map['review'],
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