import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? user = authService.currentUser;
    final bool isLoggedIn = user != null;

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
            // Prominent Login / Profile Card
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(isLoggedIn ? Icons.account_circle : Icons.person_outline, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? (user.email ?? 'Member') : 'Welcome to FlashFinds',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoggedIn ? 'Account active' : 'Sign in to access your saved cart',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isLoggedIn) {
                        authService.signOut();
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoggedIn ? Colors.grey[200] : AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isLoggedIn ? 'Logout' : 'Sign In',
                      style: TextStyle(
                        color: isLoggedIn ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
