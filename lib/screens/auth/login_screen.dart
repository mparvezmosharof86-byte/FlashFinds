import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isPhoneLogin = true; // কান্ট্রি কোড সহ ফোন লগইন নাকি ইমেইল
  bool _isLogin = true;
  bool _isLoading = false;

  // আন্তর্জাতিক দেশের তালিকা (International Country Dial Codes)
  final List<Map<String, String>> _countries = [
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
    _selectedCountry = _countries[0]; // ডিফল্ট কান্ট্রি
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Your Country', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final item = _countries[index];
                    return ListTile(
                      leading: Text(item['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(item['name']!),
                      trailing: Text(item['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      onTap: () {
                        setState(() => _selectedCountry = item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isPhoneLogin) {
        // ফোন নম্বর সাইন-ইন লজিক
        final fullPhone = '${_selectedCountry['code']}${_phoneController.text.trim()}';
        if (_phoneController.text.trim().isEmpty) {
          throw 'Please enter a valid phone number';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $fullPhone'), backgroundColor: Colors.green),
        );
      } else {
        // ইমেইল ও পাসওয়ার্ড
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        if (_isLogin) {
          await _authService.signInWithEmail(email, password);
        } else {
          await _authService.signUpWithEmail(email, password);
        }
        if (mounted) Navigator.pop(context);
      }
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const SizedBox(height: 20),
            Text(
              _isLogin ? 'Global Login' : 'Create Account',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select your country and log in to explore exclusive international deals.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Login Method Toggle (Phone / Email)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isPhoneLogin = true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isPhoneLogin ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                      side: BorderSide(color: _isPhoneLogin ? AppColors.primary : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Phone Number', style: TextStyle(color: _isPhoneLogin ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isPhoneLogin = false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isPhoneLogin ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                      side: BorderSide(color: !_isPhoneLogin ? AppColors.primary : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Email ID', style: TextStyle(color: !_isPhoneLogin ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isPhoneLogin) ...[
              // International Country Selector + Phone Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showCountryPicker,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        color: Colors.grey[100],
                        child: Row(
                          children: [
                            Text(_selectedCountry['flag']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(_selectedCountry['code']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 20),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isPhoneLogin ? 'Send Code (OTP)' : (_isLogin ? 'Sign In' : 'Sign Up'),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
