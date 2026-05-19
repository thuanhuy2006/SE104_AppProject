import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final Product? productToEdit;
  const AddProductPage({super.key, this.productToEdit});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _voucherController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;
  String _selectedCategory = 'Quần áo';

  final List<String> _categories = ['Trang sức', 'Quần áo', 'Phụ kiện', 'Giày dép'];

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final product = widget.productToEdit!;
      _titleController.text = product.title;
      _priceController.text = product.price.toString();
      _stockQuantityController.text = product.stockQuantity.toString();
      _voucherController.text = product.vouchers.isNotEmpty ? product.vouchers.first : '';
      _descriptionController.text = product.description;
      if (_categories.contains(product.category)) {
        _selectedCategory = product.category;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _voucherController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập!')));
        return;
      }

      setState(() => _isLoading = true);

      final isEditing = widget.productToEdit != null;
      String imageUrl = isEditing ? widget.productToEdit!.imageUrl : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=500';

      if (_imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child('product_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu ảnh thất bại, sử dụng ảnh mặc định.')));
        }
      }

      final productData = Product(
        id: isEditing ? widget.productToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl, 
        category: _selectedCategory,
        sellerId: currentUser.uid,
        sellerName: currentUser.name,
        stockQuantity: int.tryParse(_stockQuantityController.text.trim()) ?? 1,
        vouchers: _voucherController.text.trim().isNotEmpty ? [_voucherController.text.trim()] : [],
        revenue: isEditing ? widget.productToEdit!.revenue : 0.0,
        rating: isEditing ? widget.productToEdit!.rating : 0.0,
        reviewCount: isEditing ? widget.productToEdit!.reviewCount : 0,
      );

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (isEditing) {
        await productProvider.updateProduct(productData);
      } else {
        await productProvider.addProduct(productData);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '🎉 Cập nhật thành công!' : '🎉 Đăng bán thành công!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        title: Text(widget.productToEdit != null ? 'Chỉnh sửa sản phẩm' : 'Đăng bán sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: etsyBackground,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text("THÔNG TIN CƠ BẢN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildTextField(_titleController, "Tên sản phẩm"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_priceController, "Giá bán (đ)", isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: etsyCardColor,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Danh mục"),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(_descriptionController, "Mô tả chi tiết", maxLines: 4),
                const SizedBox(height: 20),
                const Text("HÌNH ẢNH", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(color: etsyCardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade800)),
                    child: _imageFile != null 
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : const Center(child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40)),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                    child: _isLoading ? const CircularProgressIndicator() : const Text("HOÀN TẤT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      validator: (val) => val!.isEmpty ? "Vui lòng nhập thông tin" : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: etsyCardColor,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
    );
  }
}
