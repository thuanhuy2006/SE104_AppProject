import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';
import 'profile_screen.dart';
import 'login_page.dart';
import 'purchases_screen.dart';
import 'chat_list_page.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.isLoggedIn;

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
          if (isLoggedIn) ...[
            // Phần hiển thị tên và email nhanh ở đầu
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: userProvider.isSeller ? Colors.deepOrange : Colors.grey.shade700,
                child: Text(
                  userProvider.currentUser!.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(userProvider.currentUser!.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(userProvider.currentUser!.email, style: const TextStyle(color: Colors.grey)),
            ),
            _buildDivider(),
            
            _buildMenuItem("Hồ sơ", context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
            _buildDivider(),
            
            _buildMenuItem("Đơn mua", context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
            }),
            _buildDivider(),
            
            _buildMenuItem("Tin nhắn", context, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage()));
            }),
            _buildDivider(),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  userProvider.logout();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 50),
            const Icon(Icons.person_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Chào mừng bạn đến với Etsy!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Đăng nhập để xem hồ sơ, đơn hàng và nhiều hơn nữa.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("ĐĂNG NHẬP / ĐĂNG KÝ", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade800, height: 1, thickness: 1);
  }
}
