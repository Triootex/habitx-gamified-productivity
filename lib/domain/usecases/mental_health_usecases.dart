import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/mental_health_entity.dart';
import '../../data/repositories/mental_health_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Mental Health Entry Use Case
@injectable
class CreateMentalHealthEntryUseCase implements UseCase<MentalHealthEntryEntity, CreateMentalHealthEntryParams> {
  final MentalHealthRepository repository;

  CreateMentalHealthEntryUseCase(this.repository);

  @override
  Future<Either<Failure, MentalHealthEntryEntity>> call(CreateMentalHealthEntryParams params) async {
    return await repository.createEntry(params.userId, params.entryData);
  }
}

class CreateMentalHealthEntryParams {
  final String userId;
  final Map<String, dynamic> entryData;

  CreateMentalHealthEntryParams({required this.userId, required this.entryData});
}

// Get User Mental Health Entries Use Case
@injectable
class GetUserMentalHealthEntriesUseCase implements UseCase<List<MentalHealthEntryEntity>, GetUserMentalHealthEntriesParams> {
  final MentalHealthRepository repository;

  GetUserMentalHealthEntriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MentalHealthEntryEntity>>> call(GetUserMentalHealthEntriesParams params) async {
    return await repository.getUserEntries(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserMentalHealthEntriesParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserMentalHealthEntriesParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Create CBT Thought Record Use Case
@injectable
class CreateCBTThoughtRecordUseCase implements UseCase<CBTThoughtRecordEntity, CreateCBTThoughtRecordParams> {
  final MentalHealthRepository repository;

  CreateCBTThoughtRecordUseCase(this.repository);

  @override
  Future<Either<Failure, CBTThoughtRecordEntity>> call(CreateCBTThoughtRecordParams params) async {
    return await repository.createThoughtRecord(params.userId, params.thoughtData);
  }
}

class CreateCBTThoughtRecordParams {
  final String userId;
  final Map<String, dynamic> thoughtData;

  CreateCBTThoughtRecordParams({required this.userId, required this.thoughtData});
}

// Get CBT Thought Records Use Case
@injectable
class GetCBTThoughtRecordsUseCase implements UseCase<List<CBTThoughtRecordEntity>, GetCBTThoughtRecordsParams> {
  final MentalHealthRepository repository;

  GetCBTThoughtRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CBTThoughtRecordEntity>>> call(GetCBTThoughtRecordsParams params) async {
    return await repository.getThoughtRecords(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetCBTThoughtRecordsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetCBTThoughtRecordsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Conduct Mental Health Assessment Use Case
@injectable
class ConductMentalHealthAssessmentUseCase implements UseCase<MentalHealthAssessmentEntity, ConductMentalHealthAssessmentParams> {
  final MentalHealthRepository repository;

  ConductMentalHealthAssessmentUseCase(this.repository);

  @override
  Future<Either<Failure, MentalHealthAssessmentEntity>> call(ConductMentalHealthAssessmentParams params) async {
    return await repository.conductAssessment(params.userId, params.assessmentType, params.responses);
  }
}

class ConductMentalHealthAssessmentParams {
  final String userId;
  final String assessmentType;
  final Map<String, dynamic> responses;

  ConductMentalHealthAssessmentParams({
    required this.userId,
    required this.assessmentType,
    required this.responses,
  });
}

// Get User Mental Health Assessments Use Case
@injectable
class GetUserMentalHealthAssessmentsUseCase implements UseCase<List<MentalHealthAssessmentEntity>, String> {
  final MentalHealthRepository repository;

  GetUserMentalHealthAssessmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MentalHealthAssessmentEntity>>> call(String userId) async {
    return await repository.getUserAssessments(userId);
  }
}

// Get Mental Health Analytics Use Case
@injectable
class GetMentalHealthAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetMentalHealthAnalyticsParams> {
  final MentalHealthRepository repository;

  GetMentalHealthAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMentalHealthAnalyticsParams params) async {
    return await repository.getMentalHealthAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetMentalHealthAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetMentalHealthAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Generate Coping Strategies Use Case
@injectable
class GenerateCopingStrategiesUseCase implements UseCase<List<String>, GenerateCopingStrategiesParams> {
  final MentalHealthRepository repository;

  GenerateCopingStrategiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GenerateCopingStrategiesParams params) async {
    return await repository.generateCopingStrategies(params.userId, params.mood, params.triggers);
  }
}

class GenerateCopingStrategiesParams {
  final String userId;
  final String mood;
  final List<String> triggers;

  GenerateCopingStrategiesParams({
    required this.userId,
    required this.mood,
    required this.triggers,
  });
}

// Analyze Mood Patterns Use Case
@injectable
class AnalyzeMoodPatternsUseCase implements UseCase<Map<String, dynamic>, String> {
  final MentalHealthRepository repository;

  AnalyzeMoodPatternsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.analyzeMoodPatterns(userId);
  }
}

// Get Personalized Mental Health Insights Use Case
@injectable
class GetPersonalizedMentalHealthInsightsUseCase implements UseCase<List<String>, String> {
  final MentalHealthRepository repository;

  GetPersonalizedMentalHealthInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String userId) async {
    return await repository.getPersonalizedInsights(userId);
  }
}

// Sync Mental Health Data Use Case
@injectable
class SyncMentalHealthDataUseCase implements UseCase<bool, String> {
  final MentalHealthRepository repository;

  SyncMentalHealthDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncMentalHealthData(userId);
  }
}

// Calculate Mental Wellness Score Use Case
@injectable
class CalculateMentalWellnessScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final MentalHealthRepository repository;

  CalculateMentalWellnessScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final entriesResult = await repository.getUserEntries(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      return entriesResult.fold(
        (failure) => Left(failure),
        (entries) {
          final wellnessData = _calculateWellnessScore(entries);
          return Right(wellnessData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate wellness score: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateWellnessScore(List<MentalHealthEntryEntity> entries) {
    if (entries.isEmpty) {
      return {
        'wellness_score': 50, // Neutral baseline
        'mood_average': 5.0,
        'stress_average': 5.0,
        'energy_average': 5.0,
        'sleep_quality_average': 5.0,
        'trend': 'neutral',
        'recommendation': 'Start tracking your mood to get personalized insights',
        'consistency_score': 0,
      };
    }
    
    // Calculate averages
    final moodAvg = entries.fold<double>(0, (sum, entry) => sum + entry.moodRating) / entries.length;
    final stressAvg = entries.fold<double>(0, (sum, entry) => sum + (entry.stressLevel ?? 5)) / entries.length;
    final energyAvg = entries.fold<double>(0, (sum, entry) => sum + (entry.energyLevel ?? 5)) / entries.length;
    final sleepAvg = entries.fold<double>(0, (sum, entry) => sum + (entry.sleepQuality ?? 5)) / entries.length;
    
    // Calculate wellness score (0-100)
    final wellnessScore = (
      (moodAvg / 10 * 30) + // 30% weight on mood
      ((10 - stressAvg) / 10 * 25) + // 25% weight on low stress (inverted)
      (energyAvg / 10 * 25) + // 25% weight on energy
      (sleepAvg / 10 * 20) // 20% weight on sleep
    ) * 100;
    
    // Determine trend
    final trend = _calculateTrend(entries);
    
    // Calculate consistency score
    final consistencyScore = _calculateConsistencyScore(entries);
    
    // Generate recommendation
    final recommendation = _generateRecommendation(moodAvg, stressAvg, energyAvg, sleepAvg);
    
    return {
      'wellness_score': wellnessScore.round().clamp(0, 100),
      'mood_average': double.parse(moodAvg.toStringAsFixed(1)),
      'stress_average': double.parse(stressAvg.toStringAsFixed(1)),
      'energy_average': double.parse(energyAvg.toStringAsFixed(1)),
      'sleep_quality_average': double.parse(sleepAvg.toStringAsFixed(1)),
      'trend': trend,
      'recommendation': recommendation,
      'consistency_score': consistencyScore,
      'entries_count': entries.length,
      'tracking_days': entries.length,
    };
  }

  String _calculateTrend(List<MentalHealthEntryEntity> entries) {
    if (entries.length < 3) return 'insufficient_data';
    
    // Sort by date and compare first half with second half
    entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final midPoint = entries.length ~/ 2;
    final firstHalf = entries.sublist(0, midPoint);
    final secondHalf = entries.sublist(midPoint);
    
    final firstHalfAvg = firstHalf.fold<double>(0, (sum, entry) => sum + entry.moodRating) / firstHalf.length;
    final secondHalfAvg = secondHalf.fold<double>(0, (sum, entry) => sum + entry.moodRating) / secondHalf.length;
    
    final difference = secondHalfAvg - firstHalfAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  int _calculateConsistencyScore(List<MentalHealthEntryEntity> entries) {
    if (entries.isEmpty) return 0;
    
    // Calculate how many days in the last 30 have entries
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentEntries = entries.where((entry) => 
        entry.recordedAt.isAfter(thirtyDaysAgo)).length;
    
    return ((recentEntries / 30) * 100).round().clamp(0, 100);
  }

  String _generateRecommendation(double mood, double stress, double energy, double sleep) {
    if (mood < 4) {
      return 'Consider practicing mood-boosting activities like exercise, social connection, or mindfulness';
    } else if (stress > 7) {
      return 'Try stress-reduction techniques like deep breathing, meditation, or time management';
    } else if (energy < 4) {
      return 'Focus on improving sleep, nutrition, and gentle physical activity to boost energy';
    } else if (sleep < 4) {
      return 'Prioritize sleep hygiene: consistent bedtime, limiting screens, and creating a relaxing routine';
    } else if (mood >= 7 && stress <= 4 && energy >= 7) {
      return 'Great job maintaining your mental wellness! Keep up these healthy habits';
    } else {
      return 'Continue tracking your mood and consider small daily improvements in self-care';
    }
  }
}

// Get Mental Health Insights Use Case
@injectable
class GetMentalHealthInsightsUseCase implements UseCase<Map<String, dynamic>, String> {
  final MentalHealthRepository repository;

  GetMentalHealthInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final entriesResult = await repository.getUserEntries(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      );
      
      final thoughtRecordsResult = await repository.getThoughtRecords(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      );
      
      return entriesResult.fold(
        (failure) => Left(failure),
        (entries) async {
          final thoughtRecords = await thoughtRecordsResult.fold(
            (failure) => <CBTThoughtRecordEntity>[],
            (records) => records,
          );
          
          final insights = _generateInsights(entries, thoughtRecords);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateInsights(
    List<MentalHealthEntryEntity> entries,
    List<CBTThoughtRecordEntity> thoughtRecords,
  ) {
    final insights = <String>[];
    final patterns = <String, dynamic>{};
    
    if (entries.isEmpty && thoughtRecords.isEmpty) {
      return {
        'insights': ['Start tracking your mood to discover patterns and insights'],
        'patterns': {},
        'suggestions': [
          'Log your mood daily for better self-awareness',
          'Try CBT thought records when feeling overwhelmed',
          'Practice mindfulness for 10 minutes daily'
        ],
      };
    }
    
    // Analyze mood patterns
    if (entries.isNotEmpty) {
      // Day of week patterns
      final dayMoods = <int, List<double>>{};
      for (final entry in entries) {
        final day = entry.recordedAt.weekday;
        dayMoods[day] ??= [];
        dayMoods[day]!.add(entry.moodRating.toDouble());
      }
      
      var bestDay = '';
      var worstDay = '';
      var bestMood = 0.0;
      var worstMood = 10.0;
      
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      dayMoods.forEach((day, moods) {
        final avg = moods.reduce((a, b) => a + b) / moods.length;
        if (avg > bestMood) {
          bestMood = avg;
          bestDay = dayNames[day - 1];
        }
        if (avg < worstMood) {
          worstMood = avg;
          worstDay = dayNames[day - 1];
        }
      });
      
      if (bestDay.isNotEmpty && worstDay.isNotEmpty && bestDay != worstDay) {
        insights.add('Your mood tends to be highest on $bestDay and lowest on $worstDay');
        patterns['best_day'] = bestDay;
        patterns['worst_day'] = worstDay;
      }
      
      // Time patterns
      final morningMoods = entries.where((e) => e.recordedAt.hour < 12).toList();
      final eveningMoods = entries.where((e) => e.recordedAt.hour >= 18).toList();
      
      if (morningMoods.isNotEmpty && eveningMoods.isNotEmpty) {
        final morningAvg = morningMoods.fold<double>(0, (sum, e) => sum + e.moodRating) / morningMoods.length;
        final eveningAvg = eveningMoods.fold<double>(0, (sum, e) => sum + e.moodRating) / eveningMoods.length;
        
        if ((morningAvg - eveningAvg).abs() > 1) {
          if (morningAvg > eveningAvg) {
            insights.add('You tend to feel better in the morning than evening');
          } else {
            insights.add('Your mood improves throughout the day');
          }
        }
      }
      
      // Stress correlation
      final stressEntries = entries.where((e) => e.stressLevel != null).toList();
      if (stressEntries.isNotEmpty) {
        final highStressDays = stressEntries.where((e) => e.stressLevel! > 7).length;
        final lowMoodDays = stressEntries.where((e) => e.moodRating < 4).length;
        
        if (highStressDays > 0 && lowMoodDays > 0) {
          final correlation = (highStressDays.toDouble() / lowMoodDays.toDouble()).clamp(0, 1);
          if (correlation > 0.7) {
            insights.add('High stress levels strongly correlate with lower mood - stress management could help');
          }
        }
      }
    }
    
    // Analyze thought patterns
    if (thoughtRecords.isNotEmpty) {
      final distortions = <String, int>{};
      for (final record in thoughtRecords) {
        for (final distortion in record.cognitiveDistortions) {
          distortions[distortion] = (distortions[distortion] ?? 0) + 1;
        }
      }
      
      if (distortions.isNotEmpty) {
        final topDistortion = distortions.entries.reduce((a, b) => a.value > b.value ? a : b);
        insights.add('Your most common thinking pattern is ${topDistortion.key} - awareness is the first step to change');
        patterns['top_cognitive_distortion'] = topDistortion.key;
      }
    }
    
    final suggestions = _generateSuggestions(entries, thoughtRecords, patterns);
    
    return {
      'insights': insights,
      'patterns': patterns,
      'suggestions': suggestions,
      'data_points': entries.length + thoughtRecords.length,
    };
  }

  List<String> _generateSuggestions(
    List<MentalHealthEntryEntity> entries,
    List<CBTThoughtRecordEntity> thoughtRecords,
    Map<String, dynamic> patterns,
  ) {
    final suggestions = <String>[];
    
    if (patterns.containsKey('worst_day')) {
      suggestions.add('Plan something enjoyable for ${patterns['worst_day']}s to improve your mood');
    }
    
    if (thoughtRecords.isNotEmpty) {
      suggestions.add('Continue using thought records - they help identify and change negative thinking patterns');
    } else {
      suggestions.add('Try CBT thought records when you notice negative thoughts');
    }
    
    if (entries.isNotEmpty) {
      final recentEntries = entries.where((e) => 
          e.recordedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).toList();
      
      if (recentEntries.length < 5) {
        suggestions.add('Try to track your mood daily for more accurate insights');
      }
      
      final avgMood = entries.fold<double>(0, (sum, e) => sum + e.moodRating) / entries.length;
      if (avgMood < 5) {
        suggestions.add('Consider professional support if low mood persists');
      }
    }
    
    suggestions.addAll([
      'Practice gratitude by writing down 3 things you\'re grateful for each day',
      'Try the 5-4-3-2-1 grounding technique when feeling overwhelmed',
      'Schedule regular self-care activities that bring you joy',
    ]);
    
    return suggestions.take(5).toList();
  }
}
