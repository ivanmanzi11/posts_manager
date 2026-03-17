import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController titleController;
  late TextEditingController bodyController;
  late TextEditingController userIdController;

  bool isLoading = false;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post?.title ?? '');
    bodyController = TextEditingController(text: widget.post?.body ?? '');
    userIdController =
        TextEditingController(text: widget.post?.userId.toString() ?? '1');
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    userIdController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final post = Post(
  id: widget.post?.id ?? DateTime.now().millisecondsSinceEpoch,
  userId: int.tryParse(userIdController.text) ?? 1,
  title: titleController.text.trim(),
  body: bodyController.text.trim(),
);

    try {
      if (isEditing) {

  // If post ID is from API
  if (widget.post!.id! <= 100) {
    await apiService.updatePost(widget.post!.id!, post);
  }

  // If post was created locally
  // just return updated post without API call

} else {
  await apiService.createPost(post);
}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Post updated successfully'
                : 'Post created successfully',
          ),
        ),
      );

      Navigator.pop(context, post);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.blue[100], // 👈 softer background

    appBar: AppBar(
      backgroundColor: Colors.blue,
      elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        isEditing ? 'Edit Post' : 'Create Post',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 SECTION TITLE
            const Text(
              "Post Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 12),

            /// 🧾 FORM CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// USER ID
                    TextFormField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'User ID is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// BODY
                    TextFormField(
                      controller: bodyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Body',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Body is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔵 BUTTON
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: submitForm,
                      child: Text(
                        isEditing ? 'Update Post' : 'Create Post',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}
}