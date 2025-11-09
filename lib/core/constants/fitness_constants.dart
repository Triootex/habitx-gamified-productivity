class FitnessConstants {
  // Activity Types
  static const String cardio = 'cardio';
  static const String strength = 'strength';
  static const String flexibility = 'flexibility';
  static const String balance = 'balance';
  static const String sports = 'sports';
  static const String yoga = 'yoga';
  
  // Intensity Levels
  static const String lightIntensity = 'light';
  static const String moderateIntensity = 'moderate';
  static const String vigorousIntensity = 'vigorous';
  
  // WHO Recommended Goals
  static const Map<String, Map<String, dynamic>> whoGuidelines = {
    'adult': {
      'cardio_moderate': 150, // minutes per week
      'cardio_vigorous': 75, // minutes per week
      'strength_sessions': 2, // per week
      'daily_steps': 10000,
    },
    'elderly': {
      'cardio_moderate': 150, // minutes per week
      'balance_sessions': 3, // per week
      'strength_sessions': 2, // per week
      'daily_steps': 7000,
    },
  };
  
  // Heart Rate Zones
  static const Map<String, Map<String, double>> heartRateZones = {
    'zone1_recovery': {'min': 0.5, 'max': 0.6}, // 50-60% max HR
    'zone2_aerobic': {'min': 0.6, 'max': 0.7}, // 60-70% max HR
    'zone3_tempo': {'min': 0.7, 'max': 0.8}, // 70-80% max HR
    'zone4_threshold': {'min': 0.8, 'max': 0.9}, // 80-90% max HR
    'zone5_anaerobic': {'min': 0.9, 'max': 1.0}, // 90-100% max HR
  };
  
  // Exercise Categories
  static const List<Map<String, dynamic>> exerciseCategories = [
    {
      'name': 'Cardio',
      'exercises': [
        {'name': 'Running', 'met': 8.0, 'muscle_groups': ['legs', 'core']},
        {'name': 'Cycling', 'met': 7.5, 'muscle_groups': ['legs', 'glutes']},
        {'name': 'Swimming', 'met': 6.0, 'muscle_groups': ['full_body']},
        {'name': 'Walking', 'met': 3.5, 'muscle_groups': ['legs']},
      ]
    },
    {
      'name': 'Strength',
      'exercises': [
        {'name': 'Push-ups', 'met': 3.8, 'muscle_groups': ['chest', 'triceps', 'shoulders']},
        {'name': 'Squats', 'met': 5.0, 'muscle_groups': ['legs', 'glutes']},
        {'name': 'Deadlifts', 'met': 6.0, 'muscle_groups': ['back', 'legs', 'glutes']},
        {'name': 'Pull-ups', 'met': 8.0, 'muscle_groups': ['back', 'biceps']},
      ]
    },
  ];
  
  // GPS Route Types
  static const String running = 'running';
  static const String walking = 'walking';
  static const String cycling = 'cycling';
  static const String hiking = 'hiking';
  
  // Workout Challenges
  static const List<Map<String, dynamic>> challenges = [
    {
      'name': '30-Day Push-up Challenge',
      'type': 'strength',
      'duration': 30,
      'progression': 'daily_increment',
      'start_reps': 5,
      'end_reps': 100,
    },
    {
      'name': 'Couch to 5K',
      'type': 'cardio',
      'duration': 63, // 9 weeks
      'progression': 'structured_plan',
      'goal': 'run_5k_continuously',
    },
    {
      'name': '10,000 Steps Daily',
      'type': 'cardio',
      'duration': 30,
      'progression': 'daily_goal',
      'target': 10000,
    },
  ];
  
  // Muscle Groups
  static const List<String> muscleGroups = [
    'chest',
    'back',
    'shoulders',
    'biceps',
    'triceps',
    'legs',
    'glutes',
    'core',
    'calves',
    'forearms',
  ];
  
  // Macronutrients Tracking
  static const Map<String, Map<String, dynamic>> macronutrients = {
    'protein': {
      'calories_per_gram': 4,
      'recommended_percentage': 0.25, // 25% of total calories
      'color': '#E74C3C'
    },
    'carbohydrates': {
      'calories_per_gram': 4,
      'recommended_percentage': 0.45, // 45% of total calories
      'color': '#F39C12'
    },
    'fats': {
      'calories_per_gram': 9,
      'recommended_percentage': 0.30, // 30% of total calories
      'color': '#3498DB'
    },
  };
  
  // Barcode Scanning Categories
  static const List<String> foodCategories = [
    'fruits',
    'vegetables',
    'grains',
    'proteins',
    'dairy',
    'snacks',
    'beverages',
    'supplements',
  ];
  
  // Workout Equipment
  static const List<Map<String, dynamic>> equipment = [
    {'name': 'Dumbbells', 'category': 'strength', 'icon': 'fitness_center'},
    {'name': 'Resistance Bands', 'category': 'strength', 'icon': 'gesture'},
    {'name': 'Yoga Mat', 'category': 'flexibility', 'icon': 'self_improvement'},
    {'name': 'Kettlebell', 'category': 'strength', 'icon': 'sports_gymnastics'},
    {'name': 'Treadmill', 'category': 'cardio', 'icon': 'directions_run'},
    {'name': 'Bicycle', 'category': 'cardio', 'icon': 'directions_bike'},
  ];
  
  // Fitness Goals
  static const List<Map<String, dynamic>> fitnessGoals = [
    {'name': 'Weight Loss', 'type': 'weight_management', 'focus': 'caloric_deficit'},
    {'name': 'Muscle Gain', 'type': 'strength', 'focus': 'progressive_overload'},
    {'name': 'Endurance', 'type': 'cardio', 'focus': 'aerobic_capacity'},
    {'name': 'Flexibility', 'type': 'mobility', 'focus': 'range_of_motion'},
    {'name': 'General Health', 'type': 'wellness', 'focus': 'balanced_approach'},
  ];
  
  // Heart Points System (Google Fit)
  static const Map<String, int> heartPointsPerMinute = {
    lightIntensity: 1,
    moderateIntensity: 1,
    vigorousIntensity: 2,
  };
  
  // Calorie Burn Formulas
  static const Map<String, String> calorieFormulas = {
    'men': 'BMR = 88.362 + (13.397 × weight) + (4.799 × height) - (5.677 × age)',
    'women': 'BMR = 447.593 + (9.247 × weight) + (3.098 × height) - (4.330 × age)',
  };
  
  // Activity Multipliers for TDEE
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
  };
  
  // Workout Templates
  static const List<Map<String, dynamic>> workoutTemplates = [
    {
      'name': 'Full Body Beginner',
      'exercises': [
        {'name': 'Bodyweight Squats', 'sets': 3, 'reps': '10-15'},
        {'name': 'Push-ups', 'sets': 3, 'reps': '5-10'},
        {'name': 'Plank', 'sets': 3, 'duration': '30s'},
        {'name': 'Lunges', 'sets': 2, 'reps': '10 each leg'},
      ],
      'rest_between_sets': 60,
      'estimated_duration': 30,
    },
    {
      'name': 'HIIT Cardio',
      'exercises': [
        {'name': 'Jumping Jacks', 'duration': 45, 'rest': 15},
        {'name': 'Burpees', 'duration': 30, 'rest': 30},
        {'name': 'Mountain Climbers', 'duration': 45, 'rest': 15},
        {'name': 'High Knees', 'duration': 30, 'rest': 30},
      ],
      'rounds': 4,
      'estimated_duration': 20,
    },
  ];
  
  // Progress Tracking Metrics
  static const List<String> progressMetrics = [
    'weight',
    'body_fat_percentage',
    'muscle_mass',
    'measurements', // waist, chest, arms, etc.
    'performance_improvements',
    'endurance_gains',
  ];
  
  // Integration APIs
  static const Map<String, String> fitnessApis = {
    'google_fit': 'com.google.android.gms.fitness',
    'apple_health': 'com.apple.health',
    'fitbit': 'fitbit_web_api',
    'garmin': 'garmin_connect_iq',
    'strava': 'strava_api_v3',
    'myfitnesspal': 'myfitnesspal_api',
  };
  
  // Nutrition Database
  static const Map<String, String> nutritionDatabases = {
    'usda': 'USDA FoodData Central',
    'edamam': 'Edamam Food Database API',
    'spoonacular': 'Spoonacular Food API',
    'nutritionix': 'Nutritionix API',
  };
  
  // Recovery Metrics
  static const List<String> recoveryIndicators = [
    'resting_heart_rate',
    'heart_rate_variability',
    'sleep_quality',
    'perceived_exertion',
    'muscle_soreness',
  ];
  
  // Workout Difficulty Progression
  static const Map<String, Map<String, dynamic>> difficultyProgression = {
    'beginner': {
      'duration_range': [15, 30],
      'intensity': 'light_to_moderate',
      'frequency': '2-3 times per week',
    },
    'intermediate': {
      'duration_range': [30, 60],
      'intensity': 'moderate_to_vigorous',
      'frequency': '3-5 times per week',
    },
    'advanced': {
      'duration_range': [45, 90],
      'intensity': 'vigorous_to_high',
      'frequency': '5-7 times per week',
    },
  };
  
  // Notification Types
  static const String workoutReminder = 'workout_reminder';
  static const String hydrationReminder = 'hydration_reminder';
  static const String restDayReminder = 'rest_day_reminder';
  static const String goalAchievement = 'goal_achievement';
  static const String weeklyProgress = 'weekly_progress';
  
  // Limits and Validations
  static const int maxWorkoutDuration = 300; // 5 hours in minutes
  static const int minWorkoutDuration = 5; // 5 minutes
  static const int maxSetsPerExercise = 20;
  static const int maxRepsPerSet = 1000;
  static const double maxWeightKg = 500.0;
  static const int maxExercisesPerWorkout = 50;
  static const int maxWorkoutsPerDay = 5;
}
