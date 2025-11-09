import 'package:equatable/equatable.dart';

class FlashcardDeckEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String subject;
  final String language;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> tags;
  final String visibility; // private, public, shared
  
  // Deck statistics
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;
  
  // Study settings
  final int dailyNewCards;
  final int dailyReviewCards;
  final Map<String, dynamic> spacedRepetitionSettings;
  final bool enableLeitnerSystem;
  final Map<String, int> leitnerBoxIntervals;
  
  // AI and generation
  final bool isAIGenerated;
  final String? sourceText;
  final String? sourceUrl;
  final Map<String, dynamic> aiGenerationConfig;
  
  // Sharing and collaboration
  final List<String> collaborators;
  final int downloadCount;
  final double rating;
  final int ratingCount;
  final List<String> reviews;
  
  // Import/Export
  final String? importSource; // anki, quizlet, csv, etc.
  final Map<String, dynamic> importMetadata;
  final DateTime? lastExported;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastStudied;

  const FlashcardDeckEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.subject,
    this.language = 'en',
    this.difficulty = 'intermediate',
    this.tags = const [],
    this.visibility = 'private',
    this.totalCards = 0,
    this.newCards = 0,
    this.learningCards = 0,
    this.reviewCards = 0,
    this.masteredCards = 0,
    this.dailyNewCards = 10,
    this.dailyReviewCards = 50,
    this.spacedRepetitionSettings = const {},
    this.enableLeitnerSystem = false,
    this.leitnerBoxIntervals = const {},
    this.isAIGenerated = false,
    this.sourceText,
    this.sourceUrl,
    this.aiGenerationConfig = const {},
    this.collaborators = const [],
    this.downloadCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reviews = const [],
    this.importSource,
    this.importMetadata = const {},
    this.lastExported,
    required this.createdAt,
    this.updatedAt,
    this.lastStudied,
  });

  double get studyProgress {
    if (totalCards == 0) return 0.0;
    return masteredCards / totalCards;
  }

  bool get hasNewCards => newCards > 0;
  bool get hasReviewCards => reviewCards > 0;
  bool get needsStudy => hasNewCards || hasReviewCards;

  FlashcardDeckEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? subject,
    String? language,
    String? difficulty,
    List<String>? tags,
    String? visibility,
    int? totalCards,
    int? newCards,
    int? learningCards,
    int? reviewCards,
    int? masteredCards,
    int? dailyNewCards,
    int? dailyReviewCards,
    Map<String, dynamic>? spacedRepetitionSettings,
    bool? enableLeitnerSystem,
    Map<String, int>? leitnerBoxIntervals,
    bool? isAIGenerated,
    String? sourceText,
    String? sourceUrl,
    Map<String, dynamic>? aiGenerationConfig,
    List<String>? collaborators,
    int? downloadCount,
    double? rating,
    int? ratingCount,
    List<String>? reviews,
    String? importSource,
    Map<String, dynamic>? importMetadata,
    DateTime? lastExported,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastStudied,
  }) {
    return FlashcardDeckEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      totalCards: totalCards ?? this.totalCards,
      newCards: newCards ?? this.newCards,
      learningCards: learningCards ?? this.learningCards,
      reviewCards: reviewCards ?? this.reviewCards,
      masteredCards: masteredCards ?? this.masteredCards,
      dailyNewCards: dailyNewCards ?? this.dailyNewCards,
      dailyReviewCards: dailyReviewCards ?? this.dailyReviewCards,
      spacedRepetitionSettings: spacedRepetitionSettings ?? this.spacedRepetitionSettings,
      enableLeitnerSystem: enableLeitnerSystem ?? this.enableLeitnerSystem,
      leitnerBoxIntervals: leitnerBoxIntervals ?? this.leitnerBoxIntervals,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      sourceText: sourceText ?? this.sourceText,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      aiGenerationConfig: aiGenerationConfig ?? this.aiGenerationConfig,
      collaborators: collaborators ?? this.collaborators,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      reviews: reviews ?? this.reviews,
      importSource: importSource ?? this.importSource,
      importMetadata: importMetadata ?? this.importMetadata,
      lastExported: lastExported ?? this.lastExported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastStudied: lastStudied ?? this.lastStudied,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        subject,
        language,
        difficulty,
        tags,
        visibility,
        totalCards,
        newCards,
        learningCards,
        reviewCards,
        masteredCards,
        dailyNewCards,
        dailyReviewCards,
        spacedRepetitionSettings,
        enableLeitnerSystem,
        leitnerBoxIntervals,
        isAIGenerated,
        sourceText,
        sourceUrl,
        aiGenerationConfig,
        collaborators,
        downloadCount,
        rating,
        ratingCount,
        reviews,
        importSource,
        importMetadata,
        lastExported,
        createdAt,
        updatedAt,
        lastStudied,
      ];
}

class FlashcardEntity extends Equatable {
  final String id;
  final String deckId;
  final String cardType; // basic, cloze, multiple_choice, image, audio
  final Map<String, String> content; // front, back, etc.
  final List<String> tags;
  final String difficulty;
  
  // Spaced repetition data (SM-2 algorithm)
  final int repetitionNumber;
  final double easeFactor;
  final int intervalDays;
  final DateTime? lastReviewed;
  final DateTime nextReview;
  final int qualitySum; // Sum of all quality ratings
  final int reviewCount; // Total number of reviews
  
  // Leitner system data
  final int leitnerBox;
  final DateTime? leitnerLastReview;
  final DateTime? leitnerNextReview;
  
  // Study statistics
  final int totalReviews;
  final int correctReviews;
  final double accuracyRate;
  final List<ReviewLogEntity> reviewHistory;
  final Duration totalStudyTime;
  final Duration averageStudyTime;
  
  // Card state
  final String state; // new, learning, review, mastered, suspended
  final bool isSuspended;
  final bool isMarkedDifficult;
  final List<String> notes;
  
  // Media attachments
  final List<MediaAttachmentEntity> attachments;
  final String? audioUrl;
  final String? imageUrl;
  
  // AI-generated metadata
  final bool isAIGenerated;
  final Map<String, dynamic> aiMetadata;
  final double? aiConfidenceScore;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FlashcardEntity({
    required this.id,
    required this.deckId,
    this.cardType = 'basic',
    this.content = const {},
    this.tags = const [],
    this.difficulty = 'medium',
    this.repetitionNumber = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.lastReviewed,
    required this.nextReview,
    this.qualitySum = 0,
    this.reviewCount = 0,
    this.leitnerBox = 1,
    this.leitnerLastReview,
    this.leitnerNextReview,
    this.totalReviews = 0,
    this.correctReviews = 0,
    this.accuracyRate = 0.0,
    this.reviewHistory = const [],
    this.totalStudyTime = Duration.zero,
    this.averageStudyTime = Duration.zero,
    this.state = 'new',
    this.isSuspended = false,
    this.isMarkedDifficult = false,
    this.notes = const [],
    this.attachments = const [],
    this.audioUrl,
    this.imageUrl,
    this.isAIGenerated = false,
    this.aiMetadata = const {},
    this.aiConfidenceScore,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isDue => DateTime.now().isAfter(nextReview);
  bool get isNew => state == 'new';
  bool get isMastered => state == 'mastered';
  bool get needsReview => isDue && !isSuspended;

  double get averageQuality {
    if (reviewCount == 0) return 0.0;
    return qualitySum / reviewCount;
  }

  FlashcardEntity copyWith({
    String? id,
    String? deckId,
    String? cardType,
    Map<String, String>? content,
    List<String>? tags,
    String? difficulty,
    int? repetitionNumber,
    double? easeFactor,
    int? intervalDays,
    DateTime? lastReviewed,
    DateTime? nextReview,
    int? qualitySum,
    int? reviewCount,
    int? leitnerBox,
    DateTime? leitnerLastReview,
    DateTime? leitnerNextReview,
    int? totalReviews,
    int? correctReviews,
    double? accuracyRate,
    List<ReviewLogEntity>? reviewHistory,
    Duration? totalStudyTime,
    Duration? averageStudyTime,
    String? state,
    bool? isSuspended,
    bool? isMarkedDifficult,
    List<String>? notes,
    List<MediaAttachmentEntity>? attachments,
    String? audioUrl,
    String? imageUrl,
    bool? isAIGenerated,
    Map<String, dynamic>? aiMetadata,
    double? aiConfidenceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      cardType: cardType ?? this.cardType,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      repetitionNumber: repetitionNumber ?? this.repetitionNumber,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      qualitySum: qualitySum ?? this.qualitySum,
      reviewCount: reviewCount ?? this.reviewCount,
      leitnerBox: leitnerBox ?? this.leitnerBox,
      leitnerLastReview: leitnerLastReview ?? this.leitnerLastReview,
      leitnerNextReview: leitnerNextReview ?? this.leitnerNextReview,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      reviewHistory: reviewHistory ?? this.reviewHistory,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      averageStudyTime: averageStudyTime ?? this.averageStudyTime,
      state: state ?? this.state,
      isSuspended: isSuspended ?? this.isSuspended,
      isMarkedDifficult: isMarkedDifficult ?? this.isMarkedDifficult,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        cardType,
        content,
        tags,
        difficulty,
        repetitionNumber,
        easeFactor,
        intervalDays,
        lastReviewed,
        nextReview,
        qualitySum,
        reviewCount,
        leitnerBox,
        leitnerLastReview,
        leitnerNextReview,
        totalReviews,
        correctReviews,
        accuracyRate,
        reviewHistory,
        totalStudyTime,
        averageStudyTime,
        state,
        isSuspended,
        isMarkedDifficult,
        notes,
        attachments,
        audioUrl,
        imageUrl,
        isAIGenerated,
        aiMetadata,
        aiConfidenceScore,
        createdAt,
        updatedAt,
      ];
}

class ReviewLogEntity extends Equatable {
  final String id;
  final String cardId;
  final String deckId;
  final DateTime reviewTime;
  final int quality; // 0-5 rating (SM-2 algorithm)
  final Duration responseTime;
  final String reviewType; // new, learning, review, relearning
  final int easeFactor; // Ease factor at time of review
  final int intervalDays; // Interval at time of review
  final String? notes;
  final Map<String, dynamic> context; // Study session context

  const ReviewLogEntity({
    required this.id,
    required this.cardId,
    required this.deckId,
    required this.reviewTime,
    required this.quality,
    required this.responseTime,
    required this.reviewType,
    required this.easeFactor,
    required this.intervalDays,
    this.notes,
    this.context = const {},
  });

  bool get wasCorrect => quality >= 3;

  ReviewLogEntity copyWith({
    String? id,
    String? cardId,
    String? deckId,
    DateTime? reviewTime,
    int? quality,
    Duration? responseTime,
    String? reviewType,
    int? easeFactor,
    int? intervalDays,
    String? notes,
    Map<String, dynamic>? context,
  }) {
    return ReviewLogEntity(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      deckId: deckId ?? this.deckId,
      reviewTime: reviewTime ?? this.reviewTime,
      quality: quality ?? this.quality,
      responseTime: responseTime ?? this.responseTime,
      reviewType: reviewType ?? this.reviewType,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      notes: notes ?? this.notes,
      context: context ?? this.context,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardId,
        deckId,
        reviewTime,
        quality,
        responseTime,
        reviewType,
        easeFactor,
        intervalDays,
        notes,
        context,
      ];
}

class StudySessionEntity extends Equatable {
  final String id;
  final String userId;
  final String deckId;
  final DateTime startTime;
  final DateTime? endTime;
  final int cardsStudied;
  final int cardsCorrect;
  final int cardsIncorrect;
  final Duration totalStudyTime;
  final double averageResponseTime;
  final List<String> cardIds; // Cards studied in this session
  final Map<String, int> qualityDistribution; // Quality -> Count
  final String sessionType; // review, new_cards, mixed, practice_test
  final bool wasCompleted;
  final Map<String, dynamic> sessionStats;
  final String? notes;

  const StudySessionEntity({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.startTime,
    this.endTime,
    this.cardsStudied = 0,
    this.cardsCorrect = 0,
    this.cardsIncorrect = 0,
    this.totalStudyTime = Duration.zero,
    this.averageResponseTime = 0.0,
    this.cardIds = const [],
    this.qualityDistribution = const {},
    this.sessionType = 'mixed',
    this.wasCompleted = false,
    this.sessionStats = const {},
    this.notes,
  });

  double get accuracy {
    if (cardsStudied == 0) return 0.0;
    return cardsCorrect / cardsStudied;
  }

  bool get isActive => endTime == null;

  StudySessionEntity copyWith({
    String? id,
    String? userId,
    String? deckId,
    DateTime? startTime,
    DateTime? endTime,
    int? cardsStudied,
    int? cardsCorrect,
    int? cardsIncorrect,
    Duration? totalStudyTime,
    double? averageResponseTime,
    List<String>? cardIds,
    Map<String, int>? qualityDistribution,
    String? sessionType,
    bool? wasCompleted,
    Map<String, dynamic>? sessionStats,
    String? notes,
  }) {
    return StudySessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cardsStudied: cardsStudied ?? this.cardsStudied,
      cardsCorrect: cardsCorrect ?? this.cardsCorrect,
      cardsIncorrect: cardsIncorrect ?? this.cardsIncorrect,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      cardIds: cardIds ?? this.cardIds,
      qualityDistribution: qualityDistribution ?? this.qualityDistribution,
      sessionType: sessionType ?? this.sessionType,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      sessionStats: sessionStats ?? this.sessionStats,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        deckId,
        startTime,
        endTime,
        cardsStudied,
        cardsCorrect,
        cardsIncorrect,
        totalStudyTime,
        averageResponseTime,
        cardIds,
        qualityDistribution,
        sessionType,
        wasCompleted,
        sessionStats,
        notes,
      ];
}

class MediaAttachmentEntity extends Equatable {
  final String id;
  final String cardId;
  final String type; // image, audio, video
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final Map<String, dynamic> metadata;
  final DateTime uploadedAt;

  const MediaAttachmentEntity({
    required this.id,
    required this.cardId,
    required this.type,
    required this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.metadata = const {},
    required this.uploadedAt,
  });

  MediaAttachmentEntity copyWith({
    String? id,
    String? cardId,
    String? type,
    String? url,
    String? fileName,
    int? fileSize,
    String? mimeType,
    Map<String, dynamic>? metadata,
    DateTime? uploadedAt,
  }) {
    return MediaAttachmentEntity(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      type: type ?? this.type,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [id, cardId, type, url, fileName, fileSize, mimeType, metadata, uploadedAt];
}
