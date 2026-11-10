import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully with Google!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: (isLoggedIn && user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                    child: (!isLoggedIn || user?.photoURL == null)
                        ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                        : null,
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // If Guest: Show Direct Login Options inside Profile
            if (!isLoggedIn)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign In Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),

                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleLogin,
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                          height: 20,
                        ),
                        label: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Continue with Google', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Email / Phone Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => setState(() {}));
                        },
                        icon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
                        label: const Text('Sign in with Email or Phone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            _buildOption(Icons.favorite_outline, 'Saved Wishlist Deals', () {}),
            _buildOption(Icons.notifications_none, 'Notification Settings', () {}),
            _buildOption(Icons.language, 'Currency: USD (\$)', () {}),
            _buildOption(Icons.verified_user_outlined, 'Privacy Policy & Terms', () {}),
            _buildOption(Icons.info_outline, 'About FlashFinds App', () {}),

            if (is
