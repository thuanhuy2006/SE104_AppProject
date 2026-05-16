import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import 'add_product_page.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    final myProducts = currentUser != null 
        ? productProvider.getProductsBySeller(currentUser.uid)
        : [];
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: const Text("Sản phẩm của tôi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myProducts.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: myProducts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (ctx, i) {
                final product = myProducts[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 70, height: 70, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 5),
                            Text(formatCurrency.format(product.price), 
                              style: const TextStyle(color: etsyGreen, fontSize: 14)),
                            Text("Danh mục: ${product.category}", 
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          _showDeleteConfirm(context, productProvider, product.id);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          const Text("Bạn chưa đăng sản phẩm nào", 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("Hãy bắt đầu kinh doanh bằng cách nhấn nút '+' bên dưới!", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ProductProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: etsyCardColor,
        title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: const Text("Bạn có chắc chắn muốn gỡ sản phẩm này khỏi cửa hàng?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              provider.deleteProduct(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa sản phẩm")));
            }, 
            child: const Text("XÓA", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}
