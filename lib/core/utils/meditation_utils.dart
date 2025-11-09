import '../constants/meditation_constants.dart';
import 'math_utils.dart';

class MeditationUtils {
  /// Calculate meditation session quality score
  static double calculateSessionQuality(
    Duration plannedDuration,
    Duration actualDuration,
    int distractionsCount,
    double focusRating, // 1-10
    String sessionType,
  ) {
    double score = 0.0;
    
    // Duration completion score (0-30 points)
    final durationRatio = actualDuration.inSeconds / plannedDuration.inSeconds;
    final durationScore = (durationRatio * 30).clamp(0, 30);
    score += durationScore;
    
    // Focus quality score (0-40 points)
    score += (focusRating / 10.0) * 40;
    
    // Distraction penalty (0-20 points)
    final distractionScore = (20 - (distractionsCount * 2)).clamp(0, 20);
    score += distractionScore;
    
    // Session type bonus (0-10 points)
    final typeBonus = _getSessionTypeBonus(sessionType);
    score += typeBonus;
    
    return (score / 100.0 * 10).clamp(0.0, 10.0); // Convert to 0-10 scale
  }
  
  static double _getSessionTypeBonus(String sessionType) {
    switch (sessionType) {
      case MeditationConstants.mindfulness:
        return 8.0;
      case MeditationConstants.concentration:
        return 10.0;
      case MeditationConstants.lovingKindness:
        return 7.0;
      case MeditationConstants.bodySearch:
        return 6.0;
      case MeditationConstants.visualization:
        return 9.0;
      default:
        return 5.0;
    }
  }
  
  /// Generate personalized meditation recommendations
  static List<Map<String, dynamic>> generatePersonalizedRecommendations(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> sessionHistory,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    final experienceLevel = userProfile['meditation_experience'] as String? ?? 'beginner';
    final preferredDuration = userProfile['preferred_duration'] as int? ?? 10;
    final stressLevel = userProfile['current_stress_level'] as double? ?? 0.5;
    final goals = userProfile['meditation_goals'] as List<String>? ?? [];
    
    // Analyze session history patterns
    final sessionStats = _analyzeSessionHistory(sessionHistory);
    
    // Generate recommendations based on analysis
    if (stressLevel > 0.7) {
      recommendations.add({
        'type': 'Stress Relief',
        'technique': MeditationConstants.mindfulness,
        'duration': math.min(preferredDuration, 15),
        'description': 'Quick stress relief meditation to help you find calm',
        'breathing_pattern': '4-7-8 Breathing',
        'priority': 'high',
      });
    }
    
    if (goals.contains('better_sleep')) {
      recommendations.add({
        'type': 'Sleep Preparation',
        'technique': MeditationConstants.bodySearch,
        'duration': math.max(preferredDuration, 15),
        'description': 'Progressive relaxation to prepare for restful sleep',
        'best_time': 'evening',
        'priority': 'medium',
      });
    }
    
    if (goals.contains('focus_improvement')) {
      recommendations.add({
        'type': 'Concentration Training',
        'technique': MeditationConstants.concentration,
        'duration': _adjustDurationForExperience(20, experienceLevel),
        'description': 'Build focus and attention span through concentration practice',
        'best_time': 'morning',
        'priority': 'medium',
      });
    }
    
    // Add progression recommendations
    final progressionRec = _generateProgressionRecommendation(sessionStats, experienceLevel);
    if (progressionRec != null) {
      recommendations.add(progressionRec);
    }
    
    return recommendations;
  }
  
  static Map<String, dynamic> _analyzeSessionHistory(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return {
        'average_duration': 0,
        'average_quality': 0.0,
        'consistency_rate': 0.0,
        'favorite_technique': MeditationConstants.mindfulness,
        'optimal_time': 'morning',
      };
    }
    
    final totalDuration = sessions.fold<int>(0, (sum, session) => 
        sum + (session['duration'] as int? ?? 0));
    final avgDuration = totalDuration / sessions.length;
    
    final totalQuality = sessions.fold<double>(0, (sum, session) => 
        sum + (session['quality_score'] as double? ?? 0));
    final avgQuality = totalQuality / sessions.length;
    
    // Calculate consistency (sessions per week)
    final uniqueDays = sessions.map((s) => DateTime.parse(s['date'] as String).day).toSet();
    final consistencyRate = uniqueDays.length / 7.0; // Assuming last 7 days
    
    // Find favorite technique
    final techniqueCounts = <String, int>{};
    for (final session in sessions) {
      final technique = session['technique'] as String? ?? MeditationConstants.mindfulness;
      techniqueCounts[technique] = (techniqueCounts[technique] ?? 0) + 1;
    }
    final favoriteTechnique = techniqueCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Find optimal time
    final timeCounts = <String, int>{};
    for (final session in sessions) {
      final hour = DateTime.parse(session['date'] as String).hour;
      String timeOfDay;
      if (hour < 12) {
        timeOfDay = 'morning';
      } else if (hour < 17) {
        timeOfDay = 'afternoon';
      } else {
        timeOfDay = 'evening';
      }
      timeCounts[timeOfDay] = (timeCounts[timeOfDay] ?? 0) + 1;
    }
    final optimalTime = timeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    
    return {
      'average_duration': avgDuration,
      'average_quality': avgQuality,
      'consistency_rate': consistencyRate,
      'favorite_technique': favoriteTechnique,
      'optimal_time': optimalTime,
    };
  }
  
  static Map<String, dynamic>? _generateProgressionRecommendation(
    Map<String, dynamic> stats,
    String experienceLevel,
  ) {
    final avgDuration = stats['average_duration'] as double;
    final avgQuality = stats['average_quality'] as double;
    
    if (avgQuality > 7.0 && experienceLevel == 'beginner') {
      return {
        'type': 'Level Progression',
        'technique': MeditationConstants.concentration,
        'duration': _adjustDurationForExperience(15, 'intermediate'),
        'description': 'You\'re ready for intermediate techniques!',
        'priority': 'high',
        'achievement': 'Meditation Apprentice',
      };
    }
    
    if (avgDuration < 10 && avgQuality > 6.0) {
      return {
        'type': 'Duration Increase',
        'technique': stats['favorite_technique'] as String,
        'duration': (avgDuration + 5).round(),
        'description': 'Try extending your sessions for deeper practice',
        'priority': 'medium',
      };
    }
    
    return null;
  }
  
  static int _adjustDurationForExperience(int baseDuration, String level) {
    switch (level) {
      case 'beginner':
        return (baseDuration * 0.7).round();
      case 'intermediate':
        return baseDuration;
      case 'advanced':
        return (baseDuration * 1.3).round();
      default:
        return baseDuration;
    }
  }
  
  /// Create custom ASMR sound mix
  static Map<String, dynamic> createCustomASMRMix(
    List<Map<String, dynamic>> selectedSounds,
    Map<String, double> volumeLevels,
  ) {
    final mix = <String, dynamic>{
      'id': 'custom_mix_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Custom Mix ${DateTime.now().day}/${DateTime.now().month}',
      'sounds': <Map<String, dynamic>>[],
      'total_duration': 0,
      'created_at': DateTime.now(),
    };
    
    int maxDuration = 0;
    
    for (final sound in selectedSounds) {
      final soundName = sound['name'] as String;
      final volume = volumeLevels[soundName] ?? 0.5;
      final duration = sound['duration'] as int;
      
      mix['sounds'].add({
        'name': soundName,
        'file': sound['file'],
        'volume': volume,
        'duration': duration,
        'category': sound['category'] ?? 'custom',
      });
      
      maxDuration = math.max(maxDuration, duration);
    }
    
    mix['total_duration'] = maxDuration;
    
    return mix;
  }
  
  /// Generate breathing exercise guide
  static Map<String, dynamic> generateBreathingGuide(
    String exerciseType,
    int cycles,
    String userLevel,
  ) {
    final exercise = MeditationConstants.breathingPatterns
        .firstWhere((pattern) => pattern['name'] == exerciseType,
            orElse: () => MeditationConstants.breathingPatterns.first);
    
    final adjustedExercise = Map<String, dynamic>.from(exercise);
    
    // Adjust for user level
    if (userLevel == 'beginner') {
      adjustedExercise['cycles'] = math.min(adjustedExercise['cycles'] as int, 4);
      // Reduce timing slightly for beginners
      if (adjustedExercise.containsKey('inhale')) {
        adjustedExercise['inhale'] = math.max((adjustedExercise['inhale'] as int) - 1, 2);
      }
      if (adjustedExercise.containsKey('hold')) {
        adjustedExercise['hold'] = math.max((adjustedExercise['hold'] as int) - 1, 0);
      }
    } else if (userLevel == 'advanced') {
      adjustedExercise['cycles'] = cycles;
    }
    
    // Calculate total duration
    final inhale = adjustedExercise['inhale'] as int? ?? 4;
    final hold = adjustedExercise['hold'] as int? ?? 4;
    final exhale = adjustedExercise['exhale'] as int? ?? 4;
    final pause = adjustedExercise['pause'] as int? ?? 0;
    
    final cycleTime = inhale + hold + exhale + pause;
    final totalDuration = cycleTime * (adjustedExercise['cycles'] as int);
    
    adjustedExercise['total_duration_seconds'] = totalDuration;
    
    return adjustedExercise;
  }
  
  /// Calculate meditation streaks and milestones
  static Map<String, dynamic> calculateMeditationProgress(
    List<DateTime> sessionDates,
    DateTime startDate,
  ) {
    if (sessionDates.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'total_sessions': 0,
        'days_practiced': 0,
        'consistency_rate': 0.0,
        'next_milestone': _getNextMilestone(0),
      };
    }
    
    sessionDates.sort();
    
    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);
    
    for (int i = sessionDates.length - 1; i >= 0; i--) {
      final sessionDate = DateTime(
        sessionDates[i].year,
        sessionDates[i].month,
        sessionDates[i].day,
      );
      
      if (sessionDate == checkDate || sessionDate == checkDate.subtract(const Duration(days: 1))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;
    
    for (int i = 1; i < sessionDates.length; i++) {
      final prevDate = DateTime(sessionDates[i-1].year, sessionDates[i-1].month, sessionDates[i-1].day);
      final currDate = DateTime(sessionDates[i].year, sessionDates[i].month, sessionDates[i].day);
      
      if (currDate.difference(prevDate).inDays <= 1) {
        tempStreak++;
      } else {
        longestStreak = math.max(longestStreak, tempStreak);
        tempStreak = 1;
      }
    }
    longestStreak = math.max(longestStreak, tempStreak);
    
    // Calculate other metrics
    final uniqueDays = sessionDates.map((date) => 
        DateTime(date.year, date.month, date.day)).toSet();
    final totalDays = DateTime.now().difference(startDate).inDays + 1;
    final consistencyRate = uniqueDays.length / totalDays;
    
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': sessionDates.length,
      'days_practiced': uniqueDays.length,
      'consistency_rate': consistencyRate,
      'next_milestone': _getNextMilestone(currentStreak),
    };
  }
  
  static Map<String, dynamic> _getNextMilestone(int currentStreak) {
    final milestones = [7, 14, 21, 30, 50, 100, 200, 365];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return {
          'days': milestone,
          'name': _getMilestoneName(milestone),
          'days_remaining': milestone - currentStreak,
          'reward': _getMilestoneReward(milestone),
        };
      }
    }
    
    return {
      'days': currentStreak + 100,
      'name': 'Meditation Master+',
      'days_remaining': 100,
      'reward': 'Epic Badge',
    };
  }
  
  static String _getMilestoneName(int days) {
    switch (days) {
      case 7:
        return 'Mindful Week';
      case 14:
        return 'Steady Practice';
      case 21:
        return 'Habit Former';
      case 30:
        return 'Monthly Meditator';
      case 50:
        return 'Dedicated Practitioner';
      case 100:
        return 'Centurion';
      case 200:
        return 'Meditation Warrior';
      case 365:
        return 'Zen Master';
      default:
        return 'Milestone $days';
    }
  }
  
  static String _getMilestoneReward(int days) {
    if (days <= 21) return 'Bronze Badge';
    if (days <= 50) return 'Silver Badge';
    if (days <= 100) return 'Gold Badge';
    if (days <= 200) return 'Platinum Badge';
    return 'Diamond Badge';
  }
  
  /// Generate mood-based meditation suggestions
  static List<Map<String, dynamic>> getMoodBasedSuggestions(
    String preMeditationMood,
    int availableTime,
  ) {
    final suggestions = <Map<String, dynamic>>[];
    
    switch (preMeditationMood) {
      case 'stressed':
        suggestions.addAll([
          {
            'technique': MeditationConstants.mindfulness,
            'duration': math.min(availableTime, 10),
            'title': 'Stress Relief Meditation',
            'description': 'Quick mindfulness to ease stress',
            'breathing': '4-7-8 Breathing',
          },
          {
            'technique': MeditationConstants.bodySearch,
            'duration': math.min(availableTime, 15),
            'title': 'Progressive Relaxation',
            'description': 'Release tension from head to toe',
          },
        ]);
        break;
        
      case 'anxious':
        suggestions.addAll([
          {
            'technique': MeditationConstants.breathingFocus,
            'duration': math.min(availableTime, 8),
            'title': 'Calming Breath Work',
            'description': 'Focus on breath to calm anxiety',
            'breathing': 'Box Breathing',
          },
          {
            'technique': MeditationConstants.lovingKindness,
            'duration': math.min(availableTime, 12),
            'title': 'Self-Compassion Practice',
            'description': 'Cultivate inner peace and kindness',
          },
        ]);
        break;
        
      case 'tired':
        suggestions.addAll([
          {
            'technique': MeditationConstants.energizing,
            'duration': math.min(availableTime, 10),
            'title': 'Energy Revival',
            'description': 'Gentle practice to boost energy',
            'breathing': 'Energizing Breath',
          },
          {
            'technique': MeditationConstants.visualization,
            'duration': math.min(availableTime, 15),
            'title': 'Vitality Visualization',
            'description': 'Imagine energy flowing through you',
          },
        ]);
        break;
        
      case 'happy':
        suggestions.addAll([
          {
            'technique': MeditationConstants.gratitude,
            'duration': math.min(availableTime, 10),
            'title': 'Gratitude Meditation',
            'description': 'Amplify positive feelings',
          },
          {
            'technique': MeditationConstants.lovingKindness,
            'duration': math.min(availableTime, 15),
            'title': 'Loving Kindness',
            'description': 'Share joy with others',
          },
        ]);
        break;
        
      default:
        suggestions.add({
          'technique': MeditationConstants.mindfulness,
          'duration': math.min(availableTime, 10),
          'title': 'Mindful Awareness',
          'description': 'Simple mindfulness practice',
        });
    }
    
    return suggestions;
  }
  
  /// Validate meditation session data
  static Map<String, String?> validateMeditationData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final duration = data['duration'] as int?;
    if (duration != null && (duration < MeditationConstants.minSessionDuration || 
                           duration > MeditationConstants.maxSessionDuration)) {
      errors['duration'] = 'Session duration must be between ${MeditationConstants.minSessionDuration} and ${MeditationConstants.maxSessionDuration} minutes';
    }
    
    final focusRating = data['focus_rating'] as double?;
    if (focusRating != null && (focusRating < 1.0 || focusRating > 10.0)) {
      errors['focus_rating'] = 'Focus rating must be between 1 and 10';
    }
    
    final distractions = data['distractions'] as int?;
    if (distractions != null && distractions < 0) {
      errors['distractions'] = 'Distractions count cannot be negative';
    }
    
    return errors;
  }
  
  /// Get meditation technique color
  static String getTechniqueColor(String technique) {
    switch (technique) {
      case MeditationConstants.mindfulness:
        return '#2ECC71'; // Green
      case MeditationConstants.concentration:
        return '#3498DB'; // Blue
      case MeditationConstants.lovingKindness:
        return '#E91E63'; // Pink
      case MeditationConstants.bodySearch:
        return '#9B59B6'; // Purple
      case MeditationConstants.visualization:
        return '#F39C12'; // Orange
      default:
        return '#95A5A6'; // Gray
    }
  }
  
  /// Format meditation time
  static String formatMeditationTime(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    } else if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0 ? '${minutes}m ${remainingSeconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }
}
