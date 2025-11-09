import 'package:equatable/equatable.dart';

class MeditationSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String technique; // mindfulness, concentration, loving_kindness, etc.
  final String? guidedSessionId; // Reference to guided meditation content
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final bool wasCompleted;
  
  // Quality metrics
  final double qualityScore; // 0-10 calculated score
  final double focusRating; // 1-10 user rating
  final int distractionsCount;
  final List<DistractionLogEntity> distractions;
  final double restlessnessLevel; // 1-10 scale
  
  // Breathing tracking
  final String? breathingPattern; // 4-7-8, box_breathing, etc.
  final int breathingCycles;
  final double avgBreathsPerMinute;
  final List<BreathingDataEntity> breathingData;
  
  // ASMR and sound
  final String? soundscapeId;
  final List<String> activeSounds;
  final Map<String, double> soundVolumes; // Sound ID -> Volume (0-1)
  final bool usedBinauralBeats;
  final String? binauralFrequency;
  
  // Mood and state
  final int? moodBefore; // 1-10 scale
  final int? moodAfter; // 1-10 scale
  final int? stressLevelBefore; // 1-10 scale
  final int? stressLevelAfter; // 1-10 scale
  final int? energyLevelBefore; // 1-10 scale
  final int? energyLevelAfter; // 1-10 scale
  final List<String> emotionsBefore;
  final List<String> emotionsAfter;
  
  // Environment
  final String? location; // home, office, park, etc.
  final String? posture; // sitting, lying, walking
  final bool usedTimer;
  final bool usedQuietMode;
  final int? ambientNoiseLevel; // 1-10 scale
  
  // Teacher/Guide
  final String? teacherName;
  final String? teacherVoice; // male, female, neutral
  final String? language;
  final bool usedSubtitles;
  
  // Progress and achievements
  final int xpEarned;
  final List<String> achievementsUnlocked;
  final bool isPersonalBest; // Duration, quality, etc.
  final Map<String, dynamic> progressMetrics;
  
  // Notes and insights
  final String? sessionNotes;
  final String? insights;
  final List<String> tags;
  final double? painLevel; // Before/after for therapeutic meditation
  
  // Integration data
  final Map<String, dynamic>? healthData; // Heart rate, HRV, etc.
  final String? deviceUsed; // phone, smartwatch, meditation_device
  final bool syncedWithWearable;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MeditationSessionEntity({
    required this.id,
    required this.userId,
    required this.technique,
    this.guidedSessionId,
    required this.startTime,
    this.endTime,
    this.plannedDurationMinutes = 10,
    this.actualDurationMinutes = 0,
    this.wasCompleted = false,
    this.qualityScore = 0.0,
    this.focusRating = 5.0,
    this.distractionsCount = 0,
    this.distractions = const [],
    this.restlessnessLevel = 1.0,
    this.breathingPattern,
    this.breathingCycles = 0,
    this.avgBreathsPerMinute = 0.0,
    this.breathingData = const [],
    this.soundscapeId,
    this.activeSounds = const [],
    this.soundVolumes = const {},
    this.usedBinauralBeats = false,
    this.binauralFrequency,
    this.moodBefore,
    this.moodAfter,
    this.stressLevelBefore,
    this.stressLevelAfter,
    this.energyLevelBefore,
    this.energyLevelAfter,
    this.emotionsBefore = const [],
    this.emotionsAfter = const [],
    this.location,
    this.posture,
    this.usedTimer = false,
    this.usedQuietMode = false,
    this.ambientNoiseLevel,
    this.teacherName,
    this.teacherVoice,
    this.language,
    this.usedSubtitles = false,
    this.xpEarned = 0,
    this.achievementsUnlocked = const [],
    this.isPersonalBest = false,
    this.progressMetrics = const {},
    this.sessionNotes,
    this.insights,
    this.tags = const [],
    this.painLevel,
    this.healthData,
    this.deviceUsed,
    this.syncedWithWearable = false,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => endTime == null;
  
  Duration get actualDuration => Duration(minutes: actualDurationMinutes);
  
  Duration get plannedDuration => Duration(minutes: plannedDurationMinutes);
  
  double get completionPercentage {
    if (plannedDurationMinutes == 0) return 0.0;
    return (actualDurationMinutes / plannedDurationMinutes).clamp(0.0, 1.0);
  }
  
  double get moodImprovement {
    if (moodBefore == null || moodAfter == null) return 0.0;
    return moodAfter! - moodBefore!;
  }
  
  double get stressReduction {
    if (stressLevelBefore == null || stressLevelAfter == null) return 0.0;
    return stressLevelBefore! - stressLevelAfter!;
  }

  MeditationSessionEntity copyWith({
    String? id,
    String? userId,
    String? technique,
    String? guidedSessionId,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    bool? wasCompleted,
    double? qualityScore,
    double? focusRating,
    int? distractionsCount,
    List<DistractionLogEntity>? distractions,
    double? restlessnessLevel,
    String? breathingPattern,
    int? breathingCycles,
    double? avgBreathsPerMinute,
    List<BreathingDataEntity>? breathingData,
    String? soundscapeId,
    List<String>? activeSounds,
    Map<String, double>? soundVolumes,
    bool? usedBinauralBeats,
    String? binauralFrequency,
    int? moodBefore,
    int? moodAfter,
    int? stressLevelBefore,
    int? stressLevelAfter,
    int? energyLevelBefore,
    int? energyLevelAfter,
    List<String>? emotionsBefore,
    List<String>? emotionsAfter,
    String? location,
    String? posture,
    bool? usedTimer,
    bool? usedQuietMode,
    int? ambientNoiseLevel,
    String? teacherName,
    String? teacherVoice,
    String? language,
    bool? usedSubtitles,
    int? xpEarned,
    List<String>? achievementsUnlocked,
    bool? isPersonalBest,
    Map<String, dynamic>? progressMetrics,
    String? sessionNotes,
    String? insights,
    List<String>? tags,
    double? painLevel,
    Map<String, dynamic>? healthData,
    String? deviceUsed,
    bool? syncedWithWearable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeditationSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      technique: technique ?? this.technique,
      guidedSessionId: guidedSessionId ?? this.guidedSessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      qualityScore: qualityScore ?? this.qualityScore,
      focusRating: focusRating ?? this.focusRating,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      distractions: distractions ?? this.distractions,
      restlessnessLevel: restlessnessLevel ?? this.restlessnessLevel,
      breathingPattern: breathingPattern ?? this.breathingPattern,
      breathingCycles: breathingCycles ?? this.breathingCycles,
      avgBreathsPerMinute: avgBreathsPerMinute ?? this.avgBreathsPerMinute,
      breathingData: breathingData ?? this.breathingData,
      soundscapeId: soundscapeId ?? this.soundscapeId,
      activeSounds: activeSounds ?? this.activeSounds,
      soundVolumes: soundVolumes ?? this.soundVolumes,
      usedBinauralBeats: usedBinauralBeats ?? this.usedBinauralBeats,
      binauralFrequency: binauralFrequency ?? this.binauralFrequency,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      stressLevelBefore: stressLevelBefore ?? this.stressLevelBefore,
      stressLevelAfter: stressLevelAfter ?? this.stressLevelAfter,
      energyLevelBefore: energyLevelBefore ?? this.energyLevelBefore,
      energyLevelAfter: energyLevelAfter ?? this.energyLevelAfter,
      emotionsBefore: emotionsBefore ?? this.emotionsBefore,
      emotionsAfter: emotionsAfter ?? this.emotionsAfter,
      location: location ?? this.location,
      posture: posture ?? this.posture,
      usedTimer: usedTimer ?? this.usedTimer,
      usedQuietMode: usedQuietMode ?? this.usedQuietMode,
      ambientNoiseLevel: ambientNoiseLevel ?? this.ambientNoiseLevel,
      teacherName: teacherName ?? this.teacherName,
      teacherVoice: teacherVoice ?? this.teacherVoice,
      language: language ?? this.language,
      usedSubtitles: usedSubtitles ?? this.usedSubtitles,
      xpEarned: xpEarned ?? this.xpEarned,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      isPersonalBest: isPersonalBest ?? this.isPersonalBest,
      progressMetrics: progressMetrics ?? this.progressMetrics,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      insights: insights ?? this.insights,
      tags: tags ?? this.tags,
      painLevel: painLevel ?? this.painLevel,
      healthData: healthData ?? this.healthData,
      deviceUsed: deviceUsed ?? this.deviceUsed,
      syncedWithWearable: syncedWithWearable ?? this.syncedWithWearable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        technique,
        guidedSessionId,
        startTime,
        endTime,
        plannedDurationMinutes,
        actualDurationMinutes,
        wasCompleted,
        qualityScore,
        focusRating,
        distractionsCount,
        distractions,
        restlessnessLevel,
        breathingPattern,
        breathingCycles,
        avgBreathsPerMinute,
        breathingData,
        soundscapeId,
        activeSounds,
        soundVolumes,
        usedBinauralBeats,
        binauralFrequency,
        moodBefore,
        moodAfter,
        stressLevelBefore,
        stressLevelAfter,
        energyLevelBefore,
        energyLevelAfter,
        emotionsBefore,
        emotionsAfter,
        location,
        posture,
        usedTimer,
        usedQuietMode,
        ambientNoiseLevel,
        teacherName,
        teacherVoice,
        language,
        usedSubtitles,
        xpEarned,
        achievementsUnlocked,
        isPersonalBest,
        progressMetrics,
        sessionNotes,
        insights,
        tags,
        painLevel,
        healthData,
        deviceUsed,
        syncedWithWearable,
        createdAt,
        updatedAt,
      ];
}

class DistractionLogEntity extends Equatable {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final String type; // thought, sound, physical, emotion
  final String? description;
  final int intensity; // 1-5 scale
  final int durationSeconds;
  final String? response; // How user handled the distraction

  const DistractionLogEntity({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.type,
    this.description,
    this.intensity = 1,
    this.durationSeconds = 0,
    this.response,
  });

  DistractionLogEntity copyWith({
    String? id,
    String? sessionId,
    DateTime? timestamp,
    String? type,
    String? description,
    int? intensity,
    int? durationSeconds,
    String? response,
  }) {
    return DistractionLogEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [id, sessionId, timestamp, type, description, intensity, durationSeconds, response];
}

class BreathingDataEntity extends Equatable {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final int breathsPerMinute;
  final double breathDepth; // 0-1 scale
  final String phase; // inhale, hold, exhale, pause
  final int cycleDuration; // Total cycle time in seconds

  const BreathingDataEntity({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.breathsPerMinute,
    this.breathDepth = 0.5,
    required this.phase,
    this.cycleDuration = 0,
  });

  BreathingDataEntity copyWith({
    String? id,
    String? sessionId,
    DateTime? timestamp,
    int? breathsPerMinute,
    double? breathDepth,
    String? phase,
    int? cycleDuration,
  }) {
    return BreathingDataEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      breathsPerMinute: breathsPerMinute ?? this.breathsPerMinute,
      breathDepth: breathDepth ?? this.breathDepth,
      phase: phase ?? this.phase,
      cycleDuration: cycleDuration ?? this.cycleDuration,
    );
  }

  @override
  List<Object?> get props => [id, sessionId, timestamp, breathsPerMinute, breathDepth, phase, cycleDuration];
}
