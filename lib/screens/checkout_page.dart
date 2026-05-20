import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';
import '../services/database.dart';
import 'payment_qr_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _customName;
  String? _customPhone;
  String? _customAddress;

  String _paymentMethod = "Thanh toán khi nhận hàng (COD)";
  double _discountAmount = 0.0;
  String? _discountCode;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final user = userProvider.currentUser;
    // Chỉ lấy ra các mặt hàng đã được đánh dấu chọn trong giỏ
    final selectedItems = cart.items.values
        .where((item) => item.isSelected)
        .toList();

    final displayName = _customName ?? user?.name ?? "Người mua hàng";
    final displayPhone = _customPhone ?? user?.phoneNumber ?? "";
    final displayAddress =
        _customAddress ?? user?.deliveryAddress ?? "Việt Nam";

    double finalTotal = cart.selectedTotalAmount - _discountAmount;
    if (finalTotal < 0) finalTotal = 0;

    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: const Text(
          "Xác nhận thanh toán",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ĐỊA CHỈ NHẬN HÀNG",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showEditAddressDialog(
                        displayName,
                        displayPhone,
                        displayAddress,
                      ),
                      child: const Text(
                        "Thay đổi",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.deepOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            displayPhone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text(
                          displayAddress,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "PHƯƠNG THỨC THANH TOÁN",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: Colors.white),
                    title: Text(
                      _paymentMethod,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                    onTap: _showPaymentMethodSheet,
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "MÃ GIẢM GIÁ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_offer_outlined,
                      color: Colors.deepOrange,
                    ),
                    title: Text(
                      _discountCode ?? "Chọn hoặc nhập mã giảm giá",
                      style: TextStyle(
                        color: _discountCode != null
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                    onTap: () => _showPromoCodeSheet(cart.selectedTotalAmount),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "TÓM TẮT ĐƠN HÀNG",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ...selectedItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 45,
                                    height: 45,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Số lượng: ${item.quantity}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatCurrency.format(
                                      item.price * item.quantity,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  FutureBuilder<UserModel?>(
                                    future: DatabaseService().getUser(item.sellerId),
                                    builder: (context, snapshot) {
                                      String sName = item.sellerName;
                                      if (snapshot.hasData && snapshot.data != null) {
                                        sName = snapshot.data!.name;
                                      }
                                      return Text(
                                        "Bán bởi: $sName",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: Colors.grey, height: 30),
                      _buildPriceRow(
                        "Tạm tính",
                        cart.selectedTotalAmount,
                        formatCurrency,
                      ),
                      _buildPriceRow(
                        "Phí vận chuyển",
                        0,
                        formatCurrency,
                        isFree: true,
                      ),
                      if (_discountAmount > 0)
                        _buildPriceRow(
                          "Giảm giá",
                          -_discountAmount,
                          formatCurrency,
                          isDiscount: true,
                        ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatCurrency.format(finalTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(
              20,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
            decoration: BoxDecoration(
              color: etsyCardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade800)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedItems.isEmpty) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepOrange)),
                  );
                  try {
                    // 2. Tạo đơn hàng trên Hệ thống
                    final orderId =
                        await userProvider.addOrder(selectedItems, finalTotal);

                    // Đóng dialog loading
                    if (mounted) Navigator.pop(context);

                    // 4. KIỂM TRA PHƯƠNG THỨC THANH TOÁN
                    if (_paymentMethod == "Chuyển khoản ngân hàng") {
                      if (mounted) {
                        // Tạo tóm tắt sản phẩm (VD: Ao polo, Giay nam...)
                        String summary = selectedItems
                            .map((item) => item.title)
                            .join(", ");
                        if (summary.length > 30) {
                          summary = "${summary.substring(0, 27)}...";
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentQRPage(
                              orderId: orderId,
                              totalAmount: finalTotal,
                              purchaserName: displayName,
                              productSummary: summary,
                            ),
                          ),
                        );
                      }
                    } else {
                      // Luồng đối với COD: Xóa giỏ hàng và về trang chủ
                      cart.clearSelectedCart();
                      await userProvider
                          .syncCartToFirebase(cart.items.values.toList());

                      if (mounted) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "🎉 Đặt hàng thành công ($_paymentMethod)!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (error) {
                    if (mounted) {
                      Navigator.pop(context); // Đóng loading nếu lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Có lỗi xảy ra: $error"),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "ĐẶT HÀNG NGAY",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(
    String currentName,
    String currentPhone,
    String currentAddress,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final addrCtrl = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: etsyCardColor,
        title: const Text(
          "Thay đổi địa chỉ",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Tên người nhận",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: addrCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Địa chỉ",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customName = nameCtrl.text;
                _customPhone = phoneCtrl.text;
                _customAddress = addrCtrl.text;
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSheet() {
    final methods = [
      "Thanh toán khi nhận hàng (COD)",
      "Chuyển khoản ngân hàng",
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: etsyCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Phương thức thanh toán",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...methods.map(
                  (method) => ListTile(
                    title: Text(
                      method,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(Icons.payment, color: Colors.white70),
                    onTap: () {
                      setState(() => _paymentMethod = method);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPromoCodeSheet(double totalAmount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: etsyCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Chọn mã giảm giá",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text(
                    "Giảm 10% (Tối đa 50k)",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text("Áp dụng cho mọi đơn hàng"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _discountCode = "GIAM10";
                        double discount = totalAmount * 0.1;
                        _discountAmount = discount > 50000 ? 50000 : discount;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Giảm 30.000đ",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text("Cho đơn hàng từ 150k"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (totalAmount >= 150000) {
                        setState(() {
                          _discountCode = "GIAM30K";
                          _discountAmount = 30000;
                        });
                        Navigator.pop(ctx);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đơn hàng chưa đủ điều kiện!"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Xóa mã giảm giá",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  leading: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                  onTap: () {
                    setState(() {
                      _discountCode = null;
                      _discountAmount = 0.0;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    NumberFormat format, {
    bool isFree = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            isFree ? "Miễn phí" : format.format(amount),
            style: TextStyle(
              color: isFree
                  ? Colors.green
                  : (isDiscount ? Colors.deepOrange : Colors.white70),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
