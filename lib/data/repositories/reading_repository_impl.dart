import 'package:injectable/injectable.dart';
import '../../domain/entities/reading_entity.dart';
import '../datasources/local/reading_local_data_source.dart';
import '../datasources/remote/reading_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class ReadingRepository {
  Future<Either<Failure, BookEntity>> addBook(String userId, Map<String, dynamic> bookData);
  Future<Either<Failure, ReadingSessionEntity>> startReadingSession(String bookId, Map<String, dynamic> sessionData);
  Future<Either<Failure, ReadingSessionEntity>> endReadingSession(String sessionId, Map<String, dynamic> completionData);
  Future<Either<Failure, List<BookEntity>>> getUserBooks(String userId, {String? status});
  Future<Either<Failure, ReadingChallengeEntity>> createChallenge(String userId, Map<String, dynamic> challengeData);
  Future<Either<Failure, List<ReadingChallengeEntity>>> getUserChallenges(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getReadingAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<BookRecommendationEntity>>> getPersonalizedRecommendations(String userId);
  Future<Either<Failure, BookEntity>> updateReadingProgress(String bookId, int currentPage);
  Future<Either<Failure, Map<String, dynamic>>> searchBooks(String query);
  Future<Either<Failure, bool>> syncReadingData(String userId);
  Future<Either<Failure, BookEntity>> scanBookBarcode(String barcode);
}

@LazySingleton(as: ReadingRepository)
class ReadingRepositoryImpl implements ReadingRepository {
  final ReadingLocalDataSource localDataSource;
  final ReadingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReadingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BookEntity>> addBook(String userId, Map<String, dynamic> bookData) async {
    try {
      // Add book locally first for offline support
      final localBook = await localDataSource.addBook(userId, bookData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteBook = await remoteDataSource.addBook(userId, bookData);
          // Update local with server ID and sync status
          await localDataSource.updateBook(localBook.id, {
            'server_id': remoteBook.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteBook);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateBook(localBook.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localBook);
        }
      }
      
      return Right(localBook);
    } on CacheException {
      return Left(CacheFailure('Failed to add book locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to add book on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReadingSessionEntity>> startReadingSession(String bookId, Map<String, dynamic> sessionData) async {
    try {
      // Start reading session locally first
      final localSession = await localDataSource.startReadingSession(bookId, sessionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.startReadingSession(bookId, sessionData);
          // Update local with server ID and sync status
          await localDataSource.updateReadingSession(localSession.id, {
            'server_id': remoteSession.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateReadingSession(localSession.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to start reading session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start reading session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReadingSessionEntity>> endReadingSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      // End reading session locally first
      final localSession = await localDataSource.endReadingSession(sessionId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.endReadingSession(sessionId, completionData);
          // Update local sync status
          await localDataSource.updateReadingSession(sessionId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateReadingSession(sessionId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to end reading session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end reading session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getUserBooks(String userId, {String? status}) async {
    try {
      // Always return local books first for immediate UI response
      List<BookEntity> localBooks = [];
      
      try {
        localBooks = await localDataSource.getUserBooks(userId, status: status);
      } on CacheException {
        // No local books, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteBooks = await remoteDataSource.getUserBooks(userId, status: status);
          
          // Update local cache with remote data
          await localDataSource.cacheBooks(remoteBooks);
          
          return Right(remoteBooks);
        } catch (e) {
          // Return local books if remote fails
          if (localBooks.isNotEmpty) {
            return Right(localBooks);
          } else {
            return Left(ServerFailure('Failed to fetch books and no local cache available'));
          }
        }
      }
      
      return Right(localBooks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReadingChallengeEntity>> createChallenge(String userId, Map<String, dynamic> challengeData) async {
    try {
      // Create challenge locally first
      final localChallenge = await localDataSource.createChallenge(userId, challengeData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteChallenge = await remoteDataSource.createChallenge(userId, challengeData);
          // Update local with server ID and sync status
          await localDataSource.updateChallenge(localChallenge.id, {
            'server_id': remoteChallenge.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteChallenge);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateChallenge(localChallenge.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localChallenge);
        }
      }
      
      return Right(localChallenge);
    } on CacheException {
      return Left(CacheFailure('Failed to create challenge locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create challenge on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReadingChallengeEntity>>> getUserChallenges(String userId) async {
    try {
      List<ReadingChallengeEntity> localChallenges = [];
      
      try {
        localChallenges = await localDataSource.getUserChallenges(userId);
      } on CacheException {
        // No local challenges
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteChallenges = await remoteDataSource.getUserChallenges(userId);
          await localDataSource.cacheChallenges(remoteChallenges);
          return Right(remoteChallenges);
        } catch (e) {
          if (localChallenges.isNotEmpty) {
            return Right(localChallenges);
          } else {
            return Left(ServerFailure('Failed to fetch challenges'));
          }
        }
      }
      
      return Right(localChallenges);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReadingAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getReadingAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheReadingAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getReadingAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getReadingAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BookRecommendationEntity>>> getPersonalizedRecommendations(String userId) async {
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
            return Left(ServerFailure('Failed to fetch recommendations and no local capability available'));
          }
        }
      } else {
        // Offline - use local recommendations
        final localRecommendations = await localDataSource.getPersonalizedRecommendations(userId);
        return Right(localRecommendations);
      }
    } on CacheException {
      return Left(CacheFailure('No recommendations capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> updateReadingProgress(String bookId, int currentPage) async {
    try {
      // Update reading progress locally first
      final localBook = await localDataSource.updateReadingProgress(bookId, currentPage);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteBook = await remoteDataSource.updateReadingProgress(bookId, currentPage);
          // Update local sync status
          await localDataSource.updateBook(bookId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteBook);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateBook(bookId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localBook);
        }
      }
      
      return Right(localBook);
    } on CacheException {
      return Left(CacheFailure('Failed to update reading progress locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update reading progress on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchBooks(String query) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteResults = await remoteDataSource.searchBooks(query);
          // Cache search results locally
          await localDataSource.cacheBookSearchResults(query, remoteResults);
          return Right(remoteResults);
        } catch (e) {
          // Fall back to local search
          try {
            final localResults = await localDataSource.searchBooks(query);
            return Right(localResults);
          } on CacheException {
            return Left(ServerFailure('Failed to search books and no local search capability available'));
          }
        }
      } else {
        // Offline - use local search
        final localResults = await localDataSource.searchBooks(query);
        return Right(localResults);
      }
    } on CacheException {
      return Left(CacheFailure('No book search capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncReadingData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get reading data that needs sync
      final unsyncedBooks = await localDataSource.getUnsyncedBooks(userId);
      final unsyncedSessions = await localDataSource.getUnsyncedReadingSessions(userId);
      final unsyncedChallenges = await localDataSource.getUnsyncedChallenges(userId);

      // Sync books
      for (final book in unsyncedBooks) {
        try {
          if (book.serverId == null) {
            // Create on server
            final remoteBook = await remoteDataSource.addBook(userId, book.toJson());
            await localDataSource.updateBook(book.id, {
              'server_id': remoteBook.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateBook(book.serverId!, book.toJson());
            await localDataSource.updateBook(book.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync reading sessions
      for (final session in unsyncedSessions) {
        try {
          if (session.serverId == null) {
            final remoteSession = await remoteDataSource.startReadingSession(
              session.bookId, 
              session.toJson()
            );
            if (session.isCompleted) {
              await remoteDataSource.endReadingSession(remoteSession.id, session.toJson());
            }
            await localDataSource.updateReadingSession(session.id, {
              'server_id': remoteSession.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync challenges
      for (final challenge in unsyncedChallenges) {
        try {
          if (challenge.serverId == null) {
            final remoteChallenge = await remoteDataSource.createChallenge(
              challenge.userId, 
              challenge.toJson()
            );
            await localDataSource.updateChallenge(challenge.id, {
              'server_id': remoteChallenge.id,
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
      final remoteBooks = await remoteDataSource.getUserBooks(userId);
      await localDataSource.cacheBooks(remoteBooks);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync reading data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> scanBookBarcode(String barcode) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteBook = await remoteDataSource.scanBookBarcode(barcode);
          // Cache book data locally
          await localDataSource.cacheScannedBook(barcode, remoteBook);
          return Right(remoteBook);
        } catch (e) {
          // Fall back to local barcode cache
          try {
            final localBook = await localDataSource.getScannedBookFromCache(barcode);
            return Right(localBook);
          } on CacheException {
            return Left(ServerFailure('Failed to scan barcode and no cached data available'));
          }
        }
      } else {
        // Offline - check local barcode cache
        try {
          final localBook = await localDataSource.getScannedBookFromCache(barcode);
          return Right(localBook);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no cached barcode data available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
