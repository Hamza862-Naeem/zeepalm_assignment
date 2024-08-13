import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save a new post
  Future<void> savePost(String content) async {
    final user = _auth.currentUser;
    if (user == null || content.isEmpty) return;

    await _firestore.collection('posts').add({
      'content': content,
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'userEmail': user.email ?? 'anonymous@example.com',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing post
  Future<void> updatePost(String postId, String content) async {
    if (postId.isEmpty || content.isEmpty) return;

    await _firestore.collection('posts').doc(postId).update({
      'content': content,
    });
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    if (postId.isEmpty) return;

    await _firestore.collection('posts').doc(postId).delete();
  }

  // Fetch all posts
  Stream<List<QueryDocumentSnapshot>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }
}
