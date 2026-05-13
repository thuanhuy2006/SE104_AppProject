import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
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
              Image.network(
                product.imageUrl,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 15, right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        ClipOval(
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: InkWell(
                              onTap: () => favProvider.toggleFavorite(product.id),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ClipOval(
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EtsyCartPage())),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                                    Consumer<CartProvider>(
                                      builder: (_, cart, ch) => cart.itemCount == 0
                                          ? const SizedBox.shrink()
                                          : Positioned(
                                        right: -5,
                                        top: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: Text(
                                            '${cart.itemCount}',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatCurrency.format(product.price), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: product.oldPrice != null ? etsyGreen : etsyText)),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(formatCurrency.format(product.oldPrice), style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text("Đã bao gồm VAT", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 15),
                  Text(product.title, style: const TextStyle(color: etsyText, fontSize: 18, height: 1.4, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text("Chi tiết sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: etsyText)),
                  const SizedBox(height: 10),
                  Text(product.description, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(15).copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
            decoration: BoxDecoration(color: etsyCardColor, border: Border(top: BorderSide(color: Colors.grey.shade800, width: 0.5))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.title, product.price, product.imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), duration: Duration(milliseconds: 1500)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: etsyText, foregroundColor: Colors.black, shape: const StadiumBorder()),
                    child: const Text("Thêm vào giỏ hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.title, product.price, product.imageUrl);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EtsyCartPage()));
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: etsyText, side: const BorderSide(color: etsyText, width: 1.5), shape: const StadiumBorder()),
                    child: const Text("Mua ngay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
