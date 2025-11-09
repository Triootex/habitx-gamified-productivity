class ALIConstants {
  // ALI Modes
  static const String helpMode = 'help_mode';
  static const String coachMode = 'coach_mode';
  static const String agentMode = 'agent_mode';
  static const String tutorialMode = 'tutorial_mode';
  
  // Agent Mode Capabilities
  static const List<Map<String, dynamic>> agentCapabilities = [
    {
      'capability': 'Task Management',
      'description': 'Automatically create, organize, and schedule tasks',
      'permissions': ['calendar_access', 'notification_management'],
      'premium_only': true,
    },
    {
      'capability': 'Smart Reminders',
      'description': 'Context-aware reminders based on location and time',
      'permissions': ['location_access', 'calendar_access'],
      'premium_only': true,
    },
    {
      'capability': 'Email Integration',
      'description': 'Parse emails and create tasks automatically',
      'permissions': ['email_access', 'contact_access'],
      'premium_only': true,
    },
    {
      'capability': 'Health Monitoring',
      'description': 'Track health metrics and suggest improvements',
      'permissions': ['health_data_access', 'sensor_access'],
      'premium_only': false,
    },
    {
      'capability': 'Habit Optimization',
      'description': 'Analyze patterns and optimize habit schedules',
      'permissions': ['usage_analytics', 'device_sensors'],
      'premium_only': false,
    },
  ];
  
  // Conversation Context Types
  static const String taskHelp = 'task_help';
  static const String habitCoaching = 'habit_coaching';
  static const String motivationalSupport = 'motivational_support';
  static const String productivityAdvice = 'productivity_advice';
  static const String technicalSupport = 'technical_support';
  static const String goalSetting = 'goal_setting';
  static const String timeManagement = 'time_management';
  
  // Response Types
  static const String textResponse = 'text';
  static const String voiceResponse = 'voice';
  static const String actionResponse = 'action';
  static const String visualResponse = 'visual';
  static const String mixedResponse = 'mixed';
  
  // ALI Personality Traits
  static const Map<String, Map<String, dynamic>> personalityProfiles = {
    'supportive_coach': {
      'traits': ['encouraging', 'patient', 'understanding', 'motivational'],
      'tone': 'warm and supportive',
      'response_style': 'detailed explanations with encouragement',
    },
    'efficient_assistant': {
      'traits': ['direct', 'organized', 'result_oriented', 'practical'],
      'tone': 'professional and concise',
      'response_style': 'brief and actionable advice',
    },
    'friendly_companion': {
      'traits': ['casual', 'humorous', 'relatable', 'conversational'],
      'tone': 'friendly and approachable',
      'response_style': 'casual conversation with helpful tips',
    },
    'wise_mentor': {
      'traits': ['thoughtful', 'insightful', 'philosophical', 'experienced'],
      'tone': 'calm and reflective',
      'response_style': 'deep insights with life lessons',
    },
  };
  
  // Knowledge Domains
  static const List<Map<String, dynamic>> knowledgeDomains = [
    {
      'domain': 'Productivity Techniques',
      'topics': [
        'pomodoro_technique',
        'getting_things_done',
        'time_blocking',
        'eisenhower_matrix',
        'kanban_method',
      ],
      'expertise_level': 'expert',
    },
    {
      'domain': 'Habit Formation',
      'topics': [
        'habit_stacking',
        'atomic_habits',
        'behavioral_psychology',
        'habit_loops',
        'environmental_design',
      ],
      'expertise_level': 'expert',
    },
    {
      'domain': 'Mental Health',
      'topics': [
        'stress_management',
        'mindfulness',
        'cognitive_behavioral_therapy',
        'emotional_regulation',
        'self_care',
      ],
      'expertise_level': 'intermediate',
    },
    {
      'domain': 'Physical Wellness',
      'topics': [
        'exercise_physiology',
        'nutrition_basics',
        'sleep_hygiene',
        'ergonomics',
        'movement_patterns',
      ],
      'expertise_level': 'intermediate',
    },
    {
      'domain': 'Goal Setting',
      'topics': [
        'smart_goals',
        'okr_framework',
        'milestone_planning',
        'progress_tracking',
        'accountability_systems',
      ],
      'expertise_level': 'expert',
    },
  ];
  
  // Coaching Strategies
  static const List<Map<String, dynamic>> coachingStrategies = [
    {
      'strategy': 'Socratic Questioning',
      'description': 'Help users discover solutions through guided questions',
      'use_cases': ['problem_solving', 'goal_clarification', 'self_reflection'],
    },
    {
      'strategy': 'Positive Reinforcement',
      'description': 'Acknowledge and celebrate user achievements',
      'use_cases': ['habit_building', 'motivation_boost', 'progress_recognition'],
    },
    {
      'strategy': 'Cognitive Reframing',
      'description': 'Help users view challenges from different perspectives',
      'use_cases': ['overcoming_obstacles', 'stress_reduction', 'mindset_shifts'],
    },
    {
      'strategy': 'Behavioral Activation',
      'description': 'Encourage engagement in meaningful activities',
      'use_cases': ['depression_support', 'energy_building', 'routine_establishment'],
    },
    {
      'strategy': 'Implementation Intentions',
      'description': 'Help create specific if-then plans',
      'use_cases': ['habit_formation', 'goal_achievement', 'behavior_change'],
    },
  ];
  
  // Conversation Templates
  static const Map<String, List<String>> conversationTemplates = {
    'greeting': [
      "Hello! I'm ALI, your personal productivity assistant. How can I help you today?",
      "Hi there! Ready to tackle some goals together?",
      "Good {time_of_day}! What would you like to work on today?",
    ],
    'task_suggestion': [
      "Based on your patterns, I think you might want to work on {task_category} today.",
      "You've been making great progress with {habit_name}. Ready for today's session?",
      "I notice it's your most productive time. How about tackling {high_priority_task}?",
    ],
    'motivation': [
      "You've completed {completed_tasks} tasks this week - that's amazing progress!",
      "Remember, every small step counts toward your bigger goals.",
      "You've got this! I believe in your ability to achieve {current_goal}.",
    ],
    'coaching': [
      "What's the biggest challenge you're facing with {current_struggle}?",
      "Let's break this down into smaller, manageable steps.",
      "What worked well for you the last time you faced something similar?",
    ],
  };
  
  // Context Understanding
  static const List<Map<String, dynamic>> contextFactors = [
    {
      'factor': 'Time of Day',
      'impact': 'Adjust energy level and activity suggestions',
      'data_sources': ['device_clock', 'user_schedule'],
    },
    {
      'factor': 'User Mood',
      'impact': 'Tailor communication style and suggestions',
      'data_sources': ['mood_entries', 'activity_patterns'],
    },
    {
      'factor': 'Recent Activity',
      'impact': 'Provide relevant follow-up suggestions',
      'data_sources': ['task_history', 'app_usage'],
    },
    {
      'factor': 'Goal Progress',
      'impact': 'Adjust coaching intensity and focus areas',
      'data_sources': ['goal_tracking', 'habit_data'],
    },
    {
      'factor': 'Stress Level',
      'impact': 'Modify suggestion difficulty and support level',
      'data_sources': ['self_reported_stress', 'behavior_indicators'],
    },
  ];
  
  // Learning Mechanisms
  static const List<Map<String, dynamic>> learningCapabilities = [
    {
      'capability': 'User Preference Learning',
      'description': 'Adapt to user communication and suggestion preferences',
      'implementation': 'reinforcement_learning',
    },
    {
      'capability': 'Pattern Recognition',
      'description': 'Identify user behavior patterns and optimal intervention times',
      'implementation': 'time_series_analysis',
    },
    {
      'capability': 'Effectiveness Tracking',
      'description': 'Monitor which suggestions lead to positive outcomes',
      'implementation': 'outcome_correlation_analysis',
    },
    {
      'capability': 'Continuous Improvement',
      'description': 'Refine coaching strategies based on user feedback',
      'implementation': 'feedback_integration_system',
    },
  ];
  
  // Voice Features
  static const Map<String, dynamic> voiceCapabilities = {
    'speech_recognition': {
      'supported_languages': ['en', 'es', 'fr', 'de', 'hi', 'zh'],
      'accuracy_threshold': 0.85,
      'noise_cancellation': true,
    },
    'text_to_speech': {
      'voice_options': ['male', 'female', 'neutral'],
      'emotion_variation': true,
      'speed_control': true,
      'pitch_control': false,
    },
    'conversation_flow': {
      'interrupt_handling': true,
      'context_retention': true,
      'multi_turn_conversations': true,
    },
  };
  
  // Integration Capabilities
  static const List<Map<String, dynamic>> integrationOptions = [
    {
      'platform': 'Calendar Apps',
      'capabilities': ['event_creation', 'schedule_analysis', 'conflict_detection'],
      'permissions': ['calendar_read', 'calendar_write'],
    },
    {
      'platform': 'Email Clients',
      'capabilities': ['task_extraction', 'priority_assessment', 'follow_up_scheduling'],
      'permissions': ['email_read', 'contact_access'],
    },
    {
      'platform': 'Health Apps',
      'capabilities': ['activity_tracking', 'sleep_analysis', 'wellness_recommendations'],
      'permissions': ['health_data', 'sensor_access'],
    },
    {
      'platform': 'Smart Home',
      'capabilities': ['environment_optimization', 'routine_automation', 'context_awareness'],
      'permissions': ['device_control', 'location_access'],
    },
  ];
  
  // Proactive Intervention Triggers
  static const List<Map<String, dynamic>> interventionTriggers = [
    {
      'trigger': 'Streak Risk',
      'condition': 'habit_completion_risk > 0.7',
      'action': 'send_motivational_reminder',
      'timing': '2_hours_before_deadline',
    },
    {
      'trigger': 'Productivity Dip',
      'condition': 'task_completion_rate < 0.5 for 3_days',
      'action': 'suggest_productivity_reset',
      'timing': 'next_morning',
    },
    {
      'trigger': 'Goal Stagnation',
      'condition': 'no_progress_for_7_days',
      'action': 'initiate_goal_review_conversation',
      'timing': 'user_preferred_coaching_time',
    },
    {
      'trigger': 'Stress Detection',
      'condition': 'stress_indicators > threshold',
      'action': 'offer_stress_relief_activities',
      'timing': 'immediate',
    },
  ];
  
  // Privacy and Ethics
  static const Map<String, dynamic> privacySettings = {
    'data_retention_days': 90,
    'conversation_encryption': true,
    'anonymous_analytics': true,
    'opt_out_options': [
      'personalization',
      'proactive_suggestions',
      'voice_processing',
      'integration_access',
    ],
  };
  
  // Performance Metrics
  static const List<String> performanceMetrics = [
    'response_accuracy',
    'user_satisfaction_score',
    'goal_achievement_correlation',
    'engagement_improvement',
    'feature_adoption_rate',
    'conversation_completion_rate',
  ];
  
  // Fallback Responses
  static const List<String> fallbackResponses = [
    "I'm not sure I understand that completely. Could you rephrase it?",
    "That's an interesting question. Let me think about how I can help you with that.",
    "I'm still learning about that topic. Would you like me to help you find relevant resources?",
    "I want to make sure I give you the best advice. Can you provide a bit more context?",
  ];
  
  // Conversation Limits
  static const int maxConversationLength = 50; // messages per session
  static const int maxDailyInteractions = 100;
  static const int responseTimeoutSeconds = 30;
  static const int contextMemoryDays = 7;
  
  // Feature Access Levels
  static const Map<String, List<String>> featureAccess = {
    'free': [
      'basic_conversations',
      'simple_suggestions',
      'habit_reminders',
      'progress_celebrations',
    ],
    'premium': [
      'agent_mode',
      'proactive_interventions',
      'voice_interactions',
      'advanced_integrations',
      'personalized_coaching',
      'unlimited_conversations',
    ],
  };
  
  // Notification Types
  static const String coachingReminder = 'coaching_reminder';
  static const String goalCheckIn = 'goal_check_in';
  static const String motivationalMessage = 'motivational_message';
  static const String productivityTip = 'productivity_tip';
  static const String habitNudge = 'habit_nudge';
  static const String agentAction = 'agent_action';
  
  // Response Time Expectations
  static const Map<String, int> responseTimeMs = {
    'simple_query': 500,
    'complex_analysis': 2000,
    'agent_action': 5000,
    'voice_processing': 1500,
  };
}
