import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../services/database.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'chat_room_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final favProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favProvider.isFavorite(product.id);
    final cartCount = Provider.of<CartProvider>(context).itemCount;

    return Scaffold(
      backgroundColor: etsyBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.45,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  color: etsyCardColor,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  color: etsyCardColor,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 15,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                        onPressed: () {
                          final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng đăng nhập để chat với người bán')),
                            );
                            return;
                          }
                          if (currentUser.uid == product.sellerId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bạn không thể tự chat với chính mình')),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomPage(
                                receiverId: product.sellerId,
                                receiverName: product.sellerName,
                                product: product,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => favProvider.toggleFavorite(product.id),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EtsyCartPage())),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                            if (cartCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency.format(product.price),
                    style: const TextStyle(color: Colors.deepOrange, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Đánh giá tổng quát
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${product.rating.toStringAsFixed(1)} / 5",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${product.reviewCount} đánh giá)",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 30),

                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.deepOrange,
                        radius: 16,
                        child: Icon(Icons.store, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        product.sellerName,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {}, // Xem shop
                        child: const Text("Xem Shop", style: TextStyle(color: Colors.deepOrange)),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 30),

                  const Text("Mô tả sản phẩm", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // PHẦN BÌNH LUẬN & ĐÁNH GIÁ (GIỐNG SHOPEE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bình luận từ khách hàng", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (product.reviewCount > 0)
                        TextButton(
                          onPressed: () {}, // Xem tất cả review
                          child: const Text("Xem tất cả", style: TextStyle(color: Colors.deepOrange)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  StreamBuilder<List<ReviewModel>>(
                    stream: DatabaseService().getProductReviews(product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text("Sản phẩm này chưa có bình luận nào.", style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }

                      final reviews = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length > 5 ? 5 : reviews.length, // Hiện tối đa 5 cái demo
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildCommentItem(
                            review.userName,
                            review.comment,
                            review.rating,
                            DateFormat('dd/MM/yyyy').format(review.timestamp),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Thanh điều khiển mua hàng phía dưới cùng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final cart = Provider.of<CartProvider>(context, listen: false);
                        cart.addItem(product); // ĐÃ SỬA: Truyền object product thay vì nhiều tham số
                        Provider.of<UserProvider>(context, listen: false).syncCartToFirebase(cart.items.values.toList());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), duration: Duration(milliseconds: 1500)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Thêm vào giỏ", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cart = Provider.of<CartProvider>(context, listen: false);
                        cart.addItem(product); // ĐÃ SỬA: Truyền object product
                        Provider.of<UserProvider>(context, listen: false).syncCartToFirebase(cart.items.values.toList());
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Mua ngay", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, String content, double rating, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (index) => Icon(
              index < rating.floor() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 14,
            )),
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }
}
