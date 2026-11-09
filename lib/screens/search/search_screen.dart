import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _popularKeywords = [
    'Smart Watch', 'TWS Earbuds', 'LED Strip', 'Mechanical Keyboard',
    'Men Jacket', 'Desk Mat', 'Phone Case', 'Action Camera'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search best deals, electronics...',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularKeywords.map((tag) {
                return ActionChip(
                  label: Text(tag),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  labelStyle: const TextStyle(color: AppColors.textDark, fontSize: 13),
                  onPressed: () {
                    _controller.text = tag;
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
