class AppConstants {
  // App Configuration
  static const String appName = 'HabitX';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Gamified Productivity RPG';
  
  // Database
  static const String databaseName = 'habitx_database.db';
  static const int databaseVersion = 1;
  
  // Hive Boxes
  static const String userBox = 'user_box';
  static const String tasksBox = 'tasks_box';
  static const String habitsBox = 'habits_box';
  static const String statsBox = 'stats_box';
  static const String achievementsBox = 'achievements_box';
  static const String settingsBox = 'settings_box';
  static const String marketplaceBox = 'marketplace_box';
  
  // API Endpoints
  static const String baseUrl = 'https://api.habitx.com/v1';
  static const String firebaseUrl = 'https://habitx-default-rtdb.firebaseio.com';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String habitsCollection = 'habits';
  static const String achievementsCollection = 'achievements';
  static const String marketplaceCollection = 'marketplace';
  static const String leaderboardCollection = 'leaderboard';
  static const String partiesCollection = 'parties';
  static const String questsCollection = 'quests';
  
  // AdMob IDs
  static const String androidAppOpenAdId = 'ca-app-pub-3940256099942544/9257395921';
  static const String iosAppOpenAdId = 'ca-app-pub-3940256099942544/5662855259';
  static const String androidBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerAdId = 'ca-app-pub-3940256099942544/2934735716';
  static const String androidInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitialAdId = 'ca-app-pub-3940256099942544/4411468910';
  static const String androidRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedAdId = 'ca-app-pub-3940256099942544/1712485313';
  
  // In-App Purchase IDs
  static const String hourlyPremiumId = 'hourly_premium';
  static const String dailyPremiumId = 'daily_premium';
  static const String weeklyPremiumId = 'weekly_premium';
  static const String monthlyPremiumId = 'monthly_premium';
  static const String yearlyPremiumId = 'yearly_premium';
  static const String lifetimePremiumId = 'lifetime_premium';
  static const String autoCompleteId = 'auto_complete_9';
  
  // Premium Prices (in INR paisa)
  static const int hourlyPremiumPrice = 900; // ₹9
  static const int dailyPremiumPrice = 4900; // ₹49
  static const int weeklyPremiumPrice = 14900; // ₹149
  static const int monthlyPremiumPrice = 39900; // ₹399
  static const int yearlyPremiumPrice = 299900; // ₹2999
  static const int lifetimePremiumPrice = 499900; // ₹4999
  static const int autoCompletePrice = 900; // ₹9
  
  // Gamification
  static const int maxLevel = 100;
  static const int baseXpPerLevel = 100;
  static const int maxHp = 100;
  static const int maxMana = 100;
  
  // XP Values by Difficulty
  static const Map<String, int> xpValues = {
    'easy': 10,
    'medium': 50,
    'hard': 100,
    'very_hard': 200,
  };
  
  // Gold Values by Difficulty
  static const Map<String, int> goldValues = {
    'easy': 5,
    'medium': 15,
    'hard': 30,
    'very_hard': 50,
  };
  
  // Rarity Chances
  static const Map<String, double> rarityChances = {
    'common': 0.60,
    'uncommon': 0.25,
    'rare': 0.10,
    'ultra_rare': 0.04,
    'legendary': 0.008,
    'mythical': 0.002,
  };
  
  // Categories
  static const List<String> productivityCategories = [
    'todo',
    'habits',
    'sleep',
    'mental_health',
    'flashcards',
    'fitness',
    'meditation',
    'language',
    'budget',
    'reading',
    'focus',
    'journal',
    'meals',
  ];
  
  // Classes
  static const List<String> characterClasses = [
    'warrior',
    'mage',
    'rogue',
    'monk',
    'paladin',
  ];
  
  // Notification Channels
  static const String taskReminderChannel = 'task_reminders';
  static const String questNotificationChannel = 'quest_notifications';
  static const String achievementChannel = 'achievements';
  static const String marketplaceChannel = 'marketplace';
  
  // Background Task Keys
  static const String taskRenewalKey = 'task_renewal';
  static const String rewardCalculationKey = 'reward_calculation';
  static const String notificationKey = 'notification_sender';
  static const String syncKey = 'data_sync';
  
  // Asset URLs
  static const String opengameartUrl = 'https://opengameart.org';
  static const String freesoundUrl = 'https://freesound.org';
  static const String lottiefilesUrl = 'https://lottiefiles.com';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // File Paths
  static const String assetsPath = 'assets';
  static const String imagesPath = 'assets/images';
  static const String soundsPath = 'assets/sounds';
  static const String animationsPath = 'assets/animations';
  static const String fontsPath = 'assets/fonts';
  
  // Theme Keys
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
  
  // Languages
  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'es',
    'fr',
    'de',
    'zh',
    'ja',
    'ko',
  ];
  
  // Default Values
  static const int defaultTaskLimit = 10;
  static const int premiumTaskLimit = 1000;
  static const int defaultStreakMultiplier = 1;
  static const int maxStreakMultiplier = 5;
  
  // Time Constants
  static const Duration adCooldown = Duration(hours: 1);
  static const Duration questResetTime = Duration(hours: 24);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration backgroundInterval = Duration(minutes: 1);
}
