import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myfinance/helper/category.dart';


class CategoryService {
  final String baseUrl = 'http://localhost:3000/api/categories';

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Category> categories = body
            .map((dynamic item) => Category.fromJson(item))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 201) {
        return Category.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Category> updateCategory(String id, Category category) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  addCategory(Category category) {}
}