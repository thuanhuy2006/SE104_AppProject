class Product {
  final String id;
  final String title;
  final int price;
  final int? oldPrice;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
  });
}

class CartItem {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class ProductData {
  static final List<Product> products = [
    Product(
      id: 'p1',
      title: 'Crochet Heart Blanket Pattern...',
      price: 132595,
      oldPrice: 251634,
      imageUrl: 'https://i.etsystatic.com/13155708/r/il/6b042b/2311441544/il_570xN.2311441544_9j4z.jpg',
    ),
    Product(
      id: 'p2',
      title: 'CROCHET PATTERN & VI...',
      price: 132595,
      imageUrl: 'https://i.etsystatic.com/5934502/r/il/a76295/2916568102/il_570xN.2916568102_e43t.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Easy crochet modern blank...',
      price: 200000,
      imageUrl: 'https://i.etsystatic.com/20268576/r/il/3df7f2/3138813350/il_570xN.3138813350_483n.jpg',
    ),
    Product(
      id: 'p4',
      title: 'Cozy Days Daisy Blanket C...',
      price: 450000,
      imageUrl: 'https://i.etsystatic.com/18659114/r/il/69595d/2996160533/il_570xN.2996160533_t6yv.jpg',
    ),
  ];
}