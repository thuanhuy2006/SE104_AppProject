import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import '../constants/app_colors.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final orders = userProvider.myOrders;
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: const Text("Đơn mua của bạn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ngày đặt: ${DateFormat('dd/MM/yyyy').format(order.timestamp)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const Divider(color: Colors.grey, height: 25),

                // TIẾN TRÌNH ĐƠN HÀNG (Nếu bị hủy thì hiện text cảnh báo thay vì Timeline)
                if (order.status == 'Đã hủy')
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        "🛑 Đơn hàng này đã bị hủy thành công",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  )
                else
                  _buildTimeline(order),

                const SizedBox(height: 20),

                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("x${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(color: Colors.grey, height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng thanh toán:", style: TextStyle(color: Colors.white, fontSize: 15)),
                    Text(formatCurrency.format(order.totalAmount),
                        style: const TextStyle(color: Colors.deepOrange, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),

                // NÚT CHỨC NĂNG (HỦY ĐƠN / NHẬN HÀNG / ĐÁNH GIÁ)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      if (order.status == 'Chờ xác nhận')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showCancelOrderDialog(context, userProvider, order.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                            child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (order.status == 'Đang giao')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => userProvider.markAsReceived(order.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text("ĐÃ NHẬN ĐƯỢC HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (order.status == 'Đã giao' && order.review == null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showReviewDialog(context, order),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                            child: const Text("ĐÁNH GIÁ NGAY", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (order.status == 'Đã giao' && order.review != null)
                        const Expanded(
                          child: Text("✨ Bạn đã đánh giá đơn hàng này", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic)),
                        )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Chờ xác nhận') color = Colors.orange;
    if (status == 'Đang chuẩn bị hàng') color = Colors.amber;
    if (status == 'Đang giao') color = Colors.blue;
    if (status == 'Đã giao') color = Colors.green;
    if (status == 'Đã hủy') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    // ĐÃ ĐỔI TÊN TIẾN TRÌNH THEO LUỒNG MỚI
    final List<String> stages = ['Chờ xác nhận', 'Đang chuẩn bị hàng', 'Đang giao', 'Đã giao'];
    int currentIdx = stages.indexOf(order.status);
    if (currentIdx == -1) currentIdx = 0;

    return Row(
      children: List.generate(stages.length, (index) {
        bool isDone = index <= currentIdx;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isDone ? Colors.green : Colors.grey[800]))),
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? Colors.green : Colors.grey[800]),
                  ),
                  Expanded(child: Container(height: 2, color: index == stages.length - 1 ? Colors.transparent : (index < currentIdx ? Colors.green : Colors.grey[800]))),
                ],
              ),
              const SizedBox(height: 5),
              Text(stages[index], style: TextStyle(color: isDone ? Colors.white70 : Colors.grey, fontSize: 8), textAlign: TextAlign.center),
            ],
          ),
        );
      }),
    );
  }

  void _showCancelOrderDialog(BuildContext context, UserProvider provider, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: etsyCardColor,
        title: const Text("Xác nhận hủy đơn", style: TextStyle(color: Colors.white)),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("KHÔNG", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await provider.cancelOrder(orderId);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🛑 Đã hủy đơn hàng thành công!"), backgroundColor: Colors.red)
                );
              }
            },
            child: const Text("HỦY ĐƠN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, OrderModel order) {
    double rating = 5.0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: etsyCardColor,
              title: const Text("Đánh giá sản phẩm", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Hãy chia sẻ cảm nhận của bạn về sản phẩm...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập bình luận!"))
                      );
                      return;
                    }

                    await Provider.of<UserProvider>(context, listen: false).submitOrderReview(
                      orderId: order.id,
                      rating: rating,
                      comment: commentController.text.trim(),
                      items: order.items,
                    );

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("🎉 Cảm ơn bạn đã đánh giá!"), backgroundColor: Colors.green)
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: const Text("GỬI ĐÁNH GIÁ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return const Center(child: Text("Bạn chưa có đơn hàng nào.", style: TextStyle(color: Colors.grey)));
  }
}