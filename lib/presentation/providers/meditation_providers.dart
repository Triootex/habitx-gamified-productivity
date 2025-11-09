import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../domain/usecases/meditation_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final startMeditationSessionUseCaseProvider = Provider<StartMeditationSessionUseCase>((ref) => getIt<StartMeditationSessionUseCase>());
final endMeditationSessionUseCaseProvider = Provider<EndMeditationSessionUseCase>((ref) => getIt<EndMeditationSessionUseCase>());
final getUserMeditationSessionsUseCaseProvider = Provider<GetUserMeditationSessionsUseCase>((ref) => getIt<GetUserMeditationSessionsUseCase>());
final getMeditationSessionUseCaseProvider = Provider<GetMeditationSessionUseCase>((ref) => getIt<GetMeditationSessionUseCase>());
final getMeditationTechniquesUseCaseProvider = Provider<GetMeditationTechniquesUseCase>((ref) => getIt<GetMeditationTechniquesUseCase>());
final getMeditationTechniqueUseCaseProvider = Provider<GetMeditationTechniqueUseCase>((ref) => getIt<GetMeditationTechniqueUseCase>());
final getGuidedMeditationsUseCaseProvider = Provider<GetGuidedMeditationsUseCase>((ref) => getIt<GetGuidedMeditationsUseCase>());
final getGuidedMeditationUseCaseProvider = Provider<GetGuidedMeditationUseCase>((ref) => getIt<GetGuidedMeditationUseCase>());
final getMeditationAnalyticsUseCaseProvider = Provider<GetMeditationAnalyticsUseCase>((ref) => getIt<GetMeditationAnalyticsUseCase>());
final getPersonalizedMeditationRecommendationsUseCaseProvider = Provider<GetPersonalizedMeditationRecommendationsUseCase>((ref) => getIt<GetPersonalizedMeditationRecommendationsUseCase>());
final logMeditationDistractionUseCaseProvider = Provider<LogMeditationDistractionUseCase>((ref) => getIt<LogMeditationDistractionUseCase>());
final syncMeditationSessionsUseCaseProvider = Provider<SyncMeditationSessionsUseCase>((ref) => getIt<SyncMeditationSessionsUseCase>());
final calculateMeditationStreaksUseCaseProvider = Provider<CalculateMeditationStreaksUseCase>((ref) => getIt<CalculateMeditationStreaksUseCase>());
final getMeditationProgressUseCaseProvider = Provider<GetMeditationProgressUseCase>((ref) => getIt<GetMeditationProgressUseCase>());

// State Classes
class MeditationState {
  final List<MeditationSessionEntity> sessions;
  final List<MeditationTechniqueEntity> techniques;
  final List<GuidedMeditationEntity> guidedMeditations;
  final MeditationSessionEntity? currentSession;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? streakData;
  final List<String> recommendations;
  final bool isLoading;
  final String? error;

  const MeditationState({
    this.sessions = const [],
    this.techniques = const [],
    this.guidedMeditations = const [],
    this.currentSession,
    this.analytics,
    this.streakData,
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  MeditationState copyWith({
    List<MeditationSessionEntity>? sessions,
    List<MeditationTechniqueEntity>? techniques,
    List<GuidedMeditationEntity>? guidedMeditations,
    MeditationSessionEntity? currentSession,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? streakData,
    List<String>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return MeditationState(
      sessions: sessions ?? this.sessions,
      techniques: techniques ?? this.techniques,
      guidedMeditations: guidedMeditations ?? this.guidedMeditations,
      currentSession: currentSession ?? this.currentSession,
      analytics: analytics ?? this.analytics,
      streakData: streakData ?? this.streakData,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isSessionActive => currentSession != null && currentSession!.isActive;
  int get totalSessions => sessions.length;
  int get totalMinutes => sessions.fold(0, (sum, session) => sum + (session.duration ?? 0));
}

// Meditation State Notifier
class MeditationNotifier extends StateNotifier<MeditationState> {
  final StartMeditationSessionUseCase startSessionUseCase;
  final EndMeditationSessionUseCase endSessionUseCase;
  final GetUserMeditationSessionsUseCase getUserSessionsUseCase;
  final GetMeditationTechniquesUseCase getTechniquesUseCase;
  final GetGuidedMeditationsUseCase getGuidedMeditationsUseCase;
  final GetMeditationAnalyticsUseCase getAnalyticsUseCase;
  final GetPersonalizedMeditationRecommendationsUseCase getRecommendationsUseCase;
  final LogMeditationDistractionUseCase logDistractionUseCase;
  final SyncMeditationSessionsUseCase syncSessionsUseCase;
  final CalculateMeditationStreaksUseCase calculateStreaksUseCase;
  final GetMeditationProgressUseCase getProgressUseCase;

  MeditationNotifier({
    required this.startSessionUseCase,
    required this.endSessionUseCase,
    required this.getUserSessionsUseCase,
    required this.getTechniquesUseCase,
    required this.getGuidedMeditationsUseCase,
    required this.getAnalyticsUseCase,
    required this.getRecommendationsUseCase,
    required this.logDistractionUseCase,
    required this.syncSessionsUseCase,
    required this.calculateStreaksUseCase,
    required this.getProgressUseCase,
  }) : super(const MeditationState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserData();
  }

  Future<void> loadUserData() async {
    await loadSessions();
    await loadTechniques();
    await loadGuidedMeditations();
    await loadAnalytics();
    await loadStreaks();
    await loadRecommendations();
  }

  Future<void> loadSessions({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserSessionsUseCase(GetUserMeditationSessionsParams(
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

  Future<void> loadTechniques({String? category, String? difficulty}) async {
    final result = await getTechniquesUseCase(GetMeditationTechniquesParams(
      category: category,
      difficulty: difficulty,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (techniques) => state = state.copyWith(techniques: techniques),
    );
  }

  Future<void> loadGuidedMeditations({String? category, int? duration}) async {
    final result = await getGuidedMeditationsUseCase(GetGuidedMeditationsParams(
      category: category,
      duration: duration,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (meditations) => state = state.copyWith(guidedMeditations: meditations),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getAnalyticsUseCase(GetMeditationAnalyticsParams(
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
    
    final result = await calculateStreaksUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (streaks) => state = state.copyWith(streakData: streaks),
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

  Future<bool> startSession(Map<String, dynamic> sessionData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await startSessionUseCase(StartMeditationSessionParams(
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

  Future<bool> endSession(Map<String, dynamic> completionData) async {
    if (state.currentSession == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await endSessionUseCase(EndMeditationSessionParams(
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
        // Reload analytics and streaks after session completion
        loadAnalytics();
        loadStreaks();
        return true;
      },
    );
  }

  Future<void> logDistraction(Map<String, dynamic> distractionData) async {
    if (state.currentSession == null) return;
    
    await logDistractionUseCase(LogMeditationDistractionParams(
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

// Meditation Provider
final meditationProvider = StateNotifierProvider<MeditationNotifier, MeditationState>((ref) {
  return MeditationNotifier(
    startSessionUseCase: ref.read(startMeditationSessionUseCaseProvider),
    endSessionUseCase: ref.read(endMeditationSessionUseCaseProvider),
    getUserSessionsUseCase: ref.read(getUserMeditationSessionsUseCaseProvider),
    getTechniquesUseCase: ref.read(getMeditationTechniquesUseCaseProvider),
    getGuidedMeditationsUseCase: ref.read(getGuidedMeditationsUseCaseProvider),
    getAnalyticsUseCase: ref.read(getMeditationAnalyticsUseCaseProvider),
    getRecommendationsUseCase: ref.read(getPersonalizedMeditationRecommendationsUseCaseProvider),
    logDistractionUseCase: ref.read(logMeditationDistractionUseCaseProvider),
    syncSessionsUseCase: ref.read(syncMeditationSessionsUseCaseProvider),
    calculateStreaksUseCase: ref.read(calculateMeditationStreaksUseCaseProvider),
    getProgressUseCase: ref.read(getMeditationProgressUseCaseProvider),
  );
});

// Computed Providers
final meditationSessionsByTypeProvider = Provider<Map<String, List<MeditationSessionEntity>>>((ref) {
  final meditationState = ref.watch(meditationProvider);
  final sessionsByType = <String, List<MeditationSessionEntity>>{};
  
  for (final session in meditationState.sessions) {
    final type = session.type ?? 'general';
    sessionsByType[type] ??= [];
    sessionsByType[type]!.add(session);
  }
  
  return sessionsByType;
});

final averageSessionDurationProvider = Provider<double>((ref) {
  final meditationState = ref.watch(meditationProvider);
  if (meditationState.sessions.isEmpty) return 0.0;
  
  final totalMinutes = meditationState.sessions.fold<int>(0, (sum, session) => sum + (session.duration ?? 0));
  return totalMinutes / meditationState.sessions.length;
});

final meditationStreakProvider = Provider<int>((ref) {
  final meditationState = ref.watch(meditationProvider);
  return meditationState.streakData?['current_streak'] ?? 0;
});

final longestMeditationStreakProvider = Provider<int>((ref) {
  final meditationState = ref.watch(meditationProvider);
  return meditationState.streakData?['longest_streak'] ?? 0;
});

final favoriteTechiqueProvider = Provider<String?>((ref) {
  final meditationState = ref.watch(meditationProvider);
  if (meditationState.sessions.isEmpty) return null;
  
  final techniqueCounts = <String, int>{};
  for (final session in meditationState.sessions) {
    final technique = session.technique;
    if (technique != null) {
      techniqueCounts[technique] = (techniqueCounts[technique] ?? 0) + 1;
    }
  }
  
  if (techniqueCounts.isEmpty) return null;
  
  return techniqueCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
});

final weeklyMeditationTimeProvider = Provider<int>((ref) {
  final meditationState = ref.watch(meditationProvider);
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return meditationState.sessions
      .where((session) => session.startTime.isAfter(oneWeekAgo))
      .fold<int>(0, (sum, session) => sum + (session.duration ?? 0));
});

final meditationConsistencyProvider = Provider<double>((ref) {
  final meditationState = ref.watch(meditationProvider);
  return meditationState.streakData?['consistency_score']?.toDouble() ?? 0.0;
});

// Async Providers
final meditationSessionByIdProvider = FutureProvider.family<MeditationSessionEntity?, String>((ref, sessionId) async {
  final getSessionUseCase = ref.read(getMeditationSessionUseCaseProvider);
  final result = await getSessionUseCase(sessionId);
  
  return result.fold(
    (failure) => null,
    (session) => session,
  );
});

final meditationTechniqueByIdProvider = FutureProvider.family<MeditationTechniqueEntity?, String>((ref, techniqueId) async {
  final getTechniqueUseCase = ref.read(getMeditationTechniqueUseCaseProvider);
  final result = await getTechniqueUseCase(techniqueId);
  
  return result.fold(
    (failure) => null,
    (technique) => technique,
  );
});

final guidedMeditationByIdProvider = FutureProvider.family<GuidedMeditationEntity?, String>((ref, meditationId) async {
  final getGuidedMeditationUseCase = ref.read(getGuidedMeditationUseCaseProvider);
  final result = await getGuidedMeditationUseCase(meditationId);
  
  return result.fold(
    (failure) => null,
    (meditation) => meditation,
  );
});

final meditationProgressProvider = FutureProvider.family<Map<String, dynamic>, MeditationProgressParams>((ref, params) async {
  final getProgressUseCase = ref.read(getMeditationProgressUseCaseProvider);
  final result = await getProgressUseCase(GetMeditationProgressParams(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
  ));
  
  return result.fold(
    (failure) => {},
    (progress) => progress,
  );
});

class MeditationProgressParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  MeditationProgressParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}
