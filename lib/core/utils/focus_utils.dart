import '../constants/focus_constants.dart';
import 'date_utils.dart';
import 'math_utils.dart';

class FocusUtils {
  /// Calculate focus session quality score
  static double calculateSessionQuality(
    Duration plannedDuration,
    Duration actualDuration,
    int distractionsCount,
    double productivityRating, // 1-10
    String sessionType,
  ) {
    double score = 0.0;
    
    // Duration completion score (0-25 points)
    final durationRatio = actualDuration.inMinutes / plannedDuration.inMinutes;
    final durationScore = (durationRatio * 25).clamp(0, 25);
    score += durationScore;
    
    // Productivity rating score (0-40 points)
    score += (productivityRating / 10.0) * 40;
    
    // Distraction penalty (0-25 points)
    final maxDistractions = plannedDuration.inMinutes ~/ 5; // 1 distraction per 5 minutes expected
    final distractionScore = (25 - (distractionsCount * 5)).clamp(0, 25);
    score += distractionScore;
    
    // Session type bonus (0-10 points)
    final typeBonus = _getSessionTypeBonus(sessionType);
    score += typeBonus;
    
    return (score / 100.0 * 10).clamp(0.0, 10.0); // Convert to 0-10 scale
  }
  
  static double _getSessionTypeBonus(String sessionType) {
    switch (sessionType) {
      case FocusConstants.deepWork:
        return 10.0; // Highest bonus for deep work
      case FocusConstants.learning:
        return 8.0;
      case FocusConstants.creative:
        return 7.0;
      case FocusConstants.administrative:
        return 5.0;
      case FocusConstants.planning:
        return 6.0;
      default:
        return 5.0;
    }
  }
  
  /// Generate personalized Pomodoro recommendations
  static Map<String, dynamic> generatePomodoroRecommendations(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> sessionHistory,
  ) {
    final recommendations = <String, dynamic>{};
    
    final focusLevel = userProfile['focus_level'] as String? ?? 'intermediate';
    final preferredDuration = userProfile['preferred_duration'] as int? ?? 25;
    final distractionTendency = userProfile['distraction_tendency'] as String? ?? 'medium';
    
    // Analyze session history
    final sessionStats = _analyzeSessionHistory(sessionHistory);
    
    // Customize work duration
    int recommendedWorkDuration = preferredDuration;
    if (sessionStats['average_quality'] < 6.0) {
      recommendedWorkDuration = math.max(15, preferredDuration - 5); // Shorter sessions if struggling
    } else if (sessionStats['average_quality'] > 8.0) {
      recommendedWorkDuration = math.min(45, preferredDuration + 5); // Longer sessions if doing well
    }
    
    // Customize break duration
    int shortBreak = 5;
    int longBreak = 15;
    
    if (distractionTendency == 'high') {
      shortBreak = 3; // Shorter breaks to maintain momentum
      longBreak = 10;
    } else if (distractionTendency == 'low') {
      shortBreak = 7; // Longer breaks for better focus maintenance
      longBreak = 20;
    }
    
    // Determine sessions until long break
    int sessionsUntilLongBreak = 4;
    if (focusLevel == 'beginner') {
      sessionsUntilLongBreak = 3; // More frequent long breaks
    } else if (focusLevel == 'advanced') {
      sessionsUntilLongBreak = 6; // Can handle more sessions
    }
    
    recommendations['work_duration'] = recommendedWorkDuration;
    recommendations['short_break'] = shortBreak;
    recommendations['long_break'] = longBreak;
    recommendations['sessions_until_long_break'] = sessionsUntilLongBreak;
    recommendations['reasoning'] = _generateRecommendationReasoning(
      sessionStats, focusLevel, distractionTendency);
    
    return recommendations;
  }
  
  static Map<String, dynamic> _analyzeSessionHistory(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return {
        'average_quality': 5.0,
        'average_duration': 25,
        'distraction_rate': 0.5,
        'completion_rate': 0.8,
        'most_productive_time': 'morning',
      };
    }
    
    final totalQuality = sessions.fold<double>(0, (sum, session) => 
        sum + (session['quality_score'] as double? ?? 5.0));
    final avgQuality = totalQuality / sessions.length;
    
    final totalDuration = sessions.fold<int>(0, (sum, session) => 
        sum + (session['duration'] as int? ?? 25));
    final avgDuration = totalDuration / sessions.length;
    
    final totalDistractions = sessions.fold<int>(0, (sum, session) => 
        sum + (session['distractions'] as int? ?? 0));
    final distractionRate = totalDistractions / sessions.length;
    
    final completedSessions = sessions.where((session) => 
        (session['completed'] as bool? ?? false)).length;
    final completionRate = completedSessions / sessions.length;
    
    // Find most productive time of day
    final timeCounts = <String, int>{};
    for (final session in sessions) {
      final sessionTime = DateTime.parse(session['start_time'] as String);
      final hour = sessionTime.hour;
      
      String timeOfDay;
      if (hour >= 6 && hour < 12) {
        timeOfDay = 'morning';
      } else if (hour >= 12 && hour < 17) {
        timeOfDay = 'afternoon';
      } else if (hour >= 17 && hour < 21) {
        timeOfDay = 'evening';
      } else {
        timeOfDay = 'night';
      }
      
      timeCounts[timeOfDay] = (timeCounts[timeOfDay] ?? 0) + 1;
    }
    
    final mostProductiveTime = timeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    
    return {
      'average_quality': avgQuality,
      'average_duration': avgDuration,
      'distraction_rate': distractionRate,
      'completion_rate': completionRate,
      'most_productive_time': mostProductiveTime,
    };
  }
  
  static String _generateRecommendationReasoning(
    Map<String, dynamic> stats,
    String focusLevel,
    String distractionTendency,
  ) {
    final reasons = <String>[];
    
    if (stats['average_quality'] < 6.0) {
      reasons.add('Shorter sessions recommended due to recent focus challenges');
    } else if (stats['average_quality'] > 8.0) {
      reasons.add('Longer sessions possible based on your excellent focus performance');
    }
    
    if (distractionTendency == 'high') {
      reasons.add('Shorter breaks to maintain momentum and reduce re-entry friction');
    }
    
    if (focusLevel == 'beginner') {
      reasons.add('More frequent long breaks to prevent focus fatigue');
    }
    
    return reasons.isEmpty ? 'Standard Pomodoro technique adapted to your profile' 
        : reasons.join('. ');
  }
  
  /// Grow virtual trees based on focus sessions
  static Map<String, dynamic> growVirtualTree(
    String treeType,
    int sessionDuration,
    double sessionQuality,
    Map<String, dynamic> existingTree,
  ) {
    final treeConfig = FocusConstants.treeTypes
        .firstWhere((tree) => tree['name'] == treeType,
            orElse: () => FocusConstants.treeTypes.first);
    
    final minSession = treeConfig['min_session'] as int;
    final maxSession = treeConfig['max_session'] as int;
    final xpMultiplier = treeConfig['xp_multiplier'] as double;
    final growthStages = treeConfig['growth_stages'] as List<String>;
    
    // Validate session duration
    if (sessionDuration < minSession) {
      return {
        'error': 'Session too short for this tree type',
        'min_required': minSession,
      };
    }
    
    // Calculate growth points
    double growthPoints = sessionDuration * sessionQuality * xpMultiplier;
    
    // Apply session duration bonus/penalty
    if (sessionDuration > maxSession) {
      growthPoints *= 0.8; // Penalty for excessively long sessions
    } else if (sessionDuration >= minSession * 2) {
      growthPoints *= 1.2; // Bonus for substantial sessions
    }
    
    // Update tree
    final currentGrowth = existingTree['growth_points'] as double? ?? 0.0;
    final newGrowth = currentGrowth + growthPoints;
    
    // Determine growth stage
    final stageIndex = _calculateTreeStage(newGrowth, growthStages.length);
    final currentStage = growthStages[stageIndex];
    
    return {
      'tree_type': treeType,
      'current_stage': currentStage,
      'stage_index': stageIndex,
      'growth_points': newGrowth,
      'points_earned': growthPoints,
      'is_fully_grown': stageIndex >= growthStages.length - 1,
      'next_stage': stageIndex < growthStages.length - 1 ? growthStages[stageIndex + 1] : null,
      'points_to_next_stage': stageIndex < growthStages.length - 1 ? 
          _getPointsForStage(stageIndex + 1) - newGrowth : 0,
    };
  }
  
  static int _calculateTreeStage(double growthPoints, int totalStages) {
    // Each stage requires exponentially more points
    for (int stage = 0; stage < totalStages; stage++) {
      final requiredPoints = _getPointsForStage(stage);
      if (growthPoints < requiredPoints) {
        return math.max(0, stage - 1);
      }
    }
    return totalStages - 1; // Fully grown
  }
  
  static double _getPointsForStage(int stage) {
    // Exponential growth: 100, 300, 700, 1500, 3100 points
    return 100 * (math.pow(2, stage + 1) - 1);
  }
  
  /// Integrate tasks with Pomodoro sessions
  static List<Map<String, dynamic>> planTaskPomodoros(
    List<Map<String, dynamic>> tasks,
    Map<String, int> pomodoroSettings,
  ) {
    final plannedSessions = <Map<String, dynamic>>[];
    final workDuration = pomodoroSettings['work_duration'] ?? 25;
    
    for (final task in tasks) {
      final estimatedMinutes = task['estimated_minutes'] as int? ?? 30;
      final complexity = task['complexity'] as String? ?? 'medium';
      final priority = task['priority'] as String? ?? 'medium';
      
      // Calculate number of pomodoros needed
      int pomodorosNeeded = (estimatedMinutes / workDuration).ceil();
      
      // Adjust based on complexity
      switch (complexity) {
        case 'low':
          pomodorosNeeded = math.max(1, (pomodorosNeeded * 0.8).round());
          break;
        case 'high':
          pomodorosNeeded = (pomodorosNeeded * 1.3).round();
          break;
        case 'very_high':
          pomodorosNeeded = (pomodorosNeeded * 1.5).round();
          break;
      }
      
      // Limit pomodoros per task
      pomodorosNeeded = math.min(pomodorosNeeded, FocusConstants.taskIntegration['max_pomodoros_per_subtask'] as int);
      
      // Create session plan
      for (int i = 0; i < pomodorosNeeded; i++) {
        plannedSessions.add({
          'task_id': task['id'],
          'task_name': task['name'],
          'session_number': i + 1,
          'total_sessions': pomodorosNeeded,
          'duration': workDuration,
          'type': FocusConstants.deepWork,
          'priority': priority,
          'complexity': complexity,
          'focus_areas': _generateFocusAreas(task['name'] as String, complexity),
        });
      }
    }
    
    // Sort by priority and complexity
    plannedSessions.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final priorityA = priorityOrder[a['priority']] ?? 2;
      final priorityB = priorityOrder[b['priority']] ?? 2;
      
      if (priorityA != priorityB) {
        return priorityB.compareTo(priorityA);
      }
      
      // Secondary sort by complexity (easier tasks first for momentum)
      final complexityOrder = {'low': 1, 'medium': 2, 'high': 3, 'very_high': 4};
      final complexityA = complexityOrder[a['complexity']] ?? 2;
      final complexityB = complexityOrder[b['complexity']] ?? 2;
      
      return complexityA.compareTo(complexityB);
    });
    
    return plannedSessions;
  }
  
  static List<String> _generateFocusAreas(String taskName, String complexity) {
    final focusAreas = <String>[];
    
    // Generate focus areas based on task name keywords
    final taskLower = taskName.toLowerCase();
    
    if (taskLower.contains('write') || taskLower.contains('document')) {
      focusAreas.addAll(['outline_structure', 'clear_writing', 'proofreading']);
    } else if (taskLower.contains('code') || taskLower.contains('develop')) {
      focusAreas.addAll(['algorithm_design', 'clean_code', 'testing']);
    } else if (taskLower.contains('research') || taskLower.contains('analyze')) {
      focusAreas.addAll(['information_gathering', 'critical_thinking', 'synthesis']);
    } else if (taskLower.contains('design') || taskLower.contains('create')) {
      focusAreas.addAll(['creative_thinking', 'visual_design', 'user_experience']);
    } else {
      focusAreas.addAll(['task_completion', 'attention_to_detail', 'quality_control']);
    }
    
    // Add complexity-specific areas
    if (complexity == 'high' || complexity == 'very_high') {
      focusAreas.add('deep_concentration');
      focusAreas.add('problem_solving');
    }
    
    return focusAreas.take(3).toList(); // Limit to 3 focus areas
  }
  
  /// Block distractions during focus sessions
  static Map<String, dynamic> configureDistractionBlocking(
    Map<String, dynamic> userPreferences,
    String sessionType,
    int sessionDuration,
  ) {
    final blockingConfig = <String, dynamic>{};
    
    final blockingLevel = userPreferences['blocking_level'] as String? ?? 'moderate';
    final customBlockedSites = userPreferences['blocked_sites'] as List<String>? ?? [];
    final allowEmergency = userPreferences['allow_emergency_access'] as bool? ?? true;
    
    // Configure website blocking
    final websitesToBlock = <String>[];
    websitesToBlock.addAll(FocusConstants.distractionBlocking['website_blocking']!['default_blocked_sites'] as List<String>);
    websitesToBlock.addAll(customBlockedSites);
    
    if (blockingLevel == 'strict') {
      websitesToBlock.addAll(['news.ycombinator.com', 'medium.com', 'wikipedia.org']);
    }
    
    blockingConfig['websites'] = {
      'blocked_sites': websitesToBlock.toSet().toList(),
      'allow_temporary_access': allowEmergency,
      'penalty_for_access': sessionType == FocusConstants.deepWork ? 5 : 2, // minutes deducted
    };
    
    // Configure app blocking
    final appsToBlock = <String>[];
    if (blockingLevel != 'minimal') {
      appsToBlock.addAll(['com.facebook.katana', 'com.twitter.android', 'com.instagram.android']);
    }
    
    if (blockingLevel == 'strict') {
      appsToBlock.addAll(['com.whatsapp', 'com.snapchat.android', 'com.tiktok']);
    }
    
    blockingConfig['apps'] = {
      'blocked_apps': appsToBlock,
      'blocking_duration': sessionDuration,
    };
    
    // Configure notification management
    blockingConfig['notifications'] = {
      'silence_all': blockingLevel == 'strict',
      'whitelist': allowEmergency ? ['emergency_contacts', 'work_contacts'] : [],
      'break_notifications': true, // Allow break reminders
    };
    
    return blockingConfig;
  }
  
  /// Calculate focus analytics and insights
  static Map<String, dynamic> calculateFocusAnalytics(
    List<Map<String, dynamic>> sessions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredSessions = sessions.where((session) {
      final sessionDate = DateTime.parse(session['date'] as String);
      return sessionDate.isAfter(startDate) && sessionDate.isBefore(endDate);
    }).toList();
    
    if (filteredSessions.isEmpty) {
      return {
        'total_focus_time': 0,
        'average_session_length': 0,
        'focus_quality_trend': 'no_data',
        'most_productive_hours': [],
        'distraction_patterns': {},
        'productivity_score': 0,
      };
    }
    
    // Calculate total focus time
    final totalMinutes = filteredSessions.fold<int>(0, 
        (sum, session) => sum + (session['duration'] as int? ?? 0));
    
    // Calculate average session length
    final avgSessionLength = totalMinutes / filteredSessions.length;
    
    // Analyze quality trend
    final qualityTrend = _analyzeFocusQualityTrend(filteredSessions);
    
    // Find most productive hours
    final productiveHours = _findMostProductiveHours(filteredSessions);
    
    // Analyze distraction patterns
    final distractionPatterns = _analyzeDistractionPatterns(filteredSessions);
    
    // Calculate productivity score
    final productivityScore = _calculateProductivityScore(filteredSessions);
    
    return {
      'period': '${DateTimeUtils.formatDate(startDate)} - ${DateTimeUtils.formatDate(endDate)}',
      'total_focus_time': totalMinutes,
      'total_focus_time_formatted': FocusUtils.formatFocusTime(totalMinutes),
      'session_count': filteredSessions.length,
      'average_session_length': avgSessionLength.round(),
      'focus_quality_trend': qualityTrend,
      'most_productive_hours': productiveHours,
      'distraction_patterns': distractionPatterns,
      'productivity_score': productivityScore,
      'recommendations': _generateAnalyticsRecommendations(
          qualityTrend, productiveHours, distractionPatterns, productivityScore),
    };
  }
  
  static String _analyzeFocusQualityTrend(List<Map<String, dynamic>> sessions) {
    if (sessions.length < 5) return 'insufficient_data';
    
    final midPoint = sessions.length ~/ 2;
    final firstHalf = sessions.take(midPoint);
    final secondHalf = sessions.skip(midPoint);
    
    final firstHalfAvg = firstHalf.fold<double>(0, 
        (sum, session) => sum + (session['quality_score'] as double? ?? 5.0)) / midPoint;
    final secondHalfAvg = secondHalf.fold<double>(0, 
        (sum, session) => sum + (session['quality_score'] as double? ?? 5.0)) / (sessions.length - midPoint);
    
    final difference = secondHalfAvg - firstHalfAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }
  
  static List<int> _findMostProductiveHours(List<Map<String, dynamic>> sessions) {
    final hourScores = <int, double>{};
    
    for (final session in sessions) {
      final sessionTime = DateTime.parse(session['start_time'] as String);
      final hour = sessionTime.hour;
      final quality = session['quality_score'] as double? ?? 5.0;
      
      hourScores[hour] = (hourScores[hour] ?? 0.0) + quality;
    }
    
    // Get top 3 productive hours
    final sortedHours = hourScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedHours.take(3).map((entry) => entry.key).toList();
  }
  
  static Map<String, dynamic> _analyzeDistractionPatterns(List<Map<String, dynamic>> sessions) {
    final totalDistractions = sessions.fold<int>(0, 
        (sum, session) => sum + (session['distractions'] as int? ?? 0));
    
    final avgDistractions = totalDistractions / sessions.length;
    
    // Analyze distraction by time of day
    final hourlyDistractions = <int, int>{};
    for (final session in sessions) {
      final sessionTime = DateTime.parse(session['start_time'] as String);
      final hour = sessionTime.hour;
      final distractions = session['distractions'] as int? ?? 0;
      
      hourlyDistractions[hour] = (hourlyDistractions[hour] ?? 0) + distractions;
    }
    
    final mostDistractingHour = hourlyDistractions.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    
    return {
      'average_distractions_per_session': avgDistractions.toStringAsFixed(1),
      'total_distractions': totalDistractions,
      'most_distracting_hour': mostDistractingHour,
      'distraction_trend': avgDistractions < 2 ? 'low' : 
                          avgDistractions < 5 ? 'moderate' : 'high',
    };
  }
  
  static int _calculateProductivityScore(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0;
    
    double score = 0;
    
    // Quality component (40%)
    final avgQuality = sessions.fold<double>(0, 
        (sum, session) => sum + (session['quality_score'] as double? ?? 5.0)) / sessions.length;
    score += (avgQuality / 10.0) * 40;
    
    // Consistency component (30%)
    final uniqueDays = sessions.map((session) => 
        DateTime.parse(session['date'] as String).day).toSet().length;
    final consistencyScore = math.min(uniqueDays / 7.0, 1.0); // Max 1 week
    score += consistencyScore * 30;
    
    // Volume component (20%)
    final totalMinutes = sessions.fold<int>(0, 
        (sum, session) => sum + (session['duration'] as int? ?? 0));
    final volumeScore = math.min(totalMinutes / (7 * 60), 1.0); // Target 1 hour per day
    score += volumeScore * 20;
    
    // Improvement component (10%)
    final trend = _analyzeFocusQualityTrend(sessions);
    final improvementScore = trend == 'improving' ? 1.0 : 
                            trend == 'stable' ? 0.7 : 0.3;
    score += improvementScore * 10;
    
    return score.round().clamp(0, 100);
  }
  
  static List<String> _generateAnalyticsRecommendations(
    String qualityTrend,
    List<int> productiveHours,
    Map<String, dynamic> distractionPatterns,
    int productivityScore,
  ) {
    final recommendations = <String>[];
    
    if (qualityTrend == 'declining') {
      recommendations.add('Consider shorter session durations to improve focus quality');
    } else if (qualityTrend == 'improving') {
      recommendations.add('Great progress! Try gradually increasing session lengths');
    }
    
    if (productiveHours.isNotEmpty) {
      recommendations.add('Schedule important tasks during your peak hours: ${productiveHours.join(", ")}:00');
    }
    
    final avgDistractions = double.tryParse(distractionPatterns['average_distractions_per_session'] as String? ?? '0') ?? 0;
    if (avgDistractions > 3) {
      recommendations.add('High distraction rate detected. Consider stricter blocking settings');
    }
    
    if (productivityScore < 60) {
      recommendations.add('Focus on consistency - try shorter but regular sessions');
    } else if (productivityScore > 80) {
      recommendations.add('Excellent focus habits! Consider mentoring others or trying advanced techniques');
    }
    
    return recommendations;
  }
  
  /// Validate focus session data
  static Map<String, String?> validateFocusData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final duration = data['duration'] as int?;
    if (duration != null && (duration < FocusConstants.minSessionDuration || 
                           duration > FocusConstants.maxSessionDuration)) {
      errors['duration'] = 'Session duration must be between ${FocusConstants.minSessionDuration} and ${FocusConstants.maxSessionDuration} minutes';
    }
    
    final qualityRating = data['quality_rating'] as double?;
    if (qualityRating != null && (qualityRating < 1.0 || qualityRating > 10.0)) {
      errors['quality_rating'] = 'Quality rating must be between 1 and 10';
    }
    
    final distractions = data['distractions'] as int?;
    if (distractions != null && distractions < 0) {
      errors['distractions'] = 'Distractions count cannot be negative';
    }
    
    return errors;
  }
  
  /// Format focus time for display
  static String formatFocusTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
  
  /// Get session type color
  static String getSessionTypeColor(String sessionType) {
    switch (sessionType) {
      case FocusConstants.deepWork:
        return '#2ECC71'; // Green
      case FocusConstants.learning:
        return '#3498DB'; // Blue
      case FocusConstants.creative:
        return '#9B59B6'; // Purple
      case FocusConstants.administrative:
        return '#F39C12'; // Orange
      case FocusConstants.planning:
        return '#E74C3C'; // Red
      default:
        return '#95A5A6'; // Gray
    }
  }
}
