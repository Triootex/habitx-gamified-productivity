import 'package:injectable/injectable.dart';
import '../../domain/entities/flashcards_entity.dart';
import '../../core/utils/flashcards_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class FlashcardsService {
  Future<FlashcardDeckEntity> createDeck(String userId, Map<String, dynamic> deckData);
  Future<FlashcardEntity> createCard(String deckId, Map<String, dynamic> cardData);
  Future<List<FlashcardDeckEntity>> getUserDecks(String userId);
  Future<List<FlashcardEntity>> getDeckCards(String deckId);
  Future<StudySessionEntity> startStudySession(String userId, String deckId, Map<String, dynamic> sessionData);
  Future<StudySessionEntity> endStudySession(String sessionId, Map<String, dynamic> completionData);
  Future<FlashcardEntity> reviewCard(String cardId, int performance);
  Future<List<FlashcardEntity>> getCardsForReview(String deckId);
  Future<Map<String, dynamic>> getStudyAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<FlashcardEntity>> generateAICards(String deckId, String topic, int count);
}

@LazySingleton(as: FlashcardsService)
class FlashcardsServiceImpl implements FlashcardsService {
  @override
  Future<FlashcardDeckEntity> createDeck(String userId, Map<String, dynamic> deckData) async {
    try {
      final now = DateTime.now();
      final deckId = 'deck_${now.millisecondsSinceEpoch}';
      
      final deck = FlashcardDeckEntity(
        id: deckId,
        userId: userId,
        name: deckData['name'] as String,
        description: deckData['description'] as String?,
        subject: deckData['subject'] as String,
        category: deckData['category'] as String? ?? 'general',
        difficulty: deckData['difficulty'] as String? ?? 'intermediate',
        language: deckData['language'] as String? ?? 'en',
        tags: (deckData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isPublic: deckData['is_public'] as bool? ?? false,
        allowCollaboration: deckData['allow_collaboration'] as bool? ?? false,
        studyGoals: deckData['study_goals'] as String?,
        targetRetentionRate: deckData['target_retention_rate'] as double? ?? 0.85,
        createdAt: now,
      );
      
      return deck;
    } catch (e) {
      throw Exception('Failed to create deck: ${e.toString()}');
    }
  }

  @override
  Future<FlashcardEntity> createCard(String deckId, Map<String, dynamic> cardData) async {
    try {
      final now = DateTime.now();
      final cardId = 'card_${now.millisecondsSinceEpoch}';
      
      final card = FlashcardEntity(
        id: cardId,
        deckId: deckId,
        front: cardData['front'] as String,
        back: cardData['back'] as String,
        cardType: cardData['card_type'] as String? ?? 'basic',
        difficulty: cardData['difficulty'] as String? ?? 'medium',
        tags: (cardData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        hints: (cardData['hints'] as List<dynamic>?)?.cast<String>() ?? [],
        examples: (cardData['examples'] as List<dynamic>?)?.cast<String>() ?? [],
        mediaUrls: (cardData['media_urls'] as List<dynamic>?)?.cast<String>() ?? [],
        audioUrl: cardData['audio_url'] as String?,
        imageUrl: cardData['image_url'] as String?,
        nextReview: now.add(const Duration(days: 1)), // Initial review tomorrow
        interval: 1,
        easeFactor: 2.5,
        repetitions: 0,
        createdAt: now,
      );
      
      return card;
    } catch (e) {
      throw Exception('Failed to create card: ${e.toString()}');
    }
  }

  @override
  Future<List<FlashcardDeckEntity>> getUserDecks(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockDecks(userId);
    } catch (e) {
      throw Exception('Failed to retrieve user decks: ${e.toString()}');
    }
  }

  @override
  Future<List<FlashcardEntity>> getDeckCards(String deckId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return _generateMockCards(deckId);
    } catch (e) {
      throw Exception('Failed to retrieve deck cards: ${e.toString()}');
    }
  }

  @override
  Future<StudySessionEntity> startStudySession(String userId, String deckId, Map<String, dynamic> sessionData) async {
    try {
      final now = DateTime.now();
      final sessionId = 'session_${now.millisecondsSinceEpoch}';
      
      final session = StudySessionEntity(
        id: sessionId,
        userId: userId,
        deckId: deckId,
        sessionType: sessionData['session_type'] as String? ?? 'review',
        studyMethod: sessionData['study_method'] as String? ?? 'spaced_repetition',
        startTime: now,
        targetCardCount: sessionData['target_count'] as int? ?? 20,
        studyGoal: sessionData['study_goal'] as String? ?? 'review_due',
        createdAt: now,
      );
      
      return session;
    } catch (e) {
      throw Exception('Failed to start study session: ${e.toString()}');
    }
  }

  @override
  Future<StudySessionEntity> endStudySession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Study session not found');
      }
      
      final now = DateTime.now();
      final duration = now.difference(session.startTime);
      
      final completedSession = session.copyWith(
        endTime: now,
        duration: duration,
        cardsStudied: completionData['cards_studied'] as int? ?? 0,
        cardsCorrect: completionData['cards_correct'] as int? ?? 0,
        cardsIncorrect: completionData['cards_incorrect'] as int? ?? 0,
        averageResponseTime: completionData['avg_response_time'] as double? ?? 0.0,
        xpEarned: _calculateStudyXP(
          completionData['cards_studied'] as int? ?? 0,
          completionData['cards_correct'] as int? ?? 0,
          duration.inMinutes,
        ),
        studyEfficiency: _calculateStudyEfficiency(completionData),
        retentionRate: _calculateRetentionRate(completionData),
        updatedAt: now,
      );
      
      return completedSession;
    } catch (e) {
      throw Exception('Failed to end study session: ${e.toString()}');
    }
  }

  @override
  Future<FlashcardEntity> reviewCard(String cardId, int performance) async {
    try {
      final card = await _getCardById(cardId);
      if (card == null) {
        throw Exception('Card not found');
      }
      
      final now = DateTime.now();
      
      // Apply SM-2 spaced repetition algorithm
      final updatedCard = FlashcardsUtils.applySM2Algorithm(
        card: card,
        performance: performance,
        reviewDate: now,
      );
      
      // Create review log
      final reviewLog = ReviewLogEntity(
        id: 'review_${now.millisecondsSinceEpoch}',
        cardId: cardId,
        userId: card.deckId, // This would be userId in real implementation
        reviewDate: now,
        performance: performance,
        responseTimeSeconds: 5, // Mock response time
        wasCorrect: performance >= 3,
        difficulty: performance <= 2 ? 'hard' : performance >= 4 ? 'easy' : 'normal',
        previousInterval: card.interval,
        newInterval: updatedCard.interval,
        previousEaseFactor: card.easeFactor,
        newEaseFactor: updatedCard.easeFactor,
      );
      
      return updatedCard;
    } catch (e) {
      throw Exception('Failed to review card: ${e.toString()}');
    }
  }

  @override
  Future<List<FlashcardEntity>> getCardsForReview(String deckId) async {
    try {
      final cards = await getDeckCards(deckId);
      final now = DateTime.now();
      
      return cards.where((card) => card.nextReview.isBefore(now) || card.nextReview.isAtSameMomentAs(now)).toList();
    } catch (e) {
      throw Exception('Failed to get cards for review: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getStudyAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final sessions = await _getUserStudySessions(userId, startDate: startDate, endDate: endDate);
      
      if (sessions.isEmpty) {
        return {
          'total_sessions': 0,
          'total_cards_studied': 0,
          'average_retention': 0.0,
          'total_study_time': 0,
        };
      }
      
      final totalSessions = sessions.length;
      final totalCards = sessions.fold<int>(0, (sum, s) => sum + s.cardsStudied);
      final totalCorrect = sessions.fold<int>(0, (sum, s) => sum + s.cardsCorrect);
      final totalTime = sessions.fold<int>(0, (sum, s) => sum + s.duration.inMinutes);
      
      final retentionRate = totalCards > 0 ? totalCorrect / totalCards : 0.0;
      
      return {
        'summary': {
          'total_sessions': totalSessions,
          'total_cards_studied': totalCards,
          'total_cards_correct': totalCorrect,
          'average_retention_rate': retentionRate,
          'total_study_time_minutes': totalTime,
          'average_session_length': totalSessions > 0 ? totalTime / totalSessions : 0,
        },
        'trends': {
          'daily_study_time': _getDailyStudyTime(sessions),
          'retention_over_time': _getRetentionTrends(sessions),
        },
        'insights': _generateStudyInsights(sessions),
      };
    } catch (e) {
      throw Exception('Failed to get study analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<FlashcardEntity>> generateAICards(String deckId, String topic, int count) async {
    try {
      return FlashcardsUtils.generateAIFlashcards(
        text: topic,
        count: count,
        deckId: deckId,
        cardType: 'basic',
        difficulty: 'medium',
      );
    } catch (e) {
      throw Exception('Failed to generate AI cards: ${e.toString()}');
    }
  }

  // Private helper methods
  List<FlashcardDeckEntity> _generateMockDecks(String userId) {
    final now = DateTime.now();
    
    return [
      FlashcardDeckEntity(
        id: 'deck_1',
        userId: userId,
        name: 'Spanish Vocabulary',
        description: 'Common Spanish words and phrases',
        subject: 'Spanish',
        category: 'language',
        difficulty: 'intermediate',
        totalCards: 50,
        newCards: 10,
        reviewCards: 25,
        masteredCards: 15,
        averageRetentionRate: 0.85,
        lastStudied: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      FlashcardDeckEntity(
        id: 'deck_2',
        userId: userId,
        name: 'Biology Terms',
        description: 'Key biology concepts and definitions',
        subject: 'Biology',
        category: 'science',
        difficulty: 'advanced',
        totalCards: 75,
        newCards: 5,
        reviewCards: 40,
        masteredCards: 30,
        averageRetentionRate: 0.78,
        lastStudied: now.subtract(const Duration(hours: 12)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  List<FlashcardEntity> _generateMockCards(String deckId) {
    final now = DateTime.now();
    
    return [
      FlashcardEntity(
        id: 'card_1',
        deckId: deckId,
        front: 'What is photosynthesis?',
        back: 'The process by which plants convert sunlight into energy',
        cardType: 'basic',
        difficulty: 'medium',
        interval: 7,
        easeFactor: 2.5,
        repetitions: 3,
        nextReview: now.add(const Duration(days: 7)),
        totalReviews: 5,
        correctReviews: 4,
        averageResponseTime: 8.5,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      FlashcardEntity(
        id: 'card_2',
        deckId: deckId,
        front: 'Hola',
        back: 'Hello',
        cardType: 'basic',
        difficulty: 'easy',
        interval: 3,
        easeFactor: 2.6,
        repetitions: 2,
        nextReview: now.subtract(const Duration(hours: 2)), // Due for review
        totalReviews: 3,
        correctReviews: 3,
        averageResponseTime: 3.2,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  Future<StudySessionEntity?> _getSessionById(String sessionId) async {
    // Mock session retrieval
    final now = DateTime.now();
    return StudySessionEntity(
      id: sessionId,
      userId: 'user_id',
      deckId: 'deck_1',
      sessionType: 'review',
      studyMethod: 'spaced_repetition',
      startTime: now.subtract(const Duration(minutes: 30)),
      targetCardCount: 20,
      createdAt: now.subtract(const Duration(minutes: 30)),
    );
  }

  Future<FlashcardEntity?> _getCardById(String cardId) async {
    final cards = _generateMockCards('deck_1');
    try {
      return cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  Future<List<StudySessionEntity>> _getUserStudySessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    final now = DateTime.now();
    
    return [
      StudySessionEntity(
        id: 'session_1',
        userId: userId,
        deckId: 'deck_1',
        sessionType: 'review',
        studyMethod: 'spaced_repetition',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1)).add(const Duration(minutes: 25)),
        duration: const Duration(minutes: 25),
        cardsStudied: 20,
        cardsCorrect: 17,
        cardsIncorrect: 3,
        xpEarned: 85,
        retentionRate: 0.85,
        studyEfficiency: 0.9,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  int _calculateStudyXP(int cardsStudied, int cardsCorrect, int durationMinutes) {
    int baseXP = cardsStudied * 2; // 2 XP per card studied
    int accuracyBonus = cardsCorrect * 3; // 3 XP bonus per correct answer
    int timeBonus = (durationMinutes / 5).round(); // 1 XP per 5 minutes
    
    return baseXP + accuracyBonus + timeBonus;
  }

  double _calculateStudyEfficiency(Map<String, dynamic> data) {
    final cardsStudied = data['cards_studied'] as int? ?? 0;
    final avgResponseTime = data['avg_response_time'] as double? ?? 0.0;
    
    if (cardsStudied == 0 || avgResponseTime == 0) return 0.0;
    
    // Efficiency based on cards per minute and response time
    final cardsPerMinute = cardsStudied / (avgResponseTime / 60.0);
    return (cardsPerMinute / 10.0).clamp(0.0, 1.0); // Normalize to 0-1
  }

  double _calculateRetentionRate(Map<String, dynamic> data) {
    final cardsStudied = data['cards_studied'] as int? ?? 0;
    final cardsCorrect = data['cards_correct'] as int? ?? 0;
    
    return cardsStudied > 0 ? cardsCorrect / cardsStudied : 0.0;
  }

  Map<String, int> _getDailyStudyTime(List<StudySessionEntity> sessions) {
    final dailyTime = <String, int>{};
    
    for (final session in sessions) {
      final dateKey = DateUtils.formatDate(session.startTime, 'yyyy-MM-dd');
      dailyTime[dateKey] = (dailyTime[dateKey] ?? 0) + session.duration.inMinutes;
    }
    
    return dailyTime;
  }

  Map<String, double> _getRetentionTrends(List<StudySessionEntity> sessions) {
    final retentionTrends = <String, double>{};
    
    for (final session in sessions) {
      final dateKey = DateUtils.formatDate(session.startTime, 'yyyy-MM-dd');
      retentionTrends[dateKey] = session.retentionRate;
    }
    
    return retentionTrends;
  }

  List<String> _generateStudyInsights(List<StudySessionEntity> sessions) {
    final insights = <String>[];
    
    if (sessions.isEmpty) {
      insights.add('Start studying to track your progress and get insights!');
      return insights;
    }
    
    final avgRetention = sessions.fold<double>(0, (sum, s) => sum + s.retentionRate) / sessions.length;
    
    if (avgRetention >= 0.9) {
      insights.add('Excellent retention rate! Your study methods are very effective.');
    } else if (avgRetention >= 0.75) {
      insights.add('Good retention rate. Consider reviewing challenging cards more frequently.');
    } else {
      insights.add('Your retention could improve. Try shorter, more frequent study sessions.');
    }
    
    final totalStudyTime = sessions.fold<int>(0, (sum, s) => sum + s.duration.inMinutes);
    if (totalStudyTime > 300) { // 5+ hours
      insights.add('Great dedication! You\'ve put in significant study time.');
    }
    
    final consistency = sessions.length;
    if (consistency >= 7) {
      insights.add('Excellent consistency! Regular study sessions are key to retention.');
    }
    
    return insights;
  }
}
