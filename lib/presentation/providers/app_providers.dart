import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_providers.dart';
import 'task_providers.dart';
import 'habit_providers.dart';
import 'analytics_providers.dart';
import 'permission_providers.dart';

// App Initialization Provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Initialize permissions first
  await ref.read(permissionProvider.notifier).refreshPermissions();
  
  // Initialize user authentication
  await ref.read(userProvider.notifier).initialize();
  
  // Check if user is authenticated
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  
  if (isAuthenticated) {
    final userId = ref.read(userIdProvider);
    if (userId != null) {
      // Initialize all user-dependent providers
      ref.read(taskProvider.notifier).setUserId(userId);
      ref.read(habitProvider.notifier).setUserId(userId);
      ref.read(analyticsProvider.notifier).setUserId(userId);
      
      // Request critical permissions if not granted
      final shouldShowOnboarding = ref.read(shouldShowPermissionOnboardingProvider);
      if (!shouldShowOnboarding) {
        await ref.read(permissionProvider.notifier).requestCriticalPermissions();
      }
      
      // Start analytics session (only if notifications permission granted)
      final notificationsGranted = ref.read(notificationsPermissionProvider);
      if (notificationsGranted) {
        ref.read(analyticsProvider.notifier).startSession({
          'session_type': 'app_launch',
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        // Track app launch event
        ref.read(eventTrackerProvider).trackAction('app_launched');
      }
    }
  }
  
  return true;
});

// Theme Provider
enum AppThemeMode {
  light,
  dark,
  system,
}

final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.system);

// App Settings State
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String language;
  final bool offlineMode;
  final bool dataSync;
  final Map<String, dynamic> privacySettings;

  const AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.language = 'en',
    this.offlineMode = false,
    this.dataSync = true,
    this.privacySettings = const {},
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? language,
    bool? offlineMode,
    bool? dataSync,
    Map<String, dynamic>? privacySettings,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      language: language ?? this.language,
      offlineMode: offlineMode ?? this.offlineMode,
      dataSync: dataSync ?? this.dataSync,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}

// App Settings Notifier
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void updateNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void updateHaptics(bool enabled) {
    state = state.copyWith(hapticsEnabled: enabled);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateOfflineMode(bool enabled) {
    state = state.copyWith(offlineMode: enabled);
  }

  void updateDataSync(bool enabled) {
    state = state.copyWith(dataSync: enabled);
  }

  void updatePrivacySetting(String key, dynamic value) {
    final updatedPrivacy = Map<String, dynamic>.from(state.privacySettings);
    updatedPrivacy[key] = value;
    state = state.copyWith(privacySettings: updatedPrivacy);
  }

  void loadSettings(Map<String, dynamic> settings) {
    state = AppSettings(
      notificationsEnabled: settings['notifications_enabled'] ?? true,
      soundEnabled: settings['sound_enabled'] ?? true,
      hapticsEnabled: settings['haptics_enabled'] ?? true,
      language: settings['language'] ?? 'en',
      offlineMode: settings['offline_mode'] ?? false,
      dataSync: settings['data_sync'] ?? true,
      privacySettings: settings['privacy_settings'] ?? {},
    );
  }
}

// App Settings Provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

// Network Status Provider
final networkStatusProvider = StateProvider<bool>((ref) => true);

// Loading States Provider
class LoadingState {
  final bool isInitializing;
  final bool isSyncing;
  final bool isBackingUp;
  final Set<String> activeOperations;

  const LoadingState({
    this.isInitializing = false,
    this.isSyncing = false,
    this.isBackingUp = false,
    this.activeOperations = const {},
  });

  LoadingState copyWith({
    bool? isInitializing,
    bool? isSyncing,
    bool? isBackingUp,
    Set<String>? activeOperations,
  }) {
    return LoadingState(
      isInitializing: isInitializing ?? this.isInitializing,
      isSyncing: isSyncing ?? this.isSyncing,
      isBackingUp: isBackingUp ?? this.isBackingUp,
      activeOperations: activeOperations ?? this.activeOperations,
    );
  }

  bool get hasActiveOperations => activeOperations.isNotEmpty || isInitializing || isSyncing || isBackingUp;
}

final loadingStateProvider = StateProvider<LoadingState>((ref) => const LoadingState());

// Global Error Provider
final globalErrorProvider = StateProvider<String?>((ref) => null);

// App Navigation State
enum AppPage {
  dashboard,
  tasks,
  habits,
  meditation,
  focus,
  fitness,
  language,
  mentalHealth,
  sleep,
  budget,
  reading,
  journal,
  meals,
  flashcards,
  marketplace,
  social,
  analytics,
  profile,
  settings,
}

final currentPageProvider = StateProvider<AppPage>((ref) => AppPage.dashboard);

// Dashboard Data Provider
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return {};

  // Gather data from all providers for dashboard
  final taskState = ref.watch(taskProvider);
  final habitState = ref.watch(habitProvider);
  final userState = ref.watch(userProvider);
  final analyticsState = ref.watch(analyticsProvider);

  return {
    'user': {
      'level': userState.levelData?['current_level'] ?? 1,
      'xp': userState.user?.totalXP ?? 0,
      'streak': userState.user?.currentStreak ?? 0,
      'achievements_count': userState.achievements.length,
    },
    'tasks': {
      'total': taskState.tasks.length,
      'completed_today': taskState.todayTasks.where((t) => t.isCompleted).length,
      'overdue': taskState.overdueTasks.length,
      'completion_rate': ref.read(taskCompletionRateProvider),
    },
    'habits': {
      'total': habitState.habits.length,
      'completed_today': ref.read(todayCompletedHabitsProvider).length,
      'due_today': habitState.todayHabits.length,
      'completion_rate': ref.read(habitCompletionRateProvider),
      'longest_streak': ref.read(longestStreakProvider),
    },
    'analytics': {
      'total_events': ref.read(totalEventsProvider),
      'session_duration': ref.read(sessionDurationProvider),
      'most_active_hour': ref.read(mostActiveHourProvider),
    },
  };
});

// Quick Actions Provider
final quickActionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final userState = ref.watch(userProvider);
  if (!userState.isAuthenticated) return [];

  return [
    {
      'title': 'Add Task',
      'icon': 'task_alt',
      'action': 'add_task',
      'color': '0xFF2196F3',
    },
    {
      'title': 'Log Habit',
      'icon': 'check_circle',
      'action': 'log_habit',
      'color': '0xFF4CAF50',
    },
    {
      'title': 'Start Focus',
      'icon': 'timer',
      'action': 'start_focus',
      'color': '0xFFFF9800',
    },
    {
      'title': 'Meditate',
      'icon': 'self_improvement',
      'action': 'start_meditation',
      'color': '0xFF9C27B0',
    },
    {
      'title': 'Track Sleep',
      'icon': 'bedtime',
      'action': 'track_sleep',
      'color': '0xFF3F51B5',
    },
    {
      'title': 'Add Expense',
      'icon': 'account_balance_wallet',
      'action': 'add_expense',
      'color': '0xFFE91E63',
    },
  ];
});

// Today's Summary Provider
final todaySummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return {};

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  
  // Get today's data
  final taskState = ref.watch(taskProvider);
  final habitState = ref.watch(habitProvider);
  
  final todayTasks = taskState.tasks.where((task) {
    return task.dueDate != null && 
           task.dueDate!.year == today.year &&
           task.dueDate!.month == today.month &&
           task.dueDate!.day == today.day;
  }).toList();

  final completedTasks = todayTasks.where((task) => task.isCompleted).length;
  final completedHabits = ref.read(todayCompletedHabitsProvider).length;
  final totalHabits = habitState.todayHabits.length;

  return {
    'date': today.toIso8601String(),
    'tasks': {
      'total': todayTasks.length,
      'completed': completedTasks,
      'completion_rate': todayTasks.isNotEmpty ? (completedTasks / todayTasks.length) : 0.0,
    },
    'habits': {
      'total': totalHabits,
      'completed': completedHabits,
      'completion_rate': totalHabits > 0 ? (completedHabits / totalHabits) : 0.0,
    },
    'productivity_score': _calculateProductivityScore(
      todayTasks.isNotEmpty ? (completedTasks / todayTasks.length) : 0.0,
      totalHabits > 0 ? (completedHabits / totalHabits) : 0.0,
    ),
  };
});

double _calculateProductivityScore(double taskCompletion, double habitCompletion) {
  return ((taskCompletion * 0.6) + (habitCompletion * 0.4)) * 100;
}

// Recent Activity Provider
final recentActivityProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final taskState = ref.watch(taskProvider);
  final habitState = ref.watch(habitProvider);
  final analyticsState = ref.watch(analyticsProvider);

  final activities = <Map<String, dynamic>>[];

  // Add recent completed tasks
  final recentCompletedTasks = taskState.tasks
      .where((task) => task.isCompleted && task.completedAt != null)
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  for (final task in recentCompletedTasks.take(5)) {
    activities.add({
      'type': 'task_completed',
      'title': 'Completed: ${task.title}',
      'timestamp': task.completedAt!,
      'icon': 'task_alt',
      'color': '0xFF4CAF50',
    });
  }

  // Add recent habit logs
  final recentHabits = ref.read(todayCompletedHabitsProvider);
  for (final habit in recentHabits.take(3)) {
    activities.add({
      'type': 'habit_logged',
      'title': 'Logged: ${habit.name}',
      'timestamp': habit.lastCompletedAt ?? DateTime.now(),
      'icon': 'check_circle',
      'color': '0xFF2196F3',
    });
  }

  // Add recent analytics events
  final recentEvents = analyticsState.events
      .where((event) => event.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  for (final event in recentEvents.take(3)) {
    activities.add({
      'type': 'event',
      'title': event.eventName,
      'timestamp': event.timestamp,
      'icon': 'analytics',
      'color': '0xFFFF9800',
    });
  }

  // Sort by timestamp and return latest 10
  activities.sort((a, b) => 
      (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

  return activities.take(10).toList();
});

// Streak Information Provider
final streakInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final userState = ref.watch(userProvider);
  final habitState = ref.watch(habitProvider);

  final currentStreak = userState.user?.currentStreak ?? 0;
  final longestStreak = userState.user?.longestStreak ?? 0;
  final habitStreaks = habitState.streaks;

  return {
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'habit_streaks': habitStreaks,
    'total_habit_streaks': habitStreaks.values.fold<int>(0, (sum, streak) => sum + streak),
    'average_habit_streak': habitStreaks.isNotEmpty 
        ? habitStreaks.values.reduce((a, b) => a + b) / habitStreaks.length 
        : 0.0,
  };
});

// Achievement Progress Provider
final achievementProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final userState = ref.watch(userProvider);
  final taskState = ref.watch(taskProvider);
  final habitState = ref.watch(habitProvider);

  final totalTasks = taskState.tasks.length;
  final completedTasks = taskState.tasks.where((t) => t.isCompleted).length;
  final totalHabits = habitState.habits.length;
  final currentStreak = userState.user?.currentStreak ?? 0;

  return {
    'tasks_milestone': {
      'current': completedTasks,
      'next_milestone': _getNextMilestone(completedTasks, [10, 50, 100, 500, 1000]),
      'progress': _getMilestoneProgress(completedTasks, [10, 50, 100, 500, 1000]),
    },
    'habits_milestone': {
      'current': totalHabits,
      'next_milestone': _getNextMilestone(totalHabits, [5, 10, 25, 50, 100]),
      'progress': _getMilestoneProgress(totalHabits, [5, 10, 25, 50, 100]),
    },
    'streak_milestone': {
      'current': currentStreak,
      'next_milestone': _getNextMilestone(currentStreak, [7, 30, 100, 365, 1000]),
      'progress': _getMilestoneProgress(currentStreak, [7, 30, 100, 365, 1000]),
    },
  };
});

int _getNextMilestone(int current, List<int> milestones) {
  for (final milestone in milestones) {
    if (current < milestone) return milestone;
  }
  return milestones.last * 2; // Return double the highest milestone
}

double _getMilestoneProgress(int current, List<int> milestones) {
  final nextMilestone = _getNextMilestone(current, milestones);
  
  // Find previous milestone
  int prevMilestone = 0;
  for (final milestone in milestones) {
    if (milestone < nextMilestone) {
      prevMilestone = milestone;
    } else {
      break;
    }
  }
  
  if (nextMilestone == prevMilestone) return 1.0;
  
  return (current - prevMilestone) / (nextMilestone - prevMilestone);
}
