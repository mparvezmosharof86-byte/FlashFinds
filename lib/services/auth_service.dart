import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ইউজার লগইন স্টেট লিসেন করার স্ট্রিম
  Stream<User?> get userStream => _auth.authStateChanges();

  // বর্তমান ইউজার
  User? get currentUser => _auth.currentUser;

  // ইমেইল ও পাসওয়ার্ড দিয়ে সাইন-আপ
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // ইমেইল ও পাসওয়ার্ড দিয়ে লগইন
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // লগআউট
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
