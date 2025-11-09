import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mental_health_entity.dart';
import '../../domain/usecases/mental_health_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final createMentalHealthEntryUseCaseProvider = Provider<CreateMentalHealthEntryUseCase>((ref) => getIt<CreateMentalHealthEntryUseCase>());
final getUserMentalHealthEntriesUseCaseProvider = Provider<GetUserMentalHealthEntriesUseCase>((ref) => getIt<GetUserMentalHealthEntriesUseCase>());
final createCBTThoughtRecordUseCaseProvider = Provider<CreateCBTThoughtRecordUseCase>((ref) => getIt<CreateCBTThoughtRecordUseCase>());
final getCBTThoughtRecordsUseCaseProvider = Provider<GetCBTThoughtRecordsUseCase>((ref) => getIt<GetCBTThoughtRecordsUseCase>());
final conductMentalHealthAssessmentUseCaseProvider = Provider<ConductMentalHealthAssessmentUseCase>((ref) => getIt<ConductMentalHealthAssessmentUseCase>());
final getUserMentalHealthAssessmentsUseCaseProvider = Provider<GetUserMentalHealthAssessmentsUseCase>((ref) => getIt<GetUserMentalHealthAssessmentsUseCase>());
final getMentalHealthAnalyticsUseCaseProvider = Provider<GetMentalHealthAnalyticsUseCase>((ref) => getIt<GetMentalHealthAnalyticsUseCase>());
final generateCopingStrategiesUseCaseProvider = Provider<GenerateCopingStrategiesUseCase>((ref) => getIt<GenerateCopingStrategiesUseCase>());
final analyzeMoodPatternsUseCaseProvider = Provider<AnalyzeMoodPatternsUseCase>((ref) => getIt<AnalyzeMoodPatternsUseCase>());
final getPersonalizedMentalHealthInsightsUseCaseProvider = Provider<GetPersonalizedMentalHealthInsightsUseCase>((ref) => getIt<GetPersonalizedMentalHealthInsightsUseCase>());
final syncMentalHealthDataUseCaseProvider = Provider<SyncMentalHealthDataUseCase>((ref) => getIt<SyncMentalHealthDataUseCase>());
final calculateMentalWellnessScoreUseCaseProvider = Provider<CalculateMentalWellnessScoreUseCase>((ref) => getIt<CalculateMentalWellnessScoreUseCase>());
final getMentalHealthInsightsUseCaseProvider = Provider<GetMentalHealthInsightsUseCase>((ref) => getIt<GetMentalHealthInsightsUseCase>());

// State Classes
class MentalHealthState {
  final List<MentalHealthEntryEntity> entries;
  final List<CBTThoughtRecordEntity> thoughtRecords;
  final List<MentalHealthAssessmentEntity> assessments;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? wellnessScore;
  final Map<String, dynamic>? moodPatterns;
  final Map<String, dynamic>? insights;
  final List<String> copingStrategies;
  final List<String> personalizedInsights;
  final bool isLoading;
  final String? error;

  const MentalHealthState({
    this.entries = const [],
    this.thoughtRecords = const [],
    this.assessments = const [],
    this.analytics,
    this.wellnessScore,
    this.moodPatterns,
    this.insights,
    this.copingStrategies = const [],
    this.personalizedInsights = const [],
    this.isLoading = false,
    this.error,
  });

  MentalHealthState copyWith({
    List<MentalHealthEntryEntity>? entries,
    List<CBTThoughtRecordEntity>? thoughtRecords,
    List<MentalHealthAssessmentEntity>? assessments,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? wellnessScore,
    Map<String, dynamic>? moodPatterns,
    Map<String, dynamic>? insights,
    List<String>? copingStrategies,
    List<String>? personalizedInsights,
    bool? isLoading,
    String? error,
  }) {
    return MentalHealthState(
      entries: entries ?? this.entries,
      thoughtRecords: thoughtRecords ?? this.thoughtRecords,
      assessments: assessments ?? this.assessments,
      analytics: analytics ?? this.analytics,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      moodPatterns: moodPatterns ?? this.moodPatterns,
      insights: insights ?? this.insights,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      personalizedInsights: personalizedInsights ?? this.personalizedInsights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  double get averageMood {
    if (entries.isEmpty) return 5.0;
    return entries.fold<double>(0, (sum, entry) => sum + entry.moodRating) / entries.length;
  }

  int get totalEntries => entries.length;
  int get thoughtRecordsCount => thoughtRecords.length;
}

// Mental Health State Notifier
class MentalHealthNotifier extends StateNotifier<MentalHealthState> {
  final CreateMentalHealthEntryUseCase createEntryUseCase;
  final GetUserMentalHealthEntriesUseCase getUserEntriesUseCase;
  final CreateCBTThoughtRecordUseCase createThoughtRecordUseCase;
  final GetCBTThoughtRecordsUseCase getThoughtRecordsUseCase;
  final ConductMentalHealthAssessmentUseCase conductAssessmentUseCase;
  final GetUserMentalHealthAssessmentsUseCase getUserAssessmentsUseCase;
  final GetMentalHealthAnalyticsUseCase getAnalyticsUseCase;
  final GenerateCopingStrategiesUseCase generateCopingStrategiesUseCase;
  final AnalyzeMoodPatternsUseCase analyzeMoodPatternsUseCase;
  final GetPersonalizedMentalHealthInsightsUseCase getPersonalizedInsightsUseCase;
  final SyncMentalHealthDataUseCase syncDataUseCase;
  final CalculateMentalWellnessScoreUseCase calculateWellnessScoreUseCase;
  final GetMentalHealthInsightsUseCase getInsightsUseCase;

  MentalHealthNotifier({
    required this.createEntryUseCase,
    required this.getUserEntriesUseCase,
    required this.createThoughtRecordUseCase,
    required this.getThoughtRecordsUseCase,
    required this.conductAssessmentUseCase,
    required this.getUserAssessmentsUseCase,
    required this.getAnalyticsUseCase,
    required this.generateCopingStrategiesUseCase,
    required this.analyzeMoodPatternsUseCase,
    required this.getPersonalizedInsightsUseCase,
    required this.syncDataUseCase,
    required this.calculateWellnessScoreUseCase,
    required this.getInsightsUseCase,
  }) : super(const MentalHealthState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserData();
  }

  Future<void> loadUserData() async {
    await loadEntries();
    await loadThoughtRecords();
    await loadAssessments();
    await loadAnalytics();
    await loadWellnessScore();
    await loadMoodPatterns();
    await loadInsights();
    await loadPersonalizedInsights();
  }

  Future<void> loadEntries({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getUserEntriesUseCase(GetUserMentalHealthEntriesParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (entries) => state = state.copyWith(
        isLoading: false,
        entries: entries,
        error: null,
      ),
    );
  }

  Future<void> loadThoughtRecords({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getThoughtRecordsUseCase(GetCBTThoughtRecordsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (records) => state = state.copyWith(thoughtRecords: records),
    );
  }

  Future<void> loadAssessments() async {
    if (_currentUserId == null) return;
    
    final result = await getUserAssessmentsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (assessments) => state = state.copyWith(assessments: assessments),
    );
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getAnalyticsUseCase(GetMentalHealthAnalyticsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadWellnessScore() async {
    if (_currentUserId == null) return;
    
    final result = await calculateWellnessScoreUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (score) => state = state.copyWith(wellnessScore: score),
    );
  }

  Future<void> loadMoodPatterns() async {
    if (_currentUserId == null) return;
    
    final result = await analyzeMoodPatternsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (patterns) => state = state.copyWith(moodPatterns: patterns),
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

  Future<void> loadPersonalizedInsights() async {
    if (_currentUserId == null) return;
    
    final result = await getPersonalizedInsightsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (insights) => state = state.copyWith(personalizedInsights: insights),
    );
  }

  Future<bool> createEntry(Map<String, dynamic> entryData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createEntryUseCase(CreateMentalHealthEntryParams(
      userId: _currentUserId!,
      entryData: entryData,
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
          entries: [...state.entries, entry],
          error: null,
        );
        // Reload insights and patterns after new entry
        loadWellnessScore();
        loadMoodPatterns();
        loadInsights();
        return true;
      },
    );
  }

  Future<bool> createThoughtRecord(Map<String, dynamic> thoughtData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createThoughtRecordUseCase(CreateCBTThoughtRecordParams(
      userId: _currentUserId!,
      thoughtData: thoughtData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (record) {
        state = state.copyWith(
          isLoading: false,
          thoughtRecords: [...state.thoughtRecords, record],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> conductAssessment(String assessmentType, Map<String, dynamic> responses) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await conductAssessmentUseCase(ConductMentalHealthAssessmentParams(
      userId: _currentUserId!,
      assessmentType: assessmentType,
      responses: responses,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (assessment) {
        state = state.copyWith(
          isLoading: false,
          assessments: [...state.assessments, assessment],
          error: null,
        );
        // Reload wellness score after assessment
        loadWellnessScore();
        return true;
      },
    );
  }

  Future<void> generateCopingStrategies(String mood, List<String> triggers) async {
    if (_currentUserId == null) return;
    
    final result = await generateCopingStrategiesUseCase(GenerateCopingStrategiesParams(
      userId: _currentUserId!,
      mood: mood,
      triggers: triggers,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (strategies) => state = state.copyWith(copingStrategies: strategies),
    );
  }

  Future<void> syncData() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncDataUseCase(_currentUserId!);
    
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Mental Health Provider
final mentalHealthProvider = StateNotifierProvider<MentalHealthNotifier, MentalHealthState>((ref) {
  return MentalHealthNotifier(
    createEntryUseCase: ref.read(createMentalHealthEntryUseCaseProvider),
    getUserEntriesUseCase: ref.read(getUserMentalHealthEntriesUseCaseProvider),
    createThoughtRecordUseCase: ref.read(createCBTThoughtRecordUseCaseProvider),
    getThoughtRecordsUseCase: ref.read(getCBTThoughtRecordsUseCaseProvider),
    conductAssessmentUseCase: ref.read(conductMentalHealthAssessmentUseCaseProvider),
    getUserAssessmentsUseCase: ref.read(getUserMentalHealthAssessmentsUseCaseProvider),
    getAnalyticsUseCase: ref.read(getMentalHealthAnalyticsUseCaseProvider),
    generateCopingStrategiesUseCase: ref.read(generateCopingStrategiesUseCaseProvider),
    analyzeMoodPatternsUseCase: ref.read(analyzeMoodPatternsUseCaseProvider),
    getPersonalizedInsightsUseCase: ref.read(getPersonalizedMentalHealthInsightsUseCaseProvider),
    syncDataUseCase: ref.read(syncMentalHealthDataUseCaseProvider),
    calculateWellnessScoreUseCase: ref.read(calculateMentalWellnessScoreUseCaseProvider),
    getInsightsUseCase: ref.read(getMentalHealthInsightsUseCaseProvider),
  );
});

// Computed Providers
final recentMoodEntriesProvider = Provider<List<MentalHealthEntryEntity>>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final lastWeek = DateTime.now().subtract(const Duration(days: 7));
  
  return mentalHealthState.entries
      .where((entry) => entry.recordedAt.isAfter(lastWeek))
      .toList()
    ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
});

final moodTrendProvider = Provider<String>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['trend'] ?? 'stable';
});

final wellnessScoreProvider = Provider<int>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['wellness_score'] ?? 50;
});

final stressLevelProvider = Provider<double>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['stress_average']?.toDouble() ?? 5.0;
});

final energyLevelProvider = Provider<double>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['energy_average']?.toDouble() ?? 5.0;
});

final sleepQualityProvider = Provider<double>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['sleep_quality_average']?.toDouble() ?? 5.0;
});

final consistencyScoreProvider = Provider<int>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['consistency_score'] ?? 0;
});

final bestDayProvider = Provider<String?>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.moodPatterns?['best_day'];
});

final worstDayProvider = Provider<String?>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.moodPatterns?['worst_day'];
});

final topEmotionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final emotions = mentalHealthState.moodPatterns?['top_emotions'] as List<dynamic>?;
  return emotions?.cast<Map<String, dynamic>>() ?? [];
});

final moodByDayProvider = Provider<Map<int, double>>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final moodByDay = mentalHealthState.moodPatterns?['mood_by_day'] as Map<String, dynamic>?;
  
  if (moodByDay == null) return {};
  
  return moodByDay.map((key, value) => MapEntry(int.parse(key), value.toDouble()));
});

final topCognitiveDistortionProvider = Provider<String?>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.insights?['patterns']?['top_cognitive_distortion'];
});

final totalDataPointsProvider = Provider<int>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.insights?['data_points'] ?? 0;
});

final recommendationProvider = Provider<String?>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  return mentalHealthState.wellnessScore?['recommendation'];
});

final mentalHealthInsightsProvider = Provider<List<String>>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final insights = mentalHealthState.insights?['insights'] as List<dynamic>?;
  return insights?.cast<String>() ?? [];
});

final suggestionsProvider = Provider<List<String>>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final suggestions = mentalHealthState.insights?['suggestions'] as List<dynamic>?;
  return suggestions?.cast<String>() ?? [];
});

final weeklyMoodAverageProvider = Provider<double>((ref) {
  final recentEntries = ref.watch(recentMoodEntriesProvider);
  if (recentEntries.isEmpty) return 5.0;
  
  return recentEntries.fold<double>(0, (sum, entry) => sum + entry.moodRating) / recentEntries.length;
});

final moodConsistencyProvider = Provider<double>((ref) {
  final recentEntries = ref.watch(recentMoodEntriesProvider);
  if (recentEntries.length < 2) return 0.0;
  
  final moods = recentEntries.map((e) => e.moodRating.toDouble()).toList();
  final mean = moods.reduce((a, b) => a + b) / moods.length;
  final variance = moods.fold<double>(0, (sum, mood) => sum + ((mood - mean) * (mood - mean))) / moods.length;
  final standardDeviation = variance.sqrt();
  
  // Convert to consistency score (lower standard deviation = higher consistency)
  return ((10 - standardDeviation) / 10).clamp(0.0, 1.0);
});

// Today's mood provider
final todaysMoodProvider = Provider<MentalHealthEntryEntity?>((ref) {
  final mentalHealthState = ref.watch(mentalHealthProvider);
  final today = DateTime.now();
  
  final todaysEntries = mentalHealthState.entries.where((entry) =>
      entry.recordedAt.year == today.year &&
      entry.recordedAt.month == today.month &&
      entry.recordedAt.day == today.day).toList();
  
  return todaysEntries.isNotEmpty ? todaysEntries.last : null;
});

extension on double {
  double sqrt() => this >= 0 ? this : 0;
}
