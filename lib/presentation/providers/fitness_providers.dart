import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fitness_entity.dart';
import '../../domain/usecases/fitness_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final createWorkoutUseCaseProvider = Provider<CreateWorkoutUseCase>((ref) => getIt<CreateWorkoutUseCase>());
final startWorkoutUseCaseProvider = Provider<StartWorkoutUseCase>((ref) => getIt<StartWorkoutUseCase>());
final endWorkoutUseCaseProvider = Provider<EndWorkoutUseCase>((ref) => getIt<EndWorkoutUseCase>());
final getUserWorkoutsUseCaseProvider = Provider<GetUserWorkoutsUseCase>((ref) => getIt<GetUserWorkoutsUseCase>());
final logNutritionUseCaseProvider = Provider<LogNutritionUseCase>((ref) => getIt<LogNutritionUseCase>());
final logBiometricsUseCaseProvider = Provider<LogBiometricsUseCase>((ref) => getIt<LogBiometricsUseCase>());
final getNutritionEntriesUseCaseProvider = Provider<GetNutritionEntriesUseCase>((ref) => getIt<GetNutritionEntriesUseCase>());
final getBiometricDataUseCaseProvider = Provider<GetBiometricDataUseCase>((ref) => getIt<GetBiometricDataUseCase>());
final getFitnessAnalyticsUseCaseProvider = Provider<GetFitnessAnalyticsUseCase>((ref) => getIt<GetFitnessAnalyticsUseCase>());
final generateWorkoutPlanUseCaseProvider = Provider<GenerateWorkoutPlanUseCase>((ref) => getIt<GenerateWorkoutPlanUseCase>());
final syncFitnessDataUseCaseProvider = Provider<SyncFitnessDataUseCase>((ref) => getIt<SyncFitnessDataUseCase>());
final syncWithHealthAppUseCaseProvider = Provider<SyncWithHealthAppUseCase>((ref) => getIt<SyncWithHealthAppUseCase>());
final calculateBMIUseCaseProvider = Provider<CalculateBMIUseCase>((ref) => getIt<CalculateBMIUseCase>());
final getWorkoutRecommendationsUseCaseProvider = Provider<GetWorkoutRecommendationsUseCase>((ref) => getIt<GetWorkoutRecommendationsUseCase>());
final calculateCalorieBurnUseCaseProvider = Provider<CalculateCalorieBurnUseCase>((ref) => getIt<CalculateCalorieBurnUseCase>());

// State Classes
class FitnessState {
  final List<WorkoutEntity> workouts;
  final List<NutritionEntryEntity> nutritionEntries;
  final List<BiometricDataEntity> biometricData;
  final WorkoutEntity? currentWorkout;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? bmiData;
  final List<Map<String, dynamic>> recommendations;
  final Map<String, dynamic>? workoutPlan;
  final bool isLoading;
  final String? error;

  const FitnessState({
    this.workouts = const [],
    this.nutritionEntries = const [],
    this.biometricData = const [],
    this.currentWorkout,
    this.analytics,
    this.bmiData,
    this.recommendations = const [],
    this.workoutPlan,
    this.isLoading = false,
    this.error,
  });

  FitnessState copyWith({
    List<WorkoutEntity>? workouts,
    List<NutritionEntryEntity>? nutritionEntries,
    List<BiometricDataEntity>? biometricData,
    WorkoutEntity? currentWorkout,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? bmiData,
    List<Map<String, dynamic>>? recommendations,
    Map<String, dynamic>? workoutPlan,
    bool? isLoading,
    String? error,
  }) {
    return FitnessState(
      workouts: workouts ?? this.workouts,
      nutritionEntries: nutritionEntries ?? this.nutritionEntries,
      biometricData: biometricData ?? this.biometricData,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      analytics: analytics ?? this.analytics,
      bmiData: bmiData ?? this.bmiData,
      recommendations: recommendations ?? this.recommendations,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isWorkoutActive => currentWorkout != null && currentWorkout!.isActive;
  int get totalWorkouts => workouts.length;
  int get totalCaloriesBurned => workouts.fold(0, (sum, workout) => sum + (workout.caloriesBurned ?? 0));
}

// Fitness State Notifier
class FitnessNotifier extends StateNotifier<FitnessState> {
  final CreateWorkoutUseCase createWorkoutUseCase;
  final StartWorkoutUseCase startWorkoutUseCase;
  final EndWorkoutUseCase endWorkoutUseCase;
  final GetUserWorkoutsUseCase getUserWorkoutsUseCase;
  final LogNutritionUseCase logNutritionUseCase;
  final LogBiometricsUseCase logBiometricsUseCase;
  final GetNutritionEntriesUseCase getNutritionEntriesUseCase;
  final GetBiometricDataUseCase getBiometricDataUseCase;
  final GetFitnessAnalyticsUseCase getAnalyticsUseCase;
  final GenerateWorkoutPlanUseCase generateWorkoutPlanUseCase;
  final SyncFitnessDataUseCase syncFitnessDataUseCase;
  final SyncWithHealthAppUseCase syncWithHealthAppUseCase;
  final CalculateBMIUseCase calculateBMIUseCase;
  final GetWorkoutRecommendationsUseCase getRecommendationsUseCase;
  final CalculateCalorieBurnUseCase calculateCalorieBurnUseCase;

  FitnessNotifier({
    required this.createWorkoutUseCase,
    required this.startWorkoutUseCase,
    required this.endWorkoutUseCase,
    required this.getUserWorkoutsUseCase,
    required this.logNutritionUseCase,
    required this.logBiometricsUseCase,
    required this.getNutritionEntriesUseCase,
    required this.getBiometricDataUseCase,
    required this.getAnalyticsUseCase,
    required this.generateWorkoutPlanUseCase,
    required this.syncFitnessDataUseCase,
    required this.syncWithHealthAppUseCase,
    required this.calculateBMIUseCase,
    required this.getRecommendationsUseCase,
    required this.calculateCalorieBurnUseCase,
  }) : super(const FitnessState());

  String? _currentUserId;
  double? _userHeight; // Store user height for BMI calculations

  void setUserId(String userId, {double? height}) {
    _currentUserId = userId;
    _userHeight = height;
    loadUserData();
  }

  Future<void> loadUserData() async {
    await loadWorkouts();
    await loadNutritionEntries();
    await loadBiometricData();
    await loadAnalytics();
    await loadBMI();
    await loadRecommendations();
  }

  Future<void> loadWorkouts({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserWorkoutsUseCase(GetUserWorkoutsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (workouts) => state = state.copyWith(
        isLoading: false,
        workouts: workouts,
        error: null,
      ),
    );
  }

  Future<void> loadNutritionEntries({DateTime? date}) async {
    if (_currentUserId == null) return;
    
    final result = await getNutritionEntriesUseCase(GetNutritionEntriesParams(
      userId: _currentUserId!,
      date: date,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (entries) => state = state.copyWith(nutritionEntries: entries),
    );
  }

  Future<void> loadBiometricData({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getBiometricDataUseCase(GetBiometricDataParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (data) => state = state.copyWith(biometricData: data),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getAnalyticsUseCase(GetFitnessAnalyticsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadBMI() async {
    if (_currentUserId == null) return;
    
    final result = await calculateBMIUseCase(CalculateBMIParams(
      userId: _currentUserId!,
      height: _userHeight,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (bmiData) => state = state.copyWith(bmiData: bmiData),
    );
  }

  Future<void> loadRecommendations() async {
    if (_currentUserId == null) return;
    
    final result = await getRecommendationsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (recommendations) => state = state.copyWith(recommendations: recommendations),
    );
  }

  Future<bool> createWorkout(Map<String, dynamic> workoutData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createWorkoutUseCase(CreateWorkoutParams(
      userId: _currentUserId!,
      workoutData: workoutData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (workout) {
        state = state.copyWith(
          isLoading: false,
          workouts: [...state.workouts, workout],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> startWorkout(String workoutId) async {
    state = state.copyWith(isLoading: true);
    
    final result = await startWorkoutUseCase(workoutId);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (workout) {
        state = state.copyWith(
          isLoading: false,
          currentWorkout: workout,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> endWorkout(Map<String, dynamic> completionData) async {
    if (state.currentWorkout == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await endWorkoutUseCase(EndWorkoutParams(
      workoutId: state.currentWorkout!.id,
      completionData: completionData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (workout) {
        // Update the workouts list with completed workout
        final updatedWorkouts = state.workouts.map((w) {
          return w.id == workout.id ? workout : w;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          currentWorkout: workout,
          workouts: updatedWorkouts,
          error: null,
        );
        
        // Reload analytics after workout completion
        loadAnalytics();
        loadBMI();
        return true;
      },
    );
  }

  Future<bool> logNutrition(Map<String, dynamic> nutritionData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await logNutritionUseCase(LogNutritionParams(
      userId: _currentUserId!,
      nutritionData: nutritionData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (entry) {
        state = state.copyWith(
          isLoading: false,
          nutritionEntries: [...state.nutritionEntries, entry],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> logBiometrics(Map<String, dynamic> biometricData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await logBiometricsUseCase(LogBiometricsParams(
      userId: _currentUserId!,
      biometricData: biometricData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          biometricData: [...state.biometricData, data],
          error: null,
        );
        // Recalculate BMI with new biometric data
        loadBMI();
        return true;
      },
    );
  }

  Future<void> generateWorkoutPlan(String fitnessGoal) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await generateWorkoutPlanUseCase(GenerateWorkoutPlanParams(
      userId: _currentUserId!,
      fitnessGoal: fitnessGoal,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (plan) => state = state.copyWith(
        isLoading: false,
        workoutPlan: plan,
        error: null,
      ),
    );
  }

  Future<Map<String, dynamic>?> calculateCalorieBurn({
    required String exerciseType,
    required int durationMinutes,
    required String intensity,
  }) async {
    if (_currentUserId == null) return null;
    
    final result = await calculateCalorieBurnUseCase(CalculateCalorieBurnParams(
      userId: _currentUserId!,
      exerciseType: exerciseType,
      durationMinutes: durationMinutes,
      intensity: intensity,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return null;
      },
      (data) => data,
    );
  }

  Future<void> syncFitnessData() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncFitnessDataUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadUserData();
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
          loadUserData();
        }
      },
    );
  }

  void updateUserHeight(double height) {
    _userHeight = height;
    loadBMI(); // Recalculate BMI with new height
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Fitness Provider
final fitnessProvider = StateNotifierProvider<FitnessNotifier, FitnessState>((ref) {
  return FitnessNotifier(
    createWorkoutUseCase: ref.read(createWorkoutUseCaseProvider),
    startWorkoutUseCase: ref.read(startWorkoutUseCaseProvider),
    endWorkoutUseCase: ref.read(endWorkoutUseCaseProvider),
    getUserWorkoutsUseCase: ref.read(getUserWorkoutsUseCaseProvider),
    logNutritionUseCase: ref.read(logNutritionUseCaseProvider),
    logBiometricsUseCase: ref.read(logBiometricsUseCaseProvider),
    getNutritionEntriesUseCase: ref.read(getNutritionEntriesUseCaseProvider),
    getBiometricDataUseCase: ref.read(getBiometricDataUseCaseProvider),
    getAnalyticsUseCase: ref.read(getFitnessAnalyticsUseCaseProvider),
    generateWorkoutPlanUseCase: ref.read(generateWorkoutPlanUseCaseProvider),
    syncFitnessDataUseCase: ref.read(syncFitnessDataUseCaseProvider),
    syncWithHealthAppUseCase: ref.read(syncWithHealthAppUseCaseProvider),
    calculateBMIUseCase: ref.read(calculateBMIUseCaseProvider),
    getRecommendationsUseCase: ref.read(getWorkoutRecommendationsUseCaseProvider),
    calculateCalorieBurnUseCase: ref.read(calculateCalorieBurnUseCaseProvider),
  );
});

// Computed Providers
final workoutsByTypeProvider = Provider<Map<String, List<WorkoutEntity>>>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  final workoutsByType = <String, List<WorkoutEntity>>{};
  
  for (final workout in fitnessState.workouts) {
    final type = workout.type ?? 'general';
    workoutsByType[type] ??= [];
    workoutsByType[type]!.add(workout);
  }
  
  return workoutsByType;
});

final completedWorkoutsProvider = Provider<List<WorkoutEntity>>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  return fitnessState.workouts.where((workout) => workout.isCompleted).toList();
});

final averageWorkoutDurationProvider = Provider<double>((ref) {
  final completedWorkouts = ref.watch(completedWorkoutsProvider);
  if (completedWorkouts.isEmpty) return 0.0;
  
  final totalMinutes = completedWorkouts.fold<int>(0, (sum, workout) => sum + (workout.duration ?? 0));
  return totalMinutes / completedWorkouts.length;
});

final weeklyCaloriesBurnedProvider = Provider<int>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return fitnessState.workouts
      .where((workout) => workout.startTime.isAfter(oneWeekAgo))
      .fold<int>(0, (sum, workout) => sum + (workout.caloriesBurned ?? 0));
});

final currentBMIProvider = Provider<double?>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  return fitnessState.bmiData?['bmi'];
});

final bmiCategoryProvider = Provider<String?>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  return fitnessState.bmiData?['category'];
});

final weightTrendProvider = Provider<String?>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  return fitnessState.bmiData?['trend'];
});

final todaysCaloriesProvider = Provider<int>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  final today = DateTime.now();
  
  return fitnessState.nutritionEntries
      .where((entry) => 
          entry.loggedAt.year == today.year &&
          entry.loggedAt.month == today.month &&
          entry.loggedAt.day == today.day)
      .fold<int>(0, (sum, entry) => sum + (entry.calories ?? 0));
});

final currentWorkoutDurationProvider = Provider<int?>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  final workout = fitnessState.currentWorkout;
  
  if (workout == null || !workout.isActive) return null;
  
  return DateTime.now().difference(workout.startTime).inMinutes;
});

final latestWeightProvider = Provider<double?>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  if (fitnessState.biometricData.isEmpty) return null;
  
  final weightData = fitnessState.biometricData
      .where((data) => data.weight != null)
      .toList()
    ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  
  return weightData.isNotEmpty ? weightData.first.weight : null;
});

final workoutFrequencyProvider = Provider<double>((ref) {
  final fitnessState = ref.watch(fitnessProvider);
  if (fitnessState.workouts.isEmpty) return 0.0;
  
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final recentWorkouts = fitnessState.workouts
      .where((workout) => workout.startTime.isAfter(thirtyDaysAgo))
      .length;
  
  return recentWorkouts / 30.0 * 7; // Workouts per week
});

final fitnessStreakProvider = Provider<int>((ref) {
  final completedWorkouts = ref.watch(completedWorkoutsProvider);
  if (completedWorkouts.isEmpty) return 0;
  
  // Sort workouts by date (most recent first)
  final sortedWorkouts = completedWorkouts.toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));
  
  int streak = 0;
  DateTime currentDate = DateTime.now();
  
  for (final workout in sortedWorkouts) {
    final workoutDate = DateTime(workout.startTime.year, workout.startTime.month, workout.startTime.day);
    final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    if (workoutDate.isAtSameMomentAs(checkDate) || 
        workoutDate.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  
  return streak;
});
