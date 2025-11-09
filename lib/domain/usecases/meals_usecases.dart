import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/meals_entity.dart';
import '../../data/repositories/meals_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Meal Plan Use Case
@injectable
class CreateMealPlanUseCase implements UseCase<MealPlanEntity, CreateMealPlanParams> {
  final MealsRepository repository;

  CreateMealPlanUseCase(this.repository);

  @override
  Future<Either<Failure, MealPlanEntity>> call(CreateMealPlanParams params) async {
    return await repository.createMealPlan(params.userId, params.planData);
  }
}

class CreateMealPlanParams {
  final String userId;
  final Map<String, dynamic> planData;

  CreateMealPlanParams({required this.userId, required this.planData});
}

// Add Meal Use Case
@injectable
class AddMealUseCase implements UseCase<MealEntity, AddMealParams> {
  final MealsRepository repository;

  AddMealUseCase(this.repository);

  @override
  Future<Either<Failure, MealEntity>> call(AddMealParams params) async {
    return await repository.addMeal(params.userId, params.mealData);
  }
}

class AddMealParams {
  final String userId;
  final Map<String, dynamic> mealData;

  AddMealParams({required this.userId, required this.mealData});
}

// Create Recipe Use Case
@injectable
class CreateRecipeUseCase implements UseCase<RecipeEntity, CreateRecipeParams> {
  final MealsRepository repository;

  CreateRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, RecipeEntity>> call(CreateRecipeParams params) async {
    return await repository.createRecipe(params.userId, params.recipeData);
  }
}

class CreateRecipeParams {
  final String userId;
  final Map<String, dynamic> recipeData;

  CreateRecipeParams({required this.userId, required this.recipeData});
}

// Generate Grocery List Use Case
@injectable
class GenerateMealGroceryListUseCase implements UseCase<GroceryListEntity, GenerateMealGroceryListParams> {
  final MealsRepository repository;

  GenerateMealGroceryListUseCase(this.repository);

  @override
  Future<Either<Failure, GroceryListEntity>> call(GenerateMealGroceryListParams params) async {
    return await repository.generateGroceryList(params.userId, params.mealPlanIds);
  }
}

class GenerateMealGroceryListParams {
  final String userId;
  final List<String> mealPlanIds;

  GenerateMealGroceryListParams({required this.userId, required this.mealPlanIds});
}

// Get User Meal Plans Use Case
@injectable
class GetUserMealPlansUseCase implements UseCase<List<MealPlanEntity>, String> {
  final MealsRepository repository;

  GetUserMealPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<MealPlanEntity>>> call(String userId) async {
    return await repository.getUserMealPlans(userId);
  }
}

// Get User Recipes Use Case
@injectable
class GetUserRecipesUseCase implements UseCase<List<RecipeEntity>, String> {
  final MealsRepository repository;

  GetUserRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(String userId) async {
    return await repository.getUserRecipes(userId);
  }
}

// Get Meal Analytics Use Case
@injectable
class GetMealAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetMealAnalyticsParams> {
  final MealsRepository repository;

  GetMealAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMealAnalyticsParams params) async {
    return await repository.getMealAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetMealAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetMealAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Scan Food Barcode Use Case
@injectable
class ScanFoodBarcodeUseCase implements UseCase<Map<String, dynamic>, String> {
  final MealsRepository repository;

  ScanFoodBarcodeUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String barcode) async {
    return await repository.scanBarcode(barcode);
  }
}

// Search Recipes Use Case
@injectable
class SearchRecipesUseCase implements UseCase<List<RecipeEntity>, SearchRecipesParams> {
  final MealsRepository repository;

  SearchRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(SearchRecipesParams params) async {
    return await repository.searchRecipes(params.query, params.filters);
  }
}

class SearchRecipesParams {
  final String query;
  final Map<String, dynamic> filters;

  SearchRecipesParams({required this.query, required this.filters});
}

// Calculate Nutritional Balance Use Case
@injectable
class CalculateNutritionalBalanceUseCase implements UseCase<Map<String, dynamic>, CalculateNutritionalBalanceParams> {
  final MealsRepository repository;

  CalculateNutritionalBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CalculateNutritionalBalanceParams params) async {
    return await repository.calculateNutritionalBalance(params.userId, params.date);
  }
}

class CalculateNutritionalBalanceParams {
  final String userId;
  final DateTime date;

  CalculateNutritionalBalanceParams({required this.userId, required this.date});
}

// Generate AI Meal Plan Use Case
@injectable
class GenerateAIMealPlanUseCase implements UseCase<List<String>, GenerateAIMealPlanParams> {
  final MealsRepository repository;

  GenerateAIMealPlanUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GenerateAIMealPlanParams params) async {
    return await repository.generateAIMealPlan(params.userId, params.preferences);
  }
}

class GenerateAIMealPlanParams {
  final String userId;
  final Map<String, dynamic> preferences;

  GenerateAIMealPlanParams({required this.userId, required this.preferences});
}

// Sync Meals Data Use Case
@injectable
class SyncMealsDataUseCase implements UseCase<bool, String> {
  final MealsRepository repository;

  SyncMealsDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncMealsData(userId);
  }
}

// Calculate Nutrition Score Use Case
@injectable
class CalculateNutritionScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final MealsRepository repository;

  CalculateNutritionScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final mealPlansResult = await repository.getUserMealPlans(userId);
      
      return mealPlansResult.fold(
        (failure) => Left(failure),
        (mealPlans) {
          final nutritionScore = _calculateNutritionScore(mealPlans);
          return Right(nutritionScore);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate nutrition score: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateNutritionScore(List<MealPlanEntity> mealPlans) {
    if (mealPlans.isEmpty) {
      return {
        'nutrition_score': 50,
        'variety_score': 0,
        'balance_score': 0,
        'health_score': 0,
        'meal_frequency': 0,
        'grade': 'No Data',
        'recommendations': [
          'Start tracking your meals to get nutrition insights',
          'Create a meal plan for better nutrition management'
        ],
      };
    }
    
    // Analyze recent meal plans (last 30 days)
    final recentPlans = mealPlans.where((plan) => 
        plan.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).toList();
    
    if (recentPlans.isEmpty) {
      return {
        'nutrition_score': 25,
        'variety_score': 0,
        'balance_score': 0,
        'health_score': 0,
        'meal_frequency': 0,
        'grade': 'Inactive',
        'recommendations': ['Create recent meal plans to track nutrition'],
      };
    }
    
    // Calculate variety score
    final varietyScore = _calculateVarietyScore(recentPlans);
    
    // Calculate balance score
    final balanceScore = _calculateBalanceScore(recentPlans);
    
    // Calculate health score
    final healthScore = _calculateHealthScore(recentPlans);
    
    // Calculate meal frequency
    final mealFrequency = _calculateMealFrequency(recentPlans);
    
    // Overall nutrition score (weighted average)
    final nutritionScore = (
      (varietyScore * 0.25) + // 25% variety
      (balanceScore * 0.30) + // 30% balance
      (healthScore * 0.30) + // 30% health
      (mealFrequency * 0.15) // 15% frequency
    ).round();
    
    final grade = _getNutritionGrade(nutritionScore);
    final recommendations = _generateNutritionRecommendations(
      varietyScore, balanceScore, healthScore, mealFrequency, recentPlans
    );
    
    return {
      'nutrition_score': nutritionScore,
      'variety_score': varietyScore.round(),
      'balance_score': balanceScore.round(),
      'health_score': healthScore.round(),
      'meal_frequency': mealFrequency.round(),
      'grade': grade,
      'meal_plans_analyzed': recentPlans.length,
      'total_meals': recentPlans.fold<int>(0, (sum, plan) => sum + plan.meals.length),
      'recommendations': recommendations,
    };
  }

  double _calculateVarietyScore(List<MealPlanEntity> mealPlans) {
    final ingredientsSet = <String>{};
    final cuisineTypes = <String>{};
    
    for (final plan in mealPlans) {
      for (final meal in plan.meals) {
        // Collect unique ingredients
        for (final ingredient in meal.ingredients) {
          ingredientsSet.add(ingredient.name.toLowerCase());
        }
        
        // Collect cuisine types
        if (meal.cuisineType != null) {
          cuisineTypes.add(meal.cuisineType!);
        }
      }
    }
    
    // Score based on ingredient variety and cuisine diversity
    final ingredientVariety = (ingredientsSet.length / 50.0).clamp(0, 1) * 70; // Max 70 points
    final cuisineVariety = (cuisineTypes.length / 8.0).clamp(0, 1) * 30; // Max 30 points
    
    return ingredientVariety + cuisineVariety;
  }

  double _calculateBalanceScore(List<MealPlanEntity> mealPlans) {
    var totalCalories = 0.0;
    var totalProtein = 0.0;
    var totalCarbs = 0.0;
    var totalFat = 0.0;
    var mealCount = 0;
    
    for (final plan in mealPlans) {
      for (final meal in plan.meals) {
        totalCalories += meal.calories ?? 0;
        totalProtein += meal.protein ?? 0;
        totalCarbs += meal.carbohydrates ?? 0;
        totalFat += meal.fat ?? 0;
        mealCount++;
      }
    }
    
    if (mealCount == 0 || totalCalories == 0) return 0;
    
    // Calculate macronutrient percentages
    final proteinPercent = (totalProtein * 4) / totalCalories; // 4 cal per gram
    final carbPercent = (totalCarbs * 4) / totalCalories;
    final fatPercent = (totalFat * 9) / totalCalories; // 9 cal per gram
    
    // Ideal ranges: Protein 10-35%, Carbs 45-65%, Fat 20-35%
    final proteinScore = _getPercentageScore(proteinPercent * 100, 10, 35);
    final carbScore = _getPercentageScore(carbPercent * 100, 45, 65);
    final fatScore = _getPercentageScore(fatPercent * 100, 20, 35);
    
    return (proteinScore + carbScore + fatScore) / 3 * 100;
  }

  double _getPercentageScore(double value, double min, double max) {
    if (value >= min && value <= max) return 1.0;
    if (value < min) return (value / min).clamp(0, 1);
    if (value > max) return (max / value).clamp(0, 1);
    return 0.0;
  }

  double _calculateHealthScore(List<MealPlanEntity> mealPlans) {
    var healthyMeals = 0;
    var totalMeals = 0;
    
    for (final plan in mealPlans) {
      for (final meal in plan.meals) {
        totalMeals++;
        
        // Simple health scoring based on ingredients and preparation
        var healthPoints = 0;
        
        // Check for healthy ingredients
        for (final ingredient in meal.ingredients) {
          final name = ingredient.name.toLowerCase();
          if (_isHealthyIngredient(name)) healthPoints++;
          if (_isUnhealthyIngredient(name)) healthPoints--;
        }
        
        // Check preparation method
        final prepMethod = meal.preparationMethod?.toLowerCase() ?? '';
        if (['grilled', 'baked', 'steamed', 'roasted'].contains(prepMethod)) {
          healthPoints += 2;
        } else if (['fried', 'deep-fried'].contains(prepMethod)) {
          healthPoints -= 2;
        }
        
        if (healthPoints > 0) healthyMeals++;
      }
    }
    
    return totalMeals > 0 ? (healthyMeals / totalMeals) * 100 : 0;
  }

  bool _isHealthyIngredient(String ingredient) {
    final healthyIngredients = {
      'vegetables', 'fruits', 'whole grain', 'quinoa', 'brown rice',
      'salmon', 'chicken breast', 'legumes', 'beans', 'lentils',
      'nuts', 'seeds', 'olive oil', 'avocado', 'spinach', 'broccoli'
    };
    
    return healthyIngredients.any((healthy) => ingredient.contains(healthy));
  }

  bool _isUnhealthyIngredient(String ingredient) {
    final unhealthyIngredients = {
      'processed meat', 'bacon', 'sausage', 'white bread', 'sugar',
      'high fructose', 'trans fat', 'hydrogenated oil'
    };
    
    return unhealthyIngredients.any((unhealthy) => ingredient.contains(unhealthy));
  }

  double _calculateMealFrequency(List<MealPlanEntity> mealPlans) {
    final mealsByDay = <String, int>{};
    
    for (final plan in mealPlans) {
      final dateKey = _formatDateKey(plan.createdAt);
      mealsByDay[dateKey] = (mealsByDay[dateKey] ?? 0) + plan.meals.length;
    }
    
    if (mealsByDay.isEmpty) return 0;
    
    final avgMealsPerDay = mealsByDay.values.reduce((a, b) => a + b) / mealsByDay.length;
    
    // Ideal: 3-4 meals per day
    if (avgMealsPerDay >= 3 && avgMealsPerDay <= 4) return 100;
    if (avgMealsPerDay >= 2 && avgMealsPerDay < 3) return 80;
    if (avgMealsPerDay >= 1 && avgMealsPerDay < 2) return 60;
    return 40;
  }

  String _getNutritionGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  List<String> _generateNutritionRecommendations(
    double variety, 
    double balance, 
    double health, 
    double frequency,
    List<MealPlanEntity> mealPlans
  ) {
    final recommendations = <String>[];
    
    if (variety < 60) {
      recommendations.add('Try incorporating more diverse ingredients and cuisines into your meals');
    }
    
    if (balance < 70) {
      recommendations.add('Focus on balanced macronutrients: aim for 45-65% carbs, 10-35% protein, 20-35% fat');
    }
    
    if (health < 70) {
      recommendations.add('Choose more whole foods and healthier cooking methods like grilling or steaming');
    }
    
    if (frequency < 80) {
      recommendations.add('Aim for 3-4 balanced meals per day for optimal nutrition');
    }
    
    recommendations.addAll([
      'Include more colorful fruits and vegetables in your meals',
      'Stay hydrated and consider meal prep for consistency',
      'Consult a nutritionist for personalized dietary advice',
    ]);
    
    return recommendations.take(5).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Get Meal Prep Insights Use Case
@injectable
class GetMealPrepInsightsUseCase implements UseCase<Map<String, dynamic>, String> {
  final MealsRepository repository;

  GetMealPrepInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final mealPlansResult = await repository.getUserMealPlans(userId);
      final recipesResult = await repository.getUserRecipes(userId);
      
      return mealPlansResult.fold(
        (failure) => Left(failure),
        (mealPlans) async {
          final recipes = await recipesResult.fold(
            (failure) => <RecipeEntity>[],
            (recipeList) => recipeList,
          );
          
          final insights = _generateMealPrepInsights(mealPlans, recipes);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate meal prep insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateMealPrepInsights(List<MealPlanEntity> mealPlans, List<RecipeEntity> recipes) {
    final insights = <String>[];
    final suggestions = <String>[];
    
    if (mealPlans.isEmpty && recipes.isEmpty) {
      return {
        'insights': ['Start creating meal plans and recipes to get preparation insights'],
        'prep_time_analysis': {},
        'ingredient_optimization': {},
        'suggestions': [
          'Plan meals for the week to save time and money',
          'Batch cook proteins and grains for multiple meals',
          'Prep vegetables in advance for quick cooking'
        ],
      };
    }
    
    // Analyze preparation times
    final prepTimeAnalysis = _analyzePrepTimes(recipes);
    insights.add('Average meal prep time: ${prepTimeAnalysis['average_prep_time']} minutes');
    
    // Analyze ingredient overlap
    final ingredientOptimization = _analyzeIngredientOptimization(mealPlans, recipes);
    if (ingredientOptimization['overlap_percentage'] > 60) {
      insights.add('Good ingredient overlap - efficient shopping and less waste');
    } else {
      insights.add('Consider recipes with overlapping ingredients for efficiency');
    }
    
    // Generate suggestions
    suggestions.addAll([
      'Prep ingredients on Sunday for the week ahead',
      'Use a slow cooker for hands-off meal preparation',
      'Freeze pre-portioned meals for busy days',
      'Keep a well-stocked pantry of staple ingredients',
    ]);
    
    return {
      'insights': insights,
      'prep_time_analysis': prepTimeAnalysis,
      'ingredient_optimization': ingredientOptimization,
      'suggestions': suggestions,
      'meal_plans_analyzed': mealPlans.length,
      'recipes_analyzed': recipes.length,
    };
  }

  Map<String, dynamic> _analyzePrepTimes(List<RecipeEntity> recipes) {
    if (recipes.isEmpty) {
      return {
        'average_prep_time': 0,
        'quick_recipes': 0,
        'time_intensive_recipes': 0,
      };
    }
    
    final prepTimes = recipes.map((r) => r.prepTime ?? 30).toList();
    final avgPrepTime = prepTimes.reduce((a, b) => a + b) / prepTimes.length;
    
    final quickRecipes = recipes.where((r) => (r.prepTime ?? 30) <= 15).length;
    final timeIntensiveRecipes = recipes.where((r) => (r.prepTime ?? 30) >= 60).length;
    
    return {
      'average_prep_time': avgPrepTime.round(),
      'quick_recipes': quickRecipes,
      'time_intensive_recipes': timeIntensiveRecipes,
      'total_recipes': recipes.length,
    };
  }

  Map<String, dynamic> _analyzeIngredientOptimization(List<MealPlanEntity> mealPlans, List<RecipeEntity> recipes) {
    final allIngredients = <String>{};
    final ingredientFrequency = <String, int>{};
    
    // Collect ingredients from meal plans
    for (final plan in mealPlans) {
      for (final meal in plan.meals) {
        for (final ingredient in meal.ingredients) {
          final name = ingredient.name.toLowerCase();
          allIngredients.add(name);
          ingredientFrequency[name] = (ingredientFrequency[name] ?? 0) + 1;
        }
      }
    }
    
    // Collect ingredients from recipes
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final name = ingredient.name.toLowerCase();
        allIngredients.add(name);
        ingredientFrequency[name] = (ingredientFrequency[name] ?? 0) + 1;
      }
    }
    
    final overlappingIngredients = ingredientFrequency.entries
        .where((entry) => entry.value > 1)
        .toList();
    
    final overlapPercentage = allIngredients.isNotEmpty 
        ? (overlappingIngredients.length / allIngredients.length) * 100 
        : 0;
    
    return {
      'total_unique_ingredients': allIngredients.length,
      'overlapping_ingredients': overlappingIngredients.length,
      'overlap_percentage': overlapPercentage.round(),
      'most_used_ingredients': ingredientFrequency.entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5)
        .map((e) => {'ingredient': e.key, 'frequency': e.value})
        .toList(),
    };
  }
}
