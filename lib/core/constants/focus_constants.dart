class FocusConstants {
  // Focus Techniques
  static const String pomodoroTechnique = 'pomodoro';
  static const String timeBlocking = 'time_blocking';
  static const String flowtime = 'flowtime';
  static const String ultradian = 'ultradian';
  static const String customTimer = 'custom_timer';
  
  // Pomodoro Settings
  static const Map<String, int> pomodoroDefaults = {
    'work_duration': 25, // minutes
    'short_break': 5, // minutes  
    'long_break': 15, // minutes
    'sessions_until_long_break': 4,
  };
  
  // Focus Session Types
  static const String deepWork = 'deep_work';
  static const String learning = 'learning';
  static const String creative = 'creative';
  static const String administrative = 'administrative';
  static const String planning = 'planning';
  
  // Distraction Categories
  static const List<Map<String, dynamic>> distractionTypes = [
    {
      'type': 'digital',
      'name': 'Digital Distractions',
      'sources': ['social_media', 'notifications', 'emails', 'youtube'],
      'blocking_methods': ['app_blocking', 'website_blocking', 'notification_silence']
    },
    {
      'type': 'environmental',
      'name': 'Environmental',
      'sources': ['noise', 'interruptions', 'uncomfortable_workspace'],
      'blocking_methods': ['noise_cancelling', 'do_not_disturb', 'workspace_optimization']
    },
    {
      'type': 'internal',
      'name': 'Internal Distractions',
      'sources': ['wandering_thoughts', 'hunger', 'fatigue', 'stress'],
      'blocking_methods': ['mindfulness', 'proper_nutrition', 'breaks', 'stress_management']
    },
  ];
  
  // Forest/Tree Growth System
  static const List<Map<String, dynamic>> treeTypes = [
    {
      'name': 'Oak Tree',
      'growth_stages': ['seed', 'sprout', 'sapling', 'young_tree', 'mature_oak'],
      'min_session': 15,
      'max_session': 120,
      'unlock_requirement': 0,
      'xp_multiplier': 1.0,
    },
    {
      'name': 'Cherry Blossom',
      'growth_stages': ['bud', 'bloom', 'full_blossom', 'petal_fall', 'fruit_tree'],
      'min_session': 10,
      'max_session': 60,
      'unlock_requirement': 5,
      'xp_multiplier': 1.2,
    },
    {
      'name': 'Pine Tree',
      'growth_stages': ['cone', 'needling', 'small_pine', 'tall_pine', 'ancient_pine'],
      'min_session': 30,
      'max_session': 180,
      'unlock_requirement': 20,
      'xp_multiplier': 1.5,
    },
    {
      'name': 'Bamboo',
      'growth_stages': ['shoot', 'young_bamboo', 'growing', 'tall_bamboo', 'bamboo_forest'],
      'min_session': 5,
      'max_session': 45,
      'unlock_requirement': 10,
      'xp_multiplier': 0.8,
    },
  ];
  
  // Focus Environments
  static const List<Map<String, dynamic>> focusEnvironments = [
    {
      'name': 'Library',
      'ambient_sounds': ['page_turning', 'soft_footsteps', 'whispers'],
      'visual_theme': 'warm_brown_tones',
      'lighting': 'soft_yellow',
    },
    {
      'name': 'Coffee Shop',
      'ambient_sounds': ['coffee_machine', 'gentle_chatter', 'jazz_music'],
      'visual_theme': 'cozy_cafe',
      'lighting': 'natural_daylight',
    },
    {
      'name': 'Forest',
      'ambient_sounds': ['bird_songs', 'rustling_leaves', 'distant_water'],
      'visual_theme': 'green_nature',
      'lighting': 'filtered_sunlight',
    },
    {
      'name': 'Rain',
      'ambient_sounds': ['rain_drops', 'gentle_thunder', 'wind'],
      'visual_theme': 'grey_blue_tones',
      'lighting': 'dim_cloudy',
    },
    {
      'name': 'Ocean',
      'ambient_sounds': ['wave_sounds', 'seagulls', 'wind'],
      'visual_theme': 'blue_ocean',
      'lighting': 'bright_natural',
    },
  ];
  
  // Session Reports Components
  static const List<Map<String, dynamic>> sessionMetrics = [
    {
      'metric': 'focus_score',
      'name': 'Focus Quality',
      'description': 'Overall concentration level during session',
      'scale': 100,
      'calculation': 'session_time - distraction_time',
    },
    {
      'metric': 'productivity_rating',
      'name': 'Productivity',
      'description': 'Self-rated productivity level',
      'scale': 10,
      'calculation': 'user_rating',
    },
    {
      'metric': 'distraction_count',
      'name': 'Distractions',
      'description': 'Number of times focus was broken',
      'scale': 'count',
      'calculation': 'interruption_events',
    },
    {
      'metric': 'flow_state_time',
      'name': 'Flow State',
      'description': 'Time spent in deep focus',
      'scale': 'minutes',
      'calculation': 'continuous_focus_periods',
    },
  ];
  
  // Gamified Trees Features
  static const Map<String, dynamic> treeGrowthMechanics = {
    'growth_factors': [
      'session_duration',
      'consistency',
      'focus_quality',
      'streak_bonus',
    ],
    'special_trees': {
      'golden_oak': {
        'unlock': 'complete_100_sessions',
        'bonus': 'double_xp',
        'rarity': 'legendary',
      },
      'crystal_pine': {
        'unlock': '30_day_streak',
        'bonus': 'bonus_gems',
        'rarity': 'epic',
      },
    },
    'seasonal_events': {
      'spring_bloom': 'cherry_blossoms_bloom_faster',
      'autumn_harvest': 'fruit_trees_give_bonus_rewards',
      'winter_frost': 'pine_trees_grow_stronger',
    },
  };
  
  // Task-Pomodoro Hybrid Features
  static const Map<String, dynamic> taskIntegration = {
    'task_estimation': {
      'default_pomodoros_per_task': 2,
      'estimation_accuracy_tracking': true,
      'learning_algorithm': 'adjust_based_on_history',
    },
    'task_breakdown': {
      'auto_split_large_tasks': true,
      'max_pomodoros_per_subtask': 4,
      'complexity_assessment': true,
    },
    'completion_tracking': {
      'partial_completion': true,
      'overflow_handling': 'continue_or_defer',
      'quality_rating': true,
    },
  };
  
  // Focus Challenges
  static const List<Map<String, dynamic>> focusChallenges = [
    {
      'name': 'Deep Work Week',
      'description': 'Complete 5 hours of deep focus this week',
      'target': 300, // minutes
      'duration': 7, // days
      'reward_xp': 200,
      'difficulty': 'medium',
    },
    {
      'name': 'Pomodoro Master',
      'description': 'Complete 25 pomodoro sessions',
      'target': 25,
      'duration': 30,
      'reward_xp': 150,
      'difficulty': 'easy',
    },
    {
      'name': 'Flow State',
      'description': 'Maintain focus for 2 hours straight',
      'target': 120,
      'duration': 1,
      'reward_xp': 300,
      'difficulty': 'hard',
    },
  ];
  
  // Productivity Techniques
  static const List<Map<String, dynamic>> productivityMethods = [
    {
      'name': 'Getting Things Done (GTD)',
      'description': 'Capture, clarify, organize, reflect, engage',
      'focus_component': 'time_blocking_for_contexts',
    },
    {
      'name': 'Time Blocking',
      'description': 'Schedule specific time blocks for different activities',
      'focus_component': 'dedicated_focus_blocks',
    },
    {
      'name': 'Eat the Frog',
      'description': 'Do the most important task first',
      'focus_component': 'morning_deep_work_session',
    },
    {
      'name': 'Two-Minute Rule',
      'description': 'If it takes less than 2 minutes, do it now',
      'focus_component': 'quick_task_clearing',
    },
  ];
  
  // Break Activities
  static const List<Map<String, dynamic>> breakActivities = [
    {
      'category': 'Physical',
      'activities': [
        {'name': 'Stretch', 'duration': 5, 'energy_level': 'low'},
        {'name': 'Walk', 'duration': 10, 'energy_level': 'medium'},
        {'name': 'Exercise', 'duration': 15, 'energy_level': 'high'},
      ]
    },
    {
      'category': 'Mental',
      'activities': [
        {'name': 'Meditate', 'duration': 5, 'energy_level': 'low'},
        {'name': 'Breathing Exercise', 'duration': 3, 'energy_level': 'low'},
        {'name': 'Quick Puzzle', 'duration': 8, 'energy_level': 'medium'},
      ]
    },
    {
      'category': 'Social',
      'activities': [
        {'name': 'Chat with Friend', 'duration': 10, 'energy_level': 'medium'},
        {'name': 'Team Check-in', 'duration': 15, 'energy_level': 'medium'},
      ]
    },
  ];
  
  // Focus Music Categories
  static const List<Map<String, dynamic>> focusMusic = [
    {
      'category': 'Instrumental',
      'subcategories': ['classical', 'ambient', 'electronic', 'piano'],
      'characteristics': ['no_lyrics', 'steady_rhythm', 'non_distracting'],
    },
    {
      'category': 'Nature Sounds',
      'subcategories': ['rain', 'ocean', 'forest', 'thunderstorm'],
      'characteristics': ['white_noise', 'calming', 'consistent'],
    },
    {
      'category': 'Binaural Beats',
      'subcategories': ['alpha_waves', 'beta_waves', 'theta_waves'],
      'characteristics': ['scientifically_designed', 'focus_enhancement'],
    },
  ];
  
  // Distraction Blocking
  static const Map<String, dynamic> distractionBlocking = {
    'website_blocking': {
      'default_blocked_sites': [
        'facebook.com',
        'twitter.com',
        'youtube.com',
        'instagram.com',
        'tiktok.com',
        'reddit.com',
      ],
      'custom_blocking': true,
      'temporary_access': 'with_penalty',
    },
    'app_blocking': {
      'social_media_apps': true,
      'gaming_apps': true,
      'entertainment_apps': true,
      'custom_selection': true,
    },
    'notification_management': {
      'silence_all': true,
      'whitelist_important': true,
      'emergency_bypass': true,
    },
  };
  
  // Analytics and Insights
  static const List<String> focusAnalytics = [
    'daily_focus_time',
    'weekly_patterns',
    'most_productive_hours',
    'average_session_length',
    'distraction_frequency',
    'task_completion_rate',
    'focus_streak',
    'improvement_trends',
  ];
  
  // Custom Timer Presets
  static const List<Map<String, dynamic>> timerPresets = [
    {'name': 'Quick Focus', 'work': 15, 'break': 5},
    {'name': 'Standard Pomodoro', 'work': 25, 'break': 5},
    {'name': 'Extended Focus', 'work': 45, 'break': 10},
    {'name': 'Deep Work', 'work': 90, 'break': 20},
    {'name': 'Power Hour', 'work': 60, 'break': 15},
  ];
  
  // Achievement System
  static const List<Map<String, dynamic>> focusAchievements = [
    {
      'name': 'First Focus',
      'description': 'Complete your first focus session',
      'requirement': 'complete_1_session',
      'reward_xp': 25,
    },
    {
      'name': 'Tree Planter',
      'description': 'Grow your first virtual tree',
      'requirement': 'complete_tree_growth',
      'reward_xp': 50,
    },
    {
      'name': 'Focus Warrior',
      'description': 'Complete 100 focus sessions',
      'requirement': 'complete_100_sessions',
      'reward_xp': 500,
    },
    {
      'name': 'Distraction Defeater',
      'description': 'Complete a session with zero distractions',
      'requirement': 'zero_distraction_session',
      'reward_xp': 100,
    },
  ];
  
  // Notification Types
  static const String sessionStart = 'session_start';
  static const String breakTime = 'break_time';
  static const String sessionComplete = 'session_complete';
  static const String dailyGoalReminder = 'daily_goal_reminder';
  static const String streakReminder = 'streak_reminder';
  
  // Limits and Validations
  static const int maxSessionDuration = 240; // 4 hours in minutes
  static const int minSessionDuration = 5; // 5 minutes
  static const int maxBreakDuration = 60; // 1 hour
  static const int minBreakDuration = 1; // 1 minute
  static const int maxCustomTimers = 20;
  static const int maxTreesPerForest = 100;
  static const int maxSessionsPerDay = 50;
}
