import '../constants/flashcards_constants.dart';
import 'date_utils.dart';
import 'math_utils.dart';

class FlashcardsUtils {
  /// Calculate next review date using spaced repetition algorithm (SM-2)
  static DateTime calculateNextReview(
    DateTime lastReview,
    int repetitionNumber,
    double easeFactor,
    int quality, // 0-5 rating
  ) {
    int interval = 0;
    double newEaseFactor = easeFactor;
    
    if (quality < 3) {
      // Reset repetition if quality is poor
      repetitionNumber = 0;
      interval = 1; // Review again tomorrow
    } else {
      if (repetitionNumber == 0) {
        interval = 1; // First review: 1 day
      } else if (repetitionNumber == 1) {
        interval = 6; // Second review: 6 days
      } else {
        // Calculate interval using ease factor
        interval = (repetitionNumber * newEaseFactor).round();
      }
      
      repetitionNumber++;
    }
    
    // Update ease factor
    newEaseFactor = newEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = newEaseFactor.clamp(1.3, 2.5);
    
    return lastReview.add(Duration(days: interval));
  }
  
  /// Calculate difficulty interval using Leitner system
  static int calculateLeitnerInterval(int boxNumber, bool correct) {
    if (!correct) {
      return FlashcardsConstants.leitnerBoxIntervals[1]!; // Back to box 1
    }
    
    final nextBox = (boxNumber + 1).clamp(1, 5);
    return FlashcardsConstants.leitnerBoxIntervals[nextBox]!;
  }
  
  /// Generate AI flashcards from text content
  static List<Map<String, dynamic>> generateAIFlashcards(
    String content,
    String subject,
    String difficulty,
  ) {
    final flashcards = <Map<String, dynamic>>[];
    
    // Parse content and extract key concepts
    final concepts = _extractKeyConcepts(content, subject);
    
    for (final concept in concepts) {
      final cardType = _determineCardType(concept, subject);
      final card = _createCard(concept, cardType, difficulty);
      flashcards.add(card);
    }
    
    return flashcards.take(20).toList(); // Limit to 20 cards
  }
  
  static List<Map<String, String>> _extractKeyConcepts(String content, String subject) {
    final concepts = <Map<String, String>>[];
    final sentences = content.split(RegExp(r'[.!?]+'));
    
    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.length < 20 || trimmed.length > 200) continue;
      
      // Look for definition patterns
      if (trimmed.contains(' is ') || trimmed.contains(' are ') || 
          trimmed.contains(' means ') || trimmed.contains(' refers to ')) {
        final parts = trimmed.split(RegExp(r'\s+(is|are|means|refers to)\s+'));
        if (parts.length >= 2) {
          concepts.add({
            'term': parts[0].trim(),
            'definition': parts.sublist(1).join(' ').trim(),
            'context': trimmed,
          });
        }
      }
      
      // Look for process descriptions
      if (trimmed.contains('first') || trimmed.contains('then') || 
          trimmed.contains('finally') || trimmed.contains('steps')) {
        concepts.add({
          'term': 'Process: ${trimmed.substring(0, 50)}...',
          'definition': trimmed,
          'context': 'process_description',
        });
      }
      
      // Look for formulas (for math/science subjects)
      if (subject.toLowerCase().contains('math') || subject.toLowerCase().contains('science')) {
        if (trimmed.contains('=') || trimmed.contains('formula')) {
          concepts.add({
            'term': 'Formula',
            'definition': trimmed,
            'context': 'formula',
          });
        }
      }
    }
    
    return concepts;
  }
  
  static String _determineCardType(Map<String, String> concept, String subject) {
    final context = concept['context']!;
    
    if (context == 'formula') {
      return FlashcardsConstants.basicCard; // Formula cards
    } else if (context == 'process_description') {
      return FlashcardsConstants.clozeCard; // Fill in the blanks for processes
    } else if (subject.toLowerCase().contains('language')) {
      return FlashcardsConstants.imageCard; // Visual cards for language learning
    }
    
    return FlashcardsConstants.basicCard; // Default
  }
  
  static Map<String, dynamic> _createCard(
    Map<String, String> concept,
    String cardType,
    String difficulty,
  ) {
    final card = <String, dynamic>{
      'id': 'card_${DateTime.now().millisecondsSinceEpoch}_${MathUtils.randomInt(1000, 9999)}',
      'type': cardType,
      'difficulty': difficulty,
      'created_at': DateTime.now(),
      'repetition_number': 0,
      'ease_factor': 2.5,
      'next_review': DateTime.now().add(const Duration(days: 1)),
    };
    
    switch (cardType) {
      case FlashcardsConstants.basicCard:
        card['front'] = concept['term'];
        card['back'] = concept['definition'];
        break;
        
      case FlashcardsConstants.clozeCard:
        final clozeText = _createClozeText(concept['definition']!);
        card['text'] = clozeText['text'];
        card['answers'] = clozeText['answers'];
        break;
        
      case FlashcardsConstants.multipleChoice:
        final mcq = _createMultipleChoice(concept);
        card['question'] = mcq['question'];
        card['options'] = mcq['options'];
        card['correct_answer'] = mcq['correct_answer'];
        break;
    }
    
    return card;
  }
  
  static Map<String, dynamic> _createClozeText(String text) {
    final words = text.split(' ');
    final answers = <String>[];
    
    // Replace key words with blanks (every 5th-8th word approximately)
    for (int i = 4; i < words.length; i += MathUtils.randomInt(5, 8)) {
      if (words[i].length > 3) { // Only replace meaningful words
        answers.add(words[i]);
        words[i] = '______';
      }
    }
    
    return {
      'text': words.join(' '),
      'answers': answers,
    };
  }
  
  static Map<String, dynamic> _createMultipleChoice(Map<String, String> concept) {
    final correctAnswer = concept['definition']!;
    final distractors = _generateDistractors(correctAnswer);
    
    final options = [correctAnswer, ...distractors]..shuffle();
    
    return {
      'question': 'What is ${concept['term']}?',
      'options': options,
      'correct_answer': options.indexOf(correctAnswer),
    };
  }
  
  static List<String> _generateDistractors(String correctAnswer) {
    // Generate plausible but incorrect answers
    // This would use AI in a real implementation
    return [
      'Incorrect option A',
      'Incorrect option B',
      'Incorrect option C',
    ];
  }
  
  /// Calculate study session performance
  static Map<String, dynamic> calculateSessionPerformance(
    List<Map<String, dynamic>> studiedCards,
    Duration sessionDuration,
  ) {
    if (studiedCards.isEmpty) {
      return {
        'accuracy': 0.0,
        'cards_per_minute': 0.0,
        'total_cards': 0,
        'correct_cards': 0,
        'session_rating': 0,
      };
    }
    
    final totalCards = studiedCards.length;
    final correctCards = studiedCards.where((card) => 
        (card['last_quality'] as int? ?? 0) >= 3).length;
    
    final accuracy = correctCards / totalCards;
    final cardsPerMinute = totalCards / sessionDuration.inMinutes;
    
    // Calculate session rating (1-5 stars)
    int sessionRating = 1;
    if (accuracy >= 0.9) sessionRating = 5;
    else if (accuracy >= 0.8) sessionRating = 4;
    else if (accuracy >= 0.7) sessionRating = 3;
    else if (accuracy >= 0.6) sessionRating = 2;
    
    return {
      'accuracy': accuracy,
      'cards_per_minute': cardsPerMinute,
      'total_cards': totalCards,
      'correct_cards': correctCards,
      'session_rating': sessionRating,
      'time_per_card': sessionDuration.inSeconds / totalCards,
    };
  }
  
  /// Generate spaced repetition schedule
  static List<Map<String, dynamic>> generateStudySchedule(
    List<Map<String, dynamic>> cards,
    int dailyLimit,
  ) {
    final schedule = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Sort cards by next review date
    cards.sort((a, b) => (a['next_review'] as DateTime)
        .compareTo(b['next_review'] as DateTime));
    
    // Group cards by review date
    final cardsByDate = <DateTime, List<Map<String, dynamic>>>{};
    
    for (final card in cards) {
      final reviewDate = DateTimeUtils.startOfDay(card['next_review'] as DateTime);
      cardsByDate.putIfAbsent(reviewDate, () => []).add(card);
    }
    
    // Create schedule entries
    for (final entry in cardsByDate.entries) {
      final date = entry.key;
      final dateCards = entry.value;
      
      // Split into chunks if exceeding daily limit
      for (int i = 0; i < dateCards.length; i += dailyLimit) {
        final chunk = dateCards.skip(i).take(dailyLimit).toList();
        
        schedule.add({
          'date': date.add(Duration(days: i ~/ dailyLimit)),
          'cards': chunk,
          'card_count': chunk.length,
          'estimated_duration': _estimateStudyDuration(chunk),
          'new_cards': chunk.where((c) => c['repetition_number'] == 0).length,
          'review_cards': chunk.where((c) => c['repetition_number'] > 0).length,
        });
      }
    }
    
    return schedule;
  }
  
  static Duration _estimateStudyDuration(List<Map<String, dynamic>> cards) {
    // Estimate 30 seconds per new card, 15 seconds per review card
    int totalSeconds = 0;
    
    for (final card in cards) {
      final repetitionNumber = card['repetition_number'] as int? ?? 0;
      totalSeconds += repetitionNumber == 0 ? 30 : 15;
    }
    
    return Duration(seconds: totalSeconds);
  }
  
  /// Import cards from various formats
  static List<Map<String, dynamic>> importCards(
    String content,
    String format,
    String subject,
  ) {
    final cards = <Map<String, dynamic>>[];
    
    switch (format.toLowerCase()) {
      case 'csv':
        cards.addAll(_importFromCSV(content, subject));
        break;
      case 'txt':
        cards.addAll(_importFromText(content, subject));
        break;
      case 'json':
        cards.addAll(_importFromJSON(content, subject));
        break;
      case 'xlsx':
        cards.addAll(_importFromExcel(content, subject));
        break;
    }
    
    return cards;
  }
  
  static List<Map<String, dynamic>> _importFromCSV(String content, String subject) {
    final cards = <Map<String, dynamic>>[];
    final lines = content.split('\n');
    
    // Skip header if present
    final startIndex = lines.first.toLowerCase().contains('front') ? 1 : 0;
    
    for (int i = startIndex; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length >= 2) {
        cards.add({
          'id': 'imported_${DateTime.now().millisecondsSinceEpoch}_$i',
          'type': FlashcardsConstants.basicCard,
          'front': parts[0].trim().replaceAll('"', ''),
          'back': parts[1].trim().replaceAll('"', ''),
          'subject': subject,
          'created_at': DateTime.now(),
          'repetition_number': 0,
          'ease_factor': 2.5,
          'next_review': DateTime.now(),
        });
      }
    }
    
    return cards;
  }
  
  static List<Map<String, dynamic>> _importFromText(String content, String subject) {
    final cards = <Map<String, dynamic>>[];
    final blocks = content.split('\n\n'); // Assume double newline separates cards
    
    for (int i = 0; i < blocks.length; i++) {
      final lines = blocks[i].split('\n');
      if (lines.length >= 2) {
        cards.add({
          'id': 'imported_${DateTime.now().millisecondsSinceEpoch}_$i',
          'type': FlashcardsConstants.basicCard,
          'front': lines[0].trim(),
          'back': lines.skip(1).join('\n').trim(),
          'subject': subject,
          'created_at': DateTime.now(),
          'repetition_number': 0,
          'ease_factor': 2.5,
          'next_review': DateTime.now(),
        });
      }
    }
    
    return cards;
  }
  
  static List<Map<String, dynamic>> _importFromJSON(String content, String subject) {
    // Would parse JSON content and convert to card format
    // For now, return empty list
    return [];
  }
  
  static List<Map<String, dynamic>> _importFromExcel(String content, String subject) {
    // Would parse Excel content and convert to card format
    // For now, return empty list
    return [];
  }
  
  /// Calculate retention rate over time
  static Map<String, dynamic> calculateRetentionRate(
    List<Map<String, dynamic>> studyHistory,
    Duration timeWindow,
  ) {
    final now = DateTime.now();
    final windowStart = now.subtract(timeWindow);
    
    final relevantSessions = studyHistory.where((session) =>
        (session['date'] as DateTime).isAfter(windowStart)).toList();
    
    if (relevantSessions.isEmpty) {
      return {
        'retention_rate': 0.0,
        'total_reviews': 0,
        'successful_reviews': 0,
        'trend': 'insufficient_data',
      };
    }
    
    int totalReviews = 0;
    int successfulReviews = 0;
    
    for (final session in relevantSessions) {
      final cards = session['cards'] as List<Map<String, dynamic>>? ?? [];
      totalReviews += cards.length;
      successfulReviews += cards.where((card) => 
          (card['quality'] as int? ?? 0) >= 3).length;
    }
    
    final retentionRate = totalReviews > 0 ? successfulReviews / totalReviews : 0.0;
    
    // Calculate trend
    final midPoint = relevantSessions.length ~/ 2;
    final firstHalf = relevantSessions.take(midPoint);
    final secondHalf = relevantSessions.skip(midPoint);
    
    final firstHalfRate = _calculateRateForSessions(firstHalf.toList());
    final secondHalfRate = _calculateRateForSessions(secondHalf.toList());
    
    String trend = 'stable';
    if (secondHalfRate - firstHalfRate > 0.1) {
      trend = 'improving';
    } else if (firstHalfRate - secondHalfRate > 0.1) {
      trend = 'declining';
    }
    
    return {
      'retention_rate': retentionRate,
      'total_reviews': totalReviews,
      'successful_reviews': successfulReviews,
      'trend': trend,
      'sessions_analyzed': relevantSessions.length,
    };
  }
  
  static double _calculateRateForSessions(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    int totalReviews = 0;
    int successfulReviews = 0;
    
    for (final session in sessions) {
      final cards = session['cards'] as List<Map<String, dynamic>>? ?? [];
      totalReviews += cards.length;
      successfulReviews += cards.where((card) => 
          (card['quality'] as int? ?? 0) >= 3).length;
    }
    
    return totalReviews > 0 ? successfulReviews / totalReviews : 0.0;
  }
  
  /// Validate flashcard data
  static Map<String, String?> validateCard(Map<String, dynamic> cardData) {
    final errors = <String, String?>{};
    
    final front = cardData['front'] as String?;
    if (front == null || front.trim().isEmpty) {
      errors['front'] = 'Front content is required';
    } else if (front.length > FlashcardsConstants.maxCardContentLength) {
      errors['front'] = 'Front content is too long';
    }
    
    final back = cardData['back'] as String?;
    if (back == null || back.trim().isEmpty) {
      errors['back'] = 'Back content is required';
    } else if (back.length > FlashcardsConstants.maxCardContentLength) {
      errors['back'] = 'Back content is too long';
    }
    
    final tags = cardData['tags'] as List<String>?;
    if (tags != null && tags.length > FlashcardsConstants.maxTagsPerCard) {
      errors['tags'] = 'Too many tags';
    }
    
    return errors;
  }
  
  /// Get card difficulty color
  static String getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '#2ECC71'; // Green
      case 'medium':
        return '#F39C12'; // Orange
      case 'hard':
        return '#E74C3C'; // Red
      default:
        return '#3498DB'; // Blue
    }
  }
  
  /// Format study time
  static String formatStudyTime(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
