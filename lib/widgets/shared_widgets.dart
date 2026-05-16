import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../screens/product_detail_page.dart';
import '../screens/cart_page.dart';
import '../screens/login_page.dart';
import '../screens/settings_page.dart';
import '../screens/profile_screen.dart';
import '../screens/purchases_screen.dart';

class EtsyHeader extends StatelessWidget {
  const EtsyHeader({super.key});

  void _showUserMenu(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: etsyCardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header menu: Avatar + Name + Email
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: userProvider.isSeller ? Colors.deepOrange : Colors.grey.shade700,
                      child: Text(userProvider.currentUser?.name[0].toUpperCase() ?? "U", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userProvider.currentUser?.name ?? 'Người dùng', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(userProvider.currentUser?.email ?? '', 
                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              
              // Cài đặt tài khoản (Sửa Tên & Địa chỉ)
              _buildMenuTile(context, Icons.settings_outlined, "Cài đặt tài khoản", () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              }),

              // Đơn mua hàng
              _buildMenuTile(context, Icons.receipt_long_outlined, "Đơn mua hàng", () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
              }),

              const Divider(color: Colors.grey, height: 1),
              
              // Đăng xuất
              _buildMenuTile(context, Icons.logout, "Đăng xuất", () {
                userProvider.logout();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
              }, isDestructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 15)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

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
                    border: Border.all(color: Colors.grey.shade700, width: 0.5)
                ),
                child: TextField(
                  controller: searchProvider.searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm trên Etsy",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: Colors.white, size: 22),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EtsyCartPage())),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                  Consumer<CartProvider>(
                    builder: (_, cart, __) => cart.itemCount > 0
                        ? Positioned(
                            right: -5, top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // Icon Người dùng (Avatar)
            InkWell(
              onTap: () {
                if (userProvider.isLoggedIn) {
                  _showUserMenu(context, userProvider);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                }
              },
              child: CircleAvatar(
                  radius: 18,
                  backgroundColor: userProvider.isSeller ? Colors.deepOrange : Colors.grey.shade700,
                  child: userProvider.isLoggedIn 
                    ? Text(userProvider.currentUser!.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : const Icon(Icons.person, color: Colors.white, size: 24)
              ),
            )
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

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[800]),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: InkWell(
                    onTap: () => Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.black, size: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (product.oldPrice != null) ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: etsyGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 5),
                Text(formatCurrency.format(product.oldPrice), style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
              ] else ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]
            ],
          )
        ],
      ),
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
            if (customIcon != null) customIcon! else if (iconData != null) Icon(iconData, size: iconSize, color: Colors.white),
            const SizedBox(height: 25),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Georgia', color: Colors.white)),
            if (subtitle != null) ...[const SizedBox(height: 10), Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4))],
            if (buttonText != null) ...[
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()), child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))
            ]
          ],
        ),
      ),
    );
  }
}
