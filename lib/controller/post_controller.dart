import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_services.dart';

class PostController extends GetxController {
  final PostService _postService = PostService();
  String? editingPostId;

  // Save a new post
  Future<void> savePost(String content) async {
    await _postService.savePost(content);
  }

  // Update an existing post
  Future<void> updatePost(String content) async {
    if (editingPostId != null) {
      await _postService.updatePost(editingPostId!, content);
      editingPostId = null;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    await _postService.deletePost(postId);
  }

  // Edit a post
  void editPost(String postId, String content) {
    editingPostId = postId;
  }

  // Fetch all posts
  Stream<List<QueryDocumentSnapshot>> getAllPosts() {
    return _postService.getAllPosts();
  }
}
