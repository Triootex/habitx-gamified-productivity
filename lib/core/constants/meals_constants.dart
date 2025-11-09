class MealsConstants {
  // Meal Types
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String snack = 'snack';
  static const String dessert = 'dessert';
  
  // Diet Types
  static const List<Map<String, dynamic>> dietTypes = [
    {'name': 'Standard', 'restrictions': [], 'color': '#3498DB'},
    {'name': 'Vegetarian', 'restrictions': ['meat', 'fish'], 'color': '#2ECC71'},
    {'name': 'Vegan', 'restrictions': ['meat', 'fish', 'dairy', 'eggs'], 'color': '#27AE60'},
    {'name': 'Keto', 'macros': {'carbs': 5, 'protein': 25, 'fat': 70}, 'color': '#E74C3C'},
    {'name': 'Paleo', 'restrictions': ['grains', 'dairy', 'legumes'], 'color': '#F39C12'},
    {'name': 'Mediterranean', 'emphasis': ['fish', 'olive_oil', 'vegetables'], 'color': '#3498DB'},
    {'name': 'Gluten-Free', 'restrictions': ['gluten'], 'color': '#9B59B6'},
    {'name': 'Dairy-Free', 'restrictions': ['dairy'], 'color': '#1ABC9C'},
  ];
  
  // Nutrition Goals
  static const Map<String, Map<String, dynamic>> nutritionGoals = {
    'calories': {
      'unit': 'kcal',
      'daily_targets': {
        'sedentary_male': 2200,
        'sedentary_female': 1800,
        'active_male': 2800,
        'active_female': 2200,
      },
    },
    'protein': {
      'unit': 'g',
      'calculation': 'body_weight_kg * 0.8', // minimum
      'percentage_of_calories': 25,
    },
    'carbs': {
      'unit': 'g',
      'calculation': 'total_calories * 0.45 / 4',
      'percentage_of_calories': 45,
    },
    'fat': {
      'unit': 'g',
      'calculation': 'total_calories * 0.30 / 9',
      'percentage_of_calories': 30,
    },
    'fiber': {
      'unit': 'g',
      'daily_target': 25, // for women, 38 for men
    },
    'water': {
      'unit': 'ml',
      'daily_target': 2000, // 8 glasses
    },
  };
  
  // Auto Grocery List Categories
  static const List<Map<String, dynamic>> groceryCategories = [
    {
      'name': 'Produce',
      'items': ['fruits', 'vegetables', 'herbs'],
      'icon': 'eco',
      'color': '#4CAF50',
    },
    {
      'name': 'Proteins',
      'items': ['meat', 'fish', 'poultry', 'eggs', 'tofu'],
      'icon': 'fitness_center',
      'color': '#E74C3C',
    },
    {
      'name': 'Dairy',
      'items': ['milk', 'cheese', 'yogurt', 'butter'],
      'icon': 'local_drink',
      'color': '#F1C40F',
    },
    {
      'name': 'Grains',
      'items': ['bread', 'rice', 'pasta', 'cereals'],
      'icon': 'grain',
      'color': '#D4A574',
    },
    {
      'name': 'Pantry',
      'items': ['spices', 'oils', 'canned_goods', 'condiments'],
      'icon': 'inventory',
      'color': '#8E44AD',
    },
    {
      'name': 'Frozen',
      'items': ['frozen_vegetables', 'frozen_fruits', 'ice_cream'],
      'icon': 'ac_unit',
      'color': '#3498DB',
    },
  ];
  
  // AI Meal Planning Features
  static const Map<String, dynamic> aiMealPlanning = {
    'personalization_factors': [
      'dietary_preferences',
      'allergies',
      'cooking_skill_level',
      'time_constraints',
      'budget',
      'nutrition_goals',
      'family_size',
    ],
    'planning_types': [
      'daily_meals',
      'weekly_meal_prep',
      'monthly_planning',
      'special_occasions',
    ],
    'optimization_criteria': [
      'nutrition_balance',
      'cost_effectiveness',
      'cooking_time',
      'ingredient_overlap',
      'seasonal_availability',
    ],
  };
  
  // Barcode Scanner Features
  static const Map<String, dynamic> barcodeFeatures = {
    'supported_databases': [
      'usda_food_database',
      'edamam_api',
      'spoonacular_api',
      'nutritionix_api',
    ],
    'scan_types': [
      'nutrition_facts',
      'ingredient_list',
      'allergen_information',
      'product_details',
    ],
    'auto_actions': [
      'add_to_food_log',
      'check_diet_compatibility',
      'suggest_alternatives',
      'add_to_grocery_list',
    ],
  };
  
  // Recipe Variations
  static const List<Map<String, dynamic>> recipeVariations = [
    {
      'type': 'dietary_adaptations',
      'variations': [
        'make_vegetarian',
        'make_vegan',
        'make_gluten_free',
        'make_dairy_free',
        'make_low_carb',
        'make_keto_friendly',
      ],
    },
    {
      'type': 'cooking_methods',
      'variations': [
        'air_fryer_version',
        'slow_cooker_version',
        'instant_pot_version',
        'oven_baked_version',
        'stovetop_version',
      ],
    },
    {
      'type': 'serving_sizes',
      'variations': [
        'single_serving',
        'family_size',
        'meal_prep_portions',
        'party_size',
      ],
    },
    {
      'type': 'spice_levels',
      'variations': [
        'mild',
        'medium',
        'spicy',
        'extra_hot',
      ],
    },
  ];
  
  // Meal Prep Templates
  static const List<Map<String, dynamic>> mealPrepTemplates = [
    {
      'name': 'Protein + Veggie Bowls',
      'components': [
        {'type': 'protein', 'options': ['chicken', 'beef', 'tofu', 'fish']},
        {'type': 'vegetables', 'options': ['broccoli', 'carrots', 'bell_peppers']},
        {'type': 'carbs', 'options': ['rice', 'quinoa', 'sweet_potato']},
        {'type': 'sauce', 'options': ['teriyaki', 'curry', 'garlic_herb']},
      ],
      'prep_time': 60,
      'servings': 5,
    },
    {
      'name': 'Breakfast Prep',
      'components': [
        {'type': 'base', 'options': ['overnight_oats', 'egg_muffins', 'smoothie_packs']},
        {'type': 'protein', 'options': ['greek_yogurt', 'protein_powder', 'eggs']},
        {'type': 'fruits', 'options': ['berries', 'banana', 'apple']},
        {'type': 'nuts_seeds', 'options': ['almonds', 'chia_seeds', 'walnuts']},
      ],
      'prep_time': 30,
      'servings': 7,
    },
  ];
  
  // Cooking Skill Levels
  static const Map<String, Map<String, dynamic>> skillLevels = {
    'beginner': {
      'max_cook_time': 30,
      'techniques': ['boiling', 'baking', 'simple_sauteing'],
      'equipment': ['basic_pots_pans', 'oven', 'stovetop'],
    },
    'intermediate': {
      'max_cook_time': 60,
      'techniques': ['roasting', 'braising', 'stir_frying', 'grilling'],
      'equipment': ['food_processor', 'stand_mixer', 'cast_iron'],
    },
    'advanced': {
      'max_cook_time': 120,
      'techniques': ['sous_vide', 'fermentation', 'bread_making'],
      'equipment': ['immersion_blender', 'mandoline', 'smoking_equipment'],
    },
  };
  
  // Nutritional Analysis
  static const List<String> nutritionalMetrics = [
    'calories_per_serving',
    'macronutrient_breakdown',
    'vitamin_content',
    'mineral_content',
    'fiber_content',
    'sugar_content',
    'sodium_levels',
    'cholesterol_content',
  ];
  
  // Food Allergies and Restrictions
  static const List<Map<String, dynamic>> commonAllergies = [
    {'name': 'Peanuts', 'severity': 'high', 'alternatives': ['sunflower_seeds', 'pumpkin_seeds']},
    {'name': 'Tree Nuts', 'severity': 'high', 'alternatives': ['seeds', 'coconut']},
    {'name': 'Dairy', 'severity': 'medium', 'alternatives': ['almond_milk', 'coconut_milk']},
    {'name': 'Eggs', 'severity': 'medium', 'alternatives': ['flax_eggs', 'aquafaba']},
    {'name': 'Gluten', 'severity': 'medium', 'alternatives': ['rice_flour', 'almond_flour']},
    {'name': 'Soy', 'severity': 'medium', 'alternatives': ['coconut_aminos', 'tahini']},
    {'name': 'Shellfish', 'severity': 'high', 'alternatives': ['fish', 'plant_proteins']},
    {'name': 'Fish', 'severity': 'high', 'alternatives': ['algae_oil', 'flaxseed']},
  ];
  
  // Seasonal Ingredients
  static const Map<String, List<String>> seasonalProduce = {
    'spring': [
      'asparagus', 'artichokes', 'peas', 'spinach', 'strawberries',
      'radishes', 'lettuce', 'green_onions', 'rhubarb',
    ],
    'summer': [
      'tomatoes', 'corn', 'zucchini', 'bell_peppers', 'berries',
      'peaches', 'melons', 'cucumbers', 'eggplant',
    ],
    'fall': [
      'pumpkins', 'squash', 'apples', 'pears', 'sweet_potatoes',
      'brussels_sprouts', 'cauliflower', 'cranberries',
    ],
    'winter': [
      'citrus_fruits', 'root_vegetables', 'kale', 'cabbage',
      'pomegranates', 'winter_squash', 'leeks',
    ],
  };
  
  // Custom Grocery Filters
  static const List<Map<String, dynamic>> groceryFilters = [
    {
      'name': 'Budget',
      'type': 'price_range',
      'options': ['budget_friendly', 'mid_range', 'premium'],
    },
    {
      'name': 'Preparation Time',
      'type': 'time_range',
      'options': ['quick_15min', 'medium_30min', 'long_60min'],
    },
    {
      'name': 'Store Section',
      'type': 'category',
      'options': ['produce', 'dairy', 'meat', 'pantry', 'frozen'],
    },
    {
      'name': 'Organic',
      'type': 'boolean',
      'options': ['organic_only', 'conventional_ok'],
    },
    {
      'name': 'Local',
      'type': 'boolean',
      'options': ['local_preferred', 'any_source'],
    },
  ];
  
  // Meal Timing
  static const Map<String, Map<String, dynamic>> mealTiming = {
    'breakfast': {'default_time': '07:00', 'window': 2}, // 2 hour window
    'lunch': {'default_time': '12:00', 'window': 2},
    'dinner': {'default_time': '18:00', 'window': 3},
    'snack_morning': {'default_time': '10:00', 'window': 1},
    'snack_afternoon': {'default_time': '15:00', 'window': 1},
  };
  
  // Recipe Difficulty Levels
  static const Map<String, Map<String, dynamic>> recipeDifficulty = {
    'easy': {
      'prep_time_max': 15,
      'cook_time_max': 30,
      'techniques': ['chopping', 'mixing', 'boiling'],
      'equipment': ['knife', 'pot', 'pan'],
    },
    'medium': {
      'prep_time_max': 30,
      'cook_time_max': 60,
      'techniques': ['sauteing', 'roasting', 'marinating'],
      'equipment': ['food_processor', 'thermometer'],
    },
    'hard': {
      'prep_time_max': 60,
      'cook_time_max': 120,
      'techniques': ['braising', 'sauce_making', 'timing_coordination'],
      'equipment': ['stand_mixer', 'specialty_tools'],
    },
  };
  
  // Smart Shopping Lists
  static const Map<String, dynamic> smartShoppingFeatures = {
    'auto_categorization': true,
    'store_layout_optimization': true,
    'price_tracking': true,
    'coupon_integration': true,
    'quantity_suggestions': true,
    'substitution_recommendations': true,
  };
  
  // Meal Rating System
  static const List<Map<String, dynamic>> mealRatingCriteria = [
    {'aspect': 'taste', 'weight': 40, 'scale': 5},
    {'aspect': 'nutrition', 'weight': 25, 'scale': 5},
    {'aspect': 'ease_of_preparation', 'weight': 20, 'scale': 5},
    {'aspect': 'cost_effectiveness', 'weight': 15, 'scale': 5},
  ];
  
  // Notification Types
  static const String mealPlanReminder = 'meal_plan_reminder';
  static const String groceryListReminder = 'grocery_list_reminder';
  static const String mealPrepDay = 'meal_prep_day';
  static const String hydrationReminder = 'hydration_reminder';
  static const String nutritionGoalUpdate = 'nutrition_goal_update';
  
  // Limits and Validations
  static const int maxRecipesInPlan = 50;
  static const int maxIngredientsPerRecipe = 30;
  static const int maxGroceryListItems = 200;
  static const int maxCustomRecipes = 1000;
  static const int minCookingTime = 1; // minutes
  static const int maxCookingTime = 480; // 8 hours
  static const double maxCostPerServing = 100.0; // currency units
}
