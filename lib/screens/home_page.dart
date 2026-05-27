import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Đã thêm import

import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../constants/app_colors.dart';
import 'add_product_page.dart';

class EraHomePage extends StatelessWidget {
  const EraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final searchQuery = Provider.of<SearchProvider>(context).query;

    // Lọc sản phẩm dựa trên nội dung tìm kiếm (cải thiện độ chính xác)
    final filteredProducts = productProvider.products.where((p) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            searchQuery.isEmpty ? "Gợi ý cho bạn" : "Kết quả tìm kiếm cho '$searchQuery'",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        if (userProvider.isSeller)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
                            },
                            icon: const Icon(Icons.add_a_photo, size: 18),
                            label: const Text("Đăng đồ bán"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text("Không tìm thấy sản phẩm nào khớp với từ khóa của bạn.",
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return EraProductCard(product: filteredProducts[index]);
                        },
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
