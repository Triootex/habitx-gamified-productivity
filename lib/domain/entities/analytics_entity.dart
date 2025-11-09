import 'package:equatable/equatable.dart';

class AnalyticsEventEntity extends Equatable {
  final String id;
  final String userId;
  final String eventName;
  final String category; // user_action, system_event, performance, error
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String? sessionId;
  final String platform; // ios, android, web
  final String appVersion;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> userContext;
  final String? screenName;
  final Duration? duration;
  final bool isOffline;
  final DateTime? syncedAt;

  const AnalyticsEventEntity({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.category,
    this.properties = const {},
    required this.timestamp,
    this.sessionId,
    required this.platform,
    required this.appVersion,
    this.deviceInfo = const {},
    this.userContext = const {},
    this.screenName,
    this.duration,
    this.isOffline = false,
    this.syncedAt,
  });

  bool get isSynced => syncedAt != null;

  AnalyticsEventEntity copyWith({
    String? id,
    String? userId,
    String? eventName,
    String? category,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
    String? sessionId,
    String? platform,
    String? appVersion,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? userContext,
    String? screenName,
    Duration? duration,
    bool? isOffline,
    DateTime? syncedAt,
  }) {
    return AnalyticsEventEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      category: category ?? this.category,
      properties: properties ?? this.properties,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      userContext: userContext ?? this.userContext,
      screenName: screenName ?? this.screenName,
      duration: duration ?? this.duration,
      isOffline: isOffline ?? this.isOffline,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        eventName,
        category,
        properties,
        timestamp,
        sessionId,
        platform,
        appVersion,
        deviceInfo,
        userContext,
        screenName,
        duration,
        isOffline,
        syncedAt,
      ];
}

class UserAnalyticsEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodType; // daily, weekly, monthly, yearly
  
  // Usage statistics
  final int totalSessions;
  final Duration totalTimeSpent;
  final Duration averageSessionDuration;
  final int daysActive;
  final double retentionRate;
  
  // Feature usage
  final Map<String, int> featureUsage; // feature -> usage count
  final Map<String, Duration> featureTimeSpent;
  final List<String> mostUsedFeatures;
  final List<String> unusedFeatures;
  
  // Productivity metrics
  final int tasksCompleted;
  final int habitsCompleted;
  final int streaksAchieved;
  final int goalsReached;
  final double productivityScore;
  
  // Engagement metrics
  final int totalXpEarned;
  final int achievementsUnlocked;
  final int socialInteractions;
  final double engagementScore;
  
  // Wellness metrics
  final Map<String, double> wellnessScores; // sleep, mood, stress, etc.
  final int meditationSessions;
  final Duration totalMeditationTime;
  final int journalEntries;
  final double overallWellnessScore;
  
  // Learning and growth
  final int lessonsCompleted;
  final int booksRead;
  final int flashcardsStudied;
  final Map<String, double> skillProgress;
  
  // Patterns and insights
  final Map<int, int> hourlyActivity; // hour -> activity count
  final Map<int, int> dailyActivity; // day of week -> activity count
  final List<String> behaviorPatterns;
  final List<String> insights;
  
  final DateTime generatedAt;

  const UserAnalyticsEntity({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.periodType,
    this.totalSessions = 0,
    this.totalTimeSpent = Duration.zero,
    this.averageSessionDuration = Duration.zero,
    this.daysActive = 0,
    this.retentionRate = 0.0,
    this.featureUsage = const {},
    this.featureTimeSpent = const {},
    this.mostUsedFeatures = const [],
    this.unusedFeatures = const [],
    this.tasksCompleted = 0,
    this.habitsCompleted = 0,
    this.streaksAchieved = 0,
    this.goalsReached = 0,
    this.productivityScore = 0.0,
    this.totalXpEarned = 0,
    this.achievementsUnlocked = 0,
    this.socialInteractions = 0,
    this.engagementScore = 0.0,
    this.wellnessScores = const {},
    this.meditationSessions = 0,
    this.totalMeditationTime = Duration.zero,
    this.journalEntries = 0,
    this.overallWellnessScore = 0.0,
    this.lessonsCompleted = 0,
    this.booksRead = 0,
    this.flashcardsStudied = 0,
    this.skillProgress = const {},
    this.hourlyActivity = const {},
    this.dailyActivity = const {},
    this.behaviorPatterns = const [],
    this.insights = const [],
    required this.generatedAt,
  });

  UserAnalyticsEntity copyWith({
    String? id,
    String? userId,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodType,
    int? totalSessions,
    Duration? totalTimeSpent,
    Duration? averageSessionDuration,
    int? daysActive,
    double? retentionRate,
    Map<String, int>? featureUsage,
    Map<String, Duration>? featureTimeSpent,
    List<String>? mostUsedFeatures,
    List<String>? unusedFeatures,
    int? tasksCompleted,
    int? habitsCompleted,
    int? streaksAchieved,
    int? goalsReached,
    double? productivityScore,
    int? totalXpEarned,
    int? achievementsUnlocked,
    int? socialInteractions,
    double? engagementScore,
    Map<String, double>? wellnessScores,
    int? meditationSessions,
    Duration? totalMeditationTime,
    int? journalEntries,
    double? overallWellnessScore,
    int? lessonsCompleted,
    int? booksRead,
    int? flashcardsStudied,
    Map<String, double>? skillProgress,
    Map<int, int>? hourlyActivity,
    Map<int, int>? dailyActivity,
    List<String>? behaviorPatterns,
    List<String>? insights,
    DateTime? generatedAt,
  }) {
    return UserAnalyticsEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      periodType: periodType ?? this.periodType,
      totalSessions: totalSessions ?? this.totalSessions,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      averageSessionDuration: averageSessionDuration ?? this.averageSessionDuration,
      daysActive: daysActive ?? this.daysActive,
      retentionRate: retentionRate ?? this.retentionRate,
      featureUsage: featureUsage ?? this.featureUsage,
      featureTimeSpent: featureTimeSpent ?? this.featureTimeSpent,
      mostUsedFeatures: mostUsedFeatures ?? this.mostUsedFeatures,
      unusedFeatures: unusedFeatures ?? this.unusedFeatures,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      habitsCompleted: habitsCompleted ?? this.habitsCompleted,
      streaksAchieved: streaksAchieved ?? this.streaksAchieved,
      goalsReached: goalsReached ?? this.goalsReached,
      productivityScore: productivityScore ?? this.productivityScore,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      socialInteractions: socialInteractions ?? this.socialInteractions,
      engagementScore: engagementScore ?? this.engagementScore,
      wellnessScores: wellnessScores ?? this.wellnessScores,
      meditationSessions: meditationSessions ?? this.meditationSessions,
      totalMeditationTime: totalMeditationTime ?? this.totalMeditationTime,
      journalEntries: journalEntries ?? this.journalEntries,
      overallWellnessScore: overallWellnessScore ?? this.overallWellnessScore,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      booksRead: booksRead ?? this.booksRead,
      flashcardsStudied: flashcardsStudied ?? this.flashcardsStudied,
      skillProgress: skillProgress ?? this.skillProgress,
      hourlyActivity: hourlyActivity ?? this.hourlyActivity,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      behaviorPatterns: behaviorPatterns ?? this.behaviorPatterns,
      insights: insights ?? this.insights,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        periodStart,
        periodEnd,
        periodType,
        totalSessions,
        totalTimeSpent,
        averageSessionDuration,
        daysActive,
        retentionRate,
        featureUsage,
        featureTimeSpent,
        mostUsedFeatures,
        unusedFeatures,
        tasksCompleted,
        habitsCompleted,
        streaksAchieved,
        goalsReached,
        productivityScore,
        totalXpEarned,
        achievementsUnlocked,
        socialInteractions,
        engagementScore,
        wellnessScores,
        meditationSessions,
        totalMeditationTime,
        journalEntries,
        overallWellnessScore,
        lessonsCompleted,
        booksRead,
        flashcardsStudied,
        skillProgress,
        hourlyActivity,
        dailyActivity,
        behaviorPatterns,
        insights,
        generatedAt,
      ];
}

class AppAnalyticsEntity extends Equatable {
  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodType;
  
  // User metrics
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final int returningUsers;
  final double retentionRate;
  final double churnRate;
  
  // Engagement metrics
  final double averageSessionDuration;
  final int totalSessions;
  final double sessionsPerUser;
  final Map<String, int> featurePopularity;
  final Map<String, double> featureEngagement;
  
  // Revenue metrics
  final double totalRevenue;
  final double averageRevenuePerUser;
  final int totalPurchases;
  final double conversionRate;
  final Map<String, double> revenueByFeature;
  
  // Performance metrics
  final double averageAppRating;
  final int totalCrashes;
  final double crashRate;
  final Map<String, double> performanceMetrics;
  
  // Content metrics
  final int totalContent;
  final Map<String, int> contentByCategory;
  final Map<String, double> contentEngagement;
  
  final DateTime generatedAt;

  const AppAnalyticsEntity({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.periodType,
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.newUsers = 0,
    this.returningUsers = 0,
    this.retentionRate = 0.0,
    this.churnRate = 0.0,
    this.averageSessionDuration = 0.0,
    this.totalSessions = 0,
    this.sessionsPerUser = 0.0,
    this.featurePopularity = const {},
    this.featureEngagement = const {},
    this.totalRevenue = 0.0,
    this.averageRevenuePerUser = 0.0,
    this.totalPurchases = 0,
    this.conversionRate = 0.0,
    this.revenueByFeature = const {},
    this.averageAppRating = 0.0,
    this.totalCrashes = 0,
    this.crashRate = 0.0,
    this.performanceMetrics = const {},
    this.totalContent = 0,
    this.contentByCategory = const {},
    this.contentEngagement = const {},
    required this.generatedAt,
  });

  AppAnalyticsEntity copyWith({
    String? id,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodType,
    int? totalUsers,
    int? activeUsers,
    int? newUsers,
    int? returningUsers,
    double? retentionRate,
    double? churnRate,
    double? averageSessionDuration,
    int? totalSessions,
    double? sessionsPerUser,
    Map<String, int>? featurePopularity,
    Map<String, double>? featureEngagement,
    double? totalRevenue,
    double? averageRevenuePerUser,
    int? totalPurchases,
    double? conversionRate,
    Map<String, double>? revenueByFeature,
    double? averageAppRating,
    int? totalCrashes,
    double? crashRate,
    Map<String, double>? performanceMetrics,
    int? totalContent,
    Map<String, int>? contentByCategory,
    Map<String, double>? contentEngagement,
    DateTime? generatedAt,
  }) {
    return AppAnalyticsEntity(
      id: id ?? this.id,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      periodType: periodType ?? this.periodType,
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      newUsers: newUsers ?? this.newUsers,
      returningUsers: returningUsers ?? this.returningUsers,
      retentionRate: retentionRate ?? this.retentionRate,
      churnRate: churnRate ?? this.churnRate,
      averageSessionDuration: averageSessionDuration ?? this.averageSessionDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      sessionsPerUser: sessionsPerUser ?? this.sessionsPerUser,
      featurePopularity: featurePopularity ?? this.featurePopularity,
      featureEngagement: featureEngagement ?? this.featureEngagement,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageRevenuePerUser: averageRevenuePerUser ?? this.averageRevenuePerUser,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      conversionRate: conversionRate ?? this.conversionRate,
      revenueByFeature: revenueByFeature ?? this.revenueByFeature,
      averageAppRating: averageAppRating ?? this.averageAppRating,
      totalCrashes: totalCrashes ?? this.totalCrashes,
      crashRate: crashRate ?? this.crashRate,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      totalContent: totalContent ?? this.totalContent,
      contentByCategory: contentByCategory ?? this.contentByCategory,
      contentEngagement: contentEngagement ?? this.contentEngagement,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        periodStart,
        periodEnd,
        periodType,
        totalUsers,
        activeUsers,
        newUsers,
        returningUsers,
        retentionRate,
        churnRate,
        averageSessionDuration,
        totalSessions,
        sessionsPerUser,
        featurePopularity,
        featureEngagement,
        totalRevenue,
        averageRevenuePerUser,
        totalPurchases,
        conversionRate,
        revenueByFeature,
        averageAppRating,
        totalCrashes,
        crashRate,
        performanceMetrics,
        totalContent,
        contentByCategory,
        contentEngagement,
        generatedAt,
      ];
}

class SessionTrackingEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String platform;
  final String appVersion;
  final List<String> screensVisited;
  final Map<String, Duration> screenTime;
  final List<String> actionsPerformed;
  final Map<String, int> featureInteractions;
  final bool wasCompleted; // User properly ended session vs crash/force quit
  final String? endReason; // user_action, crash, timeout
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> deviceInfo;

  const SessionTrackingEntity({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.duration = Duration.zero,
    required this.platform,
    required this.appVersion,
    this.screensVisited = const [],
    this.screenTime = const {},
    this.actionsPerformed = const [],
    this.featureInteractions = const {},
    this.wasCompleted = true,
    this.endReason,
    this.sessionData = const {},
    this.deviceInfo = const {},
  });

  bool get isActive => endTime == null;

  SessionTrackingEntity copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? platform,
    String? appVersion,
    List<String>? screensVisited,
    Map<String, Duration>? screenTime,
    List<String>? actionsPerformed,
    Map<String, int>? featureInteractions,
    bool? wasCompleted,
    String? endReason,
    Map<String, dynamic>? sessionData,
    Map<String, dynamic>? deviceInfo,
  }) {
    return SessionTrackingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      screensVisited: screensVisited ?? this.screensVisited,
      screenTime: screenTime ?? this.screenTime,
      actionsPerformed: actionsPerformed ?? this.actionsPerformed,
      featureInteractions: featureInteractions ?? this.featureInteractions,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      endReason: endReason ?? this.endReason,
      sessionData: sessionData ?? this.sessionData,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        startTime,
        endTime,
        duration,
        platform,
        appVersion,
        screensVisited,
        screenTime,
        actionsPerformed,
        featureInteractions,
        wasCompleted,
        endReason,
        sessionData,
        deviceInfo,
      ];
}
