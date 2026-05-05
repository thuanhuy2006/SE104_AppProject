import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'home_page.dart';
import 'shop_page.dart';
import 'favorite_page.dart'; // Import file mới thay vì updates_page
import 'cart_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EtsyHomePage(),
    const EtsyShopPage(),
    const FavoritePage(), // Đã thay trang Yêu thích thật vào đây
    const EtsyCartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: etsyBackground,
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
            icon: Icon(_currentIndex == 2 ? Icons.favorite : Icons.favorite_border),
            label: 'Yêu thích',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Giỏ hàng',
          ),
        ],
      ),
    );
  }
}