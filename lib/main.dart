import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EtsyCloneApp());
}

// Màu sắc chủ đạo
const Color etsyBackground = Color(0xFF221F27);
const Color etsyCardColor = Color(0xFF33303A);
const Color etsyText = Colors.white;
const Color etsyGreen = Color(0xFF81C784);

class EtsyCloneApp extends StatelessWidget {
  const EtsyCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etsy Clone UI',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: etsyBackground,
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            surface: etsyBackground,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

// ============================================================================
// MODELS & PROVIDERS
// ============================================================================
class Product {
  final String id;
  final String title;
  final int price;
  final int? oldPrice;
  final String imageUrl;
  final String category;
  final String description; // THUỘC TÍNH MÔ TẢ BẮT BUỘC

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.category,
    required this.description,
  });
}

class ProductData {
  static final List<Product> products = [
    // Trang sức
    Product(
      id: 'p1', title: 'Nhẫn kim tiền', price: 800000, category: 'Trang sức',
      imageUrl: 'https://img.vuahanghieu.com/unsafe/0x0/left/top/smart/filters:quality(90)/https://admin.vuahanghieu.com/upload/news/content/2024/01/nhan-kim-tien-la-gi-deo-nhan-kim-tien-ngon-nao-de-thu-hut-tai-loc-1-jpg-1706589596-30012024113956.jpg',
      description: 'Nhẫn kim tiền vàng 18K mang ý nghĩa thu hút tài lộc, may mắn cho người đeo. Thiết kế tinh xảo, viền nhẫn lấp lánh sang trọng, rất phù hợp để làm quà tặng cho người thân hoặc tự thưởng cho bản thân nhân dịp năm mới.',
    ),
    Product(
      id: 'p2', title: 'Dây chuyền vàng cưới', price: 32800000, category: 'Trang sức',
      imageUrl: 'https://apj.vn/wp-json/wc-sku-watermark/v1/image/5309099713/shop_single/RENIOTM5',
      description: 'Dây chuyền vàng 24K cao cấp chuẩn tuổi, được chế tác tỉ mỉ với các họa tiết hoa văn truyền thống. Tôn lên vẻ đẹp rạng rỡ, sang trọng và quý phái của cô dâu trong ngày trọng đại nhất cuộc đời.',
    ),

    // Quần áo
    Product(
      id: 'p3', title: 'Áo polo nam cộc tay', price: 1500000, category: 'Quần áo',
      imageUrl: 'https://nhatminhsports.vn/wp-content/uploads/2025/07/1-2.png',
      description: 'Áo polo nam form chuẩn ôm dáng, chất liệu 100% cotton cao cấp cực kỳ thoáng mát và thấm hút mồ hôi. Thiết kế cổ bẻ thanh lịch, phù hợp cho cả môi trường công sở lẫn những buổi đi chơi dạo phố cùng bạn bè.',
    ),
    Product(
      id: 'p4', title: 'Áo thun nam Navy cỡ lớn', price: 289000, oldPrice: 489000, category: 'Quần áo',
      imageUrl: 'https://thoitrangbigsize.vn/wp-content/uploads/2021/10/BSX653D0.jpg',
      description: 'Áo thun Big Size dành riêng cho nam giới có thân hình đậm. Chất vải thun lạnh co giãn 4 chiều mang lại cảm giác thoải mái tối đa khi vận động. Màu Navy nam tính, dễ phối đồ và che khuyết điểm cực tốt.',
    ),
    Product(
      id: 'p5', title: 'Quần Jeans Baggy ống suông', price: 195000, category: 'Quần áo',
      imageUrl: 'https://dosi-in.com/file/detailed/508/dosiin-black-monkey-quan-jeans-localbrand-baggy-ong-suong-black-monkey-508029508029.jpg?w=670&h=670&fit=fill&fm=webp',
      description: 'Quần jeans form Baggy ống suông rộng rãi, mang đậm phong cách streetwear Hàn Quốc. Chất denim dày dặn nhưng không gây bí bách. Dễ dàng mix&match với áo thun oversize hoặc hoodie.',
    ),
    Product(
      id: 'p6', title: 'Quần âu nam cạp quay trơn', price: 150000, category: 'Quần áo',
      imageUrl: 'https://product.hstatic.net/200000471735/product/mtr006k4-7-c05__1__b146c85944b545189a503468eb8ddde3_1024x1024.jpg',
      description: 'Quần tây nam chất vải tuyết mưa chống nhăn, giữ ly tốt sau nhiều lần giặt. Form dáng Slimfit tôn chiều cao, đem lại vẻ ngoài lịch lãm, chuyên nghiệp cho dân văn phòng.',
    ),

    // Phụ kiện
    Product(
      id: 'p7', title: 'Đồng hồ Casio G-SHOCK', price: 14200000, oldPrice: 12200000, category: 'Phụ kiện',
      imageUrl: 'https://cdn.casio-vietnam.vn/wp-content/uploads/2019/08/GST-B100D-1A.png',
      description: 'Mẫu đồng hồ G-SHOCK thép không gỉ huyền thoại. Tích hợp công nghệ Tough Solar sạc bằng ánh sáng, kết nối Bluetooth với smartphone. Khả năng chống nước độ sâu 200m và chống va đập tuyệt đối.',
    ),
    Product(
      id: 'p8', title: 'Nón Snapback đen', price: 2500000, category: 'Phụ kiện',
      imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/MC229K-DN3/thumbs/800_nonson_1.png',
      description: 'Nón Snapback đen cool ngầu, thêu logo 3D nổi bật. Form nón cứng cáp, lót trong êm ái thấm hút mồ hôi. Phụ kiện không thể thiếu cho những bộ outfit mang phong cách đường phố.',
    ),
    Product(
      id: 'p9', title: 'Nón vành đỏ', price: 1250000, category: 'Phụ kiện',
      imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/XH001-104-DO2/thumbs/800_nonson__2.png',
      description: 'Nón rộng vành sắc đỏ rực rỡ, làm từ chất liệu cói mềm cao cấp. Che nắng hoàn hảo cho khuôn mặt và cổ, là trợ thủ đắc lực giúp bạn có những bức ảnh sống ảo tuyệt đẹp trong các chuyến du lịch biển.',
    ),
    Product(
      id: 'p10', title: 'Dây nịt nam da bò', price: 150000, category: 'Phụ kiện',
      imageUrl: 'https://wtco.com.vn/wp-content/uploads/2024/07/that-lung-nam-infinity-6.jpg',
      description: 'Thắt lưng nam làm từ da bò thật nguyên tấm bền bỉ, càng dùng lâu da càng mềm và bóng. Mặt khóa kim loại nguyên khối chống gỉ sét, thiết kế tối giản dễ phối với quần âu lẫn quần jeans.',
    ),
    Product(
      id: 'p11', title: 'Dây nịt nữ bản nhỏ 25mm', price: 175000, category: 'Phụ kiện',
      imageUrl: 'https://image.celine.com/20228e92009b1822/original/45AGM3A01-38SI_1_SS24_P1_M.jpg?im=Resize=(1200)',
      description: 'Thắt lưng nữ bản nhỏ tinh tế, mang lại nét nhấn nhá nhẹ nhàng cho vòng eo. Rất phù hợp để thắt ngoài váy liền, áo blazer dài hoặc phối với quần tây lưng cao.',
    ),

    // Giày dép
    Product(
      id: 'p12', title: 'Giày nam da thật cao cấp', price: 2250000, category: 'Giày dép',
      imageUrl: 'https://bizweb.dktcdn.net/thumb/1024x1024/100/527/490/products/giay-nam-cao-cap-da-that-lecos-lg12-2-1731769946743.jpg?v=1731771526053',
      description: 'Giày da nam Derby cao cấp, bề mặt da bóng bẩy sang trọng. Lót giày tích hợp đệm khí êm ái, đế cao su đúc nguyên khối chống trơn trượt. Sự lựa chọn hoàn hảo cho những cuộc họp quan trọng.',
    ),
    Product(
      id: 'p13', title: 'Giày thể thao nam', price: 1500000, category: 'Giày dép',
      imageUrl: 'https://product.hstatic.net/200000068876/product/907_4fbf07e8437d4b138238e97217f194c3_master.png',
      description: 'Mẫu giày sneaker thể thao với thân giày đan lưới thoáng khí, giúp chân không bị hầm bí. Công nghệ đế Eva đàn hồi cực tốt, nâng đỡ bàn chân hiệu quả trong các hoạt động chạy bộ, tập gym.',
    ),
    Product(
      id: 'p14', title: 'Giày nữ cao gót đế vuông', price: 2450000, category: 'Giày dép',
      imageUrl: 'https://satajor.com/wp-content/uploads/2019/09/SJ0095-web-tr%E1%BA%AFng-2.jpg',
      description: 'Giày cao gót 5cm với thiết kế đế vuông trụ vững chắc, giúp chị em tự tin sải bước cả ngày dài mà không lo đau mỏi. Kiểu dáng mũi nhọn thanh lịch, màu trắng dễ dàng mix cùng mọi loại trang phục.',
    ),
  ];
}

class CartItem {
  final String id, title, imageUrl;
  final int price;
  int quantity;
  CartItem({required this.id, required this.title, required this.price, required this.imageUrl, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  void addItem(String id, String title, int price, String imageUrl) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
    } else {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }
}

class FavoriteProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) _favoriteIds.remove(id);
    else _favoriteIds.add(id);
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String get query => searchController.text.toLowerCase().trim();
  SearchProvider() { searchController.addListener(() { notifyListeners(); }); }
  void clearSearch() {
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EtsyHomePage(),
    const EtsyShopPage(),
    const EtsyUpdatesPage(),
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
        onTap: (index) {
          if (_currentIndex != index) Provider.of<SearchProvider>(context, listen: false).clearSearch();
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined), label: 'Trang chủ'),
          const BottomNavigationBarItem(icon: Icon(Icons.search, size: 26), label: 'Cửa hàng'),
          BottomNavigationBarItem(icon: Icon(_currentIndex == 2 ? Icons.favorite : Icons.favorite_border), label: 'Yêu thích'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ hàng'),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG
// ============================================================================
class EtsyHeader extends StatelessWidget {
  const EtsyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(color: etsyCardColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade700, width: 0.5)),
                child: TextField(
                  controller: searchProvider.searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm món đồ đặc biệt",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: Colors.white, size: 22),
                    suffixIcon: searchProvider.query.isNotEmpty ? IconButton(icon: const Icon(Icons.cancel, color: Colors.grey, size: 20), onPressed: () => searchProvider.clearSearch()) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade300, child: Icon(Icons.person, color: Colors.grey.shade400, size: 28))
          ],
        ),
      ),
    );
  }
}

class GreetingBanner extends StatelessWidget {
  final String userName;
  const GreetingBanner({super.key, required this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Chào buổi sáng";
    if (hour >= 12 && hour < 18) return "Chào buổi chiều";
    if (hour >= 18 && hour < 22) return "Chào buổi tối";
    return "Chúc ngủ ngon";
  }

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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${_getGreeting()},\n$userName!", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia', height: 1.2)),
                    const SizedBox(height: 10),
                    const Text("Bạn muốn tìm mua gì hôm nay?", style: TextStyle(color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  final p = Product(
                      id: 'banner1', title: 'Bộ quà tặng mùa đông', price: 990000,
                      imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60', category: 'Khám phá',
                      description: 'Khám phá bộ sưu tập những món đồ được chọn lọc riêng dựa trên sở thích của bạn. Thích hợp làm quà tặng ý nghĩa cho người thân thương.'
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
                },
                child: Image.network('https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60', fit: BoxFit.cover, height: double.infinity, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final searchQuery = Provider.of<SearchProvider>(context).query;
    final favProvider = Provider.of<FavoriteProvider>(context);

    List<Product> searchResults = ProductData.products.where((p) {
      return p.title.toLowerCase().contains(searchQuery) || p.category.toLowerCase().contains(searchQuery);
    }).toList();

    searchResults.sort((a, b) {
      bool aFav = favProvider.isFavorite(a.id);
      bool bFav = favProvider.isFavorite(b.id);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return 0;
    });

    if (searchResults.isEmpty) {
      return const EtsyEmptyState(iconData: Icons.search_off, title: "Không tìm thấy kết quả", subtitle: "Hãy thử kiểm tra lại chính tả hoặc dùng một từ khóa khác nhé.");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kết quả cho \"$searchQuery\"", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 20),
            itemCount: searchResults.length,
            itemBuilder: (context, index) => EtsyProductCard(product: searchResults[index]),
          ),
        ],
      ),
    );
  }
}

class EtsyProductCard extends StatelessWidget {
  final Product product;
  const EtsyProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final isFav = Provider.of<FavoriteProvider>(context).isFavorite(product.id);

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[800]),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: InkWell(
                    onTap: () => Provider.of<FavoriteProvider>(context, listen: false).toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.black, size: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (product.oldPrice != null) ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: etsyGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 5),
                Text(formatCurrency.format(product.oldPrice), style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
              ] else ...[
                Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]
            ],
          )
        ],
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH CHI TIẾT SẢN PHẨM (NƠI HIỂN THỊ MÔ TẢ)
// ============================================================================
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final favProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favProvider.isFavorite(product.id);

    return Scaffold(
      backgroundColor: etsyBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.network(
                product.imageUrl,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 15, right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                    ),
                    InkWell(
                      onTap: () => favProvider.toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                        child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatCurrency.format(product.price), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text("Đã bao gồm VAT", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 15),
                  Text(product.title, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4, fontWeight: FontWeight.bold)),

                  // ĐÂY LÀ PHẦN MÔ TẢ ĐÃ ĐƯỢC HIỂN THỊ TRONG CHI TIẾT SẢN PHẨM
                  const SizedBox(height: 20),
                  const Text("Chi tiết sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(product.description, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(15).copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade800, width: 0.5))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.title, product.price, product.imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), duration: Duration(milliseconds: 1500)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                    child: const Text("Thêm vào giỏ hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.title, product.price, product.imageUrl);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã mua ngay thành công!"), duration: Duration(milliseconds: 1500)));
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 1.5), shape: const StadiumBorder()),
                    child: const Text("Mua ngay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: HOME PAGE
// ============================================================================
class EtsyHomePage extends StatelessWidget {
  const EtsyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);
    final isSearching = searchProvider.query.isNotEmpty;

    List<Product> displayProducts = List.from(ProductData.products);
    displayProducts.sort((a, b) {
      bool aFav = favProvider.isFavorite(a.id);
      bool bFav = favProvider.isFavorite(b.id);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return 0;
    });

    return Scaffold(
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: isSearching
                  ? const SearchResultsGrid()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GreetingBanner(userName: 'Sang'),
                  const SizedBox(height: 25),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Cảm hứng ngay trong tầm tay bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 20),
                      itemCount: displayProducts.length,
                      itemBuilder: (context, index) => EtsyProductCard(product: displayProducts[index]),
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

// ============================================================================
// TAB 2: SHOP PAGE (ĐÃ LẤY SẢN PHẨM THẬT TỪ PRODUCTDATA)
// ============================================================================
class EtsyShopPage extends StatelessWidget {
  const EtsyShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSearching = Provider.of<SearchProvider>(context).query.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20, top: 15),
              child: isSearching
                  ? const SearchResultsGrid()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Mua sắm theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
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

                  // ĐÃ SỬ DỤNG DỮ LIỆU THẬT ĐỂ ĐẢM BẢO CÓ ĐÚNG GIÁ VÀ MÔ TẢ
                  _buildImageSection(context, 'Trang sức', ProductData.products[0], ProductData.products[1]),
                  _buildImageSection(context, 'Quần áo', ProductData.products[2], ProductData.products[4]),
                  _buildImageSection(context, 'Phụ kiện', ProductData.products[6], ProductData.products[9]),
                  _buildImageSection(context, 'Giày dép', ProductData.products[11], ProductData.products[12]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String emoji) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsPage(categoryName: title))),
      child: Container(
        width: 170, height: 60,
        decoration: BoxDecoration(color: etsyCardColor, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, String sectionTitle, Product p1, Product p2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsPage(categoryName: sectionTitle))),
                child: const Text("Khám phá thêm", style: TextStyle(fontSize: 14, color: Color(0xFFA19CFF), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(child: _buildImageItem(context, p1)),
              const SizedBox(width: 15),
              Expanded(child: _buildImageItem(context, p2)),
            ],
          ),
        ),
        const SizedBox(height: 35),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, Product product) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[800]),
                clipBehavior: Clip.hardEdge,
                child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)))
            ),
          ),
          const SizedBox(height: 8),
          Text(product.title, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH DANH MỤC SẢN PHẨM
// ============================================================================
class CategoryProductsPage extends StatelessWidget {
  final String categoryName;
  const CategoryProductsPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final products = ProductData.products.where((p) => p.category == categoryName).toList();
    final favProvider = Provider.of<FavoriteProvider>(context);

    products.sort((a, b) {
      bool aFav = favProvider.isFavorite(a.id);
      bool bFav = favProvider.isFavorite(b.id);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: etsyBackground, elevation: 0),
      body: products.isEmpty
          ? const Center(child: Text("Đang cập nhật sản phẩm...", style: TextStyle(color: Colors.grey)))
          : GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 20),
        itemCount: products.length,
        itemBuilder: (context, index) => EtsyProductCard(product: products[index]),
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG: EMPTY STATE
// ============================================================================
class EtsyEmptyState extends StatelessWidget {
  final IconData? iconData;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final double iconSize;

  const EtsyEmptyState({
    super.key, this.iconData, this.customIcon, required this.title, this.subtitle, this.buttonText, this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null) customIcon! else if (iconData != null) Icon(iconData, size: iconSize, color: Colors.white),
            const SizedBox(height: 25),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Georgia', color: Colors.white)),
            if (subtitle != null) ...[const SizedBox(height: 10), Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4))],
            if (buttonText != null) ...[
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()), child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))
            ]
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 3: UPDATES PAGE
// ============================================================================
class EtsyUpdatesPage extends StatelessWidget {
  const EtsyUpdatesPage({super.key});

  Widget _buildBoxWithSparklesIcon() {
    return SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: const [Icon(Icons.inbox_outlined, size: 80, color: Colors.white), Positioned(top: 5, left: 5, child: Icon(Icons.auto_awesome, size: 24, color: Colors.white)), Positioned(top: 35, right: 0, child: Icon(Icons.auto_awesome, size: 20, color: Colors.white))]));
  }

  Widget _buildSearchBookIcon() {
    return SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [const Icon(Icons.menu_book_outlined, size: 80, color: Colors.white), Positioned(bottom: 5, right: 5, child: Container(decoration: const BoxDecoration(color: etsyBackground, shape: BoxShape.circle), child: const Icon(Icons.search, size: 40, color: Colors.white)))]));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(backgroundColor: etsyBackground, elevation: 0, titleSpacing: 0, toolbarHeight: 0, bottom: const TabBar(isScrollable: true, indicatorColor: Colors.deepOrange, indicatorWeight: 3, labelColor: Colors.white, unselectedLabelColor: Colors.grey, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), dividerColor: Colors.transparent, tabAlignment: TabAlignment.start, tabs: [Tab(text: "Cập nhật"), Tab(text: "Sản phẩm"), Tab(text: "Cửa hàng"), Tab(text: "Tìm kiếm")])),
        body: TabBarView(
          children: [
            const EtsyEmptyState(iconData: Icons.notifications_active_outlined, title: "Chưa có thông báo nào", subtitle: "Hãy quay lại để xem cập nhật về các sản phẩm\nvà cửa hàng yêu thích của bạn—như khuyến mãi,\nưu đãi đặc biệt và sản phẩm mới.", buttonText: "Bắt đầu khám phá"),
            EtsyEmptyState(customIcon: _buildBoxWithSparklesIcon(), title: "Chưa có sản phẩm yêu thích", subtitle: "Đề xuất cho bạn sẽ chính xác hơn khi bạn thả tim nhiều thứ hơn."),
            EtsyEmptyState(customIcon: _buildBoxWithSparklesIcon(), title: "Chưa có cửa hàng yêu thích", subtitle: "Đề xuất cho bạn sẽ chính xác hơn khi bạn thả tim nhiều thứ hơn."),
            EtsyEmptyState(customIcon: _buildSearchBookIcon(), title: "Chưa lưu tìm kiếm nào"),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 4: CART PAGE
// ============================================================================
class EtsyCartPage extends StatelessWidget {
  const EtsyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: EtsyEmptyState(iconData: Icons.shopping_cart_outlined, title: "Giỏ hàng của bạn đang trống", subtitle: "Bạn đang tìm kiếm ý tưởng mua sắm?", buttonText: "Xem các sản phẩm thịnh hành", iconSize: 100)));
  }
}