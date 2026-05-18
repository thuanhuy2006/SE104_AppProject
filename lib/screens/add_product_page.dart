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
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập!')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final isEditing = widget.productToEdit != null;
      String imageUrl = isEditing ? widget.productToEdit!.imageUrl : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=500';

      if (_imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('product_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print('Lỗi Firebase Storage: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa cấu hình Firebase Storage. Dùng ảnh mặc định tạm thời.')),
          );
          // Nếu upload lỗi (do chưa mở Firebase Storage hoặc bị Rules chặn), dùng ảnh cũ hoặc ảnh mặc định
          imageUrl = isEditing ? widget.productToEdit!.imageUrl : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=500';
        }
      }

      final newProduct = Product(
        id: isEditing ? widget.productToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl, 
        category: _selectedCategory,
        sellerId: currentUser.uid,
        stockQuantity: int.tryParse(_stockQuantityController.text.trim()) ?? 1,
        vouchers: _voucherController.text.trim().isNotEmpty ? [_voucherController.text.trim()] : [],
        revenue: isEditing ? widget.productToEdit!.revenue : 0.0,
      );

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (isEditing) {
        await productProvider.updateProduct(newProduct);
      } else {
        await productProvider.addProduct(newProduct);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '🎉 Cập nhật sản phẩm thành công.' : '🎉 Chúc mừng! Sản phẩm đã được đăng bán thành công.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật sản phẩm' : 'Đăng sản phẩm mới', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                const Text("Thông tin cơ bản", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                _buildTextField(_titleController, "Tên sản phẩm", "Ví dụ: Áo thun Vintage"),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField(_priceController, "Giá bán (đ)", "0", isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Danh mục", style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: etsyCardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                dropdownColor: etsyCardColor,
                                style: const TextStyle(color: Colors.white),
                                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                                onChanged: (val) => setState(() => _selectedCategory = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_stockQuantityController, "Số lượng kho", "Ví dụ: 10", isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_voucherController, "Mã giảm giá (nếu có)", "SALE20", isRequired: false)),
                  ],
                ),

                const SizedBox(height: 20),
                _buildTextField(_descriptionController, "Mô tả chi tiết", "Mô tả sản phẩm của bạn...", maxLines: 4),
                
                const SizedBox(height: 20),
                const Text("Hình ảnh", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: etsyCardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade800, style: BorderStyle.solid),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (isEditing && widget.productToEdit!.imageUrl.isNotEmpty && !widget.productToEdit!.imageUrl.contains('unsplash.com'))
                            ? Image.network(widget.productToEdit!.imageUrl, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _buildPlaceholder())
                            : _buildPlaceholder(),
                  ),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(isEditing ? 'CẬP NHẬT SẢN PHẨM' : 'ĐĂNG BÁN NGAY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
        SizedBox(height: 10),
        Text("Tải ảnh từ thiết bị", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: etsyCardColor,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade800)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
          ),
          validator: isRequired ? (value) => value == null || value.isEmpty ? 'Không được để trống' : null : null,
        ),
      ],
    );
  }
}
