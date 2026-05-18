import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final dynamic ordersData = userProvider.myOrders;
    final List<dynamic> orders = ordersData is List ? ordersData : [];
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
          final dynamic order = orders[index];

          // Giải mã ngày tháng an toàn từ Firestore Timestamp hoặc chuỗi định dạng
          dynamic dateRaw;
          if (order is Map) {
            dateRaw = order['date'] ?? order['timestamp'];
          } else {
            try { dateRaw = order.timestamp; } catch(_) { dateRaw = null; }
          }

          DateTime date = DateTime.now();
          if (dateRaw is Timestamp) {
            date = dateRaw.toDate();
          } else if (dateRaw is String) {
            date = DateTime.tryParse(dateRaw) ?? DateTime.now();
          } else if (dateRaw is DateTime) {
            date = dateRaw;
          }

          // Trích xuất danh sách sản phẩm bên trong đơn hàng
          List<dynamic> items = [];
          if (order is Map) {
            items = order['items'] ?? [];
          } else {
            try { items = order.items ?? []; } catch(_) {}
          }

          // Trích xuất trạng thái đơn hàng
          String status = 'Đã đặt hàng';
          if (order is Map) {
            status = order['status'] ?? 'Đã đặt hàng';
          } else {
            try { status = order.status ?? 'Đã đặt hàng'; } catch(_) {}
          }

          // Tính toán tổng số tiền thanh toán
          num totalAmount = 0;
          if (order is Map) {
            final dynamic t = order['total'] ?? order['totalAmount'] ?? 0;
            totalAmount = t is num ? t : 0;
          } else {
            try { totalAmount = order.totalAmount ?? 0; } catch(_) {}
          }

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
                      "Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      status,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 25),

                // Tiến trình xử lý trạng thái đơn hàng
                _buildTimeline(order),
                const SizedBox(height: 15),

                ...items.map((item) {
                  String itemTitle = 'Sản phẩm';
                  dynamic itemQuantity = 1;
                  num itemPrice = 0;

                  if (item is Map) {
                    itemTitle = item['title']?.toString() ?? 'Sản phẩm';
                    itemQuantity = item['quantity'] ?? 1;
                    final dynamic p = item['price'] ?? 0;
                    itemPrice = p is num ? p : 0;
                  } else {
                    try { itemTitle = item.title ?? 'Sản phẩm'; } catch(_) {}
                    try { itemQuantity = item.quantity ?? 1; } catch(_) {}
                    try { itemPrice = item.price ?? 0; } catch(_) {}
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade800,
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemTitle,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text("x$itemQuantity", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(
                            formatCurrency.format(itemPrice),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(color: Colors.grey, height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng thanh toán:", style: TextStyle(color: Colors.white, fontSize: 15)),
                    Text(
                        formatCurrency.format(totalAmount),
                        style: const TextStyle(color: Colors.deepOrange, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(dynamic order) {
    final List<String> stages = ['Đã đặt hàng', 'Chờ xác nhận', 'Đang giao', 'Đã giao'];
    String currentStatus = 'Đã đặt hàng';
    if (order is Map) {
      currentStatus = order['status'] ?? 'Đã đặt hàng';
    } else {
      try { currentStatus = order.status ?? 'Đã đặt hàng'; } catch(_) {}
    }

    int currentIdx = stages.indexOf(currentStatus);
    if (currentIdx == -1) currentIdx = 0;

    return Row(
      children: List.generate(stages.length, (index) {
        bool isDone = index <= currentIdx;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Colors.green : Colors.grey[700],
                ),
              ),
              if (index < stages.length - 1)
                Expanded(child: Container(height: 2, color: isDone ? Colors.green : Colors.grey[700])),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          const Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Hãy bắt đầu mua sắm để lấp đầy danh sách này!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}