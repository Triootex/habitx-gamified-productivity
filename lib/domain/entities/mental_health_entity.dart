import 'package:equatable/equatable.dart';

class MentalHealthEntryEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int currentMood; // 1-10 scale
  final List<String> emotions;
  final int stressLevel; // 1-10 scale
  final int anxietyLevel; // 1-10 scale
  final int energyLevel; // 1-10 scale
  final int sleepQuality; // 1-10 scale
  
  // Detailed tracking
  final List<String> triggers;
  final List<String> copingStrategies;
  final String? notes;
  final List<String> activities;
  final int socialInteraction; // 1-10 scale
  final int physicalActivity; // 1-10 scale
  
  // Context
  final String? location;
  final String? weather;
  final List<String> tags;
  
  // CBT integration
  final List<CBTThoughtRecordEntity> thoughtRecords;
  final List<String> behavioralExperiments;
  final Map<String, int> moodRatings;
  
  // Crisis support
  final int riskLevel; // 1-5 scale
  final bool needsSupport;
  final List<String> supportContacts;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MentalHealthEntryEntity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.currentMood,
    this.emotions = const [],
    this.stressLevel = 5,
    this.anxietyLevel = 5,
    this.energyLevel = 5,
    this.sleepQuality = 5,
    this.triggers = const [],
    this.copingStrategies = const [],
    this.notes,
    this.activities = const [],
    this.socialInteraction = 5,
    this.physicalActivity = 5,
    this.location,
    this.weather,
    this.tags = const [],
    this.thoughtRecords = const [],
    this.behavioralExperiments = const [],
    this.moodRatings = const {},
    this.riskLevel = 1,
    this.needsSupport = false,
    this.supportContacts = const [],
    required this.createdAt,
    this.updatedAt,
  });

  MentalHealthEntryEntity copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    int? currentMood,
    List<String>? emotions,
    int? stressLevel,
    int? anxietyLevel,
    int? energyLevel,
    int? sleepQuality,
    List<String>? triggers,
    List<String>? copingStrategies,
    String? notes,
    List<String>? activities,
    int? socialInteraction,
    int? physicalActivity,
    String? location,
    String? weather,
    List<String>? tags,
    List<CBTThoughtRecordEntity>? thoughtRecords,
    List<String>? behavioralExperiments,
    Map<String, int>? moodRatings,
    int? riskLevel,
    bool? needsSupport,
    List<String>? supportContacts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MentalHealthEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      currentMood: currentMood ?? this.currentMood,
      emotions: emotions ?? this.emotions,
      stressLevel: stressLevel ?? this.stressLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      triggers: triggers ?? this.triggers,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      socialInteraction: socialInteraction ?? this.socialInteraction,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      tags: tags ?? this.tags,
      thoughtRecords: thoughtRecords ?? this.thoughtRecords,
      behavioralExperiments: behavioralExperiments ?? this.behavioralExperiments,
      moodRatings: moodRatings ?? this.moodRatings,
      riskLevel: riskLevel ?? this.riskLevel,
      needsSupport: needsSupport ?? this.needsSupport,
      supportContacts: supportContacts ?? this.supportContacts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        timestamp,
        currentMood,
        emotions,
        stressLevel,
        anxietyLevel,
        energyLevel,
        sleepQuality,
        triggers,
        copingStrategies,
        notes,
        activities,
        socialInteraction,
        physicalActivity,
        location,
        weather,
        tags,
        thoughtRecords,
        behavioralExperiments,
        moodRatings,
        riskLevel,
        needsSupport,
        supportContacts,
        createdAt,
        updatedAt,
      ];
}

class CBTThoughtRecordEntity extends Equatable {
  final String id;
  final String entryId;
  final String situation;
  final String automaticThought;
  final int emotionIntensity; // 1-10 scale
  final List<String> cognitiveDistortions;
  final String balancedThought;
  final int newEmotionIntensity; // 1-10 scale
  final List<String> evidenceFor;
  final List<String> evidenceAgainst;
  final String? actionPlan;
  final DateTime createdAt;

  const CBTThoughtRecordEntity({
    required this.id,
    required this.entryId,
    required this.situation,
    required this.automaticThought,
    required this.emotionIntensity,
    this.cognitiveDistortions = const [],
    required this.balancedThought,
    required this.newEmotionIntensity,
    this.evidenceFor = const [],
    this.evidenceAgainst = const [],
    this.actionPlan,
    required this.createdAt,
  });

  CBTThoughtRecordEntity copyWith({
    String? id,
    String? entryId,
    String? situation,
    String? automaticThought,
    int? emotionIntensity,
    List<String>? cognitiveDistortions,
    String? balancedThought,
    int? newEmotionIntensity,
    List<String>? evidenceFor,
    List<String>? evidenceAgainst,
    String? actionPlan,
    DateTime? createdAt,
  }) {
    return CBTThoughtRecordEntity(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      situation: situation ?? this.situation,
      automaticThought: automaticThought ?? this.automaticThought,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      cognitiveDistortions: cognitiveDistortions ?? this.cognitiveDistortions,
      balancedThought: balancedThought ?? this.balancedThought,
      newEmotionIntensity: newEmotionIntensity ?? this.newEmotionIntensity,
      evidenceFor: evidenceFor ?? this.evidenceFor,
      evidenceAgainst: evidenceAgainst ?? this.evidenceAgainst,
      actionPlan: actionPlan ?? this.actionPlan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entryId,
        situation,
        automaticThought,
        emotionIntensity,
        cognitiveDistortions,
        balancedThought,
        newEmotionIntensity,
        evidenceFor,
        evidenceAgainst,
        actionPlan,
        createdAt,
      ];
}

class MentalHealthAssessmentEntity extends Equatable {
  final String id;
  final String userId;
  final String assessmentType; // PHQ-9, GAD-7, PSS-10, etc.
  final Map<String, int> responses; // Question ID -> Response
  final int totalScore;
  final String severity; // minimal, mild, moderate, severe
  final List<String> recommendations;
  final DateTime takenAt;
  final DateTime? nextAssessmentDue;
  final Map<String, dynamic> metadata;

  const MentalHealthAssessmentEntity({
    required this.id,
    required this.userId,
    required this.assessmentType,
    required this.responses,
    required this.totalScore,
    required this.severity,
    this.recommendations = const [],
    required this.takenAt,
    this.nextAssessmentDue,
    this.metadata = const {},
  });

  MentalHealthAssessmentEntity copyWith({
    String? id,
    String? userId,
    String? assessmentType,
    Map<String, int>? responses,
    int? totalScore,
    String? severity,
    List<String>? recommendations,
    DateTime? takenAt,
    DateTime? nextAssessmentDue,
    Map<String, dynamic>? metadata,
  }) {
    return MentalHealthAssessmentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assessmentType: assessmentType ?? this.assessmentType,
      responses: responses ?? this.responses,
      totalScore: totalScore ?? this.totalScore,
      severity: severity ?? this.severity,
      recommendations: recommendations ?? this.recommendations,
      takenAt: takenAt ?? this.takenAt,
      nextAssessmentDue: nextAssessmentDue ?? this.nextAssessmentDue,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        assessmentType,
        responses,
        totalScore,
        severity,
        recommendations,
        takenAt,
        nextAssessmentDue,
        metadata,
      ];
}

class TherapySessionEntity extends Equatable {
  final String id;
  final String userId;
  final String? therapistId;
  final String sessionType; // individual, group, virtual, etc.
  final DateTime scheduledTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int plannedDurationMinutes;
  final int? actualDurationMinutes;
  final String status; // scheduled, completed, cancelled, no_show
  
  // Session content
  final List<String> topicsDiscussed;
  final List<String> homeworkAssigned;
  final String? sessionNotes;
  final int? sessionRating; // 1-10 scale
  final String? mood; // before session
  final String? moodAfter;
  
  // Progress tracking
  final List<String> goalsWorkedOn;
  final Map<String, int> progressRatings;
  final List<String> breakthroughs;
  final List<String> challenges;
  
  // Follow-up
  final DateTime? nextSessionScheduled;
  final List<String> actionItems;
  final String? therapistFeedback;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TherapySessionEntity({
    required this.id,
    required this.userId,
    this.therapistId,
    this.sessionType = 'individual',
    required this.scheduledTime,
    this.actualStartTime,
    this.actualEndTime,
    this.plannedDurationMinutes = 60,
    this.actualDurationMinutes,
    this.status = 'scheduled',
    this.topicsDiscussed = const [],
    this.homeworkAssigned = const [],
    this.sessionNotes,
    this.sessionRating,
    this.mood,
    this.moodAfter,
    this.goalsWorkedOn = const [],
    this.progressRatings = const {},
    this.breakthroughs = const [],
    this.challenges = const [],
    this.nextSessionScheduled,
    this.actionItems = const [],
    this.therapistFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get wasAttended => actualStartTime != null;

  TherapySessionEntity copyWith({
    String? id,
    String? userId,
    String? therapistId,
    String? sessionType,
    DateTime? scheduledTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    String? status,
    List<String>? topicsDiscussed,
    List<String>? homeworkAssigned,
    String? sessionNotes,
    int? sessionRating,
    String? mood,
    String? moodAfter,
    List<String>? goalsWorkedOn,
    Map<String, int>? progressRatings,
    List<String>? breakthroughs,
    List<String>? challenges,
    DateTime? nextSessionScheduled,
    List<String>? actionItems,
    String? therapistFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TherapySessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      therapistId: therapistId ?? this.therapistId,
      sessionType: sessionType ?? this.sessionType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      status: status ?? this.status,
      topicsDiscussed: topicsDiscussed ?? this.topicsDiscussed,
      homeworkAssigned: homeworkAssigned ?? this.homeworkAssigned,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      sessionRating: sessionRating ?? this.sessionRating,
      mood: mood ?? this.mood,
      moodAfter: moodAfter ?? this.moodAfter,
      goalsWorkedOn: goalsWorkedOn ?? this.goalsWorkedOn,
      progressRatings: progressRatings ?? this.progressRatings,
      breakthroughs: breakthroughs ?? this.breakthroughs,
      challenges: challenges ?? this.challenges,
      nextSessionScheduled: nextSessionScheduled ?? this.nextSessionScheduled,
      actionItems: actionItems ?? this.actionItems,
      therapistFeedback: therapistFeedback ?? this.therapistFeedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        therapistId,
        sessionType,
        scheduledTime,
        actualStartTime,
        actualEndTime,
        plannedDurationMinutes,
        actualDurationMinutes,
        status,
        topicsDiscussed,
        homeworkAssigned,
        sessionNotes,
        sessionRating,
        mood,
        moodAfter,
        goalsWorkedOn,
        progressRatings,
        breakthroughs,
        challenges,
        nextSessionScheduled,
        actionItems,
        therapistFeedback,
        createdAt,
        updatedAt,
      ];
}
