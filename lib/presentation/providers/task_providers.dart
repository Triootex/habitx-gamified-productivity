import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) => getIt<CreateTaskUseCase>());
final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) => getIt<UpdateTaskUseCase>());
final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) => getIt<DeleteTaskUseCase>());
final getTaskUseCaseProvider = Provider<GetTaskUseCase>((ref) => getIt<GetTaskUseCase>());
final getUserTasksUseCaseProvider = Provider<GetUserTasksUseCase>((ref) => getIt<GetUserTasksUseCase>());
final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) => getIt<CompleteTaskUseCase>());
final getTasksByProjectUseCaseProvider = Provider<GetTasksByProjectUseCase>((ref) => getIt<GetTasksByProjectUseCase>());
final getOverdueTasksUseCaseProvider = Provider<GetOverdueTasksUseCase>((ref) => getIt<GetOverdueTasksUseCase>());
final getTasksDueTodayUseCaseProvider = Provider<GetTasksDueTodayUseCase>((ref) => getIt<GetTasksDueTodayUseCase>());
final getTaskAnalyticsUseCaseProvider = Provider<GetTaskAnalyticsUseCase>((ref) => getIt<GetTaskAnalyticsUseCase>());
final searchTasksUseCaseProvider = Provider<SearchTasksUseCase>((ref) => getIt<SearchTasksUseCase>());
final syncTasksUseCaseProvider = Provider<SyncTasksUseCase>((ref) => getIt<SyncTasksUseCase>());
final bulkTaskOperationsUseCaseProvider = Provider<BulkTaskOperationsUseCase>((ref) => getIt<BulkTaskOperationsUseCase>());
final getTaskSuggestionsUseCaseProvider = Provider<GetTaskSuggestionsUseCase>((ref) => getIt<GetTaskSuggestionsUseCase>());

// State Providers
class TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> overdueTasks;
  final List<TaskEntity> todayTasks;
  final Map<String, dynamic>? analytics;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> suggestions;

  const TaskState({
    this.tasks = const [],
    this.overdueTasks = const [],
    this.todayTasks = const [],
    this.analytics,
    this.isLoading = false,
    this.error,
    this.suggestions = const [],
  });

  TaskState copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? overdueTasks,
    List<TaskEntity>? todayTasks,
    Map<String, dynamic>? analytics,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? suggestions,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      todayTasks: todayTasks ?? this.todayTasks,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

// Task State Notifier
class TaskNotifier extends StateNotifier<TaskState> {
  final GetUserTasksUseCase getUserTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final CompleteTaskUseCase completeTaskUseCase;
  final GetOverdueTasksUseCase getOverdueTasksUseCase;
  final GetTasksDueTodayUseCase getTasksDueTodayUseCase;
  final GetTaskAnalyticsUseCase getTaskAnalyticsUseCase;
  final SearchTasksUseCase searchTasksUseCase;
  final SyncTasksUseCase syncTasksUseCase;
  final BulkTaskOperationsUseCase bulkTaskOperationsUseCase;
  final GetTaskSuggestionsUseCase getTaskSuggestionsUseCase;

  TaskNotifier({
    required this.getUserTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.completeTaskUseCase,
    required this.getOverdueTasksUseCase,
    required this.getTasksDueTodayUseCase,
    required this.getTaskAnalyticsUseCase,
    required this.searchTasksUseCase,
    required this.syncTasksUseCase,
    required this.bulkTaskOperationsUseCase,
    required this.getTaskSuggestionsUseCase,
  }) : super(const TaskState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserTasks();
  }

  Future<void> loadUserTasks({String? status, String? category}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserTasksUseCase(GetUserTasksParams(
      userId: _currentUserId!,
      status: status,
      category: category,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (tasks) => state = state.copyWith(
        isLoading: false,
        tasks: tasks,
        error: null,
      ),
    );
  }

  Future<void> loadOverdueTasks() async {
    if (_currentUserId == null) return;
    
    final result = await getOverdueTasksUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (tasks) => state = state.copyWith(overdueTasks: tasks),
    );
  }

  Future<void> loadTodayTasks() async {
    if (_currentUserId == null) return;
    
    final result = await getTasksDueTodayUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (tasks) => state = state.copyWith(todayTasks: tasks),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getTaskAnalyticsUseCase(TaskAnalyticsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadSuggestions() async {
    if (_currentUserId == null) return;
    
    final result = await getTaskSuggestionsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (suggestions) => state = state.copyWith(suggestions: suggestions),
    );
  }

  Future<bool> createTask(Map<String, dynamic> taskData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createTaskUseCase(CreateTaskParams(
      userId: _currentUserId!,
      taskData: taskData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (task) {
        state = state.copyWith(
          isLoading: false,
          tasks: [...state.tasks, task],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateTask(String taskId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true);
    
    final result = await updateTaskUseCase(UpdateTaskParams(
      taskId: taskId,
      updates: updates,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (updatedTask) {
        final updatedTasks = state.tasks.map((task) {
          return task.id == taskId ? updatedTask : task;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          tasks: updatedTasks,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> completeTask(String taskId, {Map<String, dynamic>? completionData}) async {
    state = state.copyWith(isLoading: true);
    
    final result = await completeTaskUseCase(CompleteTaskParams(
      taskId: taskId,
      completionData: completionData ?? {},
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (completedTask) {
        final updatedTasks = state.tasks.map((task) {
          return task.id == taskId ? completedTask : task;
        }).toList();
        
        // Remove from today and overdue lists if completed
        final updatedTodayTasks = state.todayTasks.where((task) => task.id != taskId).toList();
        final updatedOverdueTasks = state.overdueTasks.where((task) => task.id != taskId).toList();
        
        state = state.copyWith(
          isLoading: false,
          tasks: updatedTasks,
          todayTasks: updatedTodayTasks,
          overdueTasks: updatedOverdueTasks,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> deleteTask(String taskId) async {
    state = state.copyWith(isLoading: true);
    
    final result = await deleteTaskUseCase(taskId);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        if (success) {
          final updatedTasks = state.tasks.where((task) => task.id != taskId).toList();
          final updatedTodayTasks = state.todayTasks.where((task) => task.id != taskId).toList();
          final updatedOverdueTasks = state.overdueTasks.where((task) => task.id != taskId).toList();
          
          state = state.copyWith(
            isLoading: false,
            tasks: updatedTasks,
            todayTasks: updatedTodayTasks,
            overdueTasks: updatedOverdueTasks,
            error: null,
          );
        }
        return success;
      },
    );
  }

  Future<List<TaskEntity>> searchTasks(String query, Map<String, dynamic> filters) async {
    if (_currentUserId == null) return [];
    
    final result = await searchTasksUseCase(SearchTasksParams(
      userId: _currentUserId!,
      query: query,
      filters: filters,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return [];
      },
      (tasks) => tasks,
    );
  }

  Future<bool> bulkOperations(List<String> taskIds, String operation, {Map<String, dynamic>? operationData}) async {
    state = state.copyWith(isLoading: true);
    
    final result = await bulkTaskOperationsUseCase(BulkTaskOperationsParams(
      taskIds: taskIds,
      operation: operation,
      operationData: operationData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        // Reload tasks after bulk operation
        loadUserTasks();
        return success;
      },
    );
  }

  Future<void> syncTasks() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncTasksUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          // Reload data after sync
          loadUserTasks();
          loadOverdueTasks();
          loadTodayTasks();
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Task Provider
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    getUserTasksUseCase: ref.read(getUserTasksUseCaseProvider),
    createTaskUseCase: ref.read(createTaskUseCaseProvider),
    updateTaskUseCase: ref.read(updateTaskUseCaseProvider),
    deleteTaskUseCase: ref.read(deleteTaskUseCaseProvider),
    completeTaskUseCase: ref.read(completeTaskUseCaseProvider),
    getOverdueTasksUseCase: ref.read(getOverdueTasksUseCaseProvider),
    getTasksDueTodayUseCase: ref.read(getTasksDueTodayUseCaseProvider),
    getTaskAnalyticsUseCase: ref.read(getTaskAnalyticsUseCaseProvider),
    searchTasksUseCase: ref.read(searchTasksUseCaseProvider),
    syncTasksUseCase: ref.read(syncTasksUseCaseProvider),
    bulkTaskOperationsUseCase: ref.read(bulkTaskOperationsUseCaseProvider),
    getTaskSuggestionsUseCase: ref.read(getTaskSuggestionsUseCaseProvider),
  );
});

// Computed Providers
final completedTasksProvider = Provider<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskProvider);
  return taskState.tasks.where((task) => task.isCompleted).toList();
});

final pendingTasksProvider = Provider<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskProvider);
  return taskState.tasks.where((task) => !task.isCompleted).toList();
});

final highPriorityTasksProvider = Provider<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskProvider);
  return taskState.tasks.where((task) => task.priority == 'high').toList();
});

final taskCompletionRateProvider = Provider<double>((ref) {
  final taskState = ref.watch(taskProvider);
  if (taskState.tasks.isEmpty) return 0.0;
  
  final completedCount = taskState.tasks.where((task) => task.isCompleted).length;
  return completedCount / taskState.tasks.length;
});

final taskCategoriesProvider = Provider<Map<String, int>>((ref) {
  final taskState = ref.watch(taskProvider);
  final categories = <String, int>{};
  
  for (final task in taskState.tasks) {
    categories[task.category] = (categories[task.category] ?? 0) + 1;
  }
  
  return categories;
});

// Async Providers for single operations
final taskByIdProvider = FutureProvider.family<TaskEntity?, String>((ref, taskId) async {
  final getTaskUseCase = ref.read(getTaskUseCaseProvider);
  final result = await getTaskUseCase(taskId);
  
  return result.fold(
    (failure) => null,
    (task) => task,
  );
});

final tasksByProjectProvider = FutureProvider.family<List<TaskEntity>, String>((ref, projectId) async {
  final getTasksByProjectUseCase = ref.read(getTasksByProjectUseCaseProvider);
  final result = await getTasksByProjectUseCase(projectId);
  
  return result.fold(
    (failure) => [],
    (tasks) => tasks,
  );
});
