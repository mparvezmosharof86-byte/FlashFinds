import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ১. গুগল সাইন-ইন (ফোনের সব জিমেইল লিস্ট ওপেন করবে)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // ইউজার ক্যানসেল করলে

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // ফায়ারস্টোর ডাটাবেজে প্রোফাইল তথ্য সিঙ্ক
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'phone': user.phoneNumber ?? '',
          'authProvider': 'google',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ২. ইমেইল সাইন-আপ (First Name, Last Name সহ)
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final fullName = '$firstName $lastName'.trim();
        await user.updateDisplayName(fullName);
        await user.sendEmailVerification(); // ইমেইল ভেরিফিকেশন পাঠানো

        await _firestore.collection('users').doc(user.uid).set({
          'displayName': fullName,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': '',
          'photoUrl': '',
          'authProvider': 'email',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ৩. ইমেইল লগইন
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ৪. ফোন নম্বর সাইন-ইন
  Future<void> savePhoneUser(String uid, String phoneNumber) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
      'phone': phoneNumber,
      'email': '',
      'photoUrl': '',
      'authProvider': 'phone',
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ৫. লগআউট
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
