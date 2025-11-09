import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/focus_entity.dart';
import '../../data/repositories/focus_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Start Focus Session Use Case
@injectable
class StartFocusSessionUseCase implements UseCase<FocusSessionEntity, StartFocusSessionParams> {
  final FocusRepository repository;

  StartFocusSessionUseCase(this.repository);

  @override
  Future<Either<Failure, FocusSessionEntity>> call(StartFocusSessionParams params) async {
    return await repository.startSession(params.userId, params.sessionData);
  }
}

class StartFocusSessionParams {
  final String userId;
  final Map<String, dynamic> sessionData;

  StartFocusSessionParams({required this.userId, required this.sessionData});
}

// End Focus Session Use Case
@injectable
class EndFocusSessionUseCase implements UseCase<FocusSessionEntity, EndFocusSessionParams> {
  final FocusRepository repository;

  EndFocusSessionUseCase(this.repository);

  @override
  Future<Either<Failure, FocusSessionEntity>> call(EndFocusSessionParams params) async {
    return await repository.endSession(params.sessionId, params.completionData);
  }
}

class EndFocusSessionParams {
  final String sessionId;
  final Map<String, dynamic> completionData;

  EndFocusSessionParams({required this.sessionId, required this.completionData});
}

// Get User Focus Sessions Use Case
@injectable
class GetUserFocusSessionsUseCase implements UseCase<List<FocusSessionEntity>, GetUserFocusSessionsParams> {
  final FocusRepository repository;

  GetUserFocusSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> call(GetUserFocusSessionsParams params) async {
    return await repository.getUserSessions(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserFocusSessionsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserFocusSessionsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Start Pomodoro Use Case
@injectable
class StartPomodoroUseCase implements UseCase<PomodoroTimerEntity, StartPomodoroParams> {
  final FocusRepository repository;

  StartPomodoroUseCase(this.repository);

  @override
  Future<Either<Failure, PomodoroTimerEntity>> call(StartPomodoroParams params) async {
    return await repository.startPomodoro(params.userId, params.pomodoroData);
  }
}

class StartPomodoroParams {
  final String userId;
  final Map<String, dynamic> pomodoroData;

  StartPomodoroParams({required this.userId, required this.pomodoroData});
}

// Update Pomodoro Use Case
@injectable
class UpdatePomodoroUseCase implements UseCase<PomodoroTimerEntity, UpdatePomodoroParams> {
  final FocusRepository repository;

  UpdatePomodoroUseCase(this.repository);

  @override
  Future<Either<Failure, PomodoroTimerEntity>> call(UpdatePomodoroParams params) async {
    return await repository.updatePomodoro(params.timerId, params.updates);
  }
}

class UpdatePomodoroParams {
  final String timerId;
  final Map<String, dynamic> updates;

  UpdatePomodoroParams({required this.timerId, required this.updates});
}

// Pause Focus Session Use Case
@injectable
class PauseFocusSessionUseCase implements UseCase<bool, String> {
  final FocusRepository repository;

  PauseFocusSessionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String sessionId) async {
    return await repository.pauseSession(sessionId);
  }
}

// Resume Focus Session Use Case
@injectable
class ResumeFocusSessionUseCase implements UseCase<bool, String> {
  final FocusRepository repository;

  ResumeFocusSessionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String sessionId) async {
    return await repository.resumeSession(sessionId);
  }
}

// Log Focus Distraction Use Case
@injectable
class LogFocusDistractionUseCase implements UseCase<bool, LogFocusDistractionParams> {
  final FocusRepository repository;

  LogFocusDistractionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(LogFocusDistractionParams params) async {
    return await repository.logDistraction(params.sessionId, params.distractionData);
  }
}

class LogFocusDistractionParams {
  final String sessionId;
  final Map<String, dynamic> distractionData;

  LogFocusDistractionParams({
    required this.sessionId,
    required this.distractionData,
  });
}

// Get Focus Analytics Use Case
@injectable
class GetFocusAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetFocusAnalyticsParams> {
  final FocusRepository repository;

  GetFocusAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetFocusAnalyticsParams params) async {
    return await repository.getAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetFocusAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetFocusAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Personalized Focus Recommendations Use Case
@injectable
class GetPersonalizedFocusRecommendationsUseCase implements UseCase<List<String>, String> {
  final FocusRepository repository;

  GetPersonalizedFocusRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String userId) async {
    return await repository.getPersonalizedRecommendations(userId);
  }
}

// Sync Focus Sessions Use Case
@injectable
class SyncFocusSessionsUseCase implements UseCase<bool, String> {
  final FocusRepository repository;

  SyncFocusSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncSessions(userId);
  }
}

// Calculate Focus Productivity Score Use Case
@injectable
class CalculateFocusProductivityScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final FocusRepository repository;

  CalculateFocusProductivityScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final sessionsResult = await repository.getUserSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final productivityData = _calculateProductivityScore(sessions);
          return Right(productivityData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate productivity score: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateProductivityScore(List<FocusSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return {
        'productivity_score': 0.0,
        'focus_efficiency': 0.0,
        'distraction_rate': 0.0,
        'session_completion_rate': 0.0,
        'average_session_length': 0,
        'total_focus_time': 0,
        'improvement_trend': 'stable',
      };
    }
    
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final totalSessions = sessions.length;
    final completionRate = completedSessions.length / totalSessions;
    
    // Calculate total focus time and distractions
    var totalFocusTime = 0;
    var totalDistractions = 0;
    
    for (final session in completedSessions) {
      totalFocusTime += session.actualDuration ?? 0;
      totalDistractions += session.distractionEvents?.length ?? 0;
    }
    
    final averageSessionLength = completedSessions.isNotEmpty 
        ? totalFocusTime / completedSessions.length 
        : 0;
    
    final distractionRate = totalFocusTime > 0 
        ? totalDistractions / (totalFocusTime / 60) // distractions per minute
        : 0.0;
    
    // Calculate focus efficiency (actual vs planned duration)
    var totalPlannedTime = 0;
    for (final session in completedSessions) {
      totalPlannedTime += session.plannedDuration ?? 0;
    }
    
    final focusEfficiency = totalPlannedTime > 0 
        ? (totalFocusTime / totalPlannedTime) * 100 
        : 0.0;
    
    // Calculate overall productivity score (0-100)
    final productivityScore = (
      (completionRate * 40) + // 40% weight on completion rate
      ((focusEfficiency / 100) * 30) + // 30% weight on efficiency
      ((1 - distractionRate.clamp(0, 1)) * 20) + // 20% weight on low distractions
      (averageSessionLength > 0 ? 10 : 0) // 10% bonus for having sessions
    ).clamp(0, 100);
    
    // Determine improvement trend
    final improvementTrend = _calculateImprovementTrend(sessions);
    
    return {
      'productivity_score': productivityScore.round(),
      'focus_efficiency': focusEfficiency.round(),
      'distraction_rate': distractionRate,
      'session_completion_rate': (completionRate * 100).round(),
      'average_session_length': averageSessionLength.round(),
      'total_focus_time': totalFocusTime,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions.length,
      'improvement_trend': improvementTrend,
      'best_focus_time': _getBestFocusTime(sessions),
      'most_productive_day': _getMostProductiveDay(sessions),
    };
  }

  String _calculateImprovementTrend(List<FocusSessionEntity> sessions) {
    if (sessions.length < 4) return 'insufficient_data';
    
    // Sort sessions by date
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Compare first half with second half
    final midPoint = sessions.length ~/ 2;
    final firstHalf = sessions.sublist(0, midPoint);
    final secondHalf = sessions.sublist(midPoint);
    
    final firstHalfAvgDuration = firstHalf
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + (s.actualDuration ?? 0)) / 
        firstHalf.where((s) => s.isCompleted).length;
    
    final secondHalfAvgDuration = secondHalf
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + (s.actualDuration ?? 0)) / 
        secondHalf.where((s) => s.isCompleted).length;
    
    if (secondHalfAvgDuration > firstHalfAvgDuration * 1.1) {
      return 'improving';
    } else if (secondHalfAvgDuration < firstHalfAvgDuration * 0.9) {
      return 'declining';
    } else {
      return 'stable';
    }
  }

  String _getBestFocusTime(List<FocusSessionEntity> sessions) {
    final hourProductivity = <int, double>{};
    
    for (final session in sessions.where((s) => s.isCompleted)) {
      final hour = session.startTime.hour;
      final duration = session.actualDuration ?? 0;
      hourProductivity[hour] = (hourProductivity[hour] ?? 0) + duration;
    }
    
    if (hourProductivity.isEmpty) return 'No data';
    
    final bestHour = hourProductivity.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return _formatHour(bestHour);
  }

  String _getMostProductiveDay(List<FocusSessionEntity> sessions) {
    final dayProductivity = <int, double>{};
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final session in sessions.where((s) => s.isCompleted)) {
      final day = session.startTime.weekday;
      final duration = session.actualDuration ?? 0;
      dayProductivity[day] = (dayProductivity[day] ?? 0) + duration;
    }
    
    if (dayProductivity.isEmpty) return 'No data';
    
    final bestDay = dayProductivity.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return dayNames[bestDay - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}

// Get Focus Session Insights Use Case
@injectable
class GetFocusSessionInsightsUseCase implements UseCase<Map<String, dynamic>, String> {
  final FocusRepository repository;

  GetFocusSessionInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final sessionsResult = await repository.getUserSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final insights = _generateFocusInsights(sessions);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate focus insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateFocusInsights(List<FocusSessionEntity> sessions) {
    final insights = <String, dynamic>{};
    
    if (sessions.isEmpty) {
      return {
        'message': 'Start some focus sessions to get personalized insights!',
        'suggestions': [
          'Try a 25-minute Pomodoro session',
          'Set a specific goal for your focus time',
          'Choose a quiet environment'
        ],
      };
    }
    
    // Analyze patterns
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final averageDuration = completedSessions.isNotEmpty
        ? completedSessions.fold<int>(0, (sum, s) => sum + (s.actualDuration ?? 0)) / completedSessions.length
        : 0;
    
    // Generate insights based on data
    final insightsList = <String>[];
    final suggestions = <String>[];
    
    if (averageDuration > 0) {
      if (averageDuration < 15) {
        insightsList.add('Your sessions are quite short. Consider gradually increasing duration.');
        suggestions.add('Try extending your next session by 5 minutes');
      } else if (averageDuration > 60) {
        insightsList.add('You have excellent focus stamina with long sessions!');
        suggestions.add('Consider taking short breaks to maintain peak performance');
      } else {
        insightsList.add('Your session length is in the sweet spot for productivity.');
      }
    }
    
    // Analyze completion rate
    final completionRate = sessions.isNotEmpty ? completedSessions.length / sessions.length : 0;
    if (completionRate < 0.7) {
      insightsList.add('You tend to interrupt sessions early. Try shorter, more achievable goals.');
      suggestions.add('Start with 15-minute sessions and build up');
    } else if (completionRate > 0.9) {
      insightsList.add('Excellent session completion rate! You have great focus discipline.');
      suggestions.add('Consider challenging yourself with longer sessions');
    }
    
    // Analyze distractions
    final totalDistractions = sessions.fold<int>(0, (sum, s) => sum + (s.distractionEvents?.length ?? 0));
    if (totalDistractions > sessions.length * 2) {
      insightsList.add('High distraction rate detected. Consider finding a quieter environment.');
      suggestions.add('Try using Do Not Disturb mode');
      suggestions.add('Put your phone in another room');
    }
    
    return {
      'insights': insightsList,
      'suggestions': suggestions,
      'stats': {
        'total_sessions': sessions.length,
        'completed_sessions': completedSessions.length,
        'average_duration': averageDuration.round(),
        'completion_rate': (completionRate * 100).round(),
        'total_distractions': totalDistractions,
      },
    };
  }
}
