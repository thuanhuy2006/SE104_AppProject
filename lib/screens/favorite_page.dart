import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../services/database.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'purchases_screen.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  void _showUserMenu(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: eraCardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              _buildMenuTile(context, Icons.settings_outlined, "Cài đặt tài khoản", () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              }),
              _buildMenuTile(context, Icons.receipt_long_outlined, "Đơn mua hàng", () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
              }),
              const Divider(color: Colors.grey, height: 1),
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
    final favProvider = Provider.of<FavoriteProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    final favoriteProducts = productProvider.products
        .where((p) => favProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        backgroundColor: eraBackground,
        foregroundColor: eraText,
        elevation: 0,
        title: const Text("Sản phẩm yêu thích", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Icon Giỏ hàng (Chỉ hiển thị cho người mua)
          if (!userProvider.isSeller)
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EraCartPage())),
            ),
          const SizedBox(width: 5),
          // Icon Avatar người dùng
          GestureDetector(
            onTap: () {
              if (userProvider.isLoggedIn) {
                _showUserMenu(context, userProvider);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: userProvider.isSeller ? Colors.deepOrange : Colors.grey.shade700,
                child: userProvider.isLoggedIn
                    ? Text(
                        userProvider.currentUser!.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: favoriteProducts.isEmpty
          ? const EraEmptyState(
              iconData: Icons.favorite_border,
              title: "Chưa có sản phẩm yêu thích",
              subtitle: "Đề xuất cho bạn sẽ chính xác hơn khi bạn thả tim nhiều thứ hơn.",
              buttonText: "Khám phá ngay",
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) => EraProductCard(product: favoriteProducts[index]),
            ),
    );
  }
}
