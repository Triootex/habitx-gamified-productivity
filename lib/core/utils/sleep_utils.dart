import '../constants/sleep_constants.dart';
import 'date_utils.dart';
import 'math_utils.dart';

class SleepUtils {
  /// Calculate sleep quality score based on multiple factors
  static double calculateSleepQuality(
    Duration totalSleepTime,
    Duration deepSleepTime,
    Duration remSleepTime,
    int awakenings,
    Duration sleepLatency,
  ) {
    double score = 0.0;
    
    // Sleep duration score (0-30 points)
    final targetSleep = const Duration(hours: 8);
    final durationScore = _calculateDurationScore(totalSleepTime, targetSleep);
    score += durationScore * 0.3;
    
    // Sleep efficiency score (0-25 points)
    final efficiencyScore = _calculateEfficiencyScore(totalSleepTime, sleepLatency, awakenings);
    score += efficiencyScore * 0.25;
    
    // Deep sleep score (0-25 points)
    final deepSleepPercentage = deepSleepTime.inMinutes / totalSleepTime.inMinutes;
    final deepSleepScore = _calculateDeepSleepScore(deepSleepPercentage);
    score += deepSleepScore * 0.25;
    
    // REM sleep score (0-20 points)
    final remPercentage = remSleepTime.inMinutes / totalSleepTime.inMinutes;
    final remScore = _calculateRemScore(remPercentage);
    score += remScore * 0.2;
    
    return (score * 100).clamp(0.0, 100.0);
  }
  
  static double _calculateDurationScore(Duration actual, Duration target) {
    final difference = (actual.inMinutes - target.inMinutes).abs();
    if (difference <= 30) return 1.0; // Perfect score
    if (difference <= 60) return 0.8;
    if (difference <= 90) return 0.6;
    if (difference <= 120) return 0.4;
    return 0.2;
  }
  
  static double _calculateEfficiencyScore(Duration totalSleep, Duration latency, int awakenings) {
    double score = 1.0;
    
    // Penalize long sleep latency (time to fall asleep)
    if (latency.inMinutes > 30) score -= 0.3;
    else if (latency.inMinutes > 15) score -= 0.15;
    
    // Penalize frequent awakenings
    if (awakenings > 3) score -= 0.4;
    else if (awakenings > 1) score -= 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  static double _calculateDeepSleepScore(double percentage) {
    // Optimal deep sleep is 15-20% of total sleep
    if (percentage >= 0.15 && percentage <= 0.20) return 1.0;
    if (percentage >= 0.10 && percentage < 0.15) return 0.8;
    if (percentage >= 0.08 && percentage < 0.10) return 0.6;
    if (percentage >= 0.05 && percentage < 0.08) return 0.4;
    return 0.2;
  }
  
  static double _calculateRemScore(double percentage) {
    // Optimal REM sleep is 20-25% of total sleep
    if (percentage >= 0.20 && percentage <= 0.25) return 1.0;
    if (percentage >= 0.15 && percentage < 0.20) return 0.8;
    if (percentage >= 0.10 && percentage < 0.15) return 0.6;
    return 0.4;
  }
  
  /// Detect sleep phases using motion/sound data
  static String detectSleepPhase(
    double motionLevel,
    double heartRate,
    double respirationRate,
  ) {
    // Normalize values (this would use actual sensor data in real implementation)
    final normalizedMotion = motionLevel / 100.0; // Assuming 0-100 range
    final normalizedHR = (heartRate - 60) / 40.0; // Normalize around resting HR
    
    if (normalizedMotion > 0.7 || normalizedHR > 0.8) {
      return SleepConstants.awake;
    }
    
    if (normalizedMotion < 0.1 && normalizedHR < 0.3) {
      return SleepConstants.deepSleep;
    }
    
    if (normalizedHR > 0.5 && normalizedMotion < 0.3) {
      return SleepConstants.remSleep;
    }
    
    return SleepConstants.lightSleep;
  }
  
  /// Calculate optimal bedtime based on wake time and sleep need
  static DateTime calculateOptimalBedtime(DateTime wakeTime, Duration sleepNeed) {
    // Add buffer time for falling asleep (15 minutes)
    final fallAsleepBuffer = const Duration(minutes: 15);
    return wakeTime.subtract(sleepNeed).subtract(fallAsleepBuffer);
  }
  
  /// Find optimal wake time within smart alarm window
  static DateTime? findOptimalWakeTime(
    DateTime targetWakeTime,
    List<Map<String, dynamic>> sleepPhaseData,
  ) {
    final windowStart = targetWakeTime.subtract(const Duration(minutes: SleepConstants.smartAlarmWindow));
    final windowEnd = targetWakeTime;
    
    // Look for light sleep phases within the window
    for (final phaseData in sleepPhaseData) {
      final time = phaseData['timestamp'] as DateTime;
      final phase = phaseData['phase'] as String;
      
      if (time.isAfter(windowStart) && time.isBefore(windowEnd)) {
        if (phase == SleepConstants.lightSleep || phase == SleepConstants.awake) {
          return time;
        }
      }
    }
    
    return targetWakeTime; // Fall back to original time if no optimal time found
  }
  
  /// Analyze snoring levels and patterns
  static Map<String, dynamic> analyzeSnoring(List<double> audioLevels) {
    if (audioLevels.isEmpty) {
      return {
        'level': SleepConstants.snoringLevels['silent']!,
        'episodes': 0,
        'duration': Duration.zero,
        'severity': 'none',
      };
    }
    
    final averageLevel = audioLevels.reduce((a, b) => a + b) / audioLevels.length;
    final maxLevel = audioLevels.reduce((a, b) => a > b ? a : b);
    
    // Count snoring episodes (continuous periods above threshold)
    int episodes = 0;
    bool inEpisode = false;
    int episodeDuration = 0;
    
    for (final level in audioLevels) {
      if (level > 0.3 && !inEpisode) {
        episodes++;
        inEpisode = true;
        episodeDuration = 1;
      } else if (level > 0.3 && inEpisode) {
        episodeDuration++;
      } else if (level <= 0.3 && inEpisode) {
        inEpisode = false;
      }
    }
    
    String severity;
    if (maxLevel < 0.3) {
      severity = 'silent';
    } else if (maxLevel < 0.5) {
      severity = 'light';
    } else if (maxLevel < 0.7) {
      severity = 'moderate';
    } else if (maxLevel < 0.9) {
      severity = 'heavy';
    } else {
      severity = 'severe';
    }
    
    return {
      'level': averageLevel,
      'max_level': maxLevel,
      'episodes': episodes,
      'duration': Duration(seconds: episodeDuration * 30), // Assuming 30-second intervals
      'severity': severity,
    };
  }
  
  /// Generate lucid dreaming triggers and techniques
  static Map<String, dynamic> generateLucidDreamingPlan(
    Map<String, dynamic> userPreferences,
    Map<String, dynamic> sleepPattern,
  ) {
    final techniques = <Map<String, dynamic>>[];
    
    // Add techniques based on user experience level
    final experienceLevel = userPreferences['lucid_experience'] as String? ?? 'beginner';
    
    switch (experienceLevel) {
      case 'beginner':
        techniques.addAll([
          {
            'technique': 'Reality Checks',
            'frequency': 'hourly',
            'description': 'Look at your hands and check if they appear normal',
            'reminders': _generateRealityCheckTimes(),
          },
          {
            'technique': 'Dream Journal',
            'frequency': 'daily',
            'description': 'Write down dreams immediately upon waking',
            'reminder_time': '06:00',
          },
        ]);
        break;
        
      case 'intermediate':
        techniques.addAll([
          {
            'technique': 'MILD (Mnemonic Induction)',
            'frequency': 'bedtime',
            'description': 'Repeat "Next time I\'m dreaming, I will remember I\'m dreaming"',
            'reminder_time': '22:00',
          },
          {
            'technique': 'Wake-Back-to-Bed',
            'frequency': 'weekly',
            'description': 'Wake up 4-6 hours after falling asleep, stay awake 15-30 minutes, then return to sleep',
            'optimal_time': _calculateWBTBTime(sleepPattern),
          },
        ]);
        break;
        
      case 'advanced':
        techniques.addAll([
          {
            'technique': 'Visualization',
            'frequency': 'bedtime',
            'description': 'Visualize becoming lucid in a dream scenario',
          },
          {
            'technique': 'Supplements',
            'frequency': 'as_needed',
            'description': 'Natural supplements like galantamine (consult doctor first)',
          },
        ]);
        break;
    }
    
    return {
      'techniques': techniques,
      'success_rate': _calculateLucidSuccessRate(userPreferences),
      'next_milestone': _getNextLucidMilestone(userPreferences),
    };
  }
  
  static List<String> _generateRealityCheckTimes() {
    final times = <String>[];
    for (int hour = 8; hour <= 22; hour += 2) {
      times.add('${hour.toString().padLeft(2, '0')}:00');
    }
    return times;
  }
  
  static String _calculateWBTBTime(Map<String, dynamic> sleepPattern) {
    final bedtime = sleepPattern['average_bedtime'] as String? ?? '22:00';
    final bedtimeParts = bedtime.split(':');
    final bedtimeHour = int.parse(bedtimeParts[0]);
    
    // Wake up 4-5 hours after bedtime
    final wakeHour = (bedtimeHour + 4) % 24;
    return '${wakeHour.toString().padLeft(2, '0')}:00';
  }
  
  static double _calculateLucidSuccessRate(Map<String, dynamic> preferences) {
    final experienceLevel = preferences['lucid_experience'] as String? ?? 'beginner';
    final practiceFrequency = preferences['practice_frequency'] as String? ?? 'rarely';
    
    double baseRate = 0.1; // 10% base rate for beginners
    
    switch (experienceLevel) {
      case 'intermediate':
        baseRate = 0.25;
        break;
      case 'advanced':
        baseRate = 0.4;
        break;
    }
    
    switch (practiceFrequency) {
      case 'daily':
        baseRate *= 1.5;
        break;
      case 'weekly':
        baseRate *= 1.2;
        break;
    }
    
    return baseRate.clamp(0.0, 0.8);
  }
  
  static String _getNextLucidMilestone(Map<String, dynamic> preferences) {
    final lucidCount = preferences['total_lucid_dreams'] as int? ?? 0;
    
    if (lucidCount < 1) return 'First lucid dream';
    if (lucidCount < 5) return '5 lucid dreams';
    if (lucidCount < 10) return '10 lucid dreams';
    if (lucidCount < 25) return '25 lucid dreams - Experienced dreamer';
    return '50 lucid dreams - Master dreamer';
  }
  
  /// Calculate sleep debt and recovery recommendations
  static Map<String, dynamic> calculateSleepDebt(
    List<Duration> recentSleepDurations,
    Duration targetSleepDuration,
  ) {
    if (recentSleepDurations.isEmpty) {
      return {
        'debt': Duration.zero,
        'severity': 'none',
        'recovery_plan': [],
      };
    }
    
    Duration totalDebt = Duration.zero;
    
    for (final duration in recentSleepDurations) {
      if (duration < targetSleepDuration) {
        totalDebt += targetSleepDuration - duration;
      }
    }
    
    String severity;
    if (totalDebt.inHours < 2) {
      severity = 'minimal';
    } else if (totalDebt.inHours < 5) {
      severity = 'moderate';
    } else if (totalDebt.inHours < 10) {
      severity = 'significant';
    } else {
      severity = 'severe';
    }
    
    final recoveryPlan = _generateSleepRecoveryPlan(totalDebt, severity);
    
    return {
      'debt': totalDebt,
      'severity': severity,
      'recovery_plan': recoveryPlan,
      'estimated_recovery_days': (totalDebt.inMinutes / 60.0).ceil(),
    };
  }
  
  static List<Map<String, String>> _generateSleepRecoveryPlan(Duration debt, String severity) {
    final plan = <Map<String, String>>[];
    
    switch (severity) {
      case 'minimal':
        plan.add({
          'action': 'Maintain regular schedule',
          'description': 'Keep consistent bedtime and wake time',
        });
        break;
        
      case 'moderate':
        plan.addAll([
          {
            'action': 'Earlier bedtime',
            'description': 'Go to bed 30-60 minutes earlier for next few days',
          },
          {
            'action': 'Avoid caffeine after 2 PM',
            'description': 'Reduce stimulants to improve sleep quality',
          },
        ]);
        break;
        
      case 'significant':
        plan.addAll([
          {
            'action': 'Weekend recovery sleep',
            'description': 'Allow 1-2 hours extra sleep on weekends',
          },
          {
            'action': 'Nap strategically',
            'description': '20-30 minute naps before 3 PM if needed',
          },
          {
            'action': 'Sleep hygiene focus',
            'description': 'Dark room, cool temperature, no screens 1 hour before bed',
          },
        ]);
        break;
        
      case 'severe':
        plan.addAll([
          {
            'action': 'Immediate sleep prioritization',
            'description': 'Make sleep the top priority for the next week',
          },
          {
            'action': 'Consider professional help',
            'description': 'Consult a sleep specialist if debt persists',
          },
          {
            'action': 'Gradual schedule adjustment',
            'description': 'Adjust bedtime by 15 minutes earlier each night',
          },
        ]);
        break;
    }
    
    return plan;
  }
  
  /// Generate personalized sleep recommendations
  static List<String> generateSleepRecommendations(
    Map<String, dynamic> sleepData,
    Map<String, dynamic> userProfile,
  ) {
    final recommendations = <String>[];
    
    final avgSleepDuration = sleepData['average_duration'] as Duration? ?? const Duration(hours: 7);
    final sleepQuality = sleepData['average_quality'] as double? ?? 70.0;
    final bedtimeConsistency = sleepData['bedtime_consistency'] as double? ?? 0.8;
    
    // Duration recommendations
    if (avgSleepDuration.inHours < 7) {
      recommendations.add('Try to get at least 7-8 hours of sleep per night');
    } else if (avgSleepDuration.inHours > 9) {
      recommendations.add('Consider if you might be oversleeping - 7-9 hours is typically optimal');
    }
    
    // Quality recommendations
    if (sleepQuality < 60) {
      recommendations.addAll([
        'Keep your bedroom cool (60-67°F) and dark',
        'Avoid screens 1 hour before bedtime',
        'Try relaxation techniques like deep breathing',
      ]);
    }
    
    // Consistency recommendations
    if (bedtimeConsistency < 0.7) {
      recommendations.add('Try to go to bed and wake up at the same time every day');
    }
    
    // Personalized recommendations based on user profile
    final age = userProfile['age'] as int? ?? 30;
    if (age > 60) {
      recommendations.add('Consider earlier bedtimes as sleep patterns change with age');
    }
    
    final fitnessLevel = userProfile['fitness_level'] as String? ?? 'moderate';
    if (fitnessLevel == 'high') {
      recommendations.add('Exercise earlier in the day - avoid vigorous activity 3 hours before bed');
    }
    
    return recommendations.take(5).toList(); // Limit to top 5 recommendations
  }
  
  /// Validate sleep data
  static Map<String, String?> validateSleepData(Map<String, dynamic> sleepData) {
    final errors = <String, String?>{};
    
    final bedtime = sleepData['bedtime'] as DateTime?;
    final wakeTime = sleepData['wake_time'] as DateTime?;
    
    if (bedtime == null) {
      errors['bedtime'] = 'Bedtime is required';
    }
    
    if (wakeTime == null) {
      errors['wake_time'] = 'Wake time is required';
    }
    
    if (bedtime != null && wakeTime != null) {
      final sleepDuration = wakeTime.difference(bedtime);
      
      if (sleepDuration.isNegative || sleepDuration.inHours > 16) {
        errors['duration'] = 'Invalid sleep duration';
      }
      
      if (sleepDuration < const Duration(hours: 2)) {
        errors['duration'] = 'Sleep duration seems too short';
      }
    }
    
    final sleepQuality = sleepData['quality_rating'] as int?;
    if (sleepQuality != null && (sleepQuality < 1 || sleepQuality > 10)) {
      errors['quality_rating'] = 'Sleep quality must be between 1 and 10';
    }
    
    return errors;
  }
  
  /// Get sleep phase color for UI
  static String getSleepPhaseColor(String phase) {
    switch (phase) {
      case SleepConstants.awake:
        return '#E74C3C'; // Red
      case SleepConstants.lightSleep:
        return '#F39C12'; // Orange
      case SleepConstants.deepSleep:
        return '#3498DB'; // Blue
      case SleepConstants.remSleep:
        return '#9B59B6'; // Purple
      default:
        return '#95A5A6'; // Gray
    }
  }
  
  /// Format sleep duration for display
  static String formatSleepDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
