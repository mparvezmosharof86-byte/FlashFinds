import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
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

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (_auth == null) throw 'Authentication service is initializing. Please try again.';
    return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_auth == null) throw 'Authentication service is initializing. Please try again.';
    return await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }
}
