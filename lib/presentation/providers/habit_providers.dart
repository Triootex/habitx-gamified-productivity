import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/usecases/habit_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) => getIt<CreateHabitUseCase>());
final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) => getIt<UpdateHabitUseCase>());
final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) => getIt<DeleteHabitUseCase>());
final getHabitUseCaseProvider = Provider<GetHabitUseCase>((ref) => getIt<GetHabitUseCase>());
final getUserHabitsUseCaseProvider = Provider<GetUserHabitsUseCase>((ref) => getIt<GetUserHabitsUseCase>());
final logHabitCompletionUseCaseProvider = Provider<LogHabitCompletionUseCase>((ref) => getIt<LogHabitCompletionUseCase>());
final getHabitLogsUseCaseProvider = Provider<GetHabitLogsUseCase>((ref) => getIt<GetHabitLogsUseCase>());
final getHabitAnalyticsUseCaseProvider = Provider<GetHabitAnalyticsUseCase>((ref) => getIt<GetHabitAnalyticsUseCase>());
final getHabitsDueTodayUseCaseProvider = Provider<GetHabitsDueTodayUseCase>((ref) => getIt<GetHabitsDueTodayUseCase>());
final getStreakAnalyticsUseCaseProvider = Provider<GetStreakAnalyticsUseCase>((ref) => getIt<GetStreakAnalyticsUseCase>());
final syncHabitsUseCaseProvider = Provider<SyncHabitsUseCase>((ref) => getIt<SyncHabitsUseCase>());
final syncWithHealthAppUseCaseProvider = Provider<SyncWithHealthAppUseCase>((ref) => getIt<SyncWithHealthAppUseCase>());
final calculateHabitStreaksUseCaseProvider = Provider<CalculateHabitStreaksUseCase>((ref) => getIt<CalculateHabitStreaksUseCase>());
final getHabitRecommendationsUseCaseProvider = Provider<GetHabitRecommendationsUseCase>((ref) => getIt<GetHabitRecommendationsUseCase>());

// State Classes
class HabitState {
  final List<HabitEntity> habits;
  final List<HabitEntity> todayHabits;
  final Map<String, dynamic>? analytics;
  final Map<String, int> streaks;
  final List<Map<String, dynamic>> recommendations;
  final bool isLoading;
  final String? error;

  const HabitState({
    this.habits = const [],
    this.todayHabits = const [],
    this.analytics,
    this.streaks = const {},
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  HabitState copyWith({
    List<HabitEntity>? habits,
    List<HabitEntity>? todayHabits,
    Map<String, dynamic>? analytics,
    Map<String, int>? streaks,
    List<Map<String, dynamic>>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      todayHabits: todayHabits ?? this.todayHabits,
      analytics: analytics ?? this.analytics,
      streaks: streaks ?? this.streaks,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Habit State Notifier
class HabitNotifier extends StateNotifier<HabitState> {
  final GetUserHabitsUseCase getUserHabitsUseCase;
  final CreateHabitUseCase createHabitUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final LogHabitCompletionUseCase logHabitCompletionUseCase;
  final GetHabitsDueTodayUseCase getHabitsDueTodayUseCase;
  final GetHabitAnalyticsUseCase getHabitAnalyticsUseCase;
  final CalculateHabitStreaksUseCase calculateHabitStreaksUseCase;
  final GetHabitRecommendationsUseCase getHabitRecommendationsUseCase;
  final SyncHabitsUseCase syncHabitsUseCase;
  final SyncWithHealthAppUseCase syncWithHealthAppUseCase;

  HabitNotifier({
    required this.getUserHabitsUseCase,
    required this.createHabitUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.logHabitCompletionUseCase,
    required this.getHabitsDueTodayUseCase,
    required this.getHabitAnalyticsUseCase,
    required this.calculateHabitStreaksUseCase,
    required this.getHabitRecommendationsUseCase,
    required this.syncHabitsUseCase,
    required this.syncWithHealthAppUseCase,
  }) : super(const HabitState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserHabits();
  }

  Future<void> loadUserHabits({String? category, String? status}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserHabitsUseCase(GetUserHabitsParams(
      userId: _currentUserId!,
      category: category,
      status: status,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (habits) => state = state.copyWith(
        isLoading: false,
        habits: habits,
        error: null,
      ),
    );
  }

  Future<void> loadTodayHabits() async {
    if (_currentUserId == null) return;
    
    final result = await getHabitsDueTodayUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (habits) => state = state.copyWith(todayHabits: habits),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getHabitAnalyticsUseCase(HabitAnalyticsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadStreaks() async {
    if (_currentUserId == null) return;
    
    final result = await calculateHabitStreaksUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (streaks) => state = state.copyWith(streaks: streaks),
    );
  }

  Future<void> loadRecommendations() async {
    if (_currentUserId == null) return;
    
    final result = await getHabitRecommendationsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (recommendations) => state = state.copyWith(recommendations: recommendations),
    );
  }

  Future<bool> createHabit(Map<String, dynamic> habitData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createHabitUseCase(CreateHabitParams(
      userId: _currentUserId!,
      habitData: habitData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (habit) {
        state = state.copyWith(
          isLoading: false,
          habits: [...state.habits, habit],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateHabit(String habitId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true);
    
    final result = await updateHabitUseCase(UpdateHabitParams(
      habitId: habitId,
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
      (updatedHabit) {
        final updatedHabits = state.habits.map((habit) {
          return habit.id == habitId ? updatedHabit : habit;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          habits: updatedHabits,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> logCompletion(String habitId, {Map<String, dynamic>? logData}) async {
    state = state.copyWith(isLoading: true);
    
    final result = await logHabitCompletionUseCase(LogHabitCompletionParams(
      habitId: habitId,
      logData: logData ?? {
        'completed_at': DateTime.now().toIso8601String(),
        'notes': '',
      },
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (log) {
        state = state.copyWith(isLoading: false, error: null);
        // Refresh habits and streaks after logging
        loadUserHabits();
        loadStreaks();
        return true;
      },
    );
  }

  Future<bool> deleteHabit(String habitId) async {
    state = state.copyWith(isLoading: true);
    
    final result = await deleteHabitUseCase(habitId);
    
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
          final updatedHabits = state.habits.where((habit) => habit.id != habitId).toList();
          final updatedTodayHabits = state.todayHabits.where((habit) => habit.id != habitId).toList();
          
          state = state.copyWith(
            isLoading: false,
            habits: updatedHabits,
            todayHabits: updatedTodayHabits,
            error: null,
          );
        }
        return success;
      },
    );
  }

  Future<void> syncHabits() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncHabitsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadUserHabits();
          loadTodayHabits();
        }
      },
    );
  }

  Future<void> syncWithHealthApp() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncWithHealthAppUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadUserHabits();
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Habit Provider
final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  return HabitNotifier(
    getUserHabitsUseCase: ref.read(getUserHabitsUseCaseProvider),
    createHabitUseCase: ref.read(createHabitUseCaseProvider),
    updateHabitUseCase: ref.read(updateHabitUseCaseProvider),
    deleteHabitUseCase: ref.read(deleteHabitUseCaseProvider),
    logHabitCompletionUseCase: ref.read(logHabitCompletionUseCaseProvider),
    getHabitsDueTodayUseCase: ref.read(getHabitsDueTodayUseCaseProvider),
    getHabitAnalyticsUseCase: ref.read(getHabitAnalyticsUseCaseProvider),
    calculateHabitStreaksUseCase: ref.read(calculateHabitStreaksUseCaseProvider),
    getHabitRecommendationsUseCase: ref.read(getHabitRecommendationsUseCaseProvider),
    syncHabitsUseCase: ref.read(syncHabitsUseCaseProvider),
    syncWithHealthAppUseCase: ref.read(syncWithHealthAppUseCaseProvider),
  );
});

// Computed Providers
final activeHabitsProvider = Provider<List<HabitEntity>>((ref) {
  final habitState = ref.watch(habitProvider);
  return habitState.habits.where((habit) => habit.isActive).toList();
});

final pausedHabitsProvider = Provider<List<HabitEntity>>((ref) {
  final habitState = ref.watch(habitProvider);
  return habitState.habits.where((habit) => !habit.isActive).toList();
});

final habitCategoriesProvider = Provider<Map<String, int>>((ref) {
  final habitState = ref.watch(habitProvider);
  final categories = <String, int>{};
  
  for (final habit in habitState.habits) {
    categories[habit.category] = (categories[habit.category] ?? 0) + 1;
  }
  
  return categories;
});

final todayCompletedHabitsProvider = Provider<List<HabitEntity>>((ref) {
  final habitState = ref.watch(habitProvider);
  final today = DateTime.now();
  
  return habitState.habits.where((habit) {
    if (habit.lastCompletedAt == null) return false;
    final lastCompleted = habit.lastCompletedAt!;
    return lastCompleted.year == today.year && 
           lastCompleted.month == today.month && 
           lastCompleted.day == today.day;
  }).toList();
});

final habitCompletionRateProvider = Provider<double>((ref) {
  final habitState = ref.watch(habitProvider);
  if (habitState.habits.isEmpty) return 0.0;
  
  final totalRate = habitState.habits.fold<double>(0, (sum, habit) => sum + habit.completionRate);
  return totalRate / habitState.habits.length;
});

final longestStreakProvider = Provider<int>((ref) {
  final habitState = ref.watch(habitProvider);
  if (habitState.streaks.isEmpty) return 0;
  
  return habitState.streaks.values.reduce((a, b) => a > b ? a : b);
});

// Async Providers
final habitByIdProvider = FutureProvider.family<HabitEntity?, String>((ref, habitId) async {
  final getHabitUseCase = ref.read(getHabitUseCaseProvider);
  final result = await getHabitUseCase(habitId);
  
  return result.fold(
    (failure) => null,
    (habit) => habit,
  );
});

final habitLogsProvider = FutureProvider.family<List<HabitLogEntity>, HabitLogsParams>((ref, params) async {
  final getHabitLogsUseCase = ref.read(getHabitLogsUseCaseProvider);
  final result = await getHabitLogsUseCase(GetHabitLogsParams(
    habitId: params.habitId,
    startDate: params.startDate,
    endDate: params.endDate,
  ));
  
  return result.fold(
    (failure) => [],
    (logs) => logs,
  );
});

class HabitLogsParams {
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  HabitLogsParams({
    required this.habitId,
    this.startDate,
    this.endDate,
  });
}
