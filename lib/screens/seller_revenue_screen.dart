import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import '../constants/app_colors.dart';

class SellerRevenueScreen extends StatefulWidget {
  const SellerRevenueScreen({super.key});

  @override
  State<SellerRevenueScreen> createState() => _SellerRevenueScreenState();
}

class _SellerRevenueScreenState extends State<SellerRevenueScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'week'; // 'day', 'week', 'month', 'year'
  double _taxRate = 1.5; // Mặc định là 1.5% (Thuế thương mại điện tử hộ kinh doanh tại VN)
  int? _hoveredBarIndex;

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  // Danh sách các tùy chọn tỷ lệ thuế phổ biến
  final List<double> _taxOptions = [0.0, 1.5, 2.0, 5.0, 10.0];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final salesOrders = userProvider.salesOrders;
    final sellerId = userProvider.currentUser?.uid ?? '';

    // Lọc đơn hàng hợp lệ (không bao gồm đơn hủy và trả hàng) cho doanh thu
    final activeOrders = salesOrders.where((o) => o.status != 'Đã hủy' && o.status != 'Đã trả hàng').toList();

    // Tính toán số liệu theo các mốc thời gian
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final startOfWeek = todayStart.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    List<OrderModel> filteredOrders = [];
    if (_selectedPeriod == 'day') {
      filteredOrders = activeOrders.where((o) => o.timestamp.isAfter(todayStart)).toList();
    } else if (_selectedPeriod == 'week') {
      filteredOrders = activeOrders.where((o) => o.timestamp.isAfter(startOfWeek) && o.timestamp.isBefore(endOfWeek)).toList();
    } else if (_selectedPeriod == 'month') {
      filteredOrders = activeOrders.where((o) => o.timestamp.isAfter(startOfMonth)).toList();
    } else if (_selectedPeriod == 'year') {
      filteredOrders = activeOrders.where((o) => o.timestamp.isAfter(startOfYear)).toList();
    }

    // Phân chia theo Doanh thu thực tế (Chỉ Đã giao) và Doanh thu tạm tính (Chờ xác nhận, Chuẩn bị, Đang giao, v.v.)
    final double actualPreTax = filteredOrders
        .where((o) => o.status == 'Đã giao')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
    final double actualTax = actualPreTax * (_taxRate / 100);
    final double actualPostTax = actualPreTax - actualTax;

    final double tempPreTax = filteredOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final double tempTax = tempPreTax * (_taxRate / 100);
    final double tempPostTax = tempPreTax - tempTax;

    // Chuẩn bị dữ liệu biểu đồ
    List<double> chartValues = [];
    List<String> chartLabels = [];

    if (_selectedPeriod == 'day') {
      // 4 mốc giờ: 0h-6h, 6h-12h, 12h-18h, 18h-24h
      chartLabels = ["0h-6h", "6h-12h", "12h-18h", "18h-24h"];
      chartValues = List.filled(4, 0.0);
      for (var o in filteredOrders) {
        int hour = o.timestamp.hour;
        if (hour < 6) {
          chartValues[0] += o.totalAmount;
        } else if (hour < 12) {
          chartValues[1] += o.totalAmount;
        } else if (hour < 18) {
          chartValues[2] += o.totalAmount;
        } else {
          chartValues[3] += o.totalAmount;
        }
      }
    } else if (_selectedPeriod == 'week') {
      // 7 ngày trong tuần: Thứ 2 -> Chủ nhật
      chartLabels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
      chartValues = List.filled(7, 0.0);
      for (var o in filteredOrders) {
        // o.timestamp.weekday trả về 1 (Thứ 2) -> 7 (Chủ nhật)
        int index = o.timestamp.weekday - 1;
        if (index >= 0 && index < 7) {
          chartValues[index] += o.totalAmount;
        }
      }
    } else if (_selectedPeriod == 'month') {
      // 4 tuần trong tháng
      chartLabels = ["Tuần 1", "Tuần 2", "Tuần 3", "Tuần 4+"];
      chartValues = List.filled(4, 0.0);
      for (var o in filteredOrders) {
        int day = o.timestamp.day;
        if (day <= 7) {
          chartValues[0] += o.totalAmount;
        } else if (day <= 14) {
          chartValues[1] += o.totalAmount;
        } else if (day <= 21) {
          chartValues[2] += o.totalAmount;
        } else {
          chartValues[3] += o.totalAmount;
        }
      }
    } else if (_selectedPeriod == 'year') {
      // 12 tháng
      chartLabels = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"];
      chartValues = List.filled(12, 0.0);
      for (var o in filteredOrders) {
        int index = o.timestamp.month - 1;
        if (index >= 0 && index < 12) {
          chartValues[index] += o.totalAmount;
        }
      }
    }

    // Tìm giá trị max của cột để căn chỉnh tỷ lệ chiều cao biểu đồ
    double maxChartValue = chartValues.fold(0.0, (max, val) => val > max ? val : max);
    if (maxChartValue == 0.0) maxChartValue = 1.0; // Tránh chia cho 0

    // Thống kê sản phẩm bán chạy nhất (Most Sold Items)
    Map<String, int> soldQuantities = {};
    Map<String, double> soldRevenues = {};
    Map<String, CartItem> soldItemDetails = {};

    for (var o in activeOrders) {
      for (var item in o.items) {
        soldQuantities[item.id] = (soldQuantities[item.id] ?? 0) + item.quantity;
        soldRevenues[item.id] = (soldRevenues[item.id] ?? 0.0) + (item.price * item.quantity);
        soldItemDetails[item.id] = item;
      }
    }

    final topSoldIds = soldQuantities.keys.toList()
      ..sort((a, b) => soldQuantities[b]!.compareTo(soldQuantities[a]!));

    // Thống kê sản phẩm đánh giá cao nhất (Top Rated Items) của Seller
    final sellerProducts = productProvider.getProductsBySeller(sellerId);
    final topRatedProducts = List<Product>.from(sellerProducts)
      ..sort((a, b) {
        int rateCompare = b.rating.compareTo(a.rating);
        if (rateCompare != 0) return rateCompare;
        return b.reviewCount.compareTo(a.reviewCount);
      });

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        elevation: 0,
        title: const Text(
          "Báo Cáo Doanh Thu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.refreshOrders();
          await productProvider.refreshProducts();
        },
        color: etsyOrange,
        backgroundColor: etsyCardColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Selector khoảng thời gian
              _buildPeriodSelector(),
              const SizedBox(height: 20),

              // 2. Card Tổng Doanh Thu trước và sau thuế
              _buildRevenueSummaryCard(actualPreTax, actualTax, actualPostTax, tempPreTax, tempTax, tempPostTax),
              const SizedBox(height: 20),

              // 3. Biểu đồ doanh thu tùy chỉnh
              _buildChartSection(chartLabels, chartValues, maxChartValue),
              const SizedBox(height: 25),

              // 4. Danh sách sản phẩm bán chạy nhất
              _buildTopSoldSection(topSoldIds, soldQuantities, soldRevenues, soldItemDetails),
              const SizedBox(height: 25),

              // 5. Danh sách sản phẩm đánh giá tốt nhất
              _buildTopRatedSection(topRatedProducts),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget chọn mốc thời gian: Ngày, Tuần, Tháng, Năm
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: etsyCardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          _buildPeriodButton('day', 'Hôm nay'),
          _buildPeriodButton('week', 'Tuần này'),
          _buildPeriodButton('month', 'Tháng này'),
          _buildPeriodButton('year', 'Năm nay'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String title) {
    final bool isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            _hoveredBarIndex = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? etsyOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Card hiển thị tổng quan doanh thu (Thực tế vs Tạm tính) & Thuế
  Widget _buildRevenueSummaryCard(
    double actualPre, double actualTax, double actualPost,
    double tempPre, double tempTax, double tempPost,
  ) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: etsyCardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TỔNG QUAN DOANH THU",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
              ),
              // Nút chỉnh Thuế suất
              _buildTaxSelectorDropdown(),
            ],
          ),
          const SizedBox(height: 15),

          // Hiển thị Doanh thu Thực tế
          _buildRevenueRow(
            title: "Thực tế (Đã giao)",
            preTax: actualPre,
            tax: actualTax,
            postTax: actualPost,
            accentColor: etsyGreen,
            isCompletedOnly: true,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.grey, height: 1, thickness: 0.5),
          ),

          // Hiển thị Doanh thu Tạm tính
          _buildRevenueRow(
            title: "Tạm tính (Tất cả đơn)",
            preTax: tempPre,
            tax: tempTax,
            postTax: tempPost,
            accentColor: Colors.blueAccent,
            isCompletedOnly: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow({
    required String title,
    required double preTax,
    required double tax,
    required double postTax,
    required Color accentColor,
    required bool isCompletedOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Doanh thu trước thuế:", style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(formatCurrency.format(preTax), style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Thuế suất áp dụng ($_taxRate%):", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text("-${formatCurrency.format(tax)}", style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Doanh thu sau thuế:", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(
              formatCurrency.format(postTax),
              style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // Dropdown tùy chọn thuế suất
  Widget _buildTaxSelectorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: _taxRate,
          dropdownColor: etsyCardColor,
          icon: const Icon(Icons.arrow_drop_down, color: etsyOrange, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          onChanged: (double? newValue) {
            if (newValue != null) {
              setState(() {
                _taxRate = newValue;
              });
            }
          },
          items: _taxOptions.map<DropdownMenuItem<double>>((double value) {
            String label = value == 0.0 ? "0% (Miễn thuế)" : "$value% Thuế";
            if (value == 1.5) label = "1.5% (Hộ KD)";
            if (value == 10.0) label = "10% (VAT)";
            return DropdownMenuItem<double>(
              value: value,
              child: Text(label),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Biểu đồ doanh thu tùy chỉnh
  Widget _buildChartSection(List<String> labels, List<double> values, double maxValue) {
    bool hasData = values.any((v) => v > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: etsyCardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BIỂU ĐỒ DOANH THU (TẠM TÍNH)",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
          ),
          const SizedBox(height: 20),
          if (!hasData)
            const SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined, color: Colors.grey, size: 48),
                    SizedBox(height: 10),
                    Text(
                      "Chưa có dữ liệu doanh thu trong khoảng thời gian này.",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Vùng hiển thị thông tin cột được hover/chạm
            Container(
              height: 35,
              alignment: Alignment.center,
              child: _hoveredBarIndex != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: etsyOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: etsyOrange.withOpacity(0.5)),
                      ),
                      child: Text(
                        "${labels[_hoveredBarIndex!]}: ${formatCurrency.format(values[_hoveredBarIndex!])}",
                        style: const TextStyle(color: etsyOrange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  : const Text("Chạm vào cột để xem chi tiết số tiền", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ),
            const SizedBox(height: 15),

            // Biểu đồ chính
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(labels.length, (index) {
                  final double value = values[index];
                  // Chiều cao cột: tỷ lệ so với max (tối đa 150px, tối thiểu 4px nếu có tiền)
                  double pct = value / maxValue;
                  double barHeight = pct * 150;
                  if (value > 0 && barHeight < 8) barHeight = 8; // Đảm bảo vẫn nhìn thấy cột

                  final bool isHovered = _hoveredBarIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _hoveredBarIndex = index;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cột biểu đồ
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            width: labels.length > 7 ? 14 : 24,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isHovered
                                    ? [etsyOrange, Colors.orangeAccent]
                                    : [etsyOrange.withOpacity(0.85), etsyOrange.withOpacity(0.4)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: isHovered
                                  ? [BoxShadow(color: etsyOrange.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Nhãn của cột
                          Text(
                            labels[index],
                            style: TextStyle(
                              color: isHovered ? Colors.white : Colors.grey.shade400,
                              fontSize: labels.length > 7 ? 9 : 11,
                              fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Danh sách sản phẩm bán nhiều nhất
  Widget _buildTopSoldSection(
    List<String> topSoldIds,
    Map<String, int> soldQuantities,
    Map<String, double> soldRevenues,
    Map<String, CartItem> soldItemDetails,
  ) {
    final displayIds = topSoldIds.take(5).toList(); // Hiển thị top 5

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            "🔥 Sản phẩm bán chạy nhất (Top 5)",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (displayIds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: const Center(
              child: Text("Chưa có sản phẩm nào được bán.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayIds.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 1),
              itemBuilder: (ctx, index) {
                final id = displayIds[index];
                final item = soldItemDetails[id]!;
                final qty = soldQuantities[id] ?? 0;
                final rev = soldRevenues[id] ?? 0.0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getRankColor(index + 1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Đã bán: $qty sản phẩm",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Doanh thu",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency.format(rev),
                        style: const TextStyle(color: etsyGreen, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Danh sách sản phẩm đánh giá cao nhất
  Widget _buildTopRatedSection(List<Product> products) {
    // Chỉ lấy top 5 sản phẩm có rating và có review
    final ratedList = products.where((p) => p.rating > 0).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            "⭐ Đánh giá cao nhất (Top 5)",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (ratedList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: const Center(
              child: Text("Sản phẩm của bạn chưa có đánh giá nào.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: etsyCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratedList.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 1),
              itemBuilder: (ctx, index) {
                final product = ratedList[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getRankColor(index + 1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    product.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Đơn giá: ${formatCurrency.format(product.price)}",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 15),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${product.reviewCount} đánh giá",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Helper lấy màu sắc theo thứ hạng
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700; // Vàng kim
      case 2:
        return Colors.grey.shade500; // Bạc
      case 3:
        return Colors.brown.shade400; // Đồng
      default:
        return Colors.blueGrey;
    }
  }
}
