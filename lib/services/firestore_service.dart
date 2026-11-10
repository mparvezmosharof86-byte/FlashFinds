import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // --- কার্ট সিস্টেম (CART SYSTEM) ---

  // কার্টে প্রোডাক্ট যোগ করা
  Future<void> addToCart(String userId, ProductModel product) async {
    if (_db == null) return;
    try {
      await _db!.collection('users').doc(userId).collection('cart').doc(product.id).set({
        'id': product.id,
        'title': product.title,
        'price': product.currentPrice,
        'originalPrice': product.originalPrice,
        'imageUrl': product.imageUrl,
        'affiliateUrl': product.affiliateUrl,
        'quantity': FieldValue.increment(1),
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // কার্টের লাইভ স্ট্রিম
  Stream<QuerySnapshot> getCartStream(String userId) {
    if (_db == null) return const Stream.empty();
    return _db!.collection('users').doc(userId).collection('cart').orderBy('addedAt', descending: true).snapshots();
  }

  // কার্টে সংখ্যা বাড়ানো বা কমানো (+ / -)
  Future<void> updateQuantity(String userId, String productId, int change) async {
    if (_db == null) return;
    try {
      final docRef = _db!.collection('users').doc(userId).collection('cart').doc(productId);
      final doc = await docRef.get();
      if (doc.exists) {
        int currentQty = (doc.data()?['quantity'] ?? 1);
        int newQty = currentQty + change;
        if (newQty <= 0) {
          await docRef.delete();
        } else {
          await docRef.update({'quantity': newQty});
        }
      }
    } catch (_) {}
  }

  // কার্ট থেকে আইটেম ডিলিট করা
  Future<void> removeFromCart(String userId, String productId) async {
    if (_db == null) return;
    try {
      await _db!.collection('users').doc(userId).collection('cart').doc(productId).delete();
    } catch (_) {}
  }

  // --- উইশলিস্ট বা ফেভারিট সিস্টেম (WISHLIST SYSTEM) ---

  // উইশলিস্টে টগল (Add / Remove)
  Future<bool> toggleWishlist(String userId, ProductModel product) async {
    if (_db == null) return false;
    try {
      final docRef = _db!.collection('users').doc(userId).collection('wishlist').doc(product.id);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        return false; // রিমুভ হয়েছে
      } else {
        await docRef.set({
          'id': product.id,
          'title': product.title,
          'price': product.currentPrice,
          'originalPrice': product.originalPrice,
          'imageUrl': product.imageUrl,
          'affiliateUrl': product.affiliateUrl,
          'addedAt': FieldValue.serverTimestamp(),
        });
        return true; // যোগ হয়েছে
      }
    } catch (_) {
      return false;
    }
  }

  // প্রোডাক্টটি উইশলিস্টে আছে কিনা চেক করা
  Stream<bool> isWishlistedStream(String userId, String productId) {
    if (_db == null) return Stream.value(false);
    return _db!.collection('users').doc(userId).collection('wishlist').doc(productId).snapshots().map((doc) => doc.exists);
  }
}
