import 'package:equatable/equatable.dart';

class SleepSessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime bedtime;
  final DateTime? sleepTime; // When actually fell asleep
  final DateTime? wakeTime; // When actually woke up
  final DateTime? getUpTime; // When got out of bed
  final int totalMinutesInBed;
  final int actualSleepMinutes;
  final double sleepEfficiency; // Percentage of time in bed actually asleep
  
  // Sleep quality metrics
  final double overallQualityScore; // 1-10 scale
  final int deepSleepMinutes;
  final int remSleepMinutes;
  final int lightSleepMinutes;
  final int awakeMinutes;
  final List<SleepPhaseEntity> sleepPhases;
  
  // Sleep tracking
  final String trackingMethod; // manual, smartwatch, phone, sleep_tracker
  final Map<String, dynamic>? deviceData;
  final int restlessnessScore; // 1-10 scale
  final int snoreEvents;
  final List<DisturbanceEntity> disturbances;
  
  // Environment
  final double? roomTemperature;
  final int? lightLevel; // Lux or 1-10 scale
  final int? noiseLevel; // Decibels or 1-10 scale
  final String? weather;
  final String? sleepEnvironment; // bedroom, hotel, travel, etc.
  
  // Pre-sleep routine
  final List<String> bedtimeRoutineActivities;
  final int screenTimeBeforeBed; // Minutes of screen time before bed
  final String? lastMeal; // Time of last meal
  final String? lastCaffeine; // Time of last caffeine
  final String? lastAlcohol; // Time of last alcohol
  final List<String> supplements; // Melatonin, etc.
  
  // Sleep aids
  final List<String> sleepAids; // white_noise, earplugs, eye_mask, etc.
  final String? playedSounds; // ID of sleep sounds played
  final bool usedSmartAlarm;
  final DateTime? smartAlarmWindow; // Wake up window start time
  
  // Mood and energy
  final int? moodBeforeSleep; // 1-5 scale
  final int? energyLevelBeforeSleep; // 1-5 scale
  final int? moodAfterWaking; // 1-5 scale
  final int? energyLevelAfterWaking; // 1-5 scale
  final String? sleepDreams; // Description of dreams
  
  // Lucid dreaming
  final bool attemptedLucidDreaming;
  final bool hadLucidDream;
  final String? lucidDreamTechnique;
  final String? dreamJournal;
  
  // Health integration
  final int? heartRateAvg;
  final int? heartRateVariability;
  final double? bodyTemperature;
  final int? respiratoryRate;
  final Map<String, dynamic>? healthMetrics;
  
  // Goals and targets
  final Duration? targetSleepDuration;
  final DateTime? targetBedtime;
  final DateTime? targetWakeTime;
  final bool metSleepGoal;
  
  // Notes and tags
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SleepSessionEntity({
    required this.id,
    required this.userId,
    required this.bedtime,
    this.sleepTime,
    this.wakeTime,
    this.getUpTime,
    this.totalMinutesInBed = 0,
    this.actualSleepMinutes = 0,
    this.sleepEfficiency = 0.0,
    this.overallQualityScore = 0.0,
    this.deepSleepMinutes = 0,
    this.remSleepMinutes = 0,
    this.lightSleepMinutes = 0,
    this.awakeMinutes = 0,
    this.sleepPhases = const [],
    this.trackingMethod = 'manual',
    this.deviceData,
    this.restlessnessScore = 0,
    this.snoreEvents = 0,
    this.disturbances = const [],
    this.roomTemperature,
    this.lightLevel,
    this.noiseLevel,
    this.weather,
    this.sleepEnvironment,
    this.bedtimeRoutineActivities = const [],
    this.screenTimeBeforeBed = 0,
    this.lastMeal,
    this.lastCaffeine,
    this.lastAlcohol,
    this.supplements = const [],
    this.sleepAids = const [],
    this.playedSounds,
    this.usedSmartAlarm = false,
    this.smartAlarmWindow,
    this.moodBeforeSleep,
    this.energyLevelBeforeSleep,
    this.moodAfterWaking,
    this.energyLevelAfterWaking,
    this.sleepDreams,
    this.attemptedLucidDreaming = false,
    this.hadLucidDream = false,
    this.lucidDreamTechnique,
    this.dreamJournal,
    this.heartRateAvg,
    this.heartRateVariability,
    this.bodyTemperature,
    this.respiratoryRate,
    this.healthMetrics,
    this.targetSleepDuration,
    this.targetBedtime,
    this.targetWakeTime,
    this.metSleepGoal = false,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Duration get timeInBed {
    if (getUpTime != null) {
      return getUpTime!.difference(bedtime);
    } else if (wakeTime != null) {
      return wakeTime!.difference(bedtime);
    }
    return Duration.zero;
  }

  Duration get actualSleepDuration {
    return Duration(minutes: actualSleepMinutes);
  }

  bool get isCompleteSession {
    return sleepTime != null && wakeTime != null;
  }

  String get sleepQualityRating {
    if (overallQualityScore >= 8.0) return 'Excellent';
    if (overallQualityScore >= 6.5) return 'Good';
    if (overallQualityScore >= 5.0) return 'Fair';
    if (overallQualityScore >= 3.0) return 'Poor';
    return 'Very Poor';
  }

  SleepSessionEntity copyWith({
    String? id,
    String? userId,
    DateTime? bedtime,
    DateTime? sleepTime,
    DateTime? wakeTime,
    DateTime? getUpTime,
    int? totalMinutesInBed,
    int? actualSleepMinutes,
    double? sleepEfficiency,
    double? overallQualityScore,
    int? deepSleepMinutes,
    int? remSleepMinutes,
    int? lightSleepMinutes,
    int? awakeMinutes,
    List<SleepPhaseEntity>? sleepPhases,
    String? trackingMethod,
    Map<String, dynamic>? deviceData,
    int? restlessnessScore,
    int? snoreEvents,
    List<DisturbanceEntity>? disturbances,
    double? roomTemperature,
    int? lightLevel,
    int? noiseLevel,
    String? weather,
    String? sleepEnvironment,
    List<String>? bedtimeRoutineActivities,
    int? screenTimeBeforeBed,
    String? lastMeal,
    String? lastCaffeine,
    String? lastAlcohol,
    List<String>? supplements,
    List<String>? sleepAids,
    String? playedSounds,
    bool? usedSmartAlarm,
    DateTime? smartAlarmWindow,
    int? moodBeforeSleep,
    int? energyLevelBeforeSleep,
    int? moodAfterWaking,
    int? energyLevelAfterWaking,
    String? sleepDreams,
    bool? attemptedLucidDreaming,
    bool? hadLucidDream,
    String? lucidDreamTechnique,
    String? dreamJournal,
    int? heartRateAvg,
    int? heartRateVariability,
    double? bodyTemperature,
    int? respiratoryRate,
    Map<String, dynamic>? healthMetrics,
    Duration? targetSleepDuration,
    DateTime? targetBedtime,
    DateTime? targetWakeTime,
    bool? metSleepGoal,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bedtime: bedtime ?? this.bedtime,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      getUpTime: getUpTime ?? this.getUpTime,
      totalMinutesInBed: totalMinutesInBed ?? this.totalMinutesInBed,
      actualSleepMinutes: actualSleepMinutes ?? this.actualSleepMinutes,
      sleepEfficiency: sleepEfficiency ?? this.sleepEfficiency,
      overallQualityScore: overallQualityScore ?? this.overallQualityScore,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
      lightSleepMinutes: lightSleepMinutes ?? this.lightSleepMinutes,
      awakeMinutes: awakeMinutes ?? this.awakeMinutes,
      sleepPhases: sleepPhases ?? this.sleepPhases,
      trackingMethod: trackingMethod ?? this.trackingMethod,
      deviceData: deviceData ?? this.deviceData,
      restlessnessScore: restlessnessScore ?? this.restlessnessScore,
      snoreEvents: snoreEvents ?? this.snoreEvents,
      disturbances: disturbances ?? this.disturbances,
      roomTemperature: roomTemperature ?? this.roomTemperature,
      lightLevel: lightLevel ?? this.lightLevel,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      weather: weather ?? this.weather,
      sleepEnvironment: sleepEnvironment ?? this.sleepEnvironment,
      bedtimeRoutineActivities: bedtimeRoutineActivities ?? this.bedtimeRoutineActivities,
      screenTimeBeforeBed: screenTimeBeforeBed ?? this.screenTimeBeforeBed,
      lastMeal: lastMeal ?? this.lastMeal,
      lastCaffeine: lastCaffeine ?? this.lastCaffeine,
      lastAlcohol: lastAlcohol ?? this.lastAlcohol,
      supplements: supplements ?? this.supplements,
      sleepAids: sleepAids ?? this.sleepAids,
      playedSounds: playedSounds ?? this.playedSounds,
      usedSmartAlarm: usedSmartAlarm ?? this.usedSmartAlarm,
      smartAlarmWindow: smartAlarmWindow ?? this.smartAlarmWindow,
      moodBeforeSleep: moodBeforeSleep ?? this.moodBeforeSleep,
      energyLevelBeforeSleep: energyLevelBeforeSleep ?? this.energyLevelBeforeSleep,
      moodAfterWaking: moodAfterWaking ?? this.moodAfterWaking,
      energyLevelAfterWaking: energyLevelAfterWaking ?? this.energyLevelAfterWaking,
      sleepDreams: sleepDreams ?? this.sleepDreams,
      attemptedLucidDreaming: attemptedLucidDreaming ?? this.attemptedLucidDreaming,
      hadLucidDream: hadLucidDream ?? this.hadLucidDream,
      lucidDreamTechnique: lucidDreamTechnique ?? this.lucidDreamTechnique,
      dreamJournal: dreamJournal ?? this.dreamJournal,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateVariability: heartRateVariability ?? this.heartRateVariability,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      healthMetrics: healthMetrics ?? this.healthMetrics,
      targetSleepDuration: targetSleepDuration ?? this.targetSleepDuration,
      targetBedtime: targetBedtime ?? this.targetBedtime,
      targetWakeTime: targetWakeTime ?? this.targetWakeTime,
      metSleepGoal: metSleepGoal ?? this.metSleepGoal,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        bedtime,
        sleepTime,
        wakeTime,
        getUpTime,
        totalMinutesInBed,
        actualSleepMinutes,
        sleepEfficiency,
        overallQualityScore,
        deepSleepMinutes,
        remSleepMinutes,
        lightSleepMinutes,
        awakeMinutes,
        sleepPhases,
        trackingMethod,
        deviceData,
        restlessnessScore,
        snoreEvents,
        disturbances,
        roomTemperature,
        lightLevel,
        noiseLevel,
        weather,
        sleepEnvironment,
        bedtimeRoutineActivities,
        screenTimeBeforeBed,
        lastMeal,
        lastCaffeine,
        lastAlcohol,
        supplements,
        sleepAids,
        playedSounds,
        usedSmartAlarm,
        smartAlarmWindow,
        moodBeforeSleep,
        energyLevelBeforeSleep,
        moodAfterWaking,
        energyLevelAfterWaking,
        sleepDreams,
        attemptedLucidDreaming,
        hadLucidDream,
        lucidDreamTechnique,
        dreamJournal,
        heartRateAvg,
        heartRateVariability,
        bodyTemperature,
        respiratoryRate,
        healthMetrics,
        targetSleepDuration,
        targetBedtime,
        targetWakeTime,
        metSleepGoal,
        notes,
        tags,
        createdAt,
        updatedAt,
      ];
}

class SleepPhaseEntity extends Equatable {
  final String id;
  final String sleepSessionId;
  final String phase; // awake, light, deep, rem
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double confidence; // 0.0 to 1.0 confidence level from tracking device

  const SleepPhaseEntity({
    required this.id,
    required this.sleepSessionId,
    required this.phase,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.confidence = 1.0,
  });

  SleepPhaseEntity copyWith({
    String? id,
    String? sleepSessionId,
    String? phase,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? confidence,
  }) {
    return SleepPhaseEntity(
      id: id ?? this.id,
      sleepSessionId: sleepSessionId ?? this.sleepSessionId,
      phase: phase ?? this.phase,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [id, sleepSessionId, phase, startTime, endTime, durationMinutes, confidence];
}

class DisturbanceEntity extends Equatable {
  final String id;
  final String sleepSessionId;
  final DateTime timestamp;
  final String type; // noise, movement, temperature, light, etc.
  final int intensity; // 1-10 scale
  final int durationSeconds;
  final String? description;
  final String? source; // device, manual, etc.

  const DisturbanceEntity({
    required this.id,
    required this.sleepSessionId,
    required this.timestamp,
    required this.type,
    this.intensity = 1,
    this.durationSeconds = 0,
    this.description,
    this.source,
  });

  DisturbanceEntity copyWith({
    String? id,
    String? sleepSessionId,
    DateTime? timestamp,
    String? type,
    int? intensity,
    int? durationSeconds,
    String? description,
    String? source,
  }) {
    return DisturbanceEntity(
      id: id ?? this.id,
      sleepSessionId: sleepSessionId ?? this.sleepSessionId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      description: description ?? this.description,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [id, sleepSessionId, timestamp, type, intensity, durationSeconds, description, source];
}
