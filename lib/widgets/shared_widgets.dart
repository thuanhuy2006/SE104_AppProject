import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../screens/product_detail_page.dart';
import '../screens/cart_page.dart';

// ============================================================================
// WIDGET DÙNG CHUNG: HEADER CÓ THANH TÌM KIẾM & GIỎ HÀNG
// ============================================================================
class EtsyHeader extends StatelessWidget {
  const EtsyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5)
                ),
                child: TextField(
                  controller: searchProvider.searchController,
                  style: const TextStyle(color: etsyText),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm món đồ đặc biệt",
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: etsyText, size: 22),
                    suffixIcon: searchProvider.query.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.cancel, color: Colors.grey, size: 20), onPressed: () => searchProvider.clearSearch())
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Icon Giỏ hàng
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EtsyCartPage()));
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: etsyText, size: 28),
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
            const SizedBox(width: 15),

            CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.grey.shade600, size: 28)
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG: THẺ SẢN PHẨM
// ============================================================================
class EtsyProductCard extends StatelessWidget {
  final Product product;
  const EtsyProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final isFav = Provider.of<FavoriteProvider>(context).isFavorite(product.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade200)
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade400))
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: InkWell(
                    onTap: () => Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                          ]
                      ),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.black, size: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: etsyText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),

          // XỬ LÝ LOGIC MÀU SẮC GIÁ TIỀN
          Row(
            children: [
              if (product.oldPrice != null) ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: etsyGreen, fontWeight: FontWeight.bold, fontSize: 14)), // Giá giảm màu xanh lá
                const SizedBox(width: 5),
                Text(formatCurrency.format(product.oldPrice), style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
              ] else ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: etsyText, fontWeight: FontWeight.bold, fontSize: 14)), // Giá thường màu đen
              ]
            ],
          )
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG: MÀN HÌNH TRỐNG (EMPTY STATE)
// ============================================================================
class EtsyEmptyState extends StatelessWidget {
  final IconData? iconData;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final double iconSize;

  const EtsyEmptyState({
    super.key, this.iconData, this.customIcon, required this.title, this.subtitle, this.buttonText, this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null)
              customIcon!
            else if (iconData != null)
              Icon(iconData, size: iconSize, color: etsyText),

            const SizedBox(height: 25),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Georgia', color: etsyText)),

            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4))
            ],

            if (buttonText != null) ...[
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: etsyText, foregroundColor: Colors.white, shape: const StadiumBorder()),
                      child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                  )
              )
            ]
          ],
        ),
      ),
    );
  }
}