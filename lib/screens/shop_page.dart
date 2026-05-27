import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Đã thêm import

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'product_detail_page.dart';
import 'category_products_page.dart';

class EraShopPage extends StatelessWidget {
  const EraShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    final userProvider = Provider.of<UserProvider>(context);
    final searchQuery = Provider.of<SearchProvider>(context).query;

    // Logic tìm kiếm giống trang chủ để đảm bảo tính nhất quán (cải thiện độ chính xác)
    final filteredProducts = products.where((p) {
      final title = p.title.toLowerCase();
      final category = p.category.toLowerCase();
      final sellerName = p.sellerName.toLowerCase();
      return title.contains(searchQuery) ||
          sellerName.contains(searchQuery) ||
          category == searchQuery; // Khớp chính xác danh mục để không bị khớp nhầm (như tìm "áo" khớp "Quần áo")
    }).toList();

    return Scaffold(
      backgroundColor: eraBackground,
      body: Column(
        children: [
          const EraHeader(),
          Expanded(
            child: searchQuery.isNotEmpty
                ? _buildSearchResults(filteredProducts)
                : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mua sắm theo danh mục",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        if (userProvider.isSeller)
                          const Text("Chế độ bán hàng", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Wrap(
                      spacing: 10, runSpacing: 10,
                      children: [
                        _buildCategoryCard(context, 'Trang sức', '💍'),
                        _buildCategoryCard(context, 'Quần áo', '🧥'),
                        _buildCategoryCard(context, 'Phụ kiện', '👜'),
                        _buildCategoryCard(context, 'Giày dép', '👟'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildDynamicSection(context, 'Trang sức', products),
                  _buildDynamicSection(context, 'Quần áo', products),
                  _buildDynamicSection(context, 'Phụ kiện', products),
                  _buildDynamicSection(context, 'Giày dép', products),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Product> filteredProducts) {
    if (filteredProducts.isEmpty) {
      return const Center(child: Text("Không tìm thấy sản phẩm", style: TextStyle(color: Colors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 20
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => EraProductCard(product: filteredProducts[index]),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String emoji) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsPage(categoryName: title))),
      child: Container(
        width: (MediaQuery.of(context).size.width - 40) / 2,
        height: 60,
        decoration: BoxDecoration(
            color: eraCardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade800)
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSection(BuildContext context, String category, List<Product> allProducts) {
    final categoryProducts = allProducts.where((p) => p.category == category).toList();
    if (categoryProducts.isEmpty) return const SizedBox.shrink();

    final p1 = categoryProducts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsPage(categoryName: category))),
                child: const Text("Xem tất cả", style: TextStyle(fontSize: 14, color: Colors.deepOrange)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[800],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage( // ĐÃ SỬA Ở ĐÂY
                      imageUrl: p1.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(p1.title, style: const TextStyle(color: Colors.white, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("${p1.price} đ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 35),
      ],
    );
  }
}