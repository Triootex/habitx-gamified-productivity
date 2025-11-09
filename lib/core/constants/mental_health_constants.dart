class MentalHealthConstants {
  // Mental Health Categories
  static const String stress = 'stress';
  static const String anxiety = 'anxiety';
  static const String depression = 'depression';
  static const String mood = 'mood';
  static const String selfEsteem = 'self_esteem';
  static const String relationships = 'relationships';
  static const String workLife = 'work_life';
  
  // Mood Levels
  static const Map<int, String> moodLevels = {
    1: 'Very Low',
    2: 'Low', 
    3: 'Neutral',
    4: 'Good',
    5: 'Excellent',
  };
  
  // Emotion Categories
  static const List<Map<String, dynamic>> emotionCategories = [
    {
      'category': 'Joy',
      'emotions': ['happy', 'excited', 'grateful', 'content', 'optimistic'],
      'color': '#F1C40F'
    },
    {
      'category': 'Sadness', 
      'emotions': ['sad', 'disappointed', 'lonely', 'hopeless', 'grief'],
      'color': '#3498DB'
    },
    {
      'category': 'Anger',
      'emotions': ['angry', 'frustrated', 'irritated', 'annoyed', 'furious'],
      'color': '#E74C3C'
    },
    {
      'category': 'Fear',
      'emotions': ['scared', 'anxious', 'worried', 'nervous', 'panicked'],
      'color': '#9B59B6'
    },
    {
      'category': 'Surprise',
      'emotions': ['surprised', 'shocked', 'amazed', 'confused', 'bewildered'],
      'color': '#E67E22'
    },
    {
      'category': 'Disgust',
      'emotions': ['disgusted', 'repulsed', 'revolted', 'nauseated', 'sickened'],
      'color': '#27AE60'
    },
  ];
  
  // Meditation Types
  static const List<Map<String, dynamic>> meditationTypes = [
    {
      'type': 'Mindfulness',
      'description': 'Focus on present moment awareness',
      'durations': [5, 10, 15, 20, 30],
      'difficulty': 'beginner'
    },
    {
      'type': 'Loving Kindness',
      'description': 'Cultivate compassion and love',
      'durations': [10, 15, 20, 25],
      'difficulty': 'intermediate'
    },
    {
      'type': 'Body Scan',
      'description': 'Progressive relaxation technique',
      'durations': [15, 20, 30, 45],
      'difficulty': 'beginner'
    },
    {
      'type': 'Breath Focus',
      'description': 'Concentrate on breathing patterns',
      'durations': [5, 10, 15, 20],
      'difficulty': 'beginner'
    },
  ];
  
  // Breathing Exercises
  static const List<Map<String, dynamic>> breathingExercises = [
    {
      'name': '4-7-8 Breathing',
      'description': 'Inhale 4s, hold 7s, exhale 8s',
      'inhale': 4,
      'hold': 7,
      'exhale': 8,
      'cycles': 4
    },
    {
      'name': 'Box Breathing',
      'description': 'Equal timing for all phases',
      'inhale': 4,
      'hold': 4,
      'exhale': 4,
      'pause': 4,
      'cycles': 5
    },
    {
      'name': 'Coherent Breathing',
      'description': 'Balanced breathing for coherence',
      'inhale': 5,
      'hold': 0,
      'exhale': 5,
      'cycles': 10
    },
  ];
  
  // CBT (Cognitive Behavioral Therapy) Activities
  static const List<Map<String, dynamic>> cbtActivities = [
    {
      'name': 'Thought Record',
      'description': 'Track and challenge negative thoughts',
      'fields': ['situation', 'emotion', 'thought', 'evidence', 'balanced_thought']
    },
    {
      'name': 'Mood Tracking',
      'description': 'Monitor daily mood patterns',
      'fields': ['mood_level', 'triggers', 'activities', 'notes']
    },
    {
      'name': 'Behavioral Activation',
      'description': 'Schedule pleasant activities',
      'fields': ['activity', 'enjoyment', 'mastery', 'completion']
    },
    {
      'name': 'Cognitive Restructuring',
      'description': 'Identify and change thought patterns',
      'fields': ['automatic_thought', 'emotion', 'alternative_thought', 'new_emotion']
    },
  ];
  
  // Crisis Resources (SOS Tools)
  static const List<Map<String, dynamic>> crisisResources = [
    {
      'name': 'National Suicide Prevention Lifeline',
      'number': '1800-599-0019',
      'description': '24/7 crisis support',
      'country': 'India'
    },
    {
      'name': 'Vandrevala Foundation',
      'number': '1860-2662-345',
      'description': 'Mental health support',
      'country': 'India'
    },
    {
      'name': 'Aasra',
      'number': '91-22-27546669',
      'description': 'Suicide prevention',
      'country': 'India'
    },
  ];
  
  // Coping Strategies
  static const List<Map<String, dynamic>> copingStrategies = [
    {
      'category': 'Immediate Relief',
      'strategies': [
        'Deep breathing',
        'Progressive muscle relaxation',
        'Grounding techniques (5-4-3-2-1)',
        'Cold water on face',
        'Listen to calming music'
      ]
    },
    {
      'category': 'Long-term Management',
      'strategies': [
        'Regular exercise',
        'Healthy sleep schedule',
        'Social connections',
        'Journaling',
        'Professional therapy'
      ]
    },
  ];
  
  // Sleep Stories Categories
  static const List<Map<String, dynamic>> sleepStories = [
    {
      'category': 'Nature',
      'stories': [
        {'title': 'Forest Walk', 'duration': 25, 'narrator': 'calm_voice'},
        {'title': 'Ocean Journey', 'duration': 30, 'narrator': 'soothing_voice'},
        {'title': 'Mountain Peace', 'duration': 20, 'narrator': 'gentle_voice'},
      ]
    },
    {
      'category': 'Fantasy',
      'stories': [
        {'title': 'Magical Garden', 'duration': 35, 'narrator': 'mystical_voice'},
        {'title': 'Starlight Adventure', 'duration': 40, 'narrator': 'dreamy_voice'},
        {'title': 'Cloud Castle', 'duration': 28, 'narrator': 'soft_voice'},
      ]
    },
  ];
  
  // Stress Levels
  static const Map<String, Map<String, dynamic>> stressLevels = {
    'low': {'color': '#2ECC71', 'description': 'Minimal stress, feeling calm'},
    'moderate': {'color': '#F39C12', 'description': 'Some pressure but manageable'},
    'high': {'color': '#E74C3C', 'description': 'Significant stress, need coping'},
    'extreme': {'color': '#8E44AD', 'description': 'Overwhelming, seek help'},
  };
  
  // Therapy Types
  static const List<String> therapyTypes = [
    'cognitive_behavioral_therapy',
    'dialectical_behavior_therapy',
    'acceptance_commitment_therapy',
    'mindfulness_based_therapy',
    'interpersonal_therapy',
    'psychodynamic_therapy',
  ];
  
  // Mental Health Assessments
  static const List<Map<String, dynamic>> assessments = [
    {
      'name': 'PHQ-9',
      'description': 'Depression screening',
      'questions': 9,
      'type': 'depression'
    },
    {
      'name': 'GAD-7',
      'description': 'Anxiety screening',
      'questions': 7,
      'type': 'anxiety'
    },
    {
      'name': 'Stress Scale',
      'description': 'Perceived stress level',
      'questions': 10,
      'type': 'stress'
    },
  ];
  
  // Mindfulness Activities
  static const List<Map<String, dynamic>> mindfulnessActivities = [
    {
      'name': 'Mindful Walking',
      'description': 'Focus on each step and breath',
      'duration': 10,
      'difficulty': 'easy'
    },
    {
      'name': 'Mindful Eating',
      'description': 'Pay attention to taste and texture',
      'duration': 15,
      'difficulty': 'easy'
    },
    {
      'name': 'Loving Kindness',
      'description': 'Send compassion to self and others',
      'duration': 20,
      'difficulty': 'medium'
    },
  ];
  
  // Emotional Triggers
  static const List<String> commonTriggers = [
    'work_pressure',
    'relationship_conflict',
    'financial_stress',
    'health_concerns',
    'social_situations',
    'family_issues',
    'time_pressure',
    'perfectionism',
  ];
  
  // Wellness Goals
  static const List<Map<String, dynamic>> wellnessGoals = [
    {
      'goal': 'Practice daily meditation',
      'category': 'mindfulness',
      'frequency': 'daily',
      'target': 10 // minutes
    },
    {
      'goal': 'Journal 3 gratitudes',
      'category': 'positivity',
      'frequency': 'daily',
      'target': 3 // entries
    },
    {
      'goal': 'Connect with friend/family',
      'category': 'social',
      'frequency': 'weekly',
      'target': 1 // interaction
    },
  ];
  
  // Progress Tracking Metrics
  static const List<String> progressMetrics = [
    'mood_trend',
    'stress_reduction',
    'coping_skill_usage',
    'meditation_consistency',
    'sleep_quality_correlation',
    'trigger_awareness',
  ];
  
  // Notification Types
  static const String moodCheckIn = 'mood_check_in';
  static const String meditationReminder = 'meditation_reminder';
  static const String breathingExercise = 'breathing_exercise';
  static const String copingStrategy = 'coping_strategy';
  static const String wellnessGoal = 'wellness_goal';
  
  // Data Privacy Settings
  static const String anonymousSharing = 'anonymous_sharing';
  static const String researchParticipation = 'research_participation';
  static const String professionalAccess = 'professional_access';
  
  // Limits and Validations
  static const int maxJournalEntryLength = 2000;
  static const int maxDailyMoodEntries = 10;
  static const int minMeditationDuration = 1; // minutes
  static const int maxMeditationDuration = 120; // minutes
  static const int maxCopingStrategies = 20;
}
