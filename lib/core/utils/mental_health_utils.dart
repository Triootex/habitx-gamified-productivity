import '../constants/mental_health_constants.dart';
import 'date_utils.dart';
import 'math_utils.dart';

class MentalHealthUtils {
  /// Calculate overall mental wellness score
  static double calculateWellnessScore(Map<String, dynamic> mentalHealthData) {
    final moodAverage = mentalHealthData['average_mood'] as double? ?? 3.0;
    final stressLevel = mentalHealthData['stress_level'] as double? ?? 0.5;
    final anxietyLevel = mentalHealthData['anxiety_level'] as double? ?? 0.5;
    final sleepQuality = mentalHealthData['sleep_quality'] as double? ?? 0.7;
    final exerciseFrequency = mentalHealthData['exercise_frequency'] as double? ?? 0.5;
    final socialConnection = mentalHealthData['social_connection'] as double? ?? 0.6;
    
    // Weighted calculation
    double score = 0.0;
    score += (moodAverage / 5.0) * 0.25; // 25% weight for mood
    score += (1.0 - stressLevel) * 0.20; // 20% weight for stress (inverted)
    score += (1.0 - anxietyLevel) * 0.15; // 15% weight for anxiety (inverted)
    score += sleepQuality * 0.15; // 15% weight for sleep
    score += exerciseFrequency * 0.15; // 15% weight for exercise
    score += socialConnection * 0.10; // 10% weight for social connection
    
    return (score * 100).clamp(0.0, 100.0);
  }
  
  /// Analyze mood patterns and trends
  static Map<String, dynamic> analyzeMoodPatterns(List<Map<String, dynamic>> moodEntries) {
    if (moodEntries.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'average_mood': 3.0,
        'mood_variance': 0.0,
        'patterns': <String, dynamic>{},
      };
    }
    
    final moods = moodEntries.map((entry) => entry['mood'] as double).toList();
    final timestamps = moodEntries.map((entry) => entry['timestamp'] as DateTime).toList();
    
    final averageMood = moods.reduce((a, b) => a + b) / moods.length;
    final moodVariance = MathUtils.calculateStandardDeviation(moods);
    
    // Analyze trend (last 7 days vs previous 7 days)
    final now = DateTime.now();
    final last7Days = moodEntries
        .where((entry) => now.difference(entry['timestamp'] as DateTime).inDays <= 7)
        .map((entry) => entry['mood'] as double)
        .toList();
    final previous7Days = moodEntries
        .where((entry) {
          final diff = now.difference(entry['timestamp'] as DateTime).inDays;
          return diff > 7 && diff <= 14;
        })
        .map((entry) => entry['mood'] as double)
        .toList();
    
    String trend = 'stable';
    if (last7Days.isNotEmpty && previous7Days.isNotEmpty) {
      final lastAvg = last7Days.reduce((a, b) => a + b) / last7Days.length;
      final prevAvg = previous7Days.reduce((a, b) => a + b) / previous7Days.length;
      final difference = lastAvg - prevAvg;
      
      if (difference > 0.5) {
        trend = 'improving';
      } else if (difference < -0.5) {
        trend = 'declining';
      }
    }
    
    // Analyze time-of-day patterns
    final timePatterns = _analyzeTimePatterns(moodEntries);
    
    // Analyze day-of-week patterns
    final dayPatterns = _analyzeDayPatterns(moodEntries);
    
    return {
      'trend': trend,
      'average_mood': averageMood,
      'mood_variance': moodVariance,
      'patterns': {
        'time_of_day': timePatterns,
        'day_of_week': dayPatterns,
      },
      'insights': _generateMoodInsights(trend, averageMood, timePatterns, dayPatterns),
    };
  }
  
  static Map<String, double> _analyzeTimePatterns(List<Map<String, dynamic>> moodEntries) {
    final morningMoods = <double>[];
    final afternoonMoods = <double>[];
    final eveningMoods = <double>[];
    final nightMoods = <double>[];
    
    for (final entry in moodEntries) {
      final hour = (entry['timestamp'] as DateTime).hour;
      final mood = entry['mood'] as double;
      
      if (hour >= 6 && hour < 12) {
        morningMoods.add(mood);
      } else if (hour >= 12 && hour < 17) {
        afternoonMoods.add(mood);
      } else if (hour >= 17 && hour < 22) {
        eveningMoods.add(mood);
      } else {
        nightMoods.add(mood);
      }
    }
    
    return {
      'morning': morningMoods.isEmpty ? 0.0 : morningMoods.reduce((a, b) => a + b) / morningMoods.length,
      'afternoon': afternoonMoods.isEmpty ? 0.0 : afternoonMoods.reduce((a, b) => a + b) / afternoonMoods.length,
      'evening': eveningMoods.isEmpty ? 0.0 : eveningMoods.reduce((a, b) => a + b) / eveningMoods.length,
      'night': nightMoods.isEmpty ? 0.0 : nightMoods.reduce((a, b) => a + b) / nightMoods.length,
    };
  }
  
  static Map<String, double> _analyzeDayPatterns(List<Map<String, dynamic>> moodEntries) {
    final dayMoods = <int, List<double>>{
      1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [], // Monday to Sunday
    };
    
    for (final entry in moodEntries) {
      final weekday = (entry['timestamp'] as DateTime).weekday;
      final mood = entry['mood'] as double;
      dayMoods[weekday]?.add(mood);
    }
    
    return {
      'monday': dayMoods[1]!.isEmpty ? 0.0 : dayMoods[1]!.reduce((a, b) => a + b) / dayMoods[1]!.length,
      'tuesday': dayMoods[2]!.isEmpty ? 0.0 : dayMoods[2]!.reduce((a, b) => a + b) / dayMoods[2]!.length,
      'wednesday': dayMoods[3]!.isEmpty ? 0.0 : dayMoods[3]!.reduce((a, b) => a + b) / dayMoods[3]!.length,
      'thursday': dayMoods[4]!.isEmpty ? 0.0 : dayMoods[4]!.reduce((a, b) => a + b) / dayMoods[4]!.length,
      'friday': dayMoods[5]!.isEmpty ? 0.0 : dayMoods[5]!.reduce((a, b) => a + b) / dayMoods[5]!.length,
      'saturday': dayMoods[6]!.isEmpty ? 0.0 : dayMoods[6]!.reduce((a, b) => a + b) / dayMoods[6]!.length,
      'sunday': dayMoods[7]!.isEmpty ? 0.0 : dayMoods[7]!.reduce((a, b) => a + b) / dayMoods[7]!.length,
    };
  }
  
  static List<String> _generateMoodInsights(
    String trend,
    double averageMood,
    Map<String, double> timePatterns,
    Map<String, double> dayPatterns,
  ) {
    final insights = <String>[];
    
    // Trend insights
    switch (trend) {
      case 'improving':
        insights.add('Your mood has been trending upward recently - keep up the good work!');
        break;
      case 'declining':
        insights.add('Your mood seems to be declining. Consider reaching out for support.');
        break;
      case 'stable':
        insights.add('Your mood has been relatively stable recently.');
        break;
    }
    
    // Time-based insights
    final bestTime = timePatterns.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worstTime = timePatterns.entries.reduce((a, b) => a.value < b.value ? a : b);
    
    insights.add('You tend to feel best in the ${bestTime.key}');
    if (worstTime.value < averageMood - 0.5) {
      insights.add('Consider planning self-care activities for ${worstTime.key} when your mood dips');
    }
    
    // Day-based insights
    final bestDay = dayPatterns.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worstDay = dayPatterns.entries.reduce((a, b) => a.value < b.value ? a : b);
    
    insights.add('${bestDay.key.capitalize()} tends to be your best day');
    if (worstDay.value < averageMood - 0.5) {
      insights.add('Plan extra self-care on ${worstDay.key.capitalize()}s');
    }
    
    return insights;
  }
  
  /// Generate personalized coping strategies
  static List<Map<String, dynamic>> generateCopingStrategies(
    Map<String, dynamic> userProfile,
    String currentMoodState,
    List<String> triggers,
  ) {
    final strategies = <Map<String, dynamic>>[];
    
    // Base strategies for current mood
    switch (currentMoodState) {
      case 'anxious':
        strategies.addAll([
          {
            'strategy': 'Deep Breathing',
            'description': '4-7-8 breathing technique for immediate calm',
            'duration': 5,
            'difficulty': 'easy',
            'effectiveness': 0.8,
          },
          {
            'strategy': 'Grounding Exercise',
            'description': '5-4-3-2-1 technique: 5 things you see, 4 you hear, 3 you feel, 2 you smell, 1 you taste',
            'duration': 10,
            'difficulty': 'easy',
            'effectiveness': 0.7,
          },
        ]);
        break;
        
      case 'depressed':
        strategies.addAll([
          {
            'strategy': 'Gentle Movement',
            'description': '10-minute walk or light stretching',
            'duration': 10,
            'difficulty': 'moderate',
            'effectiveness': 0.6,
          },
          {
            'strategy': 'Gratitude Practice',
            'description': 'Write down 3 things you\'re grateful for',
            'duration': 5,
            'difficulty': 'easy',
            'effectiveness': 0.5,
          },
        ]);
        break;
        
      case 'stressed':
        strategies.addAll([
          {
            'strategy': 'Progressive Muscle Relaxation',
            'description': 'Tense and release muscle groups systematically',
            'duration': 15,
            'difficulty': 'moderate',
            'effectiveness': 0.8,
          },
          {
            'strategy': 'Time Management',
            'description': 'Break overwhelming tasks into smaller steps',
            'duration': 20,
            'difficulty': 'moderate',
            'effectiveness': 0.7,
          },
        ]);
        break;
    }
    
    // Add personalized strategies based on user profile
    final preferences = userProfile['coping_preferences'] as List<String>? ?? [];
    if (preferences.contains('physical_activity')) {
      strategies.add({
        'strategy': 'Physical Exercise',
        'description': 'Go for a run or do your favorite workout',
        'duration': 30,
        'difficulty': 'moderate',
        'effectiveness': 0.9,
      });
    }
    
    if (preferences.contains('creative_expression')) {
      strategies.add({
        'strategy': 'Creative Expression',
        'description': 'Draw, write, or engage in any creative activity',
        'duration': 20,
        'difficulty': 'easy',
        'effectiveness': 0.6,
      });
    }
    
    if (preferences.contains('social_support')) {
      strategies.add({
        'strategy': 'Social Connection',
        'description': 'Call a friend or family member',
        'duration': 15,
        'difficulty': 'easy',
        'effectiveness': 0.7,
      });
    }
    
    // Add trigger-specific strategies
    for (final trigger in triggers) {
      final triggerStrategies = _getTriggerSpecificStrategies(trigger);
      strategies.addAll(triggerStrategies);
    }
    
    return strategies.take(6).toList(); // Limit to 6 strategies
  }
  
  static List<Map<String, dynamic>> _getTriggerSpecificStrategies(String trigger) {
    switch (trigger) {
      case 'work_pressure':
        return [
          {
            'strategy': 'Workplace Boundary Setting',
            'description': 'Take regular breaks and set realistic expectations',
            'duration': 0,
            'difficulty': 'hard',
            'effectiveness': 0.8,
          }
        ];
        
      case 'relationship_conflict':
        return [
          {
            'strategy': 'Communication Skills',
            'description': 'Practice "I" statements and active listening',
            'duration': 0,
            'difficulty': 'moderate',
            'effectiveness': 0.7,
          }
        ];
        
      case 'financial_stress':
        return [
          {
            'strategy': 'Financial Planning',
            'description': 'Create a budget and identify cost-cutting opportunities',
            'duration': 60,
            'difficulty': 'hard',
            'effectiveness': 0.6,
          }
        ];
        
      default:
        return [];
    }
  }
  
  /// Conduct CBT thought record analysis
  static Map<String, dynamic> analyzeCBTThoughtRecord(Map<String, dynamic> thoughtRecord) {
    final automaticThought = thoughtRecord['automatic_thought'] as String? ?? '';
    final emotion = thoughtRecord['emotion'] as String? ?? '';
    final evidenceFor = thoughtRecord['evidence_for'] as String? ?? '';
    final evidenceAgainst = thoughtRecord['evidence_against'] as String? ?? '';
    final balancedThought = thoughtRecord['balanced_thought'] as String? ?? '';
    
    // Analyze cognitive distortions
    final distortions = _identifyCognitiveDistortions(automaticThought);
    
    // Calculate thought believability (0-10)
    final believability = _calculateThoughtBelievability(evidenceFor, evidenceAgainst);
    
    // Generate insights
    final insights = _generateCBTInsights(distortions, believability, emotion);
    
    return {
      'cognitive_distortions': distortions,
      'thought_believability': believability,
      'insights': insights,
      'suggestions': _generateCBTSuggestions(distortions, balancedThought),
    };
  }
  
  static List<String> _identifyCognitiveDistortions(String thought) {
    final distortions = <String>[];
    final lowerThought = thought.toLowerCase();
    
    // All-or-nothing thinking
    if (lowerThought.contains(RegExp(r'\b(always|never|all|nothing|everything|everyone|nobody)\b'))) {
      distortions.add('All-or-Nothing Thinking');
    }
    
    // Catastrophizing
    if (lowerThought.contains(RegExp(r'\b(disaster|terrible|awful|worst|end of the world)\b'))) {
      distortions.add('Catastrophizing');
    }
    
    // Mind reading
    if (lowerThought.contains(RegExp(r'\bthey think|he thinks|she thinks|must think\b'))) {
      distortions.add('Mind Reading');
    }
    
    // Fortune telling
    if (lowerThought.contains(RegExp(r'\bwill never|going to fail|bound to happen\b'))) {
      distortions.add('Fortune Telling');
    }
    
    // Emotional reasoning
    if (lowerThought.contains(RegExp(r'\bi feel.+so it must be\b'))) {
      distortions.add('Emotional Reasoning');
    }
    
    // Should statements
    if (lowerThought.contains(RegExp(r'\b(should|must|ought to|have to)\b'))) {
      distortions.add('Should Statements');
    }
    
    // Labeling
    if (lowerThought.contains(RegExp(r'\bi am.+(stupid|failure|loser|worthless)\b'))) {
      distortions.add('Labeling');
    }
    
    return distortions;
  }
  
  static double _calculateThoughtBelievability(String evidenceFor, String evidenceAgainst) {
    // Simple heuristic based on evidence length and strength
    final forScore = evidenceFor.length / 100.0; // Normalize by character count
    final againstScore = evidenceAgainst.length / 100.0;
    
    if (againstScore > forScore) {
      return (5.0 - (againstScore - forScore) * 2).clamp(1.0, 10.0);
    } else {
      return (5.0 + (forScore - againstScore) * 2).clamp(1.0, 10.0);
    }
  }
  
  static List<String> _generateCBTInsights(List<String> distortions, double believability, String emotion) {
    final insights = <String>[];
    
    if (distortions.isNotEmpty) {
      insights.add('Identified ${distortions.length} cognitive distortion(s): ${distortions.join(", ")}');
    }
    
    if (believability > 7) {
      insights.add('This thought seems very believable to you. Consider examining the evidence more carefully.');
    } else if (believability < 4) {
      insights.add('Good job questioning this thought! The evidence suggests it may not be entirely accurate.');
    }
    
    if (emotion.toLowerCase().contains('anxious') && distortions.contains('Catastrophizing')) {
      insights.add('Catastrophizing often fuels anxiety. Try to focus on more likely outcomes.');
    }
    
    return insights;
  }
  
  static List<String> _generateCBTSuggestions(List<String> distortions, String balancedThought) {
    final suggestions = <String>[];
    
    if (distortions.contains('All-or-Nothing Thinking')) {
      suggestions.add('Look for the gray area between extremes. What\'s a more balanced perspective?');
    }
    
    if (distortions.contains('Catastrophizing')) {
      suggestions.add('What\'s the most realistic outcome? What would you tell a friend in this situation?');
    }
    
    if (distortions.contains('Mind Reading')) {
      suggestions.add('You can\'t know for certain what others are thinking. Consider asking directly or focusing on facts.');
    }
    
    if (balancedThought.isEmpty) {
      suggestions.add('Try creating a more balanced thought that considers both the evidence for and against your initial thought.');
    }
    
    return suggestions;
  }
  
  /// Calculate mental health assessment scores
  static Map<String, dynamic> calculateAssessmentScore(
    String assessmentType,
    Map<String, int> responses,
  ) {
    switch (assessmentType) {
      case 'PHQ-9': // Depression screening
        return _calculatePHQ9Score(responses);
      case 'GAD-7': // Anxiety screening
        return _calculateGAD7Score(responses);
      case 'PSS-10': // Perceived stress scale
        return _calculatePSS10Score(responses);
      default:
        return {'error': 'Unknown assessment type'};
    }
  }
  
  static Map<String, dynamic> _calculatePHQ9Score(Map<String, int> responses) {
    final totalScore = responses.values.fold<int>(0, (sum, value) => sum + value);
    
    String severity;
    String recommendation;
    
    if (totalScore <= 4) {
      severity = 'Minimal';
      recommendation = 'No treatment needed';
    } else if (totalScore <= 9) {
      severity = 'Mild';
      recommendation = 'Watchful waiting; repeat PHQ-9 at follow-up';
    } else if (totalScore <= 14) {
      severity = 'Moderate';
      recommendation = 'Treatment plan, consider counseling, follow-up';
    } else if (totalScore <= 19) {
      severity = 'Moderately Severe';
      recommendation = 'Active treatment with psychotherapy and/or medication';
    } else {
      severity = 'Severe';
      recommendation = 'Immediate initiation of psychotherapy and/or medication';
    }
    
    return {
      'score': totalScore,
      'max_score': 27,
      'severity': severity,
      'recommendation': recommendation,
      'percentage': (totalScore / 27.0) * 100,
    };
  }
  
  static Map<String, dynamic> _calculateGAD7Score(Map<String, int> responses) {
    final totalScore = responses.values.fold<int>(0, (sum, value) => sum + value);
    
    String severity;
    if (totalScore <= 4) {
      severity = 'Minimal';
    } else if (totalScore <= 9) {
      severity = 'Mild';
    } else if (totalScore <= 14) {
      severity = 'Moderate';
    } else {
      severity = 'Severe';
    }
    
    return {
      'score': totalScore,
      'max_score': 21,
      'severity': severity,
      'percentage': (totalScore / 21.0) * 100,
    };
  }
  
  static Map<String, dynamic> _calculatePSS10Score(Map<String, int> responses) {
    // Reverse score items 4, 5, 7, and 8 (subtract from 4)
    final reversedItems = {4, 5, 7, 8};
    int totalScore = 0;
    
    responses.forEach((key, value) {
      if (reversedItems.contains(key)) {
        totalScore += 4 - value;
      } else {
        totalScore += value;
      }
    });
    
    String level;
    if (totalScore <= 13) {
      level = 'Low Stress';
    } else if (totalScore <= 26) {
      level = 'Moderate Stress';
    } else {
      level = 'High Stress';
    }
    
    return {
      'score': totalScore,
      'max_score': 40,
      'stress_level': level,
      'percentage': (totalScore / 40.0) * 100,
    };
  }
  
  /// Generate crisis intervention recommendations
  static Map<String, dynamic> assessCrisisRisk(Map<String, dynamic> mentalHealthData) {
    final moodLevel = mentalHealthData['current_mood'] as int? ?? 3;
    final suicidalThoughts = mentalHealthData['suicidal_thoughts'] as bool? ?? false;
    final recentLoss = mentalHealthData['recent_loss'] as bool? ?? false;
    final substanceUse = mentalHealthData['substance_use'] as bool? ?? false;
    final socialSupport = mentalHealthData['social_support'] as double? ?? 0.5;
    
    int riskScore = 0;
    
    // Calculate risk factors
    if (moodLevel <= 2) riskScore += 3;
    if (suicidalThoughts) riskScore += 5;
    if (recentLoss) riskScore += 2;
    if (substanceUse) riskScore += 2;
    if (socialSupport < 0.3) riskScore += 2;
    
    String riskLevel;
    List<String> recommendations;
    
    if (riskScore >= 7) {
      riskLevel = 'High';
      recommendations = [
        'Contact emergency services immediately (911)',
        'Go to the nearest emergency room',
        'Call National Suicide Prevention Lifeline: 988',
        'Do not leave the person alone',
      ];
    } else if (riskScore >= 4) {
      riskLevel = 'Moderate';
      recommendations = [
        'Contact a mental health professional within 24 hours',
        'Reach out to trusted friends or family',
        'Consider crisis hotline: 1-800-273-8255',
        'Remove potential means of self-harm',
      ];
    } else {
      riskLevel = 'Low';
      recommendations = [
        'Continue regular mental health monitoring',
        'Maintain healthy coping strategies',
        'Stay connected with support network',
        'Consider professional counseling if symptoms persist',
      ];
    }
    
    return {
      'risk_level': riskLevel,
      'risk_score': riskScore,
      'recommendations': recommendations,
      'crisis_resources': MentalHealthConstants.crisisResources,
    };
  }
  
  /// Validate mental health data
  static Map<String, String?> validateMentalHealthData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    final mood = data['mood'] as int?;
    if (mood != null && (mood < 1 || mood > 5)) {
      errors['mood'] = 'Mood rating must be between 1 and 5';
    }
    
    final emotions = data['emotions'] as List<String>?;
    if (emotions != null && emotions.length > 10) {
      errors['emotions'] = 'Maximum 10 emotions can be selected';
    }
    
    final journalEntry = data['journal_entry'] as String?;
    if (journalEntry != null && journalEntry.length > MentalHealthConstants.maxJournalEntryLength) {
      errors['journal_entry'] = 'Journal entry is too long';
    }
    
    return errors;
  }
  
  /// Get emotion color for UI display
  static String getEmotionColor(String emotion) {
    final emotionCategories = MentalHealthConstants.emotionCategories;
    
    for (final category in emotionCategories) {
      final emotions = category['emotions'] as List<String>;
      if (emotions.contains(emotion)) {
        return category['color'] as String;
      }
    }
    
    return '#95A5A6'; // Default gray
  }
}
