import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class EtsyCartPage extends StatelessWidget {
  const EtsyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: EtsyEmptyState(
          iconData: Icons.shopping_cart_outlined,
          title: "Your shopping cart is empty",
          subtitle: "Looking for ideas?",
          buttonText: "See trending items",
          iconSize: 100,
        ),
      ),
    );
  }
}