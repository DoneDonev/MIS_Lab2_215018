import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class ScreenMealDetail extends StatefulWidget {
  final String mealId;
  final MealDetail? initialMeal;

  const ScreenMealDetail({
    super.key,
    required this.mealId,
    this.initialMeal,
  });

  @override
  State<ScreenMealDetail> createState() => _ScreenMealDetailState();
}

class _ScreenMealDetailState extends State<ScreenMealDetail> {
  final MealApiService apiService = MealApiService();
  MealDetail? _meal;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    
    if (widget.initialMeal != null) {
      _meal = widget.initialMeal;
      _isLoading = false;
    } else {
      _loadMeal();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMeal() async {
    try {
      final meal = await apiService.getMealDetail(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = _meal;
    final opacity = math.min(1.0, _scrollOffset / 200);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE86A33),
              ),
            )
          : meal == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data for this recipe',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: false,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          automaticallyImplyLeading: false,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Hero(
                              tag: 'meal-${meal.id}',
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    meal.thumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.restaurant,
                                          color: Colors.grey.shade400,
                                          size: 80,
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFFFFFBF5).withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFBF5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                                  child: Text(
                                    meal.name,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                      letterSpacing: -1,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                _buildSection(
                                  'Ingredients',
                                  Icons.shopping_basket_outlined,
                                  Column(
                                    children: meal.ingredients.map((ing) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE86A33),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                ing.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF2D2D2D),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              ing.measure,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                _buildSection(
                                  'Instructions',
                                  Icons.receipt_long_outlined,
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      meal.instructions,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                        height: 1.6,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),

                                // YouTube Link
                                if (meal.youtubeUrl != null &&
                                    meal.youtubeUrl!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Material(
                                      color: const Color(0xFFE86A33),
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        onTap: () async {
                                          final url = Uri.parse(meal.youtubeUrl!);
                                          try {
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            } else {
                                              // Fallback: copy link if can't open
                                              await Clipboard.setData(
                                                ClipboardData(text: meal.youtubeUrl!),
                                              );
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Could not open YouTube. Link copied!',
                                                  ),
                                                  backgroundColor: Colors.orange.shade400,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error opening link: $e'),
                                                backgroundColor: Colors.red.shade400,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Watch on YouTube',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE86A33),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}