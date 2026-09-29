import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoriesService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _stories => _db.collection('stories');

  /// Stream of active stories (last 24h)
  Stream<List<Map<String, dynamic>>> watchStories() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _stories
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'userId': d['userId'] ?? '',
          'username': d['username'] ?? 'User',
          'imageUrl': d['imageUrl'] ?? '',
          'createdAt': d['createdAt'],
        };
      }).toList();
    });
  }

  Future<void> addStory({required String imageUrl, String? username}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _stories.add({
      'userId': user.uid,
      'username': username ?? user.email?.split('@').first ?? 'User',
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
