class MeditationConstants {
  // Meditation Types
  static const String mindfulness = 'mindfulness';
  static const String concentration = 'concentration';
  static const String lovingKindness = 'loving_kindness';
  static const String bodySearch = 'body_search';
  static const String transcendental = 'transcendental';
  static const String visualization = 'visualization';
  static const String movement = 'movement';
  
  // Difficulty Levels
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';
  static const String expert = 'expert';
  
  // Duration Presets (in minutes)
  static const List<int> durationPresets = [3, 5, 10, 15, 20, 25, 30, 45, 60, 90];
  
  // Meditation Categories with 100k+ tracks
  static const List<Map<String, dynamic>> meditationCategories = [
    {
      'name': 'Mindfulness',
      'tracks': 25000,
      'color': '#2ECC71',
      'icon': 'psychology',
      'subcategories': ['breath_awareness', 'present_moment', 'observing_thoughts']
    },
    {
      'name': 'Sleep',
      'tracks': 20000,
      'color': '#9B59B6',
      'icon': 'bedtime',
      'subcategories': ['sleep_stories', 'body_scan', 'calming_sounds']
    },
    {
      'name': 'Stress Relief',
      'tracks': 18000,
      'color': '#E74C3C',
      'icon': 'spa',
      'subcategories': ['anxiety_relief', 'stress_management', 'emotional_balance']
    },
    {
      'name': 'Focus & Concentration',
      'tracks': 15000,
      'color': '#3498DB',
      'icon': 'center_focus_strong',
      'subcategories': ['attention_training', 'productivity_boost', 'mental_clarity']
    },
    {
      'name': 'Gratitude & Positivity',
      'tracks': 12000,
      'color': '#F39C12',
      'icon': 'favorite',
      'subcategories': ['gratitude_practice', 'positive_affirmations', 'self_compassion']
    },
  ];
  
  // Breathing Patterns
  static const List<Map<String, dynamic>> breathingPatterns = [
    {
      'name': '4-7-8 Breathing',
      'inhale': 4,
      'hold': 7,
      'exhale': 8,
      'cycles': 4,
      'description': 'Calming breath for sleep and anxiety'
    },
    {
      'name': 'Box Breathing',
      'inhale': 4,
      'hold': 4,
      'exhale': 4,
      'pause': 4,
      'cycles': 8,
      'description': 'Military technique for focus and calm'
    },
    {
      'name': 'Coherent Breathing',
      'inhale': 5,
      'hold': 0,
      'exhale': 5,
      'pause': 0,
      'cycles': 12,
      'description': 'Balances the nervous system'
    },
    {
      'name': 'Energizing Breath',
      'inhale': 3,
      'hold': 3,
      'exhale': 3,
      'pause': 0,
      'cycles': 10,
      'description': 'Increases alertness and energy'
    },
  ];
  
  // Breathing Bubble Visualization
  static const Map<String, dynamic> breathingBubble = {
    'min_size': 50.0,
    'max_size': 200.0,
    'animation_curve': 'ease_in_out',
    'colors': ['#3498DB', '#2ECC71', '#9B59B6', '#F39C12'],
  };
  
  // ASMR Sound Categories
  static const List<Map<String, dynamic>> asmrSounds = [
    {
      'category': 'Nature Sounds',
      'sounds': [
        {'name': 'Rain on Leaves', 'duration': 3600, 'file': 'rain_leaves.mp3'},
        {'name': 'Ocean Waves', 'duration': 3600, 'file': 'ocean_waves.mp3'},
        {'name': 'Forest Stream', 'duration': 3600, 'file': 'forest_stream.mp3'},
        {'name': 'Wind in Trees', 'duration': 3600, 'file': 'wind_trees.mp3'},
        {'name': 'Thunderstorm', 'duration': 3600, 'file': 'thunderstorm.mp3'},
      ]
    },
    {
      'category': 'Ambient Sounds',
      'sounds': [
        {'name': 'White Noise', 'duration': 3600, 'file': 'white_noise.mp3'},
        {'name': 'Pink Noise', 'duration': 3600, 'file': 'pink_noise.mp3'},
        {'name': 'Brown Noise', 'duration': 3600, 'file': 'brown_noise.mp3'},
        {'name': 'Binaural Beats', 'duration': 3600, 'file': 'binaural.mp3'},
      ]
    },
    {
      'category': 'Urban Sounds',
      'sounds': [
        {'name': 'Coffee Shop', 'duration': 3600, 'file': 'coffee_shop.mp3'},
        {'name': 'Library', 'duration': 3600, 'file': 'library.mp3'},
        {'name': 'Fireplace', 'duration': 3600, 'file': 'fireplace.mp3'},
        {'name': 'Train Journey', 'duration': 3600, 'file': 'train.mp3'},
      ]
    },
  ];
  
  // Custom ASMR Sound Mixing
  static const Map<String, dynamic> soundMixingSettings = {
    'max_layers': 5,
    'volume_range': {'min': 0.0, 'max': 1.0},
    'fade_duration': 3.0, // seconds
    'supported_formats': ['mp3', 'wav', 'ogg'],
    'max_file_size_mb': 50,
  };
  
  // Meditation Progress Metrics
  static const List<String> progressMetrics = [
    'total_sessions',
    'total_minutes',
    'current_streak',
    'longest_streak',
    'average_session_length',
    'consistency_rate',
    'mood_improvement',
    'stress_reduction',
  ];
  
  // Guided Meditation Scripts
  static const List<Map<String, dynamic>> guidedScripts = [
    {
      'title': 'Basic Mindfulness',
      'duration': 10,
      'script_segments': [
        {'time': 0, 'text': 'Find a comfortable position and close your eyes'},
        {'time': 30, 'text': 'Begin to notice your natural breath'},
        {'time': 120, 'text': 'When thoughts arise, gently return to the breath'},
        {'time': 480, 'text': 'Slowly wiggle your fingers and toes'},
        {'time': 570, 'text': 'Take three deep breaths and open your eyes'},
      ]
    },
    {
      'title': 'Body Scan Relaxation',
      'duration': 20,
      'script_segments': [
        {'time': 0, 'text': 'Lie down comfortably and close your eyes'},
        {'time': 60, 'text': 'Focus on the top of your head'},
        {'time': 240, 'text': 'Notice any sensations in your face and neck'},
        {'time': 480, 'text': 'Move attention to your shoulders and arms'},
        {'time': 720, 'text': 'Focus on your chest and breathing'},
        {'time': 960, 'text': 'Notice your abdomen and lower back'},
        {'time': 1140, 'text': 'Move to your hips and pelvis'},
        {'time': 1320, 'text': 'Focus on your legs and feet'},
      ]
    },
  ];
  
  // Meditation Challenges
  static const List<Map<String, dynamic>> challenges = [
    {
      'name': '7-Day Mindfulness',
      'description': 'Meditate for 10 minutes daily for a week',
      'duration': 7,
      'daily_target': 10,
      'reward_xp': 100,
    },
    {
      'name': '30-Day Consistency',
      'description': 'Build a meditation habit over 30 days',
      'duration': 30,
      'daily_target': 15,
      'reward_xp': 500,
    },
    {
      'name': 'Weekend Warrior',
      'description': 'Complete 30 minutes of meditation this weekend',
      'duration': 2,
      'total_target': 30,
      'reward_xp': 75,
    },
  ];
  
  // Meditation Environments
  static const List<Map<String, dynamic>> environments = [
    {'name': 'Peaceful Garden', 'image': 'garden.jpg', 'sounds': ['birds', 'water']},
    {'name': 'Mountain Peak', 'image': 'mountain.jpg', 'sounds': ['wind', 'silence']},
    {'name': 'Ocean Beach', 'image': 'beach.jpg', 'sounds': ['waves', 'seagulls']},
    {'name': 'Forest Clearing', 'image': 'forest.jpg', 'sounds': ['leaves', 'stream']},
    {'name': 'Cozy Room', 'image': 'room.jpg', 'sounds': ['fireplace', 'rain']},
  ];
  
  // Session Reminders
  static const List<Map<String, String>> reminderMessages = [
    {'time': 'morning', 'message': 'Start your day with mindful awareness'},
    {'time': 'afternoon', 'message': 'Take a moment to center yourself'},
    {'time': 'evening', 'message': 'Wind down with peaceful meditation'},
    {'time': 'bedtime', 'message': 'Prepare for restful sleep with meditation'},
  ];
  
  // Mood Tracking Integration
  static const List<String> preMeditationMoods = [
    'stressed',
    'anxious',
    'tired',
    'angry',
    'sad',
    'neutral',
    'calm',
    'happy',
  ];
  
  static const List<String> postMeditationMoods = [
    'peaceful',
    'centered',
    'refreshed',
    'grateful',
    'focused',
    'relaxed',
    'joyful',
    'energized',
  ];
  
  // Teacher/Guide Profiles
  static const List<Map<String, dynamic>> meditationTeachers = [
    {
      'name': 'Sarah Chen',
      'speciality': 'mindfulness',
      'experience': 15,
      'voice_style': 'calm_gentle',
      'tracks': 500,
    },
    {
      'name': 'Dr. Michael Ross',
      'speciality': 'stress_reduction',
      'experience': 20,
      'voice_style': 'authoritative_warm',
      'tracks': 300,
    },
    {
      'name': 'Luna Rivera',
      'speciality': 'sleep_meditation',
      'experience': 8,
      'voice_style': 'soothing_melodic',
      'tracks': 250,
    },
  ];
  
  // Binaural Beats Frequencies
  static const Map<String, Map<String, dynamic>> binauralBeats = {
    'delta': {'frequency': 2, 'benefit': 'Deep sleep, healing'},
    'theta': {'frequency': 6, 'benefit': 'Deep meditation, creativity'},
    'alpha': {'frequency': 10, 'benefit': 'Relaxation, light meditation'},
    'beta': {'frequency': 20, 'benefit': 'Focus, alertness'},
    'gamma': {'frequency': 40, 'benefit': 'High-level cognition'},
  };
  
  // Session Statistics
  static const List<String> sessionStats = [
    'heart_rate_before',
    'heart_rate_after',
    'stress_level_before',
    'stress_level_after',
    'focus_quality',
    'distractions_count',
    'session_rating',
  ];
  
  // Export Options
  static const List<String> exportFormats = [
    'meditation_log_csv',
    'progress_report_pdf',
    'session_summary_json',
    'achievement_certificate_pdf',
  ];
  
  // Integration Features
  static const Map<String, String> integrations = {
    'apple_health': 'mindful_minutes',
    'google_fit': 'meditation_session',
    'spotify': 'meditation_playlists',
    'calendar': 'meditation_appointments',
  };
  
  // Notification Types
  static const String sessionReminder = 'session_reminder';
  static const String streakReminder = 'streak_reminder';
  static const String challengeUpdate = 'challenge_update';
  static const String weeklyProgress = 'weekly_progress';
  static const String motivationalQuote = 'motivational_quote';
  
  // Limits and Validations
  static const int maxSessionDuration = 180; // 3 hours in minutes
  static const int minSessionDuration = 1; // 1 minute
  static const int maxCustomSounds = 10;
  static const int maxPlaylistSize = 100;
  static const int maxSessionsPerDay = 20;
  static const double maxVolumeLevel = 1.0;
  static const double minVolumeLevel = 0.0;
}
