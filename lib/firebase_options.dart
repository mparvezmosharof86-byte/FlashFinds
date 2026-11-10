import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const String webClientId = ''; // এটি বিল্ড টাইমে স্বয়ংক্রিয়ভাবে বসে যাবে

  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyPlaceholder',
      appId: '1:123456789:android:placeholder',
      messagingSenderId: '123456789',
      projectId: 'flashfinds',
      storageBucket: 'flashfinds.appspot.com',
    );
  }
}
