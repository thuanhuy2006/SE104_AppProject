import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Đặt Hàng',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const MainScreen(),
      ),
    );
  }
}

// ============================================================================
// WIDGET DÙNG CHUNG CHO TRẠNG THÁI TRỐNG (EMPTY STATE)
// ============================================================================
class EmptyStateWidget extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final Widget? extraWidget;

  const EmptyStateWidget({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (extraWidget != null) extraWidget!,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 100, color: Colors.deepOrange.shade200),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
// 1. MAIN SCREEN (CHỨA THANH ĐIỀU HƯỚNG DƯỚI)
// ============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProductListPage(),      // Tab 0: Home
    const OrderPage(),            // Tab 1: Đơn hàng
    const FavoritePage(),
    const ProfilePage(),          // Tab 4: Tôi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Đã thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. ORDER PAGE (TRANG ĐƠN HÀNG)
// ============================================================================
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đơn hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          // tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          // labelPadding: const EdgeInsets.symmetric(horizontal: 15),
          tabs: const [
            Tab(text: "Đang đến"),
            Tab(text: "Lịch sử"),
            Tab(text: "Đánh giá"),
            Tab(text: "Đơn nháp"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomingTab(), // Tab 1: Đang đến
          _buildHistoryTab(),  // Tab 3: Lịch sử
          _buildReviewTab(),   // Tab 4: Đánh giá
          _buildDraftTab(),    // Tab 5: Đơn nháp
        ],
      ),
    );
  }

  // --- TAB 1: Đang đến ---
  Widget _buildIncomingTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Mới';
          return ['Mới', 'Đang làm', 'Đang giao'].contains(status);
        }).toList() ?? [];

        if (docs.isEmpty) {
          return const EmptyStateWidget(
            iconData: Icons.receipt_long_outlined,
            title: "Quên chưa đặt món rồi nè bạn ơi?",
            subtitle: "Bạn sẽ nhìn thấy các món đang được chuẩn bị hoặc giao đi tại đây.",
          );
        }

        final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>;
            final firstItemName = items.isNotEmpty ? items[0]['title'] : 'Món ăn';
            // Lấy ảnh từ item đầu tiên
            final firstItemImage = (items.isNotEmpty && items[0]['imageUrl'] != null) ? items[0]['imageUrl'] : '';
            final otherItemsCount = items.length - 1;

            Color statusColor = Colors.blue;
            if (data['status'] == 'Đang làm') statusColor = Colors.orange;
            if (data['status'] == 'Đang giao') statusColor = Colors.green;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(orderData: data, orderId: docs[index].id)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(data['status'] ?? 'Mới', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          Text(
                            DateFormat('dd/MM HH:mm').format(DateTime.parse(data['date'])),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          // --- HIỂN THỊ ẢNH TỪ FIREBASE ---
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: (firstItemImage as String).isNotEmpty
                                ? Image.network(firstItemImage, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey))
                                : const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherItemsCount > 0 ? "$firstItemName và $otherItemsCount món khác" : firstItemName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(formatCurrency.format(data['totalAmount']), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- TAB 3: Lịch sử ---
  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'Hoàn tất';
        }).toList();

        if (docs.isEmpty) {
          return const EmptyStateWidget(
            iconData: Icons.history,
            title: "Chưa có lịch sử",
            subtitle: "Các đơn hàng đã hoàn thành sẽ xuất hiện ở đây.",
          );
        }

        final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>;
            final firstItemName = items.isNotEmpty ? items[0]['title'] : 'Món ăn';
            final firstItemImage = (items.isNotEmpty && items[0]['imageUrl'] != null) ? items[0]['imageUrl'] : '';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.hardEdge,
                  child: (firstItemImage as String).isNotEmpty
                      ? Image.network(firstItemImage, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.check_circle, color: Colors.green))
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
                title: Text(firstItemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Đã hoàn tất - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(data['date']))}"),
                    Text(formatCurrency.format(data['totalAmount']), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đặt lại đang phát triển")));
                  },
                  child: const Text("Đặt lại"),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(orderData: data, orderId: docs[index].id)));
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 4: Đánh giá (CẢI TIẾN) ---
  Widget _buildReviewTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(text: "Chưa đánh giá"),
                Tab(text: "Đã đánh giá"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Danh sách đơn chưa đánh giá
                _buildUnreviewedList(),
                // 2. Danh sách đã đánh giá
                _buildReviewedHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget con: Danh sách chưa đánh giá
  Widget _buildUnreviewedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Chỉ lấy đơn Hoàn tất VÀ chưa có trường 'rating' (hoặc rating == null)
          return data['status'] == 'Hoàn tất' && data['rating'] == null;
        }).toList();

        if (docs.isEmpty) {
          return const EmptyStateWidget(
            iconData: Icons.star_border,
            title: "Tuyệt vời!",
            subtitle: "Bạn đã đánh giá hết các đơn hàng rồi.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>;
            final firstItemImage = (items.isNotEmpty && items[0]['imageUrl'] != null) ? items[0]['imageUrl'] : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: firstItemImage.isNotEmpty
                              ? Image.network(firstItemImage, width: 60, height: 60, fit: BoxFit.cover)
                              : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(items[0]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 5),
                              Text("Đơn hàng ${DateFormat('dd/MM HH:mm').format(DateTime.parse(data['date']))}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              const Text("Hãy chia sẻ cảm nhận của bạn nhé!", style: TextStyle(color: Colors.orange, fontSize: 13, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(orderId: docs[index].id, orderData: data)));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: const Text("Viết Đánh Giá", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget con: Lịch sử đã đánh giá
  Widget _buildReviewedHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Chỉ lấy đơn ĐÃ có rating
          return data['rating'] != null;
        }).toList();

        if (docs.isEmpty) {
          return const EmptyStateWidget(
            iconData: Icons.history,
            title: "Chưa có đánh giá nào",
            subtitle: "Lịch sử đánh giá của bạn sẽ xuất hiện ở đây.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>;
            final rating = data['rating'] ?? 5;
            final comment = data['comment'] ?? "";
            final tags = data['tags'] != null ? List<String>.from(data['tags']) : [];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(items[0]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(DateFormat('dd/MM').format(DateTime.parse(data['date'])), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 20))),
                    const SizedBox(height: 10),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          backgroundColor: Colors.grey[100],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    const SizedBox(height: 10),
                    Text(comment.isEmpty ? "Không có lời bình." : comment, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 5: Đơn nháp ---
  Widget _buildDraftTab() {
    return Stack(
      children: [
        const EmptyStateWidget(
          iconData: Icons.remove_shopping_cart_outlined,
          title: "\"Chả\" có gì trong giỏ hết!",
          subtitle: "Mau mau đặt món tụi mình cùng măm nào!",
        ),
        Positioned(
          top: 10,
          right: 15,
          child: TextButton(
            onPressed: () {},
            child: const Text("Xóa tất cả", style: TextStyle(color: Colors.deepOrange)),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. MODELS & PROVIDERS (ĐÃ SỬA LỖI: Thêm imageUrl)
// ============================================================================
class Product {
  final String id;
  final String title;
  final int price;
  final String imageUrl;

  Product({required this.id, required this.title, required this.price, required this.imageUrl});
}

class CartItem {
  final String id;
  final String title;
  final int price;
  final String imageUrl; // <-- CẬP NHẬT
  int quantity;

  CartItem({required this.id, required this.title, required this.price, required this.imageUrl, this.quantity = 1});
  int get total => price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  int _discount = 0; // --- MỚI: Biến lưu số tiền giảm giá

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;
  int get discount => _discount; // --- MỚI: Getter lấy giảm giá

  // Tính tổng tiền tạm tính (chưa trừ voucher)
  int get subTotal {
    var total = 0;
    _items.forEach((key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  // --- CẬP NHẬT: Tính tổng tiền cuối cùng (Đã trừ voucher)
  int get totalAmount {
    int finalTotal = subTotal - _discount;
    return finalTotal < 0 ? 0 : finalTotal; // Không để tiền âm
  }

  void addItem(String productId, String title, int price, String imageUrl) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + 1
      ));
    } else {
      _items.putIfAbsent(productId, () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          imageUrl: imageUrl,
          quantity: 1
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    // Nếu xóa hết đồ thì reset voucher luôn cho hợp lý
    if (_items.isEmpty) _discount = 0;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discount = 0; // --- MỚI: Reset giảm giá khi đặt xong
    notifyListeners();
  }

  // --- MỚI: Hàm áp dụng Voucher
  void applyVoucher(int amount) {
    _discount = amount;
    notifyListeners();
  }
}

// ============================================================================
// 4. PROFILE PAGE
// ============================================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user; // Lấy thông tin user hiện tại (nếu có)

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orangeAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight
                )
            ),
            child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 15),
                      if (user == null)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Chào bạn mới!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.deepOrange,
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                  ),
                                  child: const Text("Đăng nhập / Đăng ký", style: TextStyle(fontWeight: FontWeight.bold))
                              )
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.displayName ?? "Khách hàng", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(user.email ?? "", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () {
                                  // Xác nhận đăng xuất
                                  showDialog(context: context, builder: (ctx) => AlertDialog(
                                    title: const Text("Đăng xuất?"),
                                    content: const Text("Bạn có chắc muốn đăng xuất không?"),
                                    actions: [
                                      TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Huỷ")),
                                      TextButton(onPressed: () {
                                        Navigator.pop(ctx);
                                        authProvider.signOut();
                                      }, child: const Text("Đồng ý", style: TextStyle(color: Colors.red))),
                                    ],
                                  ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.logout, color: Colors.white, size: 14),
                                      SizedBox(width: 5),
                                      Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 12))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                )
            ),
          ),

          const SizedBox(height: 10),
          _buildMenuItem(Icons.confirmation_number_outlined, "Ví Voucher", Colors.orange, onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherPage()));
          }),
          _buildMenuItem(Icons.location_on_outlined, "Địa chỉ", Colors.green, onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListPage()));
          }),
          const SizedBox(height: 10),
          _buildMenuItem(Icons.settings_outlined, "Cài đặt", Colors.grey, onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color iconColor, {VoidCallback? onTap}) {
    return Column(children: [
      Container(
          color: Colors.white,
          child: ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(text, style: const TextStyle(fontSize: 15)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: onTap ?? () {})),
      const Divider(height: 1, indent: 50, color: Colors.grey)
    ]);
  }
}

// ============================================================================
// 5. PRODUCT LIST PAGE (HOME)
// ============================================================================
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> _allProducts = ProductData.products;

  List<Product> _displayProducts = [];
  String _selectedCategory = "Tất cả";

  @override
  void initState() { super.initState(); _displayProducts = _allProducts; }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _displayProducts = category == "Tất cả" ? _allProducts : _allProducts.where((p) => p.title.toLowerCase().contains(category.toLowerCase())).toList();
    });
  }
  void _runFilter(String keyword) {
    setState(() { _displayProducts = _allProducts.where((product) => product.title.toLowerCase().contains(keyword.toLowerCase())).toList(); });
  }

  Map<String, String> _getSmartGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return {'greeting': 'Chào buổi sáng! ☀️', 'sub': 'Nạp năng lượng ngày mới nhé'};
    else if (hour >= 11 && hour < 14) return {'greeting': 'Trưa nay ăn gì? 🍱', 'sub': 'Đừng quên uống nước đầy đủ'};
    else if (hour >= 14 && hour < 18) return {'greeting': 'Chào buổi chiều! ☕', 'sub': 'Làm ly cà phê cho tỉnh táo nào'};
    else return {'greeting': 'Buổi tối vui vẻ! 🌙', 'sub': 'Thư giãn cùng món ngon nhé'};
  }

  @override
  Widget build(BuildContext context) {
    final smartData = _getSmartGreeting();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("App Đặt Hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.deepOrange),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
            ),
            Consumer<CartProvider>(builder: (_, cart, child) => Stack(alignment: Alignment.center, children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.deepOrange), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));}),
              if (cart.itemCount > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text('${cart.itemCount}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white))))
            ]))
          ]
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(smartData['greeting']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Text(smartData['sub']!, style: const TextStyle(fontSize: 15, color: Colors.grey))
                ]
            )
        ),

        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
                onChanged: _runFilter,
                decoration: InputDecoration(
                    hintText: 'Bạn đang thèm món gì?',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.deepOrange)),
                    filled: true,
                    fillColor: Colors.grey.shade50
                )
            )
        ),

        const SizedBox(height: 20),

        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                children: ["Tất cả", "Cà phê", "Trà", "Bánh", "Nước ép"].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.deepOrange,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)
                        ),
                        showCheckmark: false,
                        onSelected: (val) => _filterByCategory(category),
                      )
                  );
                }).toList()
            )
        ),

        const SizedBox(height: 10),

        Expanded(
            child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3/4.8, crossAxisSpacing: 15, mainAxisSpacing: 15),
                itemCount: _displayProducts.length,
                itemBuilder: (ctx, i) => ProductItem(product: _displayProducts[i])
            )
        ),
      ]),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({super.key, required this.product});

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');
    final favProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favProvider.isFavorite(product.id);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
          ]
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: Stack( // Dùng Stack để đè nút tim lên ảnh
              children: [
                Positioned.fill(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                          : const Icon(Icons.coffee, size: 50, color: Colors.grey)
                  ),
                ),
                // NÚT TIM
                Positioned(
                  top: 5, right: 5,
                  child: InkWell(
                    onTap: () => favProvider.toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            )
        ),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  SizedBox(
                      height: 32,
                      width: double.infinity,
                      child: OutlinedButton(
                          onPressed: () => _showAddModal(context),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.deepOrange),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero
                          ),
                          child: const Text("Thêm", style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold))
                      )
                  ),
                ]
            )
        )
      ]),
    );
  }
}

// ============================================================================
// 6. CART & CHECKOUT (ĐÃ SỬA: TỰ ĐỘNG LẤY USER INFO)
// ============================================================================
class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Biến lưu trạng thái đơn hàng
  String _paymentMethod = "Tiền mặt";
  final _noteController = TextEditingController();

  // Biến lưu địa chỉ giao hàng (Mặc định là null)
  Map<String, String>? _shippingInfo;

  bool _isLoading = false;

  // Hàm chọn địa chỉ
  Future<void> _selectAddress() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddAddressPage())
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _shippingInfo = result;
      });
    }
  }

  Future<void> _submitOrder(CartProvider cart, User? user) async {
    if (cart.items.isEmpty) return;
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // Bắt buộc phải chọn địa chỉ
    if (_shippingInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderItems = cart.items.values.map((item) => {
        'productId': item.id, 'title': item.title, 'quantity': item.quantity,
        'price': item.price, 'imageUrl': item.imageUrl, 'totalItem': item.total
      }).toList();

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'customerName': _shippingInfo!['name'],     // Lấy từ form địa chỉ
        'customerPhone': _shippingInfo!['phone'],   // Lấy từ form địa chỉ
        'address': _shippingInfo!['address'],       // Lấy từ form địa chỉ
        'note': _noteController.text,               // Ghi chú món
        'paymentMethod': _paymentMethod,            // Phương thức thanh toán
        'totalAmount': cart.totalAmount,
        'discount': cart.discount,
        'items': orderItems,
        'status': 'Mới',
        'date': DateTime.now().toIso8601String()
      });

      cart.clear();
      if (mounted) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text("Đặt hàng thành công!"),
                content: const Text("Đơn hàng của bạn đang được xử lý."),
                actions: [TextButton(onPressed: () {Navigator.of(ctx).pop(); Navigator.of(context).pop();}, child: const Text("OK"))]
            )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Giỏ Hàng"), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          // DANH SÁCH MÓN (Giữ nguyên logic cũ nhưng rút gọn hiển thị cho code ngắn)
          Expanded(
            child: cart.items.isEmpty
                ? const EmptyStateWidget(iconData: Icons.shopping_cart_outlined, title: "Giỏ trống", subtitle: "Thêm món đi bạn ơi")
                : ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) {
                  final item = cart.items.values.toList()[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.fastfood)),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${formatCurrency.format(item.price)} x ${item.quantity}"),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cart.removeItem(cart.items.keys.toList()[i])),
                    ),
                  );
                }
            ),
          ),

          // --- BOTTOM SHEET THANH TOÁN (NÂNG CẤP) ---
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. CHỌN ĐỊA CHỈ
                  InkWell(
                    onTap: _selectAddress,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepOrange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shippingInfo == null
                              ? const Text("Vui lòng chọn địa chỉ nhận hàng", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${_shippingInfo!['name']} | ${_shippingInfo!['phone']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(_shippingInfo!['address']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
                      ],
                    ),
                  ),
                  const Divider(height: 20),

                  // 2. GHI CHÚ & THANH TOÁN
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(hintText: "Ghi chú...", isDense: true, border: InputBorder.none, icon: Icon(Icons.note_alt_outlined, size: 20, color: Colors.grey)),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey.shade300),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _paymentMethod,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                        items: ["Tiền mặt", "Chuyển khoản"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                      )
                    ],
                  ),

                  // 3. VOUCHER & TỔNG TIỀN (Giữ nguyên logic hiển thị)
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Tổng thanh toán:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatCurrency.format(cart.totalAmount), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 18))
                  ]),
                  const SizedBox(height: 10),

                  // 4. NÚT ĐẶT HÀNG
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (cart.items.isEmpty || _isLoading) ? null : () => _submitOrder(cart, user),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ĐẶT HÀNG NGAY", style: TextStyle(fontWeight: FontWeight.bold)),
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
// 7. ORDER DETAIL & ADMIN
// ============================================================================
class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  const OrderDetailPage({super.key, required this.orderData, required this.orderId});

  @override
  Widget build(BuildContext context) {
    String status = orderData['status'] ?? 'Mới';
    // Xác định step, nếu 'Đã hủy' thì hiển thị khác
    int step = 0;
    if (status == 'Đang làm') step = 1;
    else if (status == 'Đang giao') step = 2;
    else if (status == 'Hoàn tất') step = 3;
    else if (status == 'Đã hủy') step = -1; // Trạng thái hủy

    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Chi tiết đơn hàng"), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TRẠNG THÁI ĐƠN
            if (step != -1)
              Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Stepper(
                      physics: const NeverScrollableScrollPhysics(),
                      currentStep: step,
                      controlsBuilder: (_,__) => Container(),
                      steps: [
                        Step(title: const Text("Đã đặt"), content: const SizedBox(), isActive: step>=0, state: step>0?StepState.complete:StepState.indexed),
                        Step(title: const Text("Đang làm"), content: const SizedBox(), isActive: step>=1, state: step>1?StepState.complete:StepState.indexed),
                        Step(title: const Text("Đang giao"), content: const SizedBox(), isActive: step>=2, state: step>2?StepState.complete:StepState.indexed),
                        Step(title: const Text("Hoàn tất"), content: const SizedBox(), isActive: step>=3, state: step==3?StepState.complete:StepState.indexed),
                      ]
                  )
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.red.shade50,
                child: Column(children: const [
                  Icon(Icons.cancel, size: 50, color: Colors.red),
                  SizedBox(height: 10),
                  Text("Đơn hàng đã bị hủy", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                ]),
              ),

            const SizedBox(height: 10),

            // THÔNG TIN NHẬN HÀNG (Mới thêm)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin nhận hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  Text("Người nhận: ${orderData['customerName']} - ${orderData['customerPhone']}"),
                  const SizedBox(height: 5),
                  Text("Địa chỉ: ${orderData['address'] ?? 'Tại quán'}"),
                  const SizedBox(height: 5),
                  Text("Ghi chú: ${orderData['note'] ?? 'Không có'}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text("Thanh toán: ${orderData['paymentMethod'] ?? 'Tiền mặt'}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // DANH SÁCH MÓN
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Danh sách món", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...List.generate((orderData['items'] as List).length, (i) {
                      final item = orderData['items'][i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item['quantity']}x ${item['title']}"),
                              Text(formatCurrency.format(item['totalItem']))
                            ]
                        ),
                      );
                    }),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Tổng tiền:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatCurrency.format(orderData['totalAmount']), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18))
                    ])
                  ]
              ),
            ),

            const SizedBox(height: 20),

            // NÚT HỦY ĐƠN (Chỉ hiện khi đơn Mới)
            if (status == 'Mới')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(context: context, builder: (ctx) => AlertDialog(
                        title: const Text("Hủy đơn hàng?"),
                        content: const Text("Bạn có chắc chắn muốn hủy đơn này không?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Không")),
                          TextButton(onPressed: () async {
                            Navigator.pop(ctx);
                            await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': 'Đã hủy'});
                            if(context.mounted) Navigator.pop(context); // Quay lại trang trước
                          }, child: const Text("Hủy đơn", style: TextStyle(color: Colors.red))),
                        ],
                      ));
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                    child: const Text("Hủy đơn hàng"),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mới': return Colors.red;
      case 'Đang làm': return Colors.orange;
      case 'Đang giao': return Colors.blue;
      case 'Hoàn tất': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': newStatus});
  }

  Widget _buildOrderCard(Map<String, dynamic> data, String docId) {
    final status = data['status'] ?? 'Mới';
    final items = data['items'] as List<dynamic>;
    final total = data['totalAmount'] ?? 0;
    final date = DateTime.parse(data['date']);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${docId.substring(0, 6).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status).withOpacity(0.5))
                  ),
                  child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text("${data['customerName']} - ${data['customerPhone']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map<Widget>((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item['quantity']}x ${item['title']}", style: const TextStyle(fontSize: 14)),
                      Text(formatCurrency.format(item['totalItem']), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng cộng:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(formatCurrency.format(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.deepOrange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepOrange)
                    ),
                    child: DropdownButton<String>(
                      value: ['Mới', 'Đang làm', 'Đang giao', 'Hoàn tất'].contains(status) ? status : 'Mới',
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepOrange),
                      style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      items: ['Mới', 'Đang làm', 'Đang giao', 'Hoàn tất'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) _updateStatus(docId, newValue);
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("KÊNH QUẢN LÝ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "ĐƠN HIỆN TẠI"),
              Tab(text: "LỊCH SỬ"),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').orderBy('date', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final allDocs = snapshot.data!.docs;

            final activeOrders = allDocs.where((doc) {
              final status = (doc.data() as Map<String, dynamic>)['status'];
              return ['Mới', 'Đang làm', 'Đang giao'].contains(status);
            }).toList();

            final historyOrders = allDocs.where((doc) {
              final status = (doc.data() as Map<String, dynamic>)['status'];
              return !['Mới', 'Đang làm', 'Đang giao'].contains(status);
            }).toList();

            return TabBarView(
              children: [
                activeOrders.isEmpty
                    ? const Center(child: Text("Không có đơn hàng nào cần xử lý!", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) => _buildOrderCard(activeOrders[index].data() as Map<String, dynamic>, activeOrders[index].id),
                ),
                historyOrders.isEmpty
                    ? const Center(child: Text("Chưa có lịch sử đơn hàng.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: historyOrders.length,
                  itemBuilder: (context, index) => _buildOrderCard(historyOrders[index].data() as Map<String, dynamic>, historyOrders[index].id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProductDetailModal extends StatefulWidget {
  final Product product;
  const ProductDetailModal({super.key, required this.product});

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  int _quantity = 1;
  int get _totalPrice => widget.product.price * _quantity;

  void _addToCart(BuildContext context) {
    // --- CẬP NHẬT: Đã truyền imageUrl vào hàm addItem ---
    for (int i = 0; i < _quantity; i++) {
      Provider.of<CartProvider>(context, listen: false).addItem(
          widget.product.id,
          widget.product.title,
          widget.product.price,
          widget.product.imageUrl
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào giỏ!"), duration: Duration(milliseconds: 500))
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 30),
                const Text("Thêm món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                        child: widget.product.imageUrl.isNotEmpty
                            ? Image.network(widget.product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                            : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            const Text("Món ngon chất lượng...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    formatCurrency.format(widget.product.price),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16, color: Colors.deepOrange),
                                        constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                        padding: EdgeInsets.zero,
                                        onPressed: () { if(_quantity > 1) setState(() => _quantity--); },
                                      ),
                                      Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16, color: Colors.deepOrange),
                                        constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                        padding: EdgeInsets.zero,
                                        onPressed: () { setState(() => _quantity++); },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Thêm vào giỏ hàng - ${formatCurrency.format(_totalPrice)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 8. MÀN HÌNH VIẾT ĐÁNH GIÁ (IMPROVED)
// ============================================================================
class WriteReviewScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const WriteReviewScreen({super.key, required this.orderId, required this.orderData});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  // Danh sách các tag gợi ý
  final List<String> _availableTags = [
    "Ngon miệng", "Giao nhanh", "Đóng gói đẹp", "Thân thiện", "Đáng tiền", "Sạch sẽ"
  ];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      // Cập nhật đơn hàng với thông tin đánh giá
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'rating': _rating,
        'comment': _commentController.text,
        'tags': _selectedTags,
        'reviewedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 15),
                const Text("Cảm ơn bạn!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Đánh giá của bạn giúp chúng tôi phục vụ tốt hơn.", textAlign: TextAlign.center),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Đóng dialog
                      Navigator.of(context).pop(); // Về trang trước
                    },
                    child: const Text("OK"),
                  ),
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.orderData['items'] as List<dynamic>;
    final firstItemImage = (items.isNotEmpty && items[0]['imageUrl'] != null) ? items[0]['imageUrl'] : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh giá đơn hàng", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header sản phẩm
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    clipBehavior: Clip.hardEdge,
                    child: firstItemImage.isNotEmpty
                        ? Image.network(firstItemImage, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[0]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Mã đơn: #${widget.orderId.substring(0, 6).toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Khu vực đánh giá chính
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  const Text("Bạn thấy món ăn thế nào?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  // Star Rating Widget
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 40,
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Text(
                    _rating == 5 ? "Cực kỳ hài lòng" : _rating == 4 ? "Hài lòng" : _rating == 3 ? "Bình thường" : "Tệ",
                    style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),

                  // Tags suggestion
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return InkWell(
                        onTap: () => _toggleTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.grey.shade100,
                            border: Border.all(color: isSelected ? Colors.deepOrange : Colors.transparent),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                                color: isSelected ? Colors.deepOrange : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // Text Field
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Hãy chia sẻ nhận xét cho món ăn này nhé...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fake Image Upload Button
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng tải ảnh đang phát triển")));
                    },
                    child: DottedBorderContainer(
                      child: Column(
                        children: const [
                          Icon(Icons.camera_alt, color: Colors.deepOrange),
                          SizedBox(height: 5),
                          Text("Thêm hình ảnh/video", style: TextStyle(color: Colors.deepOrange, fontSize: 12))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, -5)
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
                  : const Text(
                  "Gửi đánh giá",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget trang trí viền đứt nét cho nút upload ảnh
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepOrange, style: BorderStyle.solid, width: 1), // Simplification: solid border is easier without external package
      ),
      child: child,
    );
  }
}

// --- CẬP NHẬT: Dữ liệu sản phẩm dùng chung (để cả Home và Favorite đều gọi được) ---
class ProductData {
  static final List<Product> products = [
    Product(id: 'p1', title: 'Cà phê sữa đá', price: 15000, imageUrl: 'https://product.hstatic.net/200000480127/product/ca_phe_sua_da_mang_di_5e626313a29f477fa0a13c89911435b5_master.png'),
    Product(id: 'p2', title: 'Trà đào cam sả', price: 15000, imageUrl: 'https://mmvietnam.com/wp-content/uploads/2021/08/tra-dao-cam-sa-scaled.jpg'),
    Product(id: 'p3', title: 'Bạc xỉu', price: 15000, imageUrl: 'https://i.pinimg.com/736x/4a/1b/93/4a1b9367465bd41892c79f722849c28e.jpg'),
    Product(id: 'p4', title: 'Nước cam ép', price: 15000, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpW8ngZbLXbCKBTat71ntCrBLvjKnB9tmS5w&s'),
    Product(id: 'p5', title: 'Bánh Croissant', price: 20000, imageUrl: 'https://hochiminh.dongtienbakery.com/image/cache/data/B%C3%A1nh%20ng%E1%BB%8Dt/crossantphomai-608x416f.jpg'),
    Product(id: 'p6', title: 'Trà sữa trân châu', price: 25000, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvjOwk4yw5o40-lz6he471gTUupSbrFMNHmw&s'),
  ];
}

// --- MỚI: Provider quản lý Yêu thích ---
class FavoriteProvider with ChangeNotifier {
  // Lưu danh sách ID của sản phẩm yêu thích
  final List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  // Lấy ra danh sách Product object từ ID
  List<Product> get favoriteProducts {
    return ProductData.products.where((prod) => _favoriteIds.contains(prod.id)).toList();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
}

// ============================================================================
// TRANG YÊU THÍCH (NEW DESIGN)
// ============================================================================
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _selectedFilter = "Tất cả"; // Filter giả lập để giao diện đẹp hơn

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favList = favProvider.favoriteProducts;
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Yêu thích", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Nút xóa tất cả (nếu muốn)
          if (favList.isNotEmpty)
            TextButton(
              onPressed: () {
                // Tính năng mở rộng: Xóa hết
              },
              child: const Text("Chọn", style: TextStyle(color: Colors.deepOrange)),
            )
        ],
      ),
      body: Column(
        children: [
          // 1. Filter Chips (Làm màu cho đẹp/mới mẻ)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: ["Tất cả", "Đồ uống", "Đồ ăn", "Combo"].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: Colors.deepOrange.withOpacity(0.1),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepOrange : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? Colors.deepOrange : Colors.transparent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Nội dung chính
          Expanded(
            child: favList.isEmpty
                ? const EmptyStateWidget(
              iconData: Icons.favorite_border,
              title: "Chưa có món tủ nào",
              subtitle: "Thả tim các món ngon để lưu lại vào đây bạn nhé!",
            )
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: favList.length,
              itemBuilder: (context, index) {
                final product = favList[index];
                return Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  onDismissed: (direction) {
                    favProvider.toggleFavorite(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã xóa khỏi yêu thích"), duration: Duration(seconds: 1)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        // Ảnh sản phẩm
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood)),
                        ),
                        const SizedBox(width: 15),
                        // Thông tin
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 5),
                              Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const Text(" 4.8 (120)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Nút Add to Cart nhanh
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                          onPressed: () {
                            cartProvider.addItem(product.id, product.title, product.price, product.imageUrl);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ!"), duration: Duration(milliseconds: 500)));
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH THÔNG BÁO (TIN TỨC & ĐƠN HÀNG)
// ============================================================================
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(text: "Tin tức"),
              Tab(text: "Đơn hàng"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NewsTab(),   // Tab Tin tức
            _OrderTab(),  // Tab Cập nhật đơn hàng
          ],
        ),
      ),
    );
  }
}

// Widget con: Tab Tin tức (Dữ liệu giả lập)
class _NewsTab extends StatelessWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context) {
    // Danh sách tin tức giả
    final List<Map<String, String>> news = [
      {
        "title": "🎉 Giảm 50% cho đơn đầu tiên!",
        "desc": "Nhập mã CHAO-BAN-MOI để được giảm giá ngay.",
        "time": "2 giờ trước",
        "image": "https://img.freepik.com/free-vector/special-offer-modern-sale-banner-template_1017-20667.jpg"
      },
      {
        "title": "☕ Mua 1 Tặng 1 Cà Phê",
        "desc": "Áp dụng khung giờ vàng 8:00 - 10:00 sáng nay.",
        "time": "1 ngày trước",
        "image": "https://img.freepik.com/free-vector/coffee-shop-social-media-post-template_23-2149008818.jpg"
      },
      {
        "title": "🚚 Freeship bán kính 5km",
        "desc": "Không ngại mưa nắng, đặt là giao ngay!",
        "time": "3 ngày trước",
        "image": "https://img.freepik.com/free-vector/free-delivery-logo-with-bike-man-courier_1308-46678.jpg"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: news.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh banner tin tức
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  news[index]['image']!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(news[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(news[index]['desc']!, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(news[index]['time']!, style: const TextStyle(color: Colors.deepOrange, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có thông báo đơn hàng nào"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Mới';
            IconData statusIcon = Icons.receipt;
            Color iconColor = Colors.blue;
            String message = "Đơn hàng mới đã được ghi nhận.";

            if (status == 'Đang làm') {
              statusIcon = Icons.coffee_maker;
              iconColor = Colors.orange;
              message = "Quán đang chuẩn bị món cho bạn.";
            } else if (status == 'Đang giao') {
              statusIcon = Icons.delivery_dining;
              iconColor = Colors.blueAccent;
              message = "Shipper đang giao hàng đến bạn.";
            } else if (status == 'Hoàn tất') {
              statusIcon = Icons.check_circle;
              iconColor = Colors.green;
              message = "Đơn hàng đã hoàn thành. Chúc ngon miệng!";
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: iconColor),
                ),
                title: Text("Cập nhật đơn hàng: $status", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(message),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(data['date'])), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(orderData: data, orderId: docs[index].id)));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuth => _user != null;

  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user!.updateDisplayName(name);
      await result.user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}

// ============================================================================
// MÀN HÌNH ĐĂNG NHẬP
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).signIn(
        _emailController.text.trim(),
        _passController.text.trim(),
      );
      if(mounted) Navigator.pop(context); // Đăng nhập xong thì đóng màn hình này
    } on FirebaseAuthException catch (e) {
      String msg = "Lỗi đăng nhập";
      if (e.code == 'user-not-found') msg = "Không tìm thấy tài khoản này.";
      else if (e.code == 'wrong-password') msg = "Sai mật khẩu.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Nhập"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person, size: 80, color: Colors.deepOrange),
                const SizedBox(height: 20),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
                const SizedBox(height: 15),
                TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                    },
                    child: const Text("Quên mật khẩu?", style: TextStyle(color: Colors.deepOrange, fontStyle: FontStyle.italic)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ĐĂNG NHẬP", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text("Chưa có tài khoản? Đăng ký ngay", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH ĐĂNG KÝ
// ============================================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ thông tin")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).signUp(
        _emailController.text.trim(),
        _passController.text.trim(),
        _nameController.text.trim(),
      );
      if(mounted) {
        Navigator.pop(context); // Đăng ký xong tự login và đóng màn hình
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Lỗi đăng ký";
      if (e.code == 'weak-password') msg = "Mật khẩu quá yếu.";
      else if (e.code == 'email-already-in-use') msg = "Email này đã được sử dụng.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Ký"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ và Tên", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ĐĂNG KÝ NGAY", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(color: Colors.deepOrange)),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH VÍ VOUCHER (ĐÃ UPDATE LOGIC & GIAO DIỆN)
// ====================================================================== ======
class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Ví Voucher", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepOrange,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Giảm giá món"),
              Tab(text: "Phí vận chuyển"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VoucherListTab(),
            _VoucherListTab(),
            _VoucherListTab(),
          ],
        ),
      ),
    );
  }
}

class _VoucherListTab extends StatelessWidget {
  const _VoucherListTab();

  @override
  Widget build(BuildContext context) {
    // Dữ liệu voucher (Thêm trường 'value' là số tiền giảm)
    final List<Map<String, dynamic>> vouchers = [
      {
        "title": "Giảm 40.000đ trên giá món",
        "sub": "Đơn từ 0đ",
        "tag": "Ưu đãi có hạn",
        "expiry": "Hết hạn trong: 1 ngày",
        "value": 40000 // Giá trị giảm
      },
      {
        "title": "Giảm 25.000đ trên giá món",
        "sub": "Đặt tối thiểu 25.000đ",
        "tag": "Ưu đãi có hạn",
        "expiry": "HSD: 28/02/2026",
        "value": 25000
      },
      {
        "title": "Giảm 30.000đ trên giá món",
        "sub": "Đặt tối thiểu 30.000đ",
        "tag": "Ưu đãi có hạn",
        "expiry": "HSD: 28/02/2026",
        "value": 30000
      },
      {
        "title": "Giảm 100% (Test)",
        "sub": "Dành cho Admin test",
        "tag": "VIP",
        "expiry": "Vô thời hạn",
        "value": 999999
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _VoucherCard(data: vouchers[index]);
      },
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _VoucherCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // --- PHẦN TRÁI (CHỈ CÒN ICON) ---
          Container(
            width: 100,
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: const Center( // Căn giữa icon
              child: Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 40),
            ),
          ),

          // --- ĐƯỜNG KẺ ---
          Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(vertical: 10)),

          // --- PHẦN PHẢI (THÔNG TIN) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(data['sub'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange, width: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(data['tag'], style: const TextStyle(color: Colors.deepOrange, fontSize: 10)),
                      ),

                      // --- NÚT DÙNG NGAY (CÓ LOGIC) ---
                      OutlinedButton(
                        onPressed: () {
                          // 1. Gọi Provider để lưu số tiền giảm giá
                          Provider.of<CartProvider>(context, listen: false).applyVoucher(data['value']);

                          // 2. Thông báo
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Đã áp dụng mã giảm ${data['value']}đ"),
                            duration: const Duration(seconds: 1),
                          ));

                          // 3. Quay về (thường dùng xong sẽ về giỏ hàng, nhưng ở đây về trang trước)
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepOrange),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(60, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("Dùng\nngay", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.deepOrange)),
                      )
                    ],
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
// MÀN HÌNH CÀI ĐẶT (GIAO DIỆN GIỐNG ẢNH)
// ============================================================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt chuẩn style Settings
      appBar: AppBar(
        title: const Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Title căn trái giống ảnh
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NHÓM 1: CÀI ĐẶT TÀI KHOẢN ---
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 8, top: 5),
              child: Text("Cài đặt tài khoản", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSettingItem("Thông tin & Liên hệ", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInfoPage()));
                  }),
                  const Divider(height: 1, color: Colors.grey, indent: 15, endIndent: 15),
                  _buildSettingItem("Mật khẩu", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- NHÓM 2: CÀI ĐẶT ỨNG DỤNG ---
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 8),
              child: Text("Cài đặt ứng dụng", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Mục bạn yêu cầu: Cài đặt thông báo
                  _buildSettingItem("Cài đặt thông báo", onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- NÚT ĐĂNG XUẤT (GIỐNG ẢNH) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Gọi hàm đăng xuất từ AuthProvider
                  authProvider.signOut();
                  Navigator.pop(context); // Đóng màn hình cài đặt
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  side: const BorderSide(color: Colors.grey, width: 0.5), // Viền mỏng
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Đăng xuất", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con để vẽ từng dòng cài đặt
  Widget _buildSettingItem(String title, {String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          if (trailingText != null) const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}

// ============================================================================
// MÀN HÌNH THÔNG TIN NGƯỜI DÙNG (CHI TIẾT)
// ============================================================================
class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu user hiện tại từ Firebase Auth
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Giả lập dữ liệu hiển thị nếu chưa có data thật
    final String displayName = user?.displayName ?? "Chưa cập nhật";
    final String email = user?.email ?? "Chưa cập nhật";
    final String username = email.split('@')[0]; // Lấy phần đầu email làm tên đăng nhập giả

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt
      appBar: AppBar(
        title: const Text("Thông tin người dùng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- KHỐI 1: ẢNH ĐẠI DIỆN & TÀI KHOẢN ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  // Mục 1: Avatar (Custom riêng vì nó to hơn)
                  InkWell(
                    onTap: () {
                      // Xử lý đổi ảnh đại diện
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: user?.photoURL != null
                                  ? DecorationImage(image: NetworkImage(user!.photoURL!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: user?.photoURL == null
                                ? const Icon(Icons.person, color: Colors.grey, size: 30)
                                : null,
                          ),
                          const Spacer(),
                          const Text("Đổi hình đại diện", style: TextStyle(color: Colors.grey, fontSize: 14)), // Màu xám hoặc cam tùy thích
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),

                  // Mục 2: Tên đăng nhập
                  _buildInfoRow("Tên đăng nhập", value: username, showArrow: false),
                  const Divider(height: 1, color: Colors.grey),

                  // Mục 3: Số điện thoại
                  _buildInfoRow("Số điện thoại", value: "********506", showArrow: true), // Giả lập số masked
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- KHỐI 2: THÔNG TIN CÁ NHÂN ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  _buildInfoRow("Tên", value: displayName, showArrow: true),
                  const Divider(height: 1, color: Colors.grey),

                  _buildInfoRow("Email", value: email, showArrow: true),
                  const Divider(height: 1, color: Colors.grey),

                  _buildInfoRow("Giới tính", placeholder: "Cập nhật ngay", showArrow: true),
                  const Divider(height: 1, color: Colors.grey),

                  _buildInfoRow("Ngày sinh", placeholder: "Cập nhật ngay", showArrow: true),
                  const Divider(height: 1, color: Colors.grey),

                  // Giữ mục Nghề nghiệp cho giống ảnh, hoặc có thể thay bằng "Địa chỉ mặc định"
                  _buildInfoRow("Nghề nghiệp", placeholder: "Cập nhật ngay", showArrow: true),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Nút Lưu (Nếu cần, hoặc để tự động lưu khi sửa từng mục)
          ],
        ),
      ),
    );
  }

  // Widget helper để vẽ từng dòng thông tin giống ShopeeFood
  Widget _buildInfoRow(String label, {String? value, String? placeholder, bool showArrow = false}) {
    return InkWell(
      onTap: showArrow ? () {
        // Mở popup chỉnh sửa thông tin tại đây
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding bên phải lấy từ container cha + tham số này
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15, color: Colors.black)),
            Row(
              children: [
                if (value != null)
                  Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                if (placeholder != null)
                  Text(placeholder, style: const TextStyle(fontSize: 15, color: Colors.grey)), // Placeholder màu xám nhạt

                if (showArrow) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH ĐỔI MẬT KHẨU (GIAO DIỆN GIỐNG ẢNH)
// ============================================================================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu xác nhận không khớp")));
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu phải có ít nhất 6 ký tự")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gọi hàm đổi mật khẩu của Firebase
      await FirebaseAuth.instance.currentUser?.updatePassword(newPass);

      if (mounted) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Thành công"),
              content: const Text("Mật khẩu đã được thay đổi."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Đóng dialog
                      Navigator.pop(context); // Quay về trang trước
                    },
                    child: const Text("OK")
                )
              ],
            )
        );
      }
    } on FirebaseAuthException catch (e) {
      // Lưu ý: Firebase yêu cầu người dùng phải đăng nhập gần đây mới cho đổi pass.
      // Nếu lâu quá chưa đăng nhập lại, lỗi 'requires-recent-login' sẽ xảy ra.
      String msg = "Lỗi: ${e.message}";
      if (e.code == 'requires-recent-login') {
        msg = "Vì lý do bảo mật, vui lòng đăng xuất và đăng nhập lại trước khi đổi mật khẩu.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      appBar: AppBar(
        title: const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header xám nhỏ: "Nhập Mật khẩu mới"
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Text("Nhập Mật khẩu mới", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),

          // Khối nhập liệu nền trắng
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Mật khẩu mới",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none, // Bỏ viền để dùng Divider bên dưới
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),
                TextField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Xác nhận",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nút Lưu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange, // Màu cam giống ảnh
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Bo góc nhẹ
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Link Quên mật khẩu
          Center(
            child: InkWell(
              onTap: () {
                // Xử lý quên mật khẩu (thường gửi email reset)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi email khôi phục mật khẩu (Giả lập)")));
              },
              child: const Text(
                "Quên mật khẩu",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH QUÊN MẬT KHẨU (GỬI LINK RESET)
// ============================================================================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập email")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gửi link reset pass của Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        // Hiển thị thông báo thành công và quay lại trang đăng nhập
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Đã gửi liên kết"),
              content: Text("Một email khôi phục mật khẩu đã được gửi tới $email.\n\nVui lòng kiểm tra hộp thư (kể cả mục Spam) và làm theo hướng dẫn trong email để đặt lại mật khẩu."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Đóng dialog
                      Navigator.pop(context); // Quay về trang đăng nhập
                    },
                    child: const Text("Đã hiểu")
                )
              ],
            )
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Lỗi: ${e.message}";
      if (e.code == 'user-not-found') {
        msg = "Email này chưa được đăng ký tài khoản nào.";
      } else if (e.code == 'invalid-email') {
        msg = "Định dạng email không hợp lệ.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Quên mật khẩu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng nhập email đã đăng ký. Chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu cho bạn.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Ô nhập Email nền trắng
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  icon: Icon(Icons.email_outlined, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Nút Gửi yêu cầu
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Gửi yêu cầu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH THÊM ĐỊA CHỈ (ĐÃ FIX UI + LOGIC)
// ============================================================================
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gateController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.phoneNumber != null) _phoneController.text = user!.phoneNumber!;
  }

  Future<void> _saveAddress() async {
    if (_addressController.text.isEmpty || _nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ thông tin")));
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final addressData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'gate': _gateController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // 1. Lưu vào Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add(addressData);

      // 2. Trả dữ liệu về
      if (mounted) {
        Navigator.pop(context, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': "${_addressController.text} ${_gateController.text.isNotEmpty ? '(${_gateController.text})' : ''}"
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false, // Fix lỗi bàn phím đẩy giao diện
      appBar: AppBar(
        title: const Text("Thêm địa chỉ mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.deepOrange), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea( // Fix lỗi bị che bởi thanh điều hướng
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên người nhận", border: InputBorder.none, icon: Icon(Icons.person, color: Colors.grey))),
                      const Divider(height: 1),
                      TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Số điện thoại", border: InputBorder.none, icon: Icon(Icons.phone, color: Colors.grey))),
                      const Divider(height: 1),
                      TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Địa chỉ (Số nhà, Đường...)", border: InputBorder.none, icon: Icon(Icons.map, color: Colors.deepOrange))),
                      const Divider(height: 1),
                      TextField(controller: _gateController, decoration: const InputDecoration(labelText: "Ghi chú (Cổng, Tòa nhà...)", border: InputBorder.none, icon: Icon(Icons.note, color: Colors.grey))),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("HOÀN THÀNH", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH QUẢN LÝ DANH SÁCH ĐỊA CHỈ
// ============================================================================
class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Địa chỉ của tôi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.deepOrange),
            onPressed: () async {
              // Mở trang thêm địa chỉ và chờ kết quả trả về
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressPage()));

              // Nếu có kết quả trả về (người dùng vừa thêm mới), có thể pop về giỏ hàng luôn nếu muốn
              if (result != null && context.mounted) {
                // Tùy chọn: Nếu muốn chọn xong quay về luôn thì uncomment dòng dưới
                // Navigator.pop(context, result);
              }
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text("Vui lòng đăng nhập để xem địa chỉ"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  const Text("Chưa có địa chỉ nào", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;

              return Dismissible(
                key: Key(id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('addresses')
                      .doc(id)
                      .delete();
                },
                child: InkWell(
                  onTap: () {
                    // Khi bấm vào 1 địa chỉ -> Trả địa chỉ đó về trang trước (Giỏ hàng)
                    Navigator.pop(context, {
                      'name': data['name'],
                      'phone': data['phone'],
                      'address': "${data['address']} ${data['gate'] != null && data['gate'].isNotEmpty ? '(${data['gate']})' : ''}"
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepOrange, size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(data['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 10),
                                  Container(height: 12, width: 1, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Text(data['phone'] ?? "", style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(data['address'] ?? "", style: const TextStyle(fontSize: 14)),
                              if (data['gate'] != null && data['gate'].isNotEmpty)
                                Text("Ghi chú: ${data['gate']}", style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}