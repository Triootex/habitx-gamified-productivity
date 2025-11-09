import 'package:injectable/injectable.dart';
import '../../domain/entities/mental_health_entity.dart';
import '../datasources/local/mental_health_local_data_source.dart';
import '../datasources/remote/mental_health_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MentalHealthRepository {
  Future<Either<Failure, MentalHealthEntryEntity>> createEntry(String userId, Map<String, dynamic> entryData);
  Future<Either<Failure, List<MentalHealthEntryEntity>>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, CBTThoughtRecordEntity>> createThoughtRecord(String userId, Map<String, dynamic> thoughtData);
  Future<Either<Failure, List<CBTThoughtRecordEntity>>> getThoughtRecords(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, MentalHealthAssessmentEntity>> conductAssessment(String userId, String assessmentType, Map<String, dynamic> responses);
  Future<Either<Failure, List<MentalHealthAssessmentEntity>>> getUserAssessments(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getMentalHealthAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<String>>> generateCopingStrategies(String userId, String mood, List<String> triggers);
  Future<Either<Failure, Map<String, dynamic>>> analyzeMoodPatterns(String userId);
  Future<Either<Failure, List<String>>> getPersonalizedInsights(String userId);
  Future<Either<Failure, bool>> syncMentalHealthData(String userId);
}

@LazySingleton(as: MentalHealthRepository)
class MentalHealthRepositoryImpl implements MentalHealthRepository {
  final MentalHealthLocalDataSource localDataSource;
  final MentalHealthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MentalHealthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MentalHealthEntryEntity>> createEntry(String userId, Map<String, dynamic> entryData) async {
    try {
      // Create entry locally first for privacy and offline support
      final localEntry = await localDataSource.createEntry(userId, entryData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote with anonymized data
          final anonymizedData = _anonymizeEntryData(entryData);
          final remoteEntry = await remoteDataSource.createEntry(userId, anonymizedData);
          // Update local with server ID and sync status
          await localDataSource.updateEntry(localEntry.id, {
            'server_id': remoteEntry.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(localEntry); // Return local entry to preserve privacy
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateEntry(localEntry.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localEntry);
        }
      }
      
      return Right(localEntry);
    } on CacheException {
      return Left(CacheFailure('Failed to create mental health entry locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create mental health entry on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MentalHealthEntryEntity>>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local entries first for privacy and immediate response
      List<MentalHealthEntryEntity> localEntries = [];
      
      try {
        localEntries = await localDataSource.getUserEntries(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local entries
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch anonymized entries from remote for analytics backup
          final remoteEntries = await remoteDataSource.getUserEntries(userId, startDate: startDate, endDate: endDate);
          
          // Update local cache metadata only (preserve privacy)
          await localDataSource.updateEntriesMetadata(remoteEntries);
          
          return Right(localEntries); // Always return local entries for privacy
        } catch (e) {
          // Return local entries if remote fails
          return Right(localEntries);
        }
      }
      
      return Right(localEntries);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CBTThoughtRecordEntity>> createThoughtRecord(String userId, Map<String, dynamic> thoughtData) async {
    try {
      // Create thought record locally first
      final localRecord = await localDataSource.createThoughtRecord(userId, thoughtData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync anonymized data to remote
          final anonymizedData = _anonymizeThoughtData(thoughtData);
          final remoteRecord = await remoteDataSource.createThoughtRecord(userId, anonymizedData);
          // Update local with server ID and sync status
          await localDataSource.updateThoughtRecord(localRecord.id, {
            'server_id': remoteRecord.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(localRecord);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateThoughtRecord(localRecord.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localRecord);
        }
      }
      
      return Right(localRecord);
    } on CacheException {
      return Left(CacheFailure('Failed to create thought record locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create thought record on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CBTThoughtRecordEntity>>> getThoughtRecords(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      List<CBTThoughtRecordEntity> localRecords = [];
      
      try {
        localRecords = await localDataSource.getThoughtRecords(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local records
      }
      
      // For thought records, prioritize local data for privacy
      return Right(localRecords);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MentalHealthAssessmentEntity>> conductAssessment(String userId, String assessmentType, Map<String, dynamic> responses) async {
    try {
      // Conduct assessment locally first
      final localAssessment = await localDataSource.conductAssessment(userId, assessmentType, responses);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync anonymized assessment data to remote
          final anonymizedResponses = _anonymizeAssessmentData(responses);
          final remoteAssessment = await remoteDataSource.conductAssessment(userId, assessmentType, anonymizedResponses);
          // Update local with server ID and sync status
          await localDataSource.updateAssessment(localAssessment.id, {
            'server_id': remoteAssessment.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(localAssessment);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateAssessment(localAssessment.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localAssessment);
        }
      }
      
      return Right(localAssessment);
    } on CacheException {
      return Left(CacheFailure('Failed to conduct assessment locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to conduct assessment on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MentalHealthAssessmentEntity>>> getUserAssessments(String userId) async {
    try {
      List<MentalHealthAssessmentEntity> localAssessments = [];
      
      try {
        localAssessments = await localDataSource.getUserAssessments(userId);
      } on CacheException {
        // No local assessments
      }
      
      return Right(localAssessments);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMentalHealthAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Generate analytics locally to preserve privacy
      final localAnalytics = await localDataSource.getMentalHealthAnalytics(userId, startDate, endDate);
      
      if (await networkInfo.isConnected) {
        try {
          // Get aggregated insights from remote (anonymized)
          final remoteInsights = await remoteDataSource.getAggregatedInsights(userId);
          
          // Merge local analytics with remote insights
          final mergedAnalytics = {
            ...localAnalytics,
            'population_insights': remoteInsights,
          };
          
          return Right(mergedAnalytics);
        } catch (e) {
          // Return local analytics if remote fails
          return Right(localAnalytics);
        }
      }
      
      return Right(localAnalytics);
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateCopingStrategies(String userId, String mood, List<String> triggers) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteStrategies = await remoteDataSource.generateCopingStrategies(userId, mood, triggers);
          // Cache strategies locally
          await localDataSource.cacheCopingStrategies(userId, mood, triggers, remoteStrategies);
          return Right(remoteStrategies);
        } catch (e) {
          // Fall back to local strategies
          try {
            final localStrategies = await localDataSource.generateCopingStrategies(userId, mood, triggers);
            return Right(localStrategies);
          } on CacheException {
            return Left(ServerFailure('Failed to generate coping strategies and no local capability available'));
          }
        }
      } else {
        // Offline - use local strategies
        final localStrategies = await localDataSource.generateCopingStrategies(userId, mood, triggers);
        return Right(localStrategies);
      }
    } on CacheException {
      return Left(CacheFailure('No coping strategies capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> analyzeMoodPatterns(String userId) async {
    try {
      // Analyze mood patterns locally for privacy
      final localPatterns = await localDataSource.analyzeMoodPatterns(userId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get population-level patterns from remote for comparison
          final populationPatterns = await remoteDataSource.getPopulationMoodPatterns();
          
          // Merge patterns while preserving privacy
          final mergedPatterns = {
            ...localPatterns,
            'population_comparison': populationPatterns,
          };
          
          return Right(mergedPatterns);
        } catch (e) {
          // Return local patterns if remote fails
          return Right(localPatterns);
        }
      }
      
      return Right(localPatterns);
    } on CacheException {
      return Left(CacheFailure('No mood data available for pattern analysis'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPersonalizedInsights(String userId) async {
    try {
      // Generate insights locally first
      final localInsights = await localDataSource.getPersonalizedInsights(userId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get additional insights from remote based on anonymized patterns
          final remoteInsights = await remoteDataSource.getPersonalizedInsights(userId);
          
          // Combine insights
          final combinedInsights = [...localInsights, ...remoteInsights];
          
          return Right(combinedInsights);
        } catch (e) {
          // Return local insights if remote fails
          return Right(localInsights);
        }
      }
      
      return Right(localInsights);
    } on CacheException {
      return Left(CacheFailure('No data available for generating insights'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncMentalHealthData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get mental health data that needs sync (anonymized)
      final unsyncedEntries = await localDataSource.getUnsyncedEntries(userId);
      final unsyncedThoughts = await localDataSource.getUnsyncedThoughtRecords(userId);
      final unsyncedAssessments = await localDataSource.getUnsyncedAssessments(userId);

      // Sync entries (anonymized)
      for (final entry in unsyncedEntries) {
        try {
          if (entry.serverId == null) {
            // Create anonymized version on server
            final anonymizedData = _anonymizeEntryData(entry.toJson());
            final remoteEntry = await remoteDataSource.createEntry(userId, anonymizedData);
            await localDataSource.updateEntry(entry.id, {
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

      // Sync thought records (anonymized)
      for (final thought in unsyncedThoughts) {
        try {
          if (thought.serverId == null) {
            final anonymizedData = _anonymizeThoughtData(thought.toJson());
            final remoteThought = await remoteDataSource.createThoughtRecord(userId, anonymizedData);
            await localDataSource.updateThoughtRecord(thought.id, {
              'server_id': remoteThought.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync assessments (anonymized)
      for (final assessment in unsyncedAssessments) {
        try {
          if (assessment.serverId == null) {
            final anonymizedData = _anonymizeAssessmentData(assessment.responses);
            final remoteAssessment = await remoteDataSource.conductAssessment(
              userId, 
              assessment.assessmentType, 
              anonymizedData
            );
            await localDataSource.updateAssessment(assessment.id, {
              'server_id': remoteAssessment.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync mental health data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  // Privacy helper methods
  Map<String, dynamic> _anonymizeEntryData(Map<String, dynamic> entryData) {
    final anonymized = Map<String, dynamic>.from(entryData);
    
    // Remove or hash personally identifiable information
    anonymized.remove('notes');
    anonymized.remove('location');
    anonymized.remove('specific_events');
    
    // Keep aggregated data for population insights
    return {
      'mood_rating': anonymized['mood_rating'],
      'energy_level': anonymized['energy_level'],
      'stress_level': anonymized['stress_level'],
      'anxiety_level': anonymized['anxiety_level'],
      'emotions': anonymized['emotions'],
      'activities': anonymized['activities'],
      'timestamp_hour': DateTime.parse(anonymized['timestamp']).hour,
      'day_of_week': DateTime.parse(anonymized['timestamp']).weekday,
    };
  }

  Map<String, dynamic> _anonymizeThoughtData(Map<String, dynamic> thoughtData) {
    final anonymized = Map<String, dynamic>.from(thoughtData);
    
    // Remove specific thought content but keep patterns
    anonymized.remove('situation');
    anonymized.remove('automatic_thoughts');
    anonymized.remove('balanced_thought');
    
    // Keep patterns for research
    return {
      'emotions': anonymized['emotions'],
      'emotion_intensities': anonymized['emotion_intensities'],
      'cognitive_distortions': anonymized['cognitive_distortions'],
      'thought_believability': anonymized['thought_believability'],
    };
  }

  Map<String, dynamic> _anonymizeAssessmentData(Map<String, dynamic> responses) {
    // Remove free-text responses, keep numerical scores only
    final anonymized = <String, dynamic>{};
    
    responses.forEach((key, value) {
      if (value is int || value is double) {
        anonymized[key] = value;
      }
      // Skip text responses for privacy
    });
    
    return anonymized;
  }
}
