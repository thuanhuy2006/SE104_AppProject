import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

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
        title: const Text("Thông tin người dùng", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // KHỐI THÔNG TIN CÁ NHÂN (Khôi phục từ bản cũ)
            Container(
              decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Ảnh đại diện
                  _buildProfileRow(
                    label: "Đổi hình đại diện", 
                    isAvatar: true, 
                    onTap: () {}
                  ),
                  _buildDivider(),

                  // Số điện thoại (Giữ nguyên placeholder cũ)
                  _buildProfileRow(
                    label: "Số điện thoại", 
                    value: "********506", 
                    onTap: () {}
                  ),
                  _buildDivider(),

                  // Tên (Lấy từ UserProvider)
                  _buildProfileRow(
                    label: "Tên", 
                    value: user?.name ?? "Chưa cập nhật", 
                    onTap: () {}
                  ),
                  _buildDivider(),

                  // Email (Lấy từ UserProvider)
                  _buildProfileRow(
                    label: "Email", 
                    value: user?.email ?? "Nhập Email", 
                    isValueHint: user == null, 
                    onTap: () {}
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KHỐI CHẾ ĐỘ NGƯỜI BÁN (Tích hợp thêm)
            Container(
              decoration: BoxDecoration(
                color: etsyCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                leading: Icon(userProvider.isSeller ? Icons.store : Icons.person_outline, color: Colors.white),
                title: Text(
                  userProvider.isSeller ? "Chế độ: Người bán" : "Chế độ: Người mua", 
                  style: const TextStyle(color: Colors.white, fontSize: 16)
                ),
                trailing: Switch(
                  value: userProvider.isSeller,
                  onChanged: (val) {
                    userProvider.toggleRole();
                  },
                  activeColor: Colors.deepOrange,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // NÚT ĐĂNG XUẤT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  userProvider.logout();
                  Navigator.pop(context); // Quay lại main screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required String label, 
    String? value, 
    bool isAvatar = false, 
    bool isValueHint = false, 
    VoidCallback? onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isAvatar)
              CircleAvatar(
                radius: 25, 
                backgroundColor: Colors.grey.shade600, 
                child: const Icon(Icons.person, color: Colors.white, size: 30)
              )
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

  Widget _buildDivider() {
    return const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15, thickness: 0.3);
  }
}
