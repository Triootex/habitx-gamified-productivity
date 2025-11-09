import 'package:injectable/injectable.dart';
import '../../domain/entities/meditation_entity.dart';
import '../datasources/local/meditation_local_data_source.dart';
import '../datasources/remote/meditation_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MeditationRepository {
  Future<Either<Failure, MeditationSessionEntity>> startSession(String userId, Map<String, dynamic> sessionData);
  Future<Either<Failure, MeditationSessionEntity>> endSession(String sessionId, Map<String, dynamic> completionData);
  Future<Either<Failure, List<MeditationSessionEntity>>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, MeditationSessionEntity>> getSession(String sessionId);
  Future<Either<Failure, List<MeditationTechniqueEntity>>> getTechniques({String? category, String? difficulty});
  Future<Either<Failure, MeditationTechniqueEntity>> getTechnique(String techniqueId);
  Future<Either<Failure, List<GuidedMeditationEntity>>> getGuidedMeditations({String? category, int? duration});
  Future<Either<Failure, GuidedMeditationEntity>> getGuidedMeditation(String meditationId);
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<String>>> getPersonalizedRecommendations(String userId);
  Future<Either<Failure, bool>> logDistraction(String sessionId, Map<String, dynamic> distractionData);
  Future<Either<Failure, bool>> syncSessions(String userId);
}

@LazySingleton(as: MeditationRepository)
class MeditationRepositoryImpl implements MeditationRepository {
  final MeditationLocalDataSource localDataSource;
  final MeditationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MeditationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MeditationSessionEntity>> startSession(String userId, Map<String, dynamic> sessionData) async {
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
      return Left(CacheFailure('Failed to start meditation session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start meditation session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MeditationSessionEntity>> endSession(String sessionId, Map<String, dynamic> completionData) async {
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
      return Left(CacheFailure('Failed to end meditation session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end meditation session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MeditationSessionEntity>>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local sessions first for immediate UI response
      List<MeditationSessionEntity> localSessions = [];
      
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
  Future<Either<Failure, MeditationSessionEntity>> getSession(String sessionId) async {
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
  Future<Either<Failure, List<MeditationTechniqueEntity>>> getTechniques({String? category, String? difficulty}) async {
    try {
      List<MeditationTechniqueEntity> localTechniques = [];
      
      try {
        localTechniques = await localDataSource.getTechniques(category: category, difficulty: difficulty);
      } on CacheException {
        // No local techniques
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteTechniques = await remoteDataSource.getTechniques(category: category, difficulty: difficulty);
          await localDataSource.cacheTechniques(remoteTechniques);
          return Right(remoteTechniques);
        } catch (e) {
          if (localTechniques.isNotEmpty) {
            return Right(localTechniques);
          } else {
            return Left(ServerFailure('Failed to fetch techniques'));
          }
        }
      }
      
      return Right(localTechniques);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MeditationTechniqueEntity>> getTechnique(String techniqueId) async {
    try {
      // Try local cache first
      try {
        final localTechnique = await localDataSource.getTechnique(techniqueId);
        return Right(localTechnique);
      } on CacheException {
        // Not in cache, try remote if online
        if (await networkInfo.isConnected) {
          final remoteTechnique = await remoteDataSource.getTechnique(techniqueId);
          await localDataSource.cacheTechnique(remoteTechnique);
          return Right(remoteTechnique);
        } else {
          return Left(CacheFailure('Technique not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch technique from server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<GuidedMeditationEntity>>> getGuidedMeditations({String? category, int? duration}) async {
    try {
      List<GuidedMeditationEntity> localMeditations = [];
      
      try {
        localMeditations = await localDataSource.getGuidedMeditations(category: category, duration: duration);
      } on CacheException {
        // No local meditations
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteMeditations = await remoteDataSource.getGuidedMeditations(category: category, duration: duration);
          await localDataSource.cacheGuidedMeditations(remoteMeditations);
          return Right(remoteMeditations);
        } catch (e) {
          if (localMeditations.isNotEmpty) {
            return Right(localMeditations);
          } else {
            return Left(ServerFailure('Failed to fetch guided meditations'));
          }
        }
      }
      
      return Right(localMeditations);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GuidedMeditationEntity>> getGuidedMeditation(String meditationId) async {
    try {
      // Try local cache first
      try {
        final localMeditation = await localDataSource.getGuidedMeditation(meditationId);
        return Right(localMeditation);
      } on CacheException {
        // Not in cache, try remote if online
        if (await networkInfo.isConnected) {
          final remoteMeditation = await remoteDataSource.getGuidedMeditation(meditationId);
          await localDataSource.cacheGuidedMeditation(remoteMeditation);
          return Right(remoteMeditation);
        } else {
          return Left(CacheFailure('Guided meditation not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch guided meditation from server'));
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
  Future<Either<Failure, bool>> syncSessions(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get sessions that need sync
      final unsyncedSessions = await localDataSource.getUnsyncedSessions(userId);
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
