import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import '../widgets/card_category.dart';
import 'screen_meals.dart';
import 'screen_meal_detail.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MealApiService apiService = MealApiService();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await apiService.getCategories();
      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchText = query;
      _filteredCategories = _allCategories
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();
    });
  }

  Future<void> _showRandomMeal() async {
    try {
      final MealDetail meal = await apiService.getRandomMeal();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScreenMealDetail(mealId: meal.id, initialMeal: meal),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load meal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes by Category'),
        actions: [
          IconButton(
            onPressed: _showRandomMeal,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random Recipe',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredCategories.isEmpty
              ? const Center(child: Text('No categories'))
              : ListView.builder(
                  itemCount: _filteredCategories.length,
                  itemBuilder: (ctx, index) {
                    final cat = _filteredCategories[index];
                    return CardCategory(
                      category: cat,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MealsScreen(category: cat.name),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
