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
      appBar: AppBar(
  title: Text(
    isEditing ? 'Edit Post' : 'Create Post',
    style: const TextStyle(color: Colors.blue),
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Body is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
  onPressed: submitForm,
  child: Text(
    isEditing ? 'Update Post' : 'Create Post',
    style: const TextStyle(color: Colors.blue),
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