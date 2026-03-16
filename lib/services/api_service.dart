import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> fetchPosts() async {
  final response = await http.get(
    Uri.parse(baseUrl),
    headers: {
      'User-Agent': 'Mozilla/5.0',
      'Accept': 'application/json',
    },
  );

  print("STATUS CODE: ${response.statusCode}");

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Post.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load posts');
  }
}

  Future<Post> fetchPostById(int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$id'),
    headers: {
      'User-Agent': 'Mozilla/5.0',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return Post.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load post details');
  }
}

  Future<Post> createPost(Post post) async {
    final response = await http.post(
  Uri.parse(baseUrl),
  headers: {
    'Content-Type': 'application/json; charset=UTF-8',
    'User-Agent': 'Mozilla/5.0',
  },
  body: jsonEncode(post.toJson()),
);

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<Post> updatePost(int id, Post post) async {
    final response = await http.put(
  Uri.parse('$baseUrl/$id'),
  headers: {
    'Content-Type': 'application/json; charset=UTF-8',
    'User-Agent': 'Mozilla/5.0',
  },
  body: jsonEncode(post.toJson()),
);

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(
  Uri.parse('$baseUrl/$id'),
  headers: {
    'User-Agent': 'Mozilla/5.0',
  },
);

    if (response.statusCode != 200 && response.statusCode != 204) {
  throw Exception('Failed to delete post');
}
  }
}