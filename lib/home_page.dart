import 'package:flutter/material.dart';
import 'app_models.dart';
import 'shared_widgets.dart';

class EtsyHomePage extends StatelessWidget {
  const EtsyHomePage({super.key});

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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 160,
                          decoration: BoxDecoration(color: const Color(0xFFF3EAC8), borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.hardEdge,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Top 100 gifts for\nmom", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                                      const SizedBox(height: 15),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                        decoration: BoxDecoration(color: const Color(0xFF322E3B), borderRadius: BorderRadius.circular(20)),
                                        child: const Text("Shop our picks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Image.network(
                                  'https://i.etsystatic.com/26451670/r/il/64ce5f/3796677708/il_794xN.3796677708_k3eb.jpg',
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 160,
                          decoration: BoxDecoration(color: const Color(0xFF3E4F32), borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(15),
                          child: const Text("Creative gifts\nfor her", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Inspiration at your fingertips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: ProductData.products.length,
                      itemBuilder: (context, index) {
                        return EtsyProductCard(product: ProductData.products[index]);
                      },
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
}