class HabitsConstants {
  // Habit Types
  static const String positive = 'positive';
  static const String negative = 'negative';
  static const String neutral = 'neutral';
  
  // Frequency Types
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String custom = 'custom';
  
  // Tracking Types
  static const String boolean = 'boolean';
  static const String counter = 'counter';
  static const String timer = 'timer';
  static const String scale = 'scale';
  
  // Categories
  static const List<Map<String, dynamic>> habitCategories = [
    {'name': 'Health & Fitness', 'color': '#2ECC71', 'icon': 'fitness_center'},
    {'name': 'Productivity', 'color': '#3498DB', 'icon': 'productivity'},
    {'name': 'Learning', 'color': '#9B59B6', 'icon': 'school'},
    {'name': 'Mindfulness', 'color': '#E74C3C', 'icon': 'spa'},
    {'name': 'Social', 'color': '#F39C12', 'icon': 'people'},
    {'name': 'Creative', 'color': '#1ABC9C', 'icon': 'palette'},
    {'name': 'Finance', 'color': '#27AE60', 'icon': 'money'},
    {'name': 'Personal Care', 'color': '#8E44AD', 'icon': 'self_care'},
  ];
  
  // Streak Levels
  static const Map<int, String> streakLevels = {
    3: 'Beginner',
    7: 'Committed',
    14: 'Dedicated',
    30: 'Champion',
    60: 'Master',
    100: 'Legend',
    365: 'Immortal',
  };
  
  // Strength Formula Components
  static const double baseStrength = 1.0;
  static const double streakMultiplier = 0.1;
  static const double consistencyBonus = 0.2;
  static const double difficultyFactor = 1.5;
  
  // XP Rewards by Type
  static const Map<String, int> baseXpRewards = {
    positive: 20,
    negative: 15, // For avoiding negative habits
    neutral: 10,
  };
  
  // Apple Health Integration
  static const Map<String, String> healthKitMetrics = {
    'steps': 'HKQuantityTypeIdentifierStepCount',
    'water': 'HKQuantityTypeIdentifierDietaryWater',
    'sleep': 'HKCategoryTypeIdentifierSleepAnalysis',
    'exercise': 'HKQuantityTypeIdentifierAppleExerciseTime',
    'heart_rate': 'HKQuantityTypeIdentifierHeartRate',
    'calories': 'HKQuantityTypeIdentifierActiveEnergyBurned',
  };
  
  // Google Fit Integration
  static const Map<String, String> googleFitMetrics = {
    'steps': 'com.google.step_count.delta',
    'calories': 'com.google.calories.expended',
    'distance': 'com.google.distance.delta',
    'activity': 'com.google.activity.segment',
  };
  
  // Habit Templates
  static const List<Map<String, dynamic>> habitTemplates = [
    {
      'category': 'Health & Fitness',
      'habits': [
        {'name': 'Drink 8 glasses of water', 'type': counter, 'target': 8},
        {'name': 'Exercise for 30 minutes', 'type': timer, 'target': 1800},
        {'name': 'Walk 10,000 steps', 'type': counter, 'target': 10000},
        {'name': 'Get 8 hours sleep', 'type': boolean, 'target': 1},
      ]
    },
    {
      'category': 'Productivity',
      'habits': [
        {'name': 'Read for 30 minutes', 'type': timer, 'target': 1800},
        {'name': 'Write in journal', 'type': boolean, 'target': 1},
        {'name': 'Plan tomorrow\'s tasks', 'type': boolean, 'target': 1},
        {'name': 'No social media before 10 AM', 'type': boolean, 'target': 1},
      ]
    },
    {
      'category': 'Mindfulness',
      'habits': [
        {'name': 'Meditate for 10 minutes', 'type': timer, 'target': 600},
        {'name': 'Practice gratitude', 'type': boolean, 'target': 1},
        {'name': 'Deep breathing exercises', 'type': counter, 'target': 5},
        {'name': 'Mindful eating', 'type': scale, 'target': 5},
      ]
    },
  ];
  
  // Reminder Settings
  static const List<String> reminderTimes = [
    '06:00', '07:00', '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00', '20:00',
    '21:00', '22:00', '23:00',
  ];
  
  // Difficulty Levels
  static const Map<String, double> difficultyMultipliers = {
    'easy': 1.0,
    'medium': 1.5,
    'hard': 2.0,
    'extreme': 3.0,
  };
  
  // Tracking Intervals
  static const Map<String, int> trackingIntervals = {
    'real_time': 0,
    'hourly': 3600,
    'daily': 86400,
    'weekly': 604800,
  };
  
  // Analytics Periods
  static const List<String> analyticsPeriods = [
    'week',
    'month',
    'quarter',
    'year',
    'all_time',
  ];
  
  // Habit States
  static const String active = 'active';
  static const String paused = 'paused';
  static const String completed = 'completed';
  static const String archived = 'archived';
  
  // Completion Criteria
  static const String anyDay = 'any_day';
  static const String specificDays = 'specific_days';
  static const String weekdays = 'weekdays';
  static const String weekends = 'weekends';
  
  // Measurement Units
  static const Map<String, List<String>> measurementUnits = {
    'time': ['seconds', 'minutes', 'hours'],
    'distance': ['meters', 'kilometers', 'miles'],
    'weight': ['grams', 'kilograms', 'pounds'],
    'volume': ['milliliters', 'liters', 'cups'],
    'count': ['times', 'reps', 'sets'],
  };
  
  // Streak Recovery Options
  static const String noRecovery = 'no_recovery';
  static const String oneDayGrace = 'one_day_grace';
  static const String weekendSkip = 'weekend_skip';
  static const String customRecovery = 'custom_recovery';
  
  // Social Features
  static const String private = 'private';
  static const String friendsOnly = 'friends_only';
  static const String public = 'public';
  
  // Challenge Types
  static const String personalChallenge = 'personal';
  static const String groupChallenge = 'group';
  static const String communityChallenge = 'community';
  
  // Notification Types
  static const String streakReminder = 'streak_reminder';
  static const String motivationalQuote = 'motivational_quote';
  static const String progressUpdate = 'progress_update';
  static const String milestoneAchieved = 'milestone_achieved';
  
  // Export Options
  static const List<String> exportFormats = [
    'csv',
    'json',
    'pdf_report',
    'image_summary',
  ];
  
  // Limits
  static const int maxActiveHabits = 20;
  static const int maxHabitNameLength = 100;
  static const int maxHabitDescription = 500;
  static const int maxTagsPerHabit = 5;
  static const int maxTargetValue = 999999;
}
