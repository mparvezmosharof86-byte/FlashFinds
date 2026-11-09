import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ইউজারের কার্টে প্রোডাক্ট যোগ করা
  Future<void> addToCart(String userId, ProductModel product) async {
    await _db.collection('users').doc(userId).collection('cart').doc(product.id).set({
      'id': product.id,
      'title': product.title,
      'price': product.currentPrice,
      'originalPrice': product.originalPrice,
      'imageUrl': product.imageUrl,
      'affiliateUrl': product.affiliateUrl,
      'quantity': FieldValue.increment(1),
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // কার্ট আইটেমের লাইভ স্ট্রিম
  Stream<QuerySnapshot> getCartItems(String userId) {
    return _db.collection('users').doc(userId).collection('cart').snapshots();
  }

  // কার্ট থেকে আইটেম মুছে ফেলা
  Future<void> removeFromCart(String userId, String productId) async {
    await _db.collection('users').doc(userId).collection('cart').doc(productId).delete();
  }
}
