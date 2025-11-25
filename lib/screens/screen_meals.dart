import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import '../widgets/item_meal_grid.dart';
import 'screen_meal_detail.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({super.key, required this.category});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final MealApiService apiService = MealApiService();
  List<MealSummary> _meals = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    try {
      final meals = await apiService.getMealsByCategory(widget.category);
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _searchMeals(String query) async {
    setState(() {
      _searchText = query;
    });

    if (query.trim().isEmpty) {
      _loadMeals();
      return;
    }

    try {
      final List<MealDetail> results =
          await apiService.searchMeals(query.trim());

      final filtered = results
          .where((m) => (m as dynamic).strCategory == widget.category)
          .toList();

      final filteredSummaries = _meals
          .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _meals = filteredSummaries;
      });
    } catch (e) {
      // fallback: само локален filter
      final filteredSummaries = _meals
          .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _meals = filteredSummaries;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category: ${widget.category}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: _searchMeals,
              decoration: InputDecoration(
                hintText: 'Search meals...',
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
          : _meals.isEmpty
              ? const Center(child: Text('No meals for this category'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _meals.length,
                  itemBuilder: (ctx, index) {
                    final meal = _meals[index];
                    return ItemMealGrid(
                      meal: meal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ScreenMealDetail(mealId: meal.id),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
