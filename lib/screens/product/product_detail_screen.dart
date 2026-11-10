import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isAddingToCart = false;

  String get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? 'guest_device';
  }

  // সরাসরি আলিএক্সপ্রেস অ্যাপ বা ব্রাউজার ওপেন করার ফাংশন (Deep Link)
  void _openAliExpress() async {
    // এপিআই থেকে আসল লিংক আসলে সেটি ওপেন হবে, ডেমো হিসেবে আলিএক্সপ্রেসের ডিলস পেজ দেওয়া হলো
    final String targetUrl = widget.product.affiliateUrl.isNotEmpty
        ? widget.product.affiliateUrl
        : 'https://www.aliexpress.com';

    final Uri uri = Uri.parse(targetUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open AliExpress: $e')),
        );
      }
    }
  }

  void _handleAddToCart() async {
    setState(() => _isAddingToCart = true);
    await _firestoreService.addToCart(_currentUserId, widget.product);
    setState(() => _isAddingToCart = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Item added to your Cart!'),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Deal Details', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          // Wishlist / Love Toggle Button
          StreamBuilder<bool>(
            stream: _firestoreService.isWishlistedStream(_currentUserId, product.id),
            builder: (context, snapshot) {
              final bool isFavorite = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textDark,
                ),
                onPressed: () async {
                  final added = await _firestoreService.toggleWishlist(_currentUserId, product);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(added ? 'Saved to Wishlist!' : 'Removed from Wishlist'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image
            Container(
              height: 380,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(color: Colors.grey[100]),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            ),

            // Price & Title Information
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
                      Text('${product.totalSales}+ Verified Orders', style: const TextStyle(color: AppColors.textMuted)),
                      const Spacer(),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Text('Verified Deal', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Description Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Overview & Guarantee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'Guaranteed authentic deal sourced directly from verified top AliExpress merchants with international buyer protection.'
                        : product.description,
                    style: const TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
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
              // Add to Cart Button
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isAddingToCart ? null : _handleAddToCart,
                    icon: _isAddingToCart
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                    label: const Text('Add to Cart', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Direct AliExpress App Launcher Button (Deep Link)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _openAliExpress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buy on AliExpress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
