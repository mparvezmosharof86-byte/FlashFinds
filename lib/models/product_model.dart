class ProductModel {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> additionalImages;
  final double currentPrice;
  final double originalPrice;
  final int discountPercentage;
  final double rating;
  final int totalSales;
  final String category;
  final String description;
  final String affiliateUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.additionalImages = const [],
    required this.currentPrice,
    required this.originalPrice,
    required this.discountPercentage,
    required this.rating,
    required this.totalSales,
    required this.category,
    required this.description,
    required this.affiliateUrl,
  });

  // AliExpress API থেকে রেসপন্স আসলে যাতে নিমিষেই মডেল কনভার্ট হতে পারে
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['product_id']?.toString() ?? '',
      title: json['product_title'] ?? '',
      imageUrl: json['product_main_image_url'] ?? '',
      currentPrice: (json['target_sale_price'] ?? 0.0).toDouble(),
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount'] ?? 0).toInt(),
      rating: (json['evaluate_rate'] ?? 4.8).toDouble(),
      totalSales: (json['volume'] ?? 0).toInt(),
      category: json['category_name'] ?? 'Deals',
      description: json['description'] ?? '',
      affiliateUrl: json['promotion_link'] ?? '',
    );
  }
}
