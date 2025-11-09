import 'package:equatable/equatable.dart';

class JournalEntryEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String entryType; // daily, gratitude, reflection, dream, goals, etc.
  final String format; // text, voice, mixed
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Mood and emotional data
  final int? moodRating; // 1-5 scale
  final List<String> emotions;
  final Map<String, int> emotionIntensities;
  final List<String> moodEmojis;
  
  // AI-generated insights
  final List<String> aiPrompts;
  final Map<String, dynamic> aiAnalysis;
  final double? sentimentScore; // -1 to 1
  final String? sentimentLabel; // positive, negative, neutral
  final List<String> keyThemes;
  final List<String> suggestions;
  
  // CBT integration
  final List<CBTActivityEntity> cbtActivities;
  final List<String> cognitiveDistortions;
  final String? thoughtChallenge;
  final String? behavioralExperiment;
  
  // Privacy and sharing
  final String privacy; // private, shared, public
  final List<String> sharedWith;
  final bool allowAnalytics;
  final bool includeInCorrelations;
  
  // Metadata
  final List<String> tags;
  final String? location;
  final String? weather;
  final int wordCount;
  final Duration writingTime;
  final List<String> attachments;
  final String? voiceRecordingUrl;
  
  // Correlations and patterns
  final Map<String, dynamic> correlationData;
  final List<String> linkedEntries;
  final Map<String, dynamic> contextFactors;

  const JournalEntryEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.entryType,
    this.format = 'text',
    required this.timestamp,
    required this.createdAt,
    this.updatedAt,
    this.moodRating,
    this.emotions = const [],
    this.emotionIntensities = const {},
    this.moodEmojis = const [],
    this.aiPrompts = const [],
    this.aiAnalysis = const {},
    this.sentimentScore,
    this.sentimentLabel,
    this.keyThemes = const [],
    this.suggestions = const [],
    this.cbtActivities = const [],
    this.cognitiveDistortions = const [],
    this.thoughtChallenge,
    this.behavioralExperiment,
    this.privacy = 'private',
    this.sharedWith = const [],
    this.allowAnalytics = true,
    this.includeInCorrelations = true,
    this.tags = const [],
    this.location,
    this.weather,
    this.wordCount = 0,
    this.writingTime = Duration.zero,
    this.attachments = const [],
    this.voiceRecordingUrl,
    this.correlationData = const {},
    this.linkedEntries = const [],
    this.contextFactors = const {},
  });

  bool get hasVoiceRecording => voiceRecordingUrl != null;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get isPrivate => privacy == 'private';
  bool get hasCBTActivities => cbtActivities.isNotEmpty;
  bool get hasPositiveSentiment => sentimentScore != null && sentimentScore! > 0.1;

  JournalEntryEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? entryType,
    String? format,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? moodRating,
    List<String>? emotions,
    Map<String, int>? emotionIntensities,
    List<String>? moodEmojis,
    List<String>? aiPrompts,
    Map<String, dynamic>? aiAnalysis,
    double? sentimentScore,
    String? sentimentLabel,
    List<String>? keyThemes,
    List<String>? suggestions,
    List<CBTActivityEntity>? cbtActivities,
    List<String>? cognitiveDistortions,
    String? thoughtChallenge,
    String? behavioralExperiment,
    String? privacy,
    List<String>? sharedWith,
    bool? allowAnalytics,
    bool? includeInCorrelations,
    List<String>? tags,
    String? location,
    String? weather,
    int? wordCount,
    Duration? writingTime,
    List<String>? attachments,
    String? voiceRecordingUrl,
    Map<String, dynamic>? correlationData,
    List<String>? linkedEntries,
    Map<String, dynamic>? contextFactors,
  }) {
    return JournalEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryType: entryType ?? this.entryType,
      format: format ?? this.format,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodRating: moodRating ?? this.moodRating,
      emotions: emotions ?? this.emotions,
      emotionIntensities: emotionIntensities ?? this.emotionIntensities,
      moodEmojis: moodEmojis ?? this.moodEmojis,
      aiPrompts: aiPrompts ?? this.aiPrompts,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      sentimentLabel: sentimentLabel ?? this.sentimentLabel,
      keyThemes: keyThemes ?? this.keyThemes,
      suggestions: suggestions ?? this.suggestions,
      cbtActivities: cbtActivities ?? this.cbtActivities,
      cognitiveDistortions: cognitiveDistortions ?? this.cognitiveDistortions,
      thoughtChallenge: thoughtChallenge ?? this.thoughtChallenge,
      behavioralExperiment: behavioralExperiment ?? this.behavioralExperiment,
      privacy: privacy ?? this.privacy,
      sharedWith: sharedWith ?? this.sharedWith,
      allowAnalytics: allowAnalytics ?? this.allowAnalytics,
      includeInCorrelations: includeInCorrelations ?? this.includeInCorrelations,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      wordCount: wordCount ?? this.wordCount,
      writingTime: writingTime ?? this.writingTime,
      attachments: attachments ?? this.attachments,
      voiceRecordingUrl: voiceRecordingUrl ?? this.voiceRecordingUrl,
      correlationData: correlationData ?? this.correlationData,
      linkedEntries: linkedEntries ?? this.linkedEntries,
      contextFactors: contextFactors ?? this.contextFactors,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        entryType,
        format,
        timestamp,
        createdAt,
        updatedAt,
        moodRating,
        emotions,
        emotionIntensities,
        moodEmojis,
        aiPrompts,
        aiAnalysis,
        sentimentScore,
        sentimentLabel,
        keyThemes,
        suggestions,
        cbtActivities,
        cognitiveDistortions,
        thoughtChallenge,
        behavioralExperiment,
        privacy,
        sharedWith,
        allowAnalytics,
        includeInCorrelations,
        tags,
        location,
        weather,
        wordCount,
        writingTime,
        attachments,
        voiceRecordingUrl,
        correlationData,
        linkedEntries,
        contextFactors,
      ];
}

class CBTActivityEntity extends Equatable {
  final String id;
  final String entryId;
  final String activityType; // thought_record, behavioral_experiment, mood_monitoring
  final String title;
  final Map<String, dynamic> activityData;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> results;

  const CBTActivityEntity({
    required this.id,
    required this.entryId,
    required this.activityType,
    required this.title,
    this.activityData = const {},
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
    this.results = const {},
  });

  CBTActivityEntity copyWith({
    String? id,
    String? entryId,
    String? activityType,
    String? title,
    Map<String, dynamic>? activityData,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    Map<String, dynamic>? results,
  }) {
    return CBTActivityEntity(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      activityData: activityData ?? this.activityData,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entryId,
        activityType,
        title,
        activityData,
        createdAt,
        completedAt,
        isCompleted,
        results,
      ];
}

class JournalPromptEntity extends Equatable {
  final String id;
  final String promptText;
  final String category; // gratitude, reflection, creativity, goals, etc.
  final String type; // ai_generated, curated, user_created
  final List<String> tags;
  final String difficulty; // beginner, intermediate, advanced
  final int estimatedTime; // minutes
  final List<String> followUpQuestions;
  final Map<String, dynamic> customization;
  final bool isPersonalized;
  final Map<String, dynamic> personalizationData;
  final DateTime createdAt;
  final bool isActive;

  const JournalPromptEntity({
    required this.id,
    required this.promptText,
    required this.category,
    this.type = 'curated',
    this.tags = const [],
    this.difficulty = 'intermediate',
    this.estimatedTime = 10,
    this.followUpQuestions = const [],
    this.customization = const {},
    this.isPersonalized = false,
    this.personalizationData = const {},
    required this.createdAt,
    this.isActive = true,
  });

  JournalPromptEntity copyWith({
    String? id,
    String? promptText,
    String? category,
    String? type,
    List<String>? tags,
    String? difficulty,
    int? estimatedTime,
    List<String>? followUpQuestions,
    Map<String, dynamic>? customization,
    bool? isPersonalized,
    Map<String, dynamic>? personalizationData,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return JournalPromptEntity(
      id: id ?? this.id,
      promptText: promptText ?? this.promptText,
      category: category ?? this.category,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      customization: customization ?? this.customization,
      isPersonalized: isPersonalized ?? this.isPersonalized,
      personalizationData: personalizationData ?? this.personalizationData,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        promptText,
        category,
        type,
        tags,
        difficulty,
        estimatedTime,
        followUpQuestions,
        customization,
        isPersonalized,
        personalizationData,
        createdAt,
        isActive,
      ];
}

class JournalThemeEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String colorScheme;
  final String fontFamily;
  final double fontSize;
  final Map<String, String> colors;
  final Map<String, dynamic> customStyles;
  final bool isDefault;
  final bool isCustom;
  final String? backgroundImage;
  final DateTime createdAt;

  const JournalThemeEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.colorScheme,
    this.fontFamily = 'System',
    this.fontSize = 16.0,
    this.colors = const {},
    this.customStyles = const {},
    this.isDefault = false,
    this.isCustom = false,
    this.backgroundImage,
    required this.createdAt,
  });

  JournalThemeEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? colorScheme,
    String? fontFamily,
    double? fontSize,
    Map<String, String>? colors,
    Map<String, dynamic>? customStyles,
    bool? isDefault,
    bool? isCustom,
    String? backgroundImage,
    DateTime? createdAt,
  }) {
    return JournalThemeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      colorScheme: colorScheme ?? this.colorScheme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      colors: colors ?? this.colors,
      customStyles: customStyles ?? this.customStyles,
      isDefault: isDefault ?? this.isDefault,
      isCustom: isCustom ?? this.isCustom,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        colorScheme,
        fontFamily,
        fontSize,
        colors,
        customStyles,
        isDefault,
        isCustom,
        backgroundImage,
        createdAt,
      ];
}

class JournalReminderEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? message;
  final DateTime scheduledTime;
  final List<int> daysOfWeek; // 1=Monday, 7=Sunday
  final bool isActive;
  final bool isRecurring;
  final String frequency; // daily, weekly, custom
  final String entryType; // Which type of journal entry to suggest
  final List<String> suggestedPrompts;
  final Map<String, dynamic> customization;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const JournalReminderEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.message,
    required this.scheduledTime,
    this.daysOfWeek = const [],
    this.isActive = true,
    this.isRecurring = false,
    this.frequency = 'daily',
    this.entryType = 'daily',
    this.suggestedPrompts = const [],
    this.customization = const {},
    required this.createdAt,
    this.lastTriggered,
  });

  bool get shouldTriggerToday {
    final today = DateTime.now().weekday;
    return daysOfWeek.isEmpty || daysOfWeek.contains(today);
  }

  JournalReminderEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? scheduledTime,
    List<int>? daysOfWeek,
    bool? isActive,
    bool? isRecurring,
    String? frequency,
    String? entryType,
    List<String>? suggestedPrompts,
    Map<String, dynamic>? customization,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return JournalReminderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      entryType: entryType ?? this.entryType,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
      customization: customization ?? this.customization,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        scheduledTime,
        daysOfWeek,
        isActive,
        isRecurring,
        frequency,
        entryType,
        suggestedPrompts,
        customization,
        createdAt,
        lastTriggered,
      ];
}

class JournalAnalyticsEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodType; // daily, weekly, monthly, yearly
  
  // Writing statistics
  final int totalEntries;
  final int totalWords;
  final Duration totalWritingTime;
  final double averageEntryLength;
  final double averageWritingTime;
  final int currentStreak;
  final int longestStreak;
  
  // Mood and sentiment analysis
  final Map<String, int> moodDistribution;
  final Map<String, int> emotionFrequency;
  final double averageMoodRating;
  final double averageSentimentScore;
  final List<String> topThemes;
  final Map<String, double> sentimentTrends;
  
  // Patterns and insights
  final Map<String, int> entryTypeFrequency;
  final Map<int, int> writingTimeDistribution; // Hour -> Count
  final List<String> correlationInsights;
  final List<String> personalizedSuggestions;
  final Map<String, dynamic> behaviorPatterns;
  
  // Progress tracking
  final Map<String, double> improvementMetrics;
  final List<String> achievements;
  final Map<String, DateTime> milestones;
  
  final DateTime generatedAt;

  const JournalAnalyticsEntity({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.periodType,
    this.totalEntries = 0,
    this.totalWords = 0,
    this.totalWritingTime = Duration.zero,
    this.averageEntryLength = 0.0,
    this.averageWritingTime = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.moodDistribution = const {},
    this.emotionFrequency = const {},
    this.averageMoodRating = 0.0,
    this.averageSentimentScore = 0.0,
    this.topThemes = const [],
    this.sentimentTrends = const {},
    this.entryTypeFrequency = const {},
    this.writingTimeDistribution = const {},
    this.correlationInsights = const [],
    this.personalizedSuggestions = const [],
    this.behaviorPatterns = const {},
    this.improvementMetrics = const {},
    this.achievements = const [],
    this.milestones = const {},
    required this.generatedAt,
  });

  JournalAnalyticsEntity copyWith({
    String? id,
    String? userId,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodType,
    int? totalEntries,
    int? totalWords,
    Duration? totalWritingTime,
    double? averageEntryLength,
    double? averageWritingTime,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? moodDistribution,
    Map<String, int>? emotionFrequency,
    double? averageMoodRating,
    double? averageSentimentScore,
    List<String>? topThemes,
    Map<String, double>? sentimentTrends,
    Map<String, int>? entryTypeFrequency,
    Map<int, int>? writingTimeDistribution,
    List<String>? correlationInsights,
    List<String>? personalizedSuggestions,
    Map<String, dynamic>? behaviorPatterns,
    Map<String, double>? improvementMetrics,
    List<String>? achievements,
    Map<String, DateTime>? milestones,
    DateTime? generatedAt,
  }) {
    return JournalAnalyticsEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      periodType: periodType ?? this.periodType,
      totalEntries: totalEntries ?? this.totalEntries,
      totalWords: totalWords ?? this.totalWords,
      totalWritingTime: totalWritingTime ?? this.totalWritingTime,
      averageEntryLength: averageEntryLength ?? this.averageEntryLength,
      averageWritingTime: averageWritingTime ?? this.averageWritingTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      emotionFrequency: emotionFrequency ?? this.emotionFrequency,
      averageMoodRating: averageMoodRating ?? this.averageMoodRating,
      averageSentimentScore: averageSentimentScore ?? this.averageSentimentScore,
      topThemes: topThemes ?? this.topThemes,
      sentimentTrends: sentimentTrends ?? this.sentimentTrends,
      entryTypeFrequency: entryTypeFrequency ?? this.entryTypeFrequency,
      writingTimeDistribution: writingTimeDistribution ?? this.writingTimeDistribution,
      correlationInsights: correlationInsights ?? this.correlationInsights,
      personalizedSuggestions: personalizedSuggestions ?? this.personalizedSuggestions,
      behaviorPatterns: behaviorPatterns ?? this.behaviorPatterns,
      improvementMetrics: improvementMetrics ?? this.improvementMetrics,
      achievements: achievements ?? this.achievements,
      milestones: milestones ?? this.milestones,
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
        totalEntries,
        totalWords,
        totalWritingTime,
        averageEntryLength,
        averageWritingTime,
        currentStreak,
        longestStreak,
        moodDistribution,
        emotionFrequency,
        averageMoodRating,
        averageSentimentScore,
        topThemes,
        sentimentTrends,
        entryTypeFrequency,
        writingTimeDistribution,
        correlationInsights,
        personalizedSuggestions,
        behaviorPatterns,
        improvementMetrics,
        achievements,
        milestones,
        generatedAt,
      ];
}
