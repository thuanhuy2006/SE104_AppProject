import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class SellerShopPage extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const SellerShopPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final sellerProducts = productProvider.products
        .where((p) => p.sellerId == sellerId)
        .toList();

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: Text(sellerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const EtsyHeader(), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  radius: 24,
                  child: Icon(Icons.store, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${sellerProducts.length} sản phẩm",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 30),
          Expanded(
            child: sellerProducts.isEmpty
                ? const Center(child: Text("Cửa hàng này chưa có sản phẩm nào.", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: sellerProducts.length,
                    itemBuilder: (context, index) {
                      return EtsyProductCard(product: sellerProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}