import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/fitness_entity.dart';
import '../../data/repositories/fitness_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Workout Use Case
@injectable
class CreateWorkoutUseCase implements UseCase<WorkoutEntity, CreateWorkoutParams> {
  final FitnessRepository repository;

  CreateWorkoutUseCase(this.repository);

  @override
  Future<Either<Failure, WorkoutEntity>> call(CreateWorkoutParams params) async {
    return await repository.createWorkout(params.userId, params.workoutData);
  }
}

class CreateWorkoutParams {
  final String userId;
  final Map<String, dynamic> workoutData;

  CreateWorkoutParams({required this.userId, required this.workoutData});
}

// Start Workout Use Case
@injectable
class StartWorkoutUseCase implements UseCase<WorkoutEntity, String> {
  final FitnessRepository repository;

  StartWorkoutUseCase(this.repository);

  @override
  Future<Either<Failure, WorkoutEntity>> call(String workoutId) async {
    return await repository.startWorkout(workoutId);
  }
}

// End Workout Use Case
@injectable
class EndWorkoutUseCase implements UseCase<WorkoutEntity, EndWorkoutParams> {
  final FitnessRepository repository;

  EndWorkoutUseCase(this.repository);

  @override
  Future<Either<Failure, WorkoutEntity>> call(EndWorkoutParams params) async {
    return await repository.endWorkout(params.workoutId, params.completionData);
  }
}

class EndWorkoutParams {
  final String workoutId;
  final Map<String, dynamic> completionData;

  EndWorkoutParams({required this.workoutId, required this.completionData});
}

// Get User Workouts Use Case
@injectable
class GetUserWorkoutsUseCase implements UseCase<List<WorkoutEntity>, GetUserWorkoutsParams> {
  final FitnessRepository repository;

  GetUserWorkoutsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WorkoutEntity>>> call(GetUserWorkoutsParams params) async {
    return await repository.getUserWorkouts(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserWorkoutsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserWorkoutsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Log Nutrition Use Case
@injectable
class LogNutritionUseCase implements UseCase<NutritionEntryEntity, LogNutritionParams> {
  final FitnessRepository repository;

  LogNutritionUseCase(this.repository);

  @override
  Future<Either<Failure, NutritionEntryEntity>> call(LogNutritionParams params) async {
    return await repository.logNutrition(params.userId, params.nutritionData);
  }
}

class LogNutritionParams {
  final String userId;
  final Map<String, dynamic> nutritionData;

  LogNutritionParams({required this.userId, required this.nutritionData});
}

// Log Biometrics Use Case
@injectable
class LogBiometricsUseCase implements UseCase<BiometricDataEntity, LogBiometricsParams> {
  final FitnessRepository repository;

  LogBiometricsUseCase(this.repository);

  @override
  Future<Either<Failure, BiometricDataEntity>> call(LogBiometricsParams params) async {
    return await repository.logBiometrics(params.userId, params.biometricData);
  }
}

class LogBiometricsParams {
  final String userId;
  final Map<String, dynamic> biometricData;

  LogBiometricsParams({required this.userId, required this.biometricData});
}

// Get Nutrition Entries Use Case
@injectable
class GetNutritionEntriesUseCase implements UseCase<List<NutritionEntryEntity>, GetNutritionEntriesParams> {
  final FitnessRepository repository;

  GetNutritionEntriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<NutritionEntryEntity>>> call(GetNutritionEntriesParams params) async {
    return await repository.getNutritionEntries(
      params.userId,
      date: params.date,
    );
  }
}

class GetNutritionEntriesParams {
  final String userId;
  final DateTime? date;

  GetNutritionEntriesParams({required this.userId, this.date});
}

// Get Biometric Data Use Case
@injectable
class GetBiometricDataUseCase implements UseCase<List<BiometricDataEntity>, GetBiometricDataParams> {
  final FitnessRepository repository;

  GetBiometricDataUseCase(this.repository);

  @override
  Future<Either<Failure, List<BiometricDataEntity>>> call(GetBiometricDataParams params) async {
    return await repository.getBiometricData(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetBiometricDataParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetBiometricDataParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Fitness Analytics Use Case
@injectable
class GetFitnessAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetFitnessAnalyticsParams> {
  final FitnessRepository repository;

  GetFitnessAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetFitnessAnalyticsParams params) async {
    return await repository.getFitnessAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetFitnessAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetFitnessAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Generate Workout Plan Use Case
@injectable
class GenerateWorkoutPlanUseCase implements UseCase<Map<String, dynamic>, GenerateWorkoutPlanParams> {
  final FitnessRepository repository;

  GenerateWorkoutPlanUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GenerateWorkoutPlanParams params) async {
    return await repository.generateWorkoutPlan(params.userId, params.fitnessGoal);
  }
}

class GenerateWorkoutPlanParams {
  final String userId;
  final String fitnessGoal;

  GenerateWorkoutPlanParams({required this.userId, required this.fitnessGoal});
}

// Sync with Health App Use Case
@injectable
class SyncWithHealthAppUseCase implements UseCase<bool, String> {
  final FitnessRepository repository;

  SyncWithHealthAppUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncWithHealthApp(userId);
  }
}

// Sync Fitness Data Use Case
@injectable
class SyncFitnessDataUseCase implements UseCase<bool, String> {
  final FitnessRepository repository;

  SyncFitnessDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncFitnessData(userId);
  }
}

// Calculate BMI Use Case
@injectable
class CalculateBMIUseCase implements UseCase<Map<String, dynamic>, CalculateBMIParams> {
  final FitnessRepository repository;

  CalculateBMIUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CalculateBMIParams params) async {
    try {
      final biometricDataResult = await repository.getBiometricData(
        params.userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return biometricDataResult.fold(
        (failure) => Left(failure),
        (biometricData) {
          final bmiData = _calculateBMI(biometricData, params.height);
          return Right(bmiData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate BMI: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateBMI(List<BiometricDataEntity> biometricData, double? height) {
    if (height == null || height <= 0) {
      return {
        'error': 'Height is required for BMI calculation',
        'bmi': null,
        'category': null,
      };
    }
    
    // Get the most recent weight measurement
    final weightData = biometricData
        .where((data) => data.weight != null)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    if (weightData.isEmpty) {
      return {
        'error': 'No weight data available',
        'bmi': null,
        'category': null,
      };
    }
    
    final weight = weightData.first.weight!;
    final heightInMeters = height / 100; // Convert cm to meters
    final bmi = weight / (heightInMeters * heightInMeters);
    
    String category;
    String recommendation;
    
    if (bmi < 18.5) {
      category = 'Underweight';
      recommendation = 'Consider consulting a nutritionist for healthy weight gain strategies';
    } else if (bmi < 25) {
      category = 'Normal weight';
      recommendation = 'Great job! Maintain your current lifestyle with regular exercise and balanced nutrition';
    } else if (bmi < 30) {
      category = 'Overweight';
      recommendation = 'Consider incorporating more cardio and strength training with a balanced diet';
    } else {
      category = 'Obese';
      recommendation = 'Consult with healthcare professionals for a comprehensive weight management plan';
    }
    
    return {
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'category': category,
      'recommendation': recommendation,
      'weight': weight,
      'height': height,
      'recorded_at': weightData.first.recordedAt.toIso8601String(),
      'trend': _calculateWeightTrend(weightData),
    };
  }

  String _calculateWeightTrend(List<BiometricDataEntity> weightData) {
    if (weightData.length < 2) return 'insufficient_data';
    
    final recent = weightData.take(5).toList();
    final older = weightData.skip(5).take(5).toList();
    
    if (older.isEmpty) return 'insufficient_data';
    
    final recentAvg = recent.fold<double>(0, (sum, data) => sum + (data.weight ?? 0)) / recent.length;
    final olderAvg = older.fold<double>(0, (sum, data) => sum + (data.weight ?? 0)) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    if (difference > 1) return 'increasing';
    if (difference < -1) return 'decreasing';
    return 'stable';
  }
}

class CalculateBMIParams {
  final String userId;
  final double? height; // in centimeters

  CalculateBMIParams({required this.userId, this.height});
}

// Get Workout Recommendations Use Case
@injectable
class GetWorkoutRecommendationsUseCase implements UseCase<List<Map<String, dynamic>>, String> {
  final FitnessRepository repository;

  GetWorkoutRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String userId) async {
    try {
      final workoutsResult = await repository.getUserWorkouts(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return workoutsResult.fold(
        (failure) => Left(failure),
        (workouts) {
          final recommendations = _generateWorkoutRecommendations(workouts);
          return Right(recommendations);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate workout recommendations: ${e.toString()}'));
    }
  }

  List<Map<String, dynamic>> _generateWorkoutRecommendations(List<WorkoutEntity> workouts) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (workouts.isEmpty) {
      return [
        {
          'type': 'beginner',
          'title': 'Start Your Fitness Journey',
          'description': 'Begin with 20-30 minutes of light cardio 3 times per week',
          'exercises': ['Walking', 'Bodyweight squats', 'Push-ups (modified if needed)'],
          'priority': 'high',
        },
      ];
    }
    
    // Analyze workout patterns
    final workoutTypes = <String, int>{};
    final workoutFrequency = <String, int>{};
    
    for (final workout in workouts) {
      // Count workout types
      workoutTypes[workout.type] = (workoutTypes[workout.type] ?? 0) + 1;
      
      // Count weekly frequency
      final weekKey = '${workout.startTime.year}-W${_getWeekOfYear(workout.startTime)}';
      workoutFrequency[weekKey] = (workoutFrequency[weekKey] ?? 0) + 1;
    }
    
    // Recommend missing workout types
    final essentialTypes = ['cardio', 'strength', 'flexibility'];
    for (final type in essentialTypes) {
      if (!workoutTypes.containsKey(type)) {
        recommendations.add({
          'type': 'missing_workout_type',
          'title': 'Add ${type.toUpperCase()} Training',
          'description': 'Balance your routine with $type exercises',
          'priority': 'medium',
          'workout_type': type,
        });
      }
    }
    
    // Analyze frequency and suggest improvements
    final avgWeeklyWorkouts = workoutFrequency.values.isNotEmpty 
        ? workoutFrequency.values.reduce((a, b) => a + b) / workoutFrequency.length 
        : 0;
    
    if (avgWeeklyWorkouts < 3) {
      recommendations.add({
        'type': 'frequency',
        'title': 'Increase Workout Frequency',
        'description': 'Aim for at least 3 workouts per week for better results',
        'current_frequency': avgWeeklyWorkouts.round(),
        'target_frequency': 3,
        'priority': 'high',
      });
    } else if (avgWeeklyWorkouts > 6) {
      recommendations.add({
        'type': 'rest',
        'title': 'Consider Rest Days',
        'description': 'Recovery is crucial - aim for 1-2 rest days per week',
        'priority': 'medium',
      });
    }
    
    // Recommend progression
    final recentWorkouts = workouts.where((w) => 
        w.startTime.isAfter(DateTime.now().subtract(const Duration(days: 14)))
    ).toList();
    
    if (recentWorkouts.isNotEmpty) {
      final avgDuration = recentWorkouts
          .fold<int>(0, (sum, w) => sum + (w.duration ?? 0)) / recentWorkouts.length;
      
      if (avgDuration < 30) {
        recommendations.add({
          'type': 'progression',
          'title': 'Gradually Increase Duration',
          'description': 'Try adding 5-10 minutes to your workouts',
          'current_duration': avgDuration.round(),
          'priority': 'low',
        });
      }
    }
    
    return recommendations;
  }

  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(startOfYear).inDays;
    return (days / 7).floor() + 1;
  }
}

// Calculate Calorie Burn Use Case
@injectable
class CalculateCalorieBurnUseCase implements UseCase<Map<String, dynamic>, CalculateCalorieBurnParams> {
  final FitnessRepository repository;

  CalculateCalorieBurnUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CalculateCalorieBurnParams params) async {
    try {
      // Get user's biometric data for accurate calculation
      final biometricDataResult = await repository.getBiometricData(
        params.userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return biometricDataResult.fold(
        (failure) => Left(failure),
        (biometricData) {
          final calorieBurn = _calculateCalorieBurn(
            params.exerciseType,
            params.durationMinutes,
            params.intensity,
            biometricData,
          );
          return Right(calorieBurn);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate calorie burn: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateCalorieBurn(
    String exerciseType,
    int durationMinutes,
    String intensity,
    List<BiometricDataEntity> biometricData,
  ) {
    // Get user's weight for calculation
    final weightData = biometricData
        .where((data) => data.weight != null)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    double weight = 70.0; // Default weight in kg
    if (weightData.isNotEmpty) {
      weight = weightData.first.weight!;
    }
    
    // MET (Metabolic Equivalent) values for different exercises
    final metValues = {
      'walking': {'low': 2.5, 'moderate': 3.5, 'high': 4.5},
      'running': {'low': 6.0, 'moderate': 8.0, 'high': 11.0},
      'cycling': {'low': 4.0, 'moderate': 6.0, 'high': 8.0},
      'swimming': {'low': 4.0, 'moderate': 6.0, 'high': 8.0},
      'strength': {'low': 3.0, 'moderate': 5.0, 'high': 6.0},
      'yoga': {'low': 2.0, 'moderate': 3.0, 'high': 4.0},
      'hiit': {'low': 6.0, 'moderate': 8.0, 'high': 12.0},
    };
    
    final exerciseMets = metValues[exerciseType.toLowerCase()] ?? metValues['walking']!;
    final met = exerciseMets[intensity.toLowerCase()] ?? exerciseMets['moderate']!;
    
    // Calories = MET × weight(kg) × time(hours)
    final calories = (met * weight * (durationMinutes / 60.0)).round();
    
    return {
      'calories_burned': calories,
      'exercise_type': exerciseType,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'weight_used': weight,
      'met_value': met,
      'calculation_formula': 'MET × Weight(kg) × Time(hours)',
      'accuracy_note': weightData.isNotEmpty 
          ? 'Based on your recorded weight'
          : 'Based on average weight (70kg)',
    };
  }
}

class CalculateCalorieBurnParams {
  final String userId;
  final String exerciseType;
  final int durationMinutes;
  final String intensity; // 'low', 'moderate', 'high'

  CalculateCalorieBurnParams({
    required this.userId,
    required this.exerciseType,
    required this.durationMinutes,
    required this.intensity,
  });
}
