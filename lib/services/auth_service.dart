import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // নিশ্চিতভাবে FirebaseAuth পাওয়ার ফাংশন
  Future<FirebaseAuth?> _getAuthSafe() async {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      try {
        await Firebase.initializeApp();
        return FirebaseAuth.instance;
      } catch (e) {
        debugPrint("Re-init note: $e");
        return null;
      }
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore safe skip: $e");
      return null;
    }
  }

  Stream<User?> get userStream {
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  User? get currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  // ১. গুগল সাইন-ইন
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = await _getAuthSafe();
      if (auth == null) throw 'Firebase services connecting, please tap again.';
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && _firestore != null) {
        await _firestore!.collection('users').doc(user.uid).set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
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
    final auth = await _getAuthSafe();
    if (auth == null) throw 'Connecting to secure server... Please tap again.';

    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user != null && _firestore != null) {
      await user.updateDisplayName('$firstName $lastName'.trim());
      await _firestore!.collection('users').doc(user.uid).set({
        'displayName': '$firstName $lastName'.trim(),
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return cred;
  }

  // ৩. ইমেইল লগইন
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = await _getAuthSafe();
    if (auth == null) throw 'Connecting to secure server... Please tap again.';
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ৪. ফোন নম্বর সেভ করা
  Future<void> savePhoneUser(String uid, String phoneNumber) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection('users').doc(uid).set({
        'displayName': 'User ${phoneNumber.length >= 4 ? phoneNumber.substring(phoneNumber.length - 4) : phoneNumber}',
        'phone': phoneNumber,
        'email': '',
        'photoUrl': '',
        'authProvider': 'phone',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Save phone user note: $e");
    }
  }

  // ৫. লগআউট
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      final auth = await _getAuthSafe();
      await auth?.signOut();
    } catch (_) {}
  }
}
