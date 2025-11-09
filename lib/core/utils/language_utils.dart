import '../constants/language_constants.dart';
import 'math_utils.dart';
import 'string_utils.dart';

class LanguageUtils {
  /// Calculate proficiency level based on XP and performance
  static String calculateProficiencyLevel(int xp, double accuracy, int lessonsCompleted) {
    // CEFR levels: A1, A2, B1, B2, C1, C2
    const levelThresholds = [
      {'level': 'a1_beginner', 'xp': 0, 'lessons': 0},
      {'level': 'a2_elementary', 'xp': 1000, 'lessons': 25},
      {'level': 'b1_intermediate', 'xp': 3000, 'lessons': 75},
      {'level': 'b2_upper_intermediate', 'xp': 7000, 'lessons': 150},
      {'level': 'c1_advanced', 'xp': 15000, 'lessons': 300},
      {'level': 'c2_proficiency', 'xp': 30000, 'lessons': 500},
    ];
    
    String currentLevel = 'a1_beginner';
    for (final threshold in levelThresholds.reversed) {
      if (xp >= threshold['xp']! && lessonsCompleted >= threshold['lessons']!) {
        currentLevel = threshold['level']! as String;
        break;
      }
    }
    
    // Adjust for low accuracy
    if (accuracy < 0.6) {
      final levelIndex = LanguageConstants.proficiencyLevels.indexOf(currentLevel);
      if (levelIndex > 0) {
        return LanguageConstants.proficiencyLevels[levelIndex - 1];
      }
    }
    
    return currentLevel;
  }
  
  /// Calculate league placement based on weekly XP
  static Map<String, dynamic> calculateLeaguePosition(int weeklyXP, List<Map<String, dynamic>> leaderboard) {
    // Find appropriate league
    final leagues = LanguageConstants.leagues;
    Map<String, dynamic> currentLeague = leagues.first;
    
    for (final league in leagues) {
      final minXp = league['min_xp'] as int;
      final maxXp = league['max_xp'] as int;
      if (weeklyXP >= minXp && weeklyXP <= maxXp) {
        currentLeague = league;
        break;
      }
    }
    
    // Calculate position within league
    final leagueUsers = leaderboard.where((user) {
      final userXp = user['weekly_xp'] as int? ?? 0;
      final minXp = currentLeague['min_xp'] as int;
      final maxXp = currentLeague['max_xp'] as int;
      return userXp >= minXp && userXp <= maxXp;
    }).toList();
    
    leagueUsers.sort((a, b) => (b['weekly_xp'] as int).compareTo(a['weekly_xp'] as int));
    
    int position = 1;
    for (int i = 0; i < leagueUsers.length; i++) {
      if (leagueUsers[i]['weekly_xp'] == weeklyXP) {
        position = i + 1;
        break;
      }
    }
    
    return {
      'league': currentLeague,
      'position': position,
      'total_in_league': leagueUsers.length,
      'promotion_threshold': _getPromotionThreshold(currentLeague),
      'demotion_threshold': _getDemotionThreshold(currentLeague),
    };
  }
  
  static int? _getPromotionThreshold(Map<String, dynamic> league) {
    final leagues = LanguageConstants.leagues;
    final currentIndex = leagues.indexOf(league);
    if (currentIndex < leagues.length - 1) {
      return leagues[currentIndex + 1]['min_xp'] as int;
    }
    return null; // Already in highest league
  }
  
  static int? _getDemotionThreshold(Map<String, dynamic> league) {
    final leagues = LanguageConstants.leagues;
    final currentIndex = leagues.indexOf(league);
    if (currentIndex > 0) {
      return leagues[currentIndex - 1]['max_xp'] as int;
    }
    return null; // Already in lowest league
  }
  
  /// Generate AI stories based on user level and interests
  static List<Map<String, dynamic>> generateAIStories(
    String proficiencyLevel,
    List<String> interests,
    String targetLanguage,
  ) {
    final stories = <Map<String, dynamic>>[];
    final themes = LanguageConstants.storyThemes;
    
    // Filter themes by interests or use all if none specified
    final relevantThemes = interests.isEmpty ? themes : 
        themes.where((theme) => interests.contains(theme['theme'])).toList();
    
    for (final theme in relevantThemes.take(3)) { // Generate 3 stories
      final story = _generateStoryFromTheme(theme, proficiencyLevel, targetLanguage);
      stories.add(story);
    }
    
    return stories;
  }
  
  static Map<String, dynamic> _generateStoryFromTheme(
    Map<String, dynamic> theme,
    String proficiencyLevel,
    String language,
  ) {
    final difficulty = _mapProficiencyToDifficulty(proficiencyLevel);
    final topics = theme['topics'] as List<String>;
    final selectedTopic = topics[MathUtils.randomInt(0, topics.length - 1)];
    
    return {
      'id': 'story_${DateTime.now().millisecondsSinceEpoch}',
      'title': _generateStoryTitle(theme['theme'] as String, selectedTopic),
      'theme': theme['theme'],
      'topic': selectedTopic,
      'difficulty': difficulty,
      'estimated_reading_time': _calculateReadingTime(difficulty),
      'vocabulary_count': _getVocabularyCount(difficulty),
      'language': language,
      'created_at': DateTime.now(),
      'content_preview': _generateContentPreview(theme['theme'] as String, difficulty),
    };
  }
  
  static String _mapProficiencyToDifficulty(String proficiency) {
    if (proficiency.startsWith('a1') || proficiency.startsWith('a2')) return 'beginner';
    if (proficiency.startsWith('b1') || proficiency.startsWith('b2')) return 'intermediate';
    return 'advanced';
  }
  
  static String _generateStoryTitle(String theme, String topic) {
    final titles = {
      'Adventure': [
        'The Mystery of $topic',
        'Journey Through $topic',
        'The Secret of $topic',
      ],
      'Romance': [
        'Love in $topic',
        'A Heart for $topic',
        'Romance and $topic',
      ],
      'Science Fiction': [
        'Future $topic',
        'The $topic Chronicles',
        'Beyond $topic',
      ],
      'Daily Life': [
        'A Day with $topic',
        'Life and $topic',
        'Stories of $topic',
      ],
    };
    
    final themeTitles = titles[theme] ?? ['Story about $topic'];
    return themeTitles[MathUtils.randomInt(0, themeTitles.length - 1)];
  }
  
  static int _calculateReadingTime(String difficulty) {
    switch (difficulty) {
      case 'beginner': return MathUtils.randomInt(3, 7);
      case 'intermediate': return MathUtils.randomInt(7, 15);
      case 'advanced': return MathUtils.randomInt(15, 25);
      default: return 10;
    }
  }
  
  static int _getVocabularyCount(String difficulty) {
    final counts = LanguageConstants.difficultyLevels[difficulty]?['vocabulary_size'] as int? ?? 500;
    return (counts * 0.1).round(); // 10% of vocabulary in story
  }
  
  static String _generateContentPreview(String theme, String difficulty) {
    final previews = {
      'Adventure': {
        'beginner': 'Sarah finds a map. She wants to find treasure. She walks to the forest...',
        'intermediate': 'The ancient map revealed secrets that had been hidden for centuries...',
        'advanced': 'As Sarah deciphered the cryptic symbols, she realized the implications were far greater...',
      },
      'Romance': {
        'beginner': 'Tom meets Lisa at the cafe. She is beautiful. He wants to talk to her...',
        'intermediate': 'Their eyes met across the crowded restaurant, and time seemed to stand still...',
        'advanced': 'The serendipitous encounter would forever alter the trajectory of both their lives...',
      },
    };
    
    return previews[theme]?[difficulty] as String? ?? 'An interesting story awaits...';
  }
  
  /// Calculate spaced repetition for vocabulary
  static DateTime calculateNextReview(
    String wordId,
    int repetitionNumber,
    double easeFactor,
    int quality, // 0-5 rating
    DateTime lastReview,
  ) {
    int interval = 0;
    double newEaseFactor = easeFactor;
    
    if (quality < 3) {
      // Reset if answer was poor
      repetitionNumber = 0;
      interval = 1;
    } else {
      switch (repetitionNumber) {
        case 0:
          interval = 1;
          break;
        case 1:
          interval = 6;
          break;
        default:
          interval = (repetitionNumber * newEaseFactor).round();
      }
      repetitionNumber++;
    }
    
    // Update ease factor (SM-2 algorithm)
    newEaseFactor = newEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = newEaseFactor.clamp(1.3, 2.5);
    
    return lastReview.add(Duration(days: interval));
  }
  
  /// Live class matching based on level and interests
  static List<Map<String, dynamic>> findMatchingLiveClasses(
    Map<String, dynamic> userProfile,
    List<Map<String, dynamic>> availableClasses,
  ) {
    final userLevel = userProfile['proficiency_level'] as String? ?? 'a1_beginner';
    final interests = userProfile['interests'] as List<String>? ?? [];
    final timezone = userProfile['timezone'] as String? ?? 'UTC';
    
    final matchingClasses = <Map<String, dynamic>>[];
    
    for (final classInfo in availableClasses) {
      double matchScore = 0.0;
      
      // Level matching (50% weight)
      final classLevel = classInfo['level_requirement'] as String? ?? 'a1';
      if (_isLevelCompatible(userLevel, classLevel)) {
        matchScore += 0.5;
      }
      
      // Interest matching (30% weight)
      final classTags = classInfo['tags'] as List<String>? ?? [];
      final interestOverlap = interests.where((interest) => classTags.contains(interest)).length;
      if (interests.isNotEmpty) {
        matchScore += (interestOverlap / interests.length) * 0.3;
      } else {
        matchScore += 0.15; // Neutral score if no interests specified
      }
      
      // Time zone compatibility (20% weight)
      final classTime = DateTime.parse(classInfo['scheduled_time'] as String);
      if (_isTimeCompatible(classTime, timezone)) {
        matchScore += 0.2;
      }
      
      if (matchScore >= 0.5) { // Minimum 50% match required
        matchingClasses.add({
          ...classInfo,
          'match_score': matchScore,
          'match_reasons': _getMatchReasons(matchScore, classLevel, classTags, interests),
        });
      }
    }
    
    // Sort by match score
    matchingClasses.sort((a, b) => (b['match_score'] as double).compareTo(a['match_score'] as double));
    
    return matchingClasses.take(10).toList(); // Return top 10 matches
  }
  
  static bool _isLevelCompatible(String userLevel, String classLevel) {
    final userIndex = LanguageConstants.proficiencyLevels.indexOf(userLevel);
    final classIndex = LanguageConstants.proficiencyLevels.indexOf(classLevel);
    
    // Allow classes at same level or one level above/below
    return (userIndex - classIndex).abs() <= 1;
  }
  
  static bool _isTimeCompatible(DateTime classTime, String userTimezone) {
    // Simplified timezone compatibility check
    // In real implementation, would use proper timezone conversion
    final hour = classTime.hour;
    return hour >= 8 && hour <= 22; // Reasonable hours
  }
  
  static List<String> _getMatchReasons(double score, String classLevel, List<String> classTags, List<String> interests) {
    final reasons = <String>[];
    
    if (score >= 0.8) {
      reasons.add('Perfect match for your level');
    } else if (score >= 0.6) {
      reasons.add('Good match for your level');
    }
    
    final commonInterests = interests.where((interest) => classTags.contains(interest)).toList();
    if (commonInterests.isNotEmpty) {
      reasons.add('Matches interests: ${commonInterests.join(", ")}');
    }
    
    return reasons;
  }
  
  /// Calculate pronunciation accuracy using speech recognition
  static Map<String, dynamic> calculatePronunciationAccuracy(
    String targetText,
    String spokenText,
    List<double> audioFeatures,
  ) {
    // Simplified pronunciation scoring
    final textSimilarity = _calculateTextSimilarity(targetText, spokenText);
    final phoneticAccuracy = _calculatePhoneticAccuracy(audioFeatures);
    
    final overallScore = (textSimilarity * 0.6 + phoneticAccuracy * 0.4) * 100;
    
    return {
      'overall_score': overallScore.round(),
      'text_accuracy': (textSimilarity * 100).round(),
      'phonetic_accuracy': (phoneticAccuracy * 100).round(),
      'feedback': _generatePronunciationFeedback(overallScore),
      'improvement_tips': _getPronunciationTips(overallScore),
    };
  }
  
  static double _calculateTextSimilarity(String target, String spoken) {
    final targetWords = target.toLowerCase().split(' ');
    final spokenWords = spoken.toLowerCase().split(' ');
    
    int matches = 0;
    for (final word in targetWords) {
      if (spokenWords.contains(word)) {
        matches++;
      }
    }
    
    return targetWords.isEmpty ? 0.0 : matches / targetWords.length;
  }
  
  static double _calculatePhoneticAccuracy(List<double> audioFeatures) {
    // Mock phonetic analysis based on audio features
    if (audioFeatures.isEmpty) return 0.5;
    
    // Analyze features like pitch, formants, timing
    final pitchVariation = _calculateVariation(audioFeatures);
    final clarity = audioFeatures.reduce((a, b) => a > b ? a : b); // Max value as clarity proxy
    
    return ((1 - pitchVariation) * 0.6 + clarity * 0.4).clamp(0.0, 1.0);
  }
  
  static double _calculateVariation(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    return variance / (mean + 0.001); // Coefficient of variation
  }
  
  static String _generatePronunciationFeedback(double score) {
    if (score >= 90) return 'Excellent pronunciation! Native-like quality.';
    if (score >= 80) return 'Very good! Minor improvements needed.';
    if (score >= 70) return 'Good effort! Focus on clarity.';
    if (score >= 60) return 'Keep practicing. Pay attention to sounds.';
    return 'Needs improvement. Try speaking slower and clearer.';
  }
  
  static List<String> _getPronunciationTips(double score) {
    if (score >= 80) {
      return ['Fine-tune intonation', 'Work on rhythm patterns'];
    } else if (score >= 60) {
      return ['Practice difficult sounds', 'Record yourself speaking', 'Listen to native speakers'];
    } else {
      return [
        'Speak slower and clearer',
        'Break down words into syllables',
        'Use pronunciation apps',
        'Practice with tongue twisters'
      ];
    }
  }
  
  /// Generate cultural context for language learning
  static Map<String, dynamic> generateCulturalContext(
    String language,
    String topic,
    String proficiencyLevel,
  ) {
    final culturalInfo = {
      'spanish': {
        'greetings': {
          'formal': 'In formal settings, use "usted" instead of "tú"',
          'informal': 'Friends often greet with a kiss on each cheek',
          'business': 'Handshakes are standard in business meetings',
        },
        'dining': {
          'timing': 'Dinner is typically eaten late, around 9-10 PM',
          'etiquette': 'Keep hands visible on the table while eating',
          'tipping': 'Tipping 5-10% is customary in restaurants',
        },
      },
      'french': {
        'greetings': {
          'formal': 'Always use "vous" until invited to use "tu"',
          'informal': 'La bise (cheek kisses) are common among friends',
          'business': 'Firm handshakes and proper titles are important',
        },
        'dining': {
          'timing': 'Lunch is sacred - typically 12-2 PM with breaks',
          'etiquette': 'Wait for "Bon appétit" before eating',
          'tipping': 'Service is included, but small tips are appreciated',
        },
      },
    };
    
    final langInfo = culturalInfo[language.toLowerCase()] as Map<String, dynamic>? ?? {};
    final topicInfo = langInfo[topic] as Map<String, dynamic>? ?? {};
    
    return {
      'language': language,
      'topic': topic,
      'level': proficiencyLevel,
      'cultural_notes': topicInfo,
      'do_list': _generateDoList(language, topic),
      'dont_list': _generateDontList(language, topic),
      'fun_facts': _generateFunFacts(language, topic),
    };
  }
  
  static List<String> _generateDoList(String language, String topic) {
    return [
      'Observe local customs carefully',
      'Ask questions if unsure about etiquette',
      'Show respect for cultural differences',
      'Practice common phrases before social situations',
    ];
  }
  
  static List<String> _generateDontList(String language, String topic) {
    return [
      'Don\'t assume cultural norms are the same as your own',
      'Avoid sensitive political or historical topics initially',
      'Don\'t speak too loudly in public spaces',
      'Don\'t skip learning about cultural context',
    ];
  }
  
  static List<String> _generateFunFacts(String language, String topic) {
    final facts = {
      'spanish': [
        'Spanish is spoken by over 500 million people worldwide',
        'There are 21 Spanish-speaking countries',
        'Spanish has Arabic influences from 700 years of Moorish rule',
      ],
      'french': [
        'French is an official language in 29 countries',
        'French has contributed many words to English',
        'The French Academy regulates the French language',
      ],
    };
    
    return facts[language.toLowerCase()] ?? ['This language has a rich cultural history'];
  }
  
  /// Validate language learning data
  static Map<String, String?> validateLanguageData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final targetLanguage = data['target_language'] as String?;
    if (targetLanguage == null || !LanguageConstants.supportedLanguages.containsKey(targetLanguage)) {
      errors['target_language'] = 'Please select a valid target language';
    }
    
    final studyTime = data['daily_study_time'] as int?;
    if (studyTime != null && (studyTime < 5 || studyTime > 180)) {
      errors['daily_study_time'] = 'Daily study time should be between 5 and 180 minutes';
    }
    
    final weeklyGoal = data['weekly_xp_goal'] as int?;
    if (weeklyGoal != null && weeklyGoal > LanguageConstants.maxDailyXp * 7) {
      errors['weekly_xp_goal'] = 'Weekly goal is too high';
    }
    
    return errors;
  }
  
  /// Get language flag and display info
  static Map<String, String> getLanguageDisplayInfo(String languageCode) {
    final langInfo = LanguageConstants.supportedLanguages[languageCode];
    
    return {
      'name': langInfo?['name'] as String? ?? 'Unknown',
      'native_name': langInfo?['native_name'] as String? ?? 'Unknown',
      'flag': langInfo?['flag'] as String? ?? '🏳️',
      'difficulty': langInfo?['difficulty'] as String? ?? 'medium',
    };
  }
  
  /// Format study time
  static String formatStudyTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}
