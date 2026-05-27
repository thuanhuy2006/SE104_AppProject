import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart'; // Import màu Era của bạn
import '../models/app_models.dart';

class PaymentQRPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String purchaserName;
  final String productSummary;
  final List<CartItem>? purchasedItems;

  const PaymentQRPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.purchaserName,
    required this.productSummary,
    this.purchasedItems,
  });

  @override
  State<PaymentQRPage> createState() => _PaymentQRPageState();
}

class _PaymentQRPageState extends State<PaymentQRPage> {
  Timer? _timer;

  // Thay thông tin Ngân hàng của bạn cấu hình trên SePay vào đây
  final String _bankAccount = "0123456789"; // Số tài khoản ngân hàng
  final String _bankName = "MBBank";        // Tên viết tắt ngân hàng (VCB, MBBank, ICB...)

  @override
  void initState() {
    super.initState();
    _startCheckingPayment();
  }

  // Cứ mỗi 4 giây lại gọi API kiểm tra xem đơn hàng đã chuyển trạng thái thành "Đã thanh toán" chưa
  void _startCheckingPayment() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      // TODO: Gọi API lên Backend/Firebase của bạn để check trạng thái đơn hàng
      // bool isPaid = await userProvider.checkOrderStatus(widget.orderId);
      bool isPaid = false; // Demo giả lập

      if (isPaid) {
        _timer?.cancel();
        _onPaymentSuccess();
      }
    });
  }

  void _onPaymentSuccess() {
    // Xóa các sản phẩm đã thanh toán khỏi giỏ hàng
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (widget.purchasedItems != null) {
      cart.clearPurchasedItems(widget.purchasedItems!);
    } else {
      cart.clearSelectedCart();
    }
    userProvider.syncCartToFirebase(cart.items.values.toList());

    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 Hệ thống đã nhận được thanh toán. Đặt hàng thành công!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi thoát màn hình để tránh leak bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Nội dung chuyển khoản: Tên người mua + Mua hàng + ID đơn
    // Loại bỏ dấu tiếng Việt để tránh lỗi hiển thị trên một số hệ thống ngân hàng
    String cleanName = _removeDiacritics(widget.purchaserName).toUpperCase();
    String cleanItems = _removeDiacritics(widget.productSummary);

    final String paymentContent = "$cleanName MUA $cleanItems ID${widget.orderId}";

    // Tạo Link QR tự động bằng API hiển thị ảnh của SePay
    final String qrImageUrl = "https://qr.sepay.vn/img?acc=$_bankAccount&bank=$_bankName&amount=${widget.totalAmount.toInt()}&des=${Uri.encodeComponent(paymentContent)}";

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        backgroundColor: eraBackground,
        title: const Text("Thanh toán chuyển khoản", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Quay lại trang thanh toán
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Quét mã QR để thanh toán",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Hệ thống sẽ tự động xác nhận sau khi nhận được tiền",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Vùng hiển thị Mã QR
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  qrImageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: eraCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  children: [
                    _buildInfoRow("Số tiền:", formatCurrency.format(widget.totalAmount), isBold: true),
                    const Divider(color: Colors.grey),
                    _buildInfoRow("Nội dung CK:", paymentContent, color: Colors.deepOrange, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                  SizedBox(width: 12),
                  Text("Đang chờ phản hồi từ ngân hàng...", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.white, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hàm hỗ trợ loại bỏ dấu tiếng Việt
  String _removeDiacritics(String str) {
    var withDia = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    var withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }
}