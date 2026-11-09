import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome to FlashFinds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Sign in to save deals and sync cart', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Settings Options
            _buildOption(Icons.favorite_outline, 'Saved Wishlist Deals', () {}),
            _buildOption(Icons.notifications_none, 'Notification Settings', () {}),
            _buildOption(Icons.language, 'Currency: USD (\$)', () {}),
            _buildOption(Icons.verified_user_outlined, 'Privacy Policy & Terms', () {}),
            _buildOption(Icons.info_outline, 'About FlashFinds App', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
