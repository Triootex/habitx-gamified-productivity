import 'package:injectable/injectable.dart';
import '../../domain/entities/reading_entity.dart';
import '../../core/utils/reading_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class ReadingService {
  Future<BookEntity> addBook(String userId, Map<String, dynamic> bookData);
  Future<ReadingSessionEntity> startReadingSession(String bookId, Map<String, dynamic> sessionData);
  Future<ReadingSessionEntity> endReadingSession(String sessionId, Map<String, dynamic> completionData);
  Future<List<BookEntity>> getUserBooks(String userId, {String? status});
  Future<ReadingChallengeEntity> createChallenge(String userId, Map<String, dynamic> challengeData);
  Future<List<ReadingChallengeEntity>> getUserChallenges(String userId);
  Future<Map<String, dynamic>> getReadingAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<BookRecommendationEntity>> getPersonalizedRecommendations(String userId);
  Future<BookEntity> updateReadingProgress(String bookId, int currentPage);
  Future<Map<String, dynamic>> searchBooks(String query);
}

@LazySingleton(as: ReadingService)
class ReadingServiceImpl implements ReadingService {
  @override
  Future<BookEntity> addBook(String userId, Map<String, dynamic> bookData) async {
    try {
      final now = DateTime.now();
      final bookId = 'book_${now.millisecondsSinceEpoch}';
      
      final book = BookEntity(
        id: bookId,
        userId: userId,
        title: bookData['title'] as String,
        author: bookData['author'] as String,
        isbn: bookData['isbn'] as String?,
        description: bookData['description'] as String?,
        genre: bookData['genre'] as String,
        format: bookData['format'] as String? ?? 'physical',
        publisher: bookData['publisher'] as String?,
        publishedDate: bookData['published_date'] != null 
            ? DateTime.parse(bookData['published_date'] as String)
            : null,
        totalPages: bookData['total_pages'] as int?,
        language: bookData['language'] as String?,
        coverImageUrl: bookData['cover_image_url'] as String?,
        status: bookData['status'] as String? ?? 'to_read',
        tags: (bookData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isPublic: bookData['is_public'] as bool? ?? false,
        source: bookData['source'] as String? ?? 'manual',
        acquiredDate: bookData['acquired_date'] != null 
            ? DateTime.parse(bookData['acquired_date'] as String)
            : now,
        countsTowardGoal: bookData['counts_toward_goal'] as bool? ?? true,
        goalYear: bookData['goal_year'] as int?,
        createdAt: now,
      );
      
      return book;
    } catch (e) {
      throw Exception('Failed to add book: ${e.toString()}');
    }
  }

  @override
  Future<ReadingSessionEntity> startReadingSession(String bookId, Map<String, dynamic> sessionData) async {
    try {
      final now = DateTime.now();
      final sessionId = 'session_${now.millisecondsSinceEpoch}';
      
      final session = ReadingSessionEntity(
        id: sessionId,
        bookId: bookId,
        userId: sessionData['user_id'] as String,
        startTime: now,
        startPage: sessionData['start_page'] as int,
        endPage: sessionData['start_page'] as int, // Will be updated on end
        pagesRead: 0,
        duration: Duration.zero,
        location: sessionData['location'] as String?,
        environment: sessionData['environment'] as String?,
        mood: sessionData['mood'] as String?,
        focusLevel: sessionData['focus_level'] as int?,
        distractions: (sessionData['distractions'] as List<dynamic>?)?.cast<String>() ?? [],
      );
      
      return session;
    } catch (e) {
      throw Exception('Failed to start reading session: ${e.toString()}');
    }
  }

  @override
  Future<ReadingSessionEntity> endReadingSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Reading session not found');
      }
      
      final now = DateTime.now();
      final endPage = completionData['end_page'] as int;
      final pagesRead = endPage - session.startPage;
      final duration = now.difference(session.startTime);
      
      final completedSession = session.copyWith(
        endTime: now,
        endPage: endPage,
        pagesRead: pagesRead,
        duration: duration,
        notes: completionData['notes'] as String?,
        highlightedQuotes: (completionData['quotes'] as List<dynamic>?)?.cast<String>() ?? [],
        wasInterrupted: completionData['was_interrupted'] as bool? ?? false,
        interruptionReason: completionData['interruption_reason'] as String?,
      );
      
      // Update book progress
      await _updateBookProgress(session.bookId, endPage);
      
      return completedSession;
    } catch (e) {
      throw Exception('Failed to end reading session: ${e.toString()}');
    }
  }

  @override
  Future<List<BookEntity>> getUserBooks(String userId, {String? status}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final mockBooks = _generateMockBooks(userId);
      
      if (status != null) {
        return mockBooks.where((book) => book.status == status).toList();
      }
      
      return mockBooks;
    } catch (e) {
      throw Exception('Failed to retrieve user books: ${e.toString()}');
    }
  }

  @override
  Future<ReadingChallengeEntity> createChallenge(String userId, Map<String, dynamic> challengeData) async {
    try {
      final now = DateTime.now();
      final challengeId = 'challenge_${now.millisecondsSinceEpoch}';
      
      final challenge = ReadingChallengeEntity(
        id: challengeId,
        userId: userId,
        name: challengeData['name'] as String,
        description: challengeData['description'] as String,
        challengeType: challengeData['challenge_type'] as String? ?? 'yearly_goal',
        rules: Map<String, dynamic>.from(challengeData['rules'] ?? {}),
        startDate: DateTime.parse(challengeData['start_date'] as String),
        endDate: DateTime.parse(challengeData['end_date'] as String),
        targetCount: challengeData['target_count'] as int,
        isPublic: challengeData['is_public'] as bool? ?? false,
        allowJoining: challengeData['allow_joining'] as bool? ?? true,
        joinRequirement: challengeData['join_requirement'] as String? ?? 'open',
        maxParticipants: challengeData['max_participants'] as int? ?? 100,
        xpReward: challengeData['xp_reward'] as int? ?? 0,
        badges: (challengeData['badges'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: now,
      );
      
      return challenge;
    } catch (e) {
      throw Exception('Failed to create reading challenge: ${e.toString()}');
    }
  }

  @override
  Future<List<ReadingChallengeEntity>> getUserChallenges(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return _generateMockChallenges(userId);
    } catch (e) {
      throw Exception('Failed to retrieve user challenges: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getReadingAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final books = await getUserBooks(userId);
      final sessions = await _getUserReadingSessions(userId, startDate: startDate, endDate: endDate);
      
      if (books.isEmpty && sessions.isEmpty) {
        return {
          'total_books': 0,
          'books_read': 0,
          'total_pages': 0,
          'total_reading_time': 0,
        };
      }
      
      final booksRead = books.where((b) => b.status == 'finished').length;
      final totalPages = sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
      final totalTime = sessions.fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);
      
      // Reading speed calculation
      final readingSpeed = ReadingUtils.calculateReadingStatistics(
        sessions: sessions,
        books: books,
      );
      
      // Genre analysis
      final genreBreakdown = <String, int>{};
      for (final book in books.where((b) => b.status == 'finished')) {
        genreBreakdown[book.genre] = (genreBreakdown[book.genre] ?? 0) + 1;
      }
      
      // Monthly reading trends
      final monthlyReading = <String, Map<String, int>>{};
      for (final book in books.where((b) => b.finishedReading != null)) {
        final monthKey = DateUtils.formatDate(book.finishedReading!, 'yyyy-MM');
        monthlyReading.putIfAbsent(monthKey, () => {'books': 0, 'pages': 0});
        monthlyReading[monthKey]!['books'] = monthlyReading[monthKey]!['books']! + 1;
        monthlyReading[monthKey]!['pages'] = monthlyReading[monthKey]!['pages']! + (book.totalPages ?? 0);
      }
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 365))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_books': books.length,
          'books_read': booksRead,
          'books_currently_reading': books.where((b) => b.status == 'currently_reading').length,
          'total_pages_read': totalPages,
          'total_reading_time_minutes': totalTime.inMinutes,
          'average_reading_speed': readingSpeed['pages_per_minute'],
          'average_session_length': sessions.isNotEmpty ? totalTime.inMinutes / sessions.length : 0,
        },
        'breakdown': {
          'by_genre': genreBreakdown,
          'by_format': _getFormatBreakdown(books),
          'by_rating': _getRatingDistribution(books),
        },
        'trends': {
          'monthly_reading': monthlyReading,
          'reading_consistency': _calculateReadingConsistency(sessions),
        },
        'insights': _generateReadingInsights(books, sessions),
      };
    } catch (e) {
      throw Exception('Failed to get reading analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<BookRecommendationEntity>> getPersonalizedRecommendations(String userId) async {
    try {
      final userBooks = await getUserBooks(userId);
      
      return ReadingUtils.generateAIRecommendations(
        userId: userId,
        readBooks: userBooks.where((b) => b.status == 'finished').toList(),
        preferredGenres: _extractPreferredGenres(userBooks),
        currentMood: 'neutral', // Mock mood
        readingGoals: ['expand_genres', 'quick_reads'], // Mock goals
        timeAvailable: 60, // Mock available time
      );
    } catch (e) {
      throw Exception('Failed to get personalized recommendations: ${e.toString()}');
    }
  }

  @override
  Future<BookEntity> updateReadingProgress(String bookId, int currentPage) async {
    try {
      final book = await _getBookById(bookId);
      if (book == null) {
        throw Exception('Book not found');
      }
      
      final now = DateTime.now();
      final progressPercentage = book.totalPages != null && book.totalPages! > 0
          ? (currentPage / book.totalPages!).clamp(0.0, 1.0)
          : 0.0;
      
      // Check if book is completed
      String newStatus = book.status;
      DateTime? finishedDate;
      
      if (book.totalPages != null && currentPage >= book.totalPages!) {
        newStatus = 'finished';
        finishedDate = now;
      } else if (currentPage > 0 && book.status == 'to_read') {
        newStatus = 'currently_reading';
      }
      
      return book.copyWith(
        currentPage: currentPage,
        progressPercentage: progressPercentage,
        status: newStatus,
        startedReading: book.startedReading ?? (currentPage > 0 ? now : null),
        finishedReading: finishedDate,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update reading progress: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> searchBooks(String query) async {
    try {
      // Mock book search - in real implementation, would call book API
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockResults = [
        {
          'title': 'The Great Gatsby',
          'author': 'F. Scott Fitzgerald',
          'isbn': '9780743273565',
          'genre': 'Classic Literature',
          'published_year': 1925,
          'cover_url': 'https://example.com/gatsby.jpg',
          'description': 'A classic novel about the Jazz Age in America.',
        },
        {
          'title': 'To Kill a Mockingbird',
          'author': 'Harper Lee',
          'isbn': '9780446310789',
          'genre': 'Classic Literature',
          'published_year': 1960,
          'cover_url': 'https://example.com/mockingbird.jpg',
          'description': 'A gripping tale of racial injustice and childhood innocence.',
        },
      ];
      
      // Filter results based on query
      final filteredResults = mockResults.where((book) {
        final searchText = '${book['title']} ${book['author']}'.toLowerCase();
        return searchText.contains(query.toLowerCase());
      }).toList();
      
      return {
        'query': query,
        'total_results': filteredResults.length,
        'results': filteredResults,
      };
    } catch (e) {
      throw Exception('Failed to search books: ${e.toString()}');
    }
  }

  // Private helper methods
  List<BookEntity> _generateMockBooks(String userId) {
    final now = DateTime.now();
    
    return [
      BookEntity(
        id: 'book_1',
        userId: userId,
        title: 'The Psychology of Money',
        author: 'Morgan Housel',
        genre: 'Finance',
        format: 'physical',
        totalPages: 252,
        currentPage: 120,
        progressPercentage: 0.48,
        status: 'currently_reading',
        startedReading: now.subtract(const Duration(days: 10)),
        userRating: 4.5,
        tags: ['finance', 'psychology', 'investing'],
        isPublic: false,
        source: 'purchased',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      BookEntity(
        id: 'book_2',
        userId: userId,
        title: 'Atomic Habits',
        author: 'James Clear',
        genre: 'Self-Help',
        format: 'ebook',
        totalPages: 320,
        currentPage: 320,
        progressPercentage: 1.0,
        status: 'finished',
        startedReading: now.subtract(const Duration(days: 30)),
        finishedReading: now.subtract(const Duration(days: 5)),
        userRating: 5.0,
        userReview: 'Excellent book on building good habits!',
        tags: ['habits', 'productivity', 'self-improvement'],
        isPublic: true,
        source: 'purchased',
        totalReadingTime: const Duration(hours: 8, minutes: 30),
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ];
  }

  List<ReadingChallengeEntity> _generateMockChallenges(String userId) {
    final now = DateTime.now();
    
    return [
      ReadingChallengeEntity(
        id: 'challenge_1',
        userId: userId,
        name: '2024 Reading Challenge',
        description: 'Read 24 books in 2024',
        challengeType: 'yearly_goal',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        targetCount: 24,
        currentCount: 8,
        progressPercentage: 8 / 24,
        completedBookIds: ['book_2'],
        isPublic: true,
        participantCount: 156,
        xpReward: 500,
        status: 'active',
        createdAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  Future<ReadingSessionEntity?> _getSessionById(String sessionId) async {
    // Mock session retrieval
    final now = DateTime.now();
    return ReadingSessionEntity(
      id: sessionId,
      bookId: 'book_1',
      userId: 'user_id',
      startTime: now.subtract(const Duration(minutes: 30)),
      startPage: 100,
      endPage: 100,
      pagesRead: 0,
      duration: Duration.zero,
    );
  }

  Future<BookEntity?> _getBookById(String bookId) async {
    final books = _generateMockBooks('user_id');
    try {
      return books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReadingSessionEntity>> _getUserReadingSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    final now = DateTime.now();
    
    return [
      ReadingSessionEntity(
        id: 'session_1',
        bookId: 'book_1',
        userId: userId,
        startTime: now.subtract(const Duration(days: 1, hours: 1)),
        endTime: now.subtract(const Duration(days: 1)),
        startPage: 100,
        endPage: 115,
        pagesRead: 15,
        duration: const Duration(hours: 1),
        location: 'home',
        environment: 'quiet',
        mood: 'focused',
        focusLevel: 8,
      ),
    ];
  }

  Future<void> _updateBookProgress(String bookId, int currentPage) async {
    // Mock progress update
    print('Updated book $bookId progress to page $currentPage');
  }

  List<String> _extractPreferredGenres(List<BookEntity> books) {
    final genreCounts = <String, int>{};
    
    for (final book in books.where((b) => b.status == 'finished')) {
      genreCounts[book.genre] = (genreCounts[book.genre] ?? 0) + 1;
    }
    
    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedGenres.take(3).map((e) => e.key).toList();
  }

  Map<String, int> _getFormatBreakdown(List<BookEntity> books) {
    final breakdown = <String, int>{};
    
    for (final book in books) {
      breakdown[book.format] = (breakdown[book.format] ?? 0) + 1;
    }
    
    return breakdown;
  }

  Map<String, int> _getRatingDistribution(List<BookEntity> books) {
    final distribution = <String, int>{
      '5_stars': 0,
      '4_stars': 0,
      '3_stars': 0,
      '2_stars': 0,
      '1_star': 0,
      'unrated': 0,
    };
    
    for (final book in books.where((b) => b.status == 'finished')) {
      if (book.userRating == null) {
        distribution['unrated'] = distribution['unrated']! + 1;
      } else if (book.userRating! >= 4.5) {
        distribution['5_stars'] = distribution['5_stars']! + 1;
      } else if (book.userRating! >= 3.5) {
        distribution['4_stars'] = distribution['4_stars']! + 1;
      } else if (book.userRating! >= 2.5) {
        distribution['3_stars'] = distribution['3_stars']! + 1;
      } else if (book.userRating! >= 1.5) {
        distribution['2_stars'] = distribution['2_stars']! + 1;
      } else {
        distribution['1_star'] = distribution['1_star']! + 1;
      }
    }
    
    return distribution;
  }

  double _calculateReadingConsistency(List<ReadingSessionEntity> sessions) {
    if (sessions.length < 7) return 0.0;
    
    final sessionDates = sessions
        .map((s) => DateUtils.formatDate(s.startTime, 'yyyy-MM-dd'))
        .toSet();
    
    final daysCovered = sessionDates.length;
    final totalDays = DateTime.now().difference(sessions.last.startTime).inDays + 1;
    
    return totalDays > 0 ? (daysCovered / totalDays).clamp(0.0, 1.0) : 0.0;
  }

  List<String> _generateReadingInsights(List<BookEntity> books, List<ReadingSessionEntity> sessions) {
    final insights = <String>[];
    
    if (books.isEmpty) {
      insights.add('Start your reading journey! Add some books to your library.');
      return insights;
    }
    
    final booksRead = books.where((b) => b.status == 'finished').length;
    final currentlyReading = books.where((b) => b.status == 'currently_reading').length;
    
    if (booksRead >= 12) {
      insights.add('📚 Excellent! You\'ve read $booksRead books. You\'re a dedicated reader!');
    } else if (booksRead >= 5) {
      insights.add('📖 Great progress! $booksRead books completed. Keep up the reading habit!');
    } else if (booksRead > 0) {
      insights.add('🌟 Nice start! You\'ve finished $booksRead books. Every book counts!');
    }
    
    if (currentlyReading > 1) {
      insights.add('You\'re currently reading $currentlyReading books. Consider focusing on one at a time.');
    }
    
    // Genre diversity
    final genres = books.map((b) => b.genre).toSet();
    if (genres.length >= 5) {
      insights.add('🎭 Great genre diversity! You explore ${genres.length} different genres.');
    } else if (genres.length <= 2) {
      insights.add('Consider exploring new genres to broaden your reading experience.');
    }
    
    // Reading speed insights
    if (sessions.isNotEmpty) {
      final avgPagesPerSession = sessions.fold<int>(0, (sum, s) => sum + s.pagesRead) / sessions.length;
      
      if (avgPagesPerSession >= 20) {
        insights.add('🚀 You\'re a fast reader! Averaging ${avgPagesPerSession.round()} pages per session.');
      } else if (avgPagesPerSession < 10) {
        insights.add('Take your time and enjoy the reading process. Quality over speed!');
      }
    }
    
    return insights;
  }
}
