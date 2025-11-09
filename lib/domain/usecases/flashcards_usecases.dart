import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/flashcards_entity.dart';
import '../../data/repositories/flashcards_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Flashcard Deck Use Case
@injectable
class CreateFlashcardDeckUseCase implements UseCase<FlashcardDeckEntity, CreateFlashcardDeckParams> {
  final FlashcardsRepository repository;

  CreateFlashcardDeckUseCase(this.repository);

  @override
  Future<Either<Failure, FlashcardDeckEntity>> call(CreateFlashcardDeckParams params) async {
    return await repository.createDeck(params.userId, params.deckData);
  }
}

class CreateFlashcardDeckParams {
  final String userId;
  final Map<String, dynamic> deckData;

  CreateFlashcardDeckParams({required this.userId, required this.deckData});
}

// Create Flashcard Use Case
@injectable
class CreateFlashcardUseCase implements UseCase<FlashcardEntity, CreateFlashcardParams> {
  final FlashcardsRepository repository;

  CreateFlashcardUseCase(this.repository);

  @override
  Future<Either<Failure, FlashcardEntity>> call(CreateFlashcardParams params) async {
    return await repository.createCard(params.deckId, params.cardData);
  }
}

class CreateFlashcardParams {
  final String deckId;
  final Map<String, dynamic> cardData;

  CreateFlashcardParams({required this.deckId, required this.cardData});
}

// Get User Flashcard Decks Use Case
@injectable
class GetUserFlashcardDecksUseCase implements UseCase<List<FlashcardDeckEntity>, String> {
  final FlashcardsRepository repository;

  GetUserFlashcardDecksUseCase(this.repository);

  @override
  Future<Either<Failure, List<FlashcardDeckEntity>>> call(String userId) async {
    return await repository.getUserDecks(userId);
  }
}

// Get Deck Cards Use Case
@injectable
class GetDeckCardsUseCase implements UseCase<List<FlashcardEntity>, String> {
  final FlashcardsRepository repository;

  GetDeckCardsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FlashcardEntity>>> call(String deckId) async {
    return await repository.getDeckCards(deckId);
  }
}

// Start Study Session Use Case
@injectable
class StartStudySessionUseCase implements UseCase<StudySessionEntity, StartStudySessionParams> {
  final FlashcardsRepository repository;

  StartStudySessionUseCase(this.repository);

  @override
  Future<Either<Failure, StudySessionEntity>> call(StartStudySessionParams params) async {
    return await repository.startStudySession(params.userId, params.deckId, params.sessionData);
  }
}

class StartStudySessionParams {
  final String userId;
  final String deckId;
  final Map<String, dynamic> sessionData;

  StartStudySessionParams({
    required this.userId,
    required this.deckId,
    required this.sessionData,
  });
}

// End Study Session Use Case
@injectable
class EndStudySessionUseCase implements UseCase<StudySessionEntity, EndStudySessionParams> {
  final FlashcardsRepository repository;

  EndStudySessionUseCase(this.repository);

  @override
  Future<Either<Failure, StudySessionEntity>> call(EndStudySessionParams params) async {
    return await repository.endStudySession(params.sessionId, params.completionData);
  }
}

class EndStudySessionParams {
  final String sessionId;
  final Map<String, dynamic> completionData;

  EndStudySessionParams({required this.sessionId, required this.completionData});
}

// Review Flashcard Use Case
@injectable
class ReviewFlashcardUseCase implements UseCase<FlashcardEntity, ReviewFlashcardParams> {
  final FlashcardsRepository repository;

  ReviewFlashcardUseCase(this.repository);

  @override
  Future<Either<Failure, FlashcardEntity>> call(ReviewFlashcardParams params) async {
    return await repository.reviewCard(params.cardId, params.performance);
  }
}

class ReviewFlashcardParams {
  final String cardId;
  final int performance; // 0-5 scale for SM-2 algorithm

  ReviewFlashcardParams({required this.cardId, required this.performance});
}

// Get Cards For Review Use Case
@injectable
class GetCardsForReviewUseCase implements UseCase<List<FlashcardEntity>, String> {
  final FlashcardsRepository repository;

  GetCardsForReviewUseCase(this.repository);

  @override
  Future<Either<Failure, List<FlashcardEntity>>> call(String deckId) async {
    return await repository.getCardsForReview(deckId);
  }
}

// Get Study Analytics Use Case
@injectable
class GetStudyAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetStudyAnalyticsParams> {
  final FlashcardsRepository repository;

  GetStudyAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetStudyAnalyticsParams params) async {
    return await repository.getStudyAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetStudyAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetStudyAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Generate AI Flashcards Use Case
@injectable
class GenerateAIFlashcardsUseCase implements UseCase<List<FlashcardEntity>, GenerateAIFlashcardsParams> {
  final FlashcardsRepository repository;

  GenerateAIFlashcardsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FlashcardEntity>>> call(GenerateAIFlashcardsParams params) async {
    return await repository.generateAICards(params.deckId, params.topic, params.count);
  }
}

class GenerateAIFlashcardsParams {
  final String deckId;
  final String topic;
  final int count;

  GenerateAIFlashcardsParams({
    required this.deckId,
    required this.topic,
    required this.count,
  });
}

// Sync Flashcards Data Use Case
@injectable
class SyncFlashcardsDataUseCase implements UseCase<bool, String> {
  final FlashcardsRepository repository;

  SyncFlashcardsDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncFlashcardsData(userId);
  }
}

// Import Flashcard Deck Use Case
@injectable
class ImportFlashcardDeckUseCase implements UseCase<FlashcardDeckEntity, ImportFlashcardDeckParams> {
  final FlashcardsRepository repository;

  ImportFlashcardDeckUseCase(this.repository);

  @override
  Future<Either<Failure, FlashcardDeckEntity>> call(ImportFlashcardDeckParams params) async {
    return await repository.importDeck(params.userId, params.deckData);
  }
}

class ImportFlashcardDeckParams {
  final String userId;
  final Map<String, dynamic> deckData;

  ImportFlashcardDeckParams({required this.userId, required this.deckData});
}

// Calculate Learning Efficiency Use Case
@injectable
class CalculateLearningEfficiencyUseCase implements UseCase<Map<String, dynamic>, String> {
  final FlashcardsRepository repository;

  CalculateLearningEfficiencyUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final decksResult = await repository.getUserDecks(userId);
      
      return decksResult.fold(
        (failure) => Left(failure),
        (decks) async {
          final efficiencyData = await _calculateLearningEfficiency(decks);
          return Right(efficiencyData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate learning efficiency: ${e.toString()}'));
    }
  }

  Future<Map<String, dynamic>> _calculateLearningEfficiency(List<FlashcardDeckEntity> decks) async {
    if (decks.isEmpty) {
      return {
        'efficiency_score': 0,
        'retention_rate': 0.0,
        'study_frequency': 0,
        'mastery_progress': 0.0,
        'time_to_mastery': 0,
        'recommendations': [
          'Create your first flashcard deck to start learning',
          'Study consistently for better retention',
        ],
      };
    }
    
    var totalCards = 0;
    var masteredCards = 0;
    var totalReviews = 0;
    var totalStudyTime = 0;
    var recentStudySessions = 0;
    
    for (final deck in decks) {
      totalCards += deck.cardCount ?? 0;
      masteredCards += deck.masteredCards ?? 0;
      totalReviews += deck.totalReviews ?? 0;
      totalStudyTime += deck.totalStudyTime ?? 0;
      
      // Count recent study sessions (last 7 days)
      if (deck.lastStudiedAt != null && 
          deck.lastStudiedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        recentStudySessions++;
      }
    }
    
    // Calculate metrics
    final retentionRate = totalCards > 0 ? (masteredCards / totalCards) : 0.0;
    final studyFrequency = (recentStudySessions / 7.0 * 100).clamp(0, 100); // Weekly frequency
    final masteryProgress = retentionRate * 100;
    
    // Estimate time to mastery (simplified calculation)
    final avgTimePerCard = totalCards > 0 ? totalStudyTime / totalCards : 0;
    final remainingCards = totalCards - masteredCards;
    final estimatedTimeToMastery = remainingCards * avgTimePerCard * 2; // Factor for spaced repetition
    
    // Calculate efficiency score (0-100)
    final efficiencyScore = (
      (retentionRate * 40) + // 40% retention
      (studyFrequency / 100 * 35) + // 35% frequency
      ((totalReviews > 0 ? (masteredCards / totalReviews) : 0) * 25) // 25% review efficiency
    ) * 100;
    
    final recommendations = _generateLearningRecommendations(
      retentionRate, studyFrequency, totalReviews, totalCards
    );
    
    return {
      'efficiency_score': efficiencyScore.round().clamp(0, 100),
      'retention_rate': double.parse((retentionRate * 100).toStringAsFixed(1)),
      'study_frequency': studyFrequency.round(),
      'mastery_progress': double.parse(masteryProgress.toStringAsFixed(1)),
      'time_to_mastery_hours': (estimatedTimeToMastery / 60).round(),
      'total_cards': totalCards,
      'mastered_cards': masteredCards,
      'total_reviews': totalReviews,
      'active_decks': decks.length,
      'recommendations': recommendations,
    };
  }

  List<String> _generateLearningRecommendations(
    double retentionRate,
    double studyFrequency,
    int totalReviews,
    int totalCards,
  ) {
    final recommendations = <String>[];
    
    if (retentionRate < 0.3) {
      recommendations.add('Focus on understanding concepts before memorizing - retention is low');
    } else if (retentionRate > 0.8) {
      recommendations.add('Excellent retention! Consider adding more challenging material');
    }
    
    if (studyFrequency < 50) {
      recommendations.add('Study more consistently - daily practice improves long-term retention');
    }
    
    if (totalReviews < totalCards * 3) {
      recommendations.add('Increase review frequency for better spaced repetition benefits');
    }
    
    recommendations.addAll([
      'Use mnemonic devices for difficult cards',
      'Review cards just before you\'re about to forget them',
      'Break large decks into smaller, focused topics',
    ]);
    
    return recommendations.take(4).toList();
  }
}

// Get Spaced Repetition Schedule Use Case
@injectable
class GetSpacedRepetitionScheduleUseCase implements UseCase<Map<String, dynamic>, String> {
  final FlashcardsRepository repository;

  GetSpacedRepetitionScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final decksResult = await repository.getUserDecks(userId);
      
      return decksResult.fold(
        (failure) => Left(failure),
        (decks) async {
          final schedule = await _generateSpacedRepetitionSchedule(decks);
          return Right(schedule);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate schedule: ${e.toString()}'));
    }
  }

  Future<Map<String, dynamic>> _generateSpacedRepetitionSchedule(List<FlashcardDeckEntity> decks) async {
    final schedule = <String, List<Map<String, dynamic>>>{};
    final now = DateTime.now();
    
    // Generate schedule for next 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dateKey = _formatDateKey(date);
      schedule[dateKey] = [];
      
      for (final deck in decks) {
        // Simulate cards due for review (in real implementation, this would come from the repository)
        final cardsDue = _estimateCardsDue(deck, date);
        
        if (cardsDue > 0) {
          schedule[dateKey]!.add({
            'deck_id': deck.id,
            'deck_name': deck.name,
            'cards_due': cardsDue,
            'estimated_time': cardsDue * 2, // 2 minutes per card average
          });
        }
      }
    }
    
    // Calculate daily totals
    final dailyTotals = <String, Map<String, dynamic>>{};
    schedule.forEach((date, deckSessions) {
      final totalCards = deckSessions.fold<int>(0, (sum, session) => sum + (session['cards_due'] as int));
      final totalTime = deckSessions.fold<int>(0, (sum, session) => sum + (session['estimated_time'] as int));
      
      dailyTotals[date] = {
        'total_cards': totalCards,
        'total_time_minutes': totalTime,
        'deck_count': deckSessions.length,
      };
    });
    
    return {
      'schedule': schedule,
      'daily_totals': dailyTotals,
      'week_summary': {
        'total_cards': dailyTotals.values.fold<int>(0, (sum, day) => sum + (day['total_cards'] as int)),
        'total_time_hours': (dailyTotals.values.fold<int>(0, (sum, day) => sum + (day['total_time_minutes'] as int)) / 60.0).round(),
        'active_decks': decks.length,
      },
    };
  }

  int _estimateCardsDue(FlashcardDeckEntity deck, DateTime date) {
    // Simplified estimation - in real implementation, this would use actual card due dates
    final daysSinceLastStudy = deck.lastStudiedAt != null 
        ? date.difference(deck.lastStudiedAt!).inDays 
        : 7;
    
    final cardCount = deck.cardCount ?? 0;
    if (cardCount == 0) return 0;
    
    // More cards due if haven't studied recently
    if (daysSinceLastStudy > 3) return (cardCount * 0.3).round();
    if (daysSinceLastStudy > 1) return (cardCount * 0.15).round();
    return (cardCount * 0.05).round();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Get Study Streaks Use Case
@injectable
class GetStudyStreaksUseCase implements UseCase<Map<String, dynamic>, String> {
  final FlashcardsRepository repository;

  GetStudyStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final decksResult = await repository.getUserDecks(userId);
      
      return decksResult.fold(
        (failure) => Left(failure),
        (decks) {
          final streakData = _calculateStudyStreaks(decks);
          return Right(streakData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate study streaks: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateStudyStreaks(List<FlashcardDeckEntity> decks) {
    if (decks.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'total_study_days': 0,
        'streak_percentage': 0.0,
        'last_study_date': null,
      };
    }
    
    // Collect all study dates (simplified - in real implementation, use actual study session dates)
    final studyDates = <DateTime>[];
    
    for (final deck in decks) {
      if (deck.lastStudiedAt != null) {
        studyDates.add(deck.lastStudiedAt!);
      }
      
      // Simulate historical study dates based on deck creation date
      if (deck.createdAt != null) {
        final daysSinceCreation = DateTime.now().difference(deck.createdAt!).inDays;
        for (int i = 0; i < daysSinceCreation; i += 2) { // Study every other day simulation
          studyDates.add(deck.createdAt!.add(Duration(days: i)));
        }
      }
    }
    
    if (studyDates.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'total_study_days': 0,
        'streak_percentage': 0.0,
        'last_study_date': null,
      };
    }
    
    // Remove duplicates and sort
    final uniqueDates = studyDates.map((date) => DateTime(date.year, date.month, date.day)).toSet().toList();
    uniqueDates.sort();
    
    // Calculate current streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if studied today or yesterday for current streak
    if (uniqueDates.isNotEmpty) {
      final lastStudyDate = uniqueDates.last;
      final daysSinceLastStudy = today.difference(lastStudyDate).inDays;
      
      if (daysSinceLastStudy <= 1) {
        currentStreak = 1;
        
        // Count consecutive days backwards
        for (int i = uniqueDates.length - 2; i >= 0; i--) {
          final currentDate = uniqueDates[i];
          final nextDate = uniqueDates[i + 1];
          
          if (nextDate.difference(currentDate).inDays == 1) {
            currentStreak++;
          } else {
            break;
          }
        }
      }
    }
    
    // Calculate longest streak
    for (int i = 1; i < uniqueDates.length; i++) {
      final prevDate = uniqueDates[i - 1];
      final currentDate = uniqueDates[i];
      
      if (currentDate.difference(prevDate).inDays == 1) {
        tempStreak++;
      } else {
        longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
        tempStreak = 1;
      }
    }
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    
    // Calculate streak percentage (days studied out of days since first study)
    final firstStudyDate = uniqueDates.first;
    final totalDaysSinceStart = today.difference(firstStudyDate).inDays + 1;
    final streakPercentage = totalDaysSinceStart > 0 ? (uniqueDates.length / totalDaysSinceStart) * 100 : 0.0;
    
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_study_days': uniqueDates.length,
      'streak_percentage': double.parse(streakPercentage.toStringAsFixed(1)),
      'last_study_date': uniqueDates.isNotEmpty ? uniqueDates.last.toIso8601String() : null,
      'first_study_date': firstStudyDate.toIso8601String(),
      'days_since_start': totalDaysSinceStart,
    };
  }
}
