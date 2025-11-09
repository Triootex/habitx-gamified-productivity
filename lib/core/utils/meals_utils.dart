import '../constants/meals_constants.dart';
import 'math_utils.dart';
import 'string_utils.dart';

class MealsUtils {
  /// Calculate nutritional balance score
  static Map<String, dynamic> calculateNutritionalBalance(
    Map<String, double> actualNutrients,
    Map<String, double> targetNutrients,
  ) {
    double totalScore = 0;
    final scores = <String, double>{};
    
    for (final nutrient in targetNutrients.keys) {
      final actual = actualNutrients[nutrient] ?? 0;
      final target = targetNutrients[nutrient] ?? 1;
      
      final ratio = actual / target;
      double score = 0;
      
      if (ratio >= 0.8 && ratio <= 1.2) {
        score = 100; // Perfect range
      } else if (ratio >= 0.6 && ratio <= 1.4) {
        score = 80; // Good range
      } else if (ratio >= 0.4 && ratio <= 1.6) {
        score = 60; // Acceptable
      } else {
        score = math.max(0, 40 - (ratio - 1.0).abs() * 20);
      }
      
      scores[nutrient] = score;
      totalScore += score;
    }
    
    return {
      'overall_score': (totalScore / targetNutrients.length).round(),
      'nutrient_scores': scores,
      'status': _getNutritionalStatus(totalScore / targetNutrients.length),
    };
  }
  
  static String _getNutritionalStatus(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Improvement';
  }
  
  /// Generate meal plan based on preferences and goals
  static List<Map<String, dynamic>> generateMealPlan(
    Map<String, dynamic> userProfile,
    int days,
    String goal,
  ) {
    final mealPlan = <Map<String, dynamic>>[];
    final dietType = userProfile['diet_type'] as String? ?? 'Standard';
    final allergies = userProfile['allergies'] as List<String>? ?? [];
    final calorieTarget = userProfile['daily_calories'] as int? ?? 2000;
    
    for (int day = 0; day < days; day++) {
      final dayMeals = <String, Map<String, dynamic>>{};
      
      // Generate meals for each meal time
      for (final mealTime in ['breakfast', 'lunch', 'dinner', 'snack']) {
        dayMeals[mealTime] = _generateMeal(
          mealTime, dietType, allergies, calorieTarget, goal);
      }
      
      mealPlan.add({
        'day': day + 1,
        'date': DateTime.now().add(Duration(days: day)),
        'meals': dayMeals,
        'total_calories': _calculateTotalCalories(dayMeals),
        'macros': _calculateTotalMacros(dayMeals),
      });
    }
    
    return mealPlan;
  }
  
  static Map<String, dynamic> _generateMeal(
    String mealTime,
    String dietType, 
    List<String> allergies,
    int dailyCalories,
    String goal,
  ) {
    final calorieDistribution = {
      'breakfast': 0.25,
      'lunch': 0.35,
      'dinner': 0.30,
      'snack': 0.10,
    };
    
    final targetCalories = (dailyCalories * calorieDistribution[mealTime]!).round();
    
    return {
      'name': _generateMealName(mealTime, dietType),
      'ingredients': _generateIngredients(mealTime, dietType, allergies),
      'calories': targetCalories,
      'prep_time': _getEstimatedPrepTime(mealTime),
      'difficulty': _getMealDifficulty(mealTime),
      'macros': _calculateMealMacros(targetCalories, goal),
    };
  }
  
  static String _generateMealName(String mealTime, String dietType) {
    final mealNames = {
      'breakfast': ['Protein Scramble', 'Overnight Oats', 'Avocado Toast'],
      'lunch': ['Power Bowl', 'Grilled Chicken Salad', 'Quinoa Bowl'],
      'dinner': ['Baked Salmon', 'Stir-fry Vegetables', 'Lean Protein Plate'],
      'snack': ['Greek Yogurt', 'Mixed Nuts', 'Fruit Bowl'],
    };
    
    final options = mealNames[mealTime] ?? ['Healthy Meal'];
    return options[MathUtils.randomInt(0, options.length - 1)];
  }
  
  static List<Map<String, dynamic>> _generateIngredients(
    String mealTime,
    String dietType,
    List<String> allergies,
  ) {
    // Mock ingredient generation based on meal time and diet
    final ingredients = <Map<String, dynamic>>[];
    
    if (mealTime == 'breakfast') {
      ingredients.addAll([
        {'name': 'Eggs', 'quantity': 2, 'unit': 'pieces'},
        {'name': 'Spinach', 'quantity': 50, 'unit': 'g'},
        {'name': 'Whole Grain Toast', 'quantity': 1, 'unit': 'slice'},
      ]);
    }
    
    return ingredients.where((ingredient) => 
        !allergies.contains(ingredient['name'])).toList();
  }
  
  static int _getEstimatedPrepTime(String mealTime) {
    switch (mealTime) {
      case 'breakfast': return 10;
      case 'lunch': return 20;
      case 'dinner': return 30;
      case 'snack': return 5;
      default: return 15;
    }
  }
  
  static String _getMealDifficulty(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
      case 'snack': return 'easy';
      case 'lunch': return 'medium';
      case 'dinner': return 'medium';
      default: return 'easy';
    }
  }
  
  static Map<String, double> _calculateMealMacros(int calories, String goal) {
    // Adjust macro distribution based on goal
    Map<String, double> ratios;
    
    switch (goal) {
      case 'weight_loss':
        ratios = {'protein': 0.30, 'carbs': 0.35, 'fat': 0.35};
        break;
      case 'muscle_gain':
        ratios = {'protein': 0.35, 'carbs': 0.40, 'fat': 0.25};
        break;
      default:
        ratios = {'protein': 0.25, 'carbs': 0.45, 'fat': 0.30};
    }
    
    return {
      'protein': (calories * ratios['protein']!) / 4, // 4 cal/g
      'carbs': (calories * ratios['carbs']!) / 4, // 4 cal/g  
      'fat': (calories * ratios['fat']!) / 9, // 9 cal/g
    };
  }
  
  static int _calculateTotalCalories(Map<String, Map<String, dynamic>> meals) {
    return meals.values.fold<int>(0, 
        (sum, meal) => sum + (meal['calories'] as int? ?? 0));
  }
  
  static Map<String, double> _calculateTotalMacros(Map<String, Map<String, dynamic>> meals) {
    final totals = {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
    
    for (final meal in meals.values) {
      final macros = meal['macros'] as Map<String, double>? ?? {};
      for (final macro in totals.keys) {
        totals[macro] = totals[macro]! + (macros[macro] ?? 0);
      }
    }
    
    return totals;
  }
  
  /// Scan barcode and get nutrition info
  static Map<String, dynamic> processScannedBarcode(
    String barcode,
    Map<String, dynamic> productDatabase,
  ) {
    // Mock barcode processing
    final product = productDatabase[barcode] ?? _generateMockProduct(barcode);
    
    return {
      'barcode': barcode,
      'product_name': product['name'],
      'brand': product['brand'],
      'nutrition_per_100g': product['nutrition'],
      'ingredients': product['ingredients'],
      'allergens': product['allergens'],
      'category': _categorizeProduct(product['name'] as String),
      'health_score': _calculateHealthScore(product['nutrition'] as Map<String, double>),
    };
  }
  
  static Map<String, dynamic> _generateMockProduct(String barcode) {
    return {
      'name': 'Product ${barcode.substring(0, 6)}',
      'brand': 'Brand Name',
      'nutrition': {
        'calories': 250.0,
        'protein': 8.0,
        'carbs': 35.0,
        'fat': 12.0,
        'fiber': 3.0,
        'sugar': 8.0,
        'sodium': 400.0,
      },
      'ingredients': ['Wheat flour', 'Sugar', 'Oil'],
      'allergens': ['Gluten'],
    };
  }
  
  static String _categorizeProduct(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('milk') || name.contains('yogurt')) return 'dairy';
    if (name.contains('bread') || name.contains('cereal')) return 'grains';
    if (name.contains('fruit') || name.contains('apple')) return 'fruits';
    return 'processed';
  }
  
  static int _calculateHealthScore(Map<String, double> nutrition) {
    int score = 50; // Base score
    
    final protein = nutrition['protein'] ?? 0;
    final fiber = nutrition['fiber'] ?? 0;
    final sugar = nutrition['sugar'] ?? 0;
    final sodium = nutrition['sodium'] ?? 0;
    
    // Positive factors
    if (protein > 10) score += 15;
    if (fiber > 5) score += 10;
    
    // Negative factors
    if (sugar > 15) score -= 15;
    if (sodium > 600) score -= 10;
    
    return score.clamp(0, 100);
  }
  
  /// Validate meal data
  static Map<String, String?> validateMealData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final calories = data['calories'] as int?;
    if (calories != null && (calories < 50 || calories > 2000)) {
      errors['calories'] = 'Calories per meal should be between 50 and 2000';
    }
    
    final prepTime = data['prep_time'] as int?;
    if (prepTime != null && prepTime > MealsConstants.maxCookingTime) {
      errors['prep_time'] = 'Preparation time is too long';
    }
    
    return errors;
  }
}
