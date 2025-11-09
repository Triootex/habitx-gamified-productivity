import 'package:injectable/injectable.dart';
import '../../domain/entities/analytics_entity.dart';
import '../datasources/local/analytics_local_data_source.dart';
import '../datasources/remote/analytics_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, bool>> trackEvent(String userId, AnalyticsEventEntity event);
  Future<Either<Failure, UserAnalyticsEntity>> getUserAnalytics(String userId);
  Future<Either<Failure, AppAnalyticsEntity>> getAppAnalytics();
  Future<Either<Failure, List<AnalyticsEventEntity>>> getUserEvents(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, SessionTrackingEntity>> startSession(String userId, Map<String, dynamic> sessionData);
  Future<Either<Failure, SessionTrackingEntity>> endSession(String sessionId, Map<String, dynamic> completionData);
  Future<Either<Failure, Map<String, dynamic>>> getCustomAnalytics(String userId, String metricName, Map<String, dynamic> filters);
  Future<Either<Failure, Map<String, dynamic>>> generateInsights(String userId);
  Future<Either<Failure, bool>> syncAnalyticsData(String userId);
  Future<Either<Failure, Map<String, dynamic>>> exportAnalytics(String userId, String format, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> getUserAnalytics(String userId, String timeRange);
  Future<List<Map<String, dynamic>>> getHabitTrends(String userId, List<String> habitIds);
  Future<Map<String, dynamic>> getProductivityInsights(String userId);
  Future<Map<String, dynamic>> getHealthMetrics(String userId);
  Future<void> trackEvent(String userId, String eventName, Map<String, dynamic> properties);
  Future<Map<String, dynamic>> generateReport(String userId, String reportType, Map<String, dynamic> params);
  Future<List<Map<String, dynamic>>> getGoalProgress(String userId);
  Future<Map<String, dynamic>> getPredictiveAnalytics(String userId);
}

@LazySingleton(as: AnalyticsRepository)
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;
  final AnalyticsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AnalyticsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> trackEvent(String userId, AnalyticsEventEntity event) async {
    try {
      // Track event locally first for immediate processing and offline support
      await localDataSource.trackEvent(userId, event);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote analytics service
          await remoteDataSource.trackEvent(userId, event);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markEventForSync(event.id);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markEventForSync(event.id);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to track event locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserAnalyticsEntity>> getUserAnalytics(String userId) async {
    try {
      UserAnalyticsEntity? localAnalytics;
      
      try {
        localAnalytics = await localDataSource.getUserAnalytics(userId);
      } on CacheException {
        // No local analytics
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getUserAnalytics(userId);
          // Update local cache with remote data
          await localDataSource.cacheUserAnalytics(remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          if (localAnalytics != null) {
            return Right(localAnalytics);
          } else {
            return Left(ServerFailure('Failed to fetch user analytics and no local cache available'));
          }
        }
      }
      
      if (localAnalytics != null) {
        return Right(localAnalytics);
      } else {
        return Left(CacheFailure('No user analytics available'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppAnalyticsEntity>> getAppAnalytics() async {
    try {
      AppAnalyticsEntity? localAnalytics;
      
      try {
        localAnalytics = await localDataSource.getAppAnalytics();
      } on CacheException {
        // No local analytics
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getAppAnalytics();
          // Update local cache with remote data
          await localDataSource.cacheAppAnalytics(remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          if (localAnalytics != null) {
            return Right(localAnalytics);
          } else {
            return Left(ServerFailure('Failed to fetch app analytics and no local cache available'));
          }
        }
      }
      
      if (localAnalytics != null) {
        return Right(localAnalytics);
      } else {
        return Left(CacheFailure('No app analytics available'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AnalyticsEventEntity>>> getUserEvents(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      List<AnalyticsEventEntity> localEvents = [];
      
      try {
        localEvents = await localDataSource.getUserEvents(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local events
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteEvents = await remoteDataSource.getUserEvents(userId, startDate: startDate, endDate: endDate);
          await localDataSource.cacheEvents(remoteEvents);
          return Right(remoteEvents);
        } catch (e) {
          if (localEvents.isNotEmpty) {
            return Right(localEvents);
          } else {
            return Left(ServerFailure('Failed to fetch events'));
          }
        }
      }
      
      return Right(localEvents);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionTrackingEntity>> startSession(String userId, Map<String, dynamic> sessionData) async {
    try {
      // Start session locally first for immediate tracking
      final localSession = await localDataSource.startSession(userId, sessionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote analytics
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
      return Left(CacheFailure('Failed to start session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionTrackingEntity>> endSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      // End session locally first
      final localSession = await localDataSource.endSession(sessionId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote analytics
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
      return Left(CacheFailure('Failed to end session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCustomAnalytics(String userId, String metricName, Map<String, dynamic> filters) async {
    try {
      // Try to get custom analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getCustomAnalytics(userId, metricName, filters);
          // Cache custom analytics locally
          await localDataSource.cacheCustomAnalytics(userId, metricName, filters, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getCustomAnalytics(userId, metricName, filters);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch custom analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getCustomAnalytics(userId, metricName, filters);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No custom analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateInsights(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteInsights = await remoteDataSource.generateInsights(userId);
          // Cache insights locally
          await localDataSource.cacheInsights(userId, remoteInsights);
          return Right(remoteInsights);
        } catch (e) {
          // Fall back to local insights generation
          try {
            final localInsights = await localDataSource.generateInsights(userId);
            return Right(localInsights);
          } on CacheException {
            return Left(ServerFailure('Failed to generate insights and no local capability available'));
          }
        }
      } else {
        // Offline - use local insights generation
        final localInsights = await localDataSource.generateInsights(userId);
        return Right(localInsights);
      }
    } on CacheException {
      return Left(CacheFailure('No insights generation capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncAnalyticsData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get analytics data that needs sync
      final unsyncedEvents = await localDataSource.getUnsyncedEvents(userId);
      final unsyncedSessions = await localDataSource.getUnsyncedSessions(userId);

      // Sync events in batches to avoid overwhelming the server
      const batchSize = 50;
      for (int i = 0; i < unsyncedEvents.length; i += batchSize) {
        final batch = unsyncedEvents.skip(i).take(batchSize).toList();
        
        try {
          // Send batch to server
          await remoteDataSource.batchTrackEvents(userId, batch);
          
          // Mark events as synced
          for (final event in batch) {
            await localDataSource.markEventSynced(event.id);
          }
        } catch (e) {
          // Continue with next batch if one fails
          continue;
        }
      }

      // Sync sessions
      for (final session in unsyncedSessions) {
        try {
          if (session.serverId == null) {
            // Create on server
            final remoteSession = await remoteDataSource.startSession(userId, session.toJson());
            
            // If session is ended, also end it on server
            if (session.isEnded) {
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
          continue;
        }
      }

      // Fetch latest analytics from server and update local cache
      try {
        final remoteUserAnalytics = await remoteDataSource.getUserAnalytics(userId);
        await localDataSource.cacheUserAnalytics(remoteUserAnalytics);
      } catch (e) {
        // Continue even if analytics fetch fails
      }

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync analytics data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportAnalytics(String userId, String format, DateTime? startDate, DateTime? endDate) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteExport = await remoteDataSource.exportAnalytics(userId, format, startDate, endDate);
          return Right(remoteExport);
        } catch (e) {
          // Fall back to local export
          try {
            final localExport = await localDataSource.exportAnalytics(userId, format, startDate, endDate);
            return Right(localExport);
          } on CacheException {
            return Left(ServerFailure('Failed to export analytics and no local export capability available'));
          }
        }
      } else {
        // Offline - use local export
        final localExport = await localDataSource.exportAnalytics(userId, format, startDate, endDate);
        return Right(localExport);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics export capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Export failed: ${e.toString()}'));
    }
  }
}
