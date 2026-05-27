import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import 'home_page.dart';
import 'shop_page.dart';
import 'favorite_page.dart';
import 'cart_page.dart';
import 'you_screen.dart';
import 'chat_list_page.dart';
import 'my_products_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartCount = Provider.of<CartProvider>(context).itemCount;
    final isSeller = Provider.of<UserProvider>(context).isSeller;

    final List<Widget> pages = [
      const EraHomePage(),
      const EraShopPage(),
      isSeller ? const MyProductsPage() : const FavoritePage(),
      const YouScreen(),
      isSeller ? const ChatListPage() : const EraCartPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: eraBackground,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Trang chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 26),
              label: 'Cửa hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                isSeller 
                  ? (_currentIndex == 2 ? Icons.inventory_2 : Icons.inventory_2_outlined) 
                  : (_currentIndex == 2 ? Icons.favorite : Icons.favorite_border),
              ),
              label: isSeller ? 'Hàng hóa' : 'Yêu thích',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 ? Icons.person : Icons.person_outline,
              ),
              label: 'Bạn',
            ),
            if (isSeller)
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 4 ? Icons.chat : Icons.chat_bubble_outline,
                ),
                label: 'Liên hệ',
              )
            else
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Giỏ hàng',
              ),
          ],
        ),
      ),
    );
  }
}
