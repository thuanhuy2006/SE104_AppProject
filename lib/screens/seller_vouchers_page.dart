import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import 'edit_voucher_page.dart';

class SellerVouchersPage extends StatefulWidget {
  const SellerVouchersPage({super.key});

  @override
  State<SellerVouchersPage> createState() => _SellerVouchersPageState();
}

class _SellerVouchersPageState extends State<SellerVouchersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sellerId = userProvider.currentUser?.uid ?? '';
      Provider.of<VoucherProvider>(context, listen: false).fetchSellerVouchers(sellerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final userProvider = Provider.of<UserProvider>(context);
    final voucherProvider = Provider.of<VoucherProvider>(context);
    final vouchers = voucherProvider.sellerVouchers;

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        backgroundColor: eraBackground,
        elevation: 0,
        title: const Text("Quản lý Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: voucherProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : vouchers.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vouchers.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                  itemBuilder: (ctx, i) {
                    final voucher = vouchers[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: eraCardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Row(
                        children: [
                          // Voucher Ticket Icon Design
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade800.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.local_offer, color: Colors.amber, size: 24),
                                const SizedBox(height: 5),
                                Text(
                                  "${voucher.discountPercent.toInt()}%",
                                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        voucher.code,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Giảm ${voucher.discountPercent.toInt()}% cho đơn từ ${formatCurrency.format(voucher.minSpend)}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Áp dụng: ${voucher.applicableCategories.join(', ')}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditVoucherPage(voucherToEdit: voucher)),
                                  ).then((_) {
                                    // Refresh
                                    voucherProvider.fetchSellerVouchers(userProvider.currentUser?.uid ?? '');
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _showDeleteConfirm(context, voucherProvider, voucher.code),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditVoucherPage()),
          ).then((_) {
            // Refresh
            voucherProvider.fetchSellerVouchers(userProvider.currentUser?.uid ?? '');
          });
        },
        backgroundColor: Colors.amber.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          const Text(
            "Chưa có Voucher nào",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Tạo mã giảm giá khuyến mãi cho khách hàng bằng cách bấm nút '+' ở góc dưới!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, VoucherProvider provider, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: eraCardColor,
        title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: Text("Bạn có chắc chắn muốn xóa voucher '$code' này không?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await provider.deleteVoucher(code);
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa voucher thành công")));
              }
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
