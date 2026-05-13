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
    // Lấy thông tin role từ UserProvider (giả định đã có)
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner chào mừng hoặc khuyến mãi
                  const GreetingBanner(), 
                  
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Gợi ý cho bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        if (userProvider.isSeller)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
                            },
                            icon: const Icon(Icons.add_a_photo, size: 18),
                            label: const Text("Thêm đồ bán"),
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
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) {
                        return EtsyProductCard(product: productProvider.products[index]);
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
        decoration: BoxDecoration(color: const Color(0xFFF3EAC8), borderRadius: BorderRadius.circular(12)),
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
                    Text("Chào mừng bạn quay lại!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Hôm nay bạn muốn mua gì hay đăng bán gì không?", style: TextStyle(color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.network('https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60', fit: BoxFit.cover, height: double.infinity),
            )
          ],
        ),
      ),
    );
  }
}
