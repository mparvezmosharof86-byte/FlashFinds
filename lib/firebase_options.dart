import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  // এটি বিল্ড টাইমে গিটহাব স্বয়ংক্রিয়ভাবে গুগল ফাইল থেকে লাইভ ডাটা দিয়ে রিপ্লেস করে দেবে
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
