import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../constants/app_colors.dart';
// BỊ THIẾU DÒNG IMPORT FILE ADD_PRODUCT_PAGE Ở ĐÂY
import '../screens/add_product_page.dart';

class EtsyHomePage extends StatefulWidget {
  const EtsyHomePage({super.key});

  @override
  State<EtsyHomePage> createState() => _EtsyHomePageState();
}

class _EtsyHomePageState extends State<EtsyHomePage> {
  final ScrollController _scrollController = ScrollController();
  int _currentLimit = 4; // Số lượng hiển thị ban đầu
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện cuộn của người dùng
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Nếu cuộn đến tận cùng dưới cùng của trang
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Tạo độ trễ ảo 1 giây để hiển thị vòng xoay loading đẹp mắt giống app thực tế
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentLimit += 4; // Lấy thêm 4 món
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final searchQuery = Provider.of<SearchProvider>(context).query;

    // Lọc sản phẩm theo tìm kiếm
    final filteredProducts = productProvider.products.where((p) {
      final title = p.title.toLowerCase();
      final category = p.category.toLowerCase();
      return title.contains(searchQuery) || category.contains(searchQuery);
    }).toList();

    // TÍNH NĂNG PHÂN TRANG: Chỉ lấy đúng số lượng Limit để hiển thị
    final displayProducts = filteredProducts.take(_currentLimit).toList();

    return Scaffold(
      backgroundColor: etsyBackground,
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // GẮN CONTROLLER VÀO ĐÂY
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage()));
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
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          return EtsyProductCard(product: displayProducts[index]);
                        },
                      ),
                    ),

                  // HIỆN LOADING KHI ĐANG TẢI THÊM
                  if (_isLoadingMore && displayProducts.length < filteredProducts.length)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.deepOrange),
                      ),
                    ),

                  // HIỆN THÔNG BÁO KHI ĐÃ HẾT HÀNG
                  if (displayProducts.length >= filteredProducts.length && filteredProducts.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text("Bạn đã xem hết sản phẩm hôm nay 🚀", style: TextStyle(color: Colors.grey)),
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
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60',
                fit: BoxFit.cover,
                height: double.infinity,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}