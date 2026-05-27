import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../services/database.dart';
import '../providers/app_providers.dart';

class BuyerVouchersPage extends StatefulWidget {
  const BuyerVouchersPage({super.key});

  @override
  State<BuyerVouchersPage> createState() => _BuyerVouchersPageState();
}

class _BuyerVouchersPageState extends State<BuyerVouchersPage> {
  final _codeController = TextEditingController();
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      if (user is BuyerModel) {
        Provider.of<VoucherProvider>(context, listen: false).fetchBuyerVouchers(user.discountCodes);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _claimVoucher() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã Voucher!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu Voucher!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (user is BuyerModel && user.discountCodes.contains(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Bạn đã sở hữu Voucher này rồi!'), backgroundColor: Colors.amber.shade900),
      );
      return;
    }

    setState(() => _isClaiming = true);

    try {
      final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
      final success = await voucherProvider.claimVoucher(user.uid, code, userProvider);

      if (mounted) {
        setState(() => _isClaiming = false);
        if (success) {
          _codeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Lưu Voucher thành công!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mã Voucher không tồn tại hoặc không hợp lệ!'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClaiming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final voucherProvider = Provider.of<VoucherProvider>(context);
    final buyerVouchers = voucherProvider.buyerVouchers;

    return Scaffold(
      backgroundColor: eraBackground,
      appBar: AppBar(
        backgroundColor: eraBackground,
        elevation: 0,
        title: const Text("Voucher của tôi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Claim Voucher Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Nhập mã Voucher của shop...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: eraCardColor,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isClaiming ? null : _claimVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isClaiming
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Thêm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text("DANH SÁCH VOUCHER ĐÃ LƯU", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Vouchers List
          Expanded(
            child: voucherProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                : buyerVouchers.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: buyerVouchers.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                        itemBuilder: (ctx, i) {
                          final voucher = buyerVouchers[i];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: eraCardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Row(
                              children: [
                                // Voucher Ticket Icon
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          Text(
                                            "Shop: ${voucher.sellerName}",
                                            style: const TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic),
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
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          const Text(
            "Bạn chưa có Voucher nào",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Nhập mã giảm giá của người bán ở trên và lưu lại để được ưu đãi khi thanh toán đơn hàng nhé!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
