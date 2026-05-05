import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'app_models.dart';
import 'app_providers.dart';

class EtsyHeader extends StatelessWidget {
  const EtsyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.grey]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: Colors.black),
                    Text(" 19", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: etsyCardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade700, width: 0.5),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search for something special",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.white, size: 22),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.grey.shade400, size: 28),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EtsyProductCard extends StatelessWidget {
  final Product product;
  const EtsyProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final isFav = Provider.of<FavoriteProvider>(context).isFavorite(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[800]),
                clipBehavior: Clip.hardEdge,
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(product.id),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (product.oldPrice != null) ...[
              Text(formatCurrency.format(product.price), style: const TextStyle(color: etsyGreen, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                formatCurrency.format(product.oldPrice),
                style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
              ),
            ] else ...[
              Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          ],
        )
      ],
    );
  }
}

class EtsyEmptyState extends StatelessWidget {
  final IconData? iconData;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final double iconSize;

  const EtsyEmptyState({
    super.key,
    this.iconData,
    this.customIcon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.iconSize = 80,
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
              Icon(iconData, size: iconSize, color: Colors.white),
            const SizedBox(height: 25),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Georgia', color: Colors.white),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
              ),
            ],
            if (buttonText != null) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}