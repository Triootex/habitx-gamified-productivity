import 'package:injectable/injectable.dart';
import '../../domain/entities/journal_entity.dart';
import '../../core/utils/journal_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class JournalService {
  Future<JournalEntryEntity> createEntry(String userId, Map<String, dynamic> entryData);
  Future<List<JournalEntryEntity>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate});
  Future<JournalEntryEntity> updateEntry(String entryId, Map<String, dynamic> updates);
  Future<bool> deleteEntry(String entryId);
  Future<List<JournalPromptEntity>> getPersonalizedPrompts(String userId);
  Future<Map<String, dynamic>> analyzeEntry(String entryId);
  Future<Map<String, dynamic>> getJournalAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<JournalReminderEntity> createReminder(String userId, Map<String, dynamic> reminderData);
  Future<String> exportEntries(String userId, String format, DateTime? startDate, DateTime? endDate);
  Future<Map<String, dynamic>> getMoodCorrelations(String userId);
}

@LazySingleton(as: JournalService)
class JournalServiceImpl implements JournalService {
  @override
  Future<JournalEntryEntity> createEntry(String userId, Map<String, dynamic> entryData) async {
    try {
      final now = DateTime.now();
      final entryId = 'entry_${now.millisecondsSinceEpoch}';
      
      // Analyze entry content
      final analysis = JournalUtils.analyzeJournalEntry(
        content: entryData['content'] as String,
        title: entryData['title'] as String,
        entryType: entryData['entry_type'] as String? ?? 'daily',
      );
      
      final entry = JournalEntryEntity(
        id: entryId,
        userId: userId,
        title: entryData['title'] as String,
        content: entryData['content'] as String,
        entryType: entryData['entry_type'] as String? ?? 'daily',
        format: entryData['format'] as String? ?? 'text',
        timestamp: entryData['timestamp'] != null 
            ? DateTime.parse(entryData['timestamp'] as String)
            : now,
        moodRating: entryData['mood_rating'] as int?,
        emotions: (entryData['emotions'] as List<dynamic>?)?.cast<String>() ?? [],
        emotionIntensities: Map<String, int>.from(entryData['emotion_intensities'] ?? {}),
        moodEmojis: (entryData['mood_emojis'] as List<dynamic>?)?.cast<String>() ?? [],
        aiAnalysis: analysis,
        sentimentScore: analysis['sentiment_score'] as double?,
        sentimentLabel: analysis['sentiment_label'] as String?,
        keyThemes: (analysis['key_themes'] as List<dynamic>?)?.cast<String>() ?? [],
        suggestions: (analysis['suggestions'] as List<dynamic>?)?.cast<String>() ?? [],
        tags: (entryData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        location: entryData['location'] as String?,
        weather: entryData['weather'] as String?,
        wordCount: (entryData['content'] as String).split(' ').length,
        writingTime: entryData['writing_time'] != null
            ? Duration(minutes: entryData['writing_time'] as int)
            : Duration.zero,
        voiceRecordingUrl: entryData['voice_recording_url'] as String?,
        attachments: (entryData['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
        privacy: entryData['privacy'] as String? ?? 'private',
        allowAnalytics: entryData['allow_analytics'] as bool? ?? true,
        includeInCorrelations: entryData['include_correlations'] as bool? ?? true,
        createdAt: now,
      );
      
      return entry;
    } catch (e) {
      throw Exception('Failed to create journal entry: ${e.toString()}');
    }
  }

  @override
  Future<List<JournalEntryEntity>> getUserEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
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
      throw Exception('Failed to retrieve user entries: ${e.toString()}');
    }
  }

  @override
  Future<JournalEntryEntity> updateEntry(String entryId, Map<String, dynamic> updates) async {
    try {
      final entry = await _getEntryById(entryId);
      if (entry == null) {
        throw Exception('Journal entry not found');
      }
      
      final now = DateTime.now();
      
      // Re-analyze if content changed
      Map<String, dynamic> newAnalysis = entry.aiAnalysis;
      if (updates.containsKey('content')) {
        newAnalysis = JournalUtils.analyzeJournalEntry(
          content: updates['content'] as String,
          title: updates['title'] as String? ?? entry.title,
          entryType: entry.entryType,
        );
      }
      
      final updatedEntry = entry.copyWith(
        title: updates['title'] as String? ?? entry.title,
        content: updates['content'] as String? ?? entry.content,
        moodRating: updates['mood_rating'] as int? ?? entry.moodRating,
        emotions: (updates['emotions'] as List<dynamic>?)?.cast<String>() ?? entry.emotions,
        tags: (updates['tags'] as List<dynamic>?)?.cast<String>() ?? entry.tags,
        aiAnalysis: newAnalysis,
        sentimentScore: newAnalysis['sentiment_score'] as double? ?? entry.sentimentScore,
        sentimentLabel: newAnalysis['sentiment_label'] as String? ?? entry.sentimentLabel,
        wordCount: updates.containsKey('content') 
            ? (updates['content'] as String).split(' ').length 
            : entry.wordCount,
        updatedAt: now,
      );
      
      return updatedEntry;
    } catch (e) {
      throw Exception('Failed to update journal entry: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteEntry(String entryId) async {
    try {
      final entry = await _getEntryById(entryId);
      if (entry == null) {
        throw Exception('Journal entry not found');
      }
      
      // In real implementation, would delete from database
      return true;
    } catch (e) {
      throw Exception('Failed to delete journal entry: ${e.toString()}');
    }
  }

  @override
  Future<List<JournalPromptEntity>> getPersonalizedPrompts(String userId) async {
    try {
      final userEntries = await getUserEntries(userId, startDate: DateTime.now().subtract(const Duration(days: 14)));
      
      return JournalUtils.generatePersonalizedPrompts(
        userId: userId,
        recentEntries: userEntries,
        currentMood: 'neutral', // Mock current mood
        timeOfDay: DateTime.now().hour,
        userPreferences: {}, // Mock preferences
      );
    } catch (e) {
      throw Exception('Failed to get personalized prompts: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeEntry(String entryId) async {
    try {
      final entry = await _getEntryById(entryId);
      if (entry == null) {
        throw Exception('Journal entry not found');
      }
      
      return JournalUtils.analyzeJournalEntry(
        content: entry.content,
        title: entry.title,
        entryType: entry.entryType,
      );
    } catch (e) {
      throw Exception('Failed to analyze journal entry: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getJournalAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final entries = await getUserEntries(userId, startDate: startDate, endDate: endDate);
      
      if (entries.isEmpty) {
        return {
          'total_entries': 0,
          'total_words': 0,
          'average_mood': 0.0,
          'writing_streak': 0,
        };
      }
      
      final analytics = JournalUtils.calculateWritingAnalytics(
        entries: entries,
        periodDays: endDate?.difference(startDate ?? DateTime.now().subtract(const Duration(days: 30))).inDays ?? 30,
      );
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_entries': entries.length,
          'total_words': entries.fold<int>(0, (sum, e) => sum + e.wordCount),
          'total_writing_time_minutes': entries.fold<Duration>(Duration.zero, (sum, e) => sum + e.writingTime).inMinutes,
          'average_entry_length': entries.isNotEmpty ? entries.fold<int>(0, (sum, e) => sum + e.wordCount) / entries.length : 0,
          'average_mood_rating': _calculateAverageMood(entries),
          'current_streak': analytics['current_streak'],
          'longest_streak': analytics['longest_streak'],
        },
        'patterns': {
          'mood_distribution': _getMoodDistribution(entries),
          'emotion_frequency': _getEmotionFrequency(entries),
          'entry_type_breakdown': _getEntryTypeBreakdown(entries),
          'writing_times': _getWritingTimeDistribution(entries),
        },
        'trends': {
          'mood_trends': _getMoodTrends(entries),
          'sentiment_trends': _getSentimentTrends(entries),
        },
        'insights': analytics['insights'],
      };
    } catch (e) {
      throw Exception('Failed to get journal analytics: ${e.toString()}');
    }
  }

  @override
  Future<JournalReminderEntity> createReminder(String userId, Map<String, dynamic> reminderData) async {
    try {
      final now = DateTime.now();
      final reminderId = 'reminder_${now.millisecondsSinceEpoch}';
      
      final reminder = JournalReminderEntity(
        id: reminderId,
        userId: userId,
        title: reminderData['title'] as String,
        message: reminderData['message'] as String?,
        scheduledTime: DateTime.parse(reminderData['scheduled_time'] as String),
        daysOfWeek: (reminderData['days_of_week'] as List<dynamic>?)?.cast<int>() ?? [],
        isRecurring: reminderData['is_recurring'] as bool? ?? false,
        frequency: reminderData['frequency'] as String? ?? 'daily',
        entryType: reminderData['entry_type'] as String? ?? 'daily',
        suggestedPrompts: (reminderData['suggested_prompts'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: now,
      );
      
      return reminder;
    } catch (e) {
      throw Exception('Failed to create journal reminder: ${e.toString()}');
    }
  }

  @override
  Future<String> exportEntries(String userId, String format, DateTime? startDate, DateTime? endDate) async {
    try {
      final entries = await getUserEntries(userId, startDate: startDate, endDate: endDate);
      
      return JournalUtils.exportEntries(
        entries: entries,
        format: format,
        includeAnalytics: true,
        includeMoodData: true,
      );
    } catch (e) {
      throw Exception('Failed to export entries: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMoodCorrelations(String userId) async {
    try {
      final entries = await getUserEntries(userId, startDate: DateTime.now().subtract(const Duration(days: 90)));
      
      return JournalUtils.findMoodCorrelations(
        entries: entries,
        factors: ['weather', 'sleep', 'exercise', 'social_interactions'],
      );
    } catch (e) {
      throw Exception('Failed to get mood correlations: ${e.toString()}');
    }
  }

  // Private helper methods
  List<JournalEntryEntity> _generateMockEntries(String userId) {
    final now = DateTime.now();
    
    return [
      JournalEntryEntity(
        id: 'entry_1',
        userId: userId,
        title: 'Great Day at Work',
        content: 'Had an amazing day at work today. Completed the project presentation and received positive feedback from the team. Feeling grateful and motivated for tomorrow.',
        entryType: 'daily',
        format: 'text',
        timestamp: now.subtract(const Duration(days: 1)),
        moodRating: 8,
        emotions: ['happy', 'grateful', 'motivated'],
        emotionIntensities: {'happy': 8, 'grateful': 9, 'motivated': 7},
        sentimentScore: 0.8,
        sentimentLabel: 'positive',
        keyThemes: ['work', 'achievement', 'gratitude'],
        suggestions: ['Continue this positive momentum', 'Celebrate small wins'],
        tags: ['work', 'success', 'gratitude'],
        wordCount: 32,
        writingTime: const Duration(minutes: 5),
        location: 'home',
        weather: 'sunny',
        privacy: 'private',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      JournalEntryEntity(
        id: 'entry_2',
        userId: userId,
        title: 'Reflecting on Goals',
        content: 'Spent some time today thinking about my goals for next month. Want to focus more on personal development and health. Need to create a better balance between work and personal life.',
        entryType: 'reflection',
        format: 'text',
        timestamp: now.subtract(const Duration(days: 3)),
        moodRating: 6,
        emotions: ['thoughtful', 'determined'],
        emotionIntensities: {'thoughtful': 7, 'determined': 6},
        sentimentScore: 0.3,
        sentimentLabel: 'neutral',
        keyThemes: ['goals', 'self-improvement', 'work-life balance'],
        suggestions: ['Set specific, measurable goals', 'Schedule regular self-reflection'],
        tags: ['goals', 'planning', 'self-improvement'],
        wordCount: 38,
        writingTime: const Duration(minutes: 7),
        privacy: 'private',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<JournalEntryEntity?> _getEntryById(String entryId) async {
    final entries = _generateMockEntries('user_id');
    try {
      return entries.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return null;
    }
  }

  double _calculateAverageMood(List<JournalEntryEntity> entries) {
    final entriesWithMood = entries.where((e) => e.moodRating != null).toList();
    if (entriesWithMood.isEmpty) return 0.0;
    
    return entriesWithMood.fold<double>(0, (sum, e) => sum + e.moodRating!) / entriesWithMood.length;
  }

  Map<String, int> _getMoodDistribution(List<JournalEntryEntity> entries) {
    final distribution = <String, int>{
      '1-2': 0, // Very low
      '3-4': 0, // Low
      '5-6': 0, // Neutral
      '7-8': 0, // Good
      '9-10': 0, // Excellent
    };
    
    for (final entry in entries.where((e) => e.moodRating != null)) {
      final mood = entry.moodRating!;
      if (mood <= 2) {
        distribution['1-2'] = distribution['1-2']! + 1;
      } else if (mood <= 4) {
        distribution['3-4'] = distribution['3-4']! + 1;
      } else if (mood <= 6) {
        distribution['5-6'] = distribution['5-6']! + 1;
      } else if (mood <= 8) {
        distribution['7-8'] = distribution['7-8']! + 1;
      } else {
        distribution['9-10'] = distribution['9-10']! + 1;
      }
    }
    
    return distribution;
  }

  Map<String, int> _getEmotionFrequency(List<JournalEntryEntity> entries) {
    final frequency = <String, int>{};
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        frequency[emotion] = (frequency[emotion] ?? 0) + 1;
      }
    }
    
    return frequency;
  }

  Map<String, int> _getEntryTypeBreakdown(List<JournalEntryEntity> entries) {
    final breakdown = <String, int>{};
    
    for (final entry in entries) {
      breakdown[entry.entryType] = (breakdown[entry.entryType] ?? 0) + 1;
    }
    
    return breakdown;
  }

  Map<int, int> _getWritingTimeDistribution(List<JournalEntryEntity> entries) {
    final distribution = <int, int>{};
    
    for (final entry in entries) {
      final hour = entry.timestamp.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }
    
    return distribution;
  }

  Map<String, double> _getMoodTrends(List<JournalEntryEntity> entries) {
    final trends = <String, double>{};
    
    for (final entry in entries.where((e) => e.moodRating != null)) {
      final dateKey = DateUtils.formatDate(entry.timestamp, 'yyyy-MM-dd');
      trends[dateKey] = entry.moodRating!.toDouble();
    }
    
    return trends;
  }

  Map<String, double> _getSentimentTrends(List<JournalEntryEntity> entries) {
    final trends = <String, double>{};
    
    for (final entry in entries.where((e) => e.sentimentScore != null)) {
      final dateKey = DateUtils.formatDate(entry.timestamp, 'yyyy-MM-dd');
      trends[dateKey] = entry.sentimentScore!;
    }
    
    return trends;
  }
}
