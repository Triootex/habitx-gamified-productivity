import 'package:equatable/equatable.dart';

class LanguageCourseEntity extends Equatable {
  final String id;
  final String userId;
  final String targetLanguage;
  final String nativeLanguage;
  final String proficiencyLevel; // a1_beginner, a2_elementary, etc.
  final String courseType; // structured, custom, immersion
  final DateTime startDate;
  final DateTime? completionDate;
  final bool isActive;
  
  // Progress tracking
  final int totalXP;
  final int currentLevel;
  final int lessonsCompleted;
  final int totalLessons;
  final double overallProgress;
  final Map<String, int> skillProgress; // reading, writing, speaking, listening
  
  // League and competition
  final String currentLeague;
  final int weeklyXP;
  final int leaguePosition;
  final int streakLength;
  final DateTime? lastStudyDate;
  
  // Study preferences
  final int dailyGoalMinutes;
  final List<String> preferredStudyTimes;
  final bool enableReminders;
  final List<String> reminderTimes;
  final Map<String, bool> skillFocus; // Which skills to prioritize
  
  // Achievements and milestones
  final List<String> unlockedAchievements;
  final Map<String, DateTime> milestones;
  final List<String> completedChallenges;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LanguageCourseEntity({
    required this.id,
    required this.userId,
    required this.targetLanguage,
    required this.nativeLanguage,
    this.proficiencyLevel = 'a1_beginner',
    this.courseType = 'structured',
    required this.startDate,
    this.completionDate,
    this.isActive = true,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.lessonsCompleted = 0,
    this.totalLessons = 100,
    this.overallProgress = 0.0,
    this.skillProgress = const {},
    this.currentLeague = 'bronze',
    this.weeklyXP = 0,
    this.leaguePosition = 0,
    this.streakLength = 0,
    this.lastStudyDate,
    this.dailyGoalMinutes = 15,
    this.preferredStudyTimes = const [],
    this.enableReminders = true,
    this.reminderTimes = const [],
    this.skillFocus = const {},
    this.unlockedAchievements = const [],
    this.milestones = const {},
    this.completedChallenges = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasActiveStreak => streakLength > 0;
  bool get studiedToday => lastStudyDate != null && 
      DateTime.now().difference(lastStudyDate!).inDays == 0;

  LanguageCourseEntity copyWith({
    String? id,
    String? userId,
    String? targetLanguage,
    String? nativeLanguage,
    String? proficiencyLevel,
    String? courseType,
    DateTime? startDate,
    DateTime? completionDate,
    bool? isActive,
    int? totalXP,
    int? currentLevel,
    int? lessonsCompleted,
    int? totalLessons,
    double? overallProgress,
    Map<String, int>? skillProgress,
    String? currentLeague,
    int? weeklyXP,
    int? leaguePosition,
    int? streakLength,
    DateTime? lastStudyDate,
    int? dailyGoalMinutes,
    List<String>? preferredStudyTimes,
    bool? enableReminders,
    List<String>? reminderTimes,
    Map<String, bool>? skillFocus,
    List<String>? unlockedAchievements,
    Map<String, DateTime>? milestones,
    List<String>? completedChallenges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LanguageCourseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      courseType: courseType ?? this.courseType,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      isActive: isActive ?? this.isActive,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalLessons: totalLessons ?? this.totalLessons,
      overallProgress: overallProgress ?? this.overallProgress,
      skillProgress: skillProgress ?? this.skillProgress,
      currentLeague: currentLeague ?? this.currentLeague,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      leaguePosition: leaguePosition ?? this.leaguePosition,
      streakLength: streakLength ?? this.streakLength,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      preferredStudyTimes: preferredStudyTimes ?? this.preferredStudyTimes,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      skillFocus: skillFocus ?? this.skillFocus,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      milestones: milestones ?? this.milestones,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        targetLanguage,
        nativeLanguage,
        proficiencyLevel,
        courseType,
        startDate,
        completionDate,
        isActive,
        totalXP,
        currentLevel,
        lessonsCompleted,
        totalLessons,
        overallProgress,
        skillProgress,
        currentLeague,
        weeklyXP,
        leaguePosition,
        streakLength,
        lastStudyDate,
        dailyGoalMinutes,
        preferredStudyTimes,
        enableReminders,
        reminderTimes,
        skillFocus,
        unlockedAchievements,
        milestones,
        completedChallenges,
        createdAt,
        updatedAt,
      ];
}

class LanguageLessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String userId;
  final String lessonType; // vocabulary, grammar, conversation, story, etc.
  final String skillType; // reading, writing, speaking, listening
  final String title;
  final String? description;
  final int level;
  final int order;
  
  // Lesson content
  final List<ExerciseEntity> exercises;
  final int totalExercises;
  final int completedExercises;
  final Map<String, dynamic> lessonData;
  
  // Progress and performance
  final bool isCompleted;
  final DateTime? completedAt;
  final int xpEarned;
  final double accuracyRate;
  final Duration timeSpent;
  final int attempts;
  final DateTime? lastAttempt;
  
  // Story mode specific
  final String? storyTheme;
  final String? storyText;
  final List<String> newVocabulary;
  final Map<String, String> translations;
  
  // Live class integration
  final String? liveClassId;
  final DateTime? scheduledTime;
  final bool requiresTeacher;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LanguageLessonEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.lessonType,
    required this.skillType,
    required this.title,
    this.description,
    required this.level,
    required this.order,
    this.exercises = const [],
    this.totalExercises = 0,
    this.completedExercises = 0,
    this.lessonData = const {},
    this.isCompleted = false,
    this.completedAt,
    this.xpEarned = 0,
    this.accuracyRate = 0.0,
    this.timeSpent = Duration.zero,
    this.attempts = 0,
    this.lastAttempt,
    this.storyTheme,
    this.storyText,
    this.newVocabulary = const [],
    this.translations = const {},
    this.liveClassId,
    this.scheduledTime,
    this.requiresTeacher = false,
    required this.createdAt,
    this.updatedAt,
  });

  double get progressPercentage {
    if (totalExercises == 0) return 0.0;
    return completedExercises / totalExercises;
  }

  bool get isAvailable => true; // Can add logic for prerequisites
  bool get isStoryLesson => lessonType == 'story';
  bool get isLiveClass => liveClassId != null;

  LanguageLessonEntity copyWith({
    String? id,
    String? courseId,
    String? userId,
    String? lessonType,
    String? skillType,
    String? title,
    String? description,
    int? level,
    int? order,
    List<ExerciseEntity>? exercises,
    int? totalExercises,
    int? completedExercises,
    Map<String, dynamic>? lessonData,
    bool? isCompleted,
    DateTime? completedAt,
    int? xpEarned,
    double? accuracyRate,
    Duration? timeSpent,
    int? attempts,
    DateTime? lastAttempt,
    String? storyTheme,
    String? storyText,
    List<String>? newVocabulary,
    Map<String, String>? translations,
    String? liveClassId,
    DateTime? scheduledTime,
    bool? requiresTeacher,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LanguageLessonEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      lessonType: lessonType ?? this.lessonType,
      skillType: skillType ?? this.skillType,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      order: order ?? this.order,
      exercises: exercises ?? this.exercises,
      totalExercises: totalExercises ?? this.totalExercises,
      completedExercises: completedExercises ?? this.completedExercises,
      lessonData: lessonData ?? this.lessonData,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      timeSpent: timeSpent ?? this.timeSpent,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      storyTheme: storyTheme ?? this.storyTheme,
      storyText: storyText ?? this.storyText,
      newVocabulary: newVocabulary ?? this.newVocabulary,
      translations: translations ?? this.translations,
      liveClassId: liveClassId ?? this.liveClassId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      requiresTeacher: requiresTeacher ?? this.requiresTeacher,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        userId,
        lessonType,
        skillType,
        title,
        description,
        level,
        order,
        exercises,
        totalExercises,
        completedExercises,
        lessonData,
        isCompleted,
        completedAt,
        xpEarned,
        accuracyRate,
        timeSpent,
        attempts,
        lastAttempt,
        storyTheme,
        storyText,
        newVocabulary,
        translations,
        liveClassId,
        scheduledTime,
        requiresTeacher,
        createdAt,
        updatedAt,
      ];
}

class ExerciseEntity extends Equatable {
  final String id;
  final String lessonId;
  final String exerciseType; // multiple_choice, translation, listening, speaking, etc.
  final String question;
  final Map<String, dynamic> content; // Question data, audio URLs, etc.
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final List<String> acceptableAnswers; // Alternative correct answers
  final String? hint;
  final String? explanation;
  
  // User response and performance
  final String? userAnswer;
  final bool isCorrect;
  final DateTime? answeredAt;
  final Duration? responseTime;
  final int attempts;
  final List<String> previousAnswers;
  
  // Pronunciation (for speaking exercises)
  final String? audioUrl; // Native speaker audio
  final String? userAudioUrl; // User's recording
  final double? pronunciationScore; // 0-100
  final Map<String, dynamic> pronunciationFeedback;
  
  // Spaced repetition
  final int repetitionNumber;
  final double easeFactor;
  final DateTime nextReview;
  
  final int order;
  final DateTime createdAt;

  const ExerciseEntity({
    required this.id,
    required this.lessonId,
    required this.exerciseType,
    required this.question,
    this.content = const {},
    this.options = const [],
    required this.correctAnswer,
    this.acceptableAnswers = const [],
    this.hint,
    this.explanation,
    this.userAnswer,
    this.isCorrect = false,
    this.answeredAt,
    this.responseTime,
    this.attempts = 0,
    this.previousAnswers = const [],
    this.audioUrl,
    this.userAudioUrl,
    this.pronunciationScore,
    this.pronunciationFeedback = const {},
    this.repetitionNumber = 0,
    this.easeFactor = 2.5,
    required this.nextReview,
    required this.order,
    required this.createdAt,
  });

  bool get isCompleted => userAnswer != null;
  bool get needsReview => DateTime.now().isAfter(nextReview);
  bool get isSpeakingExercise => exerciseType == 'speaking' || exerciseType == 'pronunciation';

  ExerciseEntity copyWith({
    String? id,
    String? lessonId,
    String? exerciseType,
    String? question,
    Map<String, dynamic>? content,
    List<String>? options,
    String? correctAnswer,
    List<String>? acceptableAnswers,
    String? hint,
    String? explanation,
    String? userAnswer,
    bool? isCorrect,
    DateTime? answeredAt,
    Duration? responseTime,
    int? attempts,
    List<String>? previousAnswers,
    String? audioUrl,
    String? userAudioUrl,
    double? pronunciationScore,
    Map<String, dynamic>? pronunciationFeedback,
    int? repetitionNumber,
    double? easeFactor,
    DateTime? nextReview,
    int? order,
    DateTime? createdAt,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      exerciseType: exerciseType ?? this.exerciseType,
      question: question ?? this.question,
      content: content ?? this.content,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      acceptableAnswers: acceptableAnswers ?? this.acceptableAnswers,
      hint: hint ?? this.hint,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      responseTime: responseTime ?? this.responseTime,
      attempts: attempts ?? this.attempts,
      previousAnswers: previousAnswers ?? this.previousAnswers,
      audioUrl: audioUrl ?? this.audioUrl,
      userAudioUrl: userAudioUrl ?? this.userAudioUrl,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      pronunciationFeedback: pronunciationFeedback ?? this.pronunciationFeedback,
      repetitionNumber: repetitionNumber ?? this.repetitionNumber,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReview: nextReview ?? this.nextReview,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lessonId,
        exerciseType,
        question,
        content,
        options,
        correctAnswer,
        acceptableAnswers,
        hint,
        explanation,
        userAnswer,
        isCorrect,
        answeredAt,
        responseTime,
        attempts,
        previousAnswers,
        audioUrl,
        userAudioUrl,
        pronunciationScore,
        pronunciationFeedback,
        repetitionNumber,
        easeFactor,
        nextReview,
        order,
        createdAt,
      ];
}

class VocabularyWordEntity extends Equatable {
  final String id;
  final String courseId;
  final String userId;
  final String word;
  final String translation;
  final String targetLanguage;
  final String nativeLanguage;
  final String? pronunciation; // IPA or phonetic spelling
  final String? audioUrl;
  final List<String> definitions;
  final List<String> exampleSentences;
  final List<String> synonyms;
  final String partOfSpeech; // noun, verb, adjective, etc.
  final String difficulty; // beginner, intermediate, advanced
  
  // Learning progress
  final int strength; // 0-5 mastery level
  final DateTime? lastReviewed;
  final DateTime nextReview;
  final int reviewCount;
  final double accuracyRate;
  final List<DateTime> reviewHistory;
  
  // Spaced repetition data
  final int repetitionNumber;
  final double easeFactor;
  final int intervalDays;
  
  // Context and usage
  final List<String> tags;
  final List<String> relatedWords;
  final String? wordFamily; // Group of related words
  final Map<String, String> conjugations; // For verbs
  final Map<String, String> declensions; // For nouns in some languages
  
  // Learning source
  final String source; // lesson, story, conversation, manual_add
  final String? sourceId; // ID of lesson/story where first encountered
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VocabularyWordEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.word,
    required this.translation,
    required this.targetLanguage,
    required this.nativeLanguage,
    this.pronunciation,
    this.audioUrl,
    this.definitions = const [],
    this.exampleSentences = const [],
    this.synonyms = const [],
    this.partOfSpeech = 'unknown',
    this.difficulty = 'beginner',
    this.strength = 0,
    this.lastReviewed,
    required this.nextReview,
    this.reviewCount = 0,
    this.accuracyRate = 0.0,
    this.reviewHistory = const [],
    this.repetitionNumber = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.tags = const [],
    this.relatedWords = const [],
    this.wordFamily,
    this.conjugations = const {},
    this.declensions = const {},
    this.source = 'manual_add',
    this.sourceId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isMastered => strength >= 4;
  bool get needsReview => DateTime.now().isAfter(nextReview);
  bool get isNew => reviewCount == 0;

  VocabularyWordEntity copyWith({
    String? id,
    String? courseId,
    String? userId,
    String? word,
    String? translation,
    String? targetLanguage,
    String? nativeLanguage,
    String? pronunciation,
    String? audioUrl,
    List<String>? definitions,
    List<String>? exampleSentences,
    List<String>? synonyms,
    String? partOfSpeech,
    String? difficulty,
    int? strength,
    DateTime? lastReviewed,
    DateTime? nextReview,
    int? reviewCount,
    double? accuracyRate,
    List<DateTime>? reviewHistory,
    int? repetitionNumber,
    double? easeFactor,
    int? intervalDays,
    List<String>? tags,
    List<String>? relatedWords,
    String? wordFamily,
    Map<String, String>? conjugations,
    Map<String, String>? declensions,
    String? source,
    String? sourceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyWordEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      definitions: definitions ?? this.definitions,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      synonyms: synonyms ?? this.synonyms,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      difficulty: difficulty ?? this.difficulty,
      strength: strength ?? this.strength,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      reviewCount: reviewCount ?? this.reviewCount,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      reviewHistory: reviewHistory ?? this.reviewHistory,
      repetitionNumber: repetitionNumber ?? this.repetitionNumber,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      tags: tags ?? this.tags,
      relatedWords: relatedWords ?? this.relatedWords,
      wordFamily: wordFamily ?? this.wordFamily,
      conjugations: conjugations ?? this.conjugations,
      declensions: declensions ?? this.declensions,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        userId,
        word,
        translation,
        targetLanguage,
        nativeLanguage,
        pronunciation,
        audioUrl,
        definitions,
        exampleSentences,
        synonyms,
        partOfSpeech,
        difficulty,
        strength,
        lastReviewed,
        nextReview,
        reviewCount,
        accuracyRate,
        reviewHistory,
        repetitionNumber,
        easeFactor,
        intervalDays,
        tags,
        relatedWords,
        wordFamily,
        conjugations,
        declensions,
        source,
        sourceId,
        createdAt,
        updatedAt,
      ];
}
