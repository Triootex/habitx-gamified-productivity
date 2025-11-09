import 'package:equatable/equatable.dart';

class WorkoutEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category; // strength, cardio, flexibility, sports, etc.
  final String type; // custom, template, guided
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMinutes;
  final int? actualDurationMinutes;
  final bool isCompleted;
  
  // Exercises and sets
  final List<ExerciseSetEntity> exercises;
  final int totalSets;
  final int completedSets;
  
  // Intensity and effort
  final int? perceivedExertion; // 1-10 RPE scale
  final String? intensity; // light, moderate, vigorous
  final int? heartRateAvg;
  final int? heartRateMax;
  final List<HeartRateDataEntity> heartRateData;
  
  // Calories and metrics
  final int? caloriesBurned;
  final double? distance; // in kilometers
  final int? steps;
  final double? totalWeightLifted; // in kg
  final int? totalReps;
  
  // Environment and equipment
  final String? location; // gym, home, outdoor, etc.
  final List<String> equipmentUsed;
  final String? weather; // for outdoor workouts
  final double? temperature;
  
  // Social and sharing
  final bool isPublic;
  final List<String> workoutPartners;
  final String? trainerId;
  final List<String> photos;
  final String? notes;
  
  // Integration data
  final Map<String, dynamic>? wearableData;
  final String? syncSource; // apple_health, google_fit, fitbit, etc.
  final Map<String, dynamic> healthKitData;
  
  // Goals and targets
  final Map<String, dynamic> targets; // Target weight, reps, time, etc.
  final Map<String, dynamic> achievements; // PRs, goals met, etc.
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkoutEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    this.type = 'custom',
    required this.startTime,
    this.endTime,
    this.plannedDurationMinutes = 60,
    this.actualDurationMinutes,
    this.isCompleted = false,
    this.exercises = const [],
    this.totalSets = 0,
    this.completedSets = 0,
    this.perceivedExertion,
    this.intensity,
    this.heartRateAvg,
    this.heartRateMax,
    this.heartRateData = const [],
    this.caloriesBurned,
    this.distance,
    this.steps,
    this.totalWeightLifted,
    this.totalReps,
    this.location,
    this.equipmentUsed = const [],
    this.weather,
    this.temperature,
    this.isPublic = false,
    this.workoutPartners = const [],
    this.trainerId,
    this.photos = const [],
    this.notes,
    this.wearableData,
    this.syncSource,
    this.healthKitData = const {},
    this.targets = const {},
    this.achievements = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => endTime == null && !isCompleted;
  
  Duration get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else if (actualDurationMinutes != null) {
      return Duration(minutes: actualDurationMinutes!);
    }
    return Duration.zero;
  }
  
  double get completionPercentage {
    if (totalSets == 0) return 0.0;
    return completedSets / totalSets;
  }

  WorkoutEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    bool? isCompleted,
    List<ExerciseSetEntity>? exercises,
    int? totalSets,
    int? completedSets,
    int? perceivedExertion,
    String? intensity,
    int? heartRateAvg,
    int? heartRateMax,
    List<HeartRateDataEntity>? heartRateData,
    int? caloriesBurned,
    double? distance,
    int? steps,
    double? totalWeightLifted,
    int? totalReps,
    String? location,
    List<String>? equipmentUsed,
    String? weather,
    double? temperature,
    bool? isPublic,
    List<String>? workoutPartners,
    String? trainerId,
    List<String>? photos,
    String? notes,
    Map<String, dynamic>? wearableData,
    String? syncSource,
    Map<String, dynamic>? healthKitData,
    Map<String, dynamic>? targets,
    Map<String, dynamic>? achievements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      exercises: exercises ?? this.exercises,
      totalSets: totalSets ?? this.totalSets,
      completedSets: completedSets ?? this.completedSets,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      intensity: intensity ?? this.intensity,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      heartRateData: heartRateData ?? this.heartRateData,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distance: distance ?? this.distance,
      steps: steps ?? this.steps,
      totalWeightLifted: totalWeightLifted ?? this.totalWeightLifted,
      totalReps: totalReps ?? this.totalReps,
      location: location ?? this.location,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      isPublic: isPublic ?? this.isPublic,
      workoutPartners: workoutPartners ?? this.workoutPartners,
      trainerId: trainerId ?? this.trainerId,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      wearableData: wearableData ?? this.wearableData,
      syncSource: syncSource ?? this.syncSource,
      healthKitData: healthKitData ?? this.healthKitData,
      targets: targets ?? this.targets,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        startTime,
        endTime,
        plannedDurationMinutes,
        actualDurationMinutes,
        isCompleted,
        exercises,
        totalSets,
        completedSets,
        perceivedExertion,
        intensity,
        heartRateAvg,
        heartRateMax,
        heartRateData,
        caloriesBurned,
        distance,
        steps,
        totalWeightLifted,
        totalReps,
        location,
        equipmentUsed,
        weather,
        temperature,
        isPublic,
        workoutPartners,
        trainerId,
        photos,
        notes,
        wearableData,
        syncSource,
        healthKitData,
        targets,
        achievements,
        createdAt,
        updatedAt,
      ];
}

class ExerciseSetEntity extends Equatable {
  final String id;
  final String workoutId;
  final String exerciseName;
  final String exerciseType; // strength, cardio, flexibility, etc.
  final String category; // push, pull, legs, core, etc.
  final List<String> muscleGroups;
  final int setNumber;
  final int order; // Order within the workout
  
  // Set data
  final int? reps;
  final double? weight; // in kg
  final int? durationSeconds;
  final double? distance; // in km
  final int? restTimeSeconds;
  final bool isCompleted;
  final bool isWarmup;
  final bool isDropSet;
  final bool isSuperSet;
  
  // Performance metrics
  final int? heartRateAvg;
  final int? heartRateMax;
  final int? caloriesBurned;
  final double? pace; // min per km for cardio
  final int? perceivedExertion; // 1-10 RPE
  
  // Equipment and setup
  final List<String> equipment;
  final String? notes;
  final Map<String, dynamic> formCues;
  final List<String> modifications;
  
  // Personal records
  final bool isPersonalRecord;
  final String? prType; // weight, reps, time, distance
  final Map<String, dynamic> previousBest;
  
  final DateTime performedAt;
  final DateTime? updatedAt;

  const ExerciseSetEntity({
    required this.id,
    required this.workoutId,
    required this.exerciseName,
    required this.exerciseType,
    this.category = 'general',
    this.muscleGroups = const [],
    required this.setNumber,
    this.order = 0,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.distance,
    this.restTimeSeconds,
    this.isCompleted = false,
    this.isWarmup = false,
    this.isDropSet = false,
    this.isSuperSet = false,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesBurned,
    this.pace,
    this.perceivedExertion,
    this.equipment = const [],
    this.notes,
    this.formCues = const {},
    this.modifications = const [],
    this.isPersonalRecord = false,
    this.prType,
    this.previousBest = const {},
    required this.performedAt,
    this.updatedAt,
  });

  double? get volume {
    if (reps != null && weight != null) {
      return reps! * weight!;
    }
    return null;
  }

  ExerciseSetEntity copyWith({
    String? id,
    String? workoutId,
    String? exerciseName,
    String? exerciseType,
    String? category,
    List<String>? muscleGroups,
    int? setNumber,
    int? order,
    int? reps,
    double? weight,
    int? durationSeconds,
    double? distance,
    int? restTimeSeconds,
    bool? isCompleted,
    bool? isWarmup,
    bool? isDropSet,
    bool? isSuperSet,
    int? heartRateAvg,
    int? heartRateMax,
    int? caloriesBurned,
    double? pace,
    int? perceivedExertion,
    List<String>? equipment,
    String? notes,
    Map<String, dynamic>? formCues,
    List<String>? modifications,
    bool? isPersonalRecord,
    String? prType,
    Map<String, dynamic>? previousBest,
    DateTime? performedAt,
    DateTime? updatedAt,
  }) {
    return ExerciseSetEntity(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseType: exerciseType ?? this.exerciseType,
      category: category ?? this.category,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      setNumber: setNumber ?? this.setNumber,
      order: order ?? this.order,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distance: distance ?? this.distance,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropSet: isDropSet ?? this.isDropSet,
      isSuperSet: isSuperSet ?? this.isSuperSet,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      pace: pace ?? this.pace,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      formCues: formCues ?? this.formCues,
      modifications: modifications ?? this.modifications,
      isPersonalRecord: isPersonalRecord ?? this.isPersonalRecord,
      prType: prType ?? this.prType,
      previousBest: previousBest ?? this.previousBest,
      performedAt: performedAt ?? this.performedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        exerciseName,
        exerciseType,
        category,
        muscleGroups,
        setNumber,
        order,
        reps,
        weight,
        durationSeconds,
        distance,
        restTimeSeconds,
        isCompleted,
        isWarmup,
        isDropSet,
        isSuperSet,
        heartRateAvg,
        heartRateMax,
        caloriesBurned,
        pace,
        perceivedExertion,
        equipment,
        notes,
        formCues,
        modifications,
        isPersonalRecord,
        prType,
        previousBest,
        performedAt,
        updatedAt,
      ];
}

class HeartRateDataEntity extends Equatable {
  final String id;
  final String workoutId;
  final DateTime timestamp;
  final int heartRate;
  final String? zone; // Zone 1-5 or custom zones
  final String? activity; // What was happening at this moment
  final Map<String, dynamic> metadata;

  const HeartRateDataEntity({
    required this.id,
    required this.workoutId,
    required this.timestamp,
    required this.heartRate,
    this.zone,
    this.activity,
    this.metadata = const {},
  });

  HeartRateDataEntity copyWith({
    String? id,
    String? workoutId,
    DateTime? timestamp,
    int? heartRate,
    String? zone,
    String? activity,
    Map<String, dynamic>? metadata,
  }) {
    return HeartRateDataEntity(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      zone: zone ?? this.zone,
      activity: activity ?? this.activity,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, workoutId, timestamp, heartRate, zone, activity, metadata];
}

class NutritionEntryEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String mealType; // breakfast, lunch, dinner, snack
  final String foodName;
  final String? brand;
  final double quantity;
  final String unit; // grams, cups, pieces, etc.
  
  // Nutritional data per 100g
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;
  
  // Barcode and database info
  final String? barcode;
  final String? databaseId;
  final String? source; // usda, branded, custom, etc.
  final Map<String, dynamic> productInfo;
  
  // User customization
  final String? notes;
  final List<String> tags;
  final String? photo;
  final double? rating; // How much did you enjoy it
  
  // Meal context
  final String? location;
  final bool isHomeMade;
  final String? recipe;
  final List<String> ingredients;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NutritionEntryEntity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mealType,
    required this.foodName,
    this.brand,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.vitamins = const {},
    this.minerals = const {},
    this.barcode,
    this.databaseId,
    this.source,
    this.productInfo = const {},
    this.notes,
    this.tags = const [],
    this.photo,
    this.rating,
    this.location,
    this.isHomeMade = false,
    this.recipe,
    this.ingredients = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate actual nutritional values based on quantity
  double get actualCalories => calories * (quantity / 100);
  double get actualProtein => protein * (quantity / 100);
  double get actualCarbs => carbohydrates * (quantity / 100);
  double get actualFat => fat * (quantity / 100);

  NutritionEntryEntity copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? mealType,
    String? foodName,
    String? brand,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    Map<String, double>? vitamins,
    Map<String, double>? minerals,
    String? barcode,
    String? databaseId,
    String? source,
    Map<String, dynamic>? productInfo,
    String? notes,
    List<String>? tags,
    String? photo,
    double? rating,
    String? location,
    bool? isHomeMade,
    String? recipe,
    List<String>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NutritionEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      vitamins: vitamins ?? this.vitamins,
      minerals: minerals ?? this.minerals,
      barcode: barcode ?? this.barcode,
      databaseId: databaseId ?? this.databaseId,
      source: source ?? this.source,
      productInfo: productInfo ?? this.productInfo,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      photo: photo ?? this.photo,
      rating: rating ?? this.rating,
      location: location ?? this.location,
      isHomeMade: isHomeMade ?? this.isHomeMade,
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        timestamp,
        mealType,
        foodName,
        brand,
        quantity,
        unit,
        calories,
        protein,
        carbohydrates,
        fat,
        fiber,
        sugar,
        sodium,
        vitamins,
        minerals,
        barcode,
        databaseId,
        source,
        productInfo,
        notes,
        tags,
        photo,
        rating,
        location,
        isHomeMade,
        recipe,
        ingredients,
        createdAt,
        updatedAt,
      ];
}

class BiometricDataEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String type; // weight, body_fat, muscle_mass, etc.
  final double value;
  final String unit;
  final String? source; // manual, scale, app, etc.
  final String? notes;
  final Map<String, dynamic> metadata;

  const BiometricDataEntity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.value,
    required this.unit,
    this.source,
    this.notes,
    this.metadata = const {},
  });

  BiometricDataEntity copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? type,
    double? value,
    String? unit,
    String? source,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return BiometricDataEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, userId, timestamp, type, value, unit, source, notes, metadata];
}
