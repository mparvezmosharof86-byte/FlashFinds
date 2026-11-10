import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  void _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {}
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
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? (user?.displayName ?? user?.email ?? 'Member') : 'Guest User (গেস্ট মোড)',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoggedIn ? (user?.email ?? 'Verified Account') : 'Log in to sync wishlist & cart across devices',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (!isLoggedIn)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => setState(() {}));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Saved Wishlist Deals Button (কানেক্টেড)
            _buildOption(Icons.favorite_outline, 'Saved Wishlist Deals', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            }),
            _buildOption(Icons.notifications_none, 'Notification Settings', () {}),
            _buildOption(Icons.language, 'Currency: USD (\$)', () {}),
            _buildOption(Icons.verified_user_outlined, 'Privacy Policy & Terms', () {}),
            _buildOption(Icons.info_outline, 'About FlashFinds App', () {}),

            // Sign Out Option
            if (isLoggedIn) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleSignOut,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
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
