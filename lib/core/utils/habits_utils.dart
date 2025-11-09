import '../constants/habits_constants.dart';
import 'date_utils.dart';
import 'math_utils.dart';

class HabitsUtils {
  /// Calculate habit strength using custom formula
  static double calculateHabitStrength(
    int streak,
    int totalCompletions,
    int totalDays,
    String difficulty,
  ) {
    if (totalDays == 0) return HabitsConstants.baseStrength;
    
    final consistencyRate = totalCompletions / totalDays;
    final streakBonus = (streak * HabitsConstants.streakMultiplier).clamp(0, 2.0);
    final difficultyMultiplier = HabitsConstants.difficultyMultipliers[difficulty] ?? 1.0;
    
    double strength = HabitsConstants.baseStrength +
        (consistencyRate * HabitsConstants.consistencyBonus) +
        streakBonus;
    
    return (strength * difficultyMultiplier).clamp(0, 5.0);
  }
  
  /// Calculate XP reward for habit completion
  static int calculateHabitXP(
    String habitType,
    String difficulty,
    int currentStreak,
    bool isPremium,
  ) {
    final baseXP = HabitsConstants.baseXpRewards[habitType] ?? 10;
    final difficultyMultiplier = HabitsConstants.difficultyMultipliers[difficulty] ?? 1.0;
    final streakMultiplier = MathUtils.calculateStreakMultiplier(currentStreak);
    
    int xp = (baseXP * difficultyMultiplier * streakMultiplier).round();
    
    if (isPremium) {
      xp = (xp * 1.5).round(); // Premium bonus
    }
    
    return xp;
  }
  
  /// Generate habit suggestions based on category and user data
  static List<Map<String, dynamic>> generateHabitSuggestions(
    String category,
    Map<String, dynamic> userProfile,
  ) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Find templates for the category
    final categoryTemplate = HabitsConstants.habitTemplates
        .firstWhere((template) => template['category'] == category,
            orElse: () => <String, dynamic>{});
    
    if (categoryTemplate.isNotEmpty) {
      final habits = categoryTemplate['habits'] as List<Map<String, dynamic>>? ?? [];
      
      for (final habit in habits) {
        suggestions.add({
          'name': habit['name'],
          'type': habit['type'],
          'target': habit['target'],
          'difficulty': _suggestDifficulty(habit['name'], userProfile),
          'frequency': HabitsConstants.daily,
          'category': category,
        });
      }
    }
    
    return suggestions;
  }
  
  static String _suggestDifficulty(String habitName, Map<String, dynamic> userProfile) {
    final fitnessLevel = userProfile['fitness_level'] as String? ?? 'beginner';
    
    if (habitName.toLowerCase().contains('exercise') || 
        habitName.toLowerCase().contains('workout')) {
      return fitnessLevel == 'advanced' ? 'hard' : 'medium';
    }
    
    return 'easy'; // Default to easy for new users
  }
  
  /// Check if habit should be completed today based on frequency
  static bool shouldCompleteToday(
    String frequency,
    List<int> customDays,
    DateTime lastCompleted,
  ) {
    final now = DateTime.now();
    
    switch (frequency) {
      case HabitsConstants.daily:
        return true;
      
      case HabitsConstants.weekly:
        return now.difference(lastCompleted).inDays >= 7;
      
      case HabitsConstants.monthly:
        return now.month != lastCompleted.month || 
               now.year != lastCompleted.year;
      
      case HabitsConstants.custom:
        return customDays.contains(now.weekday);
      
      default:
        return true;
    }
  }
  
  /// Calculate streak count
  static int calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;
    
    completionDates.sort((a, b) => b.compareTo(a)); // Most recent first
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if completed today or yesterday to maintain streak
    final latestCompletion = completionDates.first;
    if (!DateTimeUtils.isToday(latestCompletion) && 
        !DateTimeUtils.isYesterday(latestCompletion)) {
      return 0; // Streak broken
    }
    
    int streak = 0;
    DateTime checkDate = DateTimeUtils.isToday(latestCompletion) ? today : yesterday;
    
    for (final completion in completionDates) {
      if (DateTimeUtils.isToday(completion) || 
          completion.day == checkDate.day &&
          completion.month == checkDate.month &&
          completion.year == checkDate.year) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break; // Streak broken
      }
    }
    
    return streak;
  }
  
  /// Get habit completion status for today
  static String getHabitStatus(
    List<DateTime> completionDates,
    String frequency,
    List<int> customDays,
  ) {
    final now = DateTime.now();
    final todayCompleted = completionDates.any((date) => DateTimeUtils.isToday(date));
    
    if (todayCompleted) {
      return HabitsConstants.completed;
    }
    
    if (!shouldCompleteToday(frequency, customDays, 
        completionDates.isEmpty ? DateTime(2000) : completionDates.last)) {
      return 'not_scheduled';
    }
    
    // Check if overdue (after a certain time of day)
    final cutoffTime = DateTime(now.year, now.month, now.day, 21); // 9 PM
    if (now.isAfter(cutoffTime)) {
      return 'overdue';
    }
    
    return HabitsConstants.pending;
  }
  
  /// Generate habit reminders based on optimal timing
  static List<DateTime> generateReminders(
    String habitName,
    Map<String, dynamic> userPreferences,
  ) {
    final reminders = <DateTime>[];
    final now = DateTime.now();
    
    // Default reminder times based on habit type
    final morningHabits = ['exercise', 'meditation', 'breakfast', 'vitamins'];
    final eveningHabits = ['journal', 'reading', 'skincare', 'stretch'];
    
    final habitLower = habitName.toLowerCase();
    
    if (morningHabits.any((h) => habitLower.contains(h))) {
      // Morning reminder (7 AM)
      reminders.add(DateTime(now.year, now.month, now.day, 7));
    } else if (eveningHabits.any((h) => habitLower.contains(h))) {
      // Evening reminder (7 PM)
      reminders.add(DateTime(now.year, now.month, now.day, 19));
    } else {
      // Default afternoon reminder (2 PM)
      reminders.add(DateTime(now.year, now.month, now.day, 14));
    }
    
    // Add user's preferred reminder times if available
    final preferredTimes = userPreferences['reminder_times'] as List<String>? ?? [];
    for (final timeStr in preferredTimes) {
      final timeParts = timeStr.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          reminders.add(DateTime(now.year, now.month, now.day, hour, minute));
        }
      }
    }
    
    return reminders;
  }
  
  /// Sync with Apple Health or Google Fit
  static Future<Map<String, dynamic>?> syncWithHealthApp(
    String habitName,
    String platform,
  ) async {
    // This would integrate with actual health APIs
    // For now, return mock data
    
    final habitLower = habitName.toLowerCase();
    
    if (habitLower.contains('steps') || habitLower.contains('walk')) {
      return {
        'metric': 'steps',
        'value': 8500,
        'unit': 'count',
        'date': DateTime.now(),
      };
    }
    
    if (habitLower.contains('water') || habitLower.contains('hydrat')) {
      return {
        'metric': 'water_intake',
        'value': 1.5,
        'unit': 'liters',
        'date': DateTime.now(),
      };
    }
    
    if (habitLower.contains('exercise') || habitLower.contains('workout')) {
      return {
        'metric': 'exercise_minutes',
        'value': 45,
        'unit': 'minutes',
        'date': DateTime.now(),
      };
    }
    
    return null; // No health data available
  }
  
  /// Calculate habit statistics
  static Map<String, dynamic> calculateHabitStats(
    List<DateTime> completionDates,
    DateTime createdDate,
  ) {
    final now = DateTime.now();
    final totalDays = now.difference(createdDate).inDays + 1;
    final completions = completionDates.length;
    final streak = calculateStreak(completionDates);
    
    // Calculate completion rate
    final completionRate = totalDays > 0 ? completions / totalDays : 0.0;
    
    // Calculate monthly progress
    final thisMonth = completionDates
        .where((date) => date.month == now.month && date.year == now.year)
        .length;
    
    // Calculate weekly progress  
    final weekStart = DateTimeUtils.startOfWeek(now);
    final thisWeek = completionDates
        .where((date) => date.isAfter(weekStart) || DateTimeUtils.isToday(date))
        .length;
    
    // Calculate best streak
    final allStreaks = _calculateAllStreaks(completionDates);
    final bestStreak = allStreaks.isEmpty ? 0 : allStreaks.reduce((a, b) => a > b ? a : b);
    
    return {
      'total_completions': completions,
      'completion_rate': completionRate,
      'current_streak': streak,
      'best_streak': bestStreak,
      'this_month': thisMonth,
      'this_week': thisWeek,
      'total_days': totalDays,
    };
  }
  
  static List<int> _calculateAllStreaks(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return [];
    
    completionDates.sort();
    final streaks = <int>[];
    int currentStreak = 1;
    
    for (int i = 1; i < completionDates.length; i++) {
      final current = completionDates[i];
      final previous = completionDates[i - 1];
      
      if (current.difference(previous).inDays <= 1) {
        currentStreak++;
      } else {
        streaks.add(currentStreak);
        currentStreak = 1;
      }
    }
    
    streaks.add(currentStreak);
    return streaks;
  }
  
  /// Get habit level based on completions and strength
  static int getHabitLevel(double strength) {
    if (strength >= 4.5) return 5; // Master
    if (strength >= 3.5) return 4; // Expert  
    if (strength >= 2.5) return 3; // Proficient
    if (strength >= 1.5) return 2; // Developing
    return 1; // Novice
  }
  
  /// Get habit level name
  static String getHabitLevelName(int level) {
    switch (level) {
      case 5: return 'Master';
      case 4: return 'Expert';
      case 3: return 'Proficient';
      case 2: return 'Developing';
      default: return 'Novice';
    }
  }
  
  /// Generate motivational message based on habit progress
  static String getMotivationalMessage(
    String habitName,
    int streak,
    double strength,
    String habitType,
  ) {
    final messages = <String>[];
    
    if (streak == 0) {
      messages.addAll([
        'Every expert was once a beginner. Start your $habitName journey today!',
        'The first step is always the hardest. You\'ve got this!',
        'Today is perfect to begin building your $habitName habit.',
      ]);
    } else if (streak < 7) {
      messages.addAll([
        'Great start! You\'re building momentum with $habitName.',
        '$streak days in a row! Keep the streak alive!',
        'You\'re forming a powerful habit. Stay consistent!',
      ]);
    } else if (streak < 21) {
      messages.addAll([
        'Amazing! $streak days shows real commitment to $habitName.',
        'You\'re well on your way to making $habitName automatic.',
        'Your dedication to $habitName is paying off!',
      ]);
    } else if (streak < 66) {
      messages.addAll([
        'Incredible! $streak days of $habitName consistency!',
        'You\'re a $habitName champion! Almost to the habit formation milestone.',
        'Your $habitName routine is becoming second nature!',
      ]);
    } else {
      messages.addAll([
        'Legendary! $streak days proves $habitName is truly part of who you are.',
        'You\'ve mastered $habitName! You\'re an inspiration to others.',
        'Your $habitName habit is unbreakable. Well done!',
      ]);
    }
    
    return messages[MathUtils.randomInt(0, messages.length - 1)];
  }
  
  /// Validate habit data
  static Map<String, String?> validateHabit(Map<String, dynamic> habitData) {
    final errors = <String, String?>{};
    
    final name = habitData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      errors['name'] = 'Habit name is required';
    } else if (name.length > HabitsConstants.maxHabitNameLength) {
      errors['name'] = 'Habit name is too long';
    }
    
    final description = habitData['description'] as String?;
    if (description != null && description.length > HabitsConstants.maxHabitDescription) {
      errors['description'] = 'Description is too long';
    }
    
    final targetValue = habitData['target_value'] as int?;
    if (targetValue != null && targetValue > HabitsConstants.maxTargetValue) {
      errors['target_value'] = 'Target value is too high';
    }
    
    return errors;
  }
  
  /// Get habit color based on strength
  static String getHabitColor(double strength) {
    if (strength >= 4.0) return '#2ECC71'; // Green - Strong
    if (strength >= 3.0) return '#F39C12'; // Orange - Moderate  
    if (strength >= 2.0) return '#3498DB'; // Blue - Building
    return '#E74C3C'; // Red - Weak
  }
  
  /// Get next milestone for habit
  static Map<String, dynamic> getNextMilestone(int currentStreak) {
    final milestones = [7, 14, 21, 30, 50, 66, 100, 200, 365, 1000];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return {
          'days': milestone,
          'name': HabitsConstants.streakLevels[milestone] ?? 'Milestone',
          'days_remaining': milestone - currentStreak,
        };
      }
    }
    
    // For streaks beyond 1000 days
    return {
      'days': currentStreak + 100,
      'name': 'Immortal+',
      'days_remaining': 100,
    };
  }
}
