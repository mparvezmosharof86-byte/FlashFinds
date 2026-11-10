import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
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

  // ১. গুগল সাইন-ইন (Web Client ID সহ - আর কখনো ApiException 10 আসবে না)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: DefaultFirebaseOptions.webClientId.isNotEmpty 
            ? DefaultFirebaseOptions.webClientId 
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (_auth == null) throw 'Firebase initializing, please tap again.';
      final UserCredential userCredential = await _auth!.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && _firestore != null) {
        _firestore!.collection('users').doc(user.uid).set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'authProvider': 'google',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 4)).catchError((_) {});
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ২. ইমেইল সাইন-আপ
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (_auth == null) throw 'Connecting to server... Please tap again.';

    final cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;

    if (user != null) {
      final fullName = '$firstName $lastName'.trim();
      user.updateDisplayName(fullName).catchError((_) {});

      if (_firestore != null) {
        _firestore!.collection('users').doc(user.uid).set({
          'displayName': fullName,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 3)).catchError((_) {});
      }
    }
    return cred;
  }

  // ৩. ইমেইল লগইন
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_auth == null) throw 'Connecting to server... Please tap again.';
    return await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  // ৪. ফোন নম্বর সেভ করা
  Future<void> savePhoneUser(String uid, String phoneNumber) async {
    if (_firestore == null) return;
    try {
      _firestore!.collection('users').doc(uid).set({
        'displayName': 'User ${phoneNumber.length >= 4 ? phoneNumber.substring(phoneNumber.length - 4) : phoneNumber}',
        'phone': phoneNumber,
        'email': '',
        'photoUrl': '',
        'authProvider': 'phone',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3)).catchError((_) {});
    } catch (_) {}
  }

  // ৫. লগআউট
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth?.signOut();
    } catch (_) {}
  }
}
