import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Release মোডে ক্র্যাশ হলে ধূসর স্ক্রিন যেন না দেখায়
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh, color: AppColors.primary, size: 48),
              const SizedBox(height: 16),
              const Text('Loading FlashFinds Deals...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(details.exception.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }

  runApp(const FlashFindsApp());
}

class FlashFindsApp extends StatelessWidget {
  const FlashFindsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashFinds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
