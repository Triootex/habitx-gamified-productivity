import 'package:injectable/injectable.dart';
import '../../domain/entities/journal_entity.dart';
import '../datasources/local/journal_local_data_source.dart';
import '../datasources/remote/journal_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class JournalRepository {
  Future<Either<Failure, JournalEntryEntity>> createEntry(String userId, Map<String, dynamic> entryData);
  Future<Either<Failure, List<JournalEntryEntity>>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, JournalEntryEntity>> updateEntry(String entryId, Map<String, dynamic> updates);
  Future<Either<Failure, bool>> deleteEntry(String entryId);
  Future<Either<Failure, List<JournalPromptEntity>>> getPersonalizedPrompts(String userId);
  Future<Either<Failure, Map<String, dynamic>>> analyzeEntry(String entryId);
  Future<Either<Failure, Map<String, dynamic>>> getJournalAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, JournalReminderEntity>> createReminder(String userId, Map<String, dynamic> reminderData);
  Future<Either<Failure, String>> exportEntries(String userId, String format, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> getMoodCorrelations(String userId);
  Future<Either<Failure, bool>> syncJournalData(String userId);
}

@LazySingleton(as: JournalRepository)
class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;
  final JournalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  JournalRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, JournalEntryEntity>> createEntry(String userId, Map<String, dynamic> entryData) async {
    try {
      // Create entry locally first for privacy and offline support
      final localEntry = await localDataSource.createEntry(userId, entryData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync anonymized data to remote for analytics
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
      return Left(CacheFailure('Failed to create journal entry locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create journal entry on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JournalEntryEntity>>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local entries first for privacy and immediate response
      List<JournalEntryEntity> localEntries = [];
      
      try {
        localEntries = await localDataSource.getUserEntries(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local entries
      }
      
      // For journal entries, prioritize local data for privacy
      return Right(localEntries);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, JournalEntryEntity>> updateEntry(String entryId, Map<String, dynamic> updates) async {
    try {
      // Update entry locally first
      final localEntry = await localDataSource.updateEntry(entryId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync anonymized updates to remote
          final anonymizedUpdates = _anonymizeEntryData(updates);
          await remoteDataSource.updateEntry(entryId, anonymizedUpdates);
          // Update local sync status
          await localDataSource.updateEntry(entryId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(localEntry);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateEntry(entryId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localEntry);
        }
      }
      
      return Right(localEntry);
    } on CacheException {
      return Left(CacheFailure('Failed to update journal entry locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update journal entry on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEntry(String entryId) async {
    try {
      // Delete locally first
      await localDataSource.deleteEntry(entryId);
      
      if (await networkInfo.isConnected) {
        try {
          // Delete from remote
          await remoteDataSource.deleteEntry(entryId);
        } catch (e) {
          // Mark for later sync deletion
          await localDataSource.markEntryForDeletion(entryId);
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to delete journal entry locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to delete journal entry on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JournalPromptEntity>>> getPersonalizedPrompts(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remotePrompts = await remoteDataSource.getPersonalizedPrompts(userId);
          // Cache prompts locally
          await localDataSource.cachePrompts(userId, remotePrompts);
          return Right(remotePrompts);
        } catch (e) {
          // Fall back to local prompts
          try {
            final localPrompts = await localDataSource.getPersonalizedPrompts(userId);
            return Right(localPrompts);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch prompts and no local cache available'));
          }
        }
      } else {
        // Offline - use local prompts
        final localPrompts = await localDataSource.getPersonalizedPrompts(userId);
        return Right(localPrompts);
      }
    } on CacheException {
      return Left(CacheFailure('No prompts available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> analyzeEntry(String entryId) async {
    try {
      // Analyze entry locally first for privacy
      final localAnalysis = await localDataSource.analyzeEntry(entryId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get additional insights from remote (based on anonymized patterns)
          final remoteInsights = await remoteDataSource.getEntryInsights(entryId);
          
          // Merge analyses
          final mergedAnalysis = {
            ...localAnalysis,
            'population_insights': remoteInsights,
          };
          
          return Right(mergedAnalysis);
        } catch (e) {
          // Return local analysis if remote fails
          return Right(localAnalysis);
        }
      }
      
      return Right(localAnalysis);
    } on CacheException {
      return Left(CacheFailure('Cannot analyze entry locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getJournalAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Generate analytics locally to preserve privacy
      final localAnalytics = await localDataSource.getJournalAnalytics(userId, startDate, endDate);
      
      if (await networkInfo.isConnected) {
        try {
          // Get population-level insights from remote
          final populationInsights = await remoteDataSource.getPopulationInsights();
          
          // Merge analytics while preserving privacy
          final mergedAnalytics = {
            ...localAnalytics,
            'population_comparison': populationInsights,
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
  Future<Either<Failure, JournalReminderEntity>> createReminder(String userId, Map<String, dynamic> reminderData) async {
    try {
      // Create reminder locally first
      final localReminder = await localDataSource.createReminder(userId, reminderData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteReminder = await remoteDataSource.createReminder(userId, reminderData);
          // Update local with server ID and sync status
          await localDataSource.updateReminder(localReminder.id, {
            'server_id': remoteReminder.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteReminder);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateReminder(localReminder.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localReminder);
        }
      }
      
      return Right(localReminder);
    } on CacheException {
      return Left(CacheFailure('Failed to create reminder locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create reminder on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportEntries(String userId, String format, DateTime? startDate, DateTime? endDate) async {
    try {
      // Export entries locally for privacy
      final exportData = await localDataSource.exportEntries(userId, format, startDate, endDate);
      
      return Right(exportData);
    } on CacheException {
      return Left(CacheFailure('No entries available for export'));
    } catch (e) {
      return Left(UnexpectedFailure('Export failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMoodCorrelations(String userId) async {
    try {
      // Analyze mood correlations locally for privacy
      final localCorrelations = await localDataSource.getMoodCorrelations(userId);
      
      if (await networkInfo.isConnected) {
        try {
          // Get general correlation patterns from remote for comparison
          final generalPatterns = await remoteDataSource.getGeneralMoodPatterns();
          
          // Merge correlations while preserving privacy
          final mergedCorrelations = {
            ...localCorrelations,
            'general_patterns': generalPatterns,
          };
          
          return Right(mergedCorrelations);
        } catch (e) {
          // Return local correlations if remote fails
          return Right(localCorrelations);
        }
      }
      
      return Right(localCorrelations);
    } on CacheException {
      return Left(CacheFailure('No data available for mood correlation analysis'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncJournalData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get journal data that needs sync (anonymized)
      final unsyncedEntries = await localDataSource.getUnsyncedEntries(userId);
      final unsyncedReminders = await localDataSource.getUnsyncedReminders(userId);
      final entriesToDelete = await localDataSource.getEntriesMarkedForDeletion(userId);

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
          } else {
            // Update anonymized version on server
            final anonymizedData = _anonymizeEntryData(entry.toJson());
            await remoteDataSource.updateEntry(entry.serverId!, anonymizedData);
            await localDataSource.updateEntry(entry.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync reminders
      for (final reminder in unsyncedReminders) {
        try {
          if (reminder.serverId == null) {
            final remoteReminder = await remoteDataSource.createReminder(userId, reminder.toJson());
            await localDataSource.updateReminder(reminder.id, {
              'server_id': remoteReminder.id,
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
      for (final entryId in entriesToDelete) {
        try {
          await remoteDataSource.deleteEntry(entryId);
          await localDataSource.removeDeletedEntry(entryId);
        } catch (e) {
          continue;
        }
      }

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync journal data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  // Privacy helper method
  Map<String, dynamic> _anonymizeEntryData(Map<String, dynamic> entryData) {
    final anonymized = Map<String, dynamic>.from(entryData);
    
    // Remove personally identifiable content
    anonymized.remove('title');
    anonymized.remove('content');
    anonymized.remove('notes');
    anonymized.remove('location');
    anonymized.remove('attachments');
    anonymized.remove('voice_recording_url');
    
    // Keep aggregated data for population insights
    return {
      'entry_type': anonymized['entry_type'],
      'mood_rating': anonymized['mood_rating'],
      'emotions': anonymized['emotions'],
      'emotion_intensities': anonymized['emotion_intensities'],
      'word_count': anonymized['word_count'],
      'writing_time': anonymized['writing_time']?.toString(),
      'timestamp_hour': DateTime.parse(anonymized['timestamp']).hour,
      'day_of_week': DateTime.parse(anonymized['timestamp']).weekday,
      'sentiment_score': anonymized['sentiment_score'],
      'sentiment_label': anonymized['sentiment_label'],
      'key_themes': anonymized['key_themes'],
    };
  }
}
