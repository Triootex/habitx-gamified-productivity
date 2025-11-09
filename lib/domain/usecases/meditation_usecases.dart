import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/meditation_entity.dart';
import '../../data/repositories/meditation_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Start Meditation Session Use Case
@injectable
class StartMeditationSessionUseCase implements UseCase<MeditationSessionEntity, StartMeditationSessionParams> {
  final MeditationRepository repository;

  StartMeditationSessionUseCase(this.repository);

  @override
  Future<Either<Failure, MeditationSessionEntity>> call(StartMeditationSessionParams params) async {
    return await repository.startSession(params.userId, params.sessionData);
  }
}

class StartMeditationSessionParams {
  final String userId;
  final Map<String, dynamic> sessionData;

  StartMeditationSessionParams({required this.userId, required this.sessionData});
}

// End Meditation Session Use Case
@injectable
class EndMeditationSessionUseCase implements UseCase<MeditationSessionEntity, EndMeditationSessionParams> {
  final MeditationRepository repository;

  EndMeditationSessionUseCase(this.repository);

  @override
  Future<Either<Failure, MeditationSessionEntity>> call(EndMeditationSessionParams params) async {
    return await repository.endSession(params.sessionId, params.completionData);
  }
}

class EndMeditationSessionParams {
  final String sessionId;
  final Map<String, dynamic> completionData;

  EndMeditationSessionParams({required this.sessionId, required this.completionData});
}

// Get User Meditation Sessions Use Case
@injectable
class GetUserMeditationSessionsUseCase implements UseCase<List<MeditationSessionEntity>, GetUserMeditationSessionsParams> {
  final MeditationRepository repository;

  GetUserMeditationSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MeditationSessionEntity>>> call(GetUserMeditationSessionsParams params) async {
    return await repository.getUserSessions(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserMeditationSessionsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserMeditationSessionsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Meditation Session Use Case
@injectable
class GetMeditationSessionUseCase implements UseCase<MeditationSessionEntity, String> {
  final MeditationRepository repository;

  GetMeditationSessionUseCase(this.repository);

  @override
  Future<Either<Failure, MeditationSessionEntity>> call(String sessionId) async {
    return await repository.getSession(sessionId);
  }
}

// Get Meditation Techniques Use Case
@injectable
class GetMeditationTechniquesUseCase implements UseCase<List<MeditationTechniqueEntity>, GetMeditationTechniquesParams> {
  final MeditationRepository repository;

  GetMeditationTechniquesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MeditationTechniqueEntity>>> call(GetMeditationTechniquesParams params) async {
    return await repository.getTechniques(
      category: params.category,
      difficulty: params.difficulty,
    );
  }
}

class GetMeditationTechniquesParams {
  final String? category;
  final String? difficulty;

  GetMeditationTechniquesParams({this.category, this.difficulty});
}

// Get Meditation Technique Use Case
@injectable
class GetMeditationTechniqueUseCase implements UseCase<MeditationTechniqueEntity, String> {
  final MeditationRepository repository;

  GetMeditationTechniqueUseCase(this.repository);

  @override
  Future<Either<Failure, MeditationTechniqueEntity>> call(String techniqueId) async {
    return await repository.getTechnique(techniqueId);
  }
}

// Get Guided Meditations Use Case
@injectable
class GetGuidedMeditationsUseCase implements UseCase<List<GuidedMeditationEntity>, GetGuidedMeditationsParams> {
  final MeditationRepository repository;

  GetGuidedMeditationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GuidedMeditationEntity>>> call(GetGuidedMeditationsParams params) async {
    return await repository.getGuidedMeditations(
      category: params.category,
      duration: params.duration,
    );
  }
}

class GetGuidedMeditationsParams {
  final String? category;
  final int? duration;

  GetGuidedMeditationsParams({this.category, this.duration});
}

// Get Guided Meditation Use Case
@injectable
class GetGuidedMeditationUseCase implements UseCase<GuidedMeditationEntity, String> {
  final MeditationRepository repository;

  GetGuidedMeditationUseCase(this.repository);

  @override
  Future<Either<Failure, GuidedMeditationEntity>> call(String meditationId) async {
    return await repository.getGuidedMeditation(meditationId);
  }
}

// Get Meditation Analytics Use Case
@injectable
class GetMeditationAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetMeditationAnalyticsParams> {
  final MeditationRepository repository;

  GetMeditationAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMeditationAnalyticsParams params) async {
    return await repository.getAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetMeditationAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetMeditationAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Personalized Meditation Recommendations Use Case
@injectable
class GetPersonalizedMeditationRecommendationsUseCase implements UseCase<List<String>, String> {
  final MeditationRepository repository;

  GetPersonalizedMeditationRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String userId) async {
    return await repository.getPersonalizedRecommendations(userId);
  }
}

// Log Meditation Distraction Use Case
@injectable
class LogMeditationDistractionUseCase implements UseCase<bool, LogMeditationDistractionParams> {
  final MeditationRepository repository;

  LogMeditationDistractionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(LogMeditationDistractionParams params) async {
    return await repository.logDistraction(params.sessionId, params.distractionData);
  }
}

class LogMeditationDistractionParams {
  final String sessionId;
  final Map<String, dynamic> distractionData;

  LogMeditationDistractionParams({
    required this.sessionId,
    required this.distractionData,
  });
}

// Sync Meditation Sessions Use Case
@injectable
class SyncMeditationSessionsUseCase implements UseCase<bool, String> {
  final MeditationRepository repository;

  SyncMeditationSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncSessions(userId);
  }
}

// Calculate Meditation Streaks Use Case
@injectable
class CalculateMeditationStreaksUseCase implements UseCase<Map<String, dynamic>, String> {
  final MeditationRepository repository;

  CalculateMeditationStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final sessionsResult = await repository.getUserSessions(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 365)),
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final streakData = _calculateMeditationStreaks(sessions);
          return Right(streakData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate meditation streaks: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateMeditationStreaks(List<MeditationSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'total_sessions': 0,
        'streak_broken_date': null,
      };
    }
    
    // Sort sessions by date (most recent first)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Group sessions by date
    final sessionsByDate = <String, List<MeditationSessionEntity>>{};
    for (final session in sessions) {
      final dateKey = _formatDateKey(session.startTime);
      sessionsByDate[dateKey] ??= [];
      sessionsByDate[dateKey]!.add(session);
    }
    
    // Calculate current streak
    int currentStreak = 0;
    DateTime currentDate = DateTime.now();
    
    while (true) {
      final dateKey = _formatDateKey(currentDate);
      if (sessionsByDate.containsKey(dateKey)) {
        currentStreak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // Check if it's today and we haven't meditated yet
        if (_formatDateKey(DateTime.now()) == dateKey) {
          currentDate = currentDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    
    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? streakStartDate;
    
    final sortedDates = sessionsByDate.keys.toList()..sort();
    DateTime? previousDate;
    
    for (final dateKey in sortedDates) {
      final date = DateTime.parse(dateKey);
      
      if (previousDate == null || date.difference(previousDate).inDays == 1) {
        tempStreak++;
        streakStartDate ??= date;
      } else {
        longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
        tempStreak = 1;
        streakStartDate = date;
      }
      
      previousDate = date;
    }
    
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': sessions.length,
      'total_minutes': sessions.fold<int>(0, (sum, session) => sum + (session.duration ?? 0)),
      'average_session_length': sessions.isNotEmpty 
          ? sessions.fold<int>(0, (sum, session) => sum + (session.duration ?? 0)) / sessions.length
          : 0,
      'sessions_this_week': _getSessionsThisWeek(sessions),
      'sessions_this_month': _getSessionsThisMonth(sessions),
    };
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _getSessionsThisWeek(List<MeditationSessionEntity> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return sessions.where((session) {
      return session.startTime.isAfter(startOfWeek) && session.startTime.isBefore(now);
    }).length;
  }

  int _getSessionsThisMonth(List<MeditationSessionEntity> sessions) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return sessions.where((session) {
      return session.startTime.isAfter(startOfMonth) && session.startTime.isBefore(now);
    }).length;
  }
}

// Get Meditation Progress Use Case
@injectable
class GetMeditationProgressUseCase implements UseCase<Map<String, dynamic>, GetMeditationProgressParams> {
  final MeditationRepository repository;

  GetMeditationProgressUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMeditationProgressParams params) async {
    try {
      final sessionsResult = await repository.getUserSessions(
        params.userId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      
      return sessionsResult.fold(
        (failure) => Left(failure),
        (sessions) {
          final progress = _calculateProgress(sessions);
          return Right(progress);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate progress: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateProgress(List<MeditationSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return {
        'total_sessions': 0,
        'total_minutes': 0,
        'average_quality': 0.0,
        'improvement_rate': 0.0,
        'consistency_score': 0.0,
      };
    }
    
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + (session.duration ?? 0));
    final averageQuality = sessions.fold<double>(0, (sum, session) => sum + (session.qualityRating ?? 0)) / totalSessions;
    
    // Calculate improvement rate (comparing first half to second half)
    final halfPoint = totalSessions ~/ 2;
    if (halfPoint > 0) {
      final firstHalf = sessions.sublist(0, halfPoint);
      final secondHalf = sessions.sublist(halfPoint);
      
      final firstHalfAvg = firstHalf.fold<double>(0, (sum, session) => sum + (session.qualityRating ?? 0)) / firstHalf.length;
      final secondHalfAvg = secondHalf.fold<double>(0, (sum, session) => sum + (session.qualityRating ?? 0)) / secondHalf.length;
      
      final improvementRate = ((secondHalfAvg - firstHalfAvg) / firstHalfAvg * 100).clamp(-100, 100);
      
      return {
        'total_sessions': totalSessions,
        'total_minutes': totalMinutes,
        'average_quality': averageQuality,
        'improvement_rate': improvementRate,
        'consistency_score': _calculateConsistencyScore(sessions),
        'favorite_techniques': _getFavoriteTechniques(sessions),
      };
    }
    
    return {
      'total_sessions': totalSessions,
      'total_minutes': totalMinutes,
      'average_quality': averageQuality,
      'improvement_rate': 0.0,
      'consistency_score': _calculateConsistencyScore(sessions),
      'favorite_techniques': _getFavoriteTechniques(sessions),
    };
  }

  double _calculateConsistencyScore(List<MeditationSessionEntity> sessions) {
    // Calculate based on regular practice over time
    final sessionsByDate = <String, int>{};
    
    for (final session in sessions) {
      final dateKey = _formatDateKey(session.startTime);
      sessionsByDate[dateKey] = (sessionsByDate[dateKey] ?? 0) + 1;
    }
    
    final totalDays = sessionsByDate.length;
    final daysWithSessions = sessionsByDate.values.where((count) => count > 0).length;
    
    return totalDays > 0 ? (daysWithSessions / totalDays * 100) : 0.0;
  }

  List<String> _getFavoriteTechniques(List<MeditationSessionEntity> sessions) {
    final techniqueCount = <String, int>{};
    
    for (final session in sessions) {
      if (session.technique != null) {
        techniqueCount[session.technique!] = (techniqueCount[session.technique!] ?? 0) + 1;
      }
    }
    
    final sortedTechniques = techniqueCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTechniques.take(3).map((entry) => entry.key).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class GetMeditationProgressParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetMeditationProgressParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}
