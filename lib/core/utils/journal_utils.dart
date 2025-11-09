import '../constants/journal_constants.dart';
import 'date_utils.dart';
import 'string_utils.dart';
import 'math_utils.dart';

class JournalUtils {
  /// Calculate journal entry quality and insights
  static Map<String, dynamic> analyzeJournalEntry(
    String content,
    String entryType,
    Map<String, dynamic> moodData,
  ) {
    final analysis = <String, dynamic>{};
    
    // Basic metrics
    final wordCount = content.split(RegExp(r'\s+')).length;
    final sentenceCount = content.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final avgWordsPerSentence = sentenceCount > 0 ? wordCount / sentenceCount : 0;
    
    // Sentiment analysis (simplified)
    final sentiment = _analyzeSentiment(content);
    
    // Emotional keyword detection
    final emotions = _detectEmotions(content);
    
    // Calculate entry quality score
    final qualityScore = _calculateEntryQuality(wordCount, sentenceCount, sentiment, emotions);
    
    // Generate insights
    final insights = _generateInsights(content, entryType, sentiment, emotions, wordCount);
    
    analysis['word_count'] = wordCount;
    analysis['sentence_count'] = sentenceCount;
    analysis['avg_words_per_sentence'] = avgWordsPerSentence.toStringAsFixed(1);
    analysis['sentiment_score'] = sentiment['score'];
    analysis['sentiment_label'] = sentiment['label'];
    analysis['dominant_emotions'] = emotions.take(3).toList();
    analysis['quality_score'] = qualityScore;
    analysis['insights'] = insights;
    analysis['reading_time_minutes'] = (wordCount / 200).ceil(); // Assume 200 words per minute
    
    return analysis;
  }
  
  static Map<String, dynamic> _analyzeSentiment(String content) {
    // Simplified sentiment analysis using keyword matching
    final positiveWords = [
      'happy', 'joy', 'excited', 'grateful', 'love', 'amazing', 'wonderful',
      'great', 'excellent', 'fantastic', 'good', 'smile', 'laugh', 'hope',
      'success', 'accomplished', 'proud', 'blessed', 'thankful'
    ];
    
    final negativeWords = [
      'sad', 'angry', 'frustrated', 'disappointed', 'worry', 'stress', 'fear',
      'hate', 'terrible', 'awful', 'bad', 'worst', 'difficult', 'problem',
      'fail', 'upset', 'crying', 'lonely', 'tired', 'exhausted'
    ];
    
    final words = content.toLowerCase().split(RegExp(r'\W+'));
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in words) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
    }
    
    final totalSentimentWords = positiveCount + negativeCount;
    double sentimentScore = 0.0; // Neutral
    String sentimentLabel = 'neutral';
    
    if (totalSentimentWords > 0) {
      sentimentScore = (positiveCount - negativeCount) / totalSentimentWords;
      
      if (sentimentScore > 0.3) {
        sentimentLabel = 'positive';
      } else if (sentimentScore < -0.3) {
        sentimentLabel = 'negative';
      }
    }
    
    return {
      'score': sentimentScore,
      'label': sentimentLabel,
      'positive_words': positiveCount,
      'negative_words': negativeCount,
    };
  }
  
  static List<Map<String, dynamic>> _detectEmotions(String content) {
    final emotionKeywords = {
      'joy': ['happy', 'joy', 'excited', 'thrilled', 'elated', 'cheerful'],
      'gratitude': ['grateful', 'thankful', 'blessed', 'appreciate', 'fortunate'],
      'love': ['love', 'adore', 'cherish', 'affection', 'care', 'devoted'],
      'sadness': ['sad', 'sorrow', 'grief', 'melancholy', 'glum', 'down'],
      'anger': ['angry', 'mad', 'furious', 'rage', 'irritated', 'annoyed'],
      'fear': ['scared', 'afraid', 'worried', 'anxious', 'nervous', 'terrified'],
      'surprise': ['surprised', 'amazed', 'shocked', 'astonished', 'stunned'],
      'disgust': ['disgusted', 'revolted', 'sickened', 'repulsed'],
      'anticipation': ['excited', 'eager', 'hopeful', 'optimistic', 'looking forward'],
      'trust': ['trust', 'confident', 'secure', 'safe', 'reliable'],
    };
    
    final emotionCounts = <String, int>{};
    final words = content.toLowerCase().split(RegExp(r'\W+'));
    
    for (final word in words) {
      for (final entry in emotionKeywords.entries) {
        if (entry.value.contains(word)) {
          emotionCounts[entry.key] = (emotionCounts[entry.key] ?? 0) + 1;
        }
      }
    }
    
    // Sort by count and return top emotions
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEmotions.map((entry) => {
      'emotion': entry.key,
      'intensity': entry.value,
      'color': _getEmotionColor(entry.key),
    }).toList();
  }
  
  static String _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'joy': return '#F1C40F';
      case 'gratitude': return '#27AE60';
      case 'love': return '#E91E63';
      case 'sadness': return '#3498DB';
      case 'anger': return '#E74C3C';
      case 'fear': return '#9B59B6';
      case 'surprise': return '#FF9800';
      case 'disgust': return '#795548';
      case 'anticipation': return '#00BCD4';
      case 'trust': return '#4CAF50';
      default: return '#95A5A6';
    }
  }
  
  static double _calculateEntryQuality(
    int wordCount,
    int sentenceCount,
    Map<String, dynamic> sentiment,
    List<Map<String, dynamic>> emotions,
  ) {
    double score = 0.0;
    
    // Length quality (0-30 points)
    if (wordCount >= 50 && wordCount <= 500) {
      score += 30; // Optimal length
    } else if (wordCount >= 25 || wordCount <= 750) {
      score += 20; // Good length
    } else if (wordCount >= 10) {
      score += 10; // Acceptable length
    }
    
    // Sentence structure (0-20 points)
    if (sentenceCount > 0) {
      final avgWordsPerSentence = wordCount / sentenceCount;
      if (avgWordsPerSentence >= 8 && avgWordsPerSentence <= 20) {
        score += 20; // Good sentence length
      } else {
        score += 10;
      }
    }
    
    // Emotional expression (0-25 points)
    if (emotions.isNotEmpty) {
      score += math.min(emotions.length * 5, 25); // More emotions = richer content
    }
    
    // Reflection depth (0-25 points)
    final reflectionWords = ['because', 'realize', 'understand', 'learn', 'think', 'feel', 'believe'];
    final content = sentiment['score'].toString(); // This would be the actual content in real implementation
    int reflectionCount = 0;
    for (final word in reflectionWords) {
      if (content.toLowerCase().contains(word)) reflectionCount++;
    }
    score += math.min(reflectionCount * 5, 25);
    
    return (score / 100.0 * 10).clamp(0.0, 10.0); // Convert to 0-10 scale
  }
  
  static List<String> _generateInsights(
    String content,
    String entryType,
    Map<String, dynamic> sentiment,
    List<Map<String, dynamic>> emotions,
    int wordCount,
  ) {
    final insights = <String>[];
    
    // Sentiment insights
    final sentimentLabel = sentiment['label'] as String;
    switch (sentimentLabel) {
      case 'positive':
        insights.add('Your entry reflects a positive mindset - great to see!');
        break;
      case 'negative':
        insights.add('You seem to be processing some challenging emotions. That\'s healthy.');
        break;
      case 'neutral':
        insights.add('Your entry shows balanced emotional processing.');
        break;
    }
    
    // Emotion insights
    if (emotions.isNotEmpty) {
      final dominantEmotion = emotions.first['emotion'] as String;
      insights.add('Your strongest emotion today appears to be $dominantEmotion');
      
      if (emotions.length >= 3) {
        insights.add('You\'re experiencing a rich range of emotions - this shows emotional awareness');
      }
    }
    
    // Length insights
    if (wordCount > 300) {
      insights.add('You had a lot to express today - detailed reflection is valuable');
    } else if (wordCount < 50) {
      insights.add('Consider expanding your thoughts for deeper self-reflection');
    }
    
    // Entry type specific insights
    switch (entryType) {
      case JournalConstants.gratitudeJournal:
        if (content.toLowerCase().contains('grateful') || content.toLowerCase().contains('thankful')) {
          insights.add('Practicing gratitude can improve mental well-being and life satisfaction');
        }
        break;
      case JournalConstants.dreamJournal:
        insights.add('Dream journaling can help with dream recall and pattern recognition');
        break;
      case JournalConstants.reflectionJournal:
        if (content.toLowerCase().contains('learn') || content.toLowerCase().contains('realize')) {
          insights.add('You\'re actively learning from your experiences - excellent self-awareness');
        }
        break;
    }
    
    return insights.take(4).toList(); // Limit to 4 insights
  }
  
  /// Generate personalized journal prompts
  static List<Map<String, dynamic>> generatePersonalizedPrompts(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> recentEntries,
    String currentMood,
  ) {
    final prompts = <Map<String, dynamic>>[];
    
    final journalFrequency = userProfile['journal_frequency'] as String? ?? 'daily';
    final preferredTypes = userProfile['preferred_journal_types'] as List<String>? ?? [];
    final interests = userProfile['interests'] as List<String>? ?? [];
    
    // Analyze recent entries for patterns
    final recentThemes = _analyzeRecentThemes(recentEntries);
    
    // Mood-based prompts
    prompts.addAll(_getMoodBasedPrompts(currentMood));
    
    // Follow-up prompts based on recent themes
    if (recentThemes.contains('stress')) {
      prompts.add({
        'text': 'What strategies helped you manage stress this week?',
        'category': 'reflection',
        'type': JournalConstants.reflectionJournal,
        'estimated_time': 10,
      });
    }
    
    if (recentThemes.contains('relationships')) {
      prompts.add({
        'text': 'How have your relationships contributed to your growth recently?',
        'category': 'relationships',
        'type': JournalConstants.reflectionJournal,
        'estimated_time': 15,
      });
    }
    
    // Interest-based prompts
    for (final interest in interests.take(2)) {
      prompts.add({
        'text': 'How did $interest bring you joy today?',
        'category': 'interests',
        'type': JournalConstants.gratitudeJournal,
        'estimated_time': 8,
      });
    }
    
    // Seasonal/time-based prompts
    prompts.addAll(_getSeasonalPrompts());
    
    // CBT-based prompts for mental health
    if (preferredTypes.contains(JournalConstants.reflectionJournal)) {
      prompts.addAll(_getCBTPrompts());
    }
    
    return prompts.take(8).toList(); // Return top 8 prompts
  }
  
  static List<String> _analyzeRecentThemes(List<Map<String, dynamic>> entries) {
    final themes = <String>[];
    final themeKeywords = {
      'stress': ['stress', 'overwhelmed', 'pressure', 'busy', 'deadline'],
      'relationships': ['friend', 'family', 'partner', 'colleague', 'social'],
      'work': ['job', 'work', 'career', 'boss', 'project', 'meeting'],
      'health': ['exercise', 'fitness', 'doctor', 'sick', 'energy'],
      'creativity': ['create', 'art', 'write', 'music', 'design', 'imagine'],
    };
    
    for (final entry in entries.take(10)) { // Analyze last 10 entries
      final content = entry['content'] as String? ?? '';
      final words = content.toLowerCase().split(RegExp(r'\W+'));
      
      for (final themeEntry in themeKeywords.entries) {
        if (themeEntry.value.any((keyword) => words.contains(keyword))) {
          if (!themes.contains(themeEntry.key)) {
            themes.add(themeEntry.key);
          }
        }
      }
    }
    
    return themes;
  }
  
  static List<Map<String, dynamic>> _getMoodBasedPrompts(String mood) {
    final moodPrompts = {
      'happy': [
        {
          'text': 'What made you smile today?',
          'category': 'gratitude',
          'type': JournalConstants.gratitudeJournal,
        },
        {
          'text': 'How can you share this positive energy with others?',
          'category': 'reflection',
          'type': JournalConstants.reflectionJournal,
        },
      ],
      'sad': [
        {
          'text': 'What would you tell a friend feeling the same way?',
          'category': 'self-compassion',
          'type': JournalConstants.reflectionJournal,
        },
        {
          'text': 'What small thing could bring you comfort right now?',
          'category': 'self-care',
          'type': JournalConstants.dailyJournal,
        },
      ],
      'stressed': [
        {
          'text': 'What are three things you can control in this situation?',
          'category': 'problem-solving',
          'type': JournalConstants.reflectionJournal,
        },
        {
          'text': 'Describe your ideal peaceful moment.',
          'category': 'visualization',
          'type': JournalConstants.dailyJournal,
        },
      ],
      'excited': [
        {
          'text': 'What are you most looking forward to?',
          'category': 'anticipation',
          'type': JournalConstants.goalsJournal,
        },
        {
          'text': 'How can you make the most of this energy?',
          'category': 'action-planning',
          'type': JournalConstants.reflectionJournal,
        },
      ],
    };
    
    return moodPrompts[mood] ?? moodPrompts['happy']!;
  }
  
  static List<Map<String, dynamic>> _getSeasonalPrompts() {
    final now = DateTime.now();
    final month = now.month;
    
    if (month >= 3 && month <= 5) { // Spring
      return [
        {
          'text': 'What new beginnings are you excited about this spring?',
          'category': 'seasonal',
          'type': JournalConstants.goalsJournal,
        }
      ];
    } else if (month >= 6 && month <= 8) { // Summer
      return [
        {
          'text': 'How are you embracing the energy of summer?',
          'category': 'seasonal',
          'type': JournalConstants.dailyJournal,
        }
      ];
    } else if (month >= 9 && month <= 11) { // Fall
      return [
        {
          'text': 'What are you ready to let go of as the year winds down?',
          'category': 'seasonal',
          'type': JournalConstants.reflectionJournal,
        }
      ];
    } else { // Winter
      return [
        {
          'text': 'How are you finding warmth and comfort during this season?',
          'category': 'seasonal',
          'type': JournalConstants.reflectionJournal,
        }
      ];
    }
  }
  
  static List<Map<String, dynamic>> _getCBTPrompts() {
    return [
      {
        'text': 'What thought kept coming up today? Is there evidence for and against it?',
        'category': 'cognitive',
        'type': JournalConstants.reflectionJournal,
        'cbt_technique': 'thought_challenging',
      },
      {
        'text': 'What would you tell a friend who had your exact situation?',
        'category': 'cognitive',
        'type': JournalConstants.reflectionJournal,
        'cbt_technique': 'perspective_taking',
      },
    ];
  }
  
  /// Calculate writing analytics and patterns
  static Map<String, dynamic> calculateWritingAnalytics(
    List<Map<String, dynamic>> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredEntries = entries.where((entry) {
      final entryDate = DateTime.parse(entry['created_at'] as String);
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate);
    }).toList();
    
    if (filteredEntries.isEmpty) {
      return {
        'total_entries': 0,
        'total_words': 0,
        'average_entry_length': 0,
        'writing_streak': 0,
        'most_active_day': 'No data',
        'sentiment_distribution': {},
        'common_themes': [],
      };
    }
    
    // Calculate basic metrics
    final totalEntries = filteredEntries.length;
    final totalWords = filteredEntries.fold<int>(0, (sum, entry) {
      final content = entry['content'] as String? ?? '';
      return sum + content.split(RegExp(r'\s+')).length;
    });
    final avgEntryLength = totalWords / totalEntries;
    
    // Calculate writing streak
    final streak = _calculateWritingStreak(filteredEntries);
    
    // Find most active day of week
    final dayCount = <int, int>{};
    for (final entry in filteredEntries) {
      final date = DateTime.parse(entry['created_at'] as String);
      dayCount[date.weekday] = (dayCount[date.weekday] ?? 0) + 1;
    }
    
    final mostActiveDay = dayCount.entries.isEmpty ? 'No data' : 
        _getDayName(dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key);
    
    // Analyze sentiment distribution
    final sentimentCounts = <String, int>{'positive': 0, 'negative': 0, 'neutral': 0};
    final themes = <String, int>{};
    
    for (final entry in filteredEntries) {
      final content = entry['content'] as String? ?? '';
      final sentiment = _analyzeSentiment(content);
      sentimentCounts[sentiment['label'] as String] = (sentimentCounts[sentiment['label'] as String] ?? 0) + 1;
      
      // Extract themes (simplified)
      final words = content.toLowerCase().split(RegExp(r'\W+'));
      for (final word in words) {
        if (word.length > 4) { // Only consider longer words as potential themes
          themes[word] = (themes[word] ?? 0) + 1;
        }
      }
    }
    
    // Get top themes
    final topThemes = themes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'period': '${DateTimeUtils.formatDate(startDate)} - ${DateTimeUtils.formatDate(endDate)}',
      'total_entries': totalEntries,
      'total_words': totalWords,
      'average_entry_length': avgEntryLength.round(),
      'writing_streak': streak,
      'most_active_day': mostActiveDay,
      'sentiment_distribution': sentimentCounts,
      'common_themes': topThemes.take(10).map((e) => e.key).toList(),
      'writing_consistency': _calculateConsistency(filteredEntries, startDate, endDate),
    };
  }
  
  static int _calculateWritingStreak(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 0;
    
    // Sort entries by date (most recent first)
    entries.sort((a, b) => DateTime.parse(b['created_at'] as String)
        .compareTo(DateTime.parse(a['created_at'] as String)));
    
    final uniqueDays = entries.map((entry) {
      final date = DateTime.parse(entry['created_at'] as String);
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList();
    
    uniqueDays.sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime? expectedDate;
    
    for (final day in uniqueDays) {
      if (expectedDate == null) {
        if (DateTimeUtils.isToday(day) || DateTimeUtils.isYesterday(day)) {
          streak = 1;
          expectedDate = day.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        if (day == expectedDate) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }
    
    return streak;
  }
  
  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
  
  static double _calculateConsistency(List<Map<String, dynamic>> entries, DateTime start, DateTime end) {
    final totalDays = end.difference(start).inDays + 1;
    final uniqueDays = entries.map((entry) {
      final date = DateTime.parse(entry['created_at'] as String);
      return DateTime(date.year, date.month, date.day);
    }).toSet().length;
    
    return uniqueDays / totalDays;
  }
  
  /// Export journal entries to different formats
  static String exportEntries(
    List<Map<String, dynamic>> entries,
    String format,
    Map<String, dynamic> options,
  ) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return _exportToPDF(entries, options);
      case 'markdown':
        return _exportToMarkdown(entries, options);
      case 'json':
        return _exportToJSON(entries, options);
      case 'txt':
        return _exportToText(entries, options);
      default:
        return _exportToText(entries, options);
    }
  }
  
  static String _exportToPDF(List<Map<String, dynamic>> entries, Map<String, dynamic> options) {
    // This would generate actual PDF content
    // For now, return formatted text
    final buffer = StringBuffer();
    buffer.writeln('# Journal Export');
    buffer.writeln('Exported on ${DateTimeUtils.formatDateTime(DateTime.now())}\n');
    
    for (final entry in entries) {
      buffer.writeln('## ${DateTimeUtils.formatDate(DateTime.parse(entry['created_at'] as String))}');
      buffer.writeln(entry['content']);
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  static String _exportToMarkdown(List<Map<String, dynamic>> entries, Map<String, dynamic> options) {
    final buffer = StringBuffer();
    buffer.writeln('# My Journal');
    buffer.writeln();
    
    for (final entry in entries) {
      final date = DateTime.parse(entry['created_at'] as String);
      buffer.writeln('## ${DateTimeUtils.formatDateReadable(date)}');
      buffer.writeln();
      buffer.writeln(entry['content']);
      buffer.writeln();
      
      if (entry['mood'] != null) {
        buffer.writeln('**Mood:** ${entry['mood']}');
        buffer.writeln();
      }
      
      buffer.writeln('---');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  static String _exportToJSON(List<Map<String, dynamic>> entries, Map<String, dynamic> options) {
    // This would use proper JSON encoding
    return entries.toString(); // Simplified for now
  }
  
  static String _exportToText(List<Map<String, dynamic>> entries, Map<String, dynamic> options) {
    final buffer = StringBuffer();
    
    for (final entry in entries) {
      final date = DateTime.parse(entry['created_at'] as String);
      buffer.writeln('Date: ${DateTimeUtils.formatDateTime(date)}');
      buffer.writeln();
      buffer.writeln(entry['content']);
      buffer.writeln();
      buffer.writeln('=' * 50);
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Validate journal entry data
  static Map<String, String?> validateJournalEntry(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final content = data['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      errors['content'] = 'Journal entry content cannot be empty';
    } else if (content.length > JournalConstants.maxEntryLength) {
      errors['content'] = 'Entry is too long (max ${JournalConstants.maxEntryLength} characters)';
    } else if (content.length < JournalConstants.minEntryLength) {
      errors['content'] = 'Entry is too short (min ${JournalConstants.minEntryLength} characters)';
    }
    
    final mood = data['mood'] as int?;
    if (mood != null && (mood < 1 || mood > 5)) {
      errors['mood'] = 'Mood rating must be between 1 and 5';
    }
    
    final tags = data['tags'] as List<String>?;
    if (tags != null && tags.length > JournalConstants.maxTagsPerEntry) {
      errors['tags'] = 'Too many tags (max ${JournalConstants.maxTagsPerEntry})';
    }
    
    return errors;
  }
  
  /// Get journal type color
  static String getJournalTypeColor(String type) {
    switch (type) {
      case JournalConstants.dailyJournal:
        return '#3498DB'; // Blue
      case JournalConstants.gratitudeJournal:
        return '#2ECC71'; // Green
      case JournalConstants.dreamJournal:
        return '#9B59B6'; // Purple
      case JournalConstants.reflectionJournal:
        return '#E67E22'; // Orange
      case JournalConstants.moodJournal:
        return '#E91E63'; // Pink
      case JournalConstants.goalsJournal:
        return '#F39C12'; // Yellow
      default:
        return '#95A5A6'; // Gray
    }
  }
  
  /// Format word count for display
  static String formatWordCount(int wordCount) {
    if (wordCount >= 1000) {
      return '${(wordCount / 1000).toStringAsFixed(1)}K words';
    }
    return '$wordCount words';
  }
}
