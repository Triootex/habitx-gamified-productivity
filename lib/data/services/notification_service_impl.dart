import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleTaskReminder(TaskEntity task);
  Future<void> scheduleHabitReminder(HabitEntity habit);
  Future<void> sendImmediateNotification(String title, String body, {Map<String, dynamic>? data});
  Future<void> cancelNotification(String notificationId);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
  Future<void> scheduleStreakReminder(String userId, String habitId, int streakLength);
  Future<void> scheduleMotivationalReminder(UserEntity user);
  Future<void> scheduleAchievementNotification(String achievementName, int xpReward);
}

@LazySingleton(as: NotificationService)
class NotificationServiceImpl implements NotificationService {
  static const String channelId = 'habitx_notifications';
  static const String channelName = 'HabitX Notifications';
  static const String channelDescription = 'Notifications for tasks, habits, and achievements';
  
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // In a real implementation, this would initialize flutter_local_notifications
      // and configure notification channels for Android
      
      // Mock initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      _isInitialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Failed to initialize NotificationService: $e');
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // In real implementation, this would request notification permissions
      // For now, simulate permission granted
      await Future.delayed(const Duration(milliseconds: 50));
      
      print('Notification permissions granted');
      return true;
    } catch (e) {
      print('Failed to request notification permissions: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleTaskReminder(TaskEntity task) async {
    if (!_isInitialized) await initialize();
    
    if (task.remindAt == null) return;
    
    final now = DateTime.now();
    if (task.remindAt!.isBefore(now)) return; // Don't schedule past reminders
    
    try {
      final notificationId = _generateNotificationId(task.id, 'task_reminder');
      final title = 'Task Reminder';
      final body = task.title;
      
      // Calculate time until notification
      final scheduleTime = task.remindAt!;
      
      // In real implementation, this would use flutter_local_notifications
      // to schedule the notification
      await _scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: scheduleTime,
        data: {
          'type': 'task_reminder',
          'task_id': task.id,
          'task_title': task.title,
          'priority': task.priority,
        },
      );
      
      print('Scheduled task reminder for "${task.title}" at ${task.remindAt}');
    } catch (e) {
      print('Failed to schedule task reminder: $e');
    }
  }

  @override
  Future<void> scheduleHabitReminder(HabitEntity habit) async {
    if (!_isInitialized) await initialize();
    
    if (habit.reminders.isEmpty) return;
    
    try {
      for (int i = 0; i < habit.reminders.length; i++) {
        final reminderTime = habit.reminders[i];
        final notificationId = _generateNotificationId(habit.id, 'habit_reminder_$i');
        
        final title = 'Habit Reminder';
        final body = _getHabitReminderMessage(habit);
        
        // Parse reminder time (assuming format like "09:00" or "14:30")
        final scheduledTime = _parseReminderTime(reminderTime);
        
        if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: scheduledTime,
            data: {
              'type': 'habit_reminder',
              'habit_id': habit.id,
              'habit_name': habit.name,
              'category': habit.category,
              'streak': habit.currentStreak,
            },
          );
          
          print('Scheduled habit reminder for "${habit.name}" at $scheduledTime');
        }
      }
    } catch (e) {
      print('Failed to schedule habit reminder: $e');
    }
  }

  @override
  Future<void> sendImmediateNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      final notificationId = _generateNotificationId('immediate', DateTime.now().toString());
      
      // In real implementation, this would show an immediate notification
      await _showNotification(
        id: notificationId,
        title: title,
        body: body,
        data: data ?? {},
      );
      
      print('Sent immediate notification: $title - $body');
    } catch (e) {
      print('Failed to send immediate notification: $e');
    }
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    if (!_isInitialized) await initialize();
    
    try {
      // In real implementation, this would cancel the specific notification
      await Future.delayed(const Duration(milliseconds: 10));
      
      print('Cancelled notification: $notificationId');
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    
    try {
      // In real implementation, this would cancel all pending notifications
      await Future.delayed(const Duration(milliseconds: 10));
      
      print('Cancelled all notifications');
    } catch (e) {
      print('Failed to cancel all notifications: $e');
    }
  }

  @override
  Future<void> scheduleStreakReminder(String userId, String habitId, int streakLength) async {
    if (!_isInitialized) await initialize();
    
    try {
      final title = 'Streak Milestone! 🔥';
      final body = _getStreakMessage(streakLength);
      
      await sendImmediateNotification(
        title,
        body,
        data: {
          'type': 'streak_milestone',
          'user_id': userId,
          'habit_id': habitId,
          'streak_length': streakLength,
        },
      );
    } catch (e) {
      print('Failed to send streak reminder: $e');
    }
  }

  @override
  Future<void> scheduleMotivationalReminder(UserEntity user) async {
    if (!_isInitialized) await initialize();
    
    try {
      final title = 'Keep Going, ${user.displayName}! 💪';
      final body = _getMotivationalMessage(user);
      
      // Schedule for later in the day if user hasn't been active
      final scheduledTime = DateTime.now().add(const Duration(hours: 2));
      
      await _scheduleNotification(
        id: _generateNotificationId(user.id, 'motivational'),
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        data: {
          'type': 'motivational',
          'user_id': user.id,
          'level': user.currentLevel,
        },
      );
    } catch (e) {
      print('Failed to schedule motivational reminder: $e');
    }
  }

  @override
  Future<void> scheduleAchievementNotification(String achievementName, int xpReward) async {
    if (!_isInitialized) await initialize();
    
    try {
      final title = 'Achievement Unlocked! 🏆';
      final body = '$achievementName (+$xpReward XP)';
      
      await sendImmediateNotification(
        title,
        body,
        data: {
          'type': 'achievement_unlocked',
          'achievement_name': achievementName,
          'xp_reward': xpReward,
        },
      );
    } catch (e) {
      print('Failed to send achievement notification: $e');
    }
  }

  // Helper methods
  int _generateNotificationId(String prefix, String suffix) {
    return (prefix + suffix).hashCode.abs() % 100000;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, dynamic> data,
  }) async {
    // Mock implementation - in real app would use flutter_local_notifications
    print('Scheduled notification $id: "$title" at $scheduledTime');
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Mock implementation - in real app would show immediate notification
    print('Showing notification $id: "$title" - "$body"');
  }

  DateTime? _parseReminderTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      return scheduledTime;
    } catch (e) {
      print('Failed to parse reminder time: $timeString');
      return null;
    }
  }

  String _getHabitReminderMessage(HabitEntity habit) {
    final messages = [
      'Time to ${habit.name}! 💪',
      'Don\'t break your ${habit.currentStreak}-day streak!',
      'Your future self will thank you for ${habit.name}',
      'Just ${habit.name} for a few minutes',
      'Keep building that ${habit.name} habit!',
    ];
    
    if (habit.currentStreak > 0) {
      return 'Don\'t break your ${habit.currentStreak}-day streak! Time for ${habit.name}';
    }
    
    return messages[DateTime.now().millisecond % messages.length];
  }

  String _getStreakMessage(int streakLength) {
    if (streakLength == 7) {
      return 'You\'ve completed a full week! Amazing consistency! 🎉';
    } else if (streakLength == 30) {
      return 'One month streak! You\'re building a real habit! 🔥';
    } else if (streakLength == 100) {
      return 'WOW! 100-day streak! You\'re unstoppable! 🚀';
    } else if (streakLength % 10 == 0) {
      return '$streakLength days in a row! You\'re on fire! 🔥';
    } else {
      return 'Day $streakLength complete! Keep the momentum going! ⚡';
    }
  }

  String _getMotivationalMessage(UserEntity user) {
    final messages = [
      'You\'re doing great! Time to tackle another goal',
      'Small progress is still progress',
      'Your consistency is building something amazing',
      'Level ${user.currentLevel} achiever - keep climbing!',
      'Every small step counts towards your big goals',
    ];
    
    return messages[DateTime.now().hour % messages.length];
  }
}
