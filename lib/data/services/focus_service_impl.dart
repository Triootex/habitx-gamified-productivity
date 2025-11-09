import 'package:injectable/injectable.dart';
import '../../domain/entities/focus_entity.dart';
import '../../core/utils/focus_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class FocusService {
  Future<FocusSessionEntity> startFocusSession(String userId, Map<String, dynamic> sessionData);
  Future<FocusSessionEntity> endFocusSession(String sessionId, Map<String, dynamic> completionData);
  Future<bool> logDistraction(String sessionId, Map<String, dynamic> distractionData);
  Future<Map<String, dynamic>> getPomodoroRecommendations(String userId);
  Future<Map<String, dynamic>> getFocusAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<FocusSessionEntity>> getUserSessions(String userId);
  Future<Map<String, dynamic>> generateFocusInsights(String userId);
}

@LazySingleton(as: FocusService)
class FocusServiceImpl implements FocusService {
  @override
  Future<FocusSessionEntity> startFocusSession(String userId, Map<String, dynamic> sessionData) async {
    try {
      final now = DateTime.now();
      final sessionId = 'focus_${now.millisecondsSinceEpoch}';
      
      final session = FocusSessionEntity(
        id: sessionId,
        userId: userId,
        sessionType: sessionData['session_type'] as String? ?? 'deep_work',
        technique: sessionData['technique'] as String? ?? 'pomodoro',
        taskId: sessionData['task_id'] as String?,
        startTime: now,
        plannedDurationMinutes: sessionData['duration'] as int? ?? 25,
        environment: sessionData['environment'] as String? ?? 'quiet',
        location: sessionData['location'] as String?,
        treeType: sessionData['tree_type'] as String? ?? 'oak',
        treeStage: 'seed',
        pomodoroNumber: sessionData['pomodoro_number'] as int?,
        totalPomodoros: sessionData['total_pomodoros'] as int?,
        isBreak: sessionData['is_break'] as bool? ?? false,
        breakType: sessionData['break_type'] as String?,
        blockedApps: (sessionData['blocked_apps'] as List<dynamic>?)?.cast<String>() ?? [],
        blockedWebsites: (sessionData['blocked_websites'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: now,
      );
      
      return session;
    } catch (e) {
      throw Exception('Failed to start focus session: ${e.toString()}');
    }
  }

  @override
  Future<FocusSessionEntity> endFocusSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) throw Exception('Session not found');
      
      final now = DateTime.now();
      final actualDuration = now.difference(session.startTime);
      
      final qualityScore = FocusUtils.calculateSessionQuality(
        plannedDuration: session.plannedDurationMinutes,
        actualDuration: actualDuration.inMinutes,
        distractionsCount: session.distractionsCount,
        taskProgress: completionData['task_progress'] as double? ?? 0.0,
        focusRating: completionData['focus_rating'] as double? ?? 5.0,
      );
      
      final treeGrowthPoints = _calculateTreeGrowth(actualDuration.inMinutes, qualityScore);
      
      return session.copyWith(
        endTime: now,
        actualDurationMinutes: actualDuration.inMinutes,
        wasCompleted: completionData['was_completed'] as bool? ?? true,
        qualityScore: qualityScore,
        productivityRating: completionData['productivity_rating'] as double? ?? 5.0,
        taskProgress: completionData['task_progress'] as double? ?? 0.0,
        taskCompleted: completionData['task_completed'] as bool? ?? false,
        treeGrowthPoints: treeGrowthPoints,
        treeStage: _determineTreeStage(treeGrowthPoints),
        sessionNotes: completionData['notes'] as String?,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to end focus session: ${e.toString()}');
    }
  }

  @override
  Future<bool> logDistraction(String sessionId, Map<String, dynamic> distractionData) async {
    try {
      final distraction = DistractionEventEntity(
        id: 'distraction_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        timestamp: DateTime.now(),
        type: distractionData['type'] as String,
        category: distractionData['category'] as String,
        source: distractionData['source'] as String?,
        intensity: distractionData['intensity'] as int? ?? 1,
        durationSeconds: distractionData['duration_seconds'] as int? ?? 0,
        response: distractionData['response'] as String?,
        wasHandledWell: distractionData['handled_well'] as bool? ?? true,
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to log distraction: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPomodoroRecommendations(String userId) async {
    try {
      final userSessions = await getUserSessions(userId);
      
      return FocusUtils.generatePomodoroRecommendations(
        userId: userId,
        recentSessions: userSessions.take(10).toList(),
        currentTime: DateTime.now(),
        taskContext: 'general',
        energyLevel: 7,
      );
    } catch (e) {
      throw Exception('Failed to get Pomodoro recommendations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFocusAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final sessions = await getUserSessions(userId);
      final filteredSessions = sessions.where((s) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = endDate ?? DateTime.now();
        return s.startTime.isAfter(start) && s.startTime.isBefore(end);
      }).toList();
      
      if (filteredSessions.isEmpty) {
        return {
          'total_sessions': 0,
          'total_focus_time': 0,
          'average_quality': 0.0,
        };
      }
      
      final totalSessions = filteredSessions.length;
      final totalTime = filteredSessions.fold<int>(0, (sum, s) => sum + s.actualDurationMinutes);
      final averageQuality = filteredSessions.fold<double>(0, (sum, s) => sum + s.qualityScore) / totalSessions;
      
      return {
        'summary': {
          'total_sessions': totalSessions,
          'total_focus_time': totalTime,
          'average_session_length': totalTime / totalSessions,
          'average_quality': averageQuality,
        },
        'breakdown': {
          'by_technique': _getTechniqueBreakdown(filteredSessions),
          'by_session_type': _getSessionTypeBreakdown(filteredSessions),
          'quality_distribution': _getQualityDistribution(filteredSessions),
        },
        'insights': _generateFocusInsights(filteredSessions),
      };
    } catch (e) {
      throw Exception('Failed to get focus analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<FocusSessionEntity>> getUserSessions(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockSessions(userId);
    } catch (e) {
      throw Exception('Failed to get user sessions: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateFocusInsights(String userId) async {
    try {
      final sessions = await getUserSessions(userId);
      
      return {
        'productivity_score': _calculateProductivityScore(sessions),
        'focus_patterns': _analyzeFocusPatterns(sessions),
        'recommendations': _generateRecommendations(sessions),
        'achievements': _checkFocusAchievements(sessions),
      };
    } catch (e) {
      throw Exception('Failed to generate focus insights: ${e.toString()}');
    }
  }

  // Private helper methods
  List<FocusSessionEntity> _generateMockSessions(String userId) {
    final now = DateTime.now();
    return [
      FocusSessionEntity(
        id: 'focus_1',
        userId: userId,
        sessionType: 'deep_work',
        technique: 'pomodoro',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2)).add(const Duration(minutes: 25)),
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        wasCompleted: true,
        qualityScore: 8.0,
        productivityRating: 8.5,
        distractionsCount: 1,
        treeGrowthPoints: 25.0,
        treeStage: 'sapling',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<FocusSessionEntity?> _getSessionById(String sessionId) async {
    final sessions = _generateMockSessions('user_id');
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  double _calculateTreeGrowth(int durationMinutes, double qualityScore) {
    return durationMinutes * (qualityScore / 10.0);
  }

  String _determineTreeStage(double growthPoints) {
    if (growthPoints >= 500) return 'mature';
    if (growthPoints >= 200) return 'tree';
    if (growthPoints >= 50) return 'sapling';
    return 'sprout';
  }

  Map<String, int> _getTechniqueBreakdown(List<FocusSessionEntity> sessions) {
    final breakdown = <String, int>{};
    for (final session in sessions) {
      breakdown[session.technique] = (breakdown[session.technique] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _getSessionTypeBreakdown(List<FocusSessionEntity> sessions) {
    final breakdown = <String, int>{};
    for (final session in sessions) {
      breakdown[session.sessionType] = (breakdown[session.sessionType] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _getQualityDistribution(List<FocusSessionEntity> sessions) {
    final distribution = <String, int>{'excellent': 0, 'good': 0, 'fair': 0, 'poor': 0};
    
    for (final session in sessions) {
      if (session.qualityScore >= 8.0) {
        distribution['excellent'] = distribution['excellent']! + 1;
      } else if (session.qualityScore >= 6.0) {
        distribution['good'] = distribution['good']! + 1;
      } else if (session.qualityScore >= 4.0) {
        distribution['fair'] = distribution['fair']! + 1;
      } else {
        distribution['poor'] = distribution['poor']! + 1;
      }
    }
    return distribution;
  }

  double _calculateProductivityScore(List<FocusSessionEntity> sessions) {
    if (sessions.isEmpty) return 0.0;
    return sessions.fold<double>(0, (sum, s) => sum + s.qualityScore) / sessions.length;
  }

  Map<String, dynamic> _analyzeFocusPatterns(List<FocusSessionEntity> sessions) {
    return {
      'best_time_of_day': _getBestTimeOfDay(sessions),
      'optimal_session_length': _getOptimalSessionLength(sessions),
      'distraction_patterns': _getDistractionPatterns(sessions),
    };
  }

  String _getBestTimeOfDay(List<FocusSessionEntity> sessions) {
    final timeQuality = <String, List<double>>{};
    
    for (final session in sessions) {
      final hour = session.startTime.hour;
      String timeOfDay;
      if (hour >= 6 && hour < 12) {
        timeOfDay = 'morning';
      } else if (hour >= 12 && hour < 18) {
        timeOfDay = 'afternoon';
      } else {
        timeOfDay = 'evening';
      }
      
      timeQuality.putIfAbsent(timeOfDay, () => []);
      timeQuality[timeOfDay]!.add(session.qualityScore);
    }
    
    String bestTime = 'morning';
    double bestAverage = 0.0;
    
    timeQuality.forEach((time, qualities) {
      final average = qualities.reduce((a, b) => a + b) / qualities.length;
      if (average > bestAverage) {
        bestAverage = average;
        bestTime = time;
      }
    });
    
    return bestTime;
  }

  int _getOptimalSessionLength(List<FocusSessionEntity> sessions) {
    if (sessions.isEmpty) return 25;
    
    final avgDuration = sessions.fold<int>(0, (sum, s) => sum + s.actualDurationMinutes) / sessions.length;
    return avgDuration.round();
  }

  Map<String, int> _getDistractionPatterns(List<FocusSessionEntity> sessions) {
    final totalDistractions = sessions.fold<int>(0, (sum, s) => sum + s.distractionsCount);
    final totalSessions = sessions.length;
    
    return {
      'average_per_session': totalSessions > 0 ? (totalDistractions / totalSessions).round() : 0,
      'total_distractions': totalDistractions,
    };
  }

  List<String> _generateRecommendations(List<FocusSessionEntity> sessions) {
    final recommendations = <String>[];
    
    if (sessions.isEmpty) {
      recommendations.add('Start with short 15-minute focus sessions to build consistency.');
      return recommendations;
    }
    
    final avgQuality = sessions.fold<double>(0, (sum, s) => sum + s.qualityScore) / sessions.length;
    
    if (avgQuality < 6.0) {
      recommendations.add('Try shorter sessions to improve focus quality.');
      recommendations.add('Consider using noise-blocking headphones.');
    } else if (avgQuality >= 8.0) {
      recommendations.add('Excellent focus! Consider extending session duration.');
    }
    
    final avgDistractions = sessions.fold<int>(0, (sum, s) => sum + s.distractionsCount) / sessions.length;
    if (avgDistractions > 3) {
      recommendations.add('Too many distractions. Try finding a quieter workspace.');
    }
    
    return recommendations;
  }

  List<String> _checkFocusAchievements(List<FocusSessionEntity> sessions) {
    final achievements = <String>[];
    
    if (sessions.length >= 7) {
      achievements.add('Focus Warrior: 7+ focus sessions completed!');
    }
    
    final perfectSessions = sessions.where((s) => s.qualityScore >= 9.0).length;
    if (perfectSessions >= 3) {
      achievements.add('Perfect Focus: 3+ sessions with excellent quality!');
    }
    
    return achievements;
  }

  List<String> _generateFocusInsights(List<FocusSessionEntity> sessions) {
    final insights = <String>[];
    
    if (sessions.isEmpty) {
      insights.add('Start your focus journey with regular deep work sessions.');
      return insights;
    }
    
    final avgQuality = sessions.fold<double>(0, (sum, s) => sum + s.qualityScore) / sessions.length;
    
    if (avgQuality >= 8.0) {
      insights.add('Excellent focus quality! Your concentration skills are strong.');
    } else if (avgQuality >= 6.0) {
      insights.add('Good focus development. Keep practicing to improve concentration.');
    } else {
      insights.add('Focus takes practice. Start with shorter sessions and build up.');
    }
    
    if (sessions.length >= 5) {
      insights.add('Great consistency! Regular focus sessions are building your concentration muscle.');
    }
    
    return insights;
  }
}
