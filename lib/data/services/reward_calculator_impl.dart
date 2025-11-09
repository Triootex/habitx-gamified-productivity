import 'package:injectable/injectable.dart';
import '../../core/utils/gamification_utils.dart';
import '../../core/utils/math_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/gamification_entity.dart';

abstract class RewardCalculator {
  int calculateTaskXP(TaskEntity task);
  int calculateHabitXP(HabitEntity habit, HabitLogEntity log);
  int calculateStreakBonus(int streakLength, String category);
  List<RewardEntity> generateLootRewards(String difficultyLevel, String category);
  int calculateLevelUpXP(int currentLevel);
  Map<String, dynamic> calculateCategoryBonus(String category, Map<String, int> categoryProgress);
}

@LazySingleton(as: RewardCalculator)
class RewardCalculatorImpl implements RewardCalculator {
  @override
  int calculateTaskXP(TaskEntity task) {
    return GamificationUtils.calculateTaskXP(
      priority: task.priority,
      estimatedMinutes: task.estimatedMinutes,
      actualMinutes: task.actualMinutes,
      hasSubtasks: task.hasSubtasks,
      subtaskCount: task.subtasks.length,
      completedSubtasks: task.subtasks.where((s) => s.isCompleted).length,
      isOverdue: task.isOverdue,
      tags: task.tags,
    );
  }

  @override
  int calculateHabitXP(HabitEntity habit, HabitLogEntity log) {
    int baseXP = habit.xpPerCompletion;
    
    // Streak multiplier
    double multiplier = 1.0;
    if (habit.currentStreak > 0) {
      multiplier = 1.0 + (habit.currentStreak * 0.1); // 10% bonus per streak day
    }
    
    // Habit strength bonus
    if (habit.habitStrength > 0.8) {
      multiplier += 0.2; // 20% bonus for strong habits
    }
    
    // Difficulty bonus based on tracking type
    switch (habit.trackingType) {
      case 'duration':
        if (log.durationMinutes >= (habit.targetValue ?? 0)) {
          multiplier += 0.15; // 15% bonus for meeting duration target
        }
        break;
      case 'numeric':
        if (log.value >= (habit.targetValue ?? 0)) {
          multiplier += 0.15; // 15% bonus for meeting numeric target
        }
        break;
    }
    
    // Mood improvement bonus
    if (log.moodBefore != null && log.moodAfter != null) {
      final moodImprovement = log.moodAfter! - log.moodBefore!;
      if (moodImprovement > 0) {
        multiplier += moodImprovement * 0.05; // 5% per mood point improvement
      }
    }
    
    return (baseXP * multiplier).round();
  }

  @override
  int calculateStreakBonus(int streakLength, String category) {
    if (streakLength < 3) return 0;
    
    // Base bonus increases with streak length
    int baseBonus = 0;
    if (streakLength >= 7) baseBonus = 50;
    else if (streakLength >= 14) baseBonus = 150;
    else if (streakLength >= 30) baseBonus = 500;
    else if (streakLength >= 100) baseBonus = 2000;
    else baseBonus = streakLength * 5;
    
    // Category multipliers
    final categoryMultipliers = {
      'health': 1.2,
      'productivity': 1.1,
      'learning': 1.3,
      'mindfulness': 1.25,
      'finance': 1.0,
    };
    
    final multiplier = categoryMultipliers[category] ?? 1.0;
    return (baseBonus * multiplier).round();
  }

  @override
  List<RewardEntity> generateLootRewards(String difficultyLevel, String category) {
    final rewards = <RewardEntity>[];
    final now = DateTime.now();
    
    // Generate random rewards based on difficulty
    final lootConfig = GamificationUtils.generateLootReward(difficultyLevel, category);
    
    for (final item in lootConfig['items'] as List<Map<String, dynamic>>) {
      rewards.add(RewardEntity(
        id: 'reward_${now.millisecondsSinceEpoch}_${MathUtils.randomInt(1000, 9999)}',
        userId: '', // Will be set by calling service
        type: 'item',
        sourceType: 'loot',
        sourceId: difficultyLevel,
        itemId: item['id'] as String,
        itemQuantity: item['quantity'] as int? ?? 1,
        title: item['name'] as String,
        description: item['description'] as String? ?? '',
        earnedAt: now,
        rarity: item['rarity'] as String? ?? 'common',
        metadata: {
          'category': category,
          'difficulty': difficultyLevel,
          'loot_type': 'random_drop',
        },
      ));
    }
    
    // Add XP reward
    if (lootConfig['xp'] as int? ?? 0 > 0) {
      rewards.add(RewardEntity(
        id: 'xp_reward_${now.millisecondsSinceEpoch}',
        userId: '', // Will be set by calling service
        type: 'xp',
        sourceType: 'loot',
        sourceId: difficultyLevel,
        xpAmount: lootConfig['xp'] as int,
        title: 'XP Bonus',
        description: 'Bonus experience points',
        earnedAt: now,
        rarity: 'common',
        metadata: {
          'category': category,
          'difficulty': difficultyLevel,
        },
      ));
    }
    
    return rewards;
  }

  @override
  int calculateLevelUpXP(int currentLevel) {
    return GamificationUtils.getXPForNextLevel(currentLevel);
  }

  @override
  Map<String, dynamic> calculateCategoryBonus(String category, Map<String, int> categoryProgress) {
    final totalXP = categoryProgress.values.fold<int>(0, (sum, xp) => sum + xp);
    final categoryXP = categoryProgress[category] ?? 0;
    
    // Calculate category mastery bonus
    double masteryPercentage = 0.0;
    if (totalXP > 0) {
      masteryPercentage = categoryXP / totalXP;
    }
    
    int bonusXP = 0;
    String bonusType = 'none';
    
    if (masteryPercentage > 0.5) {
      bonusXP = (categoryXP * 0.1).round(); // 10% bonus for category specialization
      bonusType = 'specialization';
    }
    
    if (categoryXP > 10000) {
      bonusXP += 500; // Mastery milestone bonus
      bonusType = 'mastery';
    }
    
    return {
      'bonus_xp': bonusXP,
      'bonus_type': bonusType,
      'mastery_percentage': masteryPercentage,
      'category_level': GamificationUtils.calculateLevel(categoryXP),
      'next_milestone': _getNextCategoryMilestone(categoryXP),
    };
  }
  
  Map<String, dynamic> _getNextCategoryMilestone(int currentXP) {
    final milestones = [1000, 2500, 5000, 10000, 25000, 50000, 100000];
    
    for (final milestone in milestones) {
      if (currentXP < milestone) {
        return {
          'xp_required': milestone,
          'xp_remaining': milestone - currentXP,
          'progress': currentXP / milestone,
        };
      }
    }
    
    // Beyond all milestones
    return {
      'xp_required': currentXP + 50000,
      'xp_remaining': 50000,
      'progress': 1.0,
    };
  }
}
