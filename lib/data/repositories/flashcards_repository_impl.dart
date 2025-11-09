import 'package:injectable/injectable.dart';
import '../../domain/entities/flashcards_entity.dart';
import '../datasources/local/flashcards_local_data_source.dart';
import '../datasources/remote/flashcards_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class FlashcardsRepository {
  Future<Either<Failure, FlashcardDeckEntity>> createDeck(String userId, Map<String, dynamic> deckData);
  Future<Either<Failure, FlashcardEntity>> createCard(String deckId, Map<String, dynamic> cardData);
  Future<Either<Failure, List<FlashcardDeckEntity>>> getUserDecks(String userId);
  Future<Either<Failure, List<FlashcardEntity>>> getDeckCards(String deckId);
  Future<Either<Failure, StudySessionEntity>> startStudySession(String userId, String deckId, Map<String, dynamic> sessionData);
  Future<Either<Failure, StudySessionEntity>> endStudySession(String sessionId, Map<String, dynamic> completionData);
  Future<Either<Failure, FlashcardEntity>> reviewCard(String cardId, int performance);
  Future<Either<Failure, List<FlashcardEntity>>> getCardsForReview(String deckId);
  Future<Either<Failure, Map<String, dynamic>>> getStudyAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<FlashcardEntity>>> generateAICards(String deckId, String topic, int count);
  Future<Either<Failure, bool>> syncFlashcardsData(String userId);
  Future<Either<Failure, FlashcardDeckEntity>> importDeck(String userId, Map<String, dynamic> deckData);
}

@LazySingleton(as: FlashcardsRepository)
class FlashcardsRepositoryImpl implements FlashcardsRepository {
  final FlashcardsLocalDataSource localDataSource;
  final FlashcardsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FlashcardsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FlashcardDeckEntity>> createDeck(String userId, Map<String, dynamic> deckData) async {
    try {
      // Create deck locally first for offline support
      final localDeck = await localDataSource.createDeck(userId, deckData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteDeck = await remoteDataSource.createDeck(userId, deckData);
          // Update local with server ID and sync status
          await localDataSource.updateDeck(localDeck.id, {
            'server_id': remoteDeck.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteDeck);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateDeck(localDeck.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localDeck);
        }
      }
      
      return Right(localDeck);
    } on CacheException {
      return Left(CacheFailure('Failed to create deck locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create deck on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlashcardEntity>> createCard(String deckId, Map<String, dynamic> cardData) async {
    try {
      // Create card locally first
      final localCard = await localDataSource.createCard(deckId, cardData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteCard = await remoteDataSource.createCard(deckId, cardData);
          // Update local with server ID and sync status
          await localDataSource.updateCard(localCard.id, {
            'server_id': remoteCard.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteCard);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateCard(localCard.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localCard);
        }
      }
      
      return Right(localCard);
    } on CacheException {
      return Left(CacheFailure('Failed to create card locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create card on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardDeckEntity>>> getUserDecks(String userId) async {
    try {
      // Always return local decks first for immediate UI response
      List<FlashcardDeckEntity> localDecks = [];
      
      try {
        localDecks = await localDataSource.getUserDecks(userId);
      } on CacheException {
        // No local decks, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteDecks = await remoteDataSource.getUserDecks(userId);
          
          // Update local cache with remote data
          await localDataSource.cacheDecks(remoteDecks);
          
          return Right(remoteDecks);
        } catch (e) {
          // Return local decks if remote fails
          if (localDecks.isNotEmpty) {
            return Right(localDecks);
          } else {
            return Left(ServerFailure('Failed to fetch decks and no local cache available'));
          }
        }
      }
      
      return Right(localDecks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardEntity>>> getDeckCards(String deckId) async {
    try {
      List<FlashcardEntity> localCards = [];
      
      try {
        localCards = await localDataSource.getDeckCards(deckId);
      } on CacheException {
        // No local cards
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteCards = await remoteDataSource.getDeckCards(deckId);
          await localDataSource.cacheCards(remoteCards);
          return Right(remoteCards);
        } catch (e) {
          if (localCards.isNotEmpty) {
            return Right(localCards);
          } else {
            return Left(ServerFailure('Failed to fetch deck cards'));
          }
        }
      }
      
      return Right(localCards);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> startStudySession(String userId, String deckId, Map<String, dynamic> sessionData) async {
    try {
      // Start study session locally first
      final localSession = await localDataSource.startStudySession(userId, deckId, sessionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.startStudySession(userId, deckId, sessionData);
          // Update local with server ID and sync status
          await localDataSource.updateStudySession(localSession.id, {
            'server_id': remoteSession.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateStudySession(localSession.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to start study session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start study session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> endStudySession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      // End study session locally first
      final localSession = await localDataSource.endStudySession(sessionId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteSession = await remoteDataSource.endStudySession(sessionId, completionData);
          // Update local sync status
          await localDataSource.updateStudySession(sessionId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteSession);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateStudySession(sessionId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localSession);
        }
      }
      
      return Right(localSession);
    } on CacheException {
      return Left(CacheFailure('Failed to end study session locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to end study session on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlashcardEntity>> reviewCard(String cardId, int performance) async {
    try {
      // Review card locally first (applies spaced repetition algorithm)
      final localCard = await localDataSource.reviewCard(cardId, performance);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteCard = await remoteDataSource.reviewCard(cardId, performance);
          // Update local sync status
          await localDataSource.updateCard(cardId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteCard);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateCard(cardId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localCard);
        }
      }
      
      return Right(localCard);
    } on CacheException {
      return Left(CacheFailure('Failed to review card locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to review card on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardEntity>>> getCardsForReview(String deckId) async {
    try {
      List<FlashcardEntity> localCards = [];
      
      try {
        localCards = await localDataSource.getCardsForReview(deckId);
      } on CacheException {
        // No local cards
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteCards = await remoteDataSource.getCardsForReview(deckId);
          await localDataSource.cacheCards(remoteCards);
          return Right(remoteCards);
        } catch (e) {
          if (localCards.isNotEmpty) {
            return Right(localCards);
          } else {
            return Left(ServerFailure('Failed to fetch cards for review'));
          }
        }
      }
      
      return Right(localCards);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStudyAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getStudyAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheStudyAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getStudyAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getStudyAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardEntity>>> generateAICards(String deckId, String topic, int count) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteCards = await remoteDataSource.generateAICards(deckId, topic, count);
          // Cache AI-generated cards locally
          await localDataSource.cacheCards(remoteCards);
          return Right(remoteCards);
        } catch (e) {
          // Fall back to local AI generation if available
          try {
            final localCards = await localDataSource.generateAICards(deckId, topic, count);
            return Right(localCards);
          } on CacheException {
            return Left(ServerFailure('Failed to generate AI cards and no local capability available'));
          }
        }
      } else {
        // Offline - use local AI generation if available
        try {
          final localCards = await localDataSource.generateAICards(deckId, topic, count);
          return Right(localCards);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no local AI generation available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncFlashcardsData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get flashcards data that needs sync
      final unsyncedDecks = await localDataSource.getUnsyncedDecks(userId);
      final unsyncedCards = await localDataSource.getUnsyncedCards(userId);
      final unsyncedSessions = await localDataSource.getUnsyncedStudySessions(userId);
      final unsyncedReviews = await localDataSource.getUnsyncedReviews(userId);

      // Sync decks
      for (final deck in unsyncedDecks) {
        try {
          if (deck.serverId == null) {
            // Create on server
            final remoteDeck = await remoteDataSource.createDeck(userId, deck.toJson());
            await localDataSource.updateDeck(deck.id, {
              'server_id': remoteDeck.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateDeck(deck.serverId!, deck.toJson());
            await localDataSource.updateDeck(deck.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync cards
      for (final card in unsyncedCards) {
        try {
          if (card.serverId == null) {
            final remoteCard = await remoteDataSource.createCard(card.deckId, card.toJson());
            await localDataSource.updateCard(card.id, {
              'server_id': remoteCard.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update card with latest review data
            await remoteDataSource.updateCard(card.serverId!, card.toJson());
            await localDataSource.updateCard(card.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync study sessions
      for (final session in unsyncedSessions) {
        try {
          if (session.serverId == null) {
            final remoteSession = await remoteDataSource.startStudySession(
              session.userId, 
              session.deckId, 
              session.toJson()
            );
            if (session.isCompleted) {
              await remoteDataSource.endStudySession(remoteSession.id, session.toJson());
            }
            await localDataSource.updateStudySession(session.id, {
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

      // Sync card reviews
      for (final review in unsyncedReviews) {
        try {
          await remoteDataSource.syncCardReview(review);
          await localDataSource.markReviewSynced(review['id']);
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteDecks = await remoteDataSource.getUserDecks(userId);
      await localDataSource.cacheDecks(remoteDecks);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync flashcards data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckEntity>> importDeck(String userId, Map<String, dynamic> deckData) async {
    try {
      // Import deck locally first
      final localDeck = await localDataSource.importDeck(userId, deckData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync imported deck to remote
          final remoteDeck = await remoteDataSource.importDeck(userId, deckData);
          // Update local with server ID and sync status
          await localDataSource.updateDeck(localDeck.id, {
            'server_id': remoteDeck.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteDeck);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateDeck(localDeck.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localDeck);
        }
      }
      
      return Right(localDeck);
    } on CacheException {
      return Left(CacheFailure('Failed to import deck locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to import deck on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
