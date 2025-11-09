import 'package:injectable/injectable.dart';
import '../../domain/entities/fitness_entity.dart';
import '../datasources/local/fitness_local_data_source.dart';
import '../datasources/remote/fitness_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class FitnessRepository {
  Future<Either<Failure, WorkoutEntity>> createWorkout(String userId, Map<String, dynamic> workoutData);
  Future<Either<Failure, WorkoutEntity>> startWorkout(String workoutId);
  Future<Either<Failure, WorkoutEntity>> endWorkout(String workoutId, Map<String, dynamic> completionData);
  Future<Either<Failure, List<WorkoutEntity>>> getUserWorkouts(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, NutritionEntryEntity>> logNutrition(String userId, Map<String, dynamic> nutritionData);
  Future<Either<Failure, BiometricDataEntity>> logBiometrics(String userId, Map<String, dynamic> biometricData);
  Future<Either<Failure, List<NutritionEntryEntity>>> getNutritionEntries(String userId, {DateTime? date});
  Future<Either<Failure, List<BiometricDataEntity>>> getBiometricData(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Map<String, dynamic>>> getFitnessAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> generateWorkoutPlan(String userId, String fitnessGoal);
  Future<Either<Failure, bool>> syncWithHealthApp(String userId);
  Future<Either<Failure, bool>> syncFitnessData(String userId);
}

@LazySingleton(as: FitnessRepository)
class FitnessRepositoryImpl implements FitnessRepository {
  final FitnessLocalDataSource localDataSource;
  final FitnessRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FitnessRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WorkoutEntity>> createWorkout(String userId, Map<String, dynamic> workoutData) async {
    try {
      // Create workout locally first for offline support
      final localWorkout = await localDataSource.createWorkout(userId, workoutData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteWorkout = await remoteDataSource.createWorkout(userId, workoutData);
          // Update local with server ID and sync status
          await localDataSource.updateWorkout(localWorkout.id, {
            'server_id': remoteWorkout.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteWorkout);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateWorkout(localWorkout.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localWorkout);
        }
      }
      
      return Right(localWorkout);
    } on CacheException {
      return Left(CacheFailure('Failed to create workout locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create workout on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WorkoutEntity>> startWorkout(String workoutId) async {
    try {
      // Start workout locally first
      final localWorkout = await localDataSource.startWorkout(workoutId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteWorkout = await remoteDataSource.startWorkout(workoutId);
          // Update local sync status
          await localDataSource.updateWorkout(workoutId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteWorkout);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateWorkout(workoutId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localWorkout);
        }
      }
      
      return Right(localWorkout);
    } on CacheException {
      return Left(CacheFailure('Failed to start workout locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start workout on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WorkoutEntity>> endWorkout(String workoutId, Map<String, dynamic> completionData) async {
    try {
      // End workout locally first
      final localWorkout = await localDataSource.endWorkout(workoutId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteWorkout = await remoteDataSource.endWorkout(workoutId, completionData);
          // Update local sync status
          await localDataSource.updateWorkout(workoutId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteWorkout);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateWorkout(workoutId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localWorkout);
        }
      }
      
      return Right(localWorkout);
    } on CacheException {
      return Left(CacheFailure('Failed to end workout locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end workout on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutEntity>>> getUserWorkouts(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local workouts first for immediate UI response
      List<WorkoutEntity> localWorkouts = [];
      
      try {
        localWorkouts = await localDataSource.getUserWorkouts(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local workouts, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteWorkouts = await remoteDataSource.getUserWorkouts(userId, startDate: startDate, endDate: endDate);
          
          // Update local cache with remote data
          await localDataSource.cacheWorkouts(remoteWorkouts);
          
          return Right(remoteWorkouts);
        } catch (e) {
          // Return local workouts if remote fails
          if (localWorkouts.isNotEmpty) {
            return Right(localWorkouts);
          } else {
            return Left(ServerFailure('Failed to fetch workouts and no local cache available'));
          }
        }
      }
      
      return Right(localWorkouts);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, NutritionEntryEntity>> logNutrition(String userId, Map<String, dynamic> nutritionData) async {
    try {
      // Log nutrition locally first
      final localEntry = await localDataSource.logNutrition(userId, nutritionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteEntry = await remoteDataSource.logNutrition(userId, nutritionData);
          // Update local sync status
          await localDataSource.updateNutritionEntry(localEntry.id, {
            'server_id': remoteEntry.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteEntry);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateNutritionEntry(localEntry.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localEntry);
        }
      }
      
      return Right(localEntry);
    } on CacheException {
      return Left(CacheFailure('Failed to log nutrition locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to log nutrition on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BiometricDataEntity>> logBiometrics(String userId, Map<String, dynamic> biometricData) async {
    try {
      // Log biometrics locally first
      final localEntry = await localDataSource.logBiometrics(userId, biometricData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteEntry = await remoteDataSource.logBiometrics(userId, biometricData);
          // Update local sync status
          await localDataSource.updateBiometricData(localEntry.id, {
            'server_id': remoteEntry.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteEntry);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateBiometricData(localEntry.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localEntry);
        }
      }
      
      return Right(localEntry);
    } on CacheException {
      return Left(CacheFailure('Failed to log biometrics locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to log biometrics on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<NutritionEntryEntity>>> getNutritionEntries(String userId, {DateTime? date}) async {
    try {
      List<NutritionEntryEntity> localEntries = [];
      
      try {
        localEntries = await localDataSource.getNutritionEntries(userId, date: date);
      } on CacheException {
        // No local entries
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteEntries = await remoteDataSource.getNutritionEntries(userId, date: date);
          await localDataSource.cacheNutritionEntries(remoteEntries);
          return Right(remoteEntries);
        } catch (e) {
          if (localEntries.isNotEmpty) {
            return Right(localEntries);
          } else {
            return Left(ServerFailure('Failed to fetch nutrition entries'));
          }
        }
      }
      
      return Right(localEntries);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BiometricDataEntity>>> getBiometricData(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      List<BiometricDataEntity> localData = [];
      
      try {
        localData = await localDataSource.getBiometricData(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local data
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteData = await remoteDataSource.getBiometricData(userId, startDate: startDate, endDate: endDate);
          await localDataSource.cacheBiometricData(remoteData);
          return Right(remoteData);
        } catch (e) {
          if (localData.isNotEmpty) {
            return Right(localData);
          } else {
            return Left(ServerFailure('Failed to fetch biometric data'));
          }
        }
      }
      
      return Right(localData);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFitnessAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getFitnessAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheFitnessAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getFitnessAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getFitnessAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateWorkoutPlan(String userId, String fitnessGoal) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remotePlan = await remoteDataSource.generateWorkoutPlan(userId, fitnessGoal);
          // Cache workout plan locally
          await localDataSource.cacheWorkoutPlan(userId, fitnessGoal, remotePlan);
          return Right(remotePlan);
        } catch (e) {
          // Fall back to local plan generation
          try {
            final localPlan = await localDataSource.generateWorkoutPlan(userId, fitnessGoal);
            return Right(localPlan);
          } on CacheException {
            return Left(ServerFailure('Failed to generate workout plan and no local capability available'));
          }
        }
      } else {
        // Offline - use local plan generation
        final localPlan = await localDataSource.generateWorkoutPlan(userId, fitnessGoal);
        return Right(localPlan);
      }
    } on CacheException {
      return Left(CacheFailure('Cannot generate workout plan locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithHealthApp(String userId) async {
    try {
      // Import data from device health app
      final healthData = await localDataSource.importHealthAppData(userId);
      
      // Process and store health data locally
      for (final dataPoint in healthData) {
        try {
          if (dataPoint['type'] == 'workout') {
            await localDataSource.createWorkout(userId, dataPoint);
          } else if (dataPoint['type'] == 'nutrition') {
            await localDataSource.logNutrition(userId, dataPoint);
          } else if (dataPoint['type'] == 'biometric') {
            await localDataSource.logBiometrics(userId, dataPoint);
          }
        } catch (e) {
          // Continue processing other data points if one fails
          continue;
        }
      }
      
      // Mark health sync timestamp
      await localDataSource.updateHealthSyncTimestamp(userId, DateTime.now());
      
      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.syncHealthData(userId, healthData);
        } catch (e) {
          // Health data sync to remote failed, but local sync succeeded
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to sync with health app'));
    } catch (e) {
      return Left(UnexpectedFailure('Health app sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncFitnessData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get fitness data that needs sync
      final unsyncedWorkouts = await localDataSource.getUnsyncedWorkouts(userId);
      final unsyncedNutrition = await localDataSource.getUnsyncedNutritionEntries(userId);
      final unsyncedBiometrics = await localDataSource.getUnsyncedBiometricData(userId);

      // Sync workouts
      for (final workout in unsyncedWorkouts) {
        try {
          if (workout.serverId == null) {
            // Create on server
            final remoteWorkout = await remoteDataSource.createWorkout(userId, workout.toJson());
            await localDataSource.updateWorkout(workout.id, {
              'server_id': remoteWorkout.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateWorkout(workout.serverId!, workout.toJson());
            await localDataSource.updateWorkout(workout.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync nutrition entries
      for (final entry in unsyncedNutrition) {
        try {
          if (entry.serverId == null) {
            final remoteEntry = await remoteDataSource.logNutrition(userId, entry.toJson());
            await localDataSource.updateNutritionEntry(entry.id, {
              'server_id': remoteEntry.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync biometric data
      for (final data in unsyncedBiometrics) {
        try {
          if (data.serverId == null) {
            final remoteData = await remoteDataSource.logBiometrics(userId, data.toJson());
            await localDataSource.updateBiometricData(data.id, {
              'server_id': remoteData.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteWorkouts = await remoteDataSource.getUserWorkouts(userId);
      await localDataSource.cacheWorkouts(remoteWorkouts);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync fitness data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }
}
