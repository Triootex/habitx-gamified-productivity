import 'package:injectable/injectable.dart';
import '../../domain/entities/meals_entity.dart';
import '../../core/utils/meals_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class MealsService {
  Future<MealPlanEntity> createMealPlan(String userId, Map<String, dynamic> planData);
  Future<MealEntity> addMeal(String userId, Map<String, dynamic> mealData);
  Future<RecipeEntity> createRecipe(String userId, Map<String, dynamic> recipeData);
  Future<GroceryListEntity> generateGroceryList(String userId, List<String> mealPlanIds);
  Future<List<MealPlanEntity>> getUserMealPlans(String userId);
  Future<Map<String, dynamic>> getMealAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> scanBarcode(String barcode);
  Future<List<RecipeEntity>> searchRecipes(String query, Map<String, dynamic> filters);
  Future<Map<String, dynamic>> calculateNutritionalBalance(String userId, DateTime date);
  Future<List<String>> generateAIMealPlan(String userId, Map<String, dynamic> preferences);
}

@LazySingleton(as: MealsService)
class MealsServiceImpl implements MealsService {
  @override
  Future<MealPlanEntity> createMealPlan(String userId, Map<String, dynamic> planData) async {
    try {
      final now = DateTime.now();
      final planId = 'plan_${now.millisecondsSinceEpoch}';
      
      final plan = MealPlanEntity(
        id: planId,
        userId: userId,
        name: planData['name'] as String,
        description: planData['description'] as String?,
        planType: planData['plan_type'] as String? ?? 'weekly',
        startDate: DateTime.parse(planData['start_date'] as String),
        endDate: DateTime.parse(planData['end_date'] as String),
        dietType: planData['diet_type'] as String? ?? 'standard',
        allergies: (planData['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
        dislikes: (planData['dislikes'] as List<dynamic>?)?.cast<String>() ?? [],
        preferences: (planData['preferences'] as List<dynamic>?)?.cast<String>() ?? [],
        nutritionGoals: Map<String, double>.from(planData['nutrition_goals'] ?? {
          'calories': 2000.0,
          'protein': 150.0,
          'carbs': 250.0,
          'fat': 65.0,
          'fiber': 25.0,
        }),
        servingSize: planData['serving_size'] as int? ?? 2,
        includeSnacks: planData['include_snacks'] as bool? ?? true,
        isAIGenerated: planData['is_ai_generated'] as bool? ?? false,
        autoGenerateGroceryList: planData['auto_grocery_list'] as bool? ?? true,
        optimizeForBudget: planData['optimize_budget'] as bool? ?? false,
        optimizeForTime: planData['optimize_time'] as bool? ?? false,
        createdAt: now,
      );
      
      return plan;
    } catch (e) {
      throw Exception('Failed to create meal plan: ${e.toString()}');
    }
  }

  @override
  Future<MealEntity> addMeal(String userId, Map<String, dynamic> mealData) async {
    try {
      final now = DateTime.now();
      final mealId = 'meal_${now.millisecondsSinceEpoch}';
      
      // Calculate nutrition if ingredients provided
      final ingredients = (mealData['ingredients'] as List<dynamic>?)
          ?.map((i) => IngredientEntity(
                id: 'ing_${now.millisecondsSinceEpoch}_${i['name']}',
                name: i['name'] as String,
                quantity: i['quantity'] as double,
                unit: i['unit'] as String,
                brand: i['brand'] as String?,
                notes: i['notes'] as String?,
                cost: i['cost'] as double?,
              ))
          .toList() ?? [];
      
      final nutrition = MealsUtils.calculateNutritionalBalance(
        ingredients: ingredients.map((i) => {
          'name': i.name,
          'quantity': i.quantity,
          'unit': i.unit,
        }).toList(),
        servings: mealData['servings'] as int? ?? 2,
      );
      
      final meal = MealEntity(
        id: mealId,
        planId: mealData['plan_id'] as String?,
        userId: userId,
        name: mealData['name'] as String,
        mealType: mealData['meal_type'] as String? ?? 'meal',
        description: mealData['description'] as String?,
        ingredients: ingredients,
        instructions: (mealData['instructions'] as List<dynamic>?)?.cast<String>() ?? [],
        prepTimeMinutes: mealData['prep_time'] as int? ?? 0,
        cookTimeMinutes: mealData['cook_time'] as int? ?? 0,
        servings: mealData['servings'] as int? ?? 2,
        difficulty: mealData['difficulty'] as String? ?? 'medium',
        nutrition: Map<String, double>.from(nutrition['per_serving'] ?? {}),
        calories: nutrition['per_serving']?['calories']?.toDouble() ?? 0.0,
        protein: nutrition['per_serving']?['protein']?.toDouble() ?? 0.0,
        carbs: nutrition['per_serving']?['carbs']?.toDouble() ?? 0.0,
        fat: nutrition['per_serving']?['fat']?.toDouble() ?? 0.0,
        fiber: nutrition['per_serving']?['fiber']?.toDouble() ?? 0.0,
        sugar: nutrition['per_serving']?['sugar']?.toDouble() ?? 0.0,
        sodium: nutrition['per_serving']?['sodium']?.toDouble() ?? 0.0,
        cuisine: mealData['cuisine'] as String?,
        tags: (mealData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        imageUrl: mealData['image_url'] as String?,
        videoUrl: mealData['video_url'] as String?,
        equipment: (mealData['equipment'] as List<dynamic>?)?.cast<String>() ?? [],
        source: mealData['source'] as String? ?? 'user_created',
        isMealPrepFriendly: mealData['meal_prep_friendly'] as bool? ?? false,
        storageLifeDays: mealData['storage_life_days'] as int? ?? 3,
        canFreeze: mealData['can_freeze'] as bool? ?? false,
        createdAt: now,
      );
      
      return meal;
    } catch (e) {
      throw Exception('Failed to add meal: ${e.toString()}');
    }
  }

  @override
  Future<RecipeEntity> createRecipe(String userId, Map<String, dynamic> recipeData) async {
    try {
      final now = DateTime.now();
      final recipeId = 'recipe_${now.millisecondsSinceEpoch}';
      
      final ingredients = (recipeData['ingredients'] as List<dynamic>?)
          ?.map((i) => IngredientEntity(
                id: 'ing_${now.millisecondsSinceEpoch}_${i['name']}',
                name: i['name'] as String,
                quantity: i['quantity'] as double,
                unit: i['unit'] as String,
                brand: i['brand'] as String?,
                alternatives: (i['alternatives'] as List<dynamic>?)?.cast<String>() ?? [],
              ))
          .toList() ?? [];
      
      final nutrition = MealsUtils.calculateNutritionalBalance(
        ingredients: ingredients.map((i) => {
          'name': i.name,
          'quantity': i.quantity,
          'unit': i.unit,
        }).toList(),
        servings: recipeData['servings'] as int? ?? 2,
      );
      
      final recipe = RecipeEntity(
        id: recipeId,
        userId: userId,
        name: recipeData['name'] as String,
        description: recipeData['description'] as String?,
        cuisine: recipeData['cuisine'] as String? ?? 'international',
        ingredients: ingredients,
        instructions: (recipeData['instructions'] as List<dynamic>?)?.cast<String>() ?? [],
        prepTime: recipeData['prep_time'] as int? ?? 0,
        cookTime: recipeData['cook_time'] as int? ?? 0,
        servings: recipeData['servings'] as int? ?? 2,
        difficulty: recipeData['difficulty'] as String? ?? 'medium',
        nutrition: Map<String, double>.from(nutrition['total'] ?? {}),
        tags: (recipeData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        imageUrl: recipeData['image_url'] as String?,
        videoUrl: recipeData['video_url'] as String?,
        isPublic: recipeData['is_public'] as bool? ?? false,
        source: recipeData['source'] as String? ?? 'user_created',
        createdAt: now,
      );
      
      return recipe;
    } catch (e) {
      throw Exception('Failed to create recipe: ${e.toString()}');
    }
  }

  @override
  Future<GroceryListEntity> generateGroceryList(String userId, List<String> mealPlanIds) async {
    try {
      final now = DateTime.now();
      final listId = 'grocery_${now.millisecondsSinceEpoch}';
      
      // Mock meal plan retrieval and ingredient aggregation
      final groceryItems = await _generateGroceryItems(listId, mealPlanIds);
      final categorizedItems = _categorizeGroceryItems(groceryItems);
      final estimatedTotal = groceryItems.fold<double>(0.0, (sum, item) => sum + (item.estimatedPrice ?? 0.0));
      
      final groceryList = GroceryListEntity(
        id: listId,
        userId: userId,
        name: 'Grocery List - ${DateUtils.formatDate(now, 'MMM dd')}',
        items: groceryItems,
        categorizedItems: categorizedItems,
        estimatedTotal: estimatedTotal,
        mealPlanIds: mealPlanIds,
        createdAt: now,
      );
      
      return groceryList;
    } catch (e) {
      throw Exception('Failed to generate grocery list: ${e.toString()}');
    }
  }

  @override
  Future<List<MealPlanEntity>> getUserMealPlans(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockMealPlans(userId);
    } catch (e) {
      throw Exception('Failed to retrieve user meal plans: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMealAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final mealPlans = await getUserMealPlans(userId);
      
      if (mealPlans.isEmpty) {
        return {
          'total_plans': 0,
          'nutrition_adherence': 0.0,
          'meal_variety': 0.0,
        };
      }
      
      final activePlans = mealPlans.where((p) => p.isActive).toList();
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_plans': mealPlans.length,
          'active_plans': activePlans.length,
          'average_adherence': activePlans.isEmpty ? 0.0 : 
              activePlans.fold<double>(0, (sum, p) => sum + p.adherenceRate) / activePlans.length,
          'nutrition_goals_met': _calculateNutritionGoalsMet(activePlans),
        },
        'nutrition': {
          'average_daily_calories': _calculateAverageDailyCalories(activePlans),
          'macro_distribution': _getMacroDistribution(activePlans),
          'nutrition_balance_score': _calculateNutritionBalance(activePlans),
        },
        'variety': {
          'unique_meals': _countUniqueMeals(activePlans),
          'cuisine_diversity': _getCuisineDistribution(activePlans),
          'meal_type_balance': _getMealTypeBalance(activePlans),
        },
        'insights': _generateMealInsights(activePlans),
      };
    } catch (e) {
      throw Exception('Failed to get meal analytics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      // Mock barcode scanning - in real implementation, would call nutrition API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final nutritionDatabase = {
        '1234567890': {
          'name': 'Organic Banana',
          'brand': 'Whole Foods',
          'serving_size': '1 medium (118g)',
          'calories': 105,
          'protein': 1.3,
          'carbs': 27.0,
          'fat': 0.4,
          'fiber': 3.1,
          'sugar': 14.4,
        },
        '0987654321': {
          'name': 'Greek Yogurt',
          'brand': 'Chobani',
          'serving_size': '1 container (170g)',
          'calories': 130,
          'protein': 20.0,
          'carbs': 6.0,
          'fat': 3.5,
          'fiber': 0.0,
          'sugar': 4.0,
        },
      };
      
      final productData = nutritionDatabase[barcode];
      if (productData != null) {
        return {
          'found': true,
          'product': productData,
          'confidence': 0.95,
        };
      } else {
        return {
          'found': false,
          'message': 'Product not found in database',
          'suggested_alternatives': ['Manual entry', 'Photo recognition'],
        };
      }
    } catch (e) {
      throw Exception('Failed to scan barcode: ${e.toString()}');
    }
  }

  @override
  Future<List<RecipeEntity>> searchRecipes(String query, Map<String, dynamic> filters) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock recipe search
      final mockRecipes = _generateMockRecipes('user_id');
      
      // Apply search and filters
      List<RecipeEntity> filteredRecipes = mockRecipes;
      
      if (query.isNotEmpty) {
        filteredRecipes = filteredRecipes.where((recipe) {
          return recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                 recipe.description?.toLowerCase().contains(query.toLowerCase()) == true ||
                 recipe.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
      
      // Apply cuisine filter
      if (filters['cuisine'] != null) {
        filteredRecipes = filteredRecipes.where((recipe) {
          return recipe.cuisine == filters['cuisine'];
        }).toList();
      }
      
      // Apply difficulty filter
      if (filters['difficulty'] != null) {
        filteredRecipes = filteredRecipes.where((recipe) {
          return recipe.difficulty == filters['difficulty'];
        }).toList();
      }
      
      // Apply time filter
      if (filters['max_total_time'] != null) {
        final maxTime = filters['max_total_time'] as int;
        filteredRecipes = filteredRecipes.where((recipe) {
          return recipe.totalTime <= maxTime;
        }).toList();
      }
      
      return filteredRecipes;
    } catch (e) {
      throw Exception('Failed to search recipes: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateNutritionalBalance(String userId, DateTime date) async {
    try {
      // Mock nutritional calculation for the day
      return MealsUtils.calculateNutritionalBalance(
        ingredients: [
          {'name': 'Chicken Breast', 'quantity': 200.0, 'unit': 'g'},
          {'name': 'Brown Rice', 'quantity': 1.0, 'unit': 'cup'},
          {'name': 'Broccoli', 'quantity': 150.0, 'unit': 'g'},
        ],
        servings: 1,
      );
    } catch (e) {
      throw Exception('Failed to calculate nutritional balance: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateAIMealPlan(String userId, Map<String, dynamic> preferences) async {
    try {
      return MealsUtils.generateMealPlan(
        dietType: preferences['diet_type'] as String? ?? 'standard',
        allergies: (preferences['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
        dislikes: (preferences['dislikes'] as List<dynamic>?)?.cast<String>() ?? [],
        nutritionGoals: Map<String, double>.from(preferences['nutrition_goals'] ?? {}),
        budgetConstraint: preferences['budget'] as double?,
        timeConstraint: preferences['max_prep_time'] as int?,
        servingSize: preferences['serving_size'] as int? ?? 2,
        mealCount: preferences['meal_count'] as int? ?? 21, // 3 meals x 7 days
      );
    } catch (e) {
      throw Exception('Failed to generate AI meal plan: ${e.toString()}');
    }
  }

  // Private helper methods
  List<MealPlanEntity> _generateMockMealPlans(String userId) {
    final now = DateTime.now();
    
    return [
      MealPlanEntity(
        id: 'plan_1',
        userId: userId,
        name: 'Healthy Weekly Plan',
        planType: 'weekly',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
        dietType: 'mediterranean',
        nutritionGoals: {
          'calories': 2000.0,
          'protein': 150.0,
          'carbs': 225.0,
          'fat': 65.0,
          'fiber': 30.0,
        },
        servingSize: 2,
        adherenceRate: 0.85,
        estimatedCost: 120.0,
        isAIGenerated: true,
        autoGenerateGroceryList: true,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  List<RecipeEntity> _generateMockRecipes(String userId) {
    final now = DateTime.now();
    
    return [
      RecipeEntity(
        id: 'recipe_1',
        userId: userId,
        name: 'Mediterranean Chicken Bowl',
        description: 'Healthy and delicious Mediterranean-style chicken bowl',
        cuisine: 'Mediterranean',
        ingredients: [
          IngredientEntity(
            id: 'ing_1',
            name: 'Chicken Breast',
            quantity: 200.0,
            unit: 'g',
          ),
          IngredientEntity(
            id: 'ing_2',
            name: 'Quinoa',
            quantity: 1.0,
            unit: 'cup',
          ),
        ],
        instructions: [
          'Season and grill chicken breast',
          'Cook quinoa according to package directions',
          'Combine and serve with vegetables',
        ],
        prepTime: 15,
        cookTime: 25,
        servings: 2,
        difficulty: 'medium',
        nutrition: {
          'calories': 450.0,
          'protein': 35.0,
          'carbs': 40.0,
          'fat': 12.0,
        },
        tags: ['healthy', 'mediterranean', 'high-protein'],
        rating: 4.8,
        ratingCount: 245,
        isPublic: true,
        source: 'user_created',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  Future<List<GroceryItemEntity>> _generateGroceryItems(String listId, List<String> mealPlanIds) async {
    final now = DateTime.now();
    
    return [
      GroceryItemEntity(
        id: 'item_1',
        listId: listId,
        name: 'Chicken Breast',
        quantity: 2.0,
        unit: 'lbs',
        category: 'Meat & Poultry',
        estimatedPrice: 12.99,
        isUrgent: false,
      ),
      GroceryItemEntity(
        id: 'item_2',
        listId: listId,
        name: 'Quinoa',
        quantity: 1.0,
        unit: 'bag',
        category: 'Grains & Pasta',
        estimatedPrice: 4.99,
        isUrgent: false,
      ),
      GroceryItemEntity(
        id: 'item_3',
        listId: listId,
        name: 'Mixed Vegetables',
        quantity: 2.0,
        unit: 'bags',
        category: 'Produce',
        estimatedPrice: 6.98,
        isUrgent: false,
      ),
    ];
  }

  Map<String, List<GroceryItemEntity>> _categorizeGroceryItems(List<GroceryItemEntity> items) {
    final categorized = <String, List<GroceryItemEntity>>{};
    
    for (final item in items) {
      categorized.putIfAbsent(item.category, () => []);
      categorized[item.category]!.add(item);
    }
    
    return categorized;
  }

  double _calculateNutritionGoalsMet(List<MealPlanEntity> plans) {
    if (plans.isEmpty) return 0.0;
    
    // Mock calculation - in real implementation, would analyze actual nutrition vs goals
    return 0.78; // 78% of nutrition goals met on average
  }

  double _calculateAverageDailyCalories(List<MealPlanEntity> plans) {
    if (plans.isEmpty) return 0.0;
    
    return plans.fold<double>(0, (sum, p) => sum + (p.nutritionGoals['calories'] ?? 0)) / plans.length;
  }

  Map<String, double> _getMacroDistribution(List<MealPlanEntity> plans) {
    if (plans.isEmpty) return {};
    
    // Mock macro distribution
    return {
      'carbs_percentage': 45.0,
      'protein_percentage': 25.0,
      'fat_percentage': 30.0,
    };
  }

  double _calculateNutritionBalance(List<MealPlanEntity> plans) {
    // Mock nutrition balance score
    return 8.2; // Out of 10
  }

  int _countUniqueMeals(List<MealPlanEntity> plans) {
    // Mock unique meal count
    return 15;
  }

  Map<String, int> _getCuisineDistribution(List<MealPlanEntity> plans) {
    // Mock cuisine distribution
    return {
      'Mediterranean': 8,
      'Asian': 5,
      'American': 4,
      'Italian': 3,
      'Mexican': 2,
    };
  }

  Map<String, int> _getMealTypeBalance(List<MealPlanEntity> plans) {
    // Mock meal type balance
    return {
      'breakfast': 7,
      'lunch': 7,
      'dinner': 7,
      'snacks': 10,
    };
  }

  List<String> _generateMealInsights(List<MealPlanEntity> plans) {
    final insights = <String>[];
    
    if (plans.isEmpty) {
      insights.add('Create your first meal plan to start tracking nutrition and meal planning insights!');
      return insights;
    }
    
    final avgAdherence = plans.fold<double>(0, (sum, p) => sum + p.adherenceRate) / plans.length;
    
    if (avgAdherence >= 0.8) {
      insights.add('🎉 Excellent meal plan adherence! You\'re staying consistent with your nutrition goals.');
    } else if (avgAdherence >= 0.6) {
      insights.add('👍 Good meal plan follow-through. Consider meal prep to improve consistency.');
    } else {
      insights.add('💡 Meal planning adherence could improve. Try simpler recipes and better preparation.');
    }
    
    // Budget insights
    final totalCost = plans.fold<double>(0, (sum, p) => sum + p.estimatedCost);
    if (totalCost > 0) {
      insights.add('💰 Average weekly meal cost: \$${(totalCost / plans.length).toStringAsFixed(2)}');
    }
    
    // Nutrition insights
    final nutritionBalance = _calculateNutritionBalance(plans);
    if (nutritionBalance >= 8.0) {
      insights.add('🥗 Excellent nutritional balance across your meal plans!');
    } else if (nutritionBalance >= 6.0) {
      insights.add('🌱 Good nutrition variety. Consider adding more diverse food groups.');
    } else {
      insights.add('🍎 Focus on improving nutritional balance with more variety in your meals.');
    }
    
    return insights;
  }
}
