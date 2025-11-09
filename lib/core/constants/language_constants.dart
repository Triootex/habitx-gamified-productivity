class LanguageConstants {
  // Supported Languages
  static const Map<String, Map<String, dynamic>> supportedLanguages = {
    'spanish': {
      'name': 'Spanish',
      'native_name': 'Español',
      'flag': '🇪🇸',
      'difficulty': 'easy',
      'speakers': 500000000,
    },
    'french': {
      'name': 'French',
      'native_name': 'Français',
      'flag': '🇫🇷',
      'difficulty': 'medium',
      'speakers': 280000000,
    },
    'german': {
      'name': 'German',
      'native_name': 'Deutsch',
      'flag': '🇩🇪',
      'difficulty': 'hard',
      'speakers': 100000000,
    },
    'mandarin': {
      'name': 'Mandarin Chinese',
      'native_name': '中文',
      'flag': '🇨🇳',
      'difficulty': 'very_hard',
      'speakers': 918000000,
    },
    'japanese': {
      'name': 'Japanese',
      'native_name': '日本語',
      'flag': '🇯🇵',
      'difficulty': 'very_hard',
      'speakers': 125000000,
    },
  };
  
  // Learning Levels
  static const List<String> proficiencyLevels = [
    'a1_beginner',
    'a2_elementary',
    'b1_intermediate',
    'b2_upper_intermediate',
    'c1_advanced',
    'c2_proficiency',
  ];
  
  // Skill Categories
  static const List<Map<String, dynamic>> skillCategories = [
    {
      'name': 'Vocabulary',
      'icon': 'book',
      'color': '#3498DB',
      'exercises': ['word_translation', 'image_match', 'definition_match']
    },
    {
      'name': 'Grammar',
      'icon': 'rule',
      'color': '#E74C3C',
      'exercises': ['sentence_building', 'conjugation', 'error_correction']
    },
    {
      'name': 'Listening',
      'icon': 'hearing',
      'color': '#F39C12',
      'exercises': ['audio_comprehension', 'dictation', 'pronunciation_match']
    },
    {
      'name': 'Speaking',
      'icon': 'record_voice_over',
      'color': '#2ECC71',
      'exercises': ['pronunciation_practice', 'conversation_simulation', 'speech_recognition']
    },
    {
      'name': 'Reading',
      'icon': 'chrome_reader_mode',
      'color': '#9B59B6',
      'exercises': ['comprehension_test', 'speed_reading', 'context_clues']
    },
    {
      'name': 'Writing',
      'icon': 'edit',
      'color': '#1ABC9C',
      'exercises': ['sentence_completion', 'essay_writing', 'translation']
    },
  ];
  
  // League System (like Duolingo)
  static const List<Map<String, dynamic>> leagues = [
    {'name': 'Bronze', 'min_xp': 0, 'max_xp': 299, 'color': '#CD7F32'},
    {'name': 'Silver', 'min_xp': 300, 'max_xp': 599, 'color': '#C0C0C0'},
    {'name': 'Gold', 'min_xp': 600, 'max_xp': 999, 'color': '#FFD700'},
    {'name': 'Sapphire', 'min_xp': 1000, 'max_xp': 1499, 'color': '#0F52BA'},
    {'name': 'Ruby', 'min_xp': 1500, 'max_xp': 2499, 'color': '#E0115F'},
    {'name': 'Emerald', 'min_xp': 2500, 'max_xp': 3999, 'color': '#50C878'},
    {'name': 'Amethyst', 'min_xp': 4000, 'max_xp': 5999, 'color': '#9966CC'},
    {'name': 'Pearl', 'min_xp': 6000, 'max_xp': 8999, 'color': '#F0EAD6'},
    {'name': 'Obsidian', 'min_xp': 9000, 'max_xp': 12999, 'color': '#3C3C3C'},
    {'name': 'Diamond', 'min_xp': 13000, 'max_xp': 999999, 'color': '#B9F2FF'},
  ];
  
  // AI Story Generation
  static const List<Map<String, dynamic>> storyThemes = [
    {
      'theme': 'Adventure',
      'topics': ['travel', 'exploration', 'mystery', 'treasure_hunt'],
      'difficulty_adaptations': ['vocabulary', 'sentence_complexity', 'tense_usage']
    },
    {
      'theme': 'Romance',
      'topics': ['love', 'relationships', 'dating', 'marriage'],
      'difficulty_adaptations': ['emotional_vocabulary', 'past_tense', 'descriptive_language']
    },
    {
      'theme': 'Science Fiction',
      'topics': ['technology', 'space', 'future', 'robots'],
      'difficulty_adaptations': ['technical_vocabulary', 'conditional_tense', 'complex_sentences']
    },
    {
      'theme': 'Daily Life',
      'topics': ['work', 'family', 'hobbies', 'shopping'],
      'difficulty_adaptations': ['common_vocabulary', 'present_tense', 'simple_structures']
    },
  ];
  
  // Native Speaker Videos
  static const List<Map<String, dynamic>> videoCategories = [
    {
      'category': 'Conversations',
      'description': 'Real conversations between native speakers',
      'levels': ['a2', 'b1', 'b2'],
      'duration_range': [2, 10] // minutes
    },
    {
      'category': 'Culture & Travel',
      'description': 'Explore culture through native perspectives',
      'levels': ['b1', 'b2', 'c1'],
      'duration_range': [5, 15]
    },
    {
      'category': 'News & Current Events',
      'description': 'Stay updated with native news sources',
      'levels': ['b2', 'c1', 'c2'],
      'duration_range': [3, 20]
    },
    {
      'category': 'Entertainment',
      'description': 'Comedy, music, and popular culture',
      'levels': ['a2', 'b1', 'b2'],
      'duration_range': [1, 8]
    },
  ];
  
  // Live Class Features
  static const List<Map<String, dynamic>> classTypes = [
    {
      'type': 'Conversation Practice',
      'max_students': 6,
      'duration': 30,
      'focus': 'speaking_fluency',
      'level_requirement': 'a2+'
    },
    {
      'type': 'Grammar Workshop',
      'max_students': 12,
      'duration': 45,
      'focus': 'grammar_concepts',
      'level_requirement': 'a1+'
    },
    {
      'type': 'Pronunciation Clinic',
      'max_students': 8,
      'duration': 25,
      'focus': 'accent_improvement',
      'level_requirement': 'a2+'
    },
    {
      'type': 'Cultural Immersion',
      'max_students': 10,
      'duration': 60,
      'focus': 'cultural_understanding',
      'level_requirement': 'b1+'
    },
  ];
  
  // Exercise Types
  static const List<Map<String, dynamic>> exerciseTypes = [
    {
      'type': 'translation',
      'name': 'Translation',
      'description': 'Translate between languages',
      'xp_reward': 10,
      'time_limit': 60
    },
    {
      'type': 'multiple_choice',
      'name': 'Multiple Choice',
      'description': 'Choose the correct answer',
      'xp_reward': 5,
      'time_limit': 30
    },
    {
      'type': 'listening_comprehension',
      'name': 'Listening',
      'description': 'Listen and answer questions',
      'xp_reward': 15,
      'time_limit': 90
    },
    {
      'type': 'speaking_practice',
      'name': 'Speaking',
      'description': 'Record your pronunciation',
      'xp_reward': 20,
      'time_limit': 120
    },
    {
      'type': 'sentence_building',
      'name': 'Sentence Building',
      'description': 'Arrange words in correct order',
      'xp_reward': 12,
      'time_limit': 45
    },
  ];
  
  // Spaced Repetition Algorithm
  static const Map<String, int> repetitionIntervals = {
    'new_word': 0, // Immediate review
    'learning': 1, // 1 day
    'young': 3, // 3 days  
    'mature': 7, // 1 week
    'master': 30, // 1 month
  };
  
  // Streak Bonuses
  static const Map<int, int> streakBonuses = {
    7: 50, // 1 week bonus
    14: 100, // 2 weeks bonus
    30: 250, // 1 month bonus
    60: 500, // 2 months bonus
    100: 1000, // 100 days bonus
    365: 5000, // 1 year bonus
  };
  
  // Achievement Categories
  static const List<Map<String, dynamic>> achievements = [
    {
      'category': 'Consistency',
      'achievements': [
        {'name': 'Early Bird', 'description': 'Study for 7 days in a row', 'xp': 100},
        {'name': 'Dedicated Learner', 'description': 'Study for 30 days in a row', 'xp': 500},
        {'name': 'Language Master', 'description': 'Study for 100 days in a row', 'xp': 2000},
      ]
    },
    {
      'category': 'Progress',
      'achievements': [
        {'name': 'Vocabulary Builder', 'description': 'Learn 100 new words', 'xp': 200},
        {'name': 'Grammar Guru', 'description': 'Complete all grammar lessons', 'xp': 300},
        {'name': 'Fluent Speaker', 'description': 'Reach C1 level', 'xp': 5000},
      ]
    },
  ];
  
  // Course Structure
  static const Map<String, List<String>> courseStructure = {
    'basics': [
      'greetings',
      'numbers',
      'colors',
      'family',
      'food',
      'time',
      'directions',
    ],
    'intermediate': [
      'past_tense',
      'future_tense',
      'conditional',
      'subjunctive',
      'complex_sentences',
      'idioms',
    ],
    'advanced': [
      'literature',
      'business',
      'technical_topics',
      'cultural_nuances',
      'advanced_grammar',
      'native_expressions',
    ],
  };
  
  // Progress Tracking Metrics
  static const List<String> progressMetrics = [
    'words_learned',
    'lessons_completed',
    'exercises_solved',
    'speaking_time',
    'listening_hours',
    'reading_pages',
    'writing_words',
  ];
  
  // Gamification Elements
  static const Map<String, int> xpRewards = {
    'lesson_completion': 20,
    'perfect_lesson': 30,
    'daily_goal': 25,
    'weekly_goal': 100,
    'monthly_goal': 500,
    'challenge_completion': 75,
  };
  
  // Difficulty Adaptation
  static const Map<String, Map<String, dynamic>> difficultyLevels = {
    'beginner': {
      'vocabulary_size': 500,
      'sentence_length': 8,
      'grammar_complexity': 'simple',
      'audio_speed': 0.8,
    },
    'intermediate': {
      'vocabulary_size': 2000,
      'sentence_length': 15,
      'grammar_complexity': 'moderate',
      'audio_speed': 0.9,
    },
    'advanced': {
      'vocabulary_size': 5000,
      'sentence_length': 25,
      'grammar_complexity': 'complex',
      'audio_speed': 1.0,
    },
  };
  
  // Cultural Context Features
  static const List<Map<String, dynamic>> culturalTopics = [
    {'topic': 'Holidays & Traditions', 'importance': 'high'},
    {'topic': 'Food & Cuisine', 'importance': 'high'},
    {'topic': 'Social Etiquette', 'importance': 'medium'},
    {'topic': 'Business Culture', 'importance': 'medium'},
    {'topic': 'History & Literature', 'importance': 'low'},
  ];
  
  // Notification Types
  static const String dailyReminder = 'daily_reminder';
  static const String streakReminder = 'streak_reminder';
  static const String liveClassReminder = 'live_class_reminder';
  static const String challengeUpdate = 'challenge_update';
  static const String leaguePromotion = 'league_promotion';
  
  // Limits and Validations
  static const int maxLessonDuration = 60; // minutes
  static const int minLessonDuration = 5; // minutes
  static const int maxDailyXp = 1000;
  static const int maxWordsPerLesson = 20;
  static const int maxSentenceLength = 50; // words
  static const int maxAudioDuration = 300; // seconds
}
