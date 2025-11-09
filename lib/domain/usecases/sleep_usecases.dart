import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/sleep_entity.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Start Sleep Tracking Use Case
@injectable
class StartSleepTrackingUseCase implements UseCase<SleepSessionEntity, StartSleepTrackingParams> {
  final SleepRepository repository;

  StartSleepTrackingUseCase(this.repository);

  @override
  Future<Either<Failure, SleepSessionEntity>> call(StartSleepTrackingParams params) async {
    return await repository.startSleepTracking(params.userId, params.sleepData);
  }
}

class StartSleepTrackingParams {
  final String userId;
  final Map<String, dynamic> sleepData;

  StartSleepTrackingParams({required this.userId, required this.sleepData});
}

// End Sleep Tracking Use Case
@injectable
class EndSleepTrackingUseCase implements UseCase<SleepSessionEntity, EndSleepTrackingParams> {
  final SleepRepository repository;

  EndSleepTrackingUseCase(this.repository);

  @override
  Future<Either<Failure, SleepSessionEntity>> call(EndSleepTrackingParams params) async {
    return await repository.endSleepTracking(params.sessionId, params.wakeData);
  }
}

class EndSleepTrackingParams {
  final String sessionId;
  final Map<String, dynamic> wakeData;

  EndSleepTrackingParams({required this.sessionId, required this.wakeData});
}

// Get User Sleep Sessions Use Case
@injectable
class GetUserSleepSessionsUseCase implements UseCase<List<SleepSessionEntity>, GetUserSleepSessionsParams> {
  final SleepRepository repository;

  GetUserSleepSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SleepSessionEntity>>> call(GetUserSleepSessionsParams params) async {
    return await repository.getUserSleepSessions(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserSleepSessionsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserSleepSessionsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Sleep Session Use Case
@injectable
class GetSleepSessionUseCase implements UseCase<SleepSessionEntity, String> {
  final SleepRepository repository;

  GetSleepSessionUseCase(this.repository);

  @override
  Future<Either<Failure, SleepSessionEntity>> call(String sessionId) async {
    return await repository.getSleepSession(sessionId);
  }
}

// Get Sleep Analytics Use Case
@injectable
class GetSleepAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetSleepAnalyticsParams> {
  final SleepRepository repository;

  GetSleepAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetSleepAnalyticsParams params) async {
    return await repository.getSleepAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetSleepAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetSleepAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Generate Sleep Recommendations Use Case
@injectable
class GenerateSleepRecommendationsUseCase implements UseCase<Map<String, dynamic>, String> {
  final SleepRepository repository;

  GenerateSleepRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.generateSleepRecommendations(userId);
  }
}

// Calculate Optimal Bedtime Use Case
@injectable
class CalculateOptimalBedtimeUseCase implements UseCase<DateTime, CalculateOptimalBedtimeParams> {
  final SleepRepository repository;

  CalculateOptimalBedtimeUseCase(this.repository);

  @override
  Future<Either<Failure, DateTime>> call(CalculateOptimalBedtimeParams params) async {
    return await repository.calculateOptimalBedtime(params.userId, params.targetWakeTime);
  }
}

class CalculateOptimalBedtimeParams {
  final String userId;
  final DateTime targetWakeTime;

  CalculateOptimalBedtimeParams({required this.userId, required this.targetWakeTime});
}

// Generate Smart Alarm Times Use Case
@injectable
class GenerateSmartAlarmTimesUseCase implements UseCase<List<DateTime>, GenerateSmartAlarmTimesParams> {
  final SleepRepository repository;

  GenerateSmartAlarmTimesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DateTime>>> call(GenerateSmartAlarmTimesParams params) async {
    return await repository.generateSmartAlarmTimes(params.userId, params.targetWakeTime);
  }
}

class GenerateSmartAlarmTimesParams {
  final String userId;
  final DateTime targetWakeTime;

  GenerateSmartAlarmTimesParams({required this.userId, required this.targetWakeTime});
}

// Log Sleep Disturbance Use Case
@injectable
class LogSleepDisturbanceUseCase implements UseCase<bool, LogSleepDisturbanceParams> {
  final SleepRepository repository;

  LogSleepDisturbanceUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(LogSleepDisturbanceParams params) async {
    return await repository.logSleepDisturbance(params.sessionId, params.disturbanceData);
  }
}

class LogSleepDisturbanceParams {
  final String sessionId;
  final Map<String, dynamic> disturbanceData;

  LogSleepDisturbanceParams({
    required this.sessionId,
    required this.disturbanceData,
  });
}

// Sync Sleep Data Use Case
@injectable
class SyncSleepDataUseCase implements UseCase<bool, String> {
  final SleepRepository repository;

  SyncSleepDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncSleepData(userId);
  }
}

// Sync with Health App Use Case
@injectable
class SyncSleepWithHealthAppUseCase implements UseCase<bool, String> {
  final SleepRepository repository;

  SyncSleepWithHealthAppUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncWithHealthApp(userId);
  }
}

// Calculate Sleep Quality Score Use Case
@injectable
class CalculateSleepQualityScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final SleepRepository repository;

  CalculateSleepQualityScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final sessionsResult = await repository.getUserSleepSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final qualityData = _calculateSleepQualityScore(sessions);
          return Right(qualityData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate sleep quality: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateSleepQualityScore(List<SleepSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return {
        'quality_score': 0,
        'sleep_efficiency': 0.0,
        'duration_score': 0,
        'consistency_score': 0,
        'disturbance_score': 0,
        'recommendation': 'Start tracking sleep to get personalized insights',
        'grade': 'No Data',
      };
    }
    
    // Calculate sleep efficiency (time asleep / time in bed)
    final efficiencies = <double>[];
    final durations = <int>[];
    final disturbanceCounts = <int>[];
    
    for (final session in sessions) {
      if (session.sleepEfficiency != null) {
        efficiencies.add(session.sleepEfficiency!);
      }
      if (session.totalDuration != null) {
        durations.add(session.totalDuration!);
      }
      disturbanceCounts.add(session.disturbances?.length ?? 0);
    }
    
    // Calculate averages
    final avgEfficiency = efficiencies.isNotEmpty 
        ? efficiencies.reduce((a, b) => a + b) / efficiencies.length 
        : 0.0;
    
    final avgDuration = durations.isNotEmpty 
        ? durations.reduce((a, b) => a + b) / durations.length 
        : 0;
    
    final avgDisturbances = disturbanceCounts.isNotEmpty 
        ? disturbanceCounts.reduce((a, b) => a + b) / disturbanceCounts.length 
        : 0.0;
    
    // Calculate component scores (0-100)
    final efficiencyScore = (avgEfficiency * 100).clamp(0, 100);
    final durationScore = _calculateDurationScore(avgDuration);
    final consistencyScore = _calculateConsistencyScore(sessions);
    final disturbanceScore = _calculateDisturbanceScore(avgDisturbances);
    
    // Overall quality score (weighted average)
    final qualityScore = (
      (efficiencyScore * 0.3) + // 30% efficiency
      (durationScore * 0.25) + // 25% duration
      (consistencyScore * 0.25) + // 25% consistency
      (disturbanceScore * 0.2) // 20% disturbances
    ).round();
    
    final grade = _getQualityGrade(qualityScore);
    final recommendation = _getQualityRecommendation(qualityScore, avgEfficiency, avgDuration, consistencyScore);
    
    return {
      'quality_score': qualityScore,
      'sleep_efficiency': double.parse(avgEfficiency.toStringAsFixed(1)),
      'duration_score': durationScore.round(),
      'consistency_score': consistencyScore.round(),
      'disturbance_score': disturbanceScore.round(),
      'average_duration_hours': (avgDuration / 60.0).round() * 100 / 100,
      'average_disturbances': avgDisturbances.round(),
      'recommendation': recommendation,
      'grade': grade,
      'sessions_analyzed': sessions.length,
    };
  }

  int _calculateDurationScore(int avgDurationMinutes) {
    final hours = avgDurationMinutes / 60.0;
    
    // Optimal sleep: 7-9 hours
    if (hours >= 7 && hours <= 9) {
      return 100;
    } else if (hours >= 6 && hours < 7) {
      return 80;
    } else if (hours >= 5 && hours < 6) {
      return 60;
    } else if (hours >= 9 && hours <= 10) {
      return 80;
    } else if (hours > 10) {
      return 60;
    } else {
      return 40;
    }
  }

  int _calculateConsistencyScore(List<SleepSessionEntity> sessions) {
    if (sessions.length < 3) return 50;
    
    final bedtimes = <int>[];
    final waketimes = <int>[];
    
    for (final session in sessions) {
      if (session.bedTime != null) {
        // Convert to minutes from midnight
        bedtimes.add(session.bedTime!.hour * 60 + session.bedTime!.minute);
      }
      if (session.wakeTime != null) {
        waketimes.add(session.wakeTime!.hour * 60 + session.wakeTime!.minute);
      }
    }
    
    final bedtimeVariance = _calculateVariance(bedtimes);
    final waketimeVariance = _calculateVariance(waketimes);
    
    // Lower variance = higher consistency
    final avgVariance = (bedtimeVariance + waketimeVariance) / 2;
    
    // Convert variance to score (lower variance = higher score)
    if (avgVariance < 30) return 100; // Within 30 minutes
    if (avgVariance < 60) return 80;  // Within 1 hour
    if (avgVariance < 120) return 60; // Within 2 hours
    return 40;
  }

  double _calculateVariance(List<int> values) {
    if (values.length < 2) return 0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((value) => (value - mean) * (value - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  int _calculateDisturbanceScore(double avgDisturbances) {
    // Fewer disturbances = higher score
    if (avgDisturbances == 0) return 100;
    if (avgDisturbances <= 1) return 90;
    if (avgDisturbances <= 2) return 70;
    if (avgDisturbances <= 3) return 50;
    return 30;
  }

  String _getQualityGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  String _getQualityRecommendation(int score, double efficiency, int duration, int consistency) {
    if (score >= 85) {
      return 'Excellent sleep quality! Keep up your healthy sleep habits.';
    } else if (efficiency < 0.8) {
      return 'Try to improve sleep efficiency by limiting time in bed when not sleeping.';
    } else if (duration < 6 * 60) {
      return 'Aim for 7-9 hours of sleep per night for optimal health.';
    } else if (consistency < 70) {
      return 'Try to maintain consistent bedtime and wake time, even on weekends.';
    } else {
      return 'Consider optimizing your sleep environment and bedtime routine.';
    }
  }
}

// Get Sleep Trends Use Case
@injectable
class GetSleepTrendsUseCase implements UseCase<Map<String, dynamic>, GetSleepTrendsParams> {
  final SleepRepository repository;

  GetSleepTrendsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetSleepTrendsParams params) async {
    try {
      final sessionsResult = await repository.getUserSleepSessions(
        params.userId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final trends = _analyzeSleepTrends(sessions, params.period);
          return Right(trends);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to analyze sleep trends: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _analyzeSleepTrends(List<SleepSessionEntity> sessions, String period) {
    if (sessions.isEmpty) {
      return {
        'trend': 'no_data',
        'duration_trend': 'stable',
        'quality_trend': 'stable',
        'consistency_trend': 'stable',
        'insights': ['Start tracking sleep to see trends'],
      };
    }
    
    // Sort sessions by date
    sessions.sort((a, b) => a.bedTime?.compareTo(b.bedTime ?? DateTime.now()) ?? 0);
    
    // Split into periods for comparison
    final midPoint = sessions.length ~/ 2;
    final firstHalf = sessions.sublist(0, midPoint);
    final secondHalf = sessions.sublist(midPoint);
    
    if (firstHalf.isEmpty || secondHalf.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'insights': ['Need more sleep data to analyze trends'],
      };
    }
    
    // Calculate averages for each period
    final firstDuration = firstHalf.fold<int>(0, (sum, s) => sum + (s.totalDuration ?? 0)) / firstHalf.length;
    final secondDuration = secondHalf.fold<int>(0, (sum, s) => sum + (s.totalDuration ?? 0)) / secondHalf.length;
    
    final firstQuality = firstHalf.fold<double>(0, (sum, s) => sum + (s.qualityScore ?? 0)) / firstHalf.length;
    final secondQuality = secondHalf.fold<double>(0, (sum, s) => sum + (s.qualityScore ?? 0)) / secondHalf.length;
    
    // Determine trends
    final durationTrend = _getTrendDirection(firstDuration.toDouble(), secondDuration.toDouble(), 30); // 30 min threshold
    final qualityTrend = _getTrendDirection(firstQuality, secondQuality, 10); // 10% threshold
    
    final insights = <String>[];
    
    if (durationTrend == 'improving') {
      insights.add('Your sleep duration has been increasing - great progress!');
    } else if (durationTrend == 'declining') {
      insights.add('Your sleep duration has been decreasing - try to prioritize more sleep time');
    }
    
    if (qualityTrend == 'improving') {
      insights.add('Your sleep quality has been improving - keep up the good habits!');
    } else if (qualityTrend == 'declining') {
      insights.add('Your sleep quality has declined - consider reviewing your sleep environment');
    }
    
    // Analyze day-of-week patterns
    final dayPatterns = _analyzeDayPatterns(sessions);
    if (dayPatterns.isNotEmpty) {
      insights.addAll(dayPatterns);
    }
    
    return {
      'duration_trend': durationTrend,
      'quality_trend': qualityTrend,
      'duration_change': (secondDuration - firstDuration).round(),
      'quality_change': (secondQuality - firstQuality).round(),
      'insights': insights,
      'period_analyzed': period,
      'sessions_count': sessions.length,
    };
  }

  String _getTrendDirection(double first, double second, double threshold) {
    final difference = second - first;
    if (difference > threshold) return 'improving';
    if (difference < -threshold) return 'declining';
    return 'stable';
  }

  List<String> _analyzeDayPatterns(List<SleepSessionEntity> sessions) {
    final insights = <String>[];
    final dayDurations = <int, List<int>>{};
    
    for (final session in sessions) {
      if (session.bedTime != null && session.totalDuration != null) {
        final day = session.bedTime!.weekday;
        dayDurations[day] ??= [];
        dayDurations[day]!.add(session.totalDuration!);
      }
    }
    
    if (dayDurations.length >= 5) {
      final dayAverages = <int, double>{};
      dayDurations.forEach((day, durations) {
        dayAverages[day] = durations.reduce((a, b) => a + b) / durations.length;
      });
      
      final sortedDays = dayAverages.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final bestDay = sortedDays.first;
      final worstDay = sortedDays.last;
      
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      if ((bestDay.value - worstDay.value) > 60) { // More than 1 hour difference
        insights.add('You sleep ${((bestDay.value - worstDay.value) / 60).toStringAsFixed(1)} hours longer on ${dayNames[bestDay.key - 1]} vs ${dayNames[worstDay.key - 1]}');
      }
    }
    
    return insights;
  }
}

class GetSleepTrendsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String period; // 'week', 'month', 'quarter'

  GetSleepTrendsParams({
    required this.userId,
    this.startDate,
    this.endDate,
    this.period = 'month',
  });
}
