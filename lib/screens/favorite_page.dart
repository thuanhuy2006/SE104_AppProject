import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);

    // Lọc ra các sản phẩm nằm trong danh sách yêu thích
    final favoriteProducts = ProductData.products
        .where((p) => favProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: const Text("Sản phẩm yêu thích", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: favoriteProducts.isEmpty
          ? const EtsyEmptyState(
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
            mainAxisSpacing: 20
        ),
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) => EtsyProductCard(product: favoriteProducts[index]),
      ),
    );
  }
}