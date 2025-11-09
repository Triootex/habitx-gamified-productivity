import 'package:injectable/injectable.dart';
import '../../core/utils/gamification_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/gamification_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/habit_entity.dart';

abstract class AchievementEngine {
  Future<List<AchievementEntity>> checkForNewAchievements(
    UserEntity user,
    String actionType,
    Map<String, dynamic> actionData,
  );
  Future<List<AchievementEntity>> getAvailableAchievements(UserEntity user);
  Future<UserAchievementEntity?> updateAchievementProgress(
    String userId,
    String achievementId,
    Map<String, dynamic> progressData,
  );
  Future<bool> canUnlockAchievement(UserEntity user, AchievementEntity achievement);
}

@LazySingleton(as: AchievementEngine)
class AchievementEngineImpl implements AchievementEngine {
  // Mock achievement definitions - in real app, these would come from database
  static final List<AchievementEntity> _allAchievements = [
    // Task achievements
    AchievementEntity(
      id: 'first_task',
      name: 'Getting Started',
      description: 'Complete your first task',
      category: 'tasks',
      type: 'bronze',
      iconUrl: '/assets/achievements/first_task.png',
      xpReward: 100,
      rarity: 'common',
      requirements: ['Complete 1 task'],
      criteria: {'tasks_completed': 1},
      createdAt: DateTime.now(),
    ),
    AchievementEntity(
      id: 'task_master',
      name: 'Task Master',
      description: 'Complete 100 tasks',
      category: 'tasks',
      type: 'gold',
      iconUrl: '/assets/achievements/task_master.png',
      xpReward: 1000,
      rarity: 'rare',
      requirements: ['Complete 100 tasks'],
      criteria: {'tasks_completed': 100},
      createdAt: DateTime.now(),
    ),
    AchievementEntity(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete 10 tasks in one day',
      category: 'tasks',
      type: 'silver',
      iconUrl: '/assets/achievements/speed_demon.png',
      xpReward: 500,
      rarity: 'uncommon',
      requirements: ['Complete 10 tasks in a single day'],
      criteria: {'daily_tasks_completed': 10},
      createdAt: DateTime.now(),
    ),
    
    // Habit achievements
    AchievementEntity(
      id: 'habit_builder',
      name: 'Habit Builder',
      description: 'Create your first habit',
      category: 'habits',
      type: 'bronze',
      iconUrl: '/assets/achievements/habit_builder.png',
      xpReward: 150,
      rarity: 'common',
      requirements: ['Create 1 habit'],
      criteria: {'habits_created': 1},
      createdAt: DateTime.now(),
    ),
    AchievementEntity(
      id: 'streak_warrior',
      name: 'Streak Warrior',
      description: 'Maintain a 30-day habit streak',
      category: 'habits',
      type: 'gold',
      iconUrl: '/assets/achievements/streak_warrior.png',
      xpReward: 2000,
      rarity: 'epic',
      requirements: ['Maintain a 30-day streak'],
      criteria: {'max_streak': 30},
      createdAt: DateTime.now(),
    ),
    
    // Productivity achievements
    AchievementEntity(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a task before 6 AM',
      category: 'productivity',
      type: 'silver',
      iconUrl: '/assets/achievements/early_bird.png',
      xpReward: 300,
      rarity: 'uncommon',
      requirements: ['Complete a task before 6 AM'],
      criteria: {'early_task_completion': true},
      createdAt: DateTime.now(),
    ),
    
    // Social achievements
    AchievementEntity(
      id: 'team_player',
      name: 'Team Player',
      description: 'Complete 5 collaborative tasks',
      category: 'social',
      type: 'silver',
      iconUrl: '/assets/achievements/team_player.png',
      xpReward: 400,
      rarity: 'uncommon',
      requirements: ['Complete 5 tasks with collaborators'],
      criteria: {'collaborative_tasks': 5},
      createdAt: DateTime.now(),
    ),
    
    // Meditation achievements
    AchievementEntity(
      id: 'zen_master',
      name: 'Zen Master',
      description: 'Complete 100 meditation sessions',
      category: 'meditation',
      type: 'platinum',
      iconUrl: '/assets/achievements/zen_master.png',
      xpReward: 5000,
      rarity: 'legendary',
      requirements: ['Complete 100 meditation sessions'],
      criteria: {'meditation_sessions': 100},
      createdAt: DateTime.now(),
    ),
    
    // Special achievements
    AchievementEntity(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Complete all daily goals for 7 consecutive days',
      category: 'special',
      type: 'diamond',
      iconUrl: '/assets/achievements/perfectionist.png',
      xpReward: 10000,
      rarity: 'legendary',
      requirements: ['Complete all daily goals for 7 days'],
      criteria: {'perfect_days': 7},
      isSecret: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<AchievementEntity>> checkForNewAchievements(
    UserEntity user,
    String actionType,
    Map<String, dynamic> actionData,
  ) async {
    final newAchievements = <AchievementEntity>[];
    
    // Get user's current achievements
    final userAchievements = user.unlockedAchievements;
    
    // Check each achievement against the action
    for (final achievement in _allAchievements) {
      // Skip if already unlocked
      if (userAchievements.contains(achievement.id)) continue;
      
      // Check prerequisites
      if (!await _checkPrerequisites(user, achievement)) continue;
      
      // Check if action triggers this achievement
      if (await _checkAchievementCriteria(achievement, actionType, actionData, user)) {
        newAchievements.add(achievement);
      }
    }
    
    return newAchievements;
  }

  @override
  Future<List<AchievementEntity>> getAvailableAchievements(UserEntity user) async {
    final availableAchievements = <AchievementEntity>[];
    final userAchievements = user.unlockedAchievements;
    
    for (final achievement in _allAchievements) {
      // Skip if already unlocked
      if (userAchievements.contains(achievement.id)) continue;
      
      // Skip secret achievements
      if (achievement.isSecret) continue;
      
      // Check prerequisites
      if (await _checkPrerequisites(user, achievement)) {
        availableAchievements.add(achievement);
      }
    }
    
    return availableAchievements;
  }

  @override
  Future<UserAchievementEntity?> updateAchievementProgress(
    String userId,
    String achievementId,
    Map<String, dynamic> progressData,
  ) async {
    final achievement = _allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    // Calculate progress based on criteria
    final progress = _calculateProgress(achievement, progressData);
    
    return UserAchievementEntity(
      id: 'user_achievement_${userId}_${achievementId}',
      userId: userId,
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
      progress: progress,
      progressData: progressData,
      isCompleted: progress >= 1.0,
      completedAt: progress >= 1.0 ? DateTime.now() : null,
    );
  }

  @override
  Future<bool> canUnlockAchievement(UserEntity user, AchievementEntity achievement) async {
    // Check if already unlocked
    if (user.unlockedAchievements.contains(achievement.id)) return false;
    
    // Check prerequisites
    if (!await _checkPrerequisites(user, achievement)) return false;
    
    // Check if valid (not expired)
    if (achievement.validUntil != null && DateTime.now().isAfter(achievement.validUntil!)) {
      return false;
    }
    
    return true;
  }

  Future<bool> _checkPrerequisites(UserEntity user, AchievementEntity achievement) async {
    for (final prerequisiteId in achievement.prerequisites) {
      if (!user.unlockedAchievements.contains(prerequisiteId)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _checkAchievementCriteria(
    AchievementEntity achievement,
    String actionType,
    Map<String, dynamic> actionData,
    UserEntity user,
  ) async {
    switch (achievement.id) {
      case 'first_task':
        return actionType == 'task_completed' && actionData['task_count'] as int >= 1;
        
      case 'task_master':
        return actionType == 'task_completed' && actionData['total_tasks'] as int >= 100;
        
      case 'speed_demon':
        return actionType == 'daily_summary' && actionData['tasks_today'] as int >= 10;
        
      case 'habit_builder':
        return actionType == 'habit_created' && actionData['habit_count'] as int >= 1;
        
      case 'streak_warrior':
        return actionType == 'habit_completed' && actionData['max_streak'] as int >= 30;
        
      case 'early_bird':
        if (actionType == 'task_completed') {
          final completedAt = actionData['completed_at'] as DateTime?;
          return completedAt != null && completedAt.hour < 6;
        }
        return false;
        
      case 'team_player':
        return actionType == 'collaborative_task_completed' && 
               actionData['collaborative_tasks'] as int >= 5;
        
      case 'zen_master':
        return actionType == 'meditation_completed' && 
               actionData['total_sessions'] as int >= 100;
        
      case 'perfectionist':
        return actionType == 'daily_goals_completed' && 
               actionData['consecutive_perfect_days'] as int >= 7;
        
      default:
        return false;
    }
  }

  double _calculateProgress(AchievementEntity achievement, Map<String, dynamic> progressData) {
    final criteria = achievement.criteria;
    
    for (final criteriaEntry in criteria.entries) {
      final key = criteriaEntry.key;
      final targetValue = criteriaEntry.value;
      
      if (progressData.containsKey(key)) {
        final currentValue = progressData[key];
        
        if (targetValue is int && currentValue is int) {
          return (currentValue / targetValue).clamp(0.0, 1.0);
        } else if (targetValue is bool && currentValue is bool) {
          return currentValue ? 1.0 : 0.0;
        }
      }
    }
    
    return 0.0;
  }
}
