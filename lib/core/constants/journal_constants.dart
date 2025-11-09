class JournalConstants {
  // Journal Types
  static const String dailyJournal = 'daily_journal';
  static const String gratitudeJournal = 'gratitude_journal';
  static const String dreamJournal = 'dream_journal';
  static const String travelJournal = 'travel_journal';
  static const String reflectionJournal = 'reflection_journal';
  static const String goalsJournal = 'goals_journal';
  static const String moodJournal = 'mood_journal';
  
  // Entry Formats
  static const String freeForm = 'free_form';
  static const String structured = 'structured';
  static const String promptBased = 'prompt_based';
  static const String templateBased = 'template_based';
  
  // Mood Tracking Integration
  static const List<Map<String, dynamic>> moodEmojis = [
    {'emoji': '😢', 'mood': 'very_sad', 'value': 1, 'color': '#3498DB'},
    {'emoji': '😔', 'mood': 'sad', 'value': 2, 'color': '#5DADE2'},
    {'emoji': '😐', 'mood': 'neutral', 'value': 3, 'color': '#F7DC6F'},
    {'emoji': '😊', 'mood': 'happy', 'value': 4, 'color': '#58D68D'},
    {'emoji': '😁', 'mood': 'very_happy', 'value': 5, 'color': '#2ECC71'},
    {'emoji': '😴', 'mood': 'tired', 'value': 0, 'color': '#9B59B6'},
    {'emoji': '😰', 'mood': 'stressed', 'value': 0, 'color': '#E74C3C'},
    {'emoji': '😌', 'mood': 'peaceful', 'value': 4, 'color': '#85C1E9'},
    {'emoji': '🤗', 'mood': 'grateful', 'value': 5, 'color': '#F8C471'},
    {'emoji': '😤', 'mood': 'frustrated', 'value': 2, 'color': '#EC7063'},
  ];
  
  // AI-Generated Prompts
  static const List<Map<String, dynamic>> journalPrompts = [
    {
      'category': 'Reflection',
      'prompts': [
        'What was the highlight of your day?',
        'What challenged you today and how did you handle it?',
        'What are three things you learned about yourself this week?',
        'If you could relive one moment from today, which would it be?',
        'What would you tell your younger self based on today\'s experiences?',
      ]
    },
    {
      'category': 'Gratitude',
      'prompts': [
        'List three things you\'re grateful for today.',
        'Who made a positive impact on your day?',
        'What small pleasure did you enjoy today?',
        'What opportunity are you thankful for?',
        'What about your health are you grateful for?',
      ]
    },
    {
      'category': 'Growth',
      'prompts': [
        'What skill would you like to develop further?',
        'How did you step out of your comfort zone today?',
        'What habit are you most proud of maintaining?',
        'What feedback did you receive and how will you use it?',
        'What would make tomorrow better than today?',
      ]
    },
    {
      'category': 'Creativity',
      'prompts': [
        'If you could create anything, what would it be?',
        'Describe a perfect day from your imagination.',
        'What story do your recent experiences tell?',
        'What would you do if you had unlimited resources?',
        'Write about a dream you remember.',
      ]
    },
  ];
  
  // CBT (Cognitive Behavioral Therapy) Activities
  static const List<Map<String, dynamic>> cbtActivities = [
    {
      'name': 'Thought Record',
      'description': 'Track and analyze negative thought patterns',
      'fields': [
        {'name': 'situation', 'type': 'text', 'required': true},
        {'name': 'emotion', 'type': 'emotion_selector', 'required': true},
        {'name': 'automatic_thought', 'type': 'text', 'required': true},
        {'name': 'evidence_for', 'type': 'text', 'required': false},
        {'name': 'evidence_against', 'type': 'text', 'required': false},
        {'name': 'balanced_thought', 'type': 'text', 'required': true},
        {'name': 'new_emotion', 'type': 'emotion_selector', 'required': true},
      ]
    },
    {
      'name': 'Behavioral Experiment',
      'description': 'Test negative beliefs with real-world experiments',
      'fields': [
        {'name': 'belief_to_test', 'type': 'text', 'required': true},
        {'name': 'prediction', 'type': 'text', 'required': true},
        {'name': 'experiment_plan', 'type': 'text', 'required': true},
        {'name': 'actual_outcome', 'type': 'text', 'required': false},
        {'name': 'learning', 'type': 'text', 'required': false},
      ]
    },
    {
      'name': 'Mood Monitoring',
      'description': 'Daily mood tracking with triggers and activities',
      'fields': [
        {'name': 'morning_mood', 'type': 'mood_scale', 'required': true},
        {'name': 'evening_mood', 'type': 'mood_scale', 'required': true},
        {'name': 'triggers', 'type': 'tags', 'required': false},
        {'name': 'helpful_activities', 'type': 'tags', 'required': false},
        {'name': 'notes', 'type': 'text', 'required': false},
      ]
    },
  ];
  
  // Correlation Statistics
  static const List<Map<String, dynamic>> correlationTypes = [
    {
      'type': 'mood_weather',
      'name': 'Mood vs Weather',
      'description': 'How weather affects your mood',
      'data_sources': ['mood_entries', 'weather_api'],
    },
    {
      'type': 'mood_sleep',
      'name': 'Mood vs Sleep',
      'description': 'Relationship between sleep and mood',
      'data_sources': ['mood_entries', 'sleep_data'],
    },
    {
      'type': 'mood_activities',
      'name': 'Mood vs Activities',
      'description': 'Which activities improve your mood',
      'data_sources': ['mood_entries', 'activity_logs'],
    },
    {
      'type': 'productivity_mood',
      'name': 'Productivity vs Mood',
      'description': 'How mood affects your productivity',
      'data_sources': ['mood_entries', 'task_completion'],
    },
  ];
  
  // Custom Emoji Sets
  static const Map<String, List<Map<String, dynamic>>> customEmojiSets = {
    'energy_levels': [
      {'emoji': '🔋', 'name': 'High Energy', 'value': 5},
      {'emoji': '⚡', 'name': 'Energized', 'value': 4},
      {'emoji': '🔌', 'name': 'Normal', 'value': 3},
      {'emoji': '🔋', 'name': 'Low Energy', 'value': 2},
      {'emoji': '📱', 'name': 'Drained', 'value': 1},
    ],
    'stress_levels': [
      {'emoji': '😌', 'name': 'Relaxed', 'value': 1},
      {'emoji': '🙂', 'name': 'Calm', 'value': 2},
      {'emoji': '😐', 'name': 'Neutral', 'value': 3},
      {'emoji': '😓', 'name': 'Stressed', 'value': 4},
      {'emoji': '😰', 'name': 'Very Stressed', 'value': 5},
    ],
    'productivity': [
      {'emoji': '🚀', 'name': 'Super Productive', 'value': 5},
      {'emoji': '💪', 'name': 'Productive', 'value': 4},
      {'emoji': '👍', 'name': 'Average', 'value': 3},
      {'emoji': '😴', 'name': 'Low', 'value': 2},
      {'emoji': '🐌', 'name': 'Very Low', 'value': 1},
    ],
  };
  
  // Prompt Templates
  static const List<Map<String, dynamic>> promptTemplates = [
    {
      'name': 'Daily Review',
      'structure': [
        'What went well today?',
        'What could have gone better?',
        'What did I learn?',
        'What am I grateful for?',
        'What will I focus on tomorrow?',
      ],
      'estimated_time': 10,
    },
    {
      'name': 'Weekly Reflection',
      'structure': [
        'What were my biggest accomplishments this week?',
        'What challenges did I face and overcome?',
        'What patterns do I notice in my behavior?',
        'How did I grow this week?',
        'What are my priorities for next week?',
      ],
      'estimated_time': 20,
    },
    {
      'name': 'Goal Setting',
      'structure': [
        'What do I want to achieve in the next 30 days?',
        'Why is this important to me?',
        'What obstacles might I face?',
        'What resources do I have available?',
        'What is my first step?',
      ],
      'estimated_time': 15,
    },
  ];
  
  // Writing Analytics
  static const List<String> writingMetrics = [
    'total_words_written',
    'average_entry_length',
    'writing_streak',
    'entries_this_month',
    'most_productive_time',
    'common_themes',
    'sentiment_trend',
    'vocabulary_diversity',
  ];
  
  // Entry Privacy Levels
  static const String private = 'private';
  static const String shared = 'shared';
  static const String public = 'public';
  static const String encrypted = 'encrypted';
  
  // Export Formats
  static const List<Map<String, dynamic>> exportOptions = [
    {
      'format': 'pdf',
      'name': 'PDF Document',
      'description': 'Formatted journal entries in PDF',
      'includes': ['text', 'mood_charts', 'photos'],
    },
    {
      'format': 'docx',
      'name': 'Word Document',
      'description': 'Editable document format',
      'includes': ['text', 'basic_formatting'],
    },
    {
      'format': 'json',
      'name': 'JSON Data',
      'description': 'Raw data export for backup',
      'includes': ['all_data', 'metadata'],
    },
    {
      'format': 'csv',
      'name': 'Spreadsheet',
      'description': 'Data for analysis in Excel/Sheets',
      'includes': ['dates', 'moods', 'word_counts'],
    },
  ];
  
  // Journal Themes
  static const List<Map<String, dynamic>> journalThemes = [
    {
      'name': 'Classic',
      'colors': ['#8B4513', '#D2B48C', '#F5DEB3'],
      'fonts': ['serif'],
      'style': 'traditional',
    },
    {
      'name': 'Modern',
      'colors': ['#2C3E50', '#ECF0F1', '#3498DB'],
      'fonts': ['sans-serif'],
      'style': 'minimalist',
    },
    {
      'name': 'Nature',
      'colors': ['#27AE60', '#F39C12', '#E67E22'],
      'fonts': ['handwritten'],
      'style': 'organic',
    },
    {
      'name': 'Sunset',
      'colors': ['#FF6B6B', '#FFE66D', '#FF8E53'],
      'fonts': ['casual'],
      'style': 'warm',
    },
  ];
  
  // Attachment Types
  static const List<String> supportedAttachments = [
    'photos',
    'voice_recordings',
    'drawings',
    'documents',
    'links',
  ];
  
  // Voice-to-Text Features
  static const Map<String, dynamic> voiceFeatures = {
    'supported_languages': ['en', 'es', 'fr', 'de', 'zh', 'hi'],
    'max_recording_duration': 600, // 10 minutes
    'auto_transcription': true,
    'emotion_detection': true,
    'speaker_identification': false,
  };
  
  // Journal Challenges
  static const List<Map<String, dynamic>> journalChallenges = [
    {
      'name': '30-Day Gratitude',
      'description': 'Write three things you\'re grateful for each day',
      'duration': 30,
      'daily_target': 3,
      'reward_xp': 300,
    },
    {
      'name': 'Weekly Reflection',
      'description': 'Complete a weekly reflection for 4 weeks',
      'duration': 28,
      'weekly_target': 1,
      'reward_xp': 200,
    },
    {
      'name': 'Stream of Consciousness',
      'description': 'Write continuously for 10 minutes daily',
      'duration': 7,
      'daily_target': 10, // minutes
      'reward_xp': 150,
    },
  ];
  
  // Reminder Settings
  static const List<Map<String, String>> reminderTemplates = [
    {'time': 'morning', 'message': 'Start your day with reflection'},
    {'time': 'evening', 'message': 'How was your day? Capture your thoughts'},
    {'time': 'bedtime', 'message': 'Wind down with gratitude journaling'},
    {'time': 'custom', 'message': 'Time for your daily journal entry'},
  ];
  
  // Search and Tagging
  static const Map<String, dynamic> searchFeatures = {
    'full_text_search': true,
    'tag_search': true,
    'mood_filter': true,
    'date_range_filter': true,
    'auto_tagging': true,
    'smart_suggestions': true,
  };
  
  // Backup and Sync
  static const Map<String, dynamic> backupOptions = {
    'auto_backup': true,
    'cloud_sync': true,
    'local_backup': true,
    'backup_frequency': 'daily',
    'encryption': true,
  };
  
  // Notification Types
  static const String dailyReminder = 'daily_reminder';
  static const String streakReminder = 'streak_reminder';
  static const String weeklyReview = 'weekly_review';
  static const String moodCheckIn = 'mood_check_in';
  static const String promptSuggestion = 'prompt_suggestion';
  
  // Limits and Validations
  static const int maxEntryLength = 10000; // characters
  static const int minEntryLength = 10; // characters
  static const int maxTagsPerEntry = 20;
  static const int maxPhotosPerEntry = 10;
  static const int maxVoiceRecordingSeconds = 600;
  static const int maxEntriesPerDay = 20;
  static const int maxCustomPrompts = 100;
}
