import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';
import 'settings_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thông tin cá nhân", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("THÔNG TIN CƠ BẢN", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    label: "Hình đại diện", 
                    isAvatar: true, 
                    onTap: () {}
                  ),
                  _buildDivider(),
                  _buildProfileRow(
                    label: "Tên người dùng", 
                    value: user?.name ?? "Trần Đình Sang", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
                  ),
                  _buildDivider(),
                  _buildProfileRow(
                    label: "Số điện thoại", 
                    value: user?.phoneNumber ?? "********506", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
                  ),
                  _buildDivider(),
                  _buildProfileRow(
                    label: "Email", 
                    value: user?.email ?? "sang@gmail.com", 
                    onTap: () {}
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text("ĐỊA CHỈ GIAO HÀNG", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProfileRow(
                label: "Địa chỉ mặc định", 
                value: user?.deliveryAddress ?? "Việt Nam", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
              ),
            ),

            const SizedBox(height: 25),
            const Text("QUẢN LÝ CỬA HÀNG", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(userProvider.isSeller ? Icons.store : Icons.person_outline, color: Colors.white),
                title: Text(
                  userProvider.isSeller ? "Đang ở chế độ Người bán" : "Đang ở chế độ Người mua", 
                  style: const TextStyle(color: Colors.white, fontSize: 15)
                ),
                trailing: Switch(
                  value: userProvider.isSeller,
                  onChanged: (val) {
                    userProvider.toggleRole();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(userProvider.isSeller ? "Đã chuyển sang chế độ NGƯỜI BÁN" : "Đã chuyển sang chế độ NGƯỜI MUA"))
                    );
                  },
                  activeColor: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, String? value, bool isAvatar = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
            Row(
              children: [
                if (isAvatar)
                  const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white))
                else
                  Text(value ?? "", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15, thickness: 0.2);
  }
}
