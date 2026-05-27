import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';
import 'personal_info_page.dart';
import 'register_page.dart';

class SellerRegisterPage extends StatefulWidget {
  const SellerRegisterPage({super.key});

  @override
  State<SellerRegisterPage> createState() => _SellerRegisterPageState();
}

class _SellerRegisterPageState extends State<SellerRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
      return;
    }

    final error = await Provider.of<UserProvider>(context, listen: false).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      isSellerRole: true,
    );
    
    if (mounted) {
      if (error == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký Người bán'), backgroundColor: eraBackground),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tạo tài khoản bán hàng', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên cửa hàng/Họ và tên', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                child: const Text('ĐĂNG KÝ BÁN HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text(
                'Bạn là người mua hàng?',
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
