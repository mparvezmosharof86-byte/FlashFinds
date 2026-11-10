import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Safe Lazy Initializers (কখনোই ক্র্যাশ করবে না)
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Auth init safe skip: $e");
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore init safe skip: $e");
      return null;
    }
  }

  Stream<User?> get userStream {
    try {
      return _auth?.authStateChanges() ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

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

      if (_auth == null) throw 'Firebase not ready yet';
      final UserCredential userCredential = await _auth!.signInWithCredential(credential);
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

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (_auth == null) throw 'Authentication service is initializing';
    final cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
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

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_auth == null) throw 'Authentication service is initializing';
    return await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth?.signOut();
    } catch (_) {}
  }
}
