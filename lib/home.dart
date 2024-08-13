import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newprjct/login_screen.dart';

import 'controller/post_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _postController = TextEditingController();
  final PostController _postControllerInstance = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: ()  async{
             await FirebaseAuth.instance.signOut();
              // Navigate to login screen or handle logout
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Write a post',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_postControllerInstance.editingPostId == null) {
                      _postControllerInstance.savePost(_postController.text);
                    } else {
                      _postControllerInstance.updatePost(_postController.text);
                    }
                    _postController.clear();
                  },
                  child: Text(_postControllerInstance.editingPostId == null
                      ? 'Save'
                      : 'Update'),
                ),
                if (_postControllerInstance.editingPostId != null)
                  ElevatedButton(
                    onPressed: () {
                      _postController.clear();
                      setState(() {
                        _postControllerInstance.editingPostId = null;
                      });
                    },
                    child: Text('Cancel'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: _postControllerInstance.getAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading posts: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    final posts = snapshot.data!;
                    print('Fetched posts: $posts');

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        print('Post data: ${post.data()}');

                        final isOwnPost = post['userId'] ==
                            FirebaseAuth.instance.currentUser?.uid;

                        // Convert the post data to a map
                        final postData = post.data() as Map<String, dynamic>;

                        final userName = postData['userName'] ?? 'Anonymous';
                        final userEmail = postData['userEmail'] ?? 'anonymous@example.com';

                        return ListTile(
                          title: Text(postData['content'] ?? ''),
                          subtitle: Text('$userName ($userEmail)'),
                          trailing: isOwnPost
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _postController.text =
                                            postData['content'] ?? '';
                                        _postControllerInstance.editPost(
                                            post.id, postData['content'] ?? '');
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _postControllerInstance
                                            .deletePost(post.id);
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  }

                  return Center(child: Text('No posts available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
