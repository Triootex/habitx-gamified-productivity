import 'package:equatable/equatable.dart';

class FocusSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String sessionType; // deep_work, learning, creative, administrative, planning
  final String technique; // pomodoro, time_blocking, flow_time
  final String? taskId; // Associated task if any
  final String? projectId; // Associated project
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMinutes;
  final int? actualDurationMinutes;
  final bool wasCompleted;
  
  // Quality metrics
  final double qualityScore; // 0-10 calculated score
  final double productivityRating; // 1-10 user rating
  final int distractionsCount;
  final List<DistractionEventEntity> distractions;
  final double focusLevel; // 1-10 average focus throughout session
  
  // Pomodoro specific
  final int? pomodoroNumber; // Which pomodoro in the sequence
  final int? totalPomodoros; // Total planned pomodoros
  final bool isBreak; // Is this a break session
  final String? breakType; // short_break, long_break
  
  // Environment and setup
  final String? location; // home, office, library, cafe
  final String environment; // quiet, noisy, music, nature_sounds
  final List<String> toolsUsed; // notebook, laptop, tablet, etc.
  final String? musicPlaylist;
  final bool usedNoiseBlocking;
  final List<String> blockedApps;
  final List<String> blockedWebsites;
  
  // Mood and energy
  final int? energyLevelBefore; // 1-10
  final int? energyLevelAfter; // 1-10
  final int? motivationBefore; // 1-10
  final int? motivationAfter; // 1-10
  final String? moodBefore;
  final String? moodAfter;
  
  // Tree growth (gamification)
  final String? treeType; // oak, pine, cherry, etc.
  final double treeGrowthPoints;
  final String treeStage; // seed, sprout, sapling, tree, mature
  final bool treeFullyGrown;
  
  // Task integration
  final List<String> completedSubtasks;
  final double taskProgress; // 0-1
  final int? taskEstimatedMinutes;
  final bool taskCompleted;
  
  // Notes and insights
  final String? sessionNotes;
  final List<String> insights;
  final List<String> improvements;
  final String? nextActionPlan;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FocusSessionEntity({
    required this.id,
    required this.userId,
    required this.sessionType,
    this.technique = 'pomodoro',
    this.taskId,
    this.projectId,
    required this.startTime,
    this.endTime,
    this.plannedDurationMinutes = 25,
    this.actualDurationMinutes,
    this.wasCompleted = false,
    this.qualityScore = 0.0,
    this.productivityRating = 5.0,
    this.distractionsCount = 0,
    this.distractions = const [],
    this.focusLevel = 5.0,
    this.pomodoroNumber,
    this.totalPomodoros,
    this.isBreak = false,
    this.breakType,
    this.location,
    this.environment = 'quiet',
    this.toolsUsed = const [],
    this.musicPlaylist,
    this.usedNoiseBlocking = false,
    this.blockedApps = const [],
    this.blockedWebsites = const [],
    this.energyLevelBefore,
    this.energyLevelAfter,
    this.motivationBefore,
    this.motivationAfter,
    this.moodBefore,
    this.moodAfter,
    this.treeType,
    this.treeGrowthPoints = 0.0,
    this.treeStage = 'seed',
    this.treeFullyGrown = false,
    this.completedSubtasks = const [],
    this.taskProgress = 0.0,
    this.taskEstimatedMinutes,
    this.taskCompleted = false,
    this.sessionNotes,
    this.insights = const [],
    this.improvements = const [],
    this.nextActionPlan,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => endTime == null;
  
  Duration get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else if (actualDurationMinutes != null) {
      return Duration(minutes: actualDurationMinutes!);
    }
    return Duration.zero;
  }
  
  double get completionPercentage {
    final actual = actualDurationMinutes ?? actualDuration.inMinutes;
    if (plannedDurationMinutes == 0) return 0.0;
    return (actual / plannedDurationMinutes).clamp(0.0, 1.0);
  }
  
  bool get isSuccessful => wasCompleted && qualityScore >= 6.0;

  FocusSessionEntity copyWith({
    String? id,
    String? userId,
    String? sessionType,
    String? technique,
    String? taskId,
    String? projectId,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    bool? wasCompleted,
    double? qualityScore,
    double? productivityRating,
    int? distractionsCount,
    List<DistractionEventEntity>? distractions,
    double? focusLevel,
    int? pomodoroNumber,
    int? totalPomodoros,
    bool? isBreak,
    String? breakType,
    String? location,
    String? environment,
    List<String>? toolsUsed,
    String? musicPlaylist,
    bool? usedNoiseBlocking,
    List<String>? blockedApps,
    List<String>? blockedWebsites,
    int? energyLevelBefore,
    int? energyLevelAfter,
    int? motivationBefore,
    int? motivationAfter,
    String? moodBefore,
    String? moodAfter,
    String? treeType,
    double? treeGrowthPoints,
    String? treeStage,
    bool? treeFullyGrown,
    List<String>? completedSubtasks,
    double? taskProgress,
    int? taskEstimatedMinutes,
    bool? taskCompleted,
    String? sessionNotes,
    List<String>? insights,
    List<String>? improvements,
    String? nextActionPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionType: sessionType ?? this.sessionType,
      technique: technique ?? this.technique,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      qualityScore: qualityScore ?? this.qualityScore,
      productivityRating: productivityRating ?? this.productivityRating,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      distractions: distractions ?? this.distractions,
      focusLevel: focusLevel ?? this.focusLevel,
      pomodoroNumber: pomodoroNumber ?? this.pomodoroNumber,
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      isBreak: isBreak ?? this.isBreak,
      breakType: breakType ?? this.breakType,
      location: location ?? this.location,
      environment: environment ?? this.environment,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      musicPlaylist: musicPlaylist ?? this.musicPlaylist,
      usedNoiseBlocking: usedNoiseBlocking ?? this.usedNoiseBlocking,
      blockedApps: blockedApps ?? this.blockedApps,
      blockedWebsites: blockedWebsites ?? this.blockedWebsites,
      energyLevelBefore: energyLevelBefore ?? this.energyLevelBefore,
      energyLevelAfter: energyLevelAfter ?? this.energyLevelAfter,
      motivationBefore: motivationBefore ?? this.motivationBefore,
      motivationAfter: motivationAfter ?? this.motivationAfter,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      treeType: treeType ?? this.treeType,
      treeGrowthPoints: treeGrowthPoints ?? this.treeGrowthPoints,
      treeStage: treeStage ?? this.treeStage,
      treeFullyGrown: treeFullyGrown ?? this.treeFullyGrown,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      taskProgress: taskProgress ?? this.taskProgress,
      taskEstimatedMinutes: taskEstimatedMinutes ?? this.taskEstimatedMinutes,
      taskCompleted: taskCompleted ?? this.taskCompleted,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      insights: insights ?? this.insights,
      improvements: improvements ?? this.improvements,
      nextActionPlan: nextActionPlan ?? this.nextActionPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionType,
        technique,
        taskId,
        projectId,
        startTime,
        endTime,
        plannedDurationMinutes,
        actualDurationMinutes,
        wasCompleted,
        qualityScore,
        productivityRating,
        distractionsCount,
        distractions,
        focusLevel,
        pomodoroNumber,
        totalPomodoros,
        isBreak,
        breakType,
        location,
        environment,
        toolsUsed,
        musicPlaylist,
        usedNoiseBlocking,
        blockedApps,
        blockedWebsites,
        energyLevelBefore,
        energyLevelAfter,
        motivationBefore,
        motivationAfter,
        moodBefore,
        moodAfter,
        treeType,
        treeGrowthPoints,
        treeStage,
        treeFullyGrown,
        completedSubtasks,
        taskProgress,
        taskEstimatedMinutes,
        taskCompleted,
        sessionNotes,
        insights,
        improvements,
        nextActionPlan,
        createdAt,
        updatedAt,
      ];
}

class DistractionEventEntity extends Equatable {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final String type; // internal, external, digital, physical
  final String category; // notification, thought, noise, interruption
  final String? source; // app_name, person, website, etc.
  final String? description;
  final int intensity; // 1-5 scale
  final int durationSeconds;
  final String? response; // ignored, handled, gave_in
  final bool wasHandledWell;
  final String? notes;

  const DistractionEventEntity({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.type,
    required this.category,
    this.source,
    this.description,
    this.intensity = 1,
    this.durationSeconds = 0,
    this.response,
    this.wasHandledWell = true,
    this.notes,
  });

  DistractionEventEntity copyWith({
    String? id,
    String? sessionId,
    DateTime? timestamp,
    String? type,
    String? category,
    String? source,
    String? description,
    int? intensity,
    int? durationSeconds,
    String? response,
    bool? wasHandledWell,
    String? notes,
  }) {
    return DistractionEventEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      category: category ?? this.category,
      source: source ?? this.source,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      response: response ?? this.response,
      wasHandledWell: wasHandledWell ?? this.wasHandledWell,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        timestamp,
        type,
        category,
        source,
        description,
        intensity,
        durationSeconds,
        response,
        wasHandledWell,
        notes,
      ];
}

class PomodoroTimerEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final bool isActive;
  final bool isRunning;
  final DateTime? startTime;
  final DateTime? pausedAt;
  final Duration timeRemaining;
  
  // Timer settings
  final int workDuration; // minutes
  final int shortBreakDuration; // minutes
  final int longBreakDuration; // minutes
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  
  // Current state
  final String currentPhase; // work, short_break, long_break
  final int currentSession; // Which pomodoro number
  final int completedSessions;
  final List<String> completedSessionIds;
  
  // Sound settings
  final bool playTickingSound;
  final bool playAlarms;
  final String? workEndSound;
  final String? breakEndSound;
  final double volume;
  
  // Task integration
  final String? currentTaskId;
  final String? currentProjectId;
  final bool trackTaskProgress;
  
  // Analytics
  final int totalSessionsToday;
  final Duration totalFocusTimeToday;
  final Map<String, int> dailyStats;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PomodoroTimerEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.isActive = false,
    this.isRunning = false,
    this.startTime,
    this.pausedAt,
    this.timeRemaining = Duration.zero,
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.currentPhase = 'work',
    this.currentSession = 1,
    this.completedSessions = 0,
    this.completedSessionIds = const [],
    this.playTickingSound = false,
    this.playAlarms = true,
    this.workEndSound,
    this.breakEndSound,
    this.volume = 0.7,
    this.currentTaskId,
    this.currentProjectId,
    this.trackTaskProgress = false,
    this.totalSessionsToday = 0,
    this.totalFocusTimeToday = Duration.zero,
    this.dailyStats = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPaused => pausedAt != null;
  bool get isWorkPhase => currentPhase == 'work';
  bool get isBreakPhase => currentPhase == 'short_break' || currentPhase == 'long_break';
  bool get isLongBreakNext => completedSessions % sessionsUntilLongBreak == 0;

  PomodoroTimerEntity copyWith({
    String? id,
    String? userId,
    String? name,
    bool? isActive,
    bool? isRunning,
    DateTime? startTime,
    DateTime? pausedAt,
    Duration? timeRemaining,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    String? currentPhase,
    int? currentSession,
    int? completedSessions,
    List<String>? completedSessionIds,
    bool? playTickingSound,
    bool? playAlarms,
    String? workEndSound,
    String? breakEndSound,
    double? volume,
    String? currentTaskId,
    String? currentProjectId,
    bool? trackTaskProgress,
    int? totalSessionsToday,
    Duration? totalFocusTimeToday,
    Map<String, int>? dailyStats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PomodoroTimerEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isRunning: isRunning ?? this.isRunning,
      startTime: startTime ?? this.startTime,
      pausedAt: pausedAt ?? this.pausedAt,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      currentPhase: currentPhase ?? this.currentPhase,
      currentSession: currentSession ?? this.currentSession,
      completedSessions: completedSessions ?? this.completedSessions,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      playTickingSound: playTickingSound ?? this.playTickingSound,
      playAlarms: playAlarms ?? this.playAlarms,
      workEndSound: workEndSound ?? this.workEndSound,
      breakEndSound: breakEndSound ?? this.breakEndSound,
      volume: volume ?? this.volume,
      currentTaskId: currentTaskId ?? this.currentTaskId,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      trackTaskProgress: trackTaskProgress ?? this.trackTaskProgress,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
      totalFocusTimeToday: totalFocusTimeToday ?? this.totalFocusTimeToday,
      dailyStats: dailyStats ?? this.dailyStats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        isActive,
        isRunning,
        startTime,
        pausedAt,
        timeRemaining,
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        sessionsUntilLongBreak,
        autoStartBreaks,
        autoStartPomodoros,
        currentPhase,
        currentSession,
        completedSessions,
        completedSessionIds,
        playTickingSound,
        playAlarms,
        workEndSound,
        breakEndSound,
        volume,
        currentTaskId,
        currentProjectId,
        trackTaskProgress,
        totalSessionsToday,
        totalFocusTimeToday,
        dailyStats,
        createdAt,
        updatedAt,
      ];
}

class FocusBlockEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String blockType; // deep_work, meeting, creative, etc.
  final String? description;
  final List<String> associatedTasks;
  final String? projectId;
  final bool isRecurring;
  final String? recurringPattern;
  final String priority; // high, medium, low
  final String status; // scheduled, in_progress, completed, cancelled
  final List<String> protectedApps; // Apps allowed during this block
  final List<String> blockedApps; // Apps blocked during this block
  final List<String> blockedWebsites;
  final bool enableDoNotDisturb;
  final Map<String, dynamic> automationRules;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FocusBlockEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.blockType,
    this.description,
    this.associatedTasks = const [],
    this.projectId,
    this.isRecurring = false,
    this.recurringPattern,
    this.priority = 'medium',
    this.status = 'scheduled',
    this.protectedApps = const [],
    this.blockedApps = const [],
    this.blockedWebsites = const [],
    this.enableDoNotDisturb = true,
    this.automationRules = const {},
    required this.createdAt,
    this.updatedAt,
  });

  Duration get duration => endTime.difference(startTime);
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isCompleted => status == 'completed';

  FocusBlockEntity copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    String? blockType,
    String? description,
    List<String>? associatedTasks,
    String? projectId,
    bool? isRecurring,
    String? recurringPattern,
    String? priority,
    String? status,
    List<String>? protectedApps,
    List<String>? blockedApps,
    List<String>? blockedWebsites,
    bool? enableDoNotDisturb,
    Map<String, dynamic>? automationRules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusBlockEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      blockType: blockType ?? this.blockType,
      description: description ?? this.description,
      associatedTasks: associatedTasks ?? this.associatedTasks,
      projectId: projectId ?? this.projectId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      protectedApps: protectedApps ?? this.protectedApps,
      blockedApps: blockedApps ?? this.blockedApps,
      blockedWebsites: blockedWebsites ?? this.blockedWebsites,
      enableDoNotDisturb: enableDoNotDisturb ?? this.enableDoNotDisturb,
      automationRules: automationRules ?? this.automationRules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        startTime,
        endTime,
        blockType,
        description,
        associatedTasks,
        projectId,
        isRecurring,
        recurringPattern,
        priority,
        status,
        protectedApps,
        blockedApps,
        blockedWebsites,
        enableDoNotDisturb,
        automationRules,
        createdAt,
        updatedAt,
      ];
}
