class FlashcardsConstants {
  // Card Types
  static const String basicCard = 'basic';
  static const String clozeCard = 'cloze';
  static const String imageCard = 'image';
  static const String audioCard = 'audio';
  static const String multipleChoice = 'multiple_choice';
  static const String trueFalse = 'true_false';
  
  // Study Methods
  static const String activeRecall = 'active_recall';
  static const String spacedRepetition = 'spaced_repetition';
  static const String leitnerSystem = 'leitner_system';
  static const String freeStudy = 'free_study';
  
  // Difficulty Levels
  static const Map<String, int> difficultyIntervals = {
    'again': 1, // Review again in 1 minute
    'hard': 6, // Review in 6 minutes
    'good': 1440, // Review in 1 day (1440 minutes)
    'easy': 4320, // Review in 3 days (4320 minutes)
  };
  
  // Spaced Repetition Intervals (SM-2 Algorithm)
  static const List<int> spacedRepetitionIntervals = [
    1, 6, 1440, 5760, 25200, // 1min, 6min, 1day, 4days, 2.5weeks
    103680, 518400, 2592000, // 10weeks, 6months, 18months
  ];
  
  // Subject Categories
  static const List<Map<String, dynamic>> subjectCategories = [
    {'name': 'Languages', 'color': '#E74C3C', 'icon': 'language'},
    {'name': 'Science', 'color': '#3498DB', 'icon': 'science'},
    {'name': 'Mathematics', 'color': '#F39C12', 'icon': 'calculate'},
    {'name': 'History', 'color': '#9B59B6', 'icon': 'history'},
    {'name': 'Geography', 'color': '#2ECC71', 'icon': 'public'},
    {'name': 'Literature', 'color': '#1ABC9C', 'icon': 'book'},
    {'name': 'Medicine', 'color': '#E67E22', 'icon': 'medical_services'},
    {'name': 'Technology', 'color': '#34495E', 'icon': 'computer'},
  ];
  
  // AI-Generated Deck Templates
  static const List<Map<String, dynamic>> aiDeckTemplates = [
    {
      'subject': 'Language Learning',
      'templates': [
        {'type': 'vocabulary', 'format': 'Word → Translation + Example'},
        {'type': 'grammar', 'format': 'Rule → Examples + Usage'},
        {'type': 'pronunciation', 'format': 'Word → Audio + Phonetics'},
        {'type': 'phrases', 'format': 'Phrase → Context + Translation'},
      ]
    },
    {
      'subject': 'Science',
      'templates': [
        {'type': 'definitions', 'format': 'Term → Definition + Formula'},
        {'type': 'processes', 'format': 'Process → Steps + Diagram'},
        {'type': 'experiments', 'format': 'Question → Method + Result'},
        {'type': 'facts', 'format': 'Concept → Explanation + Examples'},
      ]
    },
  ];
  
  // Practice Test Types
  static const List<String> testTypes = [
    'quick_review',
    'comprehensive_test',
    'weak_areas_focus',
    'timed_challenge',
    'mixed_subjects',
  ];
  
  // Import Sources
  static const List<Map<String, dynamic>> importSources = [
    {'name': 'Anki', 'format': '.apkg', 'supported': true},
    {'name': 'Quizlet', 'format': '.txt', 'supported': true},
    {'name': 'CSV', 'format': '.csv', 'supported': true},
    {'name': 'Excel', 'format': '.xlsx', 'supported': true},
    {'name': 'JSON', 'format': '.json', 'supported': true},
    {'name': 'XML', 'format': '.xml', 'supported': false},
  ];
  
  // Study Statistics
  static const List<String> studyMetrics = [
    'cards_studied',
    'correct_answers',
    'accuracy_rate',
    'study_time',
    'streak_count',
    'mature_cards',
    'retention_rate',
  ];
  
  // Card States
  static const String newCard = 'new';
  static const String learning = 'learning';
  static const String review = 'review';
  static const String mature = 'mature';
  static const String suspended = 'suspended';
  static const String buried = 'buried';
  
  // Leitner Box System
  static const Map<int, int> leitnerBoxIntervals = {
    1: 1, // Daily
    2: 3, // Every 3 days
    3: 7, // Weekly
    4: 14, // Bi-weekly
    5: 30, // Monthly
  };
  
  // Audio Features
  static const List<String> supportedAudioFormats = [
    'mp3', 'wav', 'ogg', 'm4a'
  ];
  
  // Image Features
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
  
  // Study Modes
  static const String studyMode = 'study';
  static const String testMode = 'test';
  static const String reviewMode = 'review';
  static const String cramMode = 'cram';
  
  // Card Layouts
  static const List<Map<String, dynamic>> cardLayouts = [
    {
      'name': 'Standard',
      'description': 'Simple front and back design',
      'template': 'standard'
    },
    {
      'name': 'Image Focus',
      'description': 'Large image with text overlay',
      'template': 'image_focus'
    },
    {
      'name': 'Split View',
      'description': 'Side-by-side question and answer',
      'template': 'split_view'
    },
    {
      'name': 'Minimal',
      'description': 'Clean text-only design',
      'template': 'minimal'
    },
  ];
  
  // Study Goals
  static const List<Map<String, dynamic>> studyGoals = [
    {'name': 'Daily Cards', 'type': 'daily', 'default': 20},
    {'name': 'Weekly Minutes', 'type': 'weekly', 'default': 300},
    {'name': 'Monthly Accuracy', 'type': 'monthly', 'default': 85},
    {'name': 'Streak Days', 'type': 'streak', 'default': 7},
  ];
  
  // Gamification Elements
  static const Map<String, int> studyRewards = {
    'card_correct': 5,
    'perfect_session': 50,
    'daily_goal': 25,
    'weekly_goal': 100,
    'streak_bonus': 10,
  };
  
  // Deck Sharing Options
  static const String privateAccess = 'private';
  static const String friendsAccess = 'friends';
  static const String publicAccess = 'public';
  static const String linkAccess = 'link';
  
  // Study Reminders
  static const List<String> reminderTypes = [
    'daily_study',
    'review_due',
    'goal_progress',
    'streak_maintenance',
  ];
  
  // Export Options
  static const List<String> exportFormats = [
    'apkg', // Anki package
    'csv', // Comma-separated values
    'json', // JSON format
    'pdf', // PDF document
    'txt', // Plain text
  ];
  
  // Performance Metrics
  static const List<String> performanceIndicators = [
    'retention_rate',
    'learning_efficiency',
    'time_per_card',
    'difficulty_progression',
    'weak_area_identification',
  ];
  
  // Card Generation AI Prompts
  static const Map<String, String> aiPrompts = {
    'vocabulary': 'Generate vocabulary cards for {subject} with word, definition, example sentence, and pronunciation guide',
    'concepts': 'Create concept cards for {subject} with clear definitions and real-world applications',
    'formulas': 'Generate formula cards for {subject} with the formula, explanation, and example problems',
    'facts': 'Create factual cards for {subject} with questions and detailed answers',
  };
  
  // Study Session Settings
  static const Map<String, dynamic> sessionDefaults = {
    'max_new_cards': 20,
    'max_review_cards': 100,
    'time_limit': 30, // minutes
    'break_interval': 25, // Pomodoro technique
    'auto_advance': false,
  };
  
  // Card Difficulty Adjustment
  static const Map<String, double> difficultyAdjustment = {
    'again': -0.2,
    'hard': -0.15,
    'good': 0.0,
    'easy': 0.15,
  };
  
  // Limits and Validations
  static const int maxDecksPerUser = 100;
  static const int maxCardsPerDeck = 10000;
  static const int maxCardContentLength = 5000;
  static const int maxDeckNameLength = 100;
  static const int maxTagsPerCard = 10;
  static const int maxImageSizeMB = 5;
  static const int maxAudioSizeMB = 10;
}
