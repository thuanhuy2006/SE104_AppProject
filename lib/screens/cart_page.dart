import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'checkout_page.dart';

class EtsyCartPage extends StatelessWidget {
  const EtsyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: etsyBackground,
      appBar: AppBar(
        backgroundColor: etsyBackground,
        foregroundColor: etsyText,
        elevation: 0,
        title: Text(
          "Giỏ hàng (${cart.itemCount})",
          style: const TextStyle(fontWeight: FontWeight.bold, color: etsyText),
        ),
      ),
      body: cart.items.isEmpty
          ? const SafeArea(
              child: EtsyEmptyState(
                iconData: Icons.shopping_cart_outlined,
                title: "Giỏ hàng của bạn đang trống",
                subtitle: "Bạn đang tìm kiếm ý tưởng mua sắm?",
                buttonText: "Xem các sản phẩm thịnh hành",
                iconSize: 100,
              ),
            )
          : Column(
              children: [
                // Dòng "Chọn tất cả"
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10, bottom: 5),
                  child: Row(
                    children: [
                      Checkbox(
                        value: cart.isAllSelected,
                        onChanged: (value) => cart.toggleAll(value ?? false),
                        activeColor: Colors.deepOrange,
                      ),
                      const Text(
                        "Chọn tất cả",
                        style: TextStyle(
                          color: etsyText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Card(
                        color: etsyCardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey.shade800,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: cartItem.isSelected,
                                onChanged: (value) =>
                                    cart.toggleSelection(cartItem.id),
                                activeColor: Colors.deepOrange,
                                side: const BorderSide(color: Colors.grey),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade800,
                                    child: const Icon(
                                      Icons.image,
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
                                      cartItem.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: etsyText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatCurrency.format(cartItem.price),
                                      style: const TextStyle(
                                        color: etsyText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Nút giảm số lượng
                                        InkWell(
                                          onTap: () {
                                            cart.removeSingleItem(cartItem.id);
                                            userProvider.syncCartToFirebase(
                                              cart.items.values.toList(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            '${cartItem.quantity}',
                                            style: const TextStyle(
                                              color: etsyText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Nút tăng số lượng
                                        InkWell(
                                          onTap: () {
                                            cart.addItem(
                                              cartItem.id,
                                              cartItem.title,
                                              cartItem.price,
                                              cartItem.imageUrl,
                                            );
                                            userProvider.syncCartToFirebase(
                                              cart.items.values.toList(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Nút xóa
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () {
                                            cart.removeItem(cartItem.id);
                                            userProvider.syncCartToFirebase(
                                              cart.items.values.toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Khung Tổng tiền & Thanh toán
                Container(
                  padding: const EdgeInsets.all(20).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  decoration: BoxDecoration(
                    color: etsyCardColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng thanh toán:",
                            style: TextStyle(color: etsyText, fontSize: 16),
                          ),
                          Text(
                            formatCurrency.format(cart.selectedTotalAmount),
                            style: const TextStyle(
                              color: etsyText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cart.selectedTotalAmount > 0
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CheckoutPage(),
                                    ),
                                  );
                                }
                              : null, // Vô hiệu hóa nút nếu chưa chọn món nào
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cart.selectedTotalAmount > 0
                                ? Colors.white
                                : Colors.grey.shade600,
                            foregroundColor: cart.selectedTotalAmount > 0
                                ? Colors.black
                                : Colors.grey.shade400,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Tiến hành thanh toán",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
