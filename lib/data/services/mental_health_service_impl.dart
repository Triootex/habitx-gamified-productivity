import 'package:injectable/injectable.dart';
import '../../domain/entities/mental_health_entity.dart';
import '../../core/utils/mental_health_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class MentalHealthService {
  Future<MentalHealthEntryEntity> createEntry(String userId, Map<String, dynamic> entryData);
  Future<List<MentalHealthEntryEntity>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate});
  Future<CBTThoughtRecordEntity> createThoughtRecord(String userId, Map<String, dynamic> thoughtData);
  Future<Map<String, dynamic>> getMentalHealthAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<String>> generateCopingStrategies(String userId, String mood, List<String> triggers);
  Future<MentalHealthAssessmentEntity> conductAssessment(String userId, String assessmentType, Map<String, dynamic> responses);
  Future<Map<String, dynamic>> analyzeMoodPatterns(String userId);
  Future<List<String>> getPersonalizedInsights(String userId);
}

@LazySingleton(as: MentalHealthService)
class MentalHealthServiceImpl implements MentalHealthService {
  @override
  Future<MentalHealthEntryEntity> createEntry(String userId, Map<String, dynamic> entryData) async {
    try {
      final now = DateTime.now();
      final entryId = 'mental_health_${now.millisecondsSinceEpoch}';
      
      final entry = MentalHealthEntryEntity(
        id: entryId,
        userId: userId,
        timestamp: entryData['timestamp'] != null 
            ? DateTime.parse(entryData['timestamp'] as String)
            : now,
        moodRating: entryData['mood_rating'] as int? ?? 5,
        energyLevel: entryData['energy_level'] as int? ?? 5,
        stressLevel: entryData['stress_level'] as int? ?? 5,
        anxietyLevel: entryData['anxiety_level'] as int? ?? 5,
        depressionLevel: entryData['depression_level'] as int? ?? 5,
        sleepQuality: entryData['sleep_quality'] as int? ?? 5,
        socialConnection: entryData['social_connection'] as int? ?? 5,
        emotions: (entryData['emotions'] as List<dynamic>?)?.cast<String>() ?? [],
        emotionIntensities: Map<String, int>.from(entryData['emotion_intensities'] ?? {}),
        triggers: (entryData['triggers'] as List<dynamic>?)?.cast<String>() ?? [],
        copingStrategiesUsed: (entryData['coping_strategies'] as List<dynamic>?)?.cast<String>() ?? [],
        activities: (entryData['activities'] as List<dynamic>?)?.cast<String>() ?? [],
        medications: (entryData['medications'] as List<dynamic>?)?.cast<String>() ?? [],
        therapySession: entryData['therapy_session'] as bool? ?? false,
        exerciseMinutes: entryData['exercise_minutes'] as int? ?? 0,
        meditationMinutes: entryData['meditation_minutes'] as int? ?? 0,
        socialInteractions: entryData['social_interactions'] as int? ?? 0,
        gratitudePractice: entryData['gratitude_practice'] as bool? ?? false,
        journaling: entryData['journaling'] as bool? ?? false,
        notes: entryData['notes'] as String?,
        location: entryData['location'] as String?,
        weather: entryData['weather'] as String?,
        createdAt: now,
      );
      
      return entry;
    } catch (e) {
      throw Exception('Failed to create mental health entry: ${e.toString()}');
    }
  }

  @override
  Future<List<MentalHealthEntryEntity>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final mockEntries = _generateMockEntries(userId);
      
      if (startDate != null || endDate != null) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = endDate ?? DateTime.now();
        
        return mockEntries.where((entry) {
          return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
        }).toList();
      }
      
      return mockEntries;
    } catch (e) {
      throw Exception('Failed to retrieve mental health entries: ${e.toString()}');
    }
  }

  @override
  Future<CBTThoughtRecordEntity> createThoughtRecord(String userId, Map<String, dynamic> thoughtData) async {
    try {
      final now = DateTime.now();
      final recordId = 'cbt_${now.millisecondsSinceEpoch}';
      
      final record = CBTThoughtRecordEntity(
        id: recordId,
        userId: userId,
        timestamp: now,
        situation: thoughtData['situation'] as String,
        emotions: (thoughtData['emotions'] as List<dynamic>?)?.cast<String>() ?? [],
        emotionIntensities: Map<String, int>.from(thoughtData['emotion_intensities'] ?? {}),
        automaticThoughts: (thoughtData['automatic_thoughts'] as List<dynamic>?)?.cast<String>() ?? [],
        thoughtBelievability: thoughtData['thought_believability'] as int? ?? 5,
        cognitiveDistortions: (thoughtData['cognitive_distortions'] as List<dynamic>?)?.cast<String>() ?? [],
        balancedThought: thoughtData['balanced_thought'] as String?,
        newEmotionIntensities: Map<String, int>.from(thoughtData['new_emotion_intensities'] ?? {}),
        actionPlan: thoughtData['action_plan'] as String?,
        createdAt: now,
      );
      
      return record;
    } catch (e) {
      throw Exception('Failed to create thought record: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMentalHealthAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final entries = await getUserEntries(userId, startDate: startDate, endDate: endDate);
      
      if (entries.isEmpty) {
        return {'total_entries': 0, 'average_mood': 0.0, 'wellness_score': 0.0};
      }
      
      final wellnessScore = MentalHealthUtils.calculateOverallWellnessScore(entries);
      final moodPatterns = MentalHealthUtils.analyzeMoodPatterns(entries);
      
      final averageMood = entries.fold<double>(0, (sum, e) => sum + e.moodRating) / entries.length;
      final averageStress = entries.fold<double>(0, (sum, e) => sum + e.stressLevel) / entries.length;
      final averageAnxiety = entries.fold<double>(0, (sum, e) => sum + e.anxietyLevel) / entries.length;
      
      return {
        'summary': {
          'total_entries': entries.length,
          'average_mood': averageMood,
          'average_stress': averageStress,
          'average_anxiety': averageAnxiety,
          'wellness_score': wellnessScore,
        },
        'patterns': moodPatterns,
        'insights': _generateInsights(entries),
      };
    } catch (e) {
      throw Exception('Failed to get mental health analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateCopingStrategies(String userId, String mood, List<String> triggers) async {
    try {
      return MentalHealthUtils.generateCopingStrategies(
        currentMood: mood,
        triggers: triggers,
        userPreferences: {}, // Mock preferences
        severity: 'moderate',
      );
    } catch (e) {
      throw Exception('Failed to generate coping strategies: ${e.toString()}');
    }
  }

  @override
  Future<MentalHealthAssessmentEntity> conductAssessment(String userId, String assessmentType, Map<String, dynamic> responses) async {
    try {
      final now = DateTime.now();
      final assessmentId = 'assessment_${now.millisecondsSinceEpoch}';
      
      // Calculate score based on assessment type
      final score = _calculateAssessmentScore(assessmentType, responses);
      final interpretation = _interpretAssessmentScore(assessmentType, score);
      
      final assessment = MentalHealthAssessmentEntity(
        id: assessmentId,
        userId: userId,
        assessmentType: assessmentType,
        questions: List<String>.from(responses.keys),
        responses: Map<String, dynamic>.from(responses),
        score: score,
        maxScore: _getMaxScore(assessmentType),
        interpretation: interpretation,
        riskLevel: _determineRiskLevel(assessmentType, score),
        recommendations: _generateRecommendations(assessmentType, score),
        createdAt: now,
      );
      
      return assessment;
    } catch (e) {
      throw Exception('Failed to conduct assessment: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeMoodPatterns(String userId) async {
    try {
      final entries = await getUserEntries(userId, startDate: DateTime.now().subtract(const Duration(days: 30)));
      return MentalHealthUtils.analyzeMoodPatterns(entries);
    } catch (e) {
      throw Exception('Failed to analyze mood patterns: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getPersonalizedInsights(String userId) async {
    try {
      final entries = await getUserEntries(userId, startDate: DateTime.now().subtract(const Duration(days: 14)));
      return _generateInsights(entries);
    } catch (e) {
      throw Exception('Failed to get personalized insights: ${e.toString()}');
    }
  }

  // Private helper methods
  List<MentalHealthEntryEntity> _generateMockEntries(String userId) {
    final now = DateTime.now();
    return [
      MentalHealthEntryEntity(
        id: 'entry_1',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 1)),
        moodRating: 7,
        energyLevel: 6,
        stressLevel: 4,
        anxietyLevel: 3,
        emotions: ['happy', 'calm'],
        emotionIntensities: {'happy': 7, 'calm': 6},
        copingStrategiesUsed: ['deep_breathing', 'exercise'],
        activities: ['work', 'social'],
        exerciseMinutes: 30,
        meditationMinutes: 10,
        socialInteractions: 3,
        gratitudePractice: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  int _calculateAssessmentScore(String assessmentType, Map<String, dynamic> responses) {
    // Simplified scoring - in real implementation, would use proper scoring algorithms
    return responses.values.fold<int>(0, (sum, value) => sum + (value as int? ?? 0));
  }

  String _interpretAssessmentScore(String assessmentType, int score) {
    switch (assessmentType) {
      case 'phq-9':
        if (score <= 4) return 'Minimal depression';
        if (score <= 9) return 'Mild depression';
        if (score <= 14) return 'Moderate depression';
        if (score <= 19) return 'Moderately severe depression';
        return 'Severe depression';
      case 'gad-7':
        if (score <= 4) return 'Minimal anxiety';
        if (score <= 9) return 'Mild anxiety';
        if (score <= 14) return 'Moderate anxiety';
        return 'Severe anxiety';
      default:
        return 'Normal range';
    }
  }

  int _getMaxScore(String assessmentType) {
    switch (assessmentType) {
      case 'phq-9': return 27;
      case 'gad-7': return 21;
      case 'pss-10': return 40;
      default: return 100;
    }
  }

  String _determineRiskLevel(String assessmentType, int score) {
    final maxScore = _getMaxScore(assessmentType);
    final ratio = score / maxScore;
    
    if (ratio <= 0.3) return 'low';
    if (ratio <= 0.6) return 'moderate';
    return 'high';
  }

  List<String> _generateRecommendations(String assessmentType, int score) {
    final recommendations = <String>[];
    
    if (score > 10) {
      recommendations.add('Consider speaking with a mental health professional');
      recommendations.add('Practice daily mindfulness or meditation');
      recommendations.add('Maintain regular sleep and exercise routines');
    } else {
      recommendations.add('Continue current self-care practices');
      recommendations.add('Monitor mood changes regularly');
    }
    
    return recommendations;
  }

  List<String> _generateInsights(List<MentalHealthEntryEntity> entries) {
    final insights = <String>[];
    
    if (entries.isEmpty) {
      insights.add('Start tracking your mental health to discover patterns and insights.');
      return insights;
    }
    
    final avgMood = entries.fold<double>(0, (sum, e) => sum + e.moodRating) / entries.length;
    
    if (avgMood >= 7) {
      insights.add('Your mood has been consistently positive. Keep up the good work!');
    } else if (avgMood >= 5) {
      insights.add('Your mood is fairly stable. Consider what activities boost your mood most.');
    } else {
      insights.add('Your mood has been lower lately. Consider reaching out for support.');
    }
    
    final exerciseEntries = entries.where((e) => e.exerciseMinutes > 0).length;
    final exerciseRate = exerciseEntries / entries.length;
    
    if (exerciseRate > 0.7) {
      insights.add('Great job staying active! Exercise is clearly part of your routine.');
    } else if (exerciseRate > 0.3) {
      insights.add('You exercise sometimes. Try to be more consistent for better mental health.');
    } else {
      insights.add('Consider adding regular exercise to boost your mood and energy.');
    }
    
    return insights;
  }
}
