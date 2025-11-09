import 'package:injectable/injectable.dart';
import '../../domain/entities/sleep_entity.dart';
import '../../core/utils/sleep_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class SleepService {
  Future<SleepSessionEntity> startSleepTracking(String userId, Map<String, dynamic> sleepData);
  Future<SleepSessionEntity> endSleepTracking(String sessionId, Map<String, dynamic> wakeData);
  Future<List<SleepSessionEntity>> getUserSleepSessions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Map<String, dynamic>> getSleepAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> generateSleepRecommendations(String userId);
  Future<DateTime> calculateOptimalBedtime(String userId, DateTime targetWakeTime);
  Future<List<DateTime>> generateSmartAlarmTimes(String userId, DateTime targetWakeTime);
  Future<bool> logSleepDisturbance(String sessionId, Map<String, dynamic> disturbanceData);
  Future<Map<String, dynamic>> analyzeSleepQuality(String sessionId);
  Future<List<String>> generateBedtimeRoutineSuggestions(String userId);
}

@LazySingleton(as: SleepService)
class SleepServiceImpl implements SleepService {
  @override
  Future<SleepSessionEntity> startSleepTracking(String userId, Map<String, dynamic> sleepData) async {
    try {
      final now = DateTime.now();
      final sessionId = 'sleep_${now.millisecondsSinceEpoch}';
      
      final session = SleepSessionEntity(
        id: sessionId,
        userId: userId,
        bedtime: sleepData['bedtime'] != null 
            ? DateTime.parse(sleepData['bedtime'] as String)
            : now,
        targetSleepDuration: sleepData['target_duration'] != null
            ? Duration(hours: sleepData['target_duration'] as int)
            : const Duration(hours: 8),
        targetBedtime: sleepData['target_bedtime'] != null
            ? DateTime.parse(sleepData['target_bedtime'] as String)
            : null,
        targetWakeTime: sleepData['target_wake_time'] != null
            ? DateTime.parse(sleepData['target_wake_time'] as String)
            : null,
        trackingMethod: sleepData['tracking_method'] as String? ?? 'manual',
        roomTemperature: sleepData['room_temperature'] as double?,
        lightLevel: sleepData['light_level'] as int?,
        noiseLevel: sleepData['noise_level'] as int?,
        weather: sleepData['weather'] as String?,
        sleepEnvironment: sleepData['sleep_environment'] as String? ?? 'bedroom',
        bedtimeRoutineActivities: (sleepData['routine_activities'] as List<dynamic>?)?.cast<String>() ?? [],
        screenTimeBeforeBed: sleepData['screen_time_minutes'] as int? ?? 0,
        lastMeal: sleepData['last_meal'] as String?,
        lastCaffeine: sleepData['last_caffeine'] as String?,
        lastAlcohol: sleepData['last_alcohol'] as String?,
        supplements: (sleepData['supplements'] as List<dynamic>?)?.cast<String>() ?? [],
        sleepAids: (sleepData['sleep_aids'] as List<dynamic>?)?.cast<String>() ?? [],
        playedSounds: sleepData['played_sounds'] as String?,
        usedSmartAlarm: sleepData['use_smart_alarm'] as bool? ?? false,
        moodBeforeSleep: sleepData['mood_before'] as int?,
        energyLevelBeforeSleep: sleepData['energy_before'] as int?,
        attemptedLucidDreaming: sleepData['lucid_dreaming'] as bool? ?? false,
        lucidDreamTechnique: sleepData['lucid_technique'] as String?,
        createdAt: now,
      );
      
      return session;
    } catch (e) {
      throw Exception('Failed to start sleep tracking: ${e.toString()}');
    }
  }

  @override
  Future<SleepSessionEntity> endSleepTracking(String sessionId, Map<String, dynamic> wakeData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Sleep session not found');
      }
      
      final now = DateTime.now();
      final wakeTime = wakeData['wake_time'] != null 
          ? DateTime.parse(wakeData['wake_time'] as String)
          : now;
      
      final getUpTime = wakeData['get_up_time'] != null
          ? DateTime.parse(wakeData['get_up_time'] as String)
          : wakeTime;
      
      // Calculate sleep metrics
      final timeInBed = getUpTime.difference(session.bedtime);
      final sleepTime = wakeData['sleep_time'] != null
          ? DateTime.parse(wakeData['sleep_time'] as String)
          : session.bedtime.add(const Duration(minutes: 15)); // Estimate
      
      final actualSleepDuration = wakeTime.difference(sleepTime);
      final sleepEfficiency = actualSleepDuration.inMinutes / timeInBed.inMinutes;
      
      // Calculate sleep quality
      final qualityScore = SleepUtils.calculateSleepQuality(
        duration: actualSleepDuration.inHours.toDouble(),
        efficiency: sleepEfficiency,
        deepSleepMinutes: wakeData['deep_sleep_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.2).round(),
        remSleepMinutes: wakeData['rem_sleep_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.25).round(),
        awakenings: wakeData['awakening_count'] as int? ?? 0,
      );
      
      // Generate sleep phases if not provided
      final sleepPhases = wakeData['sleep_phases'] as List<SleepPhaseEntity>? ?? 
          _generateSleepPhases(sessionId, sleepTime, wakeTime);
      
      final completedSession = session.copyWith(
        sleepTime: sleepTime,
        wakeTime: wakeTime,
        getUpTime: getUpTime,
        totalMinutesInBed: timeInBed.inMinutes,
        actualSleepMinutes: actualSleepDuration.inMinutes,
        sleepEfficiency: sleepEfficiency,
        overallQualityScore: qualityScore,
        deepSleepMinutes: wakeData['deep_sleep_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.2).round(),
        remSleepMinutes: wakeData['rem_sleep_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.25).round(),
        lightSleepMinutes: wakeData['light_sleep_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.45).round(),
        awakeMinutes: wakeData['awake_minutes'] as int? ?? 
            (actualSleepDuration.inMinutes * 0.1).round(),
        sleepPhases: sleepPhases,
        restlessnessScore: wakeData['restlessness'] as int? ?? 3,
        snoreEvents: wakeData['snore_events'] as int? ?? 0,
        moodAfterWaking: wakeData['mood_after'] as int?,
        energyLevelAfterWaking: wakeData['energy_after'] as int?,
        sleepDreams: wakeData['dream_description'] as String?,
        hadLucidDream: wakeData['had_lucid_dream'] as bool? ?? false,
        dreamJournal: wakeData['dream_journal'] as String?,
        heartRateAvg: wakeData['heart_rate_avg'] as int?,
        heartRateVariability: wakeData['hrv'] as int?,
        bodyTemperature: wakeData['body_temperature'] as double?,
        respiratoryRate: wakeData['respiratory_rate'] as int?,
        metSleepGoal: _checkSleepGoal(actualSleepDuration, session.targetSleepDuration),
        notes: wakeData['notes'] as String?,
        updatedAt: now,
      );
      
      return completedSession;
    } catch (e) {
      throw Exception('Failed to end sleep tracking: ${e.toString()}');
    }
  }

  @override
  Future<List<SleepSessionEntity>> getUserSleepSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      final mockSessions = _generateMockSessions(userId);
      
      if (startDate != null || endDate != null) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = endDate ?? DateTime.now();
        
        return mockSessions.where((session) {
          return session.bedtime.isAfter(start) && session.bedtime.isBefore(end);
        }).toList();
      }
      
      return mockSessions;
    } catch (e) {
      throw Exception('Failed to retrieve sleep sessions: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getSleepAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final sessions = await getUserSleepSessions(userId, startDate: startDate, endDate: endDate);
      
      if (sessions.isEmpty) {
        return {
          'total_sessions': 0,
          'average_sleep_duration': 0.0,
          'average_quality': 0.0,
          'sleep_efficiency': 0.0,
        };
      }
      
      final completedSessions = sessions.where((s) => s.isCompleteSession).toList();
      
      final totalSessions = completedSessions.length;
      final averageDuration = completedSessions.isEmpty ? 0.0 :
          completedSessions.fold<int>(0, (sum, s) => sum + s.actualSleepMinutes) / totalSessions / 60.0;
      
      final averageQuality = completedSessions.isEmpty ? 0.0 :
          completedSessions.fold<double>(0, (sum, s) => sum + s.overallQualityScore) / totalSessions;
      
      final averageEfficiency = completedSessions.isEmpty ? 0.0 :
          completedSessions.fold<double>(0, (sum, s) => sum + s.sleepEfficiency) / totalSessions;
      
      // Sleep debt calculation
      final sleepDebt = SleepUtils.calculateSleepDebt(
        sessions: completedSessions,
        targetHours: 8.0,
        days: 7,
      );
      
      // Sleep patterns analysis
      final bedtimePattern = _analyzeBedtimePattern(completedSessions);
      final qualityTrends = _analyzeQualityTrends(completedSessions);
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_sessions': totalSessions,
          'average_sleep_duration_hours': averageDuration,
          'average_quality_score': averageQuality,
          'average_sleep_efficiency': averageEfficiency,
          'sleep_debt_hours': sleepDebt,
        },
        'patterns': {
          'bedtime_consistency': bedtimePattern,
          'quality_trends': qualityTrends,
          'sleep_stage_distribution': _getSleepStageDistribution(completedSessions),
        },
        'insights': _generateSleepInsights(completedSessions),
        'recommendations': await generateSleepRecommendations(userId),
      };
    } catch (e) {
      throw Exception('Failed to get sleep analytics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateSleepRecommendations(String userId) async {
    try {
      final recentSessions = await getUserSleepSessions(
        userId, 
        startDate: DateTime.now().subtract(const Duration(days: 14))
      );
      
      return SleepUtils.generatePersonalizedRecommendations(
        userId: userId,
        recentSessions: recentSessions,
        currentAge: 30, // Mock age
        healthConditions: [], // Mock health conditions
        lifestyle: {
          'caffeine_consumption': 'moderate',
          'exercise_frequency': 'regular',
          'stress_level': 'medium',
        },
      );
    } catch (e) {
      throw Exception('Failed to generate sleep recommendations: ${e.toString()}');
    }
  }

  @override
  Future<DateTime> calculateOptimalBedtime(String userId, DateTime targetWakeTime) async {
    try {
      final recentSessions = await getUserSleepSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 7))
      );
      
      return SleepUtils.calculateOptimalBedtime(
        targetWakeTime: targetWakeTime,
        recentSessions: recentSessions,
        userAge: 30, // Mock age
        sleepGoalHours: 8.0,
      );
    } catch (e) {
      throw Exception('Failed to calculate optimal bedtime: ${e.toString()}');
    }
  }

  @override
  Future<List<DateTime>> generateSmartAlarmTimes(String userId, DateTime targetWakeTime) async {
    try {
      final recentSessions = await getUserSleepSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 7))
      );
      
      return SleepUtils.findOptimalWakeTimes(
        targetWakeTime: targetWakeTime,
        sleepCycles: 5, // Typical number of cycles
        recentSessions: recentSessions,
        windowMinutes: 30,
      );
    } catch (e) {
      throw Exception('Failed to generate smart alarm times: ${e.toString()}');
    }
  }

  @override
  Future<bool> logSleepDisturbance(String sessionId, Map<String, dynamic> disturbanceData) async {
    try {
      final now = DateTime.now();
      final disturbance = DisturbanceEntity(
        id: 'disturbance_${now.millisecondsSinceEpoch}',
        sleepSessionId: sessionId,
        timestamp: disturbanceData['timestamp'] != null
            ? DateTime.parse(disturbanceData['timestamp'] as String)
            : now,
        type: disturbanceData['type'] as String,
        intensity: disturbanceData['intensity'] as int? ?? 1,
        durationSeconds: disturbanceData['duration_seconds'] as int? ?? 0,
        description: disturbanceData['description'] as String?,
        source: disturbanceData['source'] as String?,
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to log sleep disturbance: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeSleepQuality(String sessionId) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Sleep session not found');
      }
      
      final qualityFactors = <String, dynamic>{};
      
      // Duration analysis
      final targetHours = session.targetSleepDuration?.inHours ?? 8;
      final actualHours = session.actualSleepMinutes / 60.0;
      qualityFactors['duration_score'] = _scoreDuration(actualHours, targetHours.toDouble());
      
      // Efficiency analysis
      qualityFactors['efficiency_score'] = _scoreEfficiency(session.sleepEfficiency);
      
      // Sleep stages analysis
      qualityFactors['deep_sleep_score'] = _scoreDeepSleep(
        session.deepSleepMinutes, 
        session.actualSleepMinutes
      );
      
      // Disturbances analysis
      qualityFactors['disturbance_score'] = _scoreDisturbances(session.disturbances.length);
      
      // Overall recommendations
      final recommendations = <String>[];
      
      if (qualityFactors['duration_score'] < 7) {
        recommendations.add('Try to get closer to ${targetHours} hours of sleep');
      }
      
      if (qualityFactors['efficiency_score'] < 7) {
        recommendations.add('Improve sleep efficiency by reducing time awake in bed');
      }
      
      if (qualityFactors['deep_sleep_score'] < 7) {
        recommendations.add('Focus on activities that promote deep sleep');
      }
      
      return {
        'session_id': sessionId,
        'overall_quality': session.overallQualityScore,
        'quality_factors': qualityFactors,
        'recommendations': recommendations,
        'sleep_rating': session.sleepQualityRating,
      };
    } catch (e) {
      throw Exception('Failed to analyze sleep quality: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateBedtimeRoutineSuggestions(String userId) async {
    try {
      final recentSessions = await getUserSleepSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 7))
      );
      
      final suggestions = <String>[];
      
      // Analyze current routine effectiveness
      final routineActivities = <String, int>{};
      for (final session in recentSessions) {
        for (final activity in session.bedtimeRoutineActivities) {
          routineActivities[activity] = (routineActivities[activity] ?? 0) + 1;
        }
      }
      
      // Base suggestions
      suggestions.addAll([
        'Read a book for 15-30 minutes',
        'Practice deep breathing or meditation',
        'Take a warm bath or shower',
        'Write in a gratitude journal',
        'Listen to calming music or sounds',
        'Do gentle stretching or yoga',
        'Prepare clothes for tomorrow',
        'Dim lights 1 hour before bed',
      ]);
      
      // Personalized suggestions based on data
      final avgQuality = recentSessions.isEmpty ? 0.0 :
          recentSessions.fold<double>(0, (sum, s) => sum + s.overallQualityScore) / recentSessions.length;
      
      if (avgQuality < 6.0) {
        suggestions.addAll([
          'Avoid screens 1 hour before bed',
          'Keep bedroom temperature between 65-68°F',
          'Use blackout curtains or sleep mask',
        ]);
      }
      
      return suggestions.take(10).toList();
    } catch (e) {
      throw Exception('Failed to generate bedtime routine suggestions: ${e.toString()}');
    }
  }

  // Private helper methods
  List<SleepSessionEntity> _generateMockSessions(String userId) {
    final now = DateTime.now();
    
    return [
      SleepSessionEntity(
        id: 'sleep_1',
        userId: userId,
        bedtime: now.subtract(const Duration(days: 1, hours: 10)),
        sleepTime: now.subtract(const Duration(days: 1, hours: 9, minutes: 45)),
        wakeTime: now.subtract(const Duration(hours: 2)),
        getUpTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        totalMinutesInBed: 480, // 8 hours
        actualSleepMinutes: 420, // 7 hours
        sleepEfficiency: 0.875,
        overallQualityScore: 7.5,
        deepSleepMinutes: 84,
        remSleepMinutes: 105,
        lightSleepMinutes: 189,
        awakeMinutes: 42,
        restlessnessScore: 3,
        snoreEvents: 2,
        moodBefore: 6,
        moodAfter: 8,
        energyLevelBefore: 4,
        energyLevelAfterWaking: 7,
        targetSleepDuration: const Duration(hours: 8),
        metSleepGoal: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<SleepSessionEntity?> _getSessionById(String sessionId) async {
    final sessions = _generateMockSessions('user_id');
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  List<SleepPhaseEntity> _generateSleepPhases(String sessionId, DateTime sleepTime, DateTime wakeTime) {
    final phases = <SleepPhaseEntity>[];
    final totalDuration = wakeTime.difference(sleepTime);
    final cycleLength = 90; // minutes per cycle
    final cycles = (totalDuration.inMinutes / cycleLength).floor();
    
    for (int i = 0; i < cycles; i++) {
      final cycleStart = sleepTime.add(Duration(minutes: i * cycleLength));
      
      // Light sleep (45 minutes)
      phases.add(SleepPhaseEntity(
        id: 'phase_${sessionId}_${i}_light',
        sleepSessionId: sessionId,
        phase: 'light',
        startTime: cycleStart,
        endTime: cycleStart.add(const Duration(minutes: 45)),
        durationMinutes: 45,
      ));
      
      // Deep sleep (20 minutes)
      phases.add(SleepPhaseEntity(
        id: 'phase_${sessionId}_${i}_deep',
        sleepSessionId: sessionId,
        phase: 'deep',
        startTime: cycleStart.add(const Duration(minutes: 45)),
        endTime: cycleStart.add(const Duration(minutes: 65)),
        durationMinutes: 20,
      ));
      
      // REM sleep (25 minutes)
      phases.add(SleepPhaseEntity(
        id: 'phase_${sessionId}_${i}_rem',
        sleepSessionId: sessionId,
        phase: 'rem',
        startTime: cycleStart.add(const Duration(minutes: 65)),
        endTime: cycleStart.add(const Duration(minutes: 90)),
        durationMinutes: 25,
      ));
    }
    
    return phases;
  }

  bool _checkSleepGoal(Duration actualSleep, Duration? targetSleep) {
    if (targetSleep == null) return true;
    return actualSleep.inMinutes >= (targetSleep.inMinutes * 0.9); // 90% of goal
  }

  Map<String, dynamic> _analyzeBedtimePattern(List<SleepSessionEntity> sessions) {
    if (sessions.isEmpty) return {'consistency': 0.0, 'average_bedtime': null};
    
    final bedtimes = sessions.map((s) => s.bedtime.hour * 60 + s.bedtime.minute).toList();
    final avgBedtime = bedtimes.reduce((a, b) => a + b) / bedtimes.length;
    
    // Calculate standard deviation for consistency
    final variance = bedtimes.map((t) => math.pow(t - avgBedtime, 2)).reduce((a, b) => a + b) / bedtimes.length;
    final stdDev = math.sqrt(variance);
    
    // Consistency score (lower stdDev = higher consistency)
    final consistency = math.max(0.0, 1.0 - (stdDev / 60.0)); // Normalize by hour
    
    final avgHour = (avgBedtime / 60).floor();
    final avgMinute = (avgBedtime % 60).round();
    
    return {
      'consistency': consistency,
      'average_bedtime': '${avgHour.toString().padLeft(2, '0')}:${avgMinute.toString().padLeft(2, '0')}',
      'bedtime_variance_minutes': stdDev,
    };
  }

  List<Map<String, dynamic>> _analyzeQualityTrends(List<SleepSessionEntity> sessions) {
    return sessions.map((session) => {
      'date': DateUtils.formatDate(session.bedtime, 'yyyy-MM-dd'),
      'quality_score': session.overallQualityScore,
      'duration_hours': session.actualSleepMinutes / 60.0,
      'efficiency': session.sleepEfficiency,
    }).toList();
  }

  Map<String, double> _getSleepStageDistribution(List<SleepSessionEntity> sessions) {
    if (sessions.isEmpty) return {};
    
    final totalSleep = sessions.fold<int>(0, (sum, s) => sum + s.actualSleepMinutes);
    final totalDeep = sessions.fold<int>(0, (sum, s) => sum + s.deepSleepMinutes);
    final totalRem = sessions.fold<int>(0, (sum, s) => sum + s.remSleepMinutes);
    final totalLight = sessions.fold<int>(0, (sum, s) => sum + s.lightSleepMinutes);
    
    return {
      'deep_sleep_percentage': totalSleep > 0 ? (totalDeep / totalSleep) * 100 : 0.0,
      'rem_sleep_percentage': totalSleep > 0 ? (totalRem / totalSleep) * 100 : 0.0,
      'light_sleep_percentage': totalSleep > 0 ? (totalLight / totalSleep) * 100 : 0.0,
    };
  }

  double _scoreDuration(double actualHours, double targetHours) {
    final ratio = actualHours / targetHours;
    if (ratio >= 0.9 && ratio <= 1.1) return 10.0;
    if (ratio >= 0.8 && ratio <= 1.2) return 8.0;
    if (ratio >= 0.7 && ratio <= 1.3) return 6.0;
    return 4.0;
  }

  double _scoreEfficiency(double efficiency) {
    if (efficiency >= 0.95) return 10.0;
    if (efficiency >= 0.90) return 8.0;
    if (efficiency >= 0.85) return 7.0;
    if (efficiency >= 0.80) return 6.0;
    return 4.0;
  }

  double _scoreDeepSleep(int deepMinutes, int totalMinutes) {
    final percentage = totalMinutes > 0 ? deepMinutes / totalMinutes : 0.0;
    if (percentage >= 0.2) return 10.0; // 20%+ is excellent
    if (percentage >= 0.15) return 8.0;
    if (percentage >= 0.10) return 6.0;
    return 4.0;
  }

  double _scoreDisturbances(int disturbanceCount) {
    if (disturbanceCount == 0) return 10.0;
    if (disturbanceCount <= 2) return 8.0;
    if (disturbanceCount <= 4) return 6.0;
    return 4.0;
  }

  List<String> _generateSleepInsights(List<SleepSessionEntity> sessions) {
    final insights = <String>[];
    
    if (sessions.isEmpty) {
      insights.add('Start tracking your sleep to get personalized insights.');
      return insights;
    }
    
    final avgQuality = sessions.fold<double>(0, (sum, s) => sum + s.overallQualityScore) / sessions.length;
    
    if (avgQuality >= 8.0) {
      insights.add('Excellent sleep quality! Your sleep habits are working well.');
    } else if (avgQuality >= 6.0) {
      insights.add('Good sleep quality overall. Small improvements could help.');
    } else {
      insights.add('Your sleep quality could improve. Consider adjusting your bedtime routine.');
    }
    
    final avgDuration = sessions.fold<int>(0, (sum, s) => sum + s.actualSleepMinutes) / sessions.length / 60.0;
    
    if (avgDuration < 7.0) {
      insights.add('You\'re getting less than 7 hours of sleep on average. Try to go to bed earlier.');
    } else if (avgDuration > 9.0) {
      insights.add('You\'re sleeping more than 9 hours on average. This might indicate oversleeping.');
    }
    
    final avgEfficiency = sessions.fold<double>(0, (sum, s) => sum + s.sleepEfficiency) / sessions.length;
    
    if (avgEfficiency < 0.85) {
      insights.add('Your sleep efficiency could improve. Try to reduce time awake in bed.');
    }
    
    return insights;
  }
}
