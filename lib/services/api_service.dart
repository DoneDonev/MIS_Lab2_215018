import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categoriesJson = data['categories'];
      return categoriesJson.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Cannot load categories');
    }
  }

  Future<List<MealSummary>> getMealsByCategory(String category) async {
    final url = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'] ?? [];
      return mealsJson.map((e) => MealSummary.fromJson(e)).toList();
    } else {
      throw Exception('Cannot load meals');
    }
  }

  Future<List<MealDetail>> searchMeals(String query) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson == null) return [];
      return mealsJson.map((e) => MealDetail.fromJson(e)).toList();
    } else {
      throw Exception('Cannot search meals');
    }
  }

  Future<MealDetail> getMealDetail(String id) async {
    final url = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'];
      return MealDetail.fromJson(mealsJson.first);
    } else {
      throw Exception('Cannot load meal detail');
    }
  }

  Future<MealDetail> getRandomMeal() async {
    final url = Uri.parse('$_baseUrl/random.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'];
      return MealDetail.fromJson(mealsJson.first);
    } else {
      throw Exception('Cannot load meal');
    }
  }
}
