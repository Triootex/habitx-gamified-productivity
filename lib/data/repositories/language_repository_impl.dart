import 'package:injectable/injectable.dart';
import '../../domain/entities/language_entity.dart';
import '../datasources/local/language_local_data_source.dart';
import '../datasources/remote/language_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class LanguageRepository {
  Future<Either<Failure, LanguageCourseEntity>> createCourse(String userId, Map<String, dynamic> courseData);
  Future<Either<Failure, List<LanguageCourseEntity>>> getUserCourses(String userId);
  Future<Either<Failure, LanguageLessonEntity>> startLesson(String courseId, Map<String, dynamic> lessonData);
  Future<Either<Failure, LanguageLessonEntity>> completeLesson(String lessonId, Map<String, dynamic> completionData);
  Future<Either<Failure, ExerciseEntity>> completeExercise(String exerciseId, Map<String, dynamic> responseData);
  Future<Either<Failure, VocabularyWordEntity>> addVocabularyWord(String courseId, Map<String, dynamic> wordData);
  Future<Either<Failure, List<VocabularyWordEntity>>> getWordsForReview(String courseId);
  Future<Either<Failure, List<VocabularyWordEntity>>> getCourseVocabulary(String courseId);
  Future<Either<Failure, Map<String, dynamic>>> getLanguageAnalytics(String userId, String courseId);
  Future<Either<Failure, Map<String, dynamic>>> generateAIStory(String courseId, String theme, String difficulty);
  Future<Either<Failure, double>> analyzePronunciation(String exerciseId, String audioData);
  Future<Either<Failure, bool>> syncLanguageData(String userId);
}

@LazySingleton(as: LanguageRepository)
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDataSource localDataSource;
  final LanguageRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LanguageRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LanguageCourseEntity>> createCourse(String userId, Map<String, dynamic> courseData) async {
    try {
      // Create course locally first for offline support
      final localCourse = await localDataSource.createCourse(userId, courseData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteCourse = await remoteDataSource.createCourse(userId, courseData);
          // Update local with server ID and sync status
          await localDataSource.updateCourse(localCourse.id, {
            'server_id': remoteCourse.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteCourse);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateCourse(localCourse.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localCourse);
        }
      }
      
      return Right(localCourse);
    } on CacheException {
      return Left(CacheFailure('Failed to create course locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create course on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LanguageCourseEntity>>> getUserCourses(String userId) async {
    try {
      // Always return local courses first for immediate UI response
      List<LanguageCourseEntity> localCourses = [];
      
      try {
        localCourses = await localDataSource.getUserCourses(userId);
      } on CacheException {
        // No local courses, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteCourses = await remoteDataSource.getUserCourses(userId);
          
          // Update local cache with remote data
          await localDataSource.cacheCourses(remoteCourses);
          
          return Right(remoteCourses);
        } catch (e) {
          // Return local courses if remote fails
          if (localCourses.isNotEmpty) {
            return Right(localCourses);
          } else {
            return Left(ServerFailure('Failed to fetch courses and no local cache available'));
          }
        }
      }
      
      return Right(localCourses);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LanguageLessonEntity>> startLesson(String courseId, Map<String, dynamic> lessonData) async {
    try {
      // Start lesson locally first
      final localLesson = await localDataSource.startLesson(courseId, lessonData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteLesson = await remoteDataSource.startLesson(courseId, lessonData);
          // Update local with server ID and sync status
          await localDataSource.updateLesson(localLesson.id, {
            'server_id': remoteLesson.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteLesson);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateLesson(localLesson.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localLesson);
        }
      }
      
      return Right(localLesson);
    } on CacheException {
      return Left(CacheFailure('Failed to start lesson locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to start lesson on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LanguageLessonEntity>> completeLesson(String lessonId, Map<String, dynamic> completionData) async {
    try {
      // Complete lesson locally first
      final localLesson = await localDataSource.completeLesson(lessonId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteLesson = await remoteDataSource.completeLesson(lessonId, completionData);
          // Update local sync status
          await localDataSource.updateLesson(lessonId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteLesson);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateLesson(lessonId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localLesson);
        }
      }
      
      return Right(localLesson);
    } on CacheException {
      return Left(CacheFailure('Failed to complete lesson locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to complete lesson on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExerciseEntity>> completeExercise(String exerciseId, Map<String, dynamic> responseData) async {
    try {
      // Complete exercise locally first
      final localExercise = await localDataSource.completeExercise(exerciseId, responseData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteExercise = await remoteDataSource.completeExercise(exerciseId, responseData);
          // Update local sync status
          await localDataSource.updateExercise(exerciseId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteExercise);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateExercise(exerciseId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localExercise);
        }
      }
      
      return Right(localExercise);
    } on CacheException {
      return Left(CacheFailure('Failed to complete exercise locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to complete exercise on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VocabularyWordEntity>> addVocabularyWord(String courseId, Map<String, dynamic> wordData) async {
    try {
      // Add word locally first
      final localWord = await localDataSource.addVocabularyWord(courseId, wordData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteWord = await remoteDataSource.addVocabularyWord(courseId, wordData);
          // Update local with server ID and sync status
          await localDataSource.updateVocabularyWord(localWord.id, {
            'server_id': remoteWord.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteWord);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateVocabularyWord(localWord.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localWord);
        }
      }
      
      return Right(localWord);
    } on CacheException {
      return Left(CacheFailure('Failed to add vocabulary word locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to add vocabulary word on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VocabularyWordEntity>>> getWordsForReview(String courseId) async {
    try {
      List<VocabularyWordEntity> localWords = [];
      
      try {
        localWords = await localDataSource.getWordsForReview(courseId);
      } on CacheException {
        // No local words
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteWords = await remoteDataSource.getWordsForReview(courseId);
          await localDataSource.cacheVocabularyWords(remoteWords);
          return Right(remoteWords);
        } catch (e) {
          if (localWords.isNotEmpty) {
            return Right(localWords);
          } else {
            return Left(ServerFailure('Failed to fetch words for review'));
          }
        }
      }
      
      return Right(localWords);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VocabularyWordEntity>>> getCourseVocabulary(String courseId) async {
    try {
      List<VocabularyWordEntity> localWords = [];
      
      try {
        localWords = await localDataSource.getCourseVocabulary(courseId);
      } on CacheException {
        // No local words
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteWords = await remoteDataSource.getCourseVocabulary(courseId);
          await localDataSource.cacheVocabularyWords(remoteWords);
          return Right(remoteWords);
        } catch (e) {
          if (localWords.isNotEmpty) {
            return Right(localWords);
          } else {
            return Left(ServerFailure('Failed to fetch course vocabulary'));
          }
        }
      }
      
      return Right(localWords);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLanguageAnalytics(String userId, String courseId) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getLanguageAnalytics(userId, courseId);
          // Cache analytics locally
          await localDataSource.cacheLanguageAnalytics(userId, courseId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getLanguageAnalytics(userId, courseId);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getLanguageAnalytics(userId, courseId);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateAIStory(String courseId, String theme, String difficulty) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteStory = await remoteDataSource.generateAIStory(courseId, theme, difficulty);
          // Cache story locally
          await localDataSource.cacheAIStory(courseId, theme, difficulty, remoteStory);
          return Right(remoteStory);
        } catch (e) {
          // Fall back to local story generation if available
          try {
            final localStory = await localDataSource.generateAIStory(courseId, theme, difficulty);
            return Right(localStory);
          } on CacheException {
            return Left(ServerFailure('Failed to generate AI story and no local capability available'));
          }
        }
      } else {
        // Offline - check for cached story or basic generation
        try {
          final cachedStory = await localDataSource.getCachedAIStory(courseId, theme, difficulty);
          return Right(cachedStory);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no cached story available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> analyzePronunciation(String exerciseId, String audioData) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final pronunciationScore = await remoteDataSource.analyzePronunciation(exerciseId, audioData);
          
          // Cache pronunciation analysis locally
          await localDataSource.cachePronunciationAnalysis(exerciseId, audioData, pronunciationScore);
          
          return Right(pronunciationScore);
        } catch (e) {
          // Fall back to local pronunciation analysis if available
          try {
            final localScore = await localDataSource.analyzePronunciationLocally(exerciseId, audioData);
            return Right(localScore);
          } on CacheException {
            return Left(ServerFailure('Failed to analyze pronunciation and no local capability available'));
          }
        }
      } else {
        // Offline - use basic local analysis
        try {
          final localScore = await localDataSource.analyzePronunciationLocally(exerciseId, audioData);
          return Right(localScore);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no local pronunciation analysis available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncLanguageData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get language data that needs sync
      final unsyncedCourses = await localDataSource.getUnsyncedCourses(userId);
      final unsyncedLessons = await localDataSource.getUnsyncedLessons(userId);
      final unsyncedExercises = await localDataSource.getUnsyncedExercises(userId);
      final unsyncedWords = await localDataSource.getUnsyncedVocabularyWords(userId);

      // Sync courses
      for (final course in unsyncedCourses) {
        try {
          if (course.serverId == null) {
            // Create on server
            final remoteCourse = await remoteDataSource.createCourse(userId, course.toJson());
            await localDataSource.updateCourse(course.id, {
              'server_id': remoteCourse.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateCourse(course.serverId!, course.toJson());
            await localDataSource.updateCourse(course.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync lessons
      for (final lesson in unsyncedLessons) {
        try {
          if (lesson.serverId == null) {
            final remoteLesson = await remoteDataSource.startLesson(lesson.courseId, lesson.toJson());
            if (lesson.isCompleted) {
              await remoteDataSource.completeLesson(remoteLesson.id, lesson.toJson());
            }
            await localDataSource.updateLesson(lesson.id, {
              'server_id': remoteLesson.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync exercises
      for (final exercise in unsyncedExercises) {
        try {
          if (exercise.isCompleted) {
            await remoteDataSource.completeExercise(exercise.id, exercise.toJson());
            await localDataSource.updateExercise(exercise.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync vocabulary words
      for (final word in unsyncedWords) {
        try {
          if (word.serverId == null) {
            final remoteWord = await remoteDataSource.addVocabularyWord(word.courseId, word.toJson());
            await localDataSource.updateVocabularyWord(word.id, {
              'server_id': remoteWord.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteCourses = await remoteDataSource.getUserCourses(userId);
      await localDataSource.cacheCourses(remoteCourses);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync language data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }
}
