import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/focus_entity.dart';
import '../../domain/usecases/focus_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final startFocusSessionUseCaseProvider = Provider<StartFocusSessionUseCase>((ref) => getIt<StartFocusSessionUseCase>());
final endFocusSessionUseCaseProvider = Provider<EndFocusSessionUseCase>((ref) => getIt<EndFocusSessionUseCase>());
final getUserFocusSessionsUseCaseProvider = Provider<GetUserFocusSessionsUseCase>((ref) => getIt<GetUserFocusSessionsUseCase>());
final startPomodoroUseCaseProvider = Provider<StartPomodoroUseCase>((ref) => getIt<StartPomodoroUseCase>());
final updatePomodoroUseCaseProvider = Provider<UpdatePomodoroUseCase>((ref) => getIt<UpdatePomodoroUseCase>());
final pauseFocusSessionUseCaseProvider = Provider<PauseFocusSessionUseCase>((ref) => getIt<PauseFocusSessionUseCase>());
final resumeFocusSessionUseCaseProvider = Provider<ResumeFocusSessionUseCase>((ref) => getIt<ResumeFocusSessionUseCase>());
final logFocusDistractionUseCaseProvider = Provider<LogFocusDistractionUseCase>((ref) => getIt<LogFocusDistractionUseCase>());
final getFocusAnalyticsUseCaseProvider = Provider<GetFocusAnalyticsUseCase>((ref) => getIt<GetFocusAnalyticsUseCase>());
final getPersonalizedFocusRecommendationsUseCaseProvider = Provider<GetPersonalizedFocusRecommendationsUseCase>((ref) => getIt<GetPersonalizedFocusRecommendationsUseCase>());
final syncFocusSessionsUseCaseProvider = Provider<SyncFocusSessionsUseCase>((ref) => getIt<SyncFocusSessionsUseCase>());
final calculateFocusProductivityScoreUseCaseProvider = Provider<CalculateFocusProductivityScoreUseCase>((ref) => getIt<CalculateFocusProductivityScoreUseCase>());
final getFocusSessionInsightsUseCaseProvider = Provider<GetFocusSessionInsightsUseCase>((ref) => getIt<GetFocusSessionInsightsUseCase>());

// State Classes
class FocusState {
  final List<FocusSessionEntity> sessions;
  final FocusSessionEntity? currentSession;
  final PomodoroTimerEntity? currentPomodoro;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? productivityScore;
  final Map<String, dynamic>? insights;
  final List<String> recommendations;
  final bool isLoading;
  final String? error;

  const FocusState({
    this.sessions = const [],
    this.currentSession,
    this.currentPomodoro,
    this.analytics,
    this.productivityScore,
    this.insights,
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  FocusState copyWith({
    List<FocusSessionEntity>? sessions,
    FocusSessionEntity? currentSession,
    PomodoroTimerEntity? currentPomodoro,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? productivityScore,
    Map<String, dynamic>? insights,
    List<String>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return FocusState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      currentPomodoro: currentPomodoro ?? this.currentPomodoro,
      analytics: analytics ?? this.analytics,
      productivityScore: productivityScore ?? this.productivityScore,
      insights: insights ?? this.insights,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isSessionActive => currentSession != null && currentSession!.isActive;
  bool get isPomodoroActive => currentPomodoro != null && currentPomodoro!.isActive;
  int get totalSessions => sessions.length;
  int get totalFocusTime => sessions.fold(0, (sum, session) => sum + (session.actualDuration ?? 0));
}

// Focus State Notifier
class FocusNotifier extends StateNotifier<FocusState> {
  final StartFocusSessionUseCase startSessionUseCase;
  final EndFocusSessionUseCase endSessionUseCase;
  final GetUserFocusSessionsUseCase getUserSessionsUseCase;
  final StartPomodoroUseCase startPomodoroUseCase;
  final UpdatePomodoroUseCase updatePomodoroUseCase;
  final PauseFocusSessionUseCase pauseSessionUseCase;
  final ResumeFocusSessionUseCase resumeSessionUseCase;
  final LogFocusDistractionUseCase logDistractionUseCase;
  final GetFocusAnalyticsUseCase getAnalyticsUseCase;
  final GetPersonalizedFocusRecommendationsUseCase getRecommendationsUseCase;
  final SyncFocusSessionsUseCase syncSessionsUseCase;
  final CalculateFocusProductivityScoreUseCase calculateProductivityScoreUseCase;
  final GetFocusSessionInsightsUseCase getInsightsUseCase;

  FocusNotifier({
    required this.startSessionUseCase,
    required this.endSessionUseCase,
    required this.getUserSessionsUseCase,
    required this.startPomodoroUseCase,
    required this.updatePomodoroUseCase,
    required this.pauseSessionUseCase,
    required this.resumeSessionUseCase,
    required this.logDistractionUseCase,
    required this.getAnalyticsUseCase,
    required this.getRecommendationsUseCase,
    required this.syncSessionsUseCase,
    required this.calculateProductivityScoreUseCase,
    required this.getInsightsUseCase,
  }) : super(const FocusState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserData();
  }

  Future<void> loadUserData() async {
    await loadSessions();
    await loadAnalytics();
    await loadProductivityScore();
    await loadInsights();
    await loadRecommendations();
  }

  Future<void> loadSessions({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserSessionsUseCase(GetUserFocusSessionsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (sessions) => state = state.copyWith(
        isLoading: false,
        sessions: sessions,
        error: null,
      ),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getAnalyticsUseCase(GetFocusAnalyticsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadProductivityScore() async {
    if (_currentUserId == null) return;
    
    final result = await calculateProductivityScoreUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (score) => state = state.copyWith(productivityScore: score),
    );
  }

  Future<void> loadInsights() async {
    if (_currentUserId == null) return;
    
    final result = await getInsightsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (insights) => state = state.copyWith(insights: insights),
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

  Future<bool> startFocusSession(Map<String, dynamic> sessionData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await startSessionUseCase(StartFocusSessionParams(
      userId: _currentUserId!,
      sessionData: sessionData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (session) {
        state = state.copyWith(
          isLoading: false,
          currentSession: session,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> endFocusSession(Map<String, dynamic> completionData) async {
    if (state.currentSession == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await endSessionUseCase(EndFocusSessionParams(
      sessionId: state.currentSession!.id,
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
      (session) {
        state = state.copyWith(
          isLoading: false,
          currentSession: session,
          sessions: [...state.sessions, session],
          error: null,
        );
        // Reload analytics and productivity score
        loadAnalytics();
        loadProductivityScore();
        return true;
      },
    );
  }

  Future<bool> startPomodoro(Map<String, dynamic> pomodoroData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await startPomodoroUseCase(StartPomodoroParams(
      userId: _currentUserId!,
      pomodoroData: pomodoroData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (pomodoro) {
        state = state.copyWith(
          isLoading: false,
          currentPomodoro: pomodoro,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> updatePomodoro(Map<String, dynamic> updates) async {
    if (state.currentPomodoro == null) return false;
    
    final result = await updatePomodoroUseCase(UpdatePomodoroParams(
      timerId: state.currentPomodoro!.id,
      updates: updates,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return false;
      },
      (pomodoro) {
        state = state.copyWith(currentPomodoro: pomodoro);
        return true;
      },
    );
  }

  Future<bool> pauseSession() async {
    if (state.currentSession == null) return false;
    
    final result = await pauseSessionUseCase(state.currentSession!.id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return false;
      },
      (success) {
        if (success && state.currentSession != null) {
          final updatedSession = state.currentSession!.copyWith(
            isPaused: true,
          );
          state = state.copyWith(currentSession: updatedSession);
        }
        return success;
      },
    );
  }

  Future<bool> resumeSession() async {
    if (state.currentSession == null) return false;
    
    final result = await resumeSessionUseCase(state.currentSession!.id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return false;
      },
      (success) {
        if (success && state.currentSession != null) {
          final updatedSession = state.currentSession!.copyWith(
            isPaused: false,
          );
          state = state.copyWith(currentSession: updatedSession);
        }
        return success;
      },
    );
  }

  Future<void> logDistraction(Map<String, dynamic> distractionData) async {
    if (state.currentSession == null) return;
    
    await logDistractionUseCase(LogFocusDistractionParams(
      sessionId: state.currentSession!.id,
      distractionData: distractionData,
    ));
  }

  Future<void> syncSessions() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncSessionsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadSessions();
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Focus Provider
final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier(
    startSessionUseCase: ref.read(startFocusSessionUseCaseProvider),
    endSessionUseCase: ref.read(endFocusSessionUseCaseProvider),
    getUserSessionsUseCase: ref.read(getUserFocusSessionsUseCaseProvider),
    startPomodoroUseCase: ref.read(startPomodoroUseCaseProvider),
    updatePomodoroUseCase: ref.read(updatePomodoroUseCaseProvider),
    pauseSessionUseCase: ref.read(pauseFocusSessionUseCaseProvider),
    resumeSessionUseCase: ref.read(resumeFocusSessionUseCaseProvider),
    logDistractionUseCase: ref.read(logFocusDistractionUseCaseProvider),
    getAnalyticsUseCase: ref.read(getFocusAnalyticsUseCaseProvider),
    getRecommendationsUseCase: ref.read(getPersonalizedFocusRecommendationsUseCaseProvider),
    syncSessionsUseCase: ref.read(syncFocusSessionsUseCaseProvider),
    calculateProductivityScoreUseCase: ref.read(calculateFocusProductivityScoreUseCaseProvider),
    getInsightsUseCase: ref.read(getFocusSessionInsightsUseCaseProvider),
  );
});

// Computed Providers
final focusSessionsByTypeProvider = Provider<Map<String, List<FocusSessionEntity>>>((ref) {
  final focusState = ref.watch(focusProvider);
  final sessionsByType = <String, List<FocusSessionEntity>>{};
  
  for (final session in focusState.sessions) {
    final type = session.sessionType ?? 'general';
    sessionsByType[type] ??= [];
    sessionsByType[type]!.add(session);
  }
  
  return sessionsByType;
});

final completedFocusSessionsProvider = Provider<List<FocusSessionEntity>>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.sessions.where((session) => session.isCompleted).toList();
});

final averageFocusDurationProvider = Provider<double>((ref) {
  final completedSessions = ref.watch(completedFocusSessionsProvider);
  if (completedSessions.isEmpty) return 0.0;
  
  final totalMinutes = completedSessions.fold<int>(0, (sum, session) => sum + (session.actualDuration ?? 0));
  return totalMinutes / completedSessions.length;
});

final focusProductivityScoreProvider = Provider<int>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.productivityScore?['productivity_score'] ?? 0;
});

final focusEfficiencyProvider = Provider<int>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.productivityScore?['focus_efficiency'] ?? 0;
});

final weeklyFocusTimeProvider = Provider<int>((ref) {
  final focusState = ref.watch(focusProvider);
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return focusState.sessions
      .where((session) => session.startTime.isAfter(oneWeekAgo))
      .fold<int>(0, (sum, session) => sum + (session.actualDuration ?? 0));
});

final totalDistractionsProvider = Provider<int>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.sessions.fold<int>(0, (sum, session) => 
      sum + (session.distractionEvents?.length ?? 0));
});

final bestFocusTimeProvider = Provider<String?>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.productivityScore?['best_focus_time'];
});

final mostProductiveDayProvider = Provider<String?>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.productivityScore?['most_productive_day'];
});

final currentSessionDurationProvider = Provider<int?>((ref) {
  final focusState = ref.watch(focusProvider);
  final session = focusState.currentSession;
  
  if (session == null || !session.isActive) return null;
  
  return DateTime.now().difference(session.startTime).inMinutes;
});

final pomodoroProgressProvider = Provider<double>((ref) {
  final focusState = ref.watch(focusProvider);
  final pomodoro = focusState.currentPomodoro;
  
  if (pomodoro == null || !pomodoro.isActive) return 0.0;
  
  final totalDuration = pomodoro.duration;
  final elapsed = DateTime.now().difference(pomodoro.startTime).inSeconds;
  
  if (totalDuration <= 0) return 0.0;
  
  return (elapsed / (totalDuration * 60)).clamp(0.0, 1.0);
});

final pomodoroTimeRemainingProvider = Provider<int>((ref) {
  final focusState = ref.watch(focusProvider);
  final pomodoro = focusState.currentPomodoro;
  
  if (pomodoro == null || !pomodoro.isActive) return 0;
  
  final totalSeconds = pomodoro.duration * 60;
  final elapsed = DateTime.now().difference(pomodoro.startTime).inSeconds;
  
  return (totalSeconds - elapsed).clamp(0, totalSeconds);
});

final improvementTrendProvider = Provider<String>((ref) {
  final focusState = ref.watch(focusProvider);
  return focusState.productivityScore?['improvement_trend'] ?? 'stable';
});

final sessionCompletionRateProvider = Provider<double>((ref) {
  final focusState = ref.watch(focusProvider);
  if (focusState.sessions.isEmpty) return 0.0;
  
  final completedSessions = focusState.sessions.where((s) => s.isCompleted).length;
  return completedSessions / focusState.sessions.length;
});

final averageDistractionsPerSessionProvider = Provider<double>((ref) {
  final focusState = ref.watch(focusProvider);
  if (focusState.sessions.isEmpty) return 0.0;
  
  final totalDistractions = focusState.sessions.fold<int>(0, (sum, session) => 
      sum + (session.distractionEvents?.length ?? 0));
  
  return totalDistractions / focusState.sessions.length;
});
