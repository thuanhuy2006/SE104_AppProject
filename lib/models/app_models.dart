class Product {
  final String id;
  final String title;
  final int price;
  final int? oldPrice;
  final String imageUrl;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.category,
    required this.description,
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
    // Trang sức
    Product(
      id: 'p1', title: 'Nhẫn kim tiền', price: 800000, category: 'Trang sức',
      imageUrl: 'https://img.vuahanghieu.com/unsafe/0x0/left/top/smart/filters:quality(90)/https://admin.vuahanghieu.com/upload/news/content/2024/01/nhan-kim-tien-la-gi-deo-nhan-kim-tien-ngon-nao-de-thu-hut-tai-loc-1-jpg-1706589596-30012024113956.jpg',
      description: 'Nhẫn kim tiền vàng 18K mang ý nghĩa thu hút tài lộc, may mắn cho người đeo. Thiết kế tinh xảo, viền nhẫn lấp lánh sang trọng, rất phù hợp để làm quà tặng cho người thân hoặc tự thưởng cho bản thân nhân dịp năm mới.',
    ),
    Product(
      id: 'p2', title: 'Dây chuyền vàng cưới', price: 32800000, category: 'Trang sức',
      imageUrl: 'https://apj.vn/wp-json/wc-sku-watermark/v1/image/5309099713/shop_single/RENIOTM5',
      description: 'Dây chuyền vàng 24K cao cấp chuẩn tuổi, được chế tác tỉ mỉ với các họa tiết hoa văn truyền thống. Tôn lên vẻ đẹp rạng rỡ, sang trọng và quý phái của cô dâu trong ngày trọng đại nhất cuộc đời.',
    ),

    // Quần áo
    Product(
      id: 'p3', title: 'Áo polo nam cộc tay', price: 1500000, category: 'Quần áo',
      imageUrl: 'https://nhatminhsports.vn/wp-content/uploads/2025/07/1-2.png',
      description: 'Áo polo nam form chuẩn ôm dáng, chất liệu 100% cotton cao cấp cực kỳ thoáng mát và thấm hút mồ hôi. Thiết kế cổ bẻ thanh lịch, phù hợp cho cả môi trường công sở lẫn những buổi đi chơi dạo phố cùng bạn bè.',
    ),
    Product(
      id: 'p4', title: 'Áo thun nam Navy cỡ lớn', price: 289000, oldPrice: 489000, category: 'Quần áo',
      imageUrl: 'https://thoitrangbigsize.vn/wp-content/uploads/2021/10/BSX653D0.jpg',
      description: 'Áo thun Big Size dành riêng cho nam giới có thân hình đậm. Chất vải thun lạnh co giãn 4 chiều mang lại cảm giác thoải mái tối đa khi vận động. Màu Navy nam tính, dễ phối đồ và che khuyết điểm cực tốt.',
    ),
    Product(
      id: 'p5', title: 'Quần Jeans Baggy ống suông', price: 195000, category: 'Quần áo',
      imageUrl: 'https://dosi-in.com/file/detailed/508/dosiin-black-monkey-quan-jeans-localbrand-baggy-ong-suong-black-monkey-508029508029.jpg?w=670&h=670&fit=fill&fm=webp',
      description: 'Quần jeans form Baggy ống suông rộng rãi, mang đậm phong cách streetwear Hàn Quốc. Chất denim dày dặn nhưng không gây bí bách. Dễ dàng mix&match với áo thun oversize hoặc hoodie.',
    ),
    Product(
      id: 'p6', title: 'Quần âu nam cạp quay trơn', price: 150000, category: 'Quần áo',
      imageUrl: 'https://product.hstatic.net/200000471735/product/mtr006k4-7-c05__1__b146c85944b545189a503468eb8ddde3_1024x1024.jpg',
      description: 'Quần tây nam chất vải tuyết mưa chống nhăn, giữ ly tốt sau nhiều lần giặt. Form dáng Slimfit tôn chiều cao, đem lại vẻ ngoài lịch lãm, chuyên nghiệp cho dân văn phòng.',
    ),

    // Phụ kiện
    Product(
      id: 'p7', title: 'Đồng hồ Casio G-SHOCK', price: 14200000, oldPrice: 12200000, category: 'Phụ kiện',
      imageUrl: 'https://cdn.casio-vietnam.vn/wp-content/uploads/2019/08/GST-B100D-1A.png',
      description: 'Mẫu đồng hồ G-SHOCK thép không gỉ huyền thoại. Tích hợp công nghệ Tough Solar sạc bằng ánh sáng, kết nối Bluetooth với smartphone. Khả năng chống nước độ sâu 200m và chống va đập tuyệt đối.',
    ),
    Product(
      id: 'p8', title: 'Nón Snapback đen', price: 2500000, category: 'Phụ kiện',
      imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/MC229K-DN3/thumbs/800_nonson_1.png',
      description: 'Nón Snapback đen cool ngầu, thêu logo 3D nổi bật. Form nón cứng cáp, lót trong êm ái thấm hút mồ hôi. Phụ kiện không thể thiếu cho những bộ outfit mang phong cách đường phố.',
    ),
    Product(
      id: 'p9', title: 'Nón vành đỏ', price: 1250000, category: 'Phụ kiện',
      imageUrl: 'https://nonson.vn/vnt_upload/product/03_2026/XH001-104-DO2/thumbs/800_nonson__2.png',
      description: 'Nón rộng vành sắc đỏ rực rỡ, làm từ chất liệu cói mềm cao cấp. Che nắng hoàn hảo cho khuôn mặt và cổ, là trợ thủ đắc lực giúp bạn có những bức ảnh sống ảo tuyệt đẹp trong các chuyến du lịch biển.',
    ),
    Product(
      id: 'p10', title: 'Dây nịt nam da bò', price: 150000, category: 'Phụ kiện',
      imageUrl: 'https://wtco.com.vn/wp-content/uploads/2024/07/that-lung-nam-infinity-6.jpg',
      description: 'Thắt lưng nam làm từ da bò thật nguyên tấm bền bỉ, càng dùng lâu da càng mềm và bóng. Mặt khóa kim loại nguyên khối chống gỉ sét, thiết kế tối giản dễ phối với quần âu lẫn quần jeans.',
    ),
    Product(
      id: 'p11', title: 'Dây nịt nữ bản nhỏ 25mm', price: 175000, category: 'Phụ kiện',
      imageUrl: 'https://image.celine.com/20228e92009b1822/original/45AGM3A01-38SI_1_SS24_P1_M.jpg?im=Resize=(1200)',
      description: 'Thắt lưng nữ bản nhỏ tinh tế, mang lại nét nhấn nhá nhẹ nhàng cho vòng eo. Rất phù hợp để thắt ngoài váy liền, áo blazer dài hoặc phối với quần tây lưng cao.',
    ),

    // Giày dép
    Product(
      id: 'p12', title: 'Giày nam da thật cao cấp', price: 2250000, category: 'Giày dép',
      imageUrl: 'https://bizweb.dktcdn.net/thumb/1024x1024/100/527/490/products/giay-nam-cao-cap-da-that-lecos-lg12-2-1731769946743.jpg?v=1731771526053',
      description: 'Giày da nam Derby cao cấp, bề mặt da bóng bẩy sang trọng. Lót giày tích hợp đệm khí êm ái, đế cao su đúc nguyên khối chống trơn trượt. Sự lựa chọn hoàn hảo cho những cuộc họp quan trọng.',
    ),
    Product(
      id: 'p13', title: 'Giày thể thao nam', price: 1500000, category: 'Giày dép',
      imageUrl: 'https://product.hstatic.net/200000068876/product/907_4fbf07e8437d4b138238e97217f194c3_master.png',
      description: 'Mẫu giày sneaker thể thao với thân giày đan lưới thoáng khí, giúp chân không bị hầm bí. Công nghệ đế Eva đàn hồi cực tốt, nâng đỡ bàn chân hiệu quả trong các hoạt động chạy bộ, tập gym.',
    ),
    Product(
      id: 'p14', title: 'Giày nữ cao gót đế vuông', price: 2450000, category: 'Giày dép',
      imageUrl: 'https://satajor.com/wp-content/uploads/2019/09/SJ0095-web-tr%E1%BA%AFng-2.jpg',
      description: 'Giày cao gót 5cm với thiết kế đế vuông trụ vững chắc, giúp chị em tự tin sải bước cả ngày dài mà không lo đau mỏi. Kiểu dáng mũi nhọn thanh lịch, màu trắng dễ dàng mix cùng mọi loại trang phục.',
    ),
  ];
}