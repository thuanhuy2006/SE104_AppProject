import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';

class EditVoucherPage extends StatefulWidget {
  final Voucher? voucherToEdit;
  const EditVoucherPage({super.key, this.voucherToEdit});

  @override
  State<EditVoucherPage> createState() => _EditVoucherPageState();
}

class _EditVoucherPageState extends State<EditVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _minSpendController = TextEditingController();
  final _discountPercentController = TextEditingController();

  bool _isLoading = false;
  final List<String> _categories = ['Trang sức', 'Quần áo', 'Phụ kiện', 'Giày dép'];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    if (widget.voucherToEdit != null) {
      final voucher = widget.voucherToEdit!;
      _codeController.text = voucher.code;
      _minSpendController.text = voucher.minSpend.toInt().toString();
      _discountPercentController.text = voucher.discountPercent.toInt().toString();
      _selectedCategories.addAll(voucher.applicableCategories);
    } else {
      // By default, apply to all categories
      _selectedCategories.addAll(_categories);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _minSpendController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  Future<void> _saveVoucher() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất 1 danh mục áp dụng!'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Chưa đăng nhập!')));
        return;
      }

      setState(() => _isLoading = true);

      final isEditing = widget.voucherToEdit != null;
      final voucherData = Voucher(
        code: _codeController.text.trim().toUpperCase(),
        sellerId: currentUser.uid,
        sellerName: currentUser.name,
        minSpend: double.tryParse(_minSpendController.text.trim()) ?? 0.0,
        discountPercent: double.tryParse(_discountPercentController.text.trim()) ?? 0.0,
        applicableCategories: _selectedCategories,
      );

      try {
        final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
        await voucherProvider.saveVoucher(voucherData);

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? '🎉 Cập nhật voucher thành công!' : '🎉 Thêm voucher thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi lưu voucher: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.voucherToEdit != null;

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa Voucher' : 'Thêm Voucher mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: eraBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text("THÔNG TIN VOUCHER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Mã Voucher
                TextFormField(
                  controller: _codeController,
                  enabled: !isEditing, // Khóa mã code không cho sửa nếu là chế độ chỉnh sửa
                  style: TextStyle(color: isEditing ? Colors.grey : Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration("Mã Voucher (VD: GIAM20, SHOPENERA)").copyWith(
                    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Vui lòng nhập mã Voucher";
                    if (val.trim().contains(" ")) return "Mã Voucher không được chứa dấu cách";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phần trăm giảm giá
                TextFormField(
                  controller: _discountPercentController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Phần trăm giảm giá (%) - Ví dụ: 20"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Vui lòng nhập phần trăm giảm";
                    final percent = double.tryParse(val.trim());
                    if (percent == null || percent <= 0 || percent > 100) {
                      return "Phần trăm giảm phải từ 1 đến 100";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Chi tiêu tối thiểu
                TextFormField(
                  controller: _minSpendController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Chi tiêu tối thiểu (đ) - Ví dụ: 1000000"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Vui lòng nhập mức chi tiêu tối thiểu";
                    final min = double.tryParse(val.trim());
                    if (min == null || min < 0) {
                      return "Mức chi tiêu tối thiểu không hợp lệ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // Danh mục áp dụng
                const Text("DANH MỤC SẢN PHẨM ÁP DỤNG", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: eraCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Column(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return CheckboxListTile(
                        title: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 15)),
                        value: isSelected,
                        activeColor: Colors.amber.shade700,
                        checkColor: Colors.white,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              if (!_selectedCategories.contains(cat)) {
                                _selectedCategories.add(cat);
                              }
                            } else {
                              _selectedCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                // Nút Hoàn tất
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? "CẬP NHẬT VOUCHER" : "HOÀN TẤT THÊM", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: eraCardColor,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
    );
  }
}
