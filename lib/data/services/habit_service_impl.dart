import 'package:injectable/injectable.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/habits_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';

abstract class HabitService {
  Future<List<HabitEntity>> getUserHabits(String userId, {bool? isActive});
  Future<HabitEntity> createHabit(String userId, Map<String, dynamic> habitData);
  Future<HabitEntity> updateHabit(String habitId, Map<String, dynamic> updates);
  Future<bool> logHabitCompletion(String habitId, Map<String, dynamic> logData);
  Future<bool> deleteHabit(String habitId);
  Future<List<HabitEntity>> getHabitsForToday(String userId);
  Future<Map<String, dynamic>> getHabitAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<String>> generateHabitSuggestions(String userId, String category);
  Future<Map<String, dynamic>> calculateHabitStreak(String habitId);
  Future<List<HabitEntity>> getHabitsByCategory(String userId, String category);
  Future<bool> syncWithHealthApp(String userId, String habitId);
}

@LazySingleton(as: HabitService)
class HabitServiceImpl implements HabitService {
  @override
  Future<List<HabitEntity>> getUserHabits(String userId, {bool? isActive}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      final mockHabits = _generateMockHabits(userId);
      
      if (isActive != null) {
        return mockHabits.where((habit) => habit.isActive == isActive).toList();
      }
      
      return mockHabits;
    } catch (e) {
      throw Exception('Failed to retrieve habits: ${e.toString()}');
    }
  }

  @override
  Future<HabitEntity> createHabit(String userId, Map<String, dynamic> habitData) async {
    try {
      // Validate habit data
      final validation = _validateHabitData(habitData);
      if (validation.isNotEmpty) {
        throw Exception('Validation failed: ${validation.values.first}');
      }
      
      final now = DateTime.now();
      final habitId = 'habit_${now.millisecondsSinceEpoch}';
      
      // Calculate XP per completion based on difficulty and frequency
      final xpPerCompletion = _calculateHabitXP(habitData);
      
      final habit = HabitEntity(
        id: habitId,
        userId: userId,
        name: habitData['name'] as String,
        description: habitData['description'] as String?,
        category: habitData['category'] as String,
        type: habitData['type'] as String? ?? 'positive',
        trackingType: habitData['tracking_type'] as String? ?? 'boolean',
        frequency: habitData['frequency'] as String? ?? 'daily',
        targetValue: habitData['target_value'] as double?,
        unit: habitData['unit'] as String?,
        scheduledDays: (habitData['scheduled_days'] as List<dynamic>?)?.cast<int>() ?? [],
        preferredTime: habitData['preferred_time'] as String?,
        reminders: (habitData['reminders'] as List<dynamic>?)?.cast<String>() ?? [],
        xpPerCompletion: xpPerCompletion,
        createdAt: now,
      );
      
      return habit;
    } catch (e) {
      throw Exception('Failed to create habit: ${e.toString()}');
    }
  }

  @override
  Future<HabitEntity> updateHabit(String habitId, Map<String, dynamic> updates) async {
    try {
      final existingHabit = await _getHabitById(habitId);
      if (existingHabit == null) {
        throw Exception('Habit not found');
      }
      
      final updatedHabit = existingHabit.copyWith(
        name: updates['name'] as String? ?? existingHabit.name,
        description: updates['description'] as String?,
        category: updates['category'] as String? ?? existingHabit.category,
        targetValue: updates['target_value'] as double? ?? existingHabit.targetValue,
        scheduledDays: (updates['scheduled_days'] as List<dynamic>?)?.cast<int>() ?? existingHabit.scheduledDays,
        reminders: (updates['reminders'] as List<dynamic>?)?.cast<String>() ?? existingHabit.reminders,
        isActive: updates['is_active'] as bool? ?? existingHabit.isActive,
        updatedAt: DateTime.now(),
      );
      
      return updatedHabit;
    } catch (e) {
      throw Exception('Failed to update habit: ${e.toString()}');
    }
  }

  @override
  Future<bool> logHabitCompletion(String habitId, Map<String, dynamic> logData) async {
    try {
      final habit = await _getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }
      
      final now = DateTime.now();
      final dateKey = DateUtils.formatDate(now, 'yyyy-MM-dd');
      
      // Create habit log entry
      final logEntry = HabitLogEntity(
        id: 'log_${habitId}_${now.millisecondsSinceEpoch}',
        habitId: habitId,
        userId: habit.userId,
        date: now,
        isCompleted: logData['is_completed'] as bool? ?? true,
        value: logData['value'] as double? ?? 0.0,
        durationMinutes: logData['duration_minutes'] as int? ?? 0,
        notes: logData['notes'] as String?,
        moodBefore: logData['mood_before'] as double?,
        moodAfter: logData['mood_after'] as double?,
        energyLevel: logData['energy_level'] as int?,
        motivationLevel: logData['motivation_level'] as int?,
        location: logData['location'] as String?,
        tags: (logData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: now,
      );
      
      // Update habit with new log
      final updatedLogs = Map<String, HabitLogEntity>.from(habit.logs);
      updatedLogs[dateKey] = logEntry;
      
      // Recalculate streak and strength
      final newStreak = _calculateStreak(updatedLogs);
      final newStrength = HabitsUtils.calculateHabitStrength(
        currentStreak: newStreak,
        totalCompletions: habit.totalCompletions + 1,
        createdDaysAgo: DateTime.now().difference(habit.createdAt).inDays,
      );
      
      // Award XP
      final xpEarned = HabitsUtils.calculateXPReward(
        habit: habit,
        currentStreak: newStreak,
        completionQuality: _calculateCompletionQuality(logEntry),
      );
      
      await _awardHabitXP(habit.userId, xpEarned);
      
      // Check for milestones
      await _checkHabitMilestones(habit, newStreak);
      
      return true;
    } catch (e) {
      throw Exception('Failed to log habit completion: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteHabit(String habitId) async {
    try {
      final habit = await _getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }
      
      // In real implementation, this would delete from database
      return true;
    } catch (e) {
      throw Exception('Failed to delete habit: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsForToday(String userId) async {
    try {
      final habits = await getUserHabits(userId, isActive: true);
      final today = DateTime.now().weekday;
      
      return habits.where((habit) {
        // Check if habit is scheduled for today
        if (habit.scheduledDays.isEmpty) {
          return true; // Daily habit
        }
        return habit.scheduledDays.contains(today);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get habits for today: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getHabitAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final habits = await getUserHabits(userId);
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      // Calculate overall statistics
      final totalHabits = habits.length;
      final activeHabits = habits.where((h) => h.isActive).length;
      final averageStreak = habits.isEmpty ? 0.0 : 
          habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length;
      
      // Completion rate analysis
      final completionRates = <String, double>{};
      final streakData = <String, int>{};
      
      for (final habit in habits) {
        final completedDays = habit.logs.values.where((log) => log.isCompleted).length;
        final totalDays = end.difference(start).inDays + 1;
        completionRates[habit.name] = totalDays > 0 ? completedDays / totalDays : 0.0;
        streakData[habit.name] = habit.currentStreak;
      }
      
      // Category breakdown
      final categoryBreakdown = <String, int>{};
      for (final habit in habits) {
        categoryBreakdown[habit.category] = (categoryBreakdown[habit.category] ?? 0) + 1;
      }
      
      // Best and worst performing habits
      final sortedByCompletion = completionRates.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return {
        'period': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
        'summary': {
          'total_habits': totalHabits,
          'active_habits': activeHabits,
          'average_streak': averageStreak.round(),
          'total_completions': habits.fold<int>(0, (sum, h) => sum + h.totalCompletions),
        },
        'completion_rates': completionRates,
        'streaks': streakData,
        'category_breakdown': categoryBreakdown,
        'best_habits': sortedByCompletion.take(5).map((e) => {
          'name': e.key,
          'completion_rate': e.value,
        }).toList(),
        'insights': _generateHabitInsights(habits),
      };
    } catch (e) {
      throw Exception('Failed to get habit analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateHabitSuggestions(String userId, String category) async {
    try {
      return HabitsUtils.generateHabitSuggestions(
        category: category,
        userLevel: 5, // Mock user level
        currentHabits: [], // Mock current habits
      );
    } catch (e) {
      throw Exception('Failed to generate habit suggestions: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateHabitStreak(String habitId) async {
    try {
      final habit = await _getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }
      
      final currentStreak = _calculateStreak(habit.logs);
      final longestStreak = _calculateLongestStreak(habit.logs);
      
      return {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'streak_strength': habit.habitStrength,
        'next_milestone': _getNextStreakMilestone(currentStreak),
        'streak_history': _getStreakHistory(habit.logs),
      };
    } catch (e) {
      throw Exception('Failed to calculate habit streak: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsByCategory(String userId, String category) async {
    try {
      final habits = await getUserHabits(userId);
      return habits.where((habit) => habit.category == category).toList();
    } catch (e) {
      throw Exception('Failed to get habits by category: ${e.toString()}');
    }
  }

  @override
  Future<bool> syncWithHealthApp(String userId, String habitId) async {
    try {
      final habit = await _getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }
      
      // Mock health app sync
      if (habit.syncWithHealthApp) {
        // Simulate syncing with health data
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Mock retrieving health data
        final healthData = await _getHealthData(habit.healthMetric);
        
        if (healthData != null) {
          // Create automatic log entry based on health data
          await logHabitCompletion(habitId, {
            'is_completed': healthData['completed'] as bool,
            'value': healthData['value'] as double,
            'notes': 'Synced from health app',
          });
        }
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to sync with health app: ${e.toString()}');
    }
  }

  // Private helper methods
  List<HabitEntity> _generateMockHabits(String userId) {
    final now = DateTime.now();
    
    return [
      HabitEntity(
        id: 'habit_1',
        userId: userId,
        name: 'Drink 8 glasses of water',
        description: 'Stay hydrated throughout the day',
        category: 'Health',
        trackingType: 'numeric',
        targetValue: 8.0,
        unit: 'glasses',
        currentStreak: 5,
        longestStreak: 12,
        habitStrength: 0.7,
        xpPerCompletion: 10,
        totalXpEarned: 150,
        scheduledDays: [1, 2, 3, 4, 5, 6, 7], // Daily
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      HabitEntity(
        id: 'habit_2',
        userId: userId,
        name: 'Morning meditation',
        description: '10 minutes of mindfulness meditation',
        category: 'Wellness',
        trackingType: 'duration',
        targetValue: 10.0,
        unit: 'minutes',
        currentStreak: 3,
        longestStreak: 8,
        habitStrength: 0.4,
        xpPerCompletion: 15,
        totalXpEarned: 90,
        scheduledDays: [1, 2, 3, 4, 5], // Weekdays
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      HabitEntity(
        id: 'habit_3',
        userId: userId,
        name: 'Read for 30 minutes',
        description: 'Daily reading habit',
        category: 'Learning',
        trackingType: 'duration',
        targetValue: 30.0,
        unit: 'minutes',
        currentStreak: 8,
        longestStreak: 15,
        habitStrength: 0.8,
        xpPerCompletion: 20,
        totalXpEarned: 200,
        scheduledDays: [1, 2, 3, 4, 5, 6, 7], // Daily
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  Future<HabitEntity?> _getHabitById(String habitId) async {
    final mockHabits = _generateMockHabits('user_id');
    try {
      return mockHabits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  Map<String, String?> _validateHabitData(Map<String, dynamic> data) {
    final errors = <String, String?>{};
    
    if (data['name'] == null || (data['name'] as String).trim().isEmpty) {
      errors['name'] = 'Habit name is required';
    }
    
    if (data['category'] == null || (data['category'] as String).trim().isEmpty) {
      errors['category'] = 'Category is required';
    }
    
    final trackingType = data['tracking_type'] as String?;
    if (trackingType == 'numeric' || trackingType == 'duration') {
      if (data['target_value'] == null || (data['target_value'] as double) <= 0) {
        errors['target_value'] = 'Target value is required for numeric/duration tracking';
      }
    }
    
    return errors;
  }

  int _calculateHabitXP(Map<String, dynamic> habitData) {
    final frequency = habitData['frequency'] as String? ?? 'daily';
    final trackingType = habitData['tracking_type'] as String? ?? 'boolean';
    
    int baseXP = 10;
    
    // Adjust for frequency
    switch (frequency) {
      case 'daily':
        baseXP = 10;
        break;
      case 'weekly':
        baseXP = 15;
        break;
      case 'monthly':
        baseXP = 25;
        break;
    }
    
    // Adjust for tracking complexity
    switch (trackingType) {
      case 'boolean':
        break; // No adjustment
      case 'numeric':
      case 'duration':
        baseXP += 5;
        break;
      case 'custom':
        baseXP += 10;
        break;
    }
    
    return baseXP;
  }

  int _calculateStreak(Map<String, HabitLogEntity> logs) {
    if (logs.isEmpty) return 0;
    
    final today = DateTime.now();
    final dateKeys = <String>[];
    
    // Generate date keys for the last 365 days
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      dateKeys.add(DateUtils.formatDate(date, 'yyyy-MM-dd'));
    }
    
    int streak = 0;
    for (final dateKey in dateKeys) {
      final log = logs[dateKey];
      if (log != null && log.isCompleted) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _calculateLongestStreak(Map<String, HabitLogEntity> logs) {
    if (logs.isEmpty) return 0;
    
    final sortedLogs = logs.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final log in sortedLogs) {
      if (log.isCompleted) {
        if (lastDate == null || log.date.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        longestStreak = math.max(longestStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
      lastDate = log.date;
    }
    
    return longestStreak;
  }

  double _calculateCompletionQuality(HabitLogEntity log) {
    double quality = 1.0;
    
    // Factor in mood improvement
    if (log.moodBefore != null && log.moodAfter != null) {
      final moodImprovement = log.moodAfter! - log.moodBefore!;
      quality += moodImprovement * 0.1;
    }
    
    // Factor in energy and motivation levels
    if (log.energyLevel != null) {
      quality += (log.energyLevel! - 3) * 0.1; // Baseline is 3
    }
    
    if (log.motivationLevel != null) {
      quality += (log.motivationLevel! - 3) * 0.1;
    }
    
    return quality.clamp(0.5, 2.0);
  }

  Future<void> _awardHabitXP(String userId, int xpAmount) async {
    // Mock XP awarding
    print('Awarded $xpAmount XP to user $userId for habit completion');
  }

  Future<void> _checkHabitMilestones(HabitEntity habit, int newStreak) async {
    final milestones = [7, 14, 30, 60, 100, 365];
    
    for (final milestone in milestones) {
      if (newStreak == milestone && !habit.milestones.contains('$milestone-day-streak')) {
        // Award milestone achievement
        await _awardMilestone(habit.userId, habit.id, milestone);
      }
    }
  }

  Future<void> _awardMilestone(String userId, String habitId, int milestone) async {
    print('Milestone achieved: $milestone-day streak for habit $habitId');
  }

  int _getNextStreakMilestone(int currentStreak) {
    final milestones = [7, 14, 30, 60, 100, 365];
    return milestones.firstWhere((m) => m > currentStreak, orElse: () => currentStreak + 30);
  }

  List<Map<String, dynamic>> _getStreakHistory(Map<String, HabitLogEntity> logs) {
    // Generate streak history over time
    final history = <Map<String, dynamic>>[];
    final sortedLogs = logs.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    int currentStreak = 0;
    for (final log in sortedLogs) {
      if (log.isCompleted) {
        currentStreak++;
      } else {
        currentStreak = 0;
      }
      
      history.add({
        'date': log.date.toIso8601String(),
        'streak': currentStreak,
        'completed': log.isCompleted,
      });
    }
    
    return history.take(30).toList(); // Last 30 days
  }

  Future<Map<String, dynamic>?> _getHealthData(String? healthMetric) async {
    if (healthMetric == null) return null;
    
    // Mock health data retrieval
    switch (healthMetric) {
      case 'steps':
        return {
          'completed': true,
          'value': 8500.0,
          'target': 10000.0,
        };
      case 'sleep':
        return {
          'completed': true,
          'value': 7.5,
          'target': 8.0,
        };
      default:
        return null;
    }
  }

  List<String> _generateHabitInsights(List<HabitEntity> habits) {
    final insights = <String>[];
    
    if (habits.isEmpty) {
      insights.add('Start building habits to improve your daily routine!');
      return insights;
    }
    
    final averageStrength = habits.isEmpty ? 0.0 : 
        habits.map((h) => h.habitStrength).reduce((a, b) => a + b) / habits.length;
    
    if (averageStrength > 0.8) {
      insights.add('Excellent habit strength! Your routines are becoming automatic.');
    } else if (averageStrength > 0.6) {
      insights.add('Good progress on habit formation. Keep up the consistency!');
    } else {
      insights.add('Focus on consistency to strengthen your habits. Small daily actions compound!');
    }
    
    // Check for long streaks
    final maxStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce(math.max);
    if (maxStreak >= 30) {
      insights.add('Amazing! You have a 30+ day streak. That\'s the power of consistency!');
    } else if (maxStreak >= 7) {
      insights.add('Great job maintaining a week-long streak! Keep the momentum going.');
    }
    
    // Category insights
    final categories = habits.map((h) => h.category).toSet();
    if (categories.length >= 3) {
      insights.add('Great variety! You\'re building habits across multiple life areas.');
    }
    
    return insights;
  }
}
