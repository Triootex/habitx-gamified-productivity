import 'package:injectable/injectable.dart';
import '../../domain/entities/habit_entity.dart';
import '../datasources/local/habit_local_data_source.dart';
import '../datasources/remote/habit_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class HabitRepository {
  Future<Either<Failure, HabitEntity>> createHabit(String userId, Map<String, dynamic> habitData);
  Future<Either<Failure, HabitEntity>> updateHabit(String habitId, Map<String, dynamic> updates);
  Future<Either<Failure, bool>> deleteHabit(String habitId);
  Future<Either<Failure, HabitEntity>> getHabit(String habitId);
  Future<Either<Failure, List<HabitEntity>>> getUserHabits(String userId, {String? category, String? status});
  Future<Either<Failure, HabitLogEntity>> logHabitCompletion(String habitId, Map<String, dynamic> logData);
  Future<Either<Failure, List<HabitLogEntity>>> getHabitLogs(String habitId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> getHabitAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<HabitEntity>>> getHabitsDueToday(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getStreakAnalytics(String userId);
  Future<Either<Failure, bool>> syncHabits(String userId);
  Future<Either<Failure, bool>> syncWithHealthApp(String userId);
}

@LazySingleton(as: HabitRepository)
class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HabitEntity>> createHabit(String userId, Map<String, dynamic> habitData) async {
    try {
      // Create locally first for offline support
      final localHabit = await localDataSource.createHabit(userId, habitData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteHabit = await remoteDataSource.createHabit(userId, habitData);
          // Update local with server ID and sync status
          await localDataSource.updateHabit(localHabit.id, {
            'server_id': remoteHabit.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteHabit);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateHabit(localHabit.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localHabit);
        }
      }
      
      return Right(localHabit);
    } on CacheException {
      return Left(CacheFailure('Failed to create habit locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create habit on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> updateHabit(String habitId, Map<String, dynamic> updates) async {
    try {
      // Update locally first
      final localHabit = await localDataSource.updateHabit(habitId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteHabit = await remoteDataSource.updateHabit(habitId, updates);
          // Update local sync status
          await localDataSource.updateHabit(habitId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteHabit);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateHabit(habitId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localHabit);
        }
      }
      
      return Right(localHabit);
    } on CacheException {
      return Left(CacheFailure('Failed to update habit locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update habit on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteHabit(String habitId) async {
    try {
      // Delete locally first
      await localDataSource.deleteHabit(habitId);
      
      if (await networkInfo.isConnected) {
        try {
          // Delete from remote
          await remoteDataSource.deleteHabit(habitId);
        } catch (e) {
          // Mark for later sync deletion
          await localDataSource.markHabitForDeletion(habitId);
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to delete habit locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to delete habit on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> getHabit(String habitId) async {
    try {
      // Try local first for speed
      try {
        final localHabit = await localDataSource.getHabit(habitId);
        
        // If online and habit needs sync, fetch from remote
        if (await networkInfo.isConnected && (!localHabit.isSynced || _shouldRefresh(localHabit.lastSynced))) {
          try {
            final remoteHabit = await remoteDataSource.getHabit(habitId);
            // Update local cache
            await localDataSource.cacheHabit(remoteHabit);
            return Right(remoteHabit);
          } catch (e) {
            // Return local if remote fails
            return Right(localHabit);
          }
        }
        
        return Right(localHabit);
      } on CacheException {
        // If not in local cache and online, fetch from remote
        if (await networkInfo.isConnected) {
          final remoteHabit = await remoteDataSource.getHabit(habitId);
          // Cache locally
          await localDataSource.cacheHabit(remoteHabit);
          return Right(remoteHabit);
        } else {
          return Left(CacheFailure('Habit not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch habit from server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getUserHabits(String userId, {String? category, String? status}) async {
    try {
      // Always return local habits first for immediate UI response
      List<HabitEntity> localHabits = [];
      
      try {
        localHabits = await localDataSource.getUserHabits(userId, category: category, status: status);
      } on CacheException {
        // No local habits, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteHabits = await remoteDataSource.getUserHabits(userId, category: category, status: status);
          
          // Update local cache with remote data
          await localDataSource.cacheHabits(remoteHabits);
          
          return Right(remoteHabits);
        } catch (e) {
          // Return local habits if remote fails
          if (localHabits.isNotEmpty) {
            return Right(localHabits);
          } else {
            return Left(ServerFailure('Failed to fetch habits and no local cache available'));
          }
        }
      }
      
      return Right(localHabits);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HabitLogEntity>> logHabitCompletion(String habitId, Map<String, dynamic> logData) async {
    try {
      // Log locally first
      final localLog = await localDataSource.logHabitCompletion(habitId, logData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteLog = await remoteDataSource.logHabitCompletion(habitId, logData);
          // Update local sync status
          await localDataSource.updateHabitLog(localLog.id, {
            'server_id': remoteLog.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          
          // Update habit streak and statistics
          await _updateHabitStatistics(habitId);
          
          return Right(remoteLog);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateHabitLog(localLog.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localLog);
        }
      }
      
      // Update habit statistics locally
      await _updateHabitStatisticsLocally(habitId);
      
      return Right(localLog);
    } on CacheException {
      return Left(CacheFailure('Failed to log habit completion locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to log habit completion on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HabitLogEntity>>> getHabitLogs(String habitId, DateTime? startDate, DateTime? endDate) async {
    try {
      List<HabitLogEntity> localLogs = [];
      
      try {
        localLogs = await localDataSource.getHabitLogs(habitId, startDate, endDate);
      } on CacheException {
        // No local logs
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteLogs = await remoteDataSource.getHabitLogs(habitId, startDate, endDate);
          await localDataSource.cacheHabitLogs(remoteLogs);
          return Right(remoteLogs);
        } catch (e) {
          if (localLogs.isNotEmpty) {
            return Right(localLogs);
          } else {
            return Left(ServerFailure('Failed to fetch habit logs'));
          }
        }
      }
      
      return Right(localLogs);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHabitAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getHabitAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheHabitAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getHabitAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getHabitAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabitsDueToday(String userId) async {
    try {
      List<HabitEntity> localHabits = [];
      
      try {
        localHabits = await localDataSource.getHabitsDueToday(userId);
      } on CacheException {
        // No local habits
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteHabits = await remoteDataSource.getHabitsDueToday(userId);
          await localDataSource.cacheHabits(remoteHabits);
          return Right(remoteHabits);
        } catch (e) {
          if (localHabits.isNotEmpty) {
            return Right(localHabits);
          } else {
            return Left(ServerFailure('Failed to fetch today\'s habits'));
          }
        }
      }
      
      return Right(localHabits);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStreakAnalytics(String userId) async {
    try {
      // Try to get streak analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteStreaks = await remoteDataSource.getStreakAnalytics(userId);
          // Cache streak analytics locally
          await localDataSource.cacheStreakAnalytics(userId, remoteStreaks);
          return Right(remoteStreaks);
        } catch (e) {
          // Fall back to local streak analytics
          try {
            final localStreaks = await localDataSource.getStreakAnalytics(userId);
            return Right(localStreaks);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch streak analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local streak analytics
        final localStreaks = await localDataSource.getStreakAnalytics(userId);
        return Right(localStreaks);
      }
    } on CacheException {
      return Left(CacheFailure('No streak analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncHabits(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get habits that need sync
      final unsyncedHabits = await localDataSource.getUnsyncedHabits(userId);
      final deletedHabits = await localDataSource.getHabitsMarkedForDeletion(userId);
      final unsyncedLogs = await localDataSource.getUnsyncedHabitLogs(userId);

      // Sync habit creations and updates
      for (final habit in unsyncedHabits) {
        try {
          if (habit.serverId == null) {
            // Create on server
            final remoteHabit = await remoteDataSource.createHabit(userId, habit.toJson());
            await localDataSource.updateHabit(habit.id, {
              'server_id': remoteHabit.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateHabit(habit.serverId!, habit.toJson());
            await localDataSource.updateHabit(habit.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Continue with other habits if one fails
          continue;
        }
      }

      // Sync habit logs
      for (final log in unsyncedLogs) {
        try {
          if (log.serverId == null) {
            // Create log on server
            final remoteLog = await remoteDataSource.logHabitCompletion(log.habitId, log.toJson());
            await localDataSource.updateHabitLog(log.id, {
              'server_id': remoteLog.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync deletions
      for (final habitId in deletedHabits) {
        try {
          await remoteDataSource.deleteHabit(habitId);
          await localDataSource.removeDeletedHabit(habitId);
        } catch (e) {
          // Continue with other deletions
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteHabits = await remoteDataSource.getUserHabits(userId);
      await localDataSource.cacheHabits(remoteHabits);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync habits with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithHealthApp(String userId) async {
    try {
      // Sync health-related habits with device health app
      final healthHabits = await localDataSource.getHealthHabits(userId);
      
      for (final habit in healthHabits) {
        try {
          // Import data from health app
          if (habit.healthDataType != null) {
            final healthData = await _getHealthAppData(habit.healthDataType!, habit.lastHealthSync);
            
            // Create habit logs from health data
            for (final dataPoint in healthData) {
              await localDataSource.logHabitCompletion(habit.id, {
                'date': dataPoint['date'],
                'value': dataPoint['value'],
                'source': 'health_app',
                'auto_logged': true,
              });
            }
            
            // Update last health sync time
            await localDataSource.updateHabit(habit.id, {
              'last_health_sync': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Continue with other habits if one fails
          continue;
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to sync with health app'));
    } catch (e) {
      return Left(UnexpectedFailure('Health app sync failed: ${e.toString()}'));
    }
  }

  // Helper methods
  bool _shouldRefresh(DateTime? lastSynced) {
    if (lastSynced == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSynced);
    return difference.inMinutes > 5; // Refresh if older than 5 minutes
  }

  Future<void> _updateHabitStatistics(String habitId) async {
    // Update habit statistics on server after logging completion
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateHabitStatistics(habitId);
      } catch (e) {
        // Mark for later sync if update fails
      }
    }
  }

  Future<void> _updateHabitStatisticsLocally(String habitId) async {
    // Update habit statistics locally
    try {
      await localDataSource.updateHabitStatistics(habitId);
    } catch (e) {
      // Handle error silently - statistics update is not critical
    }
  }

  Future<List<Map<String, dynamic>>> _getHealthAppData(String dataType, DateTime? lastSync) async {
    // Mock health app data retrieval
    // In real implementation, would integrate with HealthKit/Google Fit
    return [
      {
        'date': DateTime.now().toIso8601String(),
        'value': 1,
      }
    ];
  }
}
