import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class CategoryProductsPage extends StatelessWidget {
  final String categoryName;
  const CategoryProductsPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = productProvider.products
        .where((p) => p.category == categoryName)
        .toList();
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const EtsyHeader(), // Giữ Header để người dùng có thể tìm kiếm hoặc vào User Menu
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("Chưa có sản phẩm nào trong danh mục này.", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return EtsyProductCard(product: filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
