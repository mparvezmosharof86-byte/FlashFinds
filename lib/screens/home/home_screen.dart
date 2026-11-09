import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../search/search_screen.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.fireGradient)),
          title: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text('Search viral gadgets, discounts...', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Flash Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.fireGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.yellow, size: 32),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SUPER FLASH FINDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Up to 80% OFF Verified Top Deals', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2-Column Infinite Masonry Product Grid (100% Native)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemBuilder: (context, index) {
                // এটি অটোমেটিক ডাইনামিক মডেল (এপিআই আসার আগ পর্যন্ত ডেমো স্ট্রাকচার অনুযায়ী ভিউ হচ্ছে)
                final mockProduct = ProductModel(
                  id: '$index',
                  title: 'Ultra Fast Wireless Charging Smart Gadget 2026 Edition',
                  imageUrl: 'https://picsum.photos/400/400?random=$index',
                  currentPrice: 4.99 + (index * 1.5),
                  originalPrice: 15.99 + (index * 2),
                  discountPercentage: 65,
                  rating: 4.8,
                  totalSales: 2400,
                  category: 'Electronics',
                  description: 'Top grade certified materials with high performance battery.',
                  affiliateUrl: '',
                );

                return _buildProductCard(context, mockProduct);
              },
              childCount: 10, // এপিআই অ্যাড হলে আনলিমিটেড হবে
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 170, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(height: 170, color: Colors.grey[200], child: const Icon(Icons.image)),
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
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('\$${product.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.discountBadge.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('-${product.discountPercentage}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.discountBadge)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingStar),
                      Text(' ${product.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${product.totalSales}+ sold', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
