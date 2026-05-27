import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
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

    // Sắp xếp các đơn hàng theo mức độ ưu tiên trạng thái
    final sortedOrders = List<OrderModel>.from(orders)..sort((a, b) {
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

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        backgroundColor: eraBackground,
        elevation: 0,
        title: const Text("Đơn mua của bạn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sortedOrders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: sortedOrders.length,
        itemBuilder: (context, index) {
          final order = sortedOrders[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: eraCardColor,
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

                // NÚT CHỨC NĂNG (HỦY ĐƠN / NHẬN HÀNG / ĐÁNH GIÁ / ĐỔI TRẢ HÀNG)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      if (order.status == 'Chờ xác nhận' || order.status == 'Đã đặt hàng')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showCancelOrderDialog(context, userProvider, order.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (order.status == 'Đang giao')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => userProvider.markAsReceived(order.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text("ĐÃ NHẬN ĐƯỢC HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (order.status == 'Đã giao') ...[
                        if (order.review == null) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showReviewDialog(context, order),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                              child: const Text("ĐÁNH GIÁ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ] else ...[
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text("✨ Đã đánh giá", style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic, fontSize: 14)),
                            ),
                          ),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showReturnDialog(context, order),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text("ĐỔI TRẢ HÀNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
      ),
    );
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
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    if (order.status == 'Yêu cầu trả hàng') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orangeAccent, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Đang chờ người bán xác nhận yêu cầu đổi trả",
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    if (order.status == 'Đã trả hàng') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(Icons.assignment_return_outlined, color: Colors.purpleAccent, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Đơn mua đã được đổi trả thành công",
                style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    if (order.status == 'Từ chối trả hàng') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Yêu cầu đổi trả của bạn đã bị từ chối",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

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
        backgroundColor: eraCardColor,
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
              backgroundColor: eraCardColor,
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

  void _showReturnDialog(BuildContext context, OrderModel order) {
    final TextEditingController reasonController = TextEditingController();
    List<File> selectedImages = [];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: eraBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                selectedImages.add(File(pickedFile.path));
              });
            }
          }

          Future<void> submitRequest() async {
            if (reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Vui lòng nhập lý do đổi trả!"), backgroundColor: Colors.redAccent),
              );
              return;
            }

            setState(() => isSubmitting = true);

            try {
              List<String> imageUrls = [];
              for (int i = 0; i < selectedImages.length; i++) {
                final uploadedUrl = await ImageUploadService.uploadImage(selectedImages[i]);
                if (uploadedUrl != null) {
                  imageUrls.add(uploadedUrl);
                } else {
                  throw Exception('Không nhận được liên kết ảnh minh chứng thứ ${i + 1} từ Cloudinary. Vui lòng kiểm tra lại cấu hình hoặc kết nối mạng.');
                }
              }

              await Provider.of<UserProvider>(context, listen: false).requestReturn(
                orderId: order.id,
                reason: reasonController.text.trim(),
                imageUrls: imageUrls,
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🎉 Đã gửi yêu cầu đổi trả thành công!"), backgroundColor: Colors.green),
                );
              }
            } catch (e) {
              debugPrint("Lỗi gửi yêu cầu đổi trả: $e");
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.redAccent),
                );
              }
            } finally {
              setState(() => isSubmitting = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Yêu cầu đổi trả hàng",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Đơn hàng: ${order.id}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "LÝ DO ĐỔI TRẢ",
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Hãy viết rõ lý do hàng bị hỏng, lỗi hoặc không đúng mô tả để được duyệt nhanh chóng...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: eraCardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ẢNH MINH CHỨNG HỎNG/LỖI",
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, color: Colors.deepOrange),
                        onPressed: isSubmitting ? null : pickImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  selectedImages.isEmpty
                      ? InkWell(
                          onTap: isSubmitting ? null : pickImage,
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: eraCardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, color: Colors.grey, size: 28),
                                  SizedBox(height: 5),
                                  Text("Bấm vào đây để chọn ảnh", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImages.length,
                            itemBuilder: (ctx, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("GỬI YÊU CẦU ĐỔI TRẢ", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}