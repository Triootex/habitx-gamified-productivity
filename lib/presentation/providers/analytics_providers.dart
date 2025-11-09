import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/usecases/analytics_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final trackEventUseCaseProvider = Provider<TrackEventUseCase>((ref) => getIt<TrackEventUseCase>());
final getUserAnalyticsUseCaseProvider = Provider<GetUserAnalyticsUseCase>((ref) => getIt<GetUserAnalyticsUseCase>());
final getAppAnalyticsUseCaseProvider = Provider<GetAppAnalyticsUseCase>((ref) => getIt<GetAppAnalyticsUseCase>());
final getUserEventsUseCaseProvider = Provider<GetUserEventsUseCase>((ref) => getIt<GetUserEventsUseCase>());
final startSessionUseCaseProvider = Provider<StartSessionUseCase>((ref) => getIt<StartSessionUseCase>());
final endSessionUseCaseProvider = Provider<EndSessionUseCase>((ref) => getIt<EndSessionUseCase>());
final getCustomAnalyticsUseCaseProvider = Provider<GetCustomAnalyticsUseCase>((ref) => getIt<GetCustomAnalyticsUseCase>());
final generateInsightsUseCaseProvider = Provider<GenerateInsightsUseCase>((ref) => getIt<GenerateInsightsUseCase>());
final syncAnalyticsDataUseCaseProvider = Provider<SyncAnalyticsDataUseCase>((ref) => getIt<SyncAnalyticsDataUseCase>());
final exportAnalyticsUseCaseProvider = Provider<ExportAnalyticsUseCase>((ref) => getIt<ExportAnalyticsUseCase>());

// State Classes
class AnalyticsState {
  final UserAnalyticsEntity? userAnalytics;
  final AppAnalyticsEntity? appAnalytics;
  final List<AnalyticsEventEntity> events;
  final SessionTrackingEntity? currentSession;
  final Map<String, dynamic> customAnalytics;
  final Map<String, dynamic> insights;
  final bool isLoading;
  final String? error;

  const AnalyticsState({
    this.userAnalytics,
    this.appAnalytics,
    this.events = const [],
    this.currentSession,
    this.customAnalytics = const {},
    this.insights = const {},
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    UserAnalyticsEntity? userAnalytics,
    AppAnalyticsEntity? appAnalytics,
    List<AnalyticsEventEntity>? events,
    SessionTrackingEntity? currentSession,
    Map<String, dynamic>? customAnalytics,
    Map<String, dynamic>? insights,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      userAnalytics: userAnalytics ?? this.userAnalytics,
      appAnalytics: appAnalytics ?? this.appAnalytics,
      events: events ?? this.events,
      currentSession: currentSession ?? this.currentSession,
      customAnalytics: customAnalytics ?? this.customAnalytics,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Analytics State Notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final TrackEventUseCase trackEventUseCase;
  final GetUserAnalyticsUseCase getUserAnalyticsUseCase;
  final GetAppAnalyticsUseCase getAppAnalyticsUseCase;
  final GetUserEventsUseCase getUserEventsUseCase;
  final StartSessionUseCase startSessionUseCase;
  final EndSessionUseCase endSessionUseCase;
  final GetCustomAnalyticsUseCase getCustomAnalyticsUseCase;
  final GenerateInsightsUseCase generateInsightsUseCase;
  final SyncAnalyticsDataUseCase syncAnalyticsDataUseCase;
  final ExportAnalyticsUseCase exportAnalyticsUseCase;

  AnalyticsNotifier({
    required this.trackEventUseCase,
    required this.getUserAnalyticsUseCase,
    required this.getAppAnalyticsUseCase,
    required this.getUserEventsUseCase,
    required this.startSessionUseCase,
    required this.endSessionUseCase,
    required this.getCustomAnalyticsUseCase,
    required this.generateInsightsUseCase,
    required this.syncAnalyticsDataUseCase,
    required this.exportAnalyticsUseCase,
  }) : super(const AnalyticsState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserAnalytics();
  }

  Future<void> trackEvent(AnalyticsEventEntity event) async {
    if (_currentUserId == null) return;
    
    await trackEventUseCase(TrackEventParams(
      userId: _currentUserId!,
      event: event,
    ));
    
    // Add to local events list for immediate UI update
    state = state.copyWith(
      events: [...state.events, event],
    );
  }

  Future<void> startSession(Map<String, dynamic> sessionData) async {
    if (_currentUserId == null) return;
    
    final result = await startSessionUseCase(StartSessionParams(
      userId: _currentUserId!,
      sessionData: sessionData,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (session) => state = state.copyWith(currentSession: session),
    );
  }

  Future<void> endSession(Map<String, dynamic> completionData) async {
    if (state.currentSession == null) return;
    
    final result = await endSessionUseCase(EndSessionParams(
      sessionId: state.currentSession!.id,
      completionData: completionData,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (session) => state = state.copyWith(currentSession: session),
    );
  }

  Future<void> loadUserAnalytics() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await getUserAnalyticsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (analytics) => state = state.copyWith(
        isLoading: false,
        userAnalytics: analytics,
        error: null,
      ),
    );
  }

  Future<void> loadAppAnalytics() async {
    state = state.copyWith(isLoading: true);
    
    final result = await getAppAnalyticsUseCase(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (analytics) => state = state.copyWith(
        isLoading: false,
        appAnalytics: analytics,
        error: null,
      ),
    );
  }

  Future<void> loadUserEvents({DateTime? startDate, DateTime? endDate}) async {
    if (_currentUserId == null) return;
    
    final result = await getUserEventsUseCase(GetUserEventsParams(
      userId: _currentUserId!,
      startDate: startDate,
      endDate: endDate,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (events) => state = state.copyWith(events: events),
    );
  }

  Future<void> loadCustomAnalytics(String metricName, Map<String, dynamic> filters) async {
    if (_currentUserId == null) return;
    
    final result = await getCustomAnalyticsUseCase(GetCustomAnalyticsParams(
      userId: _currentUserId!,
      metricName: metricName,
      filters: filters,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) {
        final updated = Map<String, dynamic>.from(state.customAnalytics);
        updated[metricName] = analytics;
        state = state.copyWith(customAnalytics: updated);
      },
    );
  }

  Future<void> generateInsights() async {
    if (_currentUserId == null) return;
    
    final result = await generateInsightsUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (insights) => state = state.copyWith(insights: insights),
    );
  }

  Future<void> syncAnalytics() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncAnalyticsDataUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadUserAnalytics();
          loadUserEvents();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> exportAnalytics({
    String format = 'json',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentUserId == null) return null;
    
    final result = await exportAnalyticsUseCase(ExportAnalyticsParams(
      userId: _currentUserId!,
      format: format,
      startDate: startDate,
      endDate: endDate,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return null;
      },
      (data) => data,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Analytics Provider
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(
    trackEventUseCase: ref.read(trackEventUseCaseProvider),
    getUserAnalyticsUseCase: ref.read(getUserAnalyticsUseCaseProvider),
    getAppAnalyticsUseCase: ref.read(getAppAnalyticsUseCaseProvider),
    getUserEventsUseCase: ref.read(getUserEventsUseCaseProvider),
    startSessionUseCase: ref.read(startSessionUseCaseProvider),
    endSessionUseCase: ref.read(endSessionUseCaseProvider),
    getCustomAnalyticsUseCase: ref.read(getCustomAnalyticsUseCaseProvider),
    generateInsightsUseCase: ref.read(generateInsightsUseCaseProvider),
    syncAnalyticsDataUseCase: ref.read(syncAnalyticsDataUseCaseProvider),
    exportAnalyticsUseCase: ref.read(exportAnalyticsUseCaseProvider),
  );
});

// Computed Providers
final eventsByTypeProvider = Provider<Map<String, List<AnalyticsEventEntity>>>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  final eventsByType = <String, List<AnalyticsEventEntity>>{};
  
  for (final event in analyticsState.events) {
    eventsByType[event.eventType] ??= [];
    eventsByType[event.eventType]!.add(event);
  }
  
  return eventsByType;
});

final totalEventsProvider = Provider<int>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  return analyticsState.events.length;
});

final sessionDurationProvider = Provider<int?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  final session = analyticsState.currentSession;
  
  if (session == null || !session.isActive) return null;
  
  return DateTime.now().difference(session.startTime).inMinutes;
});

final dailyEventCountProvider = Provider<Map<String, int>>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  final dailyCounts = <String, int>{};
  
  for (final event in analyticsState.events) {
    final dateKey = '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
    dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
  }
  
  return dailyCounts;
});

final mostActiveHourProvider = Provider<int?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  if (analyticsState.events.isEmpty) return null;
  
  final hourlyCounts = <int, int>{};
  
  for (final event in analyticsState.events) {
    final hour = event.timestamp.hour;
    hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
  }
  
  if (hourlyCounts.isEmpty) return null;
  
  return hourlyCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
});

// Event Tracking Helper Provider
final eventTrackerProvider = Provider<EventTracker>((ref) {
  return EventTracker(ref.read(analyticsProvider.notifier));
});

class EventTracker {
  final AnalyticsNotifier analyticsNotifier;
  
  EventTracker(this.analyticsNotifier);
  
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEventEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: 'screen_view',
      eventName: 'screen_viewed',
      timestamp: DateTime.now(),
      properties: {
        'screen_name': screenName,
        ...?properties,
      },
    );
    
    analyticsNotifier.trackEvent(event);
  }
  
  void trackAction(String action, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEventEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: 'user_action',
      eventName: action,
      timestamp: DateTime.now(),
      properties: properties ?? {},
    );
    
    analyticsNotifier.trackEvent(event);
  }
  
  void trackFeatureUsage(String feature, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEventEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: 'feature_usage',
      eventName: 'feature_used',
      timestamp: DateTime.now(),
      properties: {
        'feature': feature,
        ...?properties,
      },
    );
    
    analyticsNotifier.trackEvent(event);
  }
  
  void trackError(String error, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEventEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: 'error',
      eventName: 'error_occurred',
      timestamp: DateTime.now(),
      properties: {
        'error_message': error,
        ...?properties,
      },
    );
    
    analyticsNotifier.trackEvent(event);
  }
  
  void trackPerformance(String operation, int durationMs, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEventEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: 'performance',
      eventName: 'operation_performance',
      timestamp: DateTime.now(),
      properties: {
        'operation': operation,
        'duration_ms': durationMs,
        ...?properties,
      },
    );
    
    analyticsNotifier.trackEvent(event);
  }
}

// Use Case Params Classes
class TrackEventParams {
  final String userId;
  final AnalyticsEventEntity event;

  TrackEventParams({required this.userId, required this.event});
}

class GetUserEventsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserEventsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

class StartSessionParams {
  final String userId;
  final Map<String, dynamic> sessionData;

  StartSessionParams({required this.userId, required this.sessionData});
}

class EndSessionParams {
  final String sessionId;
  final Map<String, dynamic> completionData;

  EndSessionParams({required this.sessionId, required this.completionData});
}

class GetCustomAnalyticsParams {
  final String userId;
  final String metricName;
  final Map<String, dynamic> filters;

  GetCustomAnalyticsParams({
    required this.userId,
    required this.metricName,
    required this.filters,
  });
}

class ExportAnalyticsParams {
  final String userId;
  final String format;
  final DateTime? startDate;
  final DateTime? endDate;

  ExportAnalyticsParams({
    required this.userId,
    required this.format,
    this.startDate,
    this.endDate,
  });
}
