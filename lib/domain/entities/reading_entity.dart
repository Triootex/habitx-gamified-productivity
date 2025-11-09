import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String? isbn;
  final String? description;
  final String genre;
  final String format; // physical, ebook, audiobook
  final String? publisher;
  final DateTime? publishedDate;
  final int? totalPages;
  final String? language;
  final String? coverImageUrl;
  
  // Reading progress
  final String status; // to_read, currently_reading, finished, paused, abandoned
  final int currentPage;
  final double progressPercentage;
  final DateTime? startedReading;
  final DateTime? finishedReading;
  final List<ReadingSessionEntity> readingSessions;
  final Duration totalReadingTime;
  
  // Rating and review
  final double? userRating; // 1-5 stars
  final String? userReview;
  final DateTime? reviewDate;
  final bool isRecommended;
  final List<String> tags;
  
  // Social features
  final bool isPublic;
  final List<String> readingBuddies;
  final String? shelfType; // read, currently_reading, want_to_read, etc.
  final List<String> bookClubs;
  
  // Goals and challenges
  final List<String> associatedChallenges;
  final bool countsTowardGoal;
  final int? goalYear;
  
  // Source and acquisition
  final String source; // purchased, library, borrowed, gift
  final double? purchasePrice;
  final DateTime? acquiredDate;
  final String? libraryDueDate;
  
  // Metadata
  final Map<String, dynamic> goodreadsData;
  final Map<String, dynamic> libraryData;
  final List<String> quotes;
  final List<String> notes;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    this.description,
    required this.genre,
    this.format = 'physical',
    this.publisher,
    this.publishedDate,
    this.totalPages,
    this.language,
    this.coverImageUrl,
    this.status = 'to_read',
    this.currentPage = 0,
    this.progressPercentage = 0.0,
    this.startedReading,
    this.finishedReading,
    this.readingSessions = const [],
    this.totalReadingTime = Duration.zero,
    this.userRating,
    this.userReview,
    this.reviewDate,
    this.isRecommended = false,
    this.tags = const [],
    this.isPublic = false,
    this.readingBuddies = const [],
    this.shelfType,
    this.bookClubs = const [],
    this.associatedChallenges = const [],
    this.countsTowardGoal = true,
    this.goalYear,
    this.source = 'purchased',
    this.purchasePrice,
    this.acquiredDate,
    this.libraryDueDate,
    this.goodreadsData = const {},
    this.libraryData = const {},
    this.quotes = const [],
    this.notes = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCurrentlyReading => status == 'currently_reading';
  bool get isFinished => status == 'finished';
  bool get hasStarted => startedReading != null;
  bool get isOverdue => libraryDueDate != null && DateTime.now().isAfter(DateTime.parse(libraryDueDate!));
  
  int get pagesRemaining => (totalPages ?? 0) - currentPage;
  
  Duration get averageReadingSpeed {
    if (readingSessions.isEmpty) return Duration.zero;
    final totalPages = readingSessions.fold<int>(0, (sum, session) => sum + session.pagesRead);
    final totalTime = readingSessions.fold<Duration>(Duration.zero, (sum, session) => sum + session.duration);
    if (totalPages == 0 || totalTime.inMinutes == 0) return Duration.zero;
    return Duration(minutes: (totalTime.inMinutes / totalPages).round());
  }

  BookEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? isbn,
    String? description,
    String? genre,
    String? format,
    String? publisher,
    DateTime? publishedDate,
    int? totalPages,
    String? language,
    String? coverImageUrl,
    String? status,
    int? currentPage,
    double? progressPercentage,
    DateTime? startedReading,
    DateTime? finishedReading,
    List<ReadingSessionEntity>? readingSessions,
    Duration? totalReadingTime,
    double? userRating,
    String? userReview,
    DateTime? reviewDate,
    bool? isRecommended,
    List<String>? tags,
    bool? isPublic,
    List<String>? readingBuddies,
    String? shelfType,
    List<String>? bookClubs,
    List<String>? associatedChallenges,
    bool? countsTowardGoal,
    int? goalYear,
    String? source,
    double? purchasePrice,
    DateTime? acquiredDate,
    String? libraryDueDate,
    Map<String, dynamic>? goodreadsData,
    Map<String, dynamic>? libraryData,
    List<String>? quotes,
    List<String>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      format: format ?? this.format,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      totalPages: totalPages ?? this.totalPages,
      language: language ?? this.language,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startedReading: startedReading ?? this.startedReading,
      finishedReading: finishedReading ?? this.finishedReading,
      readingSessions: readingSessions ?? this.readingSessions,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      reviewDate: reviewDate ?? this.reviewDate,
      isRecommended: isRecommended ?? this.isRecommended,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      readingBuddies: readingBuddies ?? this.readingBuddies,
      shelfType: shelfType ?? this.shelfType,
      bookClubs: bookClubs ?? this.bookClubs,
      associatedChallenges: associatedChallenges ?? this.associatedChallenges,
      countsTowardGoal: countsTowardGoal ?? this.countsTowardGoal,
      goalYear: goalYear ?? this.goalYear,
      source: source ?? this.source,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      libraryDueDate: libraryDueDate ?? this.libraryDueDate,
      goodreadsData: goodreadsData ?? this.goodreadsData,
      libraryData: libraryData ?? this.libraryData,
      quotes: quotes ?? this.quotes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        author,
        isbn,
        description,
        genre,
        format,
        publisher,
        publishedDate,
        totalPages,
        language,
        coverImageUrl,
        status,
        currentPage,
        progressPercentage,
        startedReading,
        finishedReading,
        readingSessions,
        totalReadingTime,
        userRating,
        userReview,
        reviewDate,
        isRecommended,
        tags,
        isPublic,
        readingBuddies,
        shelfType,
        bookClubs,
        associatedChallenges,
        countsTowardGoal,
        goalYear,
        source,
        purchasePrice,
        acquiredDate,
        libraryDueDate,
        goodreadsData,
        libraryData,
        quotes,
        notes,
        createdAt,
        updatedAt,
      ];
}

class ReadingSessionEntity extends Equatable {
  final String id;
  final String bookId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final Duration duration;
  final String? location;
  final String? environment; // quiet, noisy, public, private
  final String? mood; // How you felt while reading
  final int? focusLevel; // 1-10 scale
  final List<String> distractions;
  final String? notes;
  final List<String> highlightedQuotes;
  final bool wasInterrupted;
  final String? interruptionReason;

  const ReadingSessionEntity({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.duration,
    this.location,
    this.environment,
    this.mood,
    this.focusLevel,
    this.distractions = const [],
    this.notes,
    this.highlightedQuotes = const [],
    this.wasInterrupted = false,
    this.interruptionReason,
  });

  bool get isActive => endTime == null;
  double get readingSpeed => duration.inMinutes > 0 ? pagesRead / duration.inMinutes : 0.0; // pages per minute

  ReadingSessionEntity copyWith({
    String? id,
    String? bookId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? startPage,
    int? endPage,
    int? pagesRead,
    Duration? duration,
    String? location,
    String? environment,
    String? mood,
    int? focusLevel,
    List<String>? distractions,
    String? notes,
    List<String>? highlightedQuotes,
    bool? wasInterrupted,
    String? interruptionReason,
  }) {
    return ReadingSessionEntity(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      pagesRead: pagesRead ?? this.pagesRead,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      environment: environment ?? this.environment,
      mood: mood ?? this.mood,
      focusLevel: focusLevel ?? this.focusLevel,
      distractions: distractions ?? this.distractions,
      notes: notes ?? this.notes,
      highlightedQuotes: highlightedQuotes ?? this.highlightedQuotes,
      wasInterrupted: wasInterrupted ?? this.wasInterrupted,
      interruptionReason: interruptionReason ?? this.interruptionReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        userId,
        startTime,
        endTime,
        startPage,
        endPage,
        pagesRead,
        duration,
        location,
        environment,
        mood,
        focusLevel,
        distractions,
        notes,
        highlightedQuotes,
        wasInterrupted,
        interruptionReason,
      ];
}

class ReadingChallengeEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String challengeType; // yearly_goal, genre_explorer, speed_reader, etc.
  final Map<String, dynamic> rules;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // Progress tracking
  final int targetCount; // Number of books or pages
  final int currentCount;
  final double progressPercentage;
  final List<String> completedBookIds;
  final Map<String, int> genreProgress; // For genre challenges
  
  // Community features
  final bool isPublic;
  final bool allowJoining;
  final List<String> participants;
  final int participantCount;
  final List<String> leaderboard;
  
  // Rewards and achievements
  final List<String> milestones;
  final Map<String, bool> milestoneAchieved;
  final String? completionReward;
  final int xpReward;
  
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  const ReadingChallengeEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.challengeType,
    this.rules = const {},
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.targetCount,
    this.currentCount = 0,
    this.progressPercentage = 0.0,
    this.completedBookIds = const [],
    this.genreProgress = const {},
    this.isPublic = false,
    this.allowJoining = true,
    this.participants = const [],
    this.participantCount = 0,
    this.leaderboard = const [],
    this.milestones = const [],
    this.milestoneAchieved = const {},
    this.completionReward,
    this.xpReward = 0,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  bool get isCompleted => currentCount >= targetCount;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get booksRemaining => targetCount - currentCount;
  
  Duration get timeRemaining => endDate.difference(DateTime.now());
  
  double get dailyTarget {
    final daysRemaining = timeRemaining.inDays;
    if (daysRemaining <= 0) return 0.0;
    return booksRemaining / daysRemaining;
  }

  ReadingChallengeEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? challengeType,
    Map<String, dynamic>? rules,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? targetCount,
    int? currentCount,
    double? progressPercentage,
    List<String>? completedBookIds,
    Map<String, int>? genreProgress,
    bool? isPublic,
    bool? allowJoining,
    List<String>? participants,
    int? participantCount,
    List<String>? leaderboard,
    List<String>? milestones,
    Map<String, bool>? milestoneAchieved,
    String? completionReward,
    int? xpReward,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return ReadingChallengeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      challengeType: challengeType ?? this.challengeType,
      rules: rules ?? this.rules,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedBookIds: completedBookIds ?? this.completedBookIds,
      genreProgress: genreProgress ?? this.genreProgress,
      isPublic: isPublic ?? this.isPublic,
      allowJoining: allowJoining ?? this.allowJoining,
      participants: participants ?? this.participants,
      participantCount: participantCount ?? this.participantCount,
      leaderboard: leaderboard ?? this.leaderboard,
      milestones: milestones ?? this.milestones,
      milestoneAchieved: milestoneAchieved ?? this.milestoneAchieved,
      completionReward: completionReward ?? this.completionReward,
      xpReward: xpReward ?? this.xpReward,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        challengeType,
        rules,
        startDate,
        endDate,
        isActive,
        targetCount,
        currentCount,
        progressPercentage,
        completedBookIds,
        genreProgress,
        isPublic,
        allowJoining,
        participants,
        participantCount,
        leaderboard,
        milestones,
        milestoneAchieved,
        completionReward,
        xpReward,
        createdAt,
        completedAt,
        updatedAt,
      ];
}

class BookRecommendationEntity extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final String title;
  final String author;
  final String genre;
  final String recommendationType; // ai, friend, trending, similar
  final double relevanceScore; // 0-1
  final List<String> reasonCodes; // Why it was recommended
  final String? description;
  final double? rating;
  final String? coverImageUrl;
  final DateTime recommendedAt;
  final bool isViewed;
  final bool isAccepted; // User added to their list
  final bool isRejected; // User dismissed
  final DateTime? viewedAt;
  final DateTime? actionAt;

  const BookRecommendationEntity({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.genre,
    required this.recommendationType,
    required this.relevanceScore,
    this.reasonCodes = const [],
    this.description,
    this.rating,
    this.coverImageUrl,
    required this.recommendedAt,
    this.isViewed = false,
    this.isAccepted = false,
    this.isRejected = false,
    this.viewedAt,
    this.actionAt,
  });

  bool get isPending => !isAccepted && !isRejected;
  bool get hasAction => isAccepted || isRejected;

  BookRecommendationEntity copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? title,
    String? author,
    String? genre,
    String? recommendationType,
    double? relevanceScore,
    List<String>? reasonCodes,
    String? description,
    double? rating,
    String? coverImageUrl,
    DateTime? recommendedAt,
    bool? isViewed,
    bool? isAccepted,
    bool? isRejected,
    DateTime? viewedAt,
    DateTime? actionAt,
  }) {
    return BookRecommendationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      recommendationType: recommendationType ?? this.recommendationType,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      reasonCodes: reasonCodes ?? this.reasonCodes,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      recommendedAt: recommendedAt ?? this.recommendedAt,
      isViewed: isViewed ?? this.isViewed,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
      viewedAt: viewedAt ?? this.viewedAt,
      actionAt: actionAt ?? this.actionAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        bookId,
        title,
        author,
        genre,
        recommendationType,
        relevanceScore,
        reasonCodes,
        description,
        rating,
        coverImageUrl,
        recommendedAt,
        isViewed,
        isAccepted,
        isRejected,
        viewedAt,
        actionAt,
      ];
}
