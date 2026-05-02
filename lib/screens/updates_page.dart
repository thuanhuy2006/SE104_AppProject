import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/shared_widgets.dart';

class EtsyUpdatesPage extends StatelessWidget {
  const EtsyUpdatesPage({super.key});

  Widget _buildBoxWithSparklesIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.white),
          Positioned(
            top: 5,
            left: 5,
            child: Icon(Icons.auto_awesome, size: 24, color: Colors.white),
          ),
          Positioned(
            top: 35,
            right: 0,
            child: Icon(Icons.auto_awesome, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBookIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 80, color: Colors.white),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: etsyBackground, // Dùng màu nền để che nét đứt của cuốn sách
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: etsyBackground,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.deepOrange,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: "Updates"),
              Tab(text: "Items"),
              Tab(text: "Shops"),
              Tab(text: "Searches"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const EtsyEmptyState(
              iconData: Icons.notifications_active_outlined,
              title: "Nothing to see here...yet",
              subtitle: "Check back for updates on your favorite items\nand shops—like sales, special offers, and new\nproducts.",
              buttonText: "Start exploring",
            ),
            EtsyEmptyState(
              customIcon: _buildBoxWithSparklesIcon(),
              title: "No favorites or collections",
              subtitle: "Your recommendations get better as you favorite more things.",
            ),
            EtsyEmptyState(
              customIcon: _buildBoxWithSparklesIcon(),
              title: "No saved shops",
              subtitle: "Your recommendations get better as you favorite more things.",
            ),
            EtsyEmptyState(
              customIcon: _buildSearchBookIcon(),
              title: "No saved searches",
            ),
          ],
        ),
      ),
    );
  }
}