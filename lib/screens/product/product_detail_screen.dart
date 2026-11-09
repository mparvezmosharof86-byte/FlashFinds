import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Details', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textDark),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Native Full-Width Image
            Container(
              height: 380,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            ),
            
            // Price & Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${product.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.discountBadge.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage}% OFF',
                          style: const TextStyle(color: AppColors.discountBadge, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.ratingStar, size: 20),
                      const SizedBox(width: 4),
                      Text('${product.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text('${product.totalSales}+ Sold', style: const TextStyle(color: AppColors.textMuted)),
                      const Spacer(),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Text('Top Rated', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Description Box
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Specifications & Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty 
                      ? 'Guaranteed authentic deal verified with top buyer reviews and fast logistics.' 
                      : product.description,
                    style: const TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90), // Bottom button gap
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // এটি পরবর্তীতে অ্যাফিলিয়েট লিংকে সরাসরি আলিএক্সপ্রেস অ্যাপ ওপেন করবে
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Buy on AliExpress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
