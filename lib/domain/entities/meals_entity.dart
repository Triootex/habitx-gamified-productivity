import 'package:equatable/equatable.dart';

class MealPlanEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String planType; // weekly, monthly, custom
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // Dietary preferences
  final String dietType; // standard, vegetarian, vegan, keto, etc.
  final List<String> allergies;
  final List<String> dislikes;
  final List<String> preferences;
  final Map<String, double> nutritionGoals; // calories, protein, carbs, fat, fiber
  
  // Meal planning
  final Map<String, List<MealEntity>> weeklyMeals; // day -> meals
  final List<String> groceryList;
  final double estimatedCost;
  final int servingSize;
  final bool includeSnacks;
  
  // AI and automation
  final bool isAIGenerated;
  final Map<String, dynamic> aiPreferences;
  final bool autoGenerateGroceryList;
  final bool optimizeForBudget;
  final bool optimizeForTime;
  
  // Tracking and analytics
  final Map<String, double> actualNutrition; // tracked nutrition
  final List<String> completedMeals;
  final double adherenceRate;
  final Map<String, dynamic> progressMetrics;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MealPlanEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.planType = 'weekly',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.dietType = 'standard',
    this.allergies = const [],
    this.dislikes = const [],
    this.preferences = const [],
    this.nutritionGoals = const {},
    this.weeklyMeals = const {},
    this.groceryList = const [],
    this.estimatedCost = 0.0,
    this.servingSize = 2,
    this.includeSnacks = true,
    this.isAIGenerated = false,
    this.aiPreferences = const {},
    this.autoGenerateGroceryList = true,
    this.optimizeForBudget = false,
    this.optimizeForTime = false,
    this.actualNutrition = const {},
    this.completedMeals = const [],
    this.adherenceRate = 0.0,
    this.progressMetrics = const {},
    required this.createdAt,
    this.updatedAt,
  });

  int get totalMeals => weeklyMeals.values.fold<int>(0, (sum, meals) => sum + meals.length);
  bool get meetsNutritionGoals => _checkNutritionGoals();
  
  bool _checkNutritionGoals() {
    if (nutritionGoals.isEmpty || actualNutrition.isEmpty) return false;
    return nutritionGoals.entries.every((goal) {
      final actual = actualNutrition[goal.key] ?? 0.0;
      return actual >= goal.value * 0.8; // 80% tolerance
    });
  }

  MealPlanEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? planType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? dietType,
    List<String>? allergies,
    List<String>? dislikes,
    List<String>? preferences,
    Map<String, double>? nutritionGoals,
    Map<String, List<MealEntity>>? weeklyMeals,
    List<String>? groceryList,
    double? estimatedCost,
    int? servingSize,
    bool? includeSnacks,
    bool? isAIGenerated,
    Map<String, dynamic>? aiPreferences,
    bool? autoGenerateGroceryList,
    bool? optimizeForBudget,
    bool? optimizeForTime,
    Map<String, double>? actualNutrition,
    List<String>? completedMeals,
    double? adherenceRate,
    Map<String, dynamic>? progressMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlanEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      dislikes: dislikes ?? this.dislikes,
      preferences: preferences ?? this.preferences,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      weeklyMeals: weeklyMeals ?? this.weeklyMeals,
      groceryList: groceryList ?? this.groceryList,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      servingSize: servingSize ?? this.servingSize,
      includeSnacks: includeSnacks ?? this.includeSnacks,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      aiPreferences: aiPreferences ?? this.aiPreferences,
      autoGenerateGroceryList: autoGenerateGroceryList ?? this.autoGenerateGroceryList,
      optimizeForBudget: optimizeForBudget ?? this.optimizeForBudget,
      optimizeForTime: optimizeForTime ?? this.optimizeForTime,
      actualNutrition: actualNutrition ?? this.actualNutrition,
      completedMeals: completedMeals ?? this.completedMeals,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      progressMetrics: progressMetrics ?? this.progressMetrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        planType,
        startDate,
        endDate,
        isActive,
        dietType,
        allergies,
        dislikes,
        preferences,
        nutritionGoals,
        weeklyMeals,
        groceryList,
        estimatedCost,
        servingSize,
        includeSnacks,
        isAIGenerated,
        aiPreferences,
        autoGenerateGroceryList,
        optimizeForBudget,
        optimizeForTime,
        actualNutrition,
        completedMeals,
        adherenceRate,
        progressMetrics,
        createdAt,
        updatedAt,
      ];
}

class MealEntity extends Equatable {
  final String id;
  final String? planId;
  final String userId;
  final String name;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? description;
  final List<IngredientEntity> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // easy, medium, hard
  
  // Nutritional information
  final Map<String, double> nutrition; // per serving
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  
  // Recipe details
  final String? cuisine;
  final List<String> tags;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> equipment;
  final String source; // ai_generated, user_created, imported
  
  // Ratings and reviews
  final double rating;
  final int ratingCount;
  final List<String> reviews;
  final bool isFavorite;
  final int timesCooked;
  
  // Variations and substitutions
  final List<String> variations;
  final Map<String, String> substitutions;
  final Map<String, String> dietaryAdaptations;
  
  // Meal prep
  final bool isMealPrepFriendly;
  final int storageLifeDays;
  final List<String> mealPrepInstructions;
  final bool canFreeze;
  
  final DateTime createdAt;
  final DateTime? lastCooked;
  final DateTime? updatedAt;

  const MealEntity({
    required this.id,
    this.planId,
    required this.userId,
    required this.name,
    required this.mealType,
    this.description,
    this.ingredients = const [],
    this.instructions = const [],
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 2,
    this.difficulty = 'medium',
    this.nutrition = const {},
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.cuisine,
    this.tags = const [],
    this.imageUrl,
    this.videoUrl,
    this.equipment = const [],
    this.source = 'user_created',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reviews = const [],
    this.isFavorite = false,
    this.timesCooked = 0,
    this.variations = const [],
    this.substitutions = const {},
    this.dietaryAdaptations = const {},
    this.isMealPrepFriendly = false,
    this.storageLifeDays = 3,
    this.mealPrepInstructions = const [],
    this.canFreeze = false,
    required this.createdAt,
    this.lastCooked,
    this.updatedAt,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
  bool get isQuickMeal => totalTimeMinutes <= 30;
  bool get isHealthy => _calculateHealthScore() >= 7.0;
  
  double _calculateHealthScore() {
    double score = 5.0; // Base score
    
    if (fiber >= 5) score += 1.0; // High fiber
    if (protein >= 15) score += 1.0; // Good protein
    if (sodium <= 600) score += 1.0; // Low sodium
    if (sugar <= 10) score += 1.0; // Low sugar
    if (tags.contains('whole_grains')) score += 0.5;
    if (tags.contains('lean_protein')) score += 0.5;
    
    return score.clamp(0.0, 10.0);
  }

  MealEntity copyWith({
    String? id,
    String? planId,
    String? userId,
    String? name,
    String? mealType,
    String? description,
    List<IngredientEntity>? ingredients,
    List<String>? instructions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    Map<String, double>? nutrition,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    String? cuisine,
    List<String>? tags,
    String? imageUrl,
    String? videoUrl,
    List<String>? equipment,
    String? source,
    double? rating,
    int? ratingCount,
    List<String>? reviews,
    bool? isFavorite,
    int? timesCooked,
    List<String>? variations,
    Map<String, String>? substitutions,
    Map<String, String>? dietaryAdaptations,
    bool? isMealPrepFriendly,
    int? storageLifeDays,
    List<String>? mealPrepInstructions,
    bool? canFreeze,
    DateTime? createdAt,
    DateTime? lastCooked,
    DateTime? updatedAt,
  }) {
    return MealEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      nutrition: nutrition ?? this.nutrition,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      cuisine: cuisine ?? this.cuisine,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      equipment: equipment ?? this.equipment,
      source: source ?? this.source,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      timesCooked: timesCooked ?? this.timesCooked,
      variations: variations ?? this.variations,
      substitutions: substitutions ?? this.substitutions,
      dietaryAdaptations: dietaryAdaptations ?? this.dietaryAdaptations,
      isMealPrepFriendly: isMealPrepFriendly ?? this.isMealPrepFriendly,
      storageLifeDays: storageLifeDays ?? this.storageLifeDays,
      mealPrepInstructions: mealPrepInstructions ?? this.mealPrepInstructions,
      canFreeze: canFreeze ?? this.canFreeze,
      createdAt: createdAt ?? this.createdAt,
      lastCooked: lastCooked ?? this.lastCooked,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planId,
        userId,
        name,
        mealType,
        description,
        ingredients,
        instructions,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        difficulty,
        nutrition,
        calories,
        protein,
        carbs,
        fat,
        fiber,
        sugar,
        sodium,
        cuisine,
        tags,
        imageUrl,
        videoUrl,
        equipment,
        source,
        rating,
        ratingCount,
        reviews,
        isFavorite,
        timesCooked,
        variations,
        substitutions,
        dietaryAdaptations,
        isMealPrepFriendly,
        storageLifeDays,
        mealPrepInstructions,
        canFreeze,
        createdAt,
        lastCooked,
        updatedAt,
      ];
}

class IngredientEntity extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit; // cups, grams, pieces, etc.
  final String? brand;
  final String? notes;
  final bool isOptional;
  final List<String> alternatives;
  final Map<String, double> nutrition; // per unit
  final double? cost; // estimated cost
  final String? barcode;

  const IngredientEntity({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.brand,
    this.notes,
    this.isOptional = false,
    this.alternatives = const [],
    this.nutrition = const {},
    this.cost,
    this.barcode,
  });

  IngredientEntity copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? brand,
    String? notes,
    bool? isOptional,
    List<String>? alternatives,
    Map<String, double>? nutrition,
    double? cost,
    String? barcode,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      isOptional: isOptional ?? this.isOptional,
      alternatives: alternatives ?? this.alternatives,
      nutrition: nutrition ?? this.nutrition,
      cost: cost ?? this.cost,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        unit,
        brand,
        notes,
        isOptional,
        alternatives,
        nutrition,
        cost,
        barcode,
      ];
}

class GroceryListEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<GroceryItemEntity> items;
  final Map<String, List<GroceryItemEntity>> categorizedItems;
  final double estimatedTotal;
  final double actualTotal;
  final String? storeId;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> mealPlanIds; // Associated meal plans

  const GroceryListEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.items = const [],
    this.categorizedItems = const {},
    this.estimatedTotal = 0.0,
    this.actualTotal = 0.0,
    this.storeId,
    this.isCompleted = false,
    this.completedAt,
    this.mealPlanIds = const [],
  });

  int get totalItems => items.length;
  int get checkedItems => items.where((item) => item.isChecked).length;
  double get completionPercentage => totalItems > 0 ? checkedItems / totalItems : 0.0;

  GroceryListEntity copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<GroceryItemEntity>? items,
    Map<String, List<GroceryItemEntity>>? categorizedItems,
    double? estimatedTotal,
    double? actualTotal,
    String? storeId,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? mealPlanIds,
  }) {
    return GroceryListEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
      categorizedItems: categorizedItems ?? this.categorizedItems,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      actualTotal: actualTotal ?? this.actualTotal,
      storeId: storeId ?? this.storeId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      mealPlanIds: mealPlanIds ?? this.mealPlanIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        createdAt,
        updatedAt,
        isActive,
        items,
        categorizedItems,
        estimatedTotal,
        actualTotal,
        storeId,
        isCompleted,
        completedAt,
        mealPlanIds,
      ];
}

class GroceryItemEntity extends Equatable {
  final String id;
  final String listId;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final double? estimatedPrice;
  final double? actualPrice;
  final bool isChecked;
  final DateTime? checkedAt;
  final String? notes;
  final String? brand;
  final bool isUrgent;
  final String? barcode;

  const GroceryItemEntity({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.estimatedPrice,
    this.actualPrice,
    this.isChecked = false,
    this.checkedAt,
    this.notes,
    this.brand,
    this.isUrgent = false,
    this.barcode,
  });

  GroceryItemEntity copyWith({
    String? id,
    String? listId,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    double? estimatedPrice,
    double? actualPrice,
    bool? isChecked,
    DateTime? checkedAt,
    String? notes,
    String? brand,
    bool? isUrgent,
    String? barcode,
  }) {
    return GroceryItemEntity(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      notes: notes ?? this.notes,
      brand: brand ?? this.brand,
      isUrgent: isUrgent ?? this.isUrgent,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        name,
        quantity,
        unit,
        category,
        estimatedPrice,
        actualPrice,
        isChecked,
        checkedAt,
        notes,
        brand,
        isUrgent,
        barcode,
      ];
}

class RecipeEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String cuisine;
  final List<IngredientEntity> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final Map<String, double> nutrition;
  final List<String> tags;
  final String? imageUrl;
  final String? videoUrl;
  final double rating;
  final int ratingCount;
  final bool isPublic;
  final String source; // user_created, ai_generated, imported
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecipeEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.cuisine,
    this.ingredients = const [],
    this.instructions = const [],
    this.prepTime = 0,
    this.cookTime = 0,
    this.servings = 2,
    this.difficulty = 'medium',
    this.nutrition = const {},
    this.tags = const [],
    this.imageUrl,
    this.videoUrl,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isPublic = false,
    this.source = 'user_created',
    required this.createdAt,
    this.updatedAt,
  });

  int get totalTime => prepTime + cookTime;

  RecipeEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? cuisine,
    List<IngredientEntity>? ingredients,
    List<String>? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    Map<String, double>? nutrition,
    List<String>? tags,
    String? imageUrl,
    String? videoUrl,
    double? rating,
    int? ratingCount,
    bool? isPublic,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      cuisine: cuisine ?? this.cuisine,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      nutrition: nutrition ?? this.nutrition,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isPublic: isPublic ?? this.isPublic,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        cuisine,
        ingredients,
        instructions,
        prepTime,
        cookTime,
        servings,
        difficulty,
        nutrition,
        tags,
        imageUrl,
        videoUrl,
        rating,
        ratingCount,
        isPublic,
        source,
        createdAt,
        updatedAt,
      ];
}
