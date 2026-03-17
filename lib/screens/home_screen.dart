import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<Post> posts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.fetchPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  Future<void> deletePost(int id) async {
    setState(() {
      posts.removeWhere((post) => post.id == id);
    });

    try {
      await apiService.deletePost(id);
    } catch (e) {
      print("Delete API failed but removed locally");
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted')),
    );
  }

  void goToCreateScreen() async {
    final newPost = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PostFormScreen(),
      ),
    );

    if (newPost != null) {
      setState(() {
        posts.insert(0, newPost);
      });
    }
  }

  void goToEditScreen(Post post) async {
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostFormScreen(post: post),
      ),
    );

    if (updatedPost != null) {
      setState(() {
        final index = posts.indexWhere((p) => p.id == updatedPost.id);
        if (index != -1) {
          posts[index] = updatedPost;
        }
      });
    }
  }

  void goToDetailScreen(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  void logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🔵 MATCH DETAIL SCREEN BACKGROUND
      backgroundColor: Colors.blue[100],

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "Posts Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : posts.isEmpty
                  ? const Center(child: Text('No posts found'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔹 SECTION TITLE (like detail screen)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text(
                            "Posts",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        /// 📜 LIST
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: refreshPosts,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 80),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return PostCard(
                                  post: post,
                                  onTap: () => goToDetailScreen(post),
                                  onEdit: () => goToEditScreen(post),
                                  onDelete: () => deletePost(post.id!),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

      /// 🔵 MATCH BUTTON STYLE
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: goToCreateScreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Post",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}