import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import '../constants/app_colors.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final salesOrders = userProvider.salesOrders;
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Sắp xếp các đơn hàng theo mức độ ưu tiên trạng thái
    final sortedSalesOrders = List<OrderModel>.from(salesOrders)..sort((a, b) {
      int getStatusPriority(String status) {
        switch (status) {
          case 'Chờ xác nhận':
          case 'Đã đặt hàng':
            return 1; // Món hàng chờ được xác nhận
          case 'Đang chuẩn bị hàng':
            return 2; // Món hàng chờ được giao hàng
          case 'Đang giao':
            return 3;
          case 'Đã giao':
            return 4;
          case 'Yêu cầu trả hàng':
            return 5;
          case 'Đã trả hàng':
            return 6;
          case 'Từ chối trả hàng':
            return 7;
          case 'Đã hủy':
            return 8; // Món hàng đã hủy
          default:
            return 9;
        }
      }
      int pA = getStatusPriority(a.status);
      int pB = getStatusPriority(b.status);
      if (pA != pB) {
        return pA.compareTo(pB);
      }
      // Nếu cùng trạng thái, sắp xếp theo thời gian mới nhất lên trên
      return b.timestamp.compareTo(a.timestamp);
    });

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: etsyBackground,
        appBar: AppBar(
          backgroundColor: etsyBackground,
          elevation: 0,
          title: const Text("Quản lý đơn hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Xác nhận"),
              Tab(text: "Đang giao"),
              Tab(text: "Đã giao"),
              Tab(text: "Đã hủy"),
            ],
          ),
        ),
        body: sortedSalesOrders.isEmpty
            ? _buildEmptyState()
            : TabBarView(
                children: [
                  _buildOrdersList(
                    context,
                    sortedSalesOrders.where((o) => o.status == 'Chờ xác nhận' || o.status == 'Đã đặt hàng' || o.status == 'Yêu cầu trả hàng').toList(),
                    formatCurrency,
                  ),
                  _buildOrdersList(
                    context,
                    sortedSalesOrders.where((o) => o.status == 'Đang chuẩn bị hàng' || o.status == 'Đang giao').toList(),
                    formatCurrency,
                  ),
                  _buildOrdersList(
                    context,
                    sortedSalesOrders.where((o) => o.status == 'Đã giao').toList(),
                    formatCurrency,
                  ),
                  _buildOrdersList(
                    context,
                    sortedSalesOrders.where((o) => o.status == 'Đã hủy' || o.status == 'Đã trả hàng' || o.status == 'Từ chối trả hàng').toList(),
                    formatCurrency,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<OrderModel> orders, NumberFormat formatCurrency) {
    if (orders.isEmpty) {
      return const Center(child: Text("Không có đơn hàng nào trong mục này.", style: TextStyle(color: Colors.grey)));
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: orders.length,
      itemBuilder: (ctx, index) {
        final order = orders[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: etsyCardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Mã đơn: ${order.id}",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Khách hàng (ID): ${order.buyerId}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.timestamp)}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(color: Colors.grey, height: 25),

              // ITEMS LIST
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("x${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),

              const Divider(color: Colors.grey, height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng doanh thu:", style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text(formatCurrency.format(order.totalAmount),
                      style: const TextStyle(color: etsyGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              // RETURN DETAILS SECTION
              if (order.returnRequest != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "YÊU CẦU ĐỔI TRẢ (${order.returnRequest!['status'] ?? 'Chờ xác nhận'})",
                            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lý do của khách: \"${order.returnRequest!['reason'] ?? ''}\"",
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                      if (order.returnRequest!['images'] != null && (order.returnRequest!['images'] as List).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text("Ảnh minh chứng hư hỏng/lỗi:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (order.returnRequest!['images'] as List).length,
                            itemBuilder: (ctx, i) {
                              final imgUrl = order.returnRequest!['images'][i];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () => _showFullImageDialog(context, imgUrl),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      imgUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ACTION BUTTONS FOR SELLER
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    if (order.status == 'Chờ xác nhận' || order.status == 'Đã đặt hàng')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => userProvider.updateOrderStatus(order.id, 'Đang chuẩn bị hàng'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text("XÁC NHẬN ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (order.status == 'Đang chuẩn bị hàng')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => userProvider.updateOrderStatus(order.id, 'Đang giao'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text("GIAO HÀNG NGAY", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (order.status == 'Đang giao')
                      const Expanded(
                        child: Center(
                          child: Text("🚚 Đơn hàng đang được giao cho khách", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      ),
                    if (order.status == 'Yêu cầu trả hàng') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmReturnAction(context, userProvider, order.id, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("TỪ CHỐI", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmReturnAction(context, userProvider, order.id, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("ĐỒNG Ý ĐỔI TRẢ", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Bạn chưa bán đơn hàng nào.", style: TextStyle(color: Colors.grey)));
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Chờ xác nhận' || status == 'Đã đặt hàng') color = Colors.orange;
    if (status == 'Đang chuẩn bị hàng') color = Colors.amber;
    if (status == 'Đang giao') color = Colors.blue;
    if (status == 'Đã giao') color = Colors.green;
    if (status == 'Đã hủy') color = Colors.red;
    if (status == 'Yêu cầu trả hàng') color = Colors.orangeAccent;
    if (status == 'Đã trả hàng') color = Colors.purple;
    if (status == 'Từ chối trả hàng') color = Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReturnAction(BuildContext context, UserProvider provider, String orderId, bool approve) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: etsyCardColor,
        title: Text(approve ? "Xác nhận đồng ý đổi trả" : "Xác nhận từ chối đổi trả", style: const TextStyle(color: Colors.white)),
        content: Text(
          approve
              ? "Bạn có chắc chắn muốn ĐỒNG Ý yêu cầu đổi trả này? Tiền thanh toán của đơn hàng sẽ bị trừ khỏi doanh thu của bạn."
              : "Bạn có chắc chắn muốn TỪ CHỐI yêu cầu đổi trả từ người mua?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await provider.handleReturnRequest(orderId: orderId, approve: approve);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(approve ? "🎉 Đã chấp nhận yêu cầu đổi trả!" : "🛑 Đã từ chối yêu cầu đổi trả!"),
                    backgroundColor: approve ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(
              approve ? "ĐỒNG Ý" : "TỪ CHỐI",
              style: TextStyle(color: approve ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
