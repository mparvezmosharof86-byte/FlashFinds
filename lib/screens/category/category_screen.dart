import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'category_products_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Consumer Electronics',
      'icon': Icons.headphones,
      'subs': ['Smart Watches', 'TWS Earbuds', 'Power Banks', 'Audio & Video', 'Cameras', 'Cables & Adapters']
    },
    {
      'title': "Men's Clothing",
      'icon': Icons.man,
      'subs': ['Hoodies', 'T-Shirts', 'Jackets', 'Pants', 'Shoes', 'Underwear']
    },
    {
      'title': "Women's Clothing",
      'icon': Icons.woman,
      'subs': ['Dresses', 'Tops & Tees', 'Sweaters', 'Bags & Luggage', 'Jewelry', 'Hair Accessories']
    },
    {
      'title': 'Phones & Accessories',
      'icon': Icons.phone_android,
      'subs': ['Cases & Covers', 'Screen Protectors', 'Holders & Mounts', 'Chargers', 'Repair Parts']
    },
    {
      'title': 'Home & Garden',
      'icon': Icons.chair,
      'subs': ['Kitchen Gadgets', 'Home Decor', 'LED Lighting', 'Storage & Organization', 'Garden Supplies']
    },
    {
      'title': 'Automobile & Bike',
      'icon': Icons.directions_car,
      'subs': ['Dashcams', 'Car Lights', 'Seat Covers', 'Cleaning Tools', 'Motorcycle Gear']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Categories', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Left Rail
          Container(
            width: 105,
            color: const Color(0xFFF6F7F9),
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    color: isSelected ? Colors.white : Colors.transparent,
                    child: Column(
                      children: [
                        Icon(
                          _categories[index]['icon'] as IconData,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _categories[index]['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Right Sub-Category Grid
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categories[_selectedCategoryIndex]['title'] as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: (_categories[_selectedCategoryIndex]['subs'] as List).length,
                      itemBuilder: (context, i) {
                        final subName = (_categories[_selectedCategoryIndex]['subs'] as List)[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CategoryProductsScreen(categoryTitle: subName)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  subName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
