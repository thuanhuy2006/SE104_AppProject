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
        ChangeNotifierProvider(create: (_) => AddressProvider()),
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
  final String description;

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
    Product(id: 'p1', title: 'Nhẫn kim tiền', price: 800000, category: 'Trang sức', imageUrl: 'https://img.vuahanghieu.com/unsafe/0x0/left/top/smart/filters:quality(90)/https://admin.vuahanghieu.com/upload/news/content/2024/01/nhan-kim-tien-la-gi-deo-nhan-kim-tien-ngon-nao-de-thu-hut-tai-loc-1-jpg-1706589596-30012024113956.jpg', description: 'Nhẫn kim tiền vàng 18K mang ý nghĩa thu hút tài lộc, may mắn cho người đeo. Thiết kế tinh xảo, viền nhẫn lấp lánh sang trọng.'),
    Product(id: 'p2', title: 'Dây chuyền vàng cưới', price: 32800000, category: 'Trang sức', imageUrl: 'https://apj.vn/wp-json/wc-sku-watermark/v1/image/5309099713/shop_single/RENIOTM5', description: 'Dây chuyền vàng 24K cao cấp chuẩn tuổi, được chế tác tỉ mỉ với các họa tiết hoa văn truyền thống.'),
    // Quần áo
    Product(id: 'p3', title: 'Áo polo nam cộc tay', price: 1500000, category: 'Quần áo', imageUrl: 'https://nhatminhsports.vn/wp-content/uploads/2025/07/1-2.png', description: 'Áo polo nam form chuẩn ôm dáng, chất liệu 100% cotton cao cấp cực kỳ thoáng mát và thấm hút mồ hôi.'),
    Product(id: 'p4', title: 'Áo thun nam Navy cỡ lớn', price: 289000, oldPrice: 489000, category: 'Quần áo', imageUrl: 'https://thoitrangbigsize.vn/wp-content/uploads/2021/10/BSX653D0.jpg', description: 'Áo thun Big Size dành riêng cho nam giới có thân hình đậm. Chất vải thun lạnh co giãn 4 chiều.'),
    Product(id: 'p5', title: 'Quần Jeans Baggy ống suông', price: 195000, category: 'Quần áo', imageUrl: 'https://dosi-in.com/file/detailed/508/dosiin-black-monkey-quan-jeans-localbrand-baggy-ong-suong-black-monkey-508029508029.jpg?w=670&h=670&fit=fill&fm=webp', description: 'Quần jeans form Baggy ống suông rộng rãi, mang đậm phong cách streetwear Hàn Quốc.'),
    Product(id: 'p6', title: 'Quần âu nam cạp quay trơn', price: 150000, category: 'Quần áo', imageUrl: 'https://product.hstatic.net/200000471735/product/mtr006k4-7-c05__1__b146c85944b545189a503468eb8ddde3_1024x1024.jpg', description: 'Quần tây nam chất vải tuyết mưa chống nhăn, giữ ly tốt sau nhiều lần giặt. Form dáng Slimfit tôn chiều cao.'),
    // Phụ kiện
    Product(id: 'p7', title: 'Đồng hồ Casio G-SHOCK', price: 14200000, oldPrice: 12200000, category: 'Phụ kiện', imageUrl: 'https://cdn.casio-vietnam.vn/wp-content/uploads/2019/08/GST-B100D-1A.png', description: 'Mẫu đồng hồ G-SHOCK thép không gỉ huyền thoại. Tích hợp công nghệ Tough Solar sạc bằng ánh sáng.'),
    Product(id: 'p8', title: 'Nón Snapback đen', price: 2500000, category: 'Phụ kiện', imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/MC229K-DN3/thumbs/800_nonson_1.png', description: 'Nón Snapback đen cool ngầu, thêu logo 3D nổi bật. Phụ kiện không thể thiếu cho phong cách đường phố.'),
    Product(id: 'p9', title: 'Nón vành đỏ', price: 1250000, category: 'Phụ kiện', imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/XH001-104-DO2/thumbs/800_nonson__2.png', description: 'Nón rộng vành sắc đỏ rực rỡ, làm từ chất liệu cói mềm cao cấp. Che nắng hoàn hảo cho khuôn mặt và cổ.'),
    Product(id: 'p10', title: 'Dây nịt nam da bò', price: 150000, category: 'Phụ kiện', imageUrl: 'https://wtco.com.vn/wp-content/uploads/2024/07/that-lung-nam-infinity-6.jpg', description: 'Thắt lưng nam làm từ da bò thật nguyên tấm bền bỉ. Mặt khóa kim loại nguyên khối chống gỉ sét.'),
    Product(id: 'p11', title: 'Dây nịt nữ bản nhỏ 25mm', price: 175000, category: 'Phụ kiện', imageUrl: 'https://image.celine.com/20228e92009b1822/original/45AGM3A01-38SI_1_SS24_P1_M.jpg?im=Resize=(1200)', description: 'Thắt lưng nữ bản nhỏ tinh tế, mang lại nét nhấn nhá nhẹ nhàng cho vòng eo.'),
    // Giày dép
    Product(id: 'p12', title: 'Giày nam da thật cao cấp', price: 2250000, category: 'Giày dép', imageUrl: 'https://bizweb.dktcdn.net/thumb/1024x1024/100/527/490/products/giay-nam-cao-cap-da-that-lecos-lg12-2-1731769946743.jpg?v=1731771526053', description: 'Giày da nam Derby cao cấp, bề mặt da bóng bẩy sang trọng. Sự lựa chọn hoàn hảo cho những cuộc họp quan trọng.'),
    Product(id: 'p13', title: 'Giày thể thao nam', price: 1500000, category: 'Giày dép', imageUrl: 'https://product.hstatic.net/200000068876/product/907_4fbf07e8437d4b138238e97217f194c3_master.png', description: 'Mẫu giày sneaker thể thao với thân giày đan lưới thoáng khí. Công nghệ đế Eva đàn hồi cực tốt.'),
    Product(id: 'p14', title: 'Giày nữ cao gót đế vuông', price: 2450000, category: 'Giày dép', imageUrl: 'https://satajor.com/wp-content/uploads/2019/09/SJ0095-web-tr%E1%BA%AFng-2.jpg', description: 'Giày cao gót 5cm với thiết kế đế vuông trụ vững chắc, giúp chị em tự tin sải bước cả ngày dài.'),
  ];
}

class CartItem {
  final String id, title, imageUrl;
  final int price;
  int quantity;
  CartItem({required this.id, required this.title, required this.price, required this.imageUrl, this.quantity = 1});
}

class SavedAddress {
  final String fullName;
  final String address;
  final String phoneNumber;

  SavedAddress({
    required this.fullName,
    required this.address,
    required this.phoneNumber,
  });
}

class AddressProvider with ChangeNotifier {
  SavedAddress? _defaultAddress;

  SavedAddress? get defaultAddress => _defaultAddress;

  void saveAddress(SavedAddress address) {
    _defaultAddress = address;
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  int get totalAmount {
    int total = 0;
    _items.forEach((key, item) => total += item.price * item.quantity);
    return total;
  }

  void addItem(String id, String title, int price, String imageUrl) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
    } else {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }

  void increaseQuantity(String id) {
    if (_items.containsKey(id)) {
      _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity + 1));
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items.update(id, (ex) => CartItem(id: ex.id, title: ex.title, price: ex.price, imageUrl: ex.imageUrl, quantity: ex.quantity - 1));
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.remove(id);
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
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const EtsyHomePage(),
    const EtsyShopPage(),
    const EtsyUpdatesPage(),
    const EtsyCartPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = Provider.of<CartProvider>(context).itemCount;

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
          BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cartCount > 0)
                    Positioned(
                      right: -5, top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    )
                ],
              ),
              label: 'Giỏ hàng'
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG (CÓ AVATAR)
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
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const YouScreen()));
              },
              child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.grey.shade400, size: 28)
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH "YOU" (MENU CÁ NHÂN)
// ============================================================================
class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bạn",
          style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _buildMenuItem("Hồ sơ", context),
          _buildDivider(),
          _buildMenuItem("Đơn mua", context),
          _buildDivider(),
          _buildMenuItem("Tin nhắn", context),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, BuildContext context) {
    return InkWell(
      onTap: () {
        if (title == "Hồ sơ") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        } else if (title == "Đơn mua") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tính năng '$title' đang phát triển")));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade800, height: 1, thickness: 1);
  }
}

// ============================================================================
// MÀN HÌNH "HỒ SƠ" (PROFILE SCREEN MỚI THIẾT KẾ)
// ============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thông tin người dùng", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
            color: etsyCardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Ảnh đại diện
              _buildProfileRow(label: "Đổi hình đại diện", isAvatar: true, onTap: () {}),
              const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15, thickness: 0.3),

              // Số điện thoại
              _buildProfileRow(label: "Số điện thoại", value: "********506", onTap: () {}),
              const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15, thickness: 0.3),

              // Tên (Lấy tên Trần Đình Sang theo context)
              _buildProfileRow(label: "Tên", value: "Trần Đình Sang", onTap: () {}),
              const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15, thickness: 0.3),

              // Email
              _buildProfileRow(label: "Email", value: "Nhập Email", isValueHint: true, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, String? value, bool isAvatar = false, bool isValueHint = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isAvatar)
              CircleAvatar(radius: 25, backgroundColor: Colors.grey.shade600, child: const Icon(Icons.person, color: Colors.white, size: 30))
            else
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),

            Row(
              children: [
                if (isAvatar)
                  const Text("Đổi hình đại diện", style: TextStyle(color: Colors.deepOrange, fontSize: 14))
                else if (value != null)
                  Text(value, style: TextStyle(color: isValueHint ? Colors.grey : Colors.white70, fontSize: 15)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
              ],
            ),
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
                      id: 'banner1', title: 'Bộ quà tặng', price: 990000,
                      imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=500&q=60', category: 'Khám phá',
                      description: 'Khám phá bộ sưu tập những món đồ được chọn lọc riêng dựa trên sở thích của bạn.'
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
// MÀN HÌNH CHI TIẾT SẢN PHẨM & POPUP THÊM VÀO GIỎ HÀNG
// ============================================================================
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  void _showAddToCartPopup(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF2F2D36),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return SafeArea(
            child: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.items.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                    });
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: Colors.deepOrange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${cart.itemCount} sản phẩm trong giỏ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Mua ngay trước khi hết hàng", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                          ],
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 105,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: cart.items.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 15),
                              itemBuilder: (context, index) {
                                final item = cart.items.values.toList()[index];
                                final productId = cart.items.keys.toList()[index];

                                return Container(
                                  width: 80,
                                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Image.network(item.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 80, color: Colors.grey[700], child: const Icon(Icons.image))),
                                          Positioned(
                                            top: 4, right: 4,
                                            child: InkWell(
                                              onTap: () => cart.removeItem(productId),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                child: const Icon(Icons.close, color: Colors.black, size: 12),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(ctx, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)), (route) => false);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                            child: const Text("Xem giỏ hàng & thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          );
        }
    );
  }

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
                width: double.infinity, height: MediaQuery.of(context).size.height * 0.55, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(height: MediaQuery.of(context).size.height * 0.55, color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
                    ),
                    InkWell(
                      onTap: () => favProvider.toggleFavorite(product.id),
                      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white, size: 24)),
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
                      _showAddToCartPopup(context);
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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
// TAB 2: SHOP PAGE
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
    final cart = Provider.of<CartProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    if (cart.items.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: EtsyEmptyState(
            iconData: Icons.shopping_cart_outlined,
            title: "Giỏ hàng của bạn đang trống",
            subtitle: "Bạn đang tìm kiếm ý tưởng mua sắm?",
            buttonText: "Xem các sản phẩm thịnh hành",
            iconSize: 100,
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("${cart.itemCount} sản phẩm trong giỏ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: etsyBackground,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 30),
                  itemBuilder: (ctx, i) {
                    final item = cart.items.values.toList()[i];
                    final productId = cart.items.keys.toList()[i];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15))),
                                  GestureDetector(
                                    onTap: () => cart.removeItem(productId),
                                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => cart.decreaseQuantity(productId),
                                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Icon(Icons.remove, color: Colors.white, size: 16)),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    InkWell(
                                      onTap: () => cart.increaseQuantity(productId),
                                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Icon(Icons.add, color: Colors.white, size: 16)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: etsyCardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tạm tính", style: TextStyle(color: Colors.grey, fontSize: 15)),
                        Text(formatCurrency.format(cart.totalAmount), style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Phí giao hàng", style: TextStyle(color: Colors.grey, fontSize: 15)),
                        Text("Miễn phí", style: TextStyle(color: Colors.green, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng cộng (${cart.itemCount} sản phẩm)", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(formatCurrency.format(cart.totalAmount), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                        child: const Text("Tiến hành thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}

// ============================================================================
// MODEL MỚI: ĐƠN HÀNG (PURCHASE)
// ============================================================================
class PurchaseOrder {
  final String id;
  final String date;
  final Product product;
  final int quantity;
  final int totalAmount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.date,
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.status,
  });
}

// ============================================================================
// MÀN HÌNH "ĐƠN MUA"
// ============================================================================
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  // final List<PurchaseOrder> mockPurchases = [];
  final List<PurchaseOrder> mockPurchases = [
    PurchaseOrder(
      id: 'ord1',
      date: '02 Th03, 2026',
      product: ProductData.products[1], // Dây chuyền vàng
      quantity: 1,
      totalAmount: 32800000,
      status: 'Đã giao',
    ),
    PurchaseOrder(
      id: 'ord2',
      date: '15 Th02, 2026',
      product: ProductData.products[4], // Quần Jeans
      quantity: 2,
      totalAmount: 390000,
      status: 'Đã giao',
    ),
  ];

  // Hàm hiển thị Popup giỏ hàng (giống hệt bên ProductDetailPage)
  void _showAddToCartPopup(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF2F2D36),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return SafeArea(
            child: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.items.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                    });
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: Colors.deepOrange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${cart.itemCount} sản phẩm trong giỏ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Mua ngay trước khi hết hàng", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                          ],
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 105,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: cart.items.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 15),
                              itemBuilder: (context, index) {
                                final item = cart.items.values.toList()[index];
                                final productId = cart.items.keys.toList()[index];

                                return Container(
                                  width: 80,
                                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Image.network(item.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 80, color: Colors.grey[700], child: const Icon(Icons.image))),
                                          Positioned(
                                            top: 4, right: 4,
                                            child: InkWell(
                                              onTap: () => cart.removeItem(productId),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                child: const Icon(Icons.close, color: Colors.black, size: 12),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(ctx, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)), (route) => false);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                            child: const Text("Xem giỏ hàng & thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your purchases",
          style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: mockPurchases.isEmpty ? _buildEmptyState() : _buildPurchaseList(),
    );
  }

  // Giao diện khi chưa có đơn hàng (Hình 1)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
                ),
                const Positioned(
                  top: 0, bottom: 0, left: 0, right: 0,
                  child: CircularProgressIndicator(
                    value: 0.8,
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                ),
                const Positioned(
                  top: 10, bottom: 10, left: 10, right: 10,
                  child: CircularProgressIndicator(
                    value: 0.4,
                    strokeWidth: 1.0,
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "You haven't made any\npurchases yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.2
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện khi đã có đơn hàng (Hình 2)
  Widget _buildPurchaseList() {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: mockPurchases.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 30, thickness: 1),
      itemBuilder: (context, index) {
        final order = mockPurchases[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A67D8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                      order.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.product.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: Colors.grey.shade800, child: const Icon(Icons.image)),
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.date, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(formatCurrency.format(order.totalAmount), style: const TextStyle(color: Colors.white, fontSize: 15)),
                        const SizedBox(height: 5),
                        Text("${order.quantity} item${order.quantity > 1 ? 's' : ''}", style: const TextStyle(color: Colors.white70, fontSize: 15)),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Track package", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      // 1. Thêm sản phẩm vào giỏ hàng
                      Provider.of<CartProvider>(context, listen: false).addItem(
                          order.product.id,
                          order.product.title,
                          order.product.price,
                          order.product.imageUrl
                      );

                      // 2. Gọi hàm hiển thị Popup
                      _showAddToCartPopup(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text("Buy this again", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0; // 0: Shipping, 1: Payment, 2: Review
  bool _isAddingNewAddress = false;

  // Controllers cho form gọn nhẹ
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addrProvider = Provider.of<AddressProvider>(context, listen: false);
      if (addrProvider.defaultAddress == null) {
        setState(() => _isAddingNewAddress = true);
      }
    });
  }

  void _continueToPayment() {
    if (_isAddingNewAddress) {
      // Lưu địa chỉ mới với thông tin rút gọn
      Provider.of<AddressProvider>(context, listen: false).saveAddress(
          SavedAddress(
            fullName: _nameController.text.isNotEmpty ? _nameController.text : "Trần Đình Sang",
            address: _addressController.text.isNotEmpty ? _addressController.text : "Đường Jeju D4, Xã Lê Lợi, An Giang",
            phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : "0901234567",
          )
      );
      setState(() {
        _isAddingNewAddress = false;
        _currentStep = 1; // Chuyển sang Payment
      });
    } else {
      // Đã chọn địa chỉ có sẵn, đi tiếp
      setState(() => _currentStep = 1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else if (_isAddingNewAddress && Provider.of<AddressProvider>(context, listen: false).defaultAddress != null) {
              setState(() => _isAddingNewAddress = false); // Quay lại danh sách
            } else {
              Navigator.pop(context); // Thoát checkout
            }
          },
        ),
        title: const Text("Checkout", style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: _currentStep == 0 ? _buildShippingStep() : _buildPaymentStep(),
          )
        ],
      ),
    );
  }

  // --- UI: Dãy Stepper ---
  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(0, "Shipping"),
          Expanded(child: Divider(color: Colors.grey.shade700, thickness: 1, indent: 10, endIndent: 10)),
          _buildStepItem(1, "Payment"),
          Expanded(child: Divider(color: Colors.grey.shade700, thickness: 1, indent: 10, endIndent: 10)),
          _buildStepItem(2, "Review"),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String title) {
    bool isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.transparent,
            border: Border.all(color: isActive ? Colors.white : Colors.grey.shade600, width: 2),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  // --- UI: Bước 1 (Shipping) ---
  Widget _buildShippingStep() {
    final addrProvider = Provider.of<AddressProvider>(context);

    if (_isAddingNewAddress || addrProvider.defaultAddress == null) {
      return _buildAddressForm();
    } else {
      return _buildChooseAddressView(addrProvider.defaultAddress!);
    }
  }

  // Giao diện khi ĐÃ CÓ ĐỊA CHỈ (Hình 1)
  Widget _buildChooseAddressView(SavedAddress address) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Choose an address", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),

        InkWell(
          onTap: _continueToPayment,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Default", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Text(address.fullName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Text(address.address, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                const SizedBox(height: 5),
                Text("SĐT: ${address.phoneNumber}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        InkWell(
          onTap: () => setState(() => _isAddingNewAddress = true),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: etsyBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade700, width: 1)
            ),
            child: const Text("Add a new address", style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // Giao diện NHẬP THÔNG TIN (Hình 2, 3)
  Widget _buildAddressForm() {
    return Column(
      children: [
        const Text("Enter an address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildInputGroup("Full name *", "Ví dụ: Trần Đình Sang", controller: _nameController),
              _buildInputGroup("Full Address *", "Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố", controller: _addressController),
              _buildInputGroup("Phone number *", "Nhập số điện thoại của bạn", controller: _phoneController, isPhone: true),

              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val!),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade600),
                  ),
                  const Text("Set as default", style: TextStyle(color: Colors.white70, fontSize: 14))
                ],
              ),
            ],
          ),
        ),
        // Nút bấm dưới cùng
        Padding(
          padding: const EdgeInsets.all(20).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (Provider.of<AddressProvider>(context, listen: false).defaultAddress != null) {
                    setState(() => _isAddingNewAddress = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: _continueToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCD5F6),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("Continue to Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInputGroup(String label, String hint, {TextEditingController? controller, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: Bước 2 (Payment Placeholder) ---
  Widget _buildPaymentStep() {
    return const Center(
      child: Text(
        "Giao diện Payment đang phát triển\n(Bạn đã lưu địa chỉ thành công!)",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      ),
    );
  }
}