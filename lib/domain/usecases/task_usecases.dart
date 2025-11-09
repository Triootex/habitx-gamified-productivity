import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/task_entity.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Task Use Case
@injectable
class CreateTaskUseCase implements UseCase<TaskEntity, CreateTaskParams> {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) async {
    return await repository.createTask(params.userId, params.taskData);
  }
}

class CreateTaskParams {
  final String userId;
  final Map<String, dynamic> taskData;

  CreateTaskParams({required this.userId, required this.taskData});
}

// Update Task Use Case
@injectable
class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.taskId, params.updates);
  }
}

class UpdateTaskParams {
  final String taskId;
  final Map<String, dynamic> updates;

  UpdateTaskParams({required this.taskId, required this.updates});
}

// Delete Task Use Case
@injectable
class DeleteTaskUseCase implements UseCase<bool, String> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String taskId) async {
    return await repository.deleteTask(taskId);
  }
}

// Get Task Use Case
@injectable
class GetTaskUseCase implements UseCase<TaskEntity, String> {
  final TaskRepository repository;

  GetTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(String taskId) async {
    return await repository.getTask(taskId);
  }
}

// Get User Tasks Use Case
@injectable
class GetUserTasksUseCase implements UseCase<List<TaskEntity>, GetUserTasksParams> {
  final TaskRepository repository;

  GetUserTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(GetUserTasksParams params) async {
    return await repository.getUserTasks(
      params.userId,
      status: params.status,
      category: params.category,
    );
  }
}

class GetUserTasksParams {
  final String userId;
  final String? status;
  final String? category;

  GetUserTasksParams({
    required this.userId,
    this.status,
    this.category,
  });
}

// Complete Task Use Case
@injectable
class CompleteTaskUseCase implements UseCase<TaskEntity, CompleteTaskParams> {
  final TaskRepository repository;

  CompleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CompleteTaskParams params) async {
    return await repository.completeTask(params.taskId, params.completionData);
  }
}

class CompleteTaskParams {
  final String taskId;
  final Map<String, dynamic> completionData;

  CompleteTaskParams({required this.taskId, required this.completionData});
}

// Get Tasks by Project Use Case
@injectable
class GetTasksByProjectUseCase implements UseCase<List<TaskEntity>, String> {
  final TaskRepository repository;

  GetTasksByProjectUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(String projectId) async {
    return await repository.getTasksByProject(projectId);
  }
}

// Get Overdue Tasks Use Case
@injectable
class GetOverdueTasksUseCase implements UseCase<List<TaskEntity>, String> {
  final TaskRepository repository;

  GetOverdueTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(String userId) async {
    return await repository.getOverdueTasks(userId);
  }
}

// Get Tasks Due Today Use Case
@injectable
class GetTasksDueTodayUseCase implements UseCase<List<TaskEntity>, String> {
  final TaskRepository repository;

  GetTasksDueTodayUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(String userId) async {
    return await repository.getTasksDueToday(userId);
  }
}

// Get Task Analytics Use Case
@injectable
class GetTaskAnalyticsUseCase implements UseCase<Map<String, dynamic>, TaskAnalyticsParams> {
  final TaskRepository repository;

  GetTaskAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(TaskAnalyticsParams params) async {
    return await repository.getTaskAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class TaskAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  TaskAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Search Tasks Use Case
@injectable
class SearchTasksUseCase implements UseCase<List<TaskEntity>, SearchTasksParams> {
  final TaskRepository repository;

  SearchTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(SearchTasksParams params) async {
    return await repository.searchTasks(
      params.userId,
      params.query,
      params.filters,
    );
  }
}

class SearchTasksParams {
  final String userId;
  final String query;
  final Map<String, dynamic> filters;

  SearchTasksParams({
    required this.userId,
    required this.query,
    required this.filters,
  });
}

// Sync Tasks Use Case
@injectable
class SyncTasksUseCase implements UseCase<bool, String> {
  final TaskRepository repository;

  SyncTasksUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncTasks(userId);
  }
}

// Bulk Task Operations Use Case
@injectable
class BulkTaskOperationsUseCase implements UseCase<bool, BulkTaskOperationsParams> {
  final TaskRepository repository;

  BulkTaskOperationsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(BulkTaskOperationsParams params) async {
    try {
      for (final taskId in params.taskIds) {
        switch (params.operation) {
          case 'complete':
            await repository.completeTask(taskId, params.operationData ?? {});
            break;
          case 'delete':
            await repository.deleteTask(taskId);
            break;
          case 'update':
            await repository.updateTask(taskId, params.operationData ?? {});
            break;
        }
      }
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure('Bulk operation failed: ${e.toString()}'));
    }
  }
}

class BulkTaskOperationsParams {
  final List<String> taskIds;
  final String operation; // 'complete', 'delete', 'update'
  final Map<String, dynamic>? operationData;

  BulkTaskOperationsParams({
    required this.taskIds,
    required this.operation,
    this.operationData,
  });
}

// Get Task Suggestions Use Case
@injectable
class GetTaskSuggestionsUseCase implements UseCase<List<Map<String, dynamic>>, String> {
  final TaskRepository repository;

  GetTaskSuggestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String userId) async {
    try {
      // Get user's task history and patterns
      final tasksResult = await repository.getUserTasks(userId);
      
      return tasksResult.fold(
        (failure) => Left(failure),
        (tasks) {
          // Analyze patterns and generate suggestions
          final suggestions = _generateTaskSuggestions(tasks);
          return Right(suggestions);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate task suggestions: ${e.toString()}'));
    }
  }

  List<Map<String, dynamic>> _generateTaskSuggestions(List<TaskEntity> tasks) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Analyze common patterns
    final categoryFrequency = <String, int>{};
    final timePatterns = <int, int>{};
    
    for (final task in tasks) {
      // Category frequency
      categoryFrequency[task.category] = (categoryFrequency[task.category] ?? 0) + 1;
      
      // Time patterns
      if (task.completedAt != null) {
        final hour = task.completedAt!.hour;
        timePatterns[hour] = (timePatterns[hour] ?? 0) + 1;
      }
    }
    
    // Generate suggestions based on patterns
    final topCategories = categoryFrequency.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    final productiveHours = timePatterns.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    // Add category-based suggestions
    for (final category in topCategories.take(3)) {
      suggestions.add({
        'type': 'category_based',
        'category': category.key,
        'suggestion': 'Consider adding more ${category.key} tasks',
        'confidence': (category.value / tasks.length * 100).round(),
      });
    }
    
    // Add time-based suggestions
    if (productiveHours.isNotEmpty) {
      final bestHour = productiveHours.first.key;
      suggestions.add({
        'type': 'time_based',
        'suggestion': 'You\'re most productive around ${_formatHour(bestHour)}',
        'recommended_time': bestHour,
        'confidence': 85,
      });
    }
    
    return suggestions;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}
