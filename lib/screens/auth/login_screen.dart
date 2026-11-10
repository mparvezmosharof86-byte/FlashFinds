import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isPhoneMode = true; // Phone vs Email
  bool _isSignUpMode = false; // Login vs Register (Email এর জন্য)
  bool _isOtpSent = false;
  bool _isLoading = false;

  final List<Map<String, String>> _countries = const [
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Qatar', 'code': '+974', 'flag': '🇶🇦'},
    {'name': 'Kuwait', 'code': '+965', 'flag': '🇰🇼'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
  ];

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0];
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  // ১. গুগল সাইন-ইন এক্সিকিউট করা
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && mounted) {
        _navigateToHome();
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

  // ২. ফোন নম্বর ওটিপি হ্যান্ডলার (Passwordless)
  void _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to ${_selectedCountry['code']}$phone. (Test: 123456)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _verifyPhoneOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit verification code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final fullPhone = '${_selectedCountry['code']}${_phoneController.text.trim()}';
    
    // সেভ ডাটা
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await _authService.savePhoneUser(currentUid, fullPhone);

    if (mounted) {
      setState(() => _isLoading = false);
      _navigateToHome();
    }
  }

  // ৩. ইমেইল সাইন-ইন ও সাইন-আপ হ্যান্ডলার
  void _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUpMode) {
        final fName = _firstNameController.text.trim();
        final lName = _lastNameController.text.trim();
        if (fName.isEmpty || lName.isEmpty) throw 'Please provide First and Last Name';

        await _authService.signUpWithEmail(
          email: email,
          password: password,
          firstName: fName,
          lastName: lName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification link sent to your email. Account created!'), backgroundColor: Colors.green),
          );
        }
      } else {
        await _authService.signInWithEmail(email, password);
      }
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _navigateToHome,
            child: const Text('Skip / Guest', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.fireGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                _isPhoneMode 
                    ? (_isOtpSent ? 'Verify Phone Code' : 'Mobile Number Login') 
                    : (_isSignUpMode ? 'Register Account' : 'Welcome Back'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                _isPhoneMode
                    ? 'Enter phone number. No password needed, login via OTP.'
                    : 'Manage deals, track rewards, and synchronize your cart.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tab Switcher (Mobile vs Email)
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isPhoneMode = true;
                          _isOtpSent = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isPhoneMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isPhoneMode ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                          ),
                          alignment: Alignment.center,
                          child: Text('Mobile OTP', style: TextStyle(fontWeight: FontWeight.bold, color: _isPhoneMode ? AppColors.primary : AppColors.textMuted)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isPhoneMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isPhoneMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isPhoneMode ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                          ),
                          alignment: Alignment.center,
                          child: Text('Email & Password', style: TextStyle(fontWeight: FontWeight.bold, color: !_isPhoneMode ? AppColors.primary : AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- FORM SECTION ---
              if (_isPhoneMode) ...[
                if (!_isOtpSent) ...[
                  // Phone Number Input
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => ListView.builder(
                                itemCount: _countries.length,
                                itemBuilder: (context, i) => ListTile(
                                  leading: Text(_countries[i]['flag']!, style: const TextStyle(fontSize: 22)),
                                  title: Text(_countries[i]['name']!),
                                  trailing: Text(_countries[i]['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  onTap: () {
                                    setState(() => _selectedCountry = _countries[i]);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            color: Colors.grey[100],
                            child: Row(
                              children: [
                                Text(_selectedCountry['flag']!, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 4),
                                Text(_selectedCountry['code']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Enter Mobile Number',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildPrimaryButton('Send Verification Code', _sendPhoneOtp),
                ] else ...[
                  // OTP Box
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: '------',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPrimaryButton('Verify & Enter App', _verifyPhoneOtp),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isOtpSent = false),
                      child: const Text('Change Phone Number', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                ],
              ] else ...[
                // Email Form (Login / Register)
                if (_isSignUpMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Gmail / Email ID',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 18),
                _buildPrimaryButton(_isSignUpMode ? 'Verify & Create Account' : 'Sign In', _handleEmailAuth),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
                    child: Text(
                      _isSignUpMode ? 'Already have an account? Sign In' : "Don't have an account? Register Now",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              // --- OR SIGN IN WITH GOOGLE ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR CONNECT WITH', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),

              // Circular Google Sign-In Button
              Center(
                child: InkWell(
                  onTap: _isLoading ? null : _handleGoogleSignIn,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text('One-Tap Google Login', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}
