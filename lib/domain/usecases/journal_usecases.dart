import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/journal_entity.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Create Journal Entry Use Case
@injectable
class CreateJournalEntryUseCase implements UseCase<JournalEntryEntity, CreateJournalEntryParams> {
  final JournalRepository repository;

  CreateJournalEntryUseCase(this.repository);

  @override
  Future<Either<Failure, JournalEntryEntity>> call(CreateJournalEntryParams params) async {
    return await repository.createEntry(params.userId, params.entryData);
  }
}

class CreateJournalEntryParams {
  final String userId;
  final Map<String, dynamic> entryData;

  CreateJournalEntryParams({required this.userId, required this.entryData});
}

// Get User Journal Entries Use Case
@injectable
class GetUserJournalEntriesUseCase implements UseCase<List<JournalEntryEntity>, GetUserJournalEntriesParams> {
  final JournalRepository repository;

  GetUserJournalEntriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<JournalEntryEntity>>> call(GetUserJournalEntriesParams params) async {
    return await repository.getUserEntries(
      params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetUserJournalEntriesParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetUserJournalEntriesParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Update Journal Entry Use Case
@injectable
class UpdateJournalEntryUseCase implements UseCase<JournalEntryEntity, UpdateJournalEntryParams> {
  final JournalRepository repository;

  UpdateJournalEntryUseCase(this.repository);

  @override
  Future<Either<Failure, JournalEntryEntity>> call(UpdateJournalEntryParams params) async {
    return await repository.updateEntry(params.entryId, params.updates);
  }
}

class UpdateJournalEntryParams {
  final String entryId;
  final Map<String, dynamic> updates;

  UpdateJournalEntryParams({required this.entryId, required this.updates});
}

// Delete Journal Entry Use Case
@injectable
class DeleteJournalEntryUseCase implements UseCase<bool, String> {
  final JournalRepository repository;

  DeleteJournalEntryUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String entryId) async {
    return await repository.deleteEntry(entryId);
  }
}

// Get Personalized Journal Prompts Use Case
@injectable
class GetPersonalizedJournalPromptsUseCase implements UseCase<List<JournalPromptEntity>, String> {
  final JournalRepository repository;

  GetPersonalizedJournalPromptsUseCase(this.repository);

  @override
  Future<Either<Failure, List<JournalPromptEntity>>> call(String userId) async {
    return await repository.getPersonalizedPrompts(userId);
  }
}

// Analyze Journal Entry Use Case
@injectable
class AnalyzeJournalEntryUseCase implements UseCase<Map<String, dynamic>, String> {
  final JournalRepository repository;

  AnalyzeJournalEntryUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String entryId) async {
    return await repository.analyzeEntry(entryId);
  }
}

// Get Journal Analytics Use Case
@injectable
class GetJournalAnalyticsUseCase implements UseCase<Map<String, dynamic>, GetJournalAnalyticsParams> {
  final JournalRepository repository;

  GetJournalAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetJournalAnalyticsParams params) async {
    return await repository.getJournalAnalytics(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetJournalAnalyticsParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetJournalAnalyticsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Create Journal Reminder Use Case
@injectable
class CreateJournalReminderUseCase implements UseCase<JournalReminderEntity, CreateJournalReminderParams> {
  final JournalRepository repository;

  CreateJournalReminderUseCase(this.repository);

  @override
  Future<Either<Failure, JournalReminderEntity>> call(CreateJournalReminderParams params) async {
    return await repository.createReminder(params.userId, params.reminderData);
  }
}

class CreateJournalReminderParams {
  final String userId;
  final Map<String, dynamic> reminderData;

  CreateJournalReminderParams({required this.userId, required this.reminderData});
}

// Export Journal Entries Use Case
@injectable
class ExportJournalEntriesUseCase implements UseCase<String, ExportJournalEntriesParams> {
  final JournalRepository repository;

  ExportJournalEntriesUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportJournalEntriesParams params) async {
    return await repository.exportEntries(
      params.userId,
      params.format,
      params.startDate,
      params.endDate,
    );
  }
}

class ExportJournalEntriesParams {
  final String userId;
  final String format;
  final DateTime? startDate;
  final DateTime? endDate;

  ExportJournalEntriesParams({
    required this.userId,
    required this.format,
    this.startDate,
    this.endDate,
  });
}

// Get Mood Correlations Use Case
@injectable
class GetMoodCorrelationsUseCase implements UseCase<Map<String, dynamic>, String> {
  final JournalRepository repository;

  GetMoodCorrelationsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getMoodCorrelations(userId);
  }
}

// Sync Journal Data Use Case
@injectable
class SyncJournalDataUseCase implements UseCase<bool, String> {
  final JournalRepository repository;

  SyncJournalDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncJournalData(userId);
  }
}

// Calculate Journal Insights Use Case
@injectable
class CalculateJournalInsightsUseCase implements UseCase<Map<String, dynamic>, String> {
  final JournalRepository repository;

  CalculateJournalInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final entriesResult = await repository.getUserEntries(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      );
      
      return entriesResult.fold(
        (failure) => Left(failure),
        (entries) {
          final insights = _generateJournalInsights(entries);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate journal insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateJournalInsights(List<JournalEntryEntity> entries) {
    if (entries.isEmpty) {
      return {
        'writing_consistency': 0,
        'emotional_patterns': {},
        'theme_analysis': {},
        'growth_indicators': [],
        'suggestions': [
          'Start journaling regularly to track your thoughts and emotions',
          'Try writing for at least 10 minutes each session',
          'Use journal prompts when you\'re stuck'
        ],
      };
    }
    
    // Analyze writing consistency
    final consistency = _calculateWritingConsistency(entries);
    
    // Analyze emotional patterns
    final emotionalPatterns = _analyzeEmotionalPatterns(entries);
    
    // Analyze themes and topics
    final themeAnalysis = _analyzeThemes(entries);
    
    // Identify growth indicators
    final growthIndicators = _identifyGrowthIndicators(entries);
    
    // Generate personalized suggestions
    final suggestions = _generatePersonalizedSuggestions(entries, consistency, emotionalPatterns);
    
    return {
      'writing_consistency': consistency,
      'emotional_patterns': emotionalPatterns,
      'theme_analysis': themeAnalysis,
      'growth_indicators': growthIndicators,
      'suggestions': suggestions,
      'total_entries': entries.length,
      'writing_period_days': _calculateWritingPeriod(entries),
      'average_entry_length': _calculateAverageEntryLength(entries),
    };
  }

  int _calculateWritingConsistency(List<JournalEntryEntity> entries) {
    if (entries.length < 2) return entries.isEmpty ? 0 : 50;
    
    // Calculate days with entries vs total days in period
    final entryDates = entries.map((e) => _formatDateKey(e.createdAt)).toSet();
    final firstDate = entries.map((e) => e.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = entries.map((e) => e.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
    
    final totalDays = lastDate.difference(firstDate).inDays + 1;
    final daysWithEntries = entryDates.length;
    
    final consistencyPercent = (daysWithEntries / totalDays * 100).round();
    return consistencyPercent.clamp(0, 100);
  }

  Map<String, dynamic> _analyzeEmotionalPatterns(List<JournalEntryEntity> entries) {
    final moodFrequency = <String, int>{};
    final emotionFrequency = <String, int>{};
    final moodByDay = <int, List<int>>{};
    
    for (final entry in entries) {
      // Analyze mood ratings
      if (entry.moodRating != null) {
        final day = entry.createdAt.weekday;
        moodByDay[day] ??= [];
        moodByDay[day]!.add(entry.moodRating!);
      }
      
      // Analyze emotions
      for (final emotion in entry.emotions) {
        emotionFrequency[emotion] = (emotionFrequency[emotion] ?? 0) + 1;
      }
    }
    
    // Calculate average mood by day
    final avgMoodByDay = <int, double>{};
    moodByDay.forEach((day, moods) {
      avgMoodByDay[day] = moods.reduce((a, b) => a + b) / moods.length;
    });
    
    // Find emotional trends
    final topEmotions = emotionFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String? bestDay;
    String? worstDay;
    double bestMood = 0;
    double worstMood = 10;
    
    avgMoodByDay.forEach((day, avgMood) {
      if (avgMood > bestMood) {
        bestMood = avgMood;
        bestDay = dayNames[day - 1];
      }
      if (avgMood < worstMood) {
        worstMood = avgMood;
        worstDay = dayNames[day - 1];
      }
    });
    
    return {
      'top_emotions': topEmotions.take(5).map((e) => {
        'emotion': e.key,
        'frequency': e.value,
        'percentage': ((e.value / entries.length) * 100).round(),
      }).toList(),
      'mood_by_day': avgMoodByDay,
      'best_day': bestDay,
      'worst_day': worstDay,
      'overall_mood_trend': _calculateMoodTrend(entries),
    };
  }

  Map<String, dynamic> _analyzeThemes(List<JournalEntryEntity> entries) {
    final keywordFrequency = <String, int>{};
    final categoryFrequency = <String, int>{};
    
    // Common keywords that might indicate themes
    final meaningfulWords = {
      'work', 'family', 'friends', 'love', 'stress', 'anxiety', 'happy', 'sad',
      'grateful', 'worried', 'excited', 'tired', 'motivated', 'confused',
      'progress', 'challenge', 'goal', 'dream', 'fear', 'hope'
    };
    
    for (final entry in entries) {
      // Analyze entry type/category
      if (entry.entryType != null) {
        categoryFrequency[entry.entryType!] = (categoryFrequency[entry.entryType!] ?? 0) + 1;
      }
      
      // Simple keyword extraction (in a real app, you'd use NLP)
      final content = '${entry.title ?? ''} ${entry.content ?? ''}'.toLowerCase();
      for (final word in meaningfulWords) {
        if (content.contains(word)) {
          keywordFrequency[word] = (keywordFrequency[word] ?? 0) + 1;
        }
      }
    }
    
    final topKeywords = keywordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = categoryFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'top_keywords': topKeywords.take(10).map((e) => {
        'word': e.key,
        'frequency': e.value,
      }).toList(),
      'entry_categories': topCategories.map((e) => {
        'category': e.key,
        'count': e.value,
        'percentage': ((e.value / entries.length) * 100).round(),
      }).toList(),
    };
  }

  List<String> _identifyGrowthIndicators(List<JournalEntryEntity> entries) {
    final indicators = <String>[];
    
    if (entries.length >= 30) {
      indicators.add('Consistent journaling habit developed (30+ entries)');
    }
    
    // Analyze sentiment improvement over time
    final sentimentTrend = _calculateSentimentTrend(entries);
    if (sentimentTrend > 0.1) {
      indicators.add('Positive sentiment trend in recent entries');
    }
    
    // Check for self-reflection indicators
    final reflectionKeywords = ['learned', 'realized', 'understand', 'growth', 'progress'];
    var reflectionCount = 0;
    
    for (final entry in entries) {
      final content = '${entry.title ?? ''} ${entry.content ?? ''}'.toLowerCase();
      for (final keyword in reflectionKeywords) {
        if (content.contains(keyword)) {
          reflectionCount++;
          break;
        }
      }
    }
    
    if (reflectionCount > entries.length * 0.3) {
      indicators.add('High level of self-reflection and personal growth awareness');
    }
    
    return indicators;
  }

  List<String> _generatePersonalizedSuggestions(
    List<JournalEntryEntity> entries, 
    int consistency, 
    Map<String, dynamic> emotionalPatterns
  ) {
    final suggestions = <String>[];
    
    if (consistency < 50) {
      suggestions.add('Try to journal more regularly - consistency helps build insights');
    }
    
    if (entries.length < 10) {
      suggestions.add('Write more entries to get better personalized insights');
    }
    
    final topEmotions = emotionalPatterns['top_emotions'] as List<Map<String, dynamic>>? ?? [];
    if (topEmotions.isNotEmpty) {
      final topEmotion = topEmotions.first['emotion'] as String;
      if (['sad', 'anxious', 'stressed', 'worried'].contains(topEmotion)) {
        suggestions.add('Consider exploring coping strategies for managing $topEmotion feelings');
      }
    }
    
    if (emotionalPatterns['worst_day'] != null) {
      suggestions.add('Plan something positive for ${emotionalPatterns['worst_day']}s to improve your mood');
    }
    
    suggestions.addAll([
      'Try gratitude journaling - write 3 things you\'re grateful for',
      'Use voice recordings when you don\'t feel like typing',
      'Review old entries to see your growth and patterns',
    ]);
    
    return suggestions.take(5).toList();
  }

  String _calculateMoodTrend(List<JournalEntryEntity> entries) {
    final moodEntries = entries.where((e) => e.moodRating != null).toList();
    if (moodEntries.length < 3) return 'stable';
    
    moodEntries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final firstHalfEnd = moodEntries.length ~/ 2;
    final firstHalf = moodEntries.sublist(0, firstHalfEnd);
    final secondHalf = moodEntries.sublist(firstHalfEnd);
    
    if (firstHalf.isEmpty || secondHalf.isEmpty) return 'stable';
    
    final firstAvg = firstHalf.fold<double>(0, (sum, e) => sum + e.moodRating!) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, e) => sum + e.moodRating!) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  double _calculateSentimentTrend(List<JournalEntryEntity> entries) {
    // Simplified sentiment analysis based on sentiment scores
    final sentimentEntries = entries.where((e) => e.sentimentScore != null).toList();
    if (sentimentEntries.length < 3) return 0.0;
    
    sentimentEntries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final firstHalfEnd = sentimentEntries.length ~/ 2;
    final firstHalf = sentimentEntries.sublist(0, firstHalfEnd);
    final secondHalf = sentimentEntries.sublist(firstHalfEnd);
    
    if (firstHalf.isEmpty || secondHalf.isEmpty) return 0.0;
    
    final firstAvg = firstHalf.fold<double>(0, (sum, e) => sum + e.sentimentScore!) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, e) => sum + e.sentimentScore!) / secondHalf.length;
    
    return secondAvg - firstAvg;
  }

  int _calculateWritingPeriod(List<JournalEntryEntity> entries) {
    if (entries.isEmpty) return 0;
    
    final dates = entries.map((e) => e.createdAt).toList()..sort();
    return dates.last.difference(dates.first).inDays + 1;
  }

  int _calculateAverageEntryLength(List<JournalEntryEntity> entries) {
    if (entries.isEmpty) return 0;
    
    final totalWords = entries.fold<int>(0, (sum, entry) => sum + (entry.wordCount ?? 0));
    return (totalWords / entries.length).round();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
