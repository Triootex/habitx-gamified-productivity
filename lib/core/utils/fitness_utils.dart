import 'dart:math' as math;
import '../constants/fitness_constants.dart';
import 'math_utils.dart';

class FitnessUtils {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  static double calculateBMR(double weightKg, double heightCm, int age, bool isMale) {
    return MathUtils.calculateBMR(weightKg, heightCm, age, isMale);
  }
  
  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    return MathUtils.calculateTDEE(bmr, activityLevel);
  }
  
  /// Calculate BMI and category
  static Map<String, dynamic> calculateBMI(double weightKg, double heightM) {
    final bmi = MathUtils.calculateBMI(weightKg, heightM);
    
    String category;
    String recommendation;
    
    if (bmi < 18.5) {
      category = 'Underweight';
      recommendation = 'Consider consulting a healthcare provider for healthy weight gain strategies';
    } else if (bmi < 25.0) {
      category = 'Normal weight';
      recommendation = 'Maintain your current weight with regular exercise and balanced nutrition';
    } else if (bmi < 30.0) {
      category = 'Overweight';
      recommendation = 'Consider gradual weight loss through diet and exercise';
    } else {
      category = 'Obese';
      recommendation = 'Consult healthcare provider for personalized weight management plan';
    }
    
    return {
      'bmi': bmi,
      'category': category,
      'recommendation': recommendation,
    };
  }
  
  /// Calculate Heart Rate Zones
  static Map<String, Map<String, int>> calculateHeartRateZones(int age, int? restingHR) {
    final maxHR = 220 - age;
    final rhr = restingHR ?? 60;
    
    final zones = <String, Map<String, int>>{};
    
    for (final entry in FitnessConstants.heartRateZones.entries) {
      final zoneName = entry.key;
      final zoneData = entry.value;
      
      // Using Karvonen formula (Heart Rate Reserve)
      final minHR = ((maxHR - rhr) * zoneData['min']! + rhr).round();
      final maxHR_zone = ((maxHR - rhr) * zoneData['max']! + rhr).round();
      
      zones[zoneName] = {
        'min': minHR,
        'max': maxHR_zone,
      };
    }
    
    return zones;
  }
  
  /// Calculate calories burned for exercise
  static double calculateCaloriesBurned(
    String exerciseType,
    double weightKg,
    int durationMinutes,
  ) {
    // Get MET value for exercise
    final met = _getMETValue(exerciseType);
    
    // Calories = MET × weight (kg) × duration (hours)
    return met * weightKg * (durationMinutes / 60.0);
  }
  
  static double _getMETValue(String exerciseType) {
    // Find exercise in categories
    for (final category in FitnessConstants.exerciseCategories) {
      final exercises = category['exercises'] as List<Map<String, dynamic>>;
      for (final exercise in exercises) {
        if (exercise['name'].toLowerCase() == exerciseType.toLowerCase()) {
          return exercise['met'] as double;
        }
      }
    }
    
    // Default MET values for common activities
    final metValues = {
      'walking': 3.5,
      'running': 8.0,
      'cycling': 7.5,
      'swimming': 6.0,
      'yoga': 2.5,
      'weightlifting': 3.5,
      'basketball': 8.0,
      'tennis': 7.0,
      'dancing': 4.5,
      'hiking': 6.0,
    };
    
    return metValues[exerciseType.toLowerCase()] ?? 4.0; // Default MET
  }
  
  /// Generate personalized workout plan
  static Map<String, dynamic> generateWorkoutPlan(
    Map<String, dynamic> userProfile,
    String fitnessGoal,
    int availableDays,
    int sessionDurationMinutes,
  ) {
    final fitnessLevel = userProfile['fitness_level'] as String? ?? 'beginner';
    final age = userProfile['age'] as int? ?? 30;
    final equipment = userProfile['available_equipment'] as List<String>? ?? [];
    
    final workoutPlan = <String, dynamic>{
      'goal': fitnessGoal,
      'duration_weeks': _getPlanDuration(fitnessGoal),
      'sessions_per_week': availableDays,
      'session_duration': sessionDurationMinutes,
      'workouts': <Map<String, dynamic>>[],
    };
    
    // Generate workouts based on goal
    switch (fitnessGoal.toLowerCase()) {
      case 'weight_loss':
        workoutPlan['workouts'] = _generateWeightLossWorkouts(
          fitnessLevel, availableDays, sessionDurationMinutes, equipment);
        break;
      case 'muscle_gain':
        workoutPlan['workouts'] = _generateMuscleGainWorkouts(
          fitnessLevel, availableDays, sessionDurationMinutes, equipment);
        break;
      case 'endurance':
        workoutPlan['workouts'] = _generateEnduranceWorkouts(
          fitnessLevel, availableDays, sessionDurationMinutes, equipment);
        break;
      case 'general_health':
        workoutPlan['workouts'] = _generateGeneralHealthWorkouts(
          fitnessLevel, availableDays, sessionDurationMinutes, equipment);
        break;
      default:
        workoutPlan['workouts'] = _generateGeneralHealthWorkouts(
          fitnessLevel, availableDays, sessionDurationMinutes, equipment);
    }
    
    return workoutPlan;
  }
  
  static int _getPlanDuration(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight_loss':
        return 12; // 3 months
      case 'muscle_gain':
        return 16; // 4 months
      case 'endurance':
        return 8; // 2 months
      default:
        return 8; // 2 months
    }
  }
  
  static List<Map<String, dynamic>> _generateWeightLossWorkouts(
    String fitnessLevel,
    int availableDays,
    int sessionDuration,
    List<String> equipment,
  ) {
    final workouts = <Map<String, dynamic>>[];
    
    // High-intensity cardio focused workouts
    for (int day = 1; day <= availableDays; day++) {
      if (day % 3 == 1) {
        // Cardio day
        workouts.add({
          'day': day,
          'type': 'Cardio',
          'exercises': [
            {'name': 'Jumping Jacks', 'duration': '45s', 'rest': '15s', 'sets': 3},
            {'name': 'Burpees', 'duration': '30s', 'rest': '30s', 'sets': 3},
            {'name': 'High Knees', 'duration': '45s', 'rest': '15s', 'sets': 3},
            {'name': 'Mountain Climbers', 'duration': '45s', 'rest': '15s', 'sets': 3},
          ],
          'calories_estimate': _estimateCalories(sessionDuration, 8.0, 70),
        });
      } else if (day % 3 == 2) {
        // Strength circuit
        workouts.add({
          'day': day,
          'type': 'Strength Circuit',
          'exercises': [
            {'name': 'Push-ups', 'reps': '10-15', 'sets': 3, 'rest': '60s'},
            {'name': 'Squats', 'reps': '15-20', 'sets': 3, 'rest': '60s'},
            {'name': 'Plank', 'duration': '30-60s', 'sets': 3, 'rest': '60s'},
            {'name': 'Lunges', 'reps': '10 each leg', 'sets': 3, 'rest': '60s'},
          ],
          'calories_estimate': _estimateCalories(sessionDuration, 5.0, 70),
        });
      } else {
        // Active recovery
        workouts.add({
          'day': day,
          'type': 'Active Recovery',
          'exercises': [
            {'name': 'Walking', 'duration': '20-30 minutes'},
            {'name': 'Stretching', 'duration': '10-15 minutes'},
            {'name': 'Yoga', 'duration': '15-20 minutes'},
          ],
          'calories_estimate': _estimateCalories(sessionDuration, 3.0, 70),
        });
      }
    }
    
    return workouts;
  }
  
  static List<Map<String, dynamic>> _generateMuscleGainWorkouts(
    String fitnessLevel,
    int availableDays,
    int sessionDuration,
    List<String> equipment,
  ) {
    final workouts = <Map<String, dynamic>>[];
    
    final muscleGroups = ['chest_triceps', 'back_biceps', 'legs', 'shoulders'];
    
    for (int day = 1; day <= availableDays; day++) {
      final muscleGroup = muscleGroups[(day - 1) % muscleGroups.length];
      
      workouts.add({
        'day': day,
        'type': 'Strength Training - ${muscleGroup.replaceAll('_', ' & ').toUpperCase()}',
        'exercises': _getExercisesForMuscleGroup(muscleGroup, equipment, fitnessLevel),
        'calories_estimate': _estimateCalories(sessionDuration, 3.5, 70),
      });
    }
    
    return workouts;
  }
  
  static List<Map<String, dynamic>> _generateEnduranceWorkouts(
    String fitnessLevel,
    int availableDays,
    int sessionDuration,
    List<String> equipment,
  ) {
    final workouts = <Map<String, dynamic>>[];
    
    for (int day = 1; day <= availableDays; day++) {
      if (day % 2 == 1) {
        // Cardio endurance
        workouts.add({
          'day': day,
          'type': 'Cardio Endurance',
          'exercises': [
            {'name': 'Running/Jogging', 'duration': '${sessionDuration - 10} minutes', 'intensity': 'moderate'},
            {'name': 'Cool down walk', 'duration': '5 minutes'},
            {'name': 'Stretching', 'duration': '5 minutes'},
          ],
          'calories_estimate': _estimateCalories(sessionDuration, 7.0, 70),
        });
      } else {
        // Muscular endurance
        workouts.add({
          'day': day,
          'type': 'Muscular Endurance',
          'exercises': [
            {'name': 'Push-ups', 'reps': '15-25', 'sets': 4, 'rest': '45s'},
            {'name': 'Squats', 'reps': '20-30', 'sets': 4, 'rest': '45s'},
            {'name': 'Plank', 'duration': '60-90s', 'sets': 3, 'rest': '45s'},
            {'name': 'Jumping Jacks', 'duration': '60s', 'sets': 4, 'rest': '45s'},
          ],
          'calories_estimate': _estimateCalories(sessionDuration, 5.5, 70),
        });
      }
    }
    
    return workouts;
  }
  
  static List<Map<String, dynamic>> _generateGeneralHealthWorkouts(
    String fitnessLevel,
    int availableDays,
    int sessionDuration,
    List<String> equipment,
  ) {
    final workouts = <Map<String, dynamic>>[];
    
    final workoutTypes = ['Full Body', 'Cardio', 'Flexibility'];
    
    for (int day = 1; day <= availableDays; day++) {
      final workoutType = workoutTypes[(day - 1) % workoutTypes.length];
      
      switch (workoutType) {
        case 'Full Body':
          workouts.add({
            'day': day,
            'type': 'Full Body Strength',
            'exercises': [
              {'name': 'Squats', 'reps': '12-15', 'sets': 3, 'rest': '60s'},
              {'name': 'Push-ups', 'reps': '8-12', 'sets': 3, 'rest': '60s'},
              {'name': 'Plank', 'duration': '30-45s', 'sets': 3, 'rest': '60s'},
              {'name': 'Lunges', 'reps': '10 each leg', 'sets': 2, 'rest': '60s'},
            ],
            'calories_estimate': _estimateCalories(sessionDuration, 4.0, 70),
          });
          break;
          
        case 'Cardio':
          workouts.add({
            'day': day,
            'type': 'Cardio Workout',
            'exercises': [
              {'name': 'Brisk Walking', 'duration': '${sessionDuration ~/ 2} minutes'},
              {'name': 'Jumping Jacks', 'duration': '2 minutes', 'sets': 3, 'rest': '1 minute'},
              {'name': 'Cool down', 'duration': '5 minutes'},
            ],
            'calories_estimate': _estimateCalories(sessionDuration, 5.0, 70),
          });
          break;
          
        case 'Flexibility':
          workouts.add({
            'day': day,
            'type': 'Flexibility & Mobility',
            'exercises': [
              {'name': 'Dynamic stretching', 'duration': '10 minutes'},
              {'name': 'Yoga flow', 'duration': '${sessionDuration - 15} minutes'},
              {'name': 'Relaxation', 'duration': '5 minutes'},
            ],
            'calories_estimate': _estimateCalories(sessionDuration, 2.5, 70),
          });
          break;
      }
    }
    
    return workouts;
  }
  
  static List<Map<String, dynamic>> _getExercisesForMuscleGroup(
    String muscleGroup,
    List<String> equipment,
    String fitnessLevel,
  ) {
    final exerciseLibrary = {
      'chest_triceps': [
        {'name': 'Push-ups', 'reps': '8-12', 'sets': 3, 'rest': '90s'},
        {'name': 'Tricep Dips', 'reps': '8-10', 'sets': 3, 'rest': '90s'},
        {'name': 'Chest Fly', 'reps': '10-12', 'sets': 3, 'rest': '90s'},
      ],
      'back_biceps': [
        {'name': 'Pull-ups', 'reps': '5-8', 'sets': 3, 'rest': '90s'},
        {'name': 'Bent-over Row', 'reps': '10-12', 'sets': 3, 'rest': '90s'},
        {'name': 'Bicep Curls', 'reps': '12-15', 'sets': 3, 'rest': '60s'},
      ],
      'legs': [
        {'name': 'Squats', 'reps': '12-15', 'sets': 4, 'rest': '90s'},
        {'name': 'Lunges', 'reps': '10 each leg', 'sets': 3, 'rest': '90s'},
        {'name': 'Calf Raises', 'reps': '15-20', 'sets': 3, 'rest': '60s'},
      ],
      'shoulders': [
        {'name': 'Shoulder Press', 'reps': '10-12', 'sets': 3, 'rest': '90s'},
        {'name': 'Lateral Raises', 'reps': '12-15', 'sets': 3, 'rest': '60s'},
        {'name': 'Front Raises', 'reps': '10-12', 'sets': 3, 'rest': '60s'},
      ],
    };
    
    return exerciseLibrary[muscleGroup] ?? [];
  }
  
  static int _estimateCalories(int durationMinutes, double met, double weightKg) {
    return (met * weightKg * (durationMinutes / 60.0)).round();
  }
  
  /// Track workout performance and calculate progress
  static Map<String, dynamic> calculateWorkoutProgress(
    List<Map<String, dynamic>> workoutHistory,
    String metric,
  ) {
    if (workoutHistory.isEmpty) {
      return {
        'progress': 0.0,
        'trend': 'no_data',
        'current_value': 0,
        'best_value': 0,
        'improvement_rate': 0.0,
      };
    }
    
    final values = workoutHistory
        .map((workout) => workout[metric] as num? ?? 0)
        .where((value) => value > 0)
        .toList();
    
    if (values.isEmpty) {
      return {
        'progress': 0.0,
        'trend': 'no_data',
        'current_value': 0,
        'best_value': 0,
        'improvement_rate': 0.0,
      };
    }
    
    final currentValue = values.last;
    final bestValue = values.reduce(math.max);
    final firstValue = values.first;
    
    // Calculate progress as percentage improvement from first to current
    final progress = firstValue != 0 ? ((currentValue - firstValue) / firstValue) * 100 : 0.0;
    
    // Calculate trend (last 5 vs previous 5 workouts)
    String trend = 'stable';
    if (values.length >= 10) {
      final recent = values.skip(values.length - 5).toList();
      final previous = values.skip(values.length - 10).take(5).toList();
      
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final previousAvg = previous.reduce((a, b) => a + b) / previous.length;
      
      if (recentAvg > previousAvg * 1.05) {
        trend = 'improving';
      } else if (recentAvg < previousAvg * 0.95) {
        trend = 'declining';
      }
    }
    
    // Calculate improvement rate (per week)
    final totalWeeks = workoutHistory.length / 3; // Assuming 3 workouts per week
    final improvementRate = totalWeeks > 0 ? progress / totalWeeks : 0.0;
    
    return {
      'progress': progress,
      'trend': trend,
      'current_value': currentValue,
      'best_value': bestValue,
      'improvement_rate': improvementRate,
    };
  }
  
  /// Generate nutrition recommendations based on fitness goals
  static Map<String, dynamic> generateNutritionRecommendations(
    Map<String, dynamic> userProfile,
    String fitnessGoal,
    double tdee,
  ) {
    final recommendations = <String, dynamic>{};
    
    // Calculate calorie targets
    switch (fitnessGoal.toLowerCase()) {
      case 'weight_loss':
        recommendations['daily_calories'] = (tdee * 0.8).round(); // 20% deficit
        recommendations['protein_grams'] = ((userProfile['weight'] as double? ?? 70) * 1.2).round();
        break;
      case 'muscle_gain':
        recommendations['daily_calories'] = (tdee * 1.1).round(); // 10% surplus
        recommendations['protein_grams'] = ((userProfile['weight'] as double? ?? 70) * 1.6).round();
        break;
      case 'maintenance':
      default:
        recommendations['daily_calories'] = tdee.round();
        recommendations['protein_grams'] = ((userProfile['weight'] as double? ?? 70) * 1.0).round();
    }
    
    // Calculate macro distribution
    final calories = recommendations['daily_calories'] as int;
    final proteinGrams = recommendations['protein_grams'] as int;
    final proteinCalories = proteinGrams * 4;
    
    final fatCalories = (calories * 0.25).round(); // 25% fat
    final carbCalories = calories - proteinCalories - fatCalories;
    
    recommendations['fat_grams'] = (fatCalories / 9).round();
    recommendations['carb_grams'] = (carbCalories / 4).round();
    recommendations['water_liters'] = 2.5 + (userProfile['weight'] as double? ?? 70) * 0.03;
    
    return recommendations;
  }
  
  /// Validate fitness data
  static Map<String, String?> validateFitnessData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final weight = data['weight'] as double?;
    if (weight != null && (weight <= 0 || weight > FitnessConstants.maxWeightKg)) {
      errors['weight'] = 'Invalid weight value';
    }
    
    final duration = data['duration'] as int?;
    if (duration != null && (duration < FitnessConstants.minWorkoutDuration || 
                           duration > FitnessConstants.maxWorkoutDuration)) {
      errors['duration'] = 'Workout duration must be between ${FitnessConstants.minWorkoutDuration} and ${FitnessConstants.maxWorkoutDuration} minutes';
    }
    
    final heartRate = data['heart_rate'] as int?;
    if (heartRate != null && (heartRate < 40 || heartRate > 220)) {
      errors['heart_rate'] = 'Invalid heart rate value';
    }
    
    return errors;
  }
  
  /// Format workout duration
  static String formatWorkoutDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
  
  /// Get exercise category color
  static String getExerciseCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return '#E74C3C'; // Red
      case 'strength':
        return '#3498DB'; // Blue
      case 'flexibility':
        return '#2ECC71'; // Green
      case 'balance':
        return '#F39C12'; // Orange
      default:
        return '#95A5A6'; // Gray
    }
  }
}
