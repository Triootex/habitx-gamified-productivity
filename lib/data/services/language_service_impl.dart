import 'package:injectable/injectable.dart';
import '../../domain/entities/language_entity.dart';
import '../../core/utils/language_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class LanguageService {
  Future<LanguageCourseEntity> createCourse(String userId, Map<String, dynamic> courseData);
  Future<List<LanguageCourseEntity>> getUserCourses(String userId);
  Future<LanguageLessonEntity> startLesson(String courseId, Map<String, dynamic> lessonData);
  Future<LanguageLessonEntity> completeLesson(String lessonId, Map<String, dynamic> completionData);
  Future<ExerciseEntity> completeExercise(String exerciseId, Map<String, dynamic> responseData);
  Future<VocabularyWordEntity> addVocabularyWord(String courseId, Map<String, dynamic> wordData);
  Future<List<VocabularyWordEntity>> getWordsForReview(String courseId);
  Future<Map<String, dynamic>> getLanguageAnalytics(String userId, String courseId);
  Future<Map<String, dynamic>> generateAIStory(String courseId, String theme, String difficulty);
  Future<double> analyzePronunciation(String exerciseId, String audioData);
}

@LazySingleton(as: LanguageService)
class LanguageServiceImpl implements LanguageService {
  @override
  Future<LanguageCourseEntity> createCourse(String userId, Map<String, dynamic> courseData) async {
    try {
      final now = DateTime.now();
      final courseId = 'course_${now.millisecondsSinceEpoch}';
      
      final course = LanguageCourseEntity(
        id: courseId,
        userId: userId,
        targetLanguage: courseData['target_language'] as String,
        nativeLanguage: courseData['native_language'] as String? ?? 'en',
        proficiencyLevel: courseData['proficiency_level'] as String? ?? 'a1_beginner',
        courseType: courseData['course_type'] as String? ?? 'structured',
        startDate: now,
        dailyGoalMinutes: courseData['daily_goal_minutes'] as int? ?? 15,
        preferredStudyTimes: (courseData['preferred_times'] as List<dynamic>?)?.cast<String>() ?? [],
        enableReminders: courseData['enable_reminders'] as bool? ?? true,
        reminderTimes: (courseData['reminder_times'] as List<dynamic>?)?.cast<String>() ?? [],
        skillFocus: Map<String, bool>.from(courseData['skill_focus'] ?? {
          'reading': true,
          'writing': true,
          'speaking': true,
          'listening': true,
        }),
        createdAt: now,
      );
      
      return course;
    } catch (e) {
      throw Exception('Failed to create language course: ${e.toString()}');
    }
  }

  @override
  Future<List<LanguageCourseEntity>> getUserCourses(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockCourses(userId);
    } catch (e) {
      throw Exception('Failed to retrieve user courses: ${e.toString()}');
    }
  }

  @override
  Future<LanguageLessonEntity> startLesson(String courseId, Map<String, dynamic> lessonData) async {
    try {
      final now = DateTime.now();
      final lessonId = 'lesson_${now.millisecondsSinceEpoch}';
      
      final lesson = LanguageLessonEntity(
        id: lessonId,
        courseId: courseId,
        userId: lessonData['user_id'] as String,
        lessonType: lessonData['lesson_type'] as String? ?? 'vocabulary',
        skillType: lessonData['skill_type'] as String? ?? 'reading',
        title: lessonData['title'] as String,
        description: lessonData['description'] as String?,
        level: lessonData['level'] as int? ?? 1,
        order: lessonData['order'] as int? ?? 1,
        exercises: _generateLessonExercises(lessonId, lessonData),
        totalExercises: lessonData['total_exercises'] as int? ?? 10,
        storyTheme: lessonData['story_theme'] as String?,
        storyText: lessonData['story_text'] as String?,
        newVocabulary: (lessonData['new_vocabulary'] as List<dynamic>?)?.cast<String>() ?? [],
        translations: Map<String, String>.from(lessonData['translations'] ?? {}),
        liveClassId: lessonData['live_class_id'] as String?,
        scheduledTime: lessonData['scheduled_time'] != null
            ? DateTime.parse(lessonData['scheduled_time'] as String)
            : null,
        requiresTeacher: lessonData['requires_teacher'] as bool? ?? false,
        createdAt: now,
      );
      
      return lesson;
    } catch (e) {
      throw Exception('Failed to start lesson: ${e.toString()}');
    }
  }

  @override
  Future<LanguageLessonEntity> completeLesson(String lessonId, Map<String, dynamic> completionData) async {
    try {
      final lesson = await _getLessonById(lessonId);
      if (lesson == null) {
        throw Exception('Lesson not found');
      }
      
      final now = DateTime.now();
      final duration = lesson.timeSpent.inMinutes + (completionData['additional_time'] as int? ?? 0);
      
      // Calculate accuracy and XP
      final completedExercises = completionData['completed_exercises'] as int? ?? lesson.totalExercises;
      final accuracyRate = completionData['accuracy_rate'] as double? ?? 0.8;
      final xpEarned = LanguageUtils.calculateLessonXP(
        lessonType: lesson.lessonType,
        accuracy: accuracyRate,
        timeSpent: duration,
        difficultyLevel: lesson.level,
      );
      
      final completedLesson = lesson.copyWith(
        isCompleted: true,
        completedAt: now,
        completedExercises: completedExercises,
        xpEarned: xpEarned,
        accuracyRate: accuracyRate,
        timeSpent: Duration(minutes: duration),
        attempts: lesson.attempts + 1,
        lastAttempt: now,
        updatedAt: now,
      );
      
      // Award XP to user
      await _awardLanguageXP(lesson.userId, xpEarned);
      
      return completedLesson;
    } catch (e) {
      throw Exception('Failed to complete lesson: ${e.toString()}');
    }
  }

  @override
  Future<ExerciseEntity> completeExercise(String exerciseId, Map<String, dynamic> responseData) async {
    try {
      final exercise = await _getExerciseById(exerciseId);
      if (exercise == null) {
        throw Exception('Exercise not found');
      }
      
      final now = DateTime.now();
      final userAnswer = responseData['user_answer'] as String;
      final isCorrect = _checkAnswer(exercise, userAnswer);
      
      // Apply spaced repetition for vocabulary
      final updatedExercise = LanguageUtils.applySpacedRepetition(
        exercise: exercise,
        wasCorrect: isCorrect,
        responseTime: responseData['response_time'] as int? ?? 5000,
      );
      
      // Handle pronunciation exercises
      double? pronunciationScore;
      if (exercise.exerciseType == 'speaking' || exercise.exerciseType == 'pronunciation') {
        pronunciationScore = await _analyzePronunciation(
          exercise.correctAnswer,
          responseData['audio_data'] as String?
        );
      }
      
      return updatedExercise.copyWith(
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        answeredAt: now,
        responseTime: Duration(milliseconds: responseData['response_time'] as int? ?? 5000),
        attempts: exercise.attempts + 1,
        previousAnswers: [...exercise.previousAnswers, userAnswer],
        pronunciationScore: pronunciationScore,
        userAudioUrl: responseData['audio_url'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to complete exercise: ${e.toString()}');
    }
  }

  @override
  Future<VocabularyWordEntity> addVocabularyWord(String courseId, Map<String, dynamic> wordData) async {
    try {
      final now = DateTime.now();
      final wordId = 'word_${now.millisecondsSinceEpoch}';
      
      final word = VocabularyWordEntity(
        id: wordId,
        courseId: courseId,
        userId: wordData['user_id'] as String,
        word: wordData['word'] as String,
        translation: wordData['translation'] as String,
        targetLanguage: wordData['target_language'] as String,
        nativeLanguage: wordData['native_language'] as String,
        pronunciation: wordData['pronunciation'] as String?,
        audioUrl: wordData['audio_url'] as String?,
        definitions: (wordData['definitions'] as List<dynamic>?)?.cast<String>() ?? [],
        exampleSentences: (wordData['examples'] as List<dynamic>?)?.cast<String>() ?? [],
        synonyms: (wordData['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
        partOfSpeech: wordData['part_of_speech'] as String? ?? 'unknown',
        difficulty: wordData['difficulty'] as String? ?? 'beginner',
        nextReview: now.add(const Duration(days: 1)),
        tags: (wordData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        relatedWords: (wordData['related_words'] as List<dynamic>?)?.cast<String>() ?? [],
        source: wordData['source'] as String? ?? 'manual_add',
        sourceId: wordData['source_id'] as String?,
        createdAt: now,
      );
      
      return word;
    } catch (e) {
      throw Exception('Failed to add vocabulary word: ${e.toString()}');
    }
  }

  @override
  Future<List<VocabularyWordEntity>> getWordsForReview(String courseId) async {
    try {
      final words = await _getCourseVocabulary(courseId);
      final now = DateTime.now();
      
      return words.where((word) => word.nextReview.isBefore(now) || word.nextReview.isAtSameMomentAs(now)).toList();
    } catch (e) {
      throw Exception('Failed to get words for review: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getLanguageAnalytics(String userId, String courseId) async {
    try {
      final course = await _getCourseById(courseId);
      if (course == null) {
        throw Exception('Course not found');
      }
      
      final lessons = await _getCourseLessons(courseId);
      final vocabulary = await _getCourseVocabulary(courseId);
      
      final completedLessons = lessons.where((l) => l.isCompleted).length;
      final totalLessons = lessons.length;
      final overallProgress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
      
      final vocabularyMastered = vocabulary.where((w) => w.isMastered).length;
      final vocabularyTotal = vocabulary.length;
      
      return {
        'course_progress': {
          'total_lessons': totalLessons,
          'completed_lessons': completedLessons,
          'progress_percentage': overallProgress,
          'current_level': course.currentLevel,
          'total_xp': course.totalXP,
        },
        'vocabulary_stats': {
          'total_words': vocabularyTotal,
          'mastered_words': vocabularyMastered,
          'words_for_review': vocabulary.where((w) => w.needsReview).length,
          'average_strength': vocabularyTotal > 0 
              ? vocabulary.fold<int>(0, (sum, w) => sum + w.strength) / vocabularyTotal 
              : 0.0,
        },
        'skill_progress': course.skillProgress,
        'league_info': {
          'current_league': course.currentLeague,
          'weekly_xp': course.weeklyXP,
          'league_position': course.leaguePosition,
        },
        'streak_info': {
          'current_streak': course.streakLength,
          'last_study_date': course.lastStudyDate?.toIso8601String(),
        },
        'insights': _generateLanguageInsights(course, lessons, vocabulary),
      };
    } catch (e) {
      throw Exception('Failed to get language analytics: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateAIStory(String courseId, String theme, String difficulty) async {
    try {
      return LanguageUtils.generateAIStory(
        targetLanguage: 'spanish', // Mock language
        userLevel: difficulty,
        theme: theme,
        wordCount: 200,
        knownVocabulary: [], // Mock known vocabulary
      );
    } catch (e) {
      throw Exception('Failed to generate AI story: ${e.toString()}');
    }
  }

  @override
  Future<double> analyzePronunciation(String exerciseId, String audioData) async {
    try {
      final exercise = await _getExerciseById(exerciseId);
      if (exercise == null) {
        throw Exception('Exercise not found');
      }
      
      return await _analyzePronunciation(exercise.correctAnswer, audioData);
    } catch (e) {
      throw Exception('Failed to analyze pronunciation: ${e.toString()}');
    }
  }

  // Private helper methods
  List<LanguageCourseEntity> _generateMockCourses(String userId) {
    final now = DateTime.now();
    
    return [
      LanguageCourseEntity(
        id: 'course_1',
        userId: userId,
        targetLanguage: 'spanish',
        nativeLanguage: 'english',
        proficiencyLevel: 'a2_elementary',
        courseType: 'structured',
        startDate: now.subtract(const Duration(days: 30)),
        totalXP: 1250,
        currentLevel: 8,
        lessonsCompleted: 25,
        totalLessons: 100,
        overallProgress: 0.25,
        skillProgress: {
          'reading': 30,
          'writing': 20,
          'speaking': 15,
          'listening': 25,
        },
        currentLeague: 'silver',
        weeklyXP: 180,
        leaguePosition: 15,
        streakLength: 7,
        lastStudyDate: now.subtract(const Duration(hours: 18)),
        dailyGoalMinutes: 20,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  List<ExerciseEntity> _generateLessonExercises(String lessonId, Map<String, dynamic> lessonData) {
    final now = DateTime.now();
    
    return [
      ExerciseEntity(
        id: 'exercise_1',
        lessonId: lessonId,
        exerciseType: 'multiple_choice',
        question: 'What does "Hola" mean?',
        content: {'text': 'Hola'},
        options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
        correctAnswer: 'Hello',
        acceptableAnswers: ['Hello', 'Hi'],
        hint: 'This is a common greeting',
        explanation: 'Hola is the most common way to say hello in Spanish',
        nextReview: now.add(const Duration(days: 1)),
        order: 1,
        createdAt: now,
      ),
      ExerciseEntity(
        id: 'exercise_2',
        lessonId: lessonId,
        exerciseType: 'translation',
        question: 'Translate: "Good morning"',
        content: {'text': 'Good morning'},
        correctAnswer: 'Buenos días',
        acceptableAnswers: ['Buenos días', 'Buenos dias'],
        hint: 'Think about the time of day',
        explanation: 'Buenos días is used to greet someone in the morning',
        nextReview: now.add(const Duration(days: 1)),
        order: 2,
        createdAt: now,
      ),
    ];
  }

  Future<LanguageLessonEntity?> _getLessonById(String lessonId) async {
    // Mock lesson retrieval
    final now = DateTime.now();
    return LanguageLessonEntity(
      id: lessonId,
      courseId: 'course_1',
      userId: 'user_id',
      lessonType: 'vocabulary',
      skillType: 'reading',
      title: 'Basic Greetings',
      level: 1,
      order: 1,
      totalExercises: 10,
      timeSpent: const Duration(minutes: 15),
      createdAt: now.subtract(const Duration(minutes: 20)),
    );
  }

  Future<ExerciseEntity?> _getExerciseById(String exerciseId) async {
    final exercises = _generateLessonExercises('lesson_1', {});
    try {
      return exercises.firstWhere((e) => e.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  Future<LanguageCourseEntity?> _getCourseById(String courseId) async {
    final courses = _generateMockCourses('user_id');
    try {
      return courses.firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<List<LanguageLessonEntity>> _getCourseLessons(String courseId) async {
    final now = DateTime.now();
    return [
      LanguageLessonEntity(
        id: 'lesson_1',
        courseId: courseId,
        userId: 'user_id',
        lessonType: 'vocabulary',
        skillType: 'reading',
        title: 'Basic Greetings',
        level: 1,
        order: 1,
        totalExercises: 10,
        completedExercises: 10,
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 1)),
        xpEarned: 25,
        accuracyRate: 0.9,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  Future<List<VocabularyWordEntity>> _getCourseVocabulary(String courseId) async {
    final now = DateTime.now();
    return [
      VocabularyWordEntity(
        id: 'word_1',
        courseId: courseId,
        userId: 'user_id',
        word: 'Hola',
        translation: 'Hello',
        targetLanguage: 'spanish',
        nativeLanguage: 'english',
        definitions: ['A greeting used when meeting someone'],
        exampleSentences: ['Hola, ¿cómo estás?'],
        partOfSpeech: 'interjection',
        difficulty: 'beginner',
        strength: 5,
        nextReview: now.subtract(const Duration(hours: 2)), // Due for review
        reviewCount: 8,
        accuracyRate: 0.95,
        source: 'lesson',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  bool _checkAnswer(ExerciseEntity exercise, String userAnswer) {
    final correctAnswers = [exercise.correctAnswer, ...exercise.acceptableAnswers];
    return correctAnswers.any((answer) => 
        answer.toLowerCase().trim() == userAnswer.toLowerCase().trim()
    );
  }

  Future<double> _analyzePronunciation(String targetText, String? audioData) async {
    // Mock pronunciation analysis - in real implementation, would use speech recognition API
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (audioData == null || audioData.isEmpty) {
      return 0.0;
    }
    
    // Simulate pronunciation scoring based on audio quality and length
    final baseScore = 70.0;
    final lengthBonus = targetText.length > 10 ? 10.0 : 5.0;
    final randomVariation = (DateTime.now().millisecond % 20) - 10; // ±10 points
    
    return (baseScore + lengthBonus + randomVariation).clamp(0.0, 100.0);
  }

  Future<void> _awardLanguageXP(String userId, int xpAmount) async {
    print('Awarded $xpAmount XP to user $userId for language learning');
  }

  List<String> _generateLanguageInsights(
    LanguageCourseEntity course,
    List<LanguageLessonEntity> lessons,
    List<VocabularyWordEntity> vocabulary
  ) {
    final insights = <String>[];
    
    if (course.streakLength >= 7) {
      insights.add('🔥 Amazing! You have a ${course.streakLength}-day study streak!');
    } else if (course.streakLength >= 3) {
      insights.add('Great consistency! Keep your study streak going.');
    }
    
    if (course.overallProgress >= 0.5) {
      insights.add('Excellent progress! You\'re halfway through the course.');
    } else if (course.overallProgress >= 0.25) {
      insights.add('Good progress! You\'ve completed a quarter of the course.');
    }
    
    final vocabularyMastery = vocabulary.where((w) => w.isMastered).length / vocabulary.length;
    if (vocabularyMastery >= 0.8) {
      insights.add('Outstanding vocabulary mastery! You know most of the words well.');
    } else if (vocabularyMastery >= 0.6) {
      insights.add('Good vocabulary retention. Keep reviewing to improve further.');
    }
    
    // League insights
    if (course.currentLeague == 'diamond') {
      insights.add('💎 Diamond League! You\'re among the top learners!');
    } else if (course.leaguePosition <= 10) {
      insights.add('🏆 Top 10 in your league! Great competitive spirit!');
    }
    
    return insights;
  }
}
