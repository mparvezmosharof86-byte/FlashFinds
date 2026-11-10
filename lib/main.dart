import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ফায়ারবেস সরাসরি ডার্ট কোড দিয়ে কানেক্ট হবে
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init: $e");
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
