import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final String type; // positive, negative
  final String trackingType; // boolean, numeric, duration, custom
  final String frequency; // daily, weekly, monthly, custom
  final Map<String, dynamic> frequencyConfig;
  
  // Target and measurement
  final double? targetValue;
  final String? unit;
  final String? targetDescription;
  
  // Scheduling
  final List<int> scheduledDays; // 1=Monday, 7=Sunday
  final String? preferredTime; // morning, afternoon, evening, night
  final DateTime? specificTime;
  final List<String> reminders;
  
  // Progress tracking
  final Map<String, HabitLogEntity> logs; // Date -> Log
  final int currentStreak;
  final int longestStreak;
  final double habitStrength; // 0.0 to 1.0
  final DateTime? lastCompletedDate;
  final int totalCompletions;
  
  // Gamification
  final int xpPerCompletion;
  final int totalXpEarned;
  final List<String> milestones;
  final String? currentLevel; // novice, intermediate, expert, master
  
  // Health integration
  final bool syncWithHealthApp;
  final String? healthMetric; // steps, sleep, heart_rate, etc.
  final Map<String, dynamic>? healthConfig;
  
  // Templates and suggestions
  final bool isFromTemplate;
  final String? templateId;
  final List<String> suggestedImprovements;
  
  // Social features
  final bool isPublic;
  final List<String> accountabilityPartners;
  final int supporterCount;
  
  // Status
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  
  // Challenge integration
  final String? challengeId;
  final bool isPartOfChallenge;
  
  const HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    this.type = 'positive',
    this.trackingType = 'boolean',
    this.frequency = 'daily',
    this.frequencyConfig = const {},
    this.targetValue,
    this.unit,
    this.targetDescription,
    this.scheduledDays = const [],
    this.preferredTime,
    this.specificTime,
    this.reminders = const [],
    this.logs = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.habitStrength = 0.0,
    this.lastCompletedDate,
    this.totalCompletions = 0,
    this.xpPerCompletion = 10,
    this.totalXpEarned = 0,
    this.milestones = const [],
    this.currentLevel,
    this.syncWithHealthApp = false,
    this.healthMetric,
    this.healthConfig,
    this.isFromTemplate = false,
    this.templateId,
    this.suggestedImprovements = const [],
    this.isPublic = false,
    this.accountabilityPartners = const [],
    this.supporterCount = 0,
    this.isActive = true,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
    this.challengeId,
    this.isPartOfChallenge = false,
  });

  bool get isScheduledToday {
    final today = DateTime.now().weekday;
    return scheduledDays.isEmpty || scheduledDays.contains(today);
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final todayLog = logs[todayKey];
    return todayLog?.isCompleted ?? false;
  }

  double get todayProgress {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final todayLog = logs[todayKey];
    
    if (todayLog == null) return 0.0;
    
    if (trackingType == 'boolean') {
      return todayLog.isCompleted ? 1.0 : 0.0;
    } else if (trackingType == 'numeric' && targetValue != null) {
      return (todayLog.value / targetValue!).clamp(0.0, 1.0);
    } else if (trackingType == 'duration' && targetValue != null) {
      return (todayLog.durationMinutes / targetValue!).clamp(0.0, 1.0);
    }
    
    return 0.0;
  }

  int get completionsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = _dateKey(date);
      if (logs[dateKey]?.isCompleted ?? false) {
        count++;
      }
    }
    
    return count;
  }

  int get completionsThisMonth {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    int count = 0;
    
    for (int i = 0; i < DateTime(now.year, now.month + 1, 0).day; i++) {
      final date = monthStart.add(Duration(days: i));
      final dateKey = _dateKey(date);
      if (logs[dateKey]?.isCompleted ?? false) {
        count++;
      }
    }
    
    return count;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? type,
    String? trackingType,
    String? frequency,
    Map<String, dynamic>? frequencyConfig,
    double? targetValue,
    String? unit,
    String? targetDescription,
    List<int>? scheduledDays,
    String? preferredTime,
    DateTime? specificTime,
    List<String>? reminders,
    Map<String, HabitLogEntity>? logs,
    int? currentStreak,
    int? longestStreak,
    double? habitStrength,
    DateTime? lastCompletedDate,
    int? totalCompletions,
    int? xpPerCompletion,
    int? totalXpEarned,
    List<String>? milestones,
    String? currentLevel,
    bool? syncWithHealthApp,
    String? healthMetric,
    Map<String, dynamic>? healthConfig,
    bool? isFromTemplate,
    String? templateId,
    List<String>? suggestedImprovements,
    bool? isPublic,
    List<String>? accountabilityPartners,
    int? supporterCount,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? challengeId,
    bool? isPartOfChallenge,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      trackingType: trackingType ?? this.trackingType,
      frequency: frequency ?? this.frequency,
      frequencyConfig: frequencyConfig ?? this.frequencyConfig,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      targetDescription: targetDescription ?? this.targetDescription,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      preferredTime: preferredTime ?? this.preferredTime,
      specificTime: specificTime ?? this.specificTime,
      reminders: reminders ?? this.reminders,
      logs: logs ?? this.logs,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      habitStrength: habitStrength ?? this.habitStrength,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      xpPerCompletion: xpPerCompletion ?? this.xpPerCompletion,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      milestones: milestones ?? this.milestones,
      currentLevel: currentLevel ?? this.currentLevel,
      syncWithHealthApp: syncWithHealthApp ?? this.syncWithHealthApp,
      healthMetric: healthMetric ?? this.healthMetric,
      healthConfig: healthConfig ?? this.healthConfig,
      isFromTemplate: isFromTemplate ?? this.isFromTemplate,
      templateId: templateId ?? this.templateId,
      suggestedImprovements: suggestedImprovements ?? this.suggestedImprovements,
      isPublic: isPublic ?? this.isPublic,
      accountabilityPartners: accountabilityPartners ?? this.accountabilityPartners,
      supporterCount: supporterCount ?? this.supporterCount,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      challengeId: challengeId ?? this.challengeId,
      isPartOfChallenge: isPartOfChallenge ?? this.isPartOfChallenge,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        category,
        type,
        trackingType,
        frequency,
        frequencyConfig,
        targetValue,
        unit,
        targetDescription,
        scheduledDays,
        preferredTime,
        specificTime,
        reminders,
        logs,
        currentStreak,
        longestStreak,
        habitStrength,
        lastCompletedDate,
        totalCompletions,
        xpPerCompletion,
        totalXpEarned,
        milestones,
        currentLevel,
        syncWithHealthApp,
        healthMetric,
        healthConfig,
        isFromTemplate,
        templateId,
        suggestedImprovements,
        isPublic,
        accountabilityPartners,
        supporterCount,
        isActive,
        isArchived,
        createdAt,
        updatedAt,
        archivedAt,
        challengeId,
        isPartOfChallenge,
      ];
}

class HabitLogEntity extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool isCompleted;
  final double value; // For numeric tracking
  final int durationMinutes; // For duration tracking
  final String? notes;
  final double? moodBefore; // 1-5 scale
  final double? moodAfter; // 1-5 scale
  final String? customData; // JSON string for custom tracking
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Context
  final String? location;
  final List<String> tags;
  final String? weather;
  final int? energyLevel; // 1-5 scale
  final int? motivationLevel; // 1-5 scale

  const HabitLogEntity({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    this.isCompleted = false,
    this.value = 0.0,
    this.durationMinutes = 0,
    this.notes,
    this.moodBefore,
    this.moodAfter,
    this.customData,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.tags = const [],
    this.weather,
    this.energyLevel,
    this.motivationLevel,
  });

  HabitLogEntity copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? date,
    bool? isCompleted,
    double? value,
    int? durationMinutes,
    String? notes,
    double? moodBefore,
    double? moodAfter,
    String? customData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    List<String>? tags,
    String? weather,
    int? energyLevel,
    int? motivationLevel,
  }) {
    return HabitLogEntity(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      value: value ?? this.value,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      customData: customData ?? this.customData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      weather: weather ?? this.weather,
      energyLevel: energyLevel ?? this.energyLevel,
      motivationLevel: motivationLevel ?? this.motivationLevel,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        date,
        isCompleted,
        value,
        durationMinutes,
        notes,
        moodBefore,
        moodAfter,
        customData,
        createdAt,
        updatedAt,
        location,
        tags,
        weather,
        energyLevel,
        motivationLevel,
      ];
}
