import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/language_entity.dart';
import '../../data/repositories/language_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Language Course Use Case
@injectable
class CreateLanguageCourseUseCase implements UseCase<LanguageCourseEntity, CreateLanguageCourseParams> {
  final LanguageRepository repository;

  CreateLanguageCourseUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageCourseEntity>> call(CreateLanguageCourseParams params) async {
    return await repository.createCourse(params.userId, params.courseData);
  }
}

class CreateLanguageCourseParams {
  final String userId;
  final Map<String, dynamic> courseData;

  CreateLanguageCourseParams({required this.userId, required this.courseData});
}

// Get User Language Courses Use Case
@injectable
class GetUserLanguageCoursesUseCase implements UseCase<List<LanguageCourseEntity>, String> {
  final LanguageRepository repository;

  GetUserLanguageCoursesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LanguageCourseEntity>>> call(String userId) async {
    return await repository.getUserCourses(userId);
  }
}

// Start Language Lesson Use Case
@injectable
class StartLanguageLessonUseCase implements UseCase<LanguageLessonEntity, StartLanguageLessonParams> {
  final LanguageRepository repository;

  StartLanguageLessonUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageLessonEntity>> call(StartLanguageLessonParams params) async {
    return await repository.startLesson(params.courseId, params.lessonData);
  }
}

class StartLanguageLessonParams {
  final String courseId;
  final Map<String, dynamic> lessonData;

  StartLanguageLessonParams({required this.courseId, required this.lessonData});
}

// Complete Language Lesson Use Case
@injectable
class CompleteLanguageLessonUseCase implements UseCase<LanguageLessonEntity, CompleteLanguageLessonParams> {
  final LanguageRepository repository;

  CompleteLanguageLessonUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageLessonEntity>> call(CompleteLanguageLessonParams params) async {
    return await repository.completeLesson(params.lessonId, params.completionData);
  }
}

class CompleteLanguageLessonParams {
  final String lessonId;
  final Map<String, dynamic> completionData;

  CompleteLanguageLessonParams({required this.lessonId, required this.completionData});
}

// Complete Language Exercise Use Case
@injectable
class CompleteLanguageExerciseUseCase implements UseCase<ExerciseEntity, CompleteLanguageExerciseParams> {
  final LanguageRepository repository;

  CompleteLanguageExerciseUseCase(this.repository);

  @override
  Future<Either<Failure, ExerciseEntity>> call(CompleteLanguageExerciseParams params) async {
    return await repository.completeExercise(params.exerciseId, params.responseData);
  }
}

class CompleteLanguageExerciseParams {
  final String exerciseId;
  final Map<String, dynamic> responseData;

  CompleteLanguageExerciseParams({required this.exerciseId, required this.responseData});
}

// Add Vocabulary Word Use Case
@injectable
class AddVocabularyWordUseCase implements UseCase<VocabularyWordEntity, AddVocabularyWordParams> {
  final LanguageRepository repository;

  AddVocabularyWordUseCase(this.repository);

  @override
  Future<Either<Failure, VocabularyWordEntity>> call(AddVocabularyWordParams params) async {
    return await repository.addVocabularyWord(params.courseId, params.wordData);
  }
}

class AddVocabularyWordParams {
  final String courseId;
  final Map<String, dynamic> wordData;

  AddVocabularyWordParams({required this.courseId, required this.wordData});
}

// Get Words For Review Use Case
@injectable
class GetWordsForReviewUseCase implements UseCase<List<VocabularyWordEntity>, String> {
  final LanguageRepository repository;

  GetWordsForReviewUseCase(this.repository);

  @override
  Future<Either<Failure, List<VocabularyWordEntity>>> call(String courseId) async {
    return await repository.getWordsForReview(courseId);
  }
}

// Get Course Vocabulary Use Case
@injectable
class GetCourseVocabularyUseCase implements UseCase<List<VocabularyWordEntity>, String> {
  final LanguageRepository repository;

  GetCourseVocabularyUseCase(this.repository);

  @override
  Future<Either<Failure, List<VocabularyWordEntity>>> call(String courseId) async {
    return await repository.getCourseVocabulary(courseId);
  }
}

// Get Language Analytics Use Case
@injectable
class GetLanguageAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetLanguageAnalyticsParams> {
  final LanguageRepository repository;

  GetLanguageAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetLanguageAnalyticsParams params) async {
    return await repository.getLanguageAnalytics(params.userId, params.courseId);
  }
}

class GetLanguageAnalyticsParams {
  final String userId;
  final String courseId;

  GetLanguageAnalyticsParams({required this.userId, required this.courseId});
}

// Generate AI Story Use Case
@injectable
class GenerateAIStoryUseCase implements UseCase<Map<String, dynamic>, GenerateAIStoryParams> {
  final LanguageRepository repository;

  GenerateAIStoryUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GenerateAIStoryParams params) async {
    return await repository.generateAIStory(params.courseId, params.theme, params.difficulty);
  }
}

class GenerateAIStoryParams {
  final String courseId;
  final String theme;
  final String difficulty;

  GenerateAIStoryParams({
    required this.courseId,
    required this.theme,
    required this.difficulty,
  });
}

// Analyze Pronunciation Use Case
@injectable
class AnalyzePronunciationUseCase implements UseCase<double, AnalyzePronunciationParams> {
  final LanguageRepository repository;

  AnalyzePronunciationUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(AnalyzePronunciationParams params) async {
    return await repository.analyzePronunciation(params.exerciseId, params.audioData);
  }
}

class AnalyzePronunciationParams {
  final String exerciseId;
  final String audioData;

  AnalyzePronunciationParams({required this.exerciseId, required this.audioData});
}

// Sync Language Data Use Case
@injectable
class SyncLanguageDataUseCase implements UseCase<bool, String> {
  final LanguageRepository repository;

  SyncLanguageDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncLanguageData(userId);
  }
}

// Calculate Language Proficiency Use Case
@injectable
class CalculateLanguageProficiencyUseCase implements UseCase<Map<String, dynamic>, String> {
  final LanguageRepository repository;

  CalculateLanguageProficiencyUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String courseId) async {
    try {
      final vocabularyResult = await repository.getCourseVocabulary(courseId);
      
      return vocabularyResult.fold(
        (failure) => Left(failure),
        (vocabulary) {
          final proficiencyData = _calculateProficiency(vocabulary);
          return Right(proficiencyData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate proficiency: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateProficiency(List<VocabularyWordEntity> vocabulary) {
    if (vocabulary.isEmpty) {
      return {
        'proficiency_level': 'Beginner',
        'proficiency_score': 0,
        'vocabulary_size': 0,
        'mastery_percentage': 0.0,
        'level_description': 'Start learning vocabulary to build your foundation',
      };
    }
    
    final totalWords = vocabulary.length;
    final masteredWords = vocabulary.where((word) => word.masteryLevel >= 0.8).length;
    final masteryPercentage = (masteredWords / totalWords) * 100;
    
    String level;
    int score;
    String description;
    
    if (totalWords < 100) {
      level = 'Beginner';
      score = (totalWords / 100 * 25).round();
      description = 'Building basic vocabulary foundation';
    } else if (totalWords < 500) {
      level = 'Elementary';
      score = 25 + ((totalWords - 100) / 400 * 25).round();
      description = 'Developing essential vocabulary';
    } else if (totalWords < 1500) {
      level = 'Intermediate';
      score = 50 + ((totalWords - 500) / 1000 * 25).round();
      description = 'Expanding vocabulary for daily communication';
    } else if (totalWords < 3000) {
      level = 'Upper-Intermediate';
      score = 75 + ((totalWords - 1500) / 1500 * 15).round();
      description = 'Advanced vocabulary for complex topics';
    } else {
      level = 'Advanced';
      score = 90 + (masteryPercentage / 100 * 10).round();
      description = 'Extensive vocabulary mastery';
    }
    
    return {
      'proficiency_level': level,
      'proficiency_score': score.clamp(0, 100),
      'vocabulary_size': totalWords,
      'mastered_words': masteredWords,
      'mastery_percentage': masteryPercentage.round(),
      'level_description': description,
      'next_milestone': _getNextMilestone(totalWords),
      'skill_breakdown': _calculateSkillBreakdown(vocabulary),
    };
  }

  Map<String, dynamic> _getNextMilestone(int currentWords) {
    final milestones = [100, 500, 1500, 3000, 5000];
    
    for (final milestone in milestones) {
      if (currentWords < milestone) {
        return {
          'target': milestone,
          'remaining': milestone - currentWords,
          'progress': (currentWords / milestone * 100).round(),
        };
      }
    }
    
    return {
      'target': 'Mastery',
      'remaining': 0,
      'progress': 100,
    };
  }

  Map<String, dynamic> _calculateSkillBreakdown(List<VocabularyWordEntity> vocabulary) {
    final categories = <String, List<VocabularyWordEntity>>{};
    
    for (final word in vocabulary) {
      final category = word.category ?? 'General';
      categories[category] ??= [];
      categories[category]!.add(word);
    }
    
    final breakdown = <String, Map<String, dynamic>>{};
    
    categories.forEach((category, words) {
      final mastered = words.where((w) => w.masteryLevel >= 0.8).length;
      final total = words.length;
      final percentage = total > 0 ? (mastered / total * 100).round() : 0;
      
      breakdown[category] = {
        'total_words': total,
        'mastered_words': mastered,
        'mastery_percentage': percentage,
        'level': _getCategoryLevel(percentage),
      };
    });
    
    return breakdown;
  }

  String _getCategoryLevel(int percentage) {
    if (percentage >= 90) return 'Expert';
    if (percentage >= 70) return 'Advanced';
    if (percentage >= 50) return 'Intermediate';
    if (percentage >= 25) return 'Elementary';
    return 'Beginner';
  }
}

// Get Learning Streaks Use Case
@injectable
class GetLanguageLearningStreaksUseCase implements UseCase<Map<String, dynamic>, String> {
  final LanguageRepository repository;

  GetLanguageLearningStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final coursesResult = await repository.getUserCourses(userId);
      
      return coursesResult.fold(
        (failure) => Left(failure),
        (courses) async {
          final streakData = <String, dynamic>{};
          
          for (final course in courses) {
            final analyticsResult = await repository.getLanguageAnalytics(userId, course.id);
            
            analyticsResult.fold(
              (failure) => streakData[course.name] = {'current_streak': 0, 'longest_streak': 0},
              (analytics) {
                streakData[course.name] = {
                  'current_streak': analytics['current_streak'] ?? 0,
                  'longest_streak': analytics['longest_streak'] ?? 0,
                  'total_lessons': analytics['completed_lessons'] ?? 0,
                  'study_time_hours': analytics['total_study_time'] ?? 0,
                };
              },
            );
          }
          
          return Right({
            'courses': streakData,
            'overall_stats': _calculateOverallStats(streakData),
          });
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get learning streaks: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateOverallStats(Map<String, dynamic> courseData) {
    if (courseData.isEmpty) {
      return {
        'total_current_streak': 0,
        'total_longest_streak': 0,
        'total_lessons': 0,
        'total_study_hours': 0,
      };
    }
    
    var totalCurrentStreak = 0;
    var totalLongestStreak = 0;
    var totalLessons = 0;
    var totalStudyHours = 0;
    
    courseData.values.forEach((data) {
      totalCurrentStreak += (data['current_streak'] as int? ?? 0);
      totalLongestStreak += (data['longest_streak'] as int? ?? 0);
      totalLessons += (data['total_lessons'] as int? ?? 0);
      totalStudyHours += (data['study_time_hours'] as int? ?? 0);
    });
    
    return {
      'total_current_streak': totalCurrentStreak,
      'total_longest_streak': totalLongestStreak,
      'total_lessons': totalLessons,
      'total_study_hours': totalStudyHours,
      'active_courses': courseData.length,
    };
  }
}

// Get Language Learning Recommendations Use Case
@injectable
class GetLanguageLearningRecommendationsUseCase implements UseCase<List<Map<String, dynamic>>, String> {
  final LanguageRepository repository;

  GetLanguageLearningRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String userId) async {
    try {
      final coursesResult = await repository.getUserCourses(userId);
      
      return coursesResult.fold(
        (failure) => Left(failure),
        (courses) async {
          final recommendations = <Map<String, dynamic>>[];
          
          if (courses.isEmpty) {
            recommendations.add({
              'type': 'start_learning',
              'title': 'Start Your Language Journey',
              'description': 'Choose a language and begin with basic vocabulary',
              'priority': 'high',
              'action': 'create_course',
            });
            return Right(recommendations);
          }
          
          for (final course in courses) {
            final vocabularyResult = await repository.getCourseVocabulary(course.id);
            final wordsForReviewResult = await repository.getWordsForReview(course.id);
            
            vocabularyResult.fold(
              (failure) => null,
              (vocabulary) {
                wordsForReviewResult.fold(
                  (failure) => null,
                  (reviewWords) {
                    // Review recommendations
                    if (reviewWords.isNotEmpty) {
                      recommendations.add({
                        'type': 'review',
                        'course_id': course.id,
                        'course_name': course.name,
                        'title': 'Review ${reviewWords.length} words',
                        'description': 'Keep your vocabulary fresh with spaced repetition',
                        'priority': 'high',
                        'words_count': reviewWords.length,
                      });
                    }
                    
                    // Progress recommendations
                    if (vocabulary.length < 50) {
                      recommendations.add({
                        'type': 'vocabulary_building',
                        'course_id': course.id,
                        'course_name': course.name,
                        'title': 'Build Your Vocabulary',
                        'description': 'Learn ${50 - vocabulary.length} more words to reach 50',
                        'priority': 'medium',
                        'target': 50,
                        'current': vocabulary.length,
                      });
                    }
                    
                    // Skill balance recommendations
                    final skillGaps = _analyzeSkillGaps(vocabulary);
                    for (final gap in skillGaps) {
                      recommendations.add({
                        'type': 'skill_improvement',
                        'course_id': course.id,
                        'course_name': course.name,
                        'title': 'Improve ${gap['skill']}',
                        'description': gap['suggestion'],
                        'priority': 'low',
                      });
                    }
                  },
                );
              },
            );
          }
          
          return Right(recommendations);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate recommendations: ${e.toString()}'));
    }
  }

  List<Map<String, dynamic>> _analyzeSkillGaps(List<VocabularyWordEntity> vocabulary) {
    final gaps = <Map<String, dynamic>>[];
    
    // Analyze by difficulty level
    final difficulties = <String, int>{};
    for (final word in vocabulary) {
      final difficulty = word.difficultyLevel ?? 'beginner';
      difficulties[difficulty] = (difficulties[difficulty] ?? 0) + 1;
    }
    
    if ((difficulties['intermediate'] ?? 0) < vocabulary.length * 0.3) {
      gaps.add({
        'skill': 'Intermediate Vocabulary',
        'suggestion': 'Start learning intermediate level words to challenge yourself',
      });
    }
    
    if ((difficulties['advanced'] ?? 0) < vocabulary.length * 0.1 && vocabulary.length > 200) {
      gaps.add({
        'skill': 'Advanced Vocabulary',
        'suggestion': 'Add advanced words to reach native-like proficiency',
      });
    }
    
    return gaps;
  }
}
