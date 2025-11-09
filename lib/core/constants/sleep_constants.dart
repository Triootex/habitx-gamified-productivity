class SleepConstants {
  // Sleep Phases
  static const String awake = 'awake';
  static const String lightSleep = 'light_sleep';
  static const String deepSleep = 'deep_sleep';
  static const String remSleep = 'rem_sleep';
  
  // Sleep Quality Levels
  static const String poor = 'poor';
  static const String fair = 'fair';
  static const String good = 'good';
  static const String excellent = 'excellent';
  
  // Sleep Goals
  static const Map<String, int> recommendedSleepDuration = {
    'teenager': 9 * 60, // 9 hours in minutes
    'adult': 8 * 60, // 8 hours in minutes
    'elderly': 7 * 60, // 7 hours in minutes
  };
  
  // Sleep Phase Durations (in minutes)
  static const Map<String, Map<String, int>> typicalPhaseDurations = {
    'light_sleep': {'min': 10, 'max': 25},
    'deep_sleep': {'min': 45, 'max': 120},
    'rem_sleep': {'min': 10, 'max': 60},
  };
  
  // Smart Alarm Settings
  static const int smartAlarmWindow = 30; // minutes
  static const int minSleepBeforeAlarm = 4 * 60; // 4 hours
  static const int maxSnoozeCount = 3;
  static const int snoozeInterval = 9; // minutes
  
  // Sleep Tracking Methods
  static const String motion = 'motion';
  static const String sound = 'sound';
  static const String heartRate = 'heart_rate';
  static const String manual = 'manual';
  static const String sonar = 'sonar';
  
  // Bedtime Routine Categories
  static const List<Map<String, dynamic>> routineCategories = [
    {'name': 'Relaxation', 'color': '#9B59B6', 'icon': 'spa'},
    {'name': 'Reading', 'color': '#3498DB', 'icon': 'book'},
    {'name': 'Meditation', 'color': '#E74C3C', 'icon': 'self_improvement'},
    {'name': 'Skincare', 'color': '#F39C12', 'icon': 'face'},
    {'name': 'Stretching', 'color': '#2ECC71', 'icon': 'accessibility'},
    {'name': 'Music', 'color': '#1ABC9C', 'icon': 'music_note'},
  ];
  
  // Sleep Sounds Categories
  static const List<Map<String, dynamic>> sleepSounds = [
    {
      'category': 'Nature',
      'sounds': [
        {'name': 'Rain', 'file': 'rain.mp3', 'duration': 3600},
        {'name': 'Ocean Waves', 'file': 'ocean.mp3', 'duration': 3600},
        {'name': 'Forest', 'file': 'forest.mp3', 'duration': 3600},
        {'name': 'Thunderstorm', 'file': 'thunder.mp3', 'duration': 3600},
      ]
    },
    {
      'category': 'White Noise',
      'sounds': [
        {'name': 'White Noise', 'file': 'white_noise.mp3', 'duration': 3600},
        {'name': 'Pink Noise', 'file': 'pink_noise.mp3', 'duration': 3600},
        {'name': 'Brown Noise', 'file': 'brown_noise.mp3', 'duration': 3600},
        {'name': 'Fan Sound', 'file': 'fan.mp3', 'duration': 3600},
      ]
    },
  ];
  
  // Lucid Dreaming Techniques
  static const List<Map<String, dynamic>> lucidDreamingTechniques = [
    {
      'name': 'Reality Checks',
      'description': 'Check your hands, clocks, or text throughout the day',
      'frequency': 'hourly',
    },
    {
      'name': 'Dream Journal',
      'description': 'Write down dreams immediately after waking',
      'frequency': 'daily',
    },
    {
      'name': 'MILD Technique',
      'description': 'Mnemonic induction of lucid dreams',
      'frequency': 'bedtime',
    },
    {
      'name': 'Wake-Back-to-Bed',
      'description': 'Wake up early, then go back to sleep',
      'frequency': 'weekly',
    },
  ];
  
  // Snoring Detection Levels
  static const Map<String, double> snoringLevels = {
    'silent': 0.0,
    'light': 0.3,
    'moderate': 0.6,
    'heavy': 0.8,
    'severe': 1.0,
  };
  
  // Sleep Environment Factors
  static const List<String> environmentFactors = [
    'temperature',
    'humidity',
    'noise_level',
    'light_level',
    'air_quality',
    'comfort_level',
  ];
  
  // Sleep Disorders
  static const List<String> commonSleepDisorders = [
    'insomnia',
    'sleep_apnea',
    'restless_legs',
    'narcolepsy',
    'night_terrors',
    'sleepwalking',
  ];
  
  // Alarm Tones Categories
  static const List<Map<String, dynamic>> alarmTones = [
    {
      'category': 'Gentle',
      'tones': [
        {'name': 'Sunrise', 'file': 'sunrise.mp3'},
        {'name': 'Birds Chirping', 'file': 'birds.mp3'},
        {'name': 'Soft Piano', 'file': 'piano.mp3'},
        {'name': 'Wind Chimes', 'file': 'chimes.mp3'},
      ]
    },
    {
      'category': 'Energetic',
      'tones': [
        {'name': 'Upbeat Music', 'file': 'upbeat.mp3'},
        {'name': 'Alarm Bell', 'file': 'bell.mp3'},
        {'name': 'Rooster', 'file': 'rooster.mp3'},
        {'name': 'Electronic Beep', 'file': 'beep.mp3'},
      ]
    },
  ];
  
  // Sleep Metrics
  static const List<String> sleepMetrics = [
    'total_sleep_time',
    'sleep_efficiency',
    'sleep_latency',
    'wake_after_sleep_onset',
    'number_of_awakenings',
    'rem_percentage',
    'deep_sleep_percentage',
  ];
  
  // Sleep Coaching Tips
  static const List<String> sleepTips = [
    'Maintain a consistent sleep schedule',
    'Create a relaxing bedtime routine',
    'Keep your bedroom cool and dark',
    'Avoid caffeine before bedtime',
    'Exercise regularly, but not before bed',
    'Limit screen time 1 hour before sleep',
    'Use comfortable bedding and pillows',
    'Try relaxation techniques if you can\'t sleep',
  ];
  
  // Nap Types
  static const Map<String, int> napDurations = {
    'power_nap': 20,
    'recovery_nap': 60,
    'full_cycle_nap': 90,
  };
  
  // Sleep Debt Calculation
  static const int maxSleepDebt = 7 * 24 * 60; // 7 days in minutes
  static const double sleepDebtFactor = 0.5; // Recovery rate
  
  // Circadian Rhythm
  static const Map<String, String> circadianTypes = {
    'morning_lark': 'Early riser, productive in morning',
    'night_owl': 'Late sleeper, productive at night',
    'intermediate': 'Balanced sleep pattern',
  };
  
  // Sleep Challenges
  static const List<Map<String, dynamic>> sleepChallenges = [
    {
      'name': '7-Day Sleep Consistency',
      'description': 'Sleep and wake at the same time for 7 days',
      'duration': 7,
      'reward': 100,
    },
    {
      'name': '30-Day Sleep Quality',
      'description': 'Achieve good sleep quality for 30 days',
      'duration': 30,
      'reward': 500,
    },
  ];
  
  // Integration APIs
  static const Map<String, String> sleepApis = {
    'apple_health': 'HKCategoryTypeIdentifierSleepAnalysis',
    'google_fit': 'com.google.sleep.segment',
    'fitbit': 'sleep',
    'garmin': 'sleep',
  };
  
  // Notification Types
  static const String bedtimeReminder = 'bedtime_reminder';
  static const String wakeupAlarm = 'wakeup_alarm';
  static const String sleepGoalAchieved = 'sleep_goal_achieved';
  static const String sleepDebtWarning = 'sleep_debt_warning';
  
  // Limits and Validations
  static const int minSleepDuration = 4 * 60; // 4 hours
  static const int maxSleepDuration = 12 * 60; // 12 hours
  static const int minBedtime = 18 * 60; // 6:00 PM
  static const int maxWakeTime = 12 * 60; // 12:00 PM
  static const int maxAlarmToneLength = 5 * 60; // 5 minutes
}
