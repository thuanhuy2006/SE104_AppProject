import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class EtsyShopPage extends StatelessWidget {
  const EtsyShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const EtsyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(color: const Color(0xFFF3EAC8), borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Beautifully crafted\ndining finds, just for\nMom", style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Georgia')),
                                  Text("Find her faves", style: TextStyle(color: Colors.black87, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Image.network('https://i.etsystatic.com/15286468/r/il/15c102/2358897258/il_570xN.2358897258_50y4.jpg', fit: BoxFit.cover),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Shop by category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildCategoryCard('Jewelry', '💍'),
                        _buildCategoryCard('Clothing', '🧥'),
                        _buildCategoryCard('Home & Living', '🛋️'),
                        _buildCategoryCard('Deals on Etsy', '🏷️'),
                        _buildCategoryCard('Gift Ideas', '🎁'),
                        _buildCategoryCard('Art & Collectibles', '🖼️'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Home Decor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("Explore more", style: TextStyle(fontSize: 14, color: Color(0xFFA19CFF), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: [
                        _buildHorizontalItem('https://i.etsystatic.com/12979269/r/il/f53db0/1049969032/il_570xN.1049969032_8y2g.jpg', 'Home Accents'),
                        const SizedBox(width: 15),
                        _buildHorizontalItem('https://i.etsystatic.com/7123617/r/il/b3d4f1/3091107297/il_570xN.3091107297_d6k3.jpg', 'Pillows & Throw Blankets'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String emoji) {
    return Container(
      width: 170,
      height: 60,
      decoration: BoxDecoration(color: etsyCardColor, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildHorizontalItem(String img, String title) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[800]),
              clipBehavior: Clip.hardEdge,
              child: Image.network(img, fit: BoxFit.cover, width: 160),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}