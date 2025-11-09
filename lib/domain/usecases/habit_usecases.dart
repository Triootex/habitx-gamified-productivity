import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/habit_entity.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Habit Use Case
@injectable
class CreateHabitUseCase implements UseCase<HabitEntity, CreateHabitParams> {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  @override
  Future<Either<Failure, HabitEntity>> call(CreateHabitParams params) async {
    return await repository.createHabit(params.userId, params.habitData);
  }
}

class CreateHabitParams {
  final String userId;
  final Map<String, dynamic> habitData;

  CreateHabitParams({required this.userId, required this.habitData});
}

// Update Habit Use Case
@injectable
class UpdateHabitUseCase implements UseCase<HabitEntity, UpdateHabitParams> {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  @override
  Future<Either<Failure, HabitEntity>> call(UpdateHabitParams params) async {
    return await repository.updateHabit(params.habitId, params.updates);
  }
}

class UpdateHabitParams {
  final String habitId;
  final Map<String, dynamic> updates;

  UpdateHabitParams({required this.habitId, required this.updates});
}

// Delete Habit Use Case
@injectable
class DeleteHabitUseCase implements UseCase<bool, String> {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String habitId) async {
    return await repository.deleteHabit(habitId);
  }
}

// Get Habit Use Case
@injectable
class GetHabitUseCase implements UseCase<HabitEntity, String> {
  final HabitRepository repository;

  GetHabitUseCase(this.repository);

  @override
  Future<Either<Failure, HabitEntity>> call(String habitId) async {
    return await repository.getHabit(habitId);
  }
}

// Get User Habits Use Case
@injectable
class GetUserHabitsUseCase implements UseCase<List<HabitEntity>, GetUserHabitsParams> {
  final HabitRepository repository;

  GetUserHabitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HabitEntity>>> call(GetUserHabitsParams params) async {
    return await repository.getUserHabits(
      params.userId,
      category: params.category,
      status: params.status,
    );
  }
}

class GetUserHabitsParams {
  final String userId;
  final String? category;
  final String? status;

  GetUserHabitsParams({
    required this.userId,
    this.category,
    this.status,
  });
}

// Log Habit Completion Use Case
@injectable
class LogHabitCompletionUseCase implements UseCase<HabitLogEntity, LogHabitCompletionParams> {
  final HabitRepository repository;

  LogHabitCompletionUseCase(this.repository);

  @override
  Future<Either<Failure, HabitLogEntity>> call(LogHabitCompletionParams params) async {
    return await repository.logHabitCompletion(params.habitId, params.logData);
  }
}

class LogHabitCompletionParams {
  final String habitId;
  final Map<String, dynamic> logData;

  LogHabitCompletionParams({required this.habitId, required this.logData});
}

// Get Habit Logs Use Case
@injectable
class GetHabitLogsUseCase implements UseCase<List<HabitLogEntity>, GetHabitLogsParams> {
  final HabitRepository repository;

  GetHabitLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HabitLogEntity>>> call(GetHabitLogsParams params) async {
    return await repository.getHabitLogs(
      params.habitId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetHabitLogsParams {
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetHabitLogsParams({
    required this.habitId,
    this.startDate,
    this.endDate,
  });
}

// Get Habit Analytics Use Case
@injectable
class GetHabitAnalyticsUseCase implements UseCase<Map<String, dynamic>, HabitAnalyticsParams> {
  final HabitRepository repository;

  GetHabitAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(HabitAnalyticsParams params) async {
    return await repository.getHabitAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class HabitAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  HabitAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Habits Due Today Use Case
@injectable
class GetHabitsDueTodayUseCase implements UseCase<List<HabitEntity>, String> {
  final HabitRepository repository;

  GetHabitsDueTodayUseCase(this.repository);

  @override
  Future<Either<Failure, List<HabitEntity>>> call(String userId) async {
    return await repository.getHabitsDueToday(userId);
  }
}

// Get Streak Analytics Use Case
@injectable
class GetStreakAnalyticsUseCase implements UseCase<Map<String, dynamic>, String> {
  final HabitRepository repository;

  GetStreakAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getStreakAnalytics(userId);
  }
}

// Sync Habits Use Case
@injectable
class SyncHabitsUseCase implements UseCase<bool, String> {
  final HabitRepository repository;

  SyncHabitsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncHabits(userId);
  }
}

// Sync with Health App Use Case
@injectable
class SyncWithHealthAppUseCase implements UseCase<bool, String> {
  final HabitRepository repository;

  SyncWithHealthAppUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncWithHealthApp(userId);
  }
}

// Calculate Habit Streaks Use Case
@injectable
class CalculateHabitStreaksUseCase implements UseCase<Map<String, int>, String> {
  final HabitRepository repository;

  CalculateHabitStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(String userId) async {
    try {
      final habitsResult = await repository.getUserHabits(userId);
      
      return habitsResult.fold(
        (failure) => Left(failure),
        (habits) async {
          final streaks = <String, int>{};
          
          for (final habit in habits) {
            final logsResult = await repository.getHabitLogs(
              habit.id,
              DateTime.now().subtract(const Duration(days: 365)),
              DateTime.now(),
            );
            
            logsResult.fold(
              (failure) => streaks[habit.id] = 0,
              (logs) {
                streaks[habit.id] = _calculateCurrentStreak(logs, habit);
              },
            );
          }
          
          return Right(streaks);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate streaks: ${e.toString()}'));
    }
  }

  int _calculateCurrentStreak(List<HabitLogEntity> logs, HabitEntity habit) {
    if (logs.isEmpty) return 0;
    
    // Sort logs by date (most recent first)
    logs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Check if habit was completed today or yesterday (grace period)
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    for (final log in logs) {
      final logDate = DateTime(log.loggedAt.year, log.loggedAt.month, log.loggedAt.day);
      
      if (logDate.isAtSameMomentAs(today) || logDate.isAtSameMomentAs(yesterday)) {
        streak++;
        currentDate = logDate;
        today = today.subtract(const Duration(days: 1));
      } else if (logDate.isBefore(yesterday)) {
        // Check for consecutive days
        final expectedDate = currentDate.subtract(const Duration(days: 1));
        if (logDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          currentDate = logDate;
        } else {
          break; // Streak broken
        }
      }
    }
    
    return streak;
  }
}

// Get Habit Recommendations Use Case
@injectable
class GetHabitRecommendationsUseCase implements UseCase<List<Map<String, dynamic>>, String> {
  final HabitRepository repository;

  GetHabitRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String userId) async {
    try {
      final habitsResult = await repository.getUserHabits(userId);
      
      return habitsResult.fold(
        (failure) => Left(failure),
        (habits) {
          final recommendations = _generateHabitRecommendations(habits);
          return Right(recommendations);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate recommendations: ${e.toString()}'));
    }
  }

  List<Map<String, dynamic>> _generateHabitRecommendations(List<HabitEntity> habits) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Analyze habit categories
    final categoryCount = <String, int>{};
    for (final habit in habits) {
      categoryCount[habit.category] = (categoryCount[habit.category] ?? 0) + 1;
    }
    
    // Recommend missing essential categories
    final essentialCategories = ['health', 'productivity', 'mindfulness', 'learning'];
    for (final category in essentialCategories) {
      if (!categoryCount.containsKey(category)) {
        recommendations.add({
          'type': 'missing_category',
          'category': category,
          'suggestion': 'Consider adding a $category habit',
          'priority': 'high',
        });
      }
    }
    
    // Recommend habit improvements based on completion rates
    for (final habit in habits) {
      if (habit.completionRate < 0.5) {
        recommendations.add({
          'type': 'improvement',
          'habit_id': habit.id,
          'habit_name': habit.name,
          'suggestion': 'Consider reducing the target or frequency for better consistency',
          'current_rate': habit.completionRate,
          'priority': 'medium',
        });
      }
    }
    
    // Recommend habit stacking opportunities
    final morningHabits = habits.where((h) => h.reminderTime != null && h.reminderTime!.hour < 10).toList();
    if (morningHabits.length == 1) {
      recommendations.add({
        'type': 'habit_stacking',
        'suggestion': 'Stack another habit with your morning routine for better consistency',
        'anchor_habit': morningHabits.first.name,
        'priority': 'low',
      });
    }
    
    return recommendations;
  }
}

// Bulk Habit Operations Use Case
@injectable
class BulkHabitOperationsUseCase implements UseCase<bool, BulkHabitOperationsParams> {
  final HabitRepository repository;

  BulkHabitOperationsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(BulkHabitOperationsParams params) async {
    try {
      for (final habitId in params.habitIds) {
        switch (params.operation) {
          case 'complete':
            await repository.logHabitCompletion(habitId, params.operationData ?? {});
            break;
          case 'pause':
            await repository.updateHabit(habitId, {'is_paused': true});
            break;
          case 'resume':
            await repository.updateHabit(habitId, {'is_paused': false});
            break;
          case 'delete':
            await repository.deleteHabit(habitId);
            break;
        }
      }
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure('Bulk habit operation failed: ${e.toString()}'));
    }
  }
}

class BulkHabitOperationsParams {
  final List<String> habitIds;
  final String operation; // 'complete', 'pause', 'resume', 'delete'
  final Map<String, dynamic>? operationData;

  BulkHabitOperationsParams({
    required this.habitIds,
    required this.operation,
    this.operationData,
  });
}
