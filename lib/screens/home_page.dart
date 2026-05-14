import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../constants/app_colors.dart';
import 'add_product_page.dart';

class EtsyHomePage extends StatelessWidget {
  const EtsyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final searchQuery = Provider.of<SearchProvider>(context).query;

    // Lọc sản phẩm dựa trên nội dung tìm kiếm
    final filteredProducts = productProvider.products.where((p) {
      final title = p.title.toLowerCase();
      final category = p.category.toLowerCase();
      return title.contains(searchQuery) || category.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: etsyBackground,
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner chào mừng (Ẩn đi khi đang tìm kiếm để nhường chỗ cho kết quả)
                  if (searchQuery.isEmpty) const GreetingBanner(), 
                  
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
                          return EtsyProductCard(product: filteredProducts[index]);
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

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EAC8), 
          borderRadius: BorderRadius.circular(12)
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            const Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Chào mừng bạn!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Bạn muốn mua gì hay đăng bán gì hôm nay?", style: TextStyle(color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.network(
                'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60', 
                fit: BoxFit.cover, 
                height: double.infinity
              ),
            )
          ],
        ),
      ),
    );
  }
}
