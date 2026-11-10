import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryTitle;

  const CategoryProductsScreen({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(categoryTitle, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MasonryGridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 8,
        itemBuilder: (context, index) {
          final product = ProductModel(
            id: 'cat_${categoryTitle}_$index',
            title: '$categoryTitle Premium Verified Deal Edition #$index',
            imageUrl: 'https://picsum.photos/400/400?random=${index + 50}',
            currentPrice: 5.99 + (index * 2.2),
            originalPrice: 19.99 + (index * 3.5),
            discountPercentage: 60,
            rating: 4.9,
            totalSales: 1800 + (index * 200),
            category: categoryTitle,
            description: 'Top grade $categoryTitle certified product with authentic quality and fast shipping.',
            affiliateUrl: '',
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 165,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('\$${product.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.discountBadge.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text('-${product.discountPercentage}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.discountBadge)),
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
    );
  }
}
