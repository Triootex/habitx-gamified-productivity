import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/reading_entity.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Add Book Use Case
@injectable
class AddBookUseCase implements UseCase<BookEntity, AddBookParams> {
  final ReadingRepository repository;

  AddBookUseCase(this.repository);

  @override
  Future<Either<Failure, BookEntity>> call(AddBookParams params) async {
    return await repository.addBook(params.userId, params.bookData);
  }
}

class AddBookParams {
  final String userId;
  final Map<String, dynamic> bookData;

  AddBookParams({required this.userId, required this.bookData});
}

// Start Reading Session Use Case
@injectable
class StartReadingSessionUseCase implements UseCase<ReadingSessionEntity, StartReadingSessionParams> {
  final ReadingRepository repository;

  StartReadingSessionUseCase(this.repository);

  @override
  Future<Either<Failure, ReadingSessionEntity>> call(StartReadingSessionParams params) async {
    return await repository.startReadingSession(params.bookId, params.sessionData);
  }
}

class StartReadingSessionParams {
  final String bookId;
  final Map<String, dynamic> sessionData;

  StartReadingSessionParams({required this.bookId, required this.sessionData});
}

// End Reading Session Use Case
@injectable
class EndReadingSessionUseCase implements UseCase<ReadingSessionEntity, EndReadingSessionParams> {
  final ReadingRepository repository;

  EndReadingSessionUseCase(this.repository);

  @override
  Future<Either<Failure, ReadingSessionEntity>> call(EndReadingSessionParams params) async {
    return await repository.endReadingSession(params.sessionId, params.completionData);
  }
}

class EndReadingSessionParams {
  final String sessionId;
  final Map<String, dynamic> completionData;

  EndReadingSessionParams({required this.sessionId, required this.completionData});
}

// Get User Books Use Case
@injectable
class GetUserBooksUseCase implements UseCase<List<BookEntity>, GetUserBooksParams> {
  final ReadingRepository repository;

  GetUserBooksUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookEntity>>> call(GetUserBooksParams params) async {
    return await repository.getUserBooks(params.userId, status: params.status);
  }
}

class GetUserBooksParams {
  final String userId;
  final String? status;

  GetUserBooksParams({required this.userId, this.status});
}

// Create Reading Challenge Use Case
@injectable
class CreateReadingChallengeUseCase implements UseCase<ReadingChallengeEntity, CreateReadingChallengeParams> {
  final ReadingRepository repository;

  CreateReadingChallengeUseCase(this.repository);

  @override
  Future<Either<Failure, ReadingChallengeEntity>> call(CreateReadingChallengeParams params) async {
    return await repository.createChallenge(params.userId, params.challengeData);
  }
}

class CreateReadingChallengeParams {
  final String userId;
  final Map<String, dynamic> challengeData;

  CreateReadingChallengeParams({required this.userId, required this.challengeData});
}

// Get User Reading Challenges Use Case
@injectable
class GetUserReadingChallengesUseCase implements UseCase<List<ReadingChallengeEntity>, String> {
  final ReadingRepository repository;

  GetUserReadingChallengesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReadingChallengeEntity>>> call(String userId) async {
    return await repository.getUserChallenges(userId);
  }
}

// Get Reading Analytics Use Case
@injectable
class GetReadingAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetReadingAnalyticsParams> {
  final ReadingRepository repository;

  GetReadingAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetReadingAnalyticsParams params) async {
    return await repository.getReadingAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetReadingAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetReadingAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Get Personalized Book Recommendations Use Case
@injectable
class GetPersonalizedBookRecommendationsUseCase implements UseCase<List<BookRecommendationEntity>, String> {
  final ReadingRepository repository;

  GetPersonalizedBookRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookRecommendationEntity>>> call(String userId) async {
    return await repository.getPersonalizedRecommendations(userId);
  }
}

// Update Reading Progress Use Case
@injectable
class UpdateReadingProgressUseCase implements UseCase<BookEntity, UpdateReadingProgressParams> {
  final ReadingRepository repository;

  UpdateReadingProgressUseCase(this.repository);

  @override
  Future<Either<Failure, BookEntity>> call(UpdateReadingProgressParams params) async {
    return await repository.updateReadingProgress(params.bookId, params.currentPage);
  }
}

class UpdateReadingProgressParams {
  final String bookId;
  final int currentPage;

  UpdateReadingProgressParams({required this.bookId, required this.currentPage});
}

// Search Books Use Case
@injectable
class SearchBooksUseCase implements UseCase<Map<String, dynamic>, String> {
  final ReadingRepository repository;

  SearchBooksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String query) async {
    return await repository.searchBooks(query);
  }
}

// Sync Reading Data Use Case
@injectable
class SyncReadingDataUseCase implements UseCase<bool, String> {
  final ReadingRepository repository;

  SyncReadingDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncReadingData(userId);
  }
}

// Scan Book Barcode Use Case
@injectable
class ScanBookBarcodeUseCase implements UseCase<BookEntity, String> {
  final ReadingRepository repository;

  ScanBookBarcodeUseCase(this.repository);

  @override
  Future<Either<Failure, BookEntity>> call(String barcode) async {
    return await repository.scanBookBarcode(barcode);
  }
}

// Calculate Reading Speed Use Case
@injectable
class CalculateReadingSpeedUseCase implements UseCase<Map<String, dynamic>, String> {
  final ReadingRepository repository;

  CalculateReadingSpeedUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final booksResult = await repository.getUserBooks(userId);
      
      return booksResult.fold(
        (failure) => Left(failure),
        (books) {
          final speedData = _calculateReadingSpeed(books);
          return Right(speedData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate reading speed: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateReadingSpeed(List<BookEntity> books) {
    final completedBooks = books.where((book) => book.status == 'completed').toList();
    
    if (completedBooks.isEmpty) {
      return {
        'average_speed_wpm': 0,
        'average_speed_pph': 0, // pages per hour
        'books_analyzed': 0,
        'total_pages_read': 0,
        'total_reading_time': 0,
        'reading_level': 'No data',
        'recommendations': ['Complete a book to calculate your reading speed'],
      };
    }
    
    var totalPages = 0;
    var totalMinutes = 0;
    var totalWords = 0;
    
    for (final book in completedBooks) {
      totalPages += book.totalPages ?? 0;
      totalMinutes += book.totalReadingTime ?? 0;
      
      // Estimate words (average 250-300 words per page)
      final estimatedWords = (book.totalPages ?? 0) * 275;
      totalWords += estimatedWords;
    }
    
    if (totalMinutes == 0) {
      return {
        'average_speed_wpm': 0,
        'average_speed_pph': 0,
        'books_analyzed': completedBooks.length,
        'total_pages_read': totalPages,
        'total_reading_time': 0,
        'reading_level': 'Unknown',
        'recommendations': ['Track reading time to calculate speed accurately'],
      };
    }
    
    final wordsPerMinute = totalWords / totalMinutes;
    final pagesPerHour = (totalPages / (totalMinutes / 60.0));
    
    final readingLevel = _getReadingLevel(wordsPerMinute);
    final recommendations = _getReadingSpeedRecommendations(wordsPerMinute, readingLevel);
    
    return {
      'average_speed_wpm': wordsPerMinute.round(),
      'average_speed_pph': pagesPerHour.round(),
      'books_analyzed': completedBooks.length,
      'total_pages_read': totalPages,
      'total_reading_time': totalMinutes,
      'total_reading_hours': (totalMinutes / 60.0).round(),
      'reading_level': readingLevel,
      'recommendations': recommendations,
      'comparison': _getSpeedComparison(wordsPerMinute),
    };
  }

  String _getReadingLevel(double wpm) {
    if (wpm >= 300) return 'Advanced';
    if (wpm >= 250) return 'Above Average';
    if (wpm >= 200) return 'Average';
    if (wpm >= 150) return 'Below Average';
    return 'Beginner';
  }

  List<String> _getReadingSpeedRecommendations(double wpm, String level) {
    final recommendations = <String>[];
    
    if (wpm < 200) {
      recommendations.addAll([
        'Practice reading daily to improve speed',
        'Try speed reading techniques like skimming',
        'Reduce subvocalization (inner voice) while reading',
      ]);
    } else if (wpm < 250) {
      recommendations.addAll([
        'Good reading speed! Try to increase vocabulary for faster comprehension',
        'Practice reading different genres to maintain speed',
      ]);
    } else {
      recommendations.addAll([
        'Excellent reading speed! Focus on comprehension and retention',
        'Challenge yourself with more complex material',
      ]);
    }
    
    return recommendations;
  }

  Map<String, dynamic> _getSpeedComparison(double wpm) {
    return {
      'vs_average': wpm - 225, // Average adult reading speed
      'percentile': _calculatePercentile(wpm),
      'description': _getSpeedDescription(wpm),
    };
  }

  int _calculatePercentile(double wpm) {
    // Rough percentile based on reading speed distribution
    if (wpm >= 350) return 95;
    if (wpm >= 300) return 85;
    if (wpm >= 275) return 75;
    if (wpm >= 250) return 65;
    if (wpm >= 225) return 50;
    if (wpm >= 200) return 35;
    if (wpm >= 175) return 25;
    return 15;
  }

  String _getSpeedDescription(double wpm) {
    if (wpm >= 300) return 'You read faster than most people!';
    if (wpm >= 250) return 'You have above-average reading speed';
    if (wpm >= 200) return 'You read at an average pace';
    return 'There\'s room to improve your reading speed';
  }
}

// Get Reading Streaks Use Case
@injectable
class GetReadingStreaksUseCase implements UseCase<Map<String, dynamic>, String> {
  final ReadingRepository repository;

  GetReadingStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final booksResult = await repository.getUserBooks(userId);
      
      return booksResult.fold(
        (failure) => Left(failure),
        (books) {
          final streakData = _calculateReadingStreaks(books);
          return Right(streakData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate reading streaks: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateReadingStreaks(List<BookEntity> books) {
    final completedBooks = books.where((book) => 
        book.status == 'completed' && book.completedAt != null).toList();
    
    if (completedBooks.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
        'books_this_year': 0,
        'books_this_month': 0,
        'average_books_per_month': 0.0,
        'reading_consistency': 0,
      };
    }
    
    // Sort by completion date
    completedBooks.sort((a, b) => a.completedAt!.compareTo(b.completedAt!));
    
    // Calculate current streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    DateTime? lastDate;
    
    for (final book in completedBooks.reversed) {
      if (lastDate == null) {
        lastDate = book.completedAt;
        currentStreak = 1;
        continue;
      }
      
      final daysDifference = lastDate.difference(book.completedAt!).inDays;
      
      if (daysDifference <= 7) { // Within a week
        currentStreak++;
        tempStreak++;
      } else {
        longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
        tempStreak = 1;
        if (DateTime.now().difference(lastDate).inDays > 14) {
          currentStreak = 0; // Streak broken if more than 2 weeks ago
        }
      }
      
      lastDate = book.completedAt;
    }
    
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    
    // Calculate other stats
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final booksThisYear = completedBooks.where((book) => 
        book.completedAt!.isAfter(startOfYear)).length;
    
    final booksThisMonth = completedBooks.where((book) => 
        book.completedAt!.isAfter(startOfMonth)).length;
    
    // Calculate average books per month
    final firstBookDate = completedBooks.first.completedAt!;
    final monthsDifference = ((now.difference(firstBookDate).inDays) / 30.0).ceil();
    final averageBooksPerMonth = monthsDifference > 0 ? completedBooks.length / monthsDifference : 0.0;
    
    // Calculate reading consistency (books per month variance)
    final consistency = _calculateReadingConsistency(completedBooks);
    
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'books_this_year': booksThisYear,
      'books_this_month': booksThisMonth,
      'total_books_completed': completedBooks.length,
      'average_books_per_month': double.parse(averageBooksPerMonth.toStringAsFixed(1)),
      'reading_consistency': consistency,
      'first_book_date': firstBookDate.toIso8601String(),
      'latest_book_date': completedBooks.last.completedAt!.toIso8601String(),
    };
  }

  int _calculateReadingConsistency(List<BookEntity> books) {
    if (books.length < 3) return 50; // Not enough data
    
    // Group books by month
    final monthlyBooks = <String, int>{};
    
    for (final book in books) {
      final monthKey = '${book.completedAt!.year}-${book.completedAt!.month}';
      monthlyBooks[monthKey] = (monthlyBooks[monthKey] ?? 0) + 1;
    }
    
    if (monthlyBooks.length < 2) return 75; // Only one month of data
    
    final bookCounts = monthlyBooks.values.toList();
    final mean = bookCounts.reduce((a, b) => a + b) / bookCounts.length;
    
    // Calculate coefficient of variation
    final variance = bookCounts.fold<double>(0.0, (sum, count) => sum + ((count - mean) * (count - mean))) / bookCounts.length;
    final coefficientOfVariation = variance > 0 ? (variance.sqrt() / mean) : 0.0;
    
    // Convert to consistency score (0-100, where 100 is most consistent)
    final consistencyScore = (100 - (coefficientOfVariation * 100)).clamp(0, 100);
    
    return consistencyScore.round();
  }
}

// Get Reading Goals Progress Use Case
@injectable
class GetReadingGoalsProgressUseCase implements UseCase<Map<String, dynamic>, String> {
  final ReadingRepository repository;

  GetReadingGoalsProgressUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final challengesResult = await repository.getUserChallenges(userId);
      final booksResult = await repository.getUserBooks(userId);
      
      return challengesResult.fold(
        (failure) => Left(failure),
        (challenges) async {
          final books = await booksResult.fold(
            (failure) => <BookEntity>[],
            (bookList) => bookList,
          );
          
          final progress = _calculateGoalsProgress(challenges, books);
          return Right(progress);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get reading goals progress: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateGoalsProgress(List<ReadingChallengeEntity> challenges, List<BookEntity> books) {
    if (challenges.isEmpty) {
      return {
        'active_challenges': 0,
        'completed_challenges': 0,
        'overall_progress': 0.0,
        'recommendations': ['Set a reading challenge to track your progress'],
      };
    }
    
    final now = DateTime.now();
    final activeChallenges = challenges.where((c) => c.endDate.isAfter(now)).toList();
    final completedChallenges = challenges.where((c) => c.isCompleted).toList();
    
    final challengeProgress = <Map<String, dynamic>>[];
    double totalProgress = 0.0;
    
    for (final challenge in activeChallenges) {
      final relevantBooks = books.where((book) => 
          book.completedAt != null &&
          book.completedAt!.isAfter(challenge.startDate) &&
          book.completedAt!.isBefore(challenge.endDate)
      ).toList();
      
      double progress = 0.0;
      
      if (challenge.targetType == 'books') {
        progress = relevantBooks.length / challenge.targetValue;
      } else if (challenge.targetType == 'pages') {
        final totalPages = relevantBooks.fold<int>(0, (sum, book) => sum + (book.totalPages ?? 0));
        progress = totalPages / challenge.targetValue;
      }
      
      progress = progress.clamp(0.0, 1.0);
      totalProgress += progress;
      
      challengeProgress.add({
        'challenge_id': challenge.id,
        'title': challenge.title,
        'target_type': challenge.targetType,
        'target_value': challenge.targetValue,
        'current_value': challenge.targetType == 'books' 
            ? relevantBooks.length 
            : relevantBooks.fold<int>(0, (sum, book) => sum + (book.totalPages ?? 0)),
        'progress': (progress * 100).round(),
        'end_date': challenge.endDate.toIso8601String(),
        'days_remaining': challenge.endDate.difference(now).inDays,
        'on_track': _isOnTrack(challenge, progress, now),
      });
    }
    
    final overallProgress = activeChallenges.isNotEmpty ? (totalProgress / activeChallenges.length) : 0.0;
    
    final recommendations = _generateGoalRecommendations(challengeProgress, overallProgress);
    
    return {
      'active_challenges': activeChallenges.length,
      'completed_challenges': completedChallenges.length,
      'overall_progress': (overallProgress * 100).round(),
      'challenge_details': challengeProgress,
      'recommendations': recommendations,
    };
  }

  bool _isOnTrack(ReadingChallengeEntity challenge, double currentProgress, DateTime now) {
    final totalDays = challenge.endDate.difference(challenge.startDate).inDays;
    final daysPassed = now.difference(challenge.startDate).inDays;
    
    if (totalDays <= 0) return true;
    
    final expectedProgress = daysPassed / totalDays;
    return currentProgress >= (expectedProgress * 0.8); // 80% of expected progress
  }

  List<String> _generateGoalRecommendations(List<Map<String, dynamic>> challenges, double overallProgress) {
    final recommendations = <String>[];
    
    if (challenges.isEmpty) {
      recommendations.add('Set a reading challenge to stay motivated');
      return recommendations;
    }
    
    if (overallProgress < 50) {
      recommendations.add('You\'re behind on your reading goals - try setting aside dedicated reading time daily');
    } else if (overallProgress > 80) {
      recommendations.add('Great progress on your reading goals! Consider setting a more ambitious target');
    }
    
    final behindChallenges = challenges.where((c) => c['on_track'] == false).toList();
    if (behindChallenges.isNotEmpty) {
      recommendations.add('Focus on catching up with ${behindChallenges.length} challenge(s) you\'re behind on');
    }
    
    recommendations.addAll([
      'Join online reading communities for motivation',
      'Try audiobooks during commutes to increase reading time',
      'Set a daily reading reminder to build consistency',
    ]);
    
    return recommendations.take(4).toList();
  }
}
