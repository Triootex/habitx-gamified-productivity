import 'package:injectable/injectable.dart';
import '../../domain/entities/focus_entity.dart';
import '../datasources/local/focus_local_data_source.dart';
import '../datasources/remote/focus_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class FocusRepository {
  Future<Either<Failure, FocusSessionEntity>> startSession(String userId, Map<String, dynamic> sessionData);
  Future<Either<Failure, FocusSessionEntity>> endSession(String sessionId, Map<String, dynamic> completionData);
  Future<Either<Failure, List<FocusSessionEntity>>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, FocusSessionEntity>> getSession(String sessionId);
  Future<Either<Failure, PomodoroTimerEntity>> startPomodoro(String userId, Map<String, dynamic> pomodoroData);
  Future<Either<Failure, PomodoroTimerEntity>> updatePomodoro(String timerId, Map<String, dynamic> updates);
  Future<Either<Failure, bool>> pauseSession(String sessionId);
  Future<Either<Failure, bool>> resumeSession(String sessionId);
  Future<Either<Failure, bool>> logDistraction(String sessionId, Map<String, dynamic> distractionData);
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<String>>> getPersonalizedRecommendations(String userId);
  Future<Either<Failure, bool>> syncSessions(String userId);
}

@LazySingleton(as: FocusRepository)
class FocusRepositoryImpl implements FocusRepository {
  final FocusLocalDataSource localDataSource;
  final FocusRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FocusRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FocusSessionEntity>> startSession(String userId, Map<String, dynamic> sessionData) async {
    try {
      // Start session locally first for offline support
      final localSession = await localDataSource.startSession(userId, sessionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.startSession(userId, sessionData);
          // Update local with server ID and sync status
          await localDataSource.updateSession(localSession.id, {
            'server_id': remoteSession.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateSession(localSession.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to start focus session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start focus session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> endSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      // End session locally first
      final localSession = await localDataSource.endSession(sessionId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.endSession(sessionId, completionData);
          // Update local sync status
          await localDataSource.updateSession(sessionId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateSession(sessionId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to end focus session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end focus session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FocusSessionEntity>>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local sessions first for immediate UI response
      List<FocusSessionEntity> localSessions = [];
      
      try {
        localSessions = await localDataSource.getUserSessions(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local sessions, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteSessions = await remoteDataSource.getUserSessions(userId, startDate: startDate, endDate: endDate);
          
          // Update local cache with remote data
          await localDataSource.cacheSessions(remoteSessions);
          
          return Right(remoteSessions);
        } catch (e) {
          // Return local sessions if remote fails
          if (localSessions.isNotEmpty) {
            return Right(localSessions);
          } else {
            return Left(ServerFailure('Failed to fetch sessions and no local cache available'));
          }
        }
      }
      
      return Right(localSessions);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FocusSessionEntity>> getSession(String sessionId) async {
    try {
      // Try local first for speed
      try {
        final localSession = await localDataSource.getSession(sessionId);
        
        // If online and session needs sync, fetch from remote
        if (await networkInfo.isConnected && (!localSession.isSynced || _shouldRefresh(localSession.lastSynced))) {
          try {
            final remoteSession = await remoteDataSource.getSession(sessionId);
            // Update local cache
            await localDataSource.cacheSession(remoteSession);
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
          final remoteSession = await remoteDataSource.getSession(sessionId);
          // Cache locally
          await localDataSource.cacheSession(remoteSession);
          return Right(remoteSession);
        } else {
          return Left(CacheFailure('Session not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch session from server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PomodoroTimerEntity>> startPomodoro(String userId, Map<String, dynamic> pomodoroData) async {
    try {
      // Start Pomodoro locally first
      final localPomodoro = await localDataSource.startPomodoro(userId, pomodoroData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remotePomodoro = await remoteDataSource.startPomodoro(userId, pomodoroData);
          // Update local with server ID and sync status
          await localDataSource.updatePomodoro(localPomodoro.id, {
            'server_id': remotePomodoro.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remotePomodoro);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updatePomodoro(localPomodoro.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localPomodoro);
        }
      }
      
      return Right(localPomodoro);
    } on CacheException {
      return Left(CacheFailure('Failed to start Pomodoro locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start Pomodoro on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PomodoroTimerEntity>> updatePomodoro(String timerId, Map<String, dynamic> updates) async {
    try {
      // Update Pomodoro locally first
      final localPomodoro = await localDataSource.updatePomodoro(timerId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remotePomodoro = await remoteDataSource.updatePomodoro(timerId, updates);
          // Update local sync status
          await localDataSource.updatePomodoro(timerId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remotePomodoro);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updatePomodoro(timerId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localPomodoro);
        }
      }
      
      return Right(localPomodoro);
    } on CacheException {
      return Left(CacheFailure('Failed to update Pomodoro locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update Pomodoro on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> pauseSession(String sessionId) async {
    try {
      // Pause session locally first
      await localDataSource.pauseSession(sessionId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.pauseSession(sessionId);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markSessionForSync(sessionId);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markSessionForSync(sessionId);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to pause session locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resumeSession(String sessionId) async {
    try {
      // Resume session locally first
      await localDataSource.resumeSession(sessionId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.resumeSession(sessionId);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markSessionForSync(sessionId);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markSessionForSync(sessionId);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to resume session locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> logDistraction(String sessionId, Map<String, dynamic> distractionData) async {
    try {
      // Log distraction locally first
      await localDataSource.logDistraction(sessionId, distractionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.logDistraction(sessionId, distractionData);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markDistractionForSync(sessionId, distractionData);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markDistractionForSync(sessionId, distractionData);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to log distraction locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPersonalizedRecommendations(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteRecommendations = await remoteDataSource.getPersonalizedRecommendations(userId);
          // Cache recommendations locally
          await localDataSource.cacheRecommendations(userId, remoteRecommendations);
          return Right(remoteRecommendations);
        } catch (e) {
          // Fall back to local recommendations
          try {
            final localRecommendations = await localDataSource.getPersonalizedRecommendations(userId);
            return Right(localRecommendations);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch recommendations and no local cache available'));
          }
        }
      } else {
        // Offline - use local recommendations
        final localRecommendations = await localDataSource.getPersonalizedRecommendations(userId);
        return Right(localRecommendations);
      }
    } on CacheException {
      return Left(CacheFailure('No recommendations available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncSessions(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get sessions that need sync
      final unsyncedSessions = await localDataSource.getUnsyncedSessions(userId);
      final unsyncedPomodoros = await localDataSource.getUnsyncedPomodoros(userId);
      final unsyncedDistractions = await localDataSource.getUnsyncedDistractions(userId);

      // Sync session creations and updates
      for (final session in unsyncedSessions) {
        try {
          if (session.serverId == null) {
            // Create on server
            final remoteSession = await remoteDataSource.startSession(userId, session.toJson());
            
            // If session is completed, also end it on server
            if (session.isCompleted) {
              await remoteDataSource.endSession(remoteSession.id, session.toJson());
            }
            
            await localDataSource.updateSession(session.id, {
              'server_id': remoteSession.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateSession(session.serverId!, session.toJson());
            await localDataSource.updateSession(session.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Continue with other sessions if one fails
          continue;
        }
      }

      // Sync Pomodoros
      for (final pomodoro in unsyncedPomodoros) {
        try {
          if (pomodoro.serverId == null) {
            // Create on server
            final remotePomodoro = await remoteDataSource.startPomodoro(userId, pomodoro.toJson());
            await localDataSource.updatePomodoro(pomodoro.id, {
              'server_id': remotePomodoro.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updatePomodoro(pomodoro.serverId!, pomodoro.toJson());
            await localDataSource.updatePomodoro(pomodoro.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync distractions
      for (final distraction in unsyncedDistractions) {
        try {
          await remoteDataSource.logDistraction(distraction['session_id'], distraction);
          await localDataSource.markDistractionSynced(distraction['id']);
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteSessions = await remoteDataSource.getUserSessions(userId);
      await localDataSource.cacheSessions(remoteSessions);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync sessions with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
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
