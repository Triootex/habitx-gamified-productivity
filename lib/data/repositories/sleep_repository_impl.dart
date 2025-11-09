import 'package:injectable/injectable.dart';
import '../../domain/entities/sleep_entity.dart';
import '../datasources/local/sleep_local_data_source.dart';
import '../datasources/remote/sleep_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SleepRepository {
  Future<Either<Failure, SleepSessionEntity>> startSleepTracking(String userId, Map<String, dynamic> sleepData);
  Future<Either<Failure, SleepSessionEntity>> endSleepTracking(String sessionId, Map<String, dynamic> wakeData);
  Future<Either<Failure, List<SleepSessionEntity>>> getUserSleepSessions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, SleepSessionEntity>> getSleepSession(String sessionId);
  Future<Either<Failure, Map<String, dynamic>>> getSleepAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> generateSleepRecommendations(String userId);
  Future<Either<Failure, DateTime>> calculateOptimalBedtime(String userId, DateTime targetWakeTime);
  Future<Either<Failure, List<DateTime>>> generateSmartAlarmTimes(String userId, DateTime targetWakeTime);
  Future<Either<Failure, bool>> logSleepDisturbance(String sessionId, Map<String, dynamic> disturbanceData);
  Future<Either<Failure, bool>> syncSleepData(String userId);
  Future<Either<Failure, bool>> syncWithHealthApp(String userId);
}

@LazySingleton(as: SleepRepository)
class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource localDataSource;
  final SleepRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SleepRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SleepSessionEntity>> startSleepTracking(String userId, Map<String, dynamic> sleepData) async {
    try {
      // Start sleep tracking locally first for offline support
      final localSession = await localDataSource.startSleepTracking(userId, sleepData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.startSleepTracking(userId, sleepData);
          // Update local with server ID and sync status
          await localDataSource.updateSleepSession(localSession.id, {
            'server_id': remoteSession.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateSleepSession(localSession.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to start sleep tracking locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start sleep tracking on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SleepSessionEntity>> endSleepTracking(String sessionId, Map<String, dynamic> wakeData) async {
    try {
      // End sleep tracking locally first
      final localSession = await localDataSource.endSleepTracking(sessionId, wakeData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.endSleepTracking(sessionId, wakeData);
          // Update local sync status
          await localDataSource.updateSleepSession(sessionId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateSleepSession(sessionId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to end sleep tracking locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end sleep tracking on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SleepSessionEntity>>> getUserSleepSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local sessions first for immediate UI response
      List<SleepSessionEntity> localSessions = [];
      
      try {
        localSessions = await localDataSource.getUserSleepSessions(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local sessions, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteSessions = await remoteDataSource.getUserSleepSessions(userId, startDate: startDate, endDate: endDate);
          
          // Update local cache with remote data
          await localDataSource.cacheSleepSessions(remoteSessions);
          
          return Right(remoteSessions);
        } catch (e) {
          // Return local sessions if remote fails
          if (localSessions.isNotEmpty) {
            return Right(localSessions);
          } else {
            return Left(ServerFailure('Failed to fetch sleep sessions and no local cache available'));
          }
        }
      }
      
      return Right(localSessions);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SleepSessionEntity>> getSleepSession(String sessionId) async {
    try {
      // Try local first for speed
      try {
        final localSession = await localDataSource.getSleepSession(sessionId);
        
        // If online and session needs sync, fetch from remote
        if (await networkInfo.isConnected && (!localSession.isSynced || _shouldRefresh(localSession.lastSynced))) {
          try {
            final remoteSession = await remoteDataSource.getSleepSession(sessionId);
            // Update local cache
            await localDataSource.cacheSleepSession(remoteSession);
            return Right(remoteSession);
          } catch (e) {
            // Return local if remote fails
            return Right(localSession);
          }
        }
        
        return Right(localSession);
      } on CacheException {
        // If not in local cache and online, fetch from remote
        if (await networkInfo.isConnected) {
          final remoteSession = await remoteDataSource.getSleepSession(sessionId);
          // Cache locally
          await localDataSource.cacheSleepSession(remoteSession);
          return Right(remoteSession);
        } else {
          return Left(CacheFailure('Sleep session not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch sleep session from server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSleepAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getSleepAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheSleepAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getSleepAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getSleepAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateSleepRecommendations(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteRecommendations = await remoteDataSource.generateSleepRecommendations(userId);
          // Cache recommendations locally
          await localDataSource.cacheSleepRecommendations(userId, remoteRecommendations);
          return Right(remoteRecommendations);
        } catch (e) {
          // Fall back to local recommendations
          try {
            final localRecommendations = await localDataSource.generateSleepRecommendations(userId);
            return Right(localRecommendations);
          } on CacheException {
            return Left(ServerFailure('Failed to generate recommendations and no local capability available'));
          }
        }
      } else {
        // Offline - use local recommendations
        final localRecommendations = await localDataSource.generateSleepRecommendations(userId);
        return Right(localRecommendations);
      }
    } on CacheException {
      return Left(CacheFailure('No recommendations capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> calculateOptimalBedtime(String userId, DateTime targetWakeTime) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteBedtime = await remoteDataSource.calculateOptimalBedtime(userId, targetWakeTime);
          // Cache bedtime calculation
          await localDataSource.cacheOptimalBedtime(userId, targetWakeTime, remoteBedtime);
          return Right(remoteBedtime);
        } catch (e) {
          // Fall back to local calculation
          try {
            final localBedtime = await localDataSource.calculateOptimalBedtime(userId, targetWakeTime);
            return Right(localBedtime);
          } on CacheException {
            return Left(ServerFailure('Failed to calculate optimal bedtime and no local capability available'));
          }
        }
      } else {
        // Offline - use local calculation
        final localBedtime = await localDataSource.calculateOptimalBedtime(userId, targetWakeTime);
        return Right(localBedtime);
      }
    } on CacheException {
      return Left(CacheFailure('Cannot calculate optimal bedtime locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> generateSmartAlarmTimes(String userId, DateTime targetWakeTime) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteAlarmTimes = await remoteDataSource.generateSmartAlarmTimes(userId, targetWakeTime);
          // Cache alarm times
          await localDataSource.cacheSmartAlarmTimes(userId, targetWakeTime, remoteAlarmTimes);
          return Right(remoteAlarmTimes);
        } catch (e) {
          // Fall back to local generation
          try {
            final localAlarmTimes = await localDataSource.generateSmartAlarmTimes(userId, targetWakeTime);
            return Right(localAlarmTimes);
          } on CacheException {
            return Left(ServerFailure('Failed to generate smart alarm times and no local capability available'));
          }
        }
      } else {
        // Offline - use local generation
        final localAlarmTimes = await localDataSource.generateSmartAlarmTimes(userId, targetWakeTime);
        return Right(localAlarmTimes);
      }
    } on CacheException {
      return Left(CacheFailure('Cannot generate smart alarm times locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> logSleepDisturbance(String sessionId, Map<String, dynamic> disturbanceData) async {
    try {
      // Log disturbance locally first
      await localDataSource.logSleepDisturbance(sessionId, disturbanceData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.logSleepDisturbance(sessionId, disturbanceData);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markDisturbanceForSync(sessionId, disturbanceData);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markDisturbanceForSync(sessionId, disturbanceData);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to log sleep disturbance locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncSleepData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get sleep data that needs sync
      final unsyncedSessions = await localDataSource.getUnsyncedSleepSessions(userId);
      final unsyncedDisturbances = await localDataSource.getUnsyncedDisturbances(userId);

      // Sync sleep sessions
      for (final session in unsyncedSessions) {
        try {
          if (session.serverId == null) {
            // Create on server
            final remoteSession = await remoteDataSource.startSleepTracking(userId, session.toJson());
            
            // If session is completed, also end it on server
            if (session.isCompleteSession) {
              await remoteDataSource.endSleepTracking(remoteSession.id, session.toJson());
            }
            
            await localDataSource.updateSleepSession(session.id, {
              'server_id': remoteSession.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateSleepSession(session.serverId!, session.toJson());
            await localDataSource.updateSleepSession(session.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync disturbances
      for (final disturbance in unsyncedDisturbances) {
        try {
          await remoteDataSource.logSleepDisturbance(disturbance['session_id'], disturbance);
          await localDataSource.markDisturbanceSynced(disturbance['id']);
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteSessions = await remoteDataSource.getUserSleepSessions(userId);
      await localDataSource.cacheSleepSessions(remoteSessions);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync sleep data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithHealthApp(String userId) async {
    try {
      // Import sleep data from device health app
      final healthSleepData = await localDataSource.importHealthAppSleepData(userId);
      
      // Process and store health app sleep data locally
      for (final sleepData in healthSleepData) {
        try {
          // Check if sleep session already exists for this date
          final existingSession = await localDataSource.findSleepSessionByDate(
            userId, 
            DateTime.parse(sleepData['date'])
          );
          
          if (existingSession == null) {
            // Create new sleep session from health app data
            await localDataSource.startSleepTracking(userId, {
              ...sleepData,
              'source': 'health_app',
              'tracking_method': 'automatic',
            });
          } else {
            // Update existing session with health app data
            await localDataSource.updateSleepSession(existingSession.id, {
              ...sleepData,
              'source': 'health_app_enriched',
            });
          }
        } catch (e) {
          // Continue processing other sleep data if one fails
          continue;
        }
      }
      
      // Mark health app sync timestamp
      await localDataSource.updateHealthAppSyncTimestamp(userId, DateTime.now());
      
      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.syncHealthAppSleepData(userId, healthSleepData);
        } catch (e) {
          // Health app sync to remote failed, but local sync succeeded
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to sync with health app'));
    } catch (e) {
      return Left(UnexpectedFailure('Health app sync failed: ${e.toString()}'));
    }
  }

  // Helper method to determine if data should be refreshed
  bool _shouldRefresh(DateTime? lastSynced) {
    if (lastSynced == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSynced);
    return difference.inMinutes > 5; // Refresh if older than 5 minutes
  }
}
