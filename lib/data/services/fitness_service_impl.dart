import 'package:injectable/injectable.dart';
import '../../domain/entities/fitness_entity.dart';
import '../../core/utils/fitness_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class FitnessService {
  Future<WorkoutEntity> createWorkout(String userId, Map<String, dynamic> workoutData);
  Future<WorkoutEntity> startWorkout(String workoutId);
  Future<WorkoutEntity> endWorkout(String workoutId, Map<String, dynamic> completionData);
  Future<List<WorkoutEntity>> getUserWorkouts(String userId, {DateTime? startDate, DateTime? endDate});
  Future<NutritionEntryEntity> logNutrition(String userId, Map<String, dynamic> nutritionData);
  Future<BiometricDataEntity> logBiometrics(String userId, Map<String, dynamic> biometricData);
  Future<Map<String, dynamic>> getFitnessAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> generateWorkoutPlan(String userId, String fitnessGoal);
  Future<Map<String, dynamic>> getNutritionRecommendations(String userId);
  Future<List<String>> scanBarcodeForNutrition(String barcode);
  Future<Map<String, dynamic>> calculateCaloriesBurned(String userId, String activity, int durationMinutes);
}

@LazySingleton(as: FitnessService)
class FitnessServiceImpl implements FitnessService {
  @override
  Future<WorkoutEntity> createWorkout(String userId, Map<String, dynamic> workoutData) async {
    try {
      final now = DateTime.now();
      final workoutId = 'workout_${now.millisecondsSinceEpoch}';
      
      final workout = WorkoutEntity(
        id: workoutId,
        userId: userId,
        name: workoutData['name'] as String,
        workoutType: workoutData['workout_type'] as String? ?? 'strength',
        description: workoutData['description'] as String?,
        exercises: (workoutData['exercises'] as List<dynamic>?)?.cast<String>() ?? [],
        muscleGroups: (workoutData['muscle_groups'] as List<dynamic>?)?.cast<String>() ?? [],
        equipment: (workoutData['equipment'] as List<dynamic>?)?.cast<String>() ?? [],
        difficulty: workoutData['difficulty'] as String? ?? 'intermediate',
        estimatedDurationMinutes: workoutData['estimated_duration'] as int? ?? 30,
        caloriesBurnedEstimate: workoutData['calories_estimate'] as int? ?? 150,
        notes: workoutData['notes'] as String?,
        tags: (workoutData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isCustom: workoutData['is_custom'] as bool? ?? true,
        createdAt: now,
      );
      
      return workout;
    } catch (e) {
      throw Exception('Failed to create workout: ${e.toString()}');
    }
  }

  @override
  Future<WorkoutEntity> startWorkout(String workoutId) async {
    try {
      final workout = await _getWorkoutById(workoutId);
      if (workout == null) {
        throw Exception('Workout not found');
      }
      
      final now = DateTime.now();
      return workout.copyWith(
        status: 'in_progress',
        startTime: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to start workout: ${e.toString()}');
    }
  }

  @override
  Future<WorkoutEntity> endWorkout(String workoutId, Map<String, dynamic> completionData) async {
    try {
      final workout = await _getWorkoutById(workoutId);
      if (workout == null) {
        throw Exception('Workout not found');
      }
      
      final now = DateTime.now();
      final actualDuration = workout.startTime != null 
          ? now.difference(workout.startTime!).inMinutes
          : completionData['actual_duration'] as int? ?? workout.estimatedDurationMinutes;
      
      final caloriesBurned = FitnessUtils.calculateCaloriesBurned(
        activity: workout.workoutType,
        durationMinutes: actualDuration.toDouble(),
        weightKg: 70.0, // Mock weight - would come from user profile
        intensity: _getIntensityFromDifficulty(workout.difficulty),
      );
      
      final completedWorkout = workout.copyWith(
        status: 'completed',
        endTime: now,
        actualDurationMinutes: actualDuration,
        actualCaloriesBurned: caloriesBurned.round(),
        completionPercentage: completionData['completion_percentage'] as double? ?? 1.0,
        intensityRating: completionData['intensity_rating'] as int?,
        satisfactionRating: completionData['satisfaction_rating'] as int?,
        notes: completionData['notes'] as String? ?? workout.notes,
        updatedAt: now,
      );
      
      // Award XP for workout completion
      await _awardWorkoutXP(workout.userId, completedWorkout);
      
      return completedWorkout;
    } catch (e) {
      throw Exception('Failed to end workout: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkoutEntity>> getUserWorkouts(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final mockWorkouts = _generateMockWorkouts(userId);
      
      if (startDate != null || endDate != null) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = endDate ?? DateTime.now();
        
        return mockWorkouts.where((workout) {
          final workoutDate = workout.startTime ?? workout.createdAt;
          return workoutDate.isAfter(start) && workoutDate.isBefore(end);
        }).toList();
      }
      
      return mockWorkouts;
    } catch (e) {
      throw Exception('Failed to retrieve user workouts: ${e.toString()}');
    }
  }

  @override
  Future<NutritionEntryEntity> logNutrition(String userId, Map<String, dynamic> nutritionData) async {
    try {
      final now = DateTime.now();
      final entryId = 'nutrition_${now.millisecondsSinceEpoch}';
      
      final entry = NutritionEntryEntity(
        id: entryId,
        userId: userId,
        foodName: nutritionData['food_name'] as String,
        brandName: nutritionData['brand_name'] as String?,
        mealType: nutritionData['meal_type'] as String? ?? 'meal',
        servingSize: nutritionData['serving_size'] as double? ?? 1.0,
        servingUnit: nutritionData['serving_unit'] as String? ?? 'serving',
        calories: nutritionData['calories'] as double? ?? 0.0,
        protein: nutritionData['protein'] as double? ?? 0.0,
        carbohydrates: nutritionData['carbohydrates'] as double? ?? 0.0,
        fat: nutritionData['fat'] as double? ?? 0.0,
        fiber: nutritionData['fiber'] as double? ?? 0.0,
        sugar: nutritionData['sugar'] as double? ?? 0.0,
        sodium: nutritionData['sodium'] as double? ?? 0.0,
        potassium: nutritionData['potassium'] as double? ?? 0.0,
        cholesterol: nutritionData['cholesterol'] as double? ?? 0.0,
        saturatedFat: nutritionData['saturated_fat'] as double? ?? 0.0,
        transFat: nutritionData['trans_fat'] as double? ?? 0.0,
        vitaminA: nutritionData['vitamin_a'] as double? ?? 0.0,
        vitaminC: nutritionData['vitamin_c'] as double? ?? 0.0,
        calcium: nutritionData['calcium'] as double? ?? 0.0,
        iron: nutritionData['iron'] as double? ?? 0.0,
        barcode: nutritionData['barcode'] as String?,
        isVerified: nutritionData['is_verified'] as bool? ?? false,
        mealTime: nutritionData['meal_time'] != null 
            ? DateTime.parse(nutritionData['meal_time'] as String)
            : now,
        createdAt: now,
      );
      
      return entry;
    } catch (e) {
      throw Exception('Failed to log nutrition: ${e.toString()}');
    }
  }

  @override
  Future<BiometricDataEntity> logBiometrics(String userId, Map<String, dynamic> biometricData) async {
    try {
      final now = DateTime.now();
      final entryId = 'biometric_${now.millisecondsSinceEpoch}';
      
      final entry = BiometricDataEntity(
        id: entryId,
        userId: userId,
        timestamp: biometricData['timestamp'] != null 
            ? DateTime.parse(biometricData['timestamp'] as String)
            : now,
        weight: biometricData['weight'] as double?,
        bodyFatPercentage: biometricData['body_fat'] as double?,
        muscleMass: biometricData['muscle_mass'] as double?,
        bmi: biometricData['bmi'] as double?,
        restingHeartRate: biometricData['resting_heart_rate'] as int?,
        bloodPressureSystolic: biometricData['bp_systolic'] as int?,
        bloodPressureDiastolic: biometricData['bp_diastolic'] as int?,
        bodyTemperature: biometricData['body_temperature'] as double?,
        hydrationLevel: biometricData['hydration_level'] as double?,
        sleepHours: biometricData['sleep_hours'] as double?,
        stressLevel: biometricData['stress_level'] as int?,
        energyLevel: biometricData['energy_level'] as int?,
        measurements: Map<String, double>.from(biometricData['measurements'] ?? {}),
        notes: biometricData['notes'] as String?,
        source: biometricData['source'] as String? ?? 'manual',
        isVerified: biometricData['is_verified'] as bool? ?? true,
        createdAt: now,
      );
      
      return entry;
    } catch (e) {
      throw Exception('Failed to log biometrics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFitnessAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final workouts = await getUserWorkouts(userId, startDate: startDate, endDate: endDate);
      final completedWorkouts = workouts.where((w) => w.status == 'completed').toList();
      
      if (completedWorkouts.isEmpty) {
        return {
          'total_workouts': 0,
          'total_exercise_time': 0,
          'calories_burned': 0,
          'average_workout_duration': 0.0,
        };
      }
      
      final totalWorkouts = completedWorkouts.length;
      final totalTime = completedWorkouts.fold<int>(0, (sum, w) => sum + w.actualDurationMinutes);
      final totalCalories = completedWorkouts.fold<int>(0, (sum, w) => sum + w.actualCaloriesBurned);
      
      // Workout type breakdown
      final workoutTypeBreakdown = <String, int>{};
      for (final workout in completedWorkouts) {
        workoutTypeBreakdown[workout.workoutType] = (workoutTypeBreakdown[workout.workoutType] ?? 0) + 1;
      }
      
      // Progress trends
      final weeklyProgress = _calculateWeeklyProgress(completedWorkouts);
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_workouts': totalWorkouts,
          'total_exercise_time_minutes': totalTime,
          'total_calories_burned': totalCalories,
          'average_workout_duration': totalWorkouts > 0 ? totalTime / totalWorkouts : 0.0,
          'average_calories_per_workout': totalWorkouts > 0 ? totalCalories / totalWorkouts : 0,
        },
        'breakdown': {
          'by_workout_type': workoutTypeBreakdown,
          'by_muscle_group': _getMuscleGroupBreakdown(completedWorkouts),
        },
        'trends': {
          'weekly_progress': weeklyProgress,
          'consistency_score': _calculateConsistencyScore(completedWorkouts),
        },
        'insights': _generateFitnessInsights(completedWorkouts),
      };
    } catch (e) {
      throw Exception('Failed to get fitness analytics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateWorkoutPlan(String userId, String fitnessGoal) async {
    try {
      return FitnessUtils.generatePersonalizedWorkoutPlan(
        fitnessGoal: fitnessGoal,
        userLevel: 'intermediate', // Mock level
        availableEquipment: ['dumbbells', 'bodyweight'], // Mock equipment
        timeAvailable: 45, // Mock time
        daysPerWeek: 4, // Mock frequency
      );
    } catch (e) {
      throw Exception('Failed to generate workout plan: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getNutritionRecommendations(String userId) async {
    try {
      return FitnessUtils.generateNutritionRecommendations(
        userId: userId,
        fitnessGoal: 'general_health', // Mock goal
        currentWeight: 70.0, // Mock weight
        targetWeight: 68.0, // Mock target
        activityLevel: 'moderate', // Mock activity
        dietaryRestrictions: [], // Mock restrictions
      );
    } catch (e) {
      throw Exception('Failed to get nutrition recommendations: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> scanBarcodeForNutrition(String barcode) async {
    try {
      // Mock barcode scanning - in real implementation, would call nutrition API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockNutritionData = {
        '1234567890': 'Banana - 105 calories, 27g carbs, 1g protein',
        '0987654321': 'Greek Yogurt - 150 calories, 20g protein, 6g carbs',
        '5555555555': 'Almonds - 160 calories, 6g protein, 14g fat',
      };
      
      final nutritionInfo = mockNutritionData[barcode];
      if (nutritionInfo != null) {
        return [nutritionInfo];
      } else {
        return ['Product not found. Please enter nutrition information manually.'];
      }
    } catch (e) {
      throw Exception('Failed to scan barcode: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateCaloriesBurned(String userId, String activity, int durationMinutes) async {
    try {
      final calories = FitnessUtils.calculateCaloriesBurned(
        activity: activity,
        durationMinutes: durationMinutes.toDouble(),
        weightKg: 70.0, // Mock weight
        intensity: 'moderate',
      );
      
      return {
        'activity': activity,
        'duration_minutes': durationMinutes,
        'calories_burned': calories.round(),
        'mets_value': _getMETsValue(activity),
        'intensity': 'moderate',
      };
    } catch (e) {
      throw Exception('Failed to calculate calories burned: ${e.toString()}');
    }
  }

  // Private helper methods
  List<WorkoutEntity> _generateMockWorkouts(String userId) {
    final now = DateTime.now();
    
    return [
      WorkoutEntity(
        id: 'workout_1',
        userId: userId,
        name: 'Upper Body Strength',
        workoutType: 'strength',
        exercises: ['push_ups', 'pull_ups', 'shoulder_press'],
        muscleGroups: ['chest', 'back', 'shoulders'],
        difficulty: 'intermediate',
        estimatedDurationMinutes: 45,
        actualDurationMinutes: 48,
        caloriesBurnedEstimate: 200,
        actualCaloriesBurned: 215,
        status: 'completed',
        startTime: now.subtract(const Duration(days: 1, hours: 1)),
        endTime: now.subtract(const Duration(days: 1)),
        completionPercentage: 1.0,
        intensityRating: 7,
        satisfactionRating: 8,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      WorkoutEntity(
        id: 'workout_2',
        userId: userId,
        name: 'Morning Cardio',
        workoutType: 'cardio',
        exercises: ['running', 'jumping_jacks'],
        muscleGroups: ['legs', 'cardiovascular'],
        difficulty: 'easy',
        estimatedDurationMinutes: 30,
        actualDurationMinutes: 32,
        caloriesBurnedEstimate: 250,
        actualCaloriesBurned: 270,
        status: 'completed',
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7, minutes: 28)),
        completionPercentage: 1.0,
        intensityRating: 6,
        satisfactionRating: 9,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<WorkoutEntity?> _getWorkoutById(String workoutId) async {
    final workouts = _generateMockWorkouts('user_id');
    try {
      return workouts.firstWhere((w) => w.id == workoutId);
    } catch (e) {
      return null;
    }
  }

  String _getIntensityFromDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return 'light';
      case 'intermediate': return 'moderate';
      case 'hard': return 'vigorous';
      default: return 'moderate';
    }
  }

  Future<void> _awardWorkoutXP(String userId, WorkoutEntity workout) async {
    final baseXP = workout.actualDurationMinutes;
    final intensityBonus = (workout.intensityRating ?? 5) * 5;
    final completionBonus = workout.completionPercentage >= 1.0 ? 25 : 0;
    
    final totalXP = baseXP + intensityBonus + completionBonus;
    print('Awarded $totalXP XP to user $userId for workout completion');
  }

  Map<String, int> _getMuscleGroupBreakdown(List<WorkoutEntity> workouts) {
    final breakdown = <String, int>{};
    
    for (final workout in workouts) {
      for (final muscleGroup in workout.muscleGroups) {
        breakdown[muscleGroup] = (breakdown[muscleGroup] ?? 0) + 1;
      }
    }
    
    return breakdown;
  }

  Map<String, double> _calculateWeeklyProgress(List<WorkoutEntity> workouts) {
    final weeklyData = <String, double>{};
    
    for (final workout in workouts) {
      final weekKey = DateUtils.formatDate(workout.startTime ?? workout.createdAt, 'yyyy-ww');
      weeklyData[weekKey] = (weeklyData[weekKey] ?? 0.0) + workout.actualDurationMinutes.toDouble();
    }
    
    return weeklyData;
  }

  double _calculateConsistencyScore(List<WorkoutEntity> workouts) {
    if (workouts.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final daysWithWorkouts = workouts
        .map((w) => DateUtils.formatDate(w.startTime ?? w.createdAt, 'yyyy-MM-dd'))
        .toSet()
        .length;
    
    final totalDays = now.difference(workouts.last.createdAt).inDays + 1;
    
    return totalDays > 0 ? (daysWithWorkouts / totalDays).clamp(0.0, 1.0) : 0.0;
  }

  double _getMETsValue(String activity) {
    final metsValues = {
      'walking': 3.5,
      'running': 8.0,
      'cycling': 6.0,
      'swimming': 7.0,
      'strength': 4.5,
      'yoga': 3.0,
      'cardio': 6.5,
    };
    
    return metsValues[activity.toLowerCase()] ?? 5.0;
  }

  List<String> _generateFitnessInsights(List<WorkoutEntity> workouts) {
    final insights = <String>[];
    
    if (workouts.isEmpty) {
      insights.add('Start your fitness journey! Even short workouts make a difference.');
      return insights;
    }
    
    final totalWorkouts = workouts.length;
    final avgDuration = workouts.fold<int>(0, (sum, w) => sum + w.actualDurationMinutes) / totalWorkouts;
    final avgIntensity = workouts
        .where((w) => w.intensityRating != null)
        .fold<double>(0, (sum, w) => sum + w.intensityRating!) / totalWorkouts;
    
    if (totalWorkouts >= 10) {
      insights.add('Excellent consistency! You\'ve completed $totalWorkouts workouts.');
    } else if (totalWorkouts >= 5) {
      insights.add('Good progress! Keep building your fitness routine.');
    }
    
    if (avgDuration >= 45) {
      insights.add('Great workout duration! You\'re dedicating quality time to fitness.');
    } else if (avgDuration < 20) {
      insights.add('Consider longer workouts for better fitness gains.');
    }
    
    if (avgIntensity >= 7) {
      insights.add('High intensity workouts! You\'re pushing yourself well.');
    } else if (avgIntensity < 5) {
      insights.add('Try increasing workout intensity for better results.');
    }
    
    return insights;
  }
}
