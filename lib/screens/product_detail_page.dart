import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ĐÃ THÊM THƯ VIỆN Ở ĐÂY

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
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

    return Scaffold(
      backgroundColor: etsyBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // ĐÃ SỬA LỖI TẠI ĐÂY: Dùng CachedNetworkImage
              CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  color: etsyCardColor,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  color: etsyCardColor,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),

              Positioned(
                top: 50,
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
                top: 50,
                right: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () => favProvider.toggleFavorite(product.id),
                  ),
                ),
              ),
              Positioned(
                top: 110,
                right: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
                  const SizedBox(height: 10),
                  Text(
                    formatCurrency.format(product.price),
                    style: const TextStyle(color: Colors.deepOrange, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("Mô tả sản phẩm", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
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
                        cart.addItem(
                          product.id,
                          product.title,
                          product.price,
                          product.imageUrl,
                          product.sellerId,
                          product.sellerName,
                        );
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
                        cart.addItem(
                          product.id,
                          product.title,
                          product.price,
                          product.imageUrl,
                          product.sellerId,
                          product.sellerName,
                        );
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
}