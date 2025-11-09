import '../constants/reading_constants.dart';
import 'string_utils.dart';
import 'date_utils.dart';

class ReadingUtils {
  /// Calculate reading progress and statistics
  static Map<String, dynamic> calculateReadingProgress(
    int totalPages,
    int currentPage,
    DateTime startDate,
    List<Map<String, dynamic>> readingSessions,
  ) {
    final progress = currentPage / totalPages;
    final pagesRemaining = totalPages - currentPage;
    
    // Calculate reading speed (pages per hour)
    final totalReadingTime = readingSessions.fold<int>(0, 
        (sum, session) => sum + (session['duration_minutes'] as int? ?? 0));
    final pagesRead = readingSessions.fold<int>(0, 
        (sum, session) => sum + (session['pages_read'] as int? ?? 0));
    
    final readingSpeed = totalReadingTime > 0 ? (pagesRead / (totalReadingTime / 60.0)) : 0.0;
    
    // Estimate completion time
    final hoursRemaining = readingSpeed > 0 ? pagesRemaining / readingSpeed : 0.0;
    final estimatedCompletionDate = DateTime.now().add(Duration(hours: hoursRemaining.round()));
    
    // Calculate streak
    final streak = _calculateReadingStreak(readingSessions);
    
    return {
      'progress_percentage': (progress * 100).round(),
      'pages_remaining': pagesRemaining,
      'reading_speed_pages_per_hour': readingSpeed.toStringAsFixed(1),
      'estimated_completion_date': estimatedCompletionDate,
      'estimated_hours_remaining': hoursRemaining.toStringAsFixed(1),
      'current_streak': streak,
      'total_reading_time_hours': (totalReadingTime / 60.0).toStringAsFixed(1),
      'average_session_length': totalReadingTime > 0 ? (totalReadingTime / readingSessions.length).round() : 0,
    };
  }
  
  static int _calculateReadingStreak(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0;
    
    // Sort sessions by date (most recent first)
    sessions.sort((a, b) => DateTime.parse(b['date'] as String)
        .compareTo(DateTime.parse(a['date'] as String)));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final session in sessions) {
      final sessionDate = DateTime.parse(session['date'] as String);
      final dayOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      
      if (lastDate == null) {
        // First session
        if (DateTimeUtils.isToday(dayOnly) || DateTimeUtils.isYesterday(dayOnly)) {
          streak = 1;
          lastDate = dayOnly;
        } else {
          break; // Streak broken
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (dayOnly == expectedDate) {
          streak++;
          lastDate = dayOnly;
        } else {
          break; // Streak broken
        }
      }
    }
    
    return streak;
  }
  
  /// Generate AI book recommendations based on preferences and history
  static List<Map<String, dynamic>> generateBookRecommendations(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> readingHistory,
    String recommendationType,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    final preferredGenres = userProfile['preferred_genres'] as List<String>? ?? [];
    final readingLevel = userProfile['reading_level'] as String? ?? 'intermediate';
    final currentMood = userProfile['current_mood'] as String? ?? 'neutral';
    
    switch (recommendationType) {
      case 'mood_based':
        recommendations.addAll(_generateMoodBasedRecommendations(currentMood, preferredGenres));
        break;
      case 'similar_books':
        recommendations.addAll(_generateSimilarBookRecommendations(readingHistory, preferredGenres));
        break;
      case 'trending':
        recommendations.addAll(_generateTrendingRecommendations(preferredGenres));
        break;
      case 'challenge_books':
        recommendations.addAll(_generateChallengeRecommendations(readingLevel, preferredGenres));
        break;
      default:
        recommendations.addAll(_generatePersonalizedRecommendations(userProfile, readingHistory));
    }
    
    return recommendations.take(10).toList(); // Return top 10 recommendations
  }
  
  static List<Map<String, dynamic>> _generateMoodBasedRecommendations(
    String mood,
    List<String> preferredGenres,
  ) {
    final moodBooks = ReadingConstants.moodBasedBooks[mood] ?? 
        ReadingConstants.moodBasedBooks['curious']!;
    
    final recommendations = <Map<String, dynamic>>[];
    
    // Generate book suggestions based on mood characteristics
    final characteristics = moodBooks[0]['characteristics'] as List<String>;
    
    for (final characteristic in characteristics.take(3)) {
      recommendations.add({
        'title': _generateBookTitle(characteristic),
        'author': _generateAuthorName(),
        'genre': preferredGenres.isNotEmpty ? preferredGenres.first : 'Fiction',
        'mood_match': mood,
        'characteristic': characteristic,
        'rating': (3.5 + (characteristics.indexOf(characteristic) * 0.3)).clamp(3.0, 5.0),
        'pages': 200 + (characteristic.length * 10),
        'description': _generateBookDescription(characteristic, mood),
        'recommendation_reason': 'Perfect for when you\'re feeling $mood',
      });
    }
    
    return recommendations;
  }
  
  static List<Map<String, dynamic>> _generateSimilarBookRecommendations(
    List<Map<String, dynamic>> history,
    List<String> preferredGenres,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (history.isEmpty) {
      return _generateGenericRecommendations(preferredGenres);
    }
    
    // Find highest rated books from history
    final topBooks = history.where((book) => (book['rating'] as double? ?? 0) >= 4.0).toList();
    topBooks.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    
    for (final book in topBooks.take(3)) {
      final genre = book['genre'] as String? ?? 'Fiction';
      final author = book['author'] as String? ?? 'Unknown Author';
      
      recommendations.add({
        'title': _generateSimilarBookTitle(book['title'] as String? ?? 'Great Book'),
        'author': _generateSimilarAuthor(author),
        'genre': genre,
        'rating': (book['rating'] as double? ?? 4.0) + (0.1 - 0.2), // Slightly varied rating
        'pages': (book['pages'] as int? ?? 300) + (-50 + 100), // Similar length
        'similarity_score': 0.85 + (0.1 * (recommendations.length / 10)),
        'based_on': book['title'],
        'recommendation_reason': 'Similar to "${book['title']}" which you rated highly',
      });
    }
    
    return recommendations;
  }
  
  static List<Map<String, dynamic>> _generateTrendingRecommendations(List<String> preferredGenres) {
    final recommendations = <Map<String, dynamic>>[];
    
    final trendingBooks = [
      {
        'title': 'The Midnight Library',
        'author': 'Matt Haig',
        'genre': 'Fiction',
        'trending_score': 0.95,
        'reason': 'Currently trending in literary fiction',
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'genre': 'Self-Help',
        'trending_score': 0.92,
        'reason': 'Most popular productivity book this year',
      },
      {
        'title': 'The Seven Moons of Maali Almeida',
        'author': 'Shehan Karunatilaka',
        'genre': 'Fantasy',
        'trending_score': 0.88,
        'reason': 'Award-winning fantasy novel',
      },
    ];
    
    for (final book in trendingBooks) {
      if (preferredGenres.isEmpty || preferredGenres.contains(book['genre'])) {
        recommendations.add({
          ...book,
          'rating': 4.2 + (book['trending_score'] as double * 0.8),
          'pages': 250 + (book['title'].toString().length * 5),
          'recommendation_reason': book['reason'],
        });
      }
    }
    
    return recommendations;
  }
  
  static List<Map<String, dynamic>> _generateChallengeRecommendations(
    String readingLevel,
    List<String> preferredGenres,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    final challengeBooks = {
      'beginner': [
        'The Alchemist by Paulo Coelho',
        'To Kill a Mockingbird by Harper Lee',
        'The Great Gatsby by F. Scott Fitzgerald',
      ],
      'intermediate': [
        '1984 by George Orwell',
        'Pride and Prejudice by Jane Austen',
        'The Catcher in the Rye by J.D. Salinger',
      ],
      'advanced': [
        'Ulysses by James Joyce',
        'War and Peace by Leo Tolstoy',
        'Infinite Jest by David Foster Wallace',
      ],
    };
    
    final books = challengeBooks[readingLevel] ?? challengeBooks['intermediate']!;
    
    for (final bookString in books) {
      final parts = bookString.split(' by ');
      recommendations.add({
        'title': parts[0],
        'author': parts.length > 1 ? parts[1] : 'Classic Author',
        'genre': 'Classic Literature',
        'difficulty_level': readingLevel,
        'rating': 4.0 + (0.2 * recommendations.length),
        'pages': readingLevel == 'advanced' ? 500 + (recommendations.length * 100) : 300,
        'challenge_level': 'high',
        'recommendation_reason': 'Great challenge for your current reading level',
      });
    }
    
    return recommendations;
  }
  
  static List<Map<String, dynamic>> _generatePersonalizedRecommendations(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> history,
  ) {
    // Combine multiple recommendation strategies
    final recommendations = <Map<String, dynamic>>[];
    
    final preferredGenres = userProfile['preferred_genres'] as List<String>? ?? [];
    final readingGoal = userProfile['annual_reading_goal'] as int? ?? 12;
    
    // Add variety based on reading goal
    if (readingGoal > 20) {
      // High-volume reader - suggest shorter books
      recommendations.addAll(_generateQuickReads(preferredGenres));
    } else {
      // Casual reader - suggest engaging page-turners
      recommendations.addAll(_generatePageTurners(preferredGenres));
    }
    
    return recommendations;
  }
  
  static List<Map<String, dynamic>> _generateGenericRecommendations(List<String> genres) {
    return [
      {
        'title': 'The Seven Habits of Highly Effective People',
        'author': 'Stephen Covey',
        'genre': 'Self-Help',
        'rating': 4.5,
        'pages': 372,
        'recommendation_reason': 'Popular choice for new readers',
      }
    ];
  }
  
  static List<Map<String, dynamic>> _generateQuickReads(List<String> genres) {
    return [
      {
        'title': 'The Old Man and the Sea',
        'author': 'Ernest Hemingway',
        'genre': 'Classic',
        'rating': 4.2,
        'pages': 127,
        'reading_time_hours': 2,
        'recommendation_reason': 'Perfect quick classic read',
      }
    ];
  }
  
  static List<Map<String, dynamic>> _generatePageTurners(List<String> genres) {
    return [
      {
        'title': 'The Da Vinci Code',
        'author': 'Dan Brown',
        'genre': 'Thriller',
        'rating': 4.1,
        'pages': 454,
        'page_turner_score': 0.9,
        'recommendation_reason': 'Highly engaging thriller',
      }
    ];
  }
  
  // Helper methods for generating book data
  static String _generateBookTitle(String characteristic) {
    final prefixes = ['The', 'A', 'An', 'Beyond', 'Through', 'Under'];
    final themes = {
      'upbeat': ['Joy', 'Light', 'Hope', 'Dawn'],
      'emotional': ['Heart', 'Soul', 'Tears', 'Love'],
      'thought_provoking': ['Mind', 'Truth', 'Reality', 'Wisdom'],
    };
    
    final prefix = prefixes[characteristic.length % prefixes.length];
    final theme = themes[characteristic]?.first ?? 'Story';
    return '$prefix $theme of ${StringUtils.capitalizeWords(characteristic)}';
  }
  
  static String _generateAuthorName() {
    final firstNames = ['Emma', 'James', 'Sarah', 'Michael', 'Lisa', 'David'];
    final lastNames = ['Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson'];
    
    final firstName = firstNames[DateTime.now().millisecond % firstNames.length];
    final lastName = lastNames[DateTime.now().microsecond % lastNames.length];
    return '$firstName $lastName';
  }
  
  static String _generateBookDescription(String characteristic, String mood) {
    return 'A $characteristic story perfect for when you\'re feeling $mood. '
        'This book will take you on an emotional journey that matches your current state of mind.';
  }
  
  static String _generateSimilarBookTitle(String baseTitle) {
    final variations = ['Chronicles', 'Tales', 'Stories', 'Journey', 'Adventure'];
    final variation = variations[baseTitle.length % variations.length];
    return '$variation of ${baseTitle.split(' ').last}';
  }
  
  static String _generateSimilarAuthor(String baseAuthor) {
    final parts = baseAuthor.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}. ${_generateAuthorName().split(' ').last}';
    }
    return _generateAuthorName();
  }
  
  /// Create and manage community shelves
  static Map<String, dynamic> createCommunityShelf(
    String name,
    String description,
    String shelfType,
    List<String> tags,
    Map<String, dynamic> creatorProfile,
  ) {
    return {
      'id': 'shelf_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'description': description,
      'type': shelfType,
      'tags': tags,
      'creator_id': creatorProfile['user_id'],
      'creator_name': creatorProfile['display_name'],
      'created_at': DateTime.now(),
      'book_count': 0,
      'follower_count': 0,
      'privacy': 'public',
      'books': <Map<String, dynamic>>[],
      'activity_score': 0.0,
      'last_updated': DateTime.now(),
    };
  }
  
  /// Calculate reading challenge progress
  static Map<String, dynamic> calculateChallengeProgress(
    Map<String, dynamic> challenge,
    List<Map<String, dynamic>> completedBooks,
  ) {
    final challengeType = challenge['name'] as String;
    final target = challenge['target'] as int;
    final duration = challenge['duration'] as int;
    final startDate = DateTime.parse(challenge['start_date'] as String);
    
    int progress = 0;
    
    switch (challengeType) {
      case '52 Books in a Year':
        progress = completedBooks.length;
        break;
      case 'Genre Explorer':
        final uniqueGenres = completedBooks
            .map((book) => book['genre'] as String)
            .toSet();
        progress = uniqueGenres.length;
        break;
      case 'Speed Reader':
        final thisMonth = completedBooks.where((book) {
          final completedDate = DateTime.parse(book['completed_date'] as String);
          final now = DateTime.now();
          return completedDate.year == now.year && completedDate.month == now.month;
        }).length;
        progress = thisMonth;
        break;
      case 'Classic Literature':
        final classics = completedBooks.where((book) {
          final genre = book['genre'] as String? ?? '';
          return genre.toLowerCase().contains('classic');
        }).length;
        progress = classics;
        break;
    }
    
    final progressPercentage = target > 0 ? (progress / target) * 100 : 0.0;
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final daysRemaining = duration - daysElapsed;
    
    // Calculate if on track
    final expectedProgress = target * (daysElapsed / duration);
    final onTrack = progress >= expectedProgress * 0.9; // 90% of expected
    
    return {
      'challenge_name': challengeType,
      'current_progress': progress,
      'target': target,
      'progress_percentage': progressPercentage.round(),
      'days_remaining': daysRemaining.clamp(0, duration),
      'on_track': onTrack,
      'books_behind_schedule': onTrack ? 0 : (expectedProgress - progress).ceil(),
      'estimated_completion_date': _estimateCompletionDate(
        startDate, duration, progress, target),
    };
  }
  
  static DateTime _estimateCompletionDate(
    DateTime startDate,
    int totalDuration,
    int currentProgress,
    int target,
  ) {
    if (currentProgress == 0) {
      return startDate.add(Duration(days: totalDuration));
    }
    
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final currentRate = currentProgress / daysElapsed; // books per day
    final remainingBooks = target - currentProgress;
    final estimatedDaysRemaining = remainingBooks / currentRate;
    
    return DateTime.now().add(Duration(days: estimatedDaysRemaining.round()));
  }
  
  /// Validate reading data
  static Map<String, String?> validateReadingData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final title = data['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Book title is required';
    } else if (title.length > ReadingConstants.maxBookTitleLength) {
      errors['title'] = 'Title is too long';
    }
    
    final pages = data['total_pages'] as int?;
    if (pages != null && (pages <= 0 || pages > 10000)) {
      errors['total_pages'] = 'Invalid number of pages';
    }
    
    final rating = data['rating'] as double?;
    if (rating != null && (rating < 1.0 || rating > 5.0)) {
      errors['rating'] = 'Rating must be between 1 and 5';
    }
    
    final review = data['review'] as String?;
    if (review != null && review.length > ReadingConstants.maxReviewLength) {
      errors['review'] = 'Review is too long';
    }
    
    return errors;
  }
  
  /// Get reading status color
  static String getReadingStatusColor(String status) {
    switch (status) {
      case ReadingConstants.currentlyReading:
        return '#3498DB'; // Blue
      case ReadingConstants.finished:
        return '#2ECC71'; // Green
      case ReadingConstants.toRead:
        return '#F39C12'; // Orange
      case ReadingConstants.paused:
        return '#95A5A6'; // Gray
      case ReadingConstants.abandoned:
        return '#E74C3C'; // Red
      default:
        return '#95A5A6'; // Gray
    }
  }
  
  /// Format reading time
  static String formatReadingTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}
