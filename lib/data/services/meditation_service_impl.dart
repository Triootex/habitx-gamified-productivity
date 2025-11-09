import 'package:injectable/injectable.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/meditation_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class MeditationService {
  Future<List<MeditationSessionEntity>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<MeditationSessionEntity> startSession(String userId, Map<String, dynamic> sessionData);
  Future<MeditationSessionEntity> endSession(String sessionId, Map<String, dynamic> completionData);
  Future<bool> logDistraction(String sessionId, Map<String, dynamic> distractionData);
  Future<Map<String, dynamic>> getPersonalizedRecommendations(String userId);
  Future<Map<String, String>> generateCustomSoundscape(String userId, String mood, List<String> preferences);
  Future<Map<String, dynamic>> getSessionAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<Map<String, dynamic>>> getBreathingExercises(String difficulty);
  Future<bool> updateSessionMood(String sessionId, int moodBefore, int moodAfter);
  Future<Map<String, dynamic>> generateSessionInsights(String sessionId);
}

@LazySingleton(as: MeditationService)
class MeditationServiceImpl implements MeditationService {
  @override
  Future<List<MeditationSessionEntity>> getUserSessions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final mockSessions = _generateMockSessions(userId);
      
      if (startDate != null || endDate != null) {
        final start = startDate ?? DateTime.now().subtract(const Duration(days: 365));
        final end = endDate ?? DateTime.now();
        
        return mockSessions.where((session) {
          return session.startTime.isAfter(start) && session.startTime.isBefore(end);
        }).toList();
      }
      
      return mockSessions;
    } catch (e) {
      throw Exception('Failed to retrieve meditation sessions: ${e.toString()}');
    }
  }

  @override
  Future<MeditationSessionEntity> startSession(String userId, Map<String, dynamic> sessionData) async {
    try {
      final now = DateTime.now();
      final sessionId = 'meditation_${now.millisecondsSinceEpoch}';
      
      // Generate personalized settings based on user history
      final personalizedSettings = await _generatePersonalizedSettings(userId);
      
      final session = MeditationSessionEntity(
        id: sessionId,
        userId: userId,
        technique: sessionData['technique'] as String? ?? 'mindfulness',
        guidedSessionId: sessionData['guided_session_id'] as String?,
        startTime: now,
        plannedDurationMinutes: sessionData['duration'] as int? ?? 10,
        location: sessionData['location'] as String?,
        environment: sessionData['environment'] as String? ?? 'quiet',
        soundscapeId: sessionData['soundscape_id'] as String?,
        activeSounds: (sessionData['active_sounds'] as List<dynamic>?)?.cast<String>() ?? [],
        usedBinauralBeats: sessionData['use_binaural_beats'] as bool? ?? false,
        binauralFrequency: sessionData['binaural_frequency'] as String?,
        breathingPattern: sessionData['breathing_pattern'] as String?,
        usedTimer: sessionData['use_timer'] as bool? ?? true,
        treeType: personalizedSettings['tree_type'] as String?,
        createdAt: now,
      );
      
      return session;
    } catch (e) {
      throw Exception('Failed to start meditation session: ${e.toString()}');
    }
  }

  @override
  Future<MeditationSessionEntity> endSession(String sessionId, Map<String, dynamic> completionData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final now = DateTime.now();
      final actualDuration = now.difference(session.startTime);
      
      // Calculate session quality score
      final qualityScore = MeditationUtils.calculateSessionQuality(
        plannedDuration: session.plannedDurationMinutes,
        actualDuration: actualDuration.inMinutes,
        distractionsCount: session.distractionsCount,
        completionRate: completionData['completion_rate'] as double? ?? 1.0,
        focusRating: completionData['focus_rating'] as double? ?? 5.0,
      );
      
      // Calculate XP earned
      final xpEarned = _calculateMeditationXP(
        actualDuration.inMinutes,
        qualityScore,
        session.technique,
      );
      
      // Determine tree growth
      final treeGrowthPoints = _calculateTreeGrowth(actualDuration.inMinutes, qualityScore);
      final treeStage = _determineTreeStage(treeGrowthPoints);
      
      final completedSession = session.copyWith(
        endTime: now,
        actualDurationMinutes: actualDuration.inMinutes,
        wasCompleted: completionData['was_completed'] as bool? ?? true,
        qualityScore: qualityScore,
        focusRating: completionData['focus_rating'] as double? ?? 5.0,
        moodAfter: completionData['mood_after'] as int?,
        energyLevelAfter: completionData['energy_after'] as int?,
        xpEarned: xpEarned,
        treeGrowthPoints: treeGrowthPoints,
        treeStage: treeStage,
        treeFullyGrown: treeStage == 'mature',
        sessionNotes: completionData['notes'] as String?,
        insights: (completionData['insights'] as List<dynamic>?)?.cast<String>() ?? [],
        updatedAt: now,
      );
      
      // Award XP to user
      await _awardMeditationXP(session.userId, xpEarned);
      
      // Check for achievements
      await _checkMeditationAchievements(session.userId, completedSession);
      
      return completedSession;
    } catch (e) {
      throw Exception('Failed to end meditation session: ${e.toString()}');
    }
  }

  @override
  Future<bool> logDistraction(String sessionId, Map<String, dynamic> distractionData) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final now = DateTime.now();
      final distraction = DistractionLogEntity(
        id: 'distraction_${now.millisecondsSinceEpoch}',
        sessionId: sessionId,
        timestamp: now,
        type: distractionData['type'] as String,
        description: distractionData['description'] as String?,
        intensity: distractionData['intensity'] as int? ?? 1,
        durationSeconds: distractionData['duration_seconds'] as int? ?? 0,
        response: distractionData['response'] as String?,
      );
      
      // Update session with new distraction
      final updatedDistractions = List<DistractionLogEntity>.from(session.distractions)
        ..add(distraction);
      
      final updatedSession = session.copyWith(
        distractions: updatedDistractions,
        distractionsCount: updatedDistractions.length,
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to log distraction: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPersonalizedRecommendations(String userId) async {
    try {
      final userSessions = await getUserSessions(userId);
      
      return MeditationUtils.generatePersonalizedRecommendations(
        userId: userId,
        recentSessions: userSessions.take(10).toList(),
        userPreferences: await _getUserPreferences(userId),
        currentMood: 'neutral', // Mock current mood
        availableTime: 15, // Mock available time
      );
    } catch (e) {
      throw Exception('Failed to get personalized recommendations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>> generateCustomSoundscape(String userId, String mood, List<String> preferences) async {
    try {
      return MeditationUtils.createCustomASMRMix(
        baseCategory: mood,
        userPreferences: preferences,
        sessionDuration: 10, // Mock duration
        moodContext: mood,
      );
    } catch (e) {
      throw Exception('Failed to generate custom soundscape: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getSessionAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final sessions = await getUserSessions(userId, startDate: startDate, endDate: endDate);
      
      if (sessions.isEmpty) {
        return {
          'total_sessions': 0,
          'total_time': 0,
          'average_quality': 0.0,
          'streak': 0,
        };
      }
      
      final totalSessions = sessions.length;
      final totalTime = sessions.fold<int>(0, (sum, session) => sum + session.actualDurationMinutes);
      final averageQuality = sessions.fold<double>(0, (sum, session) => sum + session.qualityScore) / sessions.length;
      
      // Calculate current streak
      final streak = _calculateMeditationStreak(sessions);
      
      // Technique breakdown
      final techniqueBreakdown = <String, int>{};
      for (final session in sessions) {
        techniqueBreakdown[session.technique] = (techniqueBreakdown[session.technique] ?? 0) + 1;
      }
      
      // Quality trends over time
      final qualityTrends = sessions.map((session) => {
        'date': DateUtils.formatDate(session.startTime, 'yyyy-MM-dd'),
        'quality': session.qualityScore,
        'duration': session.actualDurationMinutes,
      }).toList();
      
      // Mood improvement analysis
      final moodImprovements = sessions.where((s) => s.moodBefore != null && s.moodAfter != null)
          .map((s) => s.moodAfter! - s.moodBefore!)
          .toList();
      
      final averageMoodImprovement = moodImprovements.isEmpty ? 0.0 :
          moodImprovements.reduce((a, b) => a + b) / moodImprovements.length;
      
      return {
        'period': {
          'start': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
          'end': (endDate ?? DateTime.now()).toIso8601String(),
        },
        'summary': {
          'total_sessions': totalSessions,
          'total_time_minutes': totalTime,
          'average_session_length': totalSessions > 0 ? totalTime / totalSessions : 0,
          'average_quality': averageQuality,
          'current_streak': streak,
        },
        'breakdown': {
          'by_technique': techniqueBreakdown,
          'quality_distribution': _getQualityDistribution(sessions),
          'time_of_day': _getTimeOfDayBreakdown(sessions),
        },
        'trends': {
          'quality_over_time': qualityTrends,
          'average_mood_improvement': averageMoodImprovement,
        },
        'insights': _generateMeditationInsights(sessions),
      };
    } catch (e) {
      throw Exception('Failed to get session analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBreathingExercises(String difficulty) async {
    try {
      return MeditationUtils.generateBreathingGuide(
        pattern: _getBreathingPatternForDifficulty(difficulty),
        duration: 5, // Mock duration
        includeVisualCues: true,
        includeAudioCues: false,
      );
    } catch (e) {
      throw Exception('Failed to get breathing exercises: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateSessionMood(String sessionId, int moodBefore, int moodAfter) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final updatedSession = session.copyWith(
        moodBefore: moodBefore,
        moodAfter: moodAfter,
        updatedAt: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to update session mood: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateSessionInsights(String sessionId) async {
    try {
      final session = await _getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      final insights = <String>[];
      final recommendations = <String>[];
      
      // Quality insights
      if (session.qualityScore >= 8.0) {
        insights.add('Excellent session! Your focus and consistency are improving.');
      } else if (session.qualityScore >= 6.0) {
        insights.add('Good session overall. Keep practicing to deepen your meditation.');
      } else {
        insights.add('Every session is progress. Consider shorter sessions to build consistency.');
        recommendations.add('Try a 5-minute session tomorrow to maintain momentum.');
      }
      
      // Distraction insights
      if (session.distractionsCount == 0) {
        insights.add('Amazing focus! No distractions logged during this session.');
      } else if (session.distractionsCount <= 2) {
        insights.add('Good focus with minimal distractions. This is normal for developing practice.');
      } else {
        insights.add('Many distractions noticed. This awareness is actually progress in mindfulness!');
        recommendations.add('Try meditation in a quieter space or with noise-canceling headphones.');
      }
      
      // Mood insights
      if (session.moodBefore != null && session.moodAfter != null) {
        final moodImprovement = session.moodAfter! - session.moodBefore!;
        if (moodImprovement > 0) {
          insights.add('Great mood improvement! Meditation helped you feel ${moodImprovement} points better.');
        } else if (moodImprovement == 0) {
          insights.add('Mood remained stable. Sometimes maintenance is just as valuable as improvement.');
        }
      }
      
      // Tree growth insights
      if (session.treeFullyGrown) {
        insights.add('🌳 Your virtual tree has fully grown! This represents your growing meditation practice.');
      } else if (session.treeGrowthPoints > 0) {
        insights.add('🌱 Your meditation tree grew during this session. Keep nurturing your practice!');
      }
      
      return {
        'session_id': sessionId,
        'quality_score': session.qualityScore,
        'insights': insights,
        'recommendations': recommendations,
        'next_session_suggestions': _getNextSessionSuggestions(session),
        'progress_indicators': {
          'focus_improvement': session.qualityScore > 6.0,
          'consistency_building': session.actualDurationMinutes >= session.plannedDurationMinutes * 0.8,
          'mindfulness_developing': session.distractionsCount <= 3,
        },
      };
    } catch (e) {
      throw Exception('Failed to generate session insights: ${e.toString()}');
    }
  }

  // Private helper methods
  List<MeditationSessionEntity> _generateMockSessions(String userId) {
    final now = DateTime.now();
    
    return [
      MeditationSessionEntity(
        id: 'meditation_1',
        userId: userId,
        technique: 'mindfulness',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1)).add(const Duration(minutes: 15)),
        plannedDurationMinutes: 15,
        actualDurationMinutes: 15,
        wasCompleted: true,
        qualityScore: 7.5,
        focusRating: 8.0,
        distractionsCount: 1,
        moodBefore: 6,
        moodAfter: 8,
        environment: 'quiet',
        treeType: 'oak',
        treeGrowthPoints: 15.0,
        treeStage: 'sapling',
        xpEarned: 25,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MeditationSessionEntity(
        id: 'meditation_2',
        userId: userId,
        technique: 'loving_kindness',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2)).add(const Duration(minutes: 10)),
        plannedDurationMinutes: 10,
        actualDurationMinutes: 10,
        wasCompleted: true,
        qualityScore: 6.0,
        focusRating: 6.5,
        distractionsCount: 3,
        moodBefore: 5,
        moodAfter: 7,
        environment: 'music',
        treeType: 'cherry',
        treeGrowthPoints: 10.0,
        treeStage: 'sprout',
        xpEarned: 18,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<MeditationSessionEntity?> _getSessionById(String sessionId) async {
    final mockSessions = _generateMockSessions('user_id');
    try {
      return mockSessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _generatePersonalizedSettings(String userId) async {
    // Mock personalized settings based on user history
    return {
      'preferred_duration': 15,
      'preferred_technique': 'mindfulness',
      'tree_type': 'oak',
      'recommended_environment': 'quiet',
    };
  }

  Future<Map<String, dynamic>> _getUserPreferences(String userId) async {
    // Mock user preferences
    return {
      'preferred_techniques': ['mindfulness', 'breathing'],
      'preferred_duration': 15,
      'preferred_times': ['morning'],
      'environment_preferences': ['quiet', 'nature_sounds'],
    };
  }

  int _calculateMeditationXP(int durationMinutes, double qualityScore, String technique) {
    int baseXP = durationMinutes; // 1 XP per minute
    
    // Quality bonus
    if (qualityScore >= 8.0) {
      baseXP = (baseXP * 1.5).round();
    } else if (qualityScore >= 6.0) {
      baseXP = (baseXP * 1.2).round();
    }
    
    // Technique bonus
    final techniqueMultipliers = {
      'mindfulness': 1.0,
      'concentration': 1.1,
      'loving_kindness': 1.1,
      'body_scan': 1.0,
      'breathing': 0.9,
    };
    
    final multiplier = techniqueMultipliers[technique] ?? 1.0;
    baseXP = (baseXP * multiplier).round();
    
    return baseXP;
  }

  double _calculateTreeGrowth(int durationMinutes, double qualityScore) {
    // Base growth is proportional to duration
    double growth = durationMinutes.toDouble();
    
    // Quality multiplier
    growth *= (qualityScore / 10.0);
    
    return growth;
  }

  String _determineTreeStage(double totalGrowthPoints) {
    if (totalGrowthPoints >= 1000) return 'mature';
    if (totalGrowthPoints >= 500) return 'tree';
    if (totalGrowthPoints >= 200) return 'sapling';
    if (totalGrowthPoints >= 50) return 'sprout';
    return 'seed';
  }

  Future<void> _awardMeditationXP(String userId, int xpAmount) async {
    print('Awarded $xpAmount XP to user $userId for meditation');
  }

  Future<void> _checkMeditationAchievements(String userId, MeditationSessionEntity session) async {
    // Check for meditation-specific achievements
    if (session.actualDurationMinutes >= 30) {
      print('Achievement unlocked: Long meditation session');
    }
    
    if (session.qualityScore >= 9.0) {
      print('Achievement unlocked: Excellent meditation quality');
    }
  }

  int _calculateMeditationStreak(List<MeditationSessionEntity> sessions) {
    if (sessions.isEmpty) return 0;
    
    final sortedSessions = sessions.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final session in sortedSessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      
      if (lastDate == null) {
        lastDate = sessionDate;
        streak = 1;
      } else if (sessionDate.difference(lastDate).inDays == -1) {
        streak++;
        lastDate = sessionDate;
      } else if (sessionDate.difference(lastDate).inDays == 0) {
        // Same day, don't break streak
        continue;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Map<String, int> _getQualityDistribution(List<MeditationSessionEntity> sessions) {
    final distribution = <String, int>{
      'excellent': 0, // 8.0+
      'good': 0,      // 6.0-7.9
      'fair': 0,      // 4.0-5.9
      'poor': 0,      // <4.0
    };
    
    for (final session in sessions) {
      if (session.qualityScore >= 8.0) {
        distribution['excellent'] = distribution['excellent']! + 1;
      } else if (session.qualityScore >= 6.0) {
        distribution['good'] = distribution['good']! + 1;
      } else if (session.qualityScore >= 4.0) {
        distribution['fair'] = distribution['fair']! + 1;
      } else {
        distribution['poor'] = distribution['poor']! + 1;
      }
    }
    
    return distribution;
  }

  Map<String, int> _getTimeOfDayBreakdown(List<MeditationSessionEntity> sessions) {
    final breakdown = <String, int>{
      'morning': 0,   // 5-12
      'afternoon': 0, // 12-17
      'evening': 0,   // 17-21
      'night': 0,     // 21-5
    };
    
    for (final session in sessions) {
      final hour = session.startTime.hour;
      if (hour >= 5 && hour < 12) {
        breakdown['morning'] = breakdown['morning']! + 1;
      } else if (hour >= 12 && hour < 17) {
        breakdown['afternoon'] = breakdown['afternoon']! + 1;
      } else if (hour >= 17 && hour < 21) {
        breakdown['evening'] = breakdown['evening']! + 1;
      } else {
        breakdown['night'] = breakdown['night']! + 1;
      }
    }
    
    return breakdown;
  }

  String _getBreathingPatternForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '4-4-4-4'; // Equal breathing
      case 'intermediate':
        return '4-7-8'; // Relaxing breath
      case 'advanced':
        return '6-2-6-2'; // Extended breath
      default:
        return '4-4-4-4';
    }
  }

  List<String> _generateMeditationInsights(List<MeditationSessionEntity> sessions) {
    final insights = <String>[];
    
    if (sessions.isEmpty) {
      insights.add('Start your meditation journey! Even 5 minutes daily can make a difference.');
      return insights;
    }
    
    final averageQuality = sessions.fold<double>(0, (sum, s) => sum + s.qualityScore) / sessions.length;
    
    if (averageQuality >= 8.0) {
      insights.add('Excellent meditation practice! Your consistency is paying off.');
    } else if (averageQuality >= 6.0) {
      insights.add('Good progress in your meditation journey. Keep up the regular practice.');
    } else {
      insights.add('Remember, meditation is a practice. Be patient and kind with yourself.');
    }
    
    // Check for consistency
    if (sessions.length >= 7) {
      insights.add('Great consistency! Regular meditation practice strengthens mindfulness.');
    }
    
    // Check for mood improvements
    final sessionsWithMood = sessions.where((s) => s.moodBefore != null && s.moodAfter != null).toList();
    if (sessionsWithMood.isNotEmpty) {
      final avgMoodImprovement = sessionsWithMood
          .map((s) => s.moodAfter! - s.moodBefore!)
          .reduce((a, b) => a + b) / sessionsWithMood.length;
      
      if (avgMoodImprovement > 1.0) {
        insights.add('Meditation is consistently improving your mood. Notice this positive pattern!');
      }
    }
    
    return insights;
  }

  List<String> _getNextSessionSuggestions(MeditationSessionEntity session) {
    final suggestions = <String>[];
    
    if (session.qualityScore < 6.0) {
      suggestions.add('Try a shorter session (5-10 minutes) to build consistency');
      suggestions.add('Focus on just following your breath');
    } else if (session.qualityScore >= 8.0) {
      suggestions.add('Consider extending your next session by 5 minutes');
      suggestions.add('Try a new meditation technique');
    }
    
    if (session.distractionsCount > 3) {
      suggestions.add('Find a quieter space for your next session');
      suggestions.add('Try using background sounds or music');
    }
    
    suggestions.add('Same time tomorrow works well for building habits');
    
    return suggestions;
  }
}
