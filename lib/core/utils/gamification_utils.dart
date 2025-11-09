import 'dart:math' as math;
import '../constants/app_constants.dart';
import 'math_utils.dart';

class GamificationUtils {
  /// Calculate user level from total XP
  static int calculateLevel(int totalXp) {
    return MathUtils.calculateLevelFromXp(totalXp);
  }
  
  /// Calculate XP required for next level
  static int calculateXpForNextLevel(int currentLevel) {
    return MathUtils.calculateXpForLevel(currentLevel + 1);
  }
  
  /// Calculate progress to next level (0.0 to 1.0)
  static double calculateLevelProgress(int totalXp) {
    return MathUtils.calculateLevelProgress(totalXp);
  }
  
  /// Generate loot rewards based on task difficulty and user status
  static Map<String, dynamic> generateLootRewards(
    String difficulty,
    String category,
    bool isPremium,
  ) {
    final random = math.Random();
    double roll = random.nextDouble();
    
    // Premium users get better odds
    if (isPremium) {
      roll = math.min(roll + 0.2, 1.0);
    }
    
    final rarity = MathUtils.calculateRarity(roll, difficulty);
    final quantity = MathUtils.calculateItemQuantity(rarity);
    
    // Calculate rewards
    final rewards = MathUtils.calculateReward(difficulty, isPremium: isPremium);
    
    // Generate specific items based on category and rarity
    final items = _generateCategoryItems(category, rarity, quantity);
    
    return {
      'xp': rewards['xp'],
      'gold': rewards['gold'],
      'items': items,
      'rarity': rarity,
      'category': category,
    };
  }
  
  static List<Map<String, dynamic>> _generateCategoryItems(
    String category,
    String rarity,
    int quantity,
  ) {
    final items = <Map<String, dynamic>>[];
    
    // Define item pools per category
    final categoryItems = _getCategoryItemPool(category);
    final rarityItems = categoryItems[rarity] ?? [];
    
    for (int i = 0; i < quantity; i++) {
      if (rarityItems.isNotEmpty) {
        final randomItem = rarityItems[MathUtils.randomInt(0, rarityItems.length - 1)];
        items.add({
          'id': _generateItemId(),
          'name': randomItem['name'],
          'description': randomItem['description'],
          'rarity': rarity,
          'category': category,
          'effects': randomItem['effects'] ?? {},
          'icon': randomItem['icon'] ?? 'inventory',
        });
      }
    }
    
    return items;
  }
  
  static Map<String, List<Map<String, dynamic>>> _getCategoryItemPool(String category) {
    switch (category) {
      case 'todo':
        return {
          'common': [
            {'name': 'Productivity Potion', 'description': '+5% XP for next task', 'effects': {'xp_bonus': 0.05}},
            {'name': 'Focus Herb', 'description': 'Reduces distractions', 'effects': {'focus_bonus': 0.1}},
          ],
          'rare': [
            {'name': 'Task Accelerator', 'description': '+10% XP for 1 hour', 'effects': {'xp_bonus': 0.1, 'duration': 3600}},
            {'name': 'Priority Crystal', 'description': 'Auto-sorts tasks by importance', 'effects': {'auto_priority': true}},
          ],
          'legendary': [
            {'name': 'Completion Crown', 'description': 'Double XP for all tasks today', 'effects': {'xp_multiplier': 2.0, 'duration': 86400}},
          ],
        };
      
      case 'habits':
        return {
          'common': [
            {'name': 'Streak Shield', 'description': 'Protects streak for 1 day', 'effects': {'streak_protection': 1}},
            {'name': 'Motivation Gem', 'description': '+10% habit strength', 'effects': {'strength_bonus': 0.1}},
          ],
          'rare': [
            {'name': 'Habit Anchor', 'description': 'Prevents habit decay for 3 days', 'effects': {'decay_protection': 3}},
            {'name': 'Consistency Charm', 'description': '+20% XP for habit completion', 'effects': {'habit_xp_bonus': 0.2}},
          ],
          'legendary': [
            {'name': 'Master\'s Medallion', 'description': 'Instantly levels up any habit', 'effects': {'instant_level': true}},
          ],
        };
      
      case 'fitness':
        return {
          'common': [
            {'name': 'Energy Drink', 'description': '+5 stamina points', 'effects': {'stamina': 5}},
            {'name': 'Protein Crystal', 'description': '+10% workout XP', 'effects': {'workout_xp_bonus': 0.1}},
          ],
          'rare': [
            {'name': 'Endurance Elixir', 'description': '+25% workout duration', 'effects': {'workout_duration_bonus': 0.25}},
            {'name': 'Strength Serum', 'description': '+15% strength gains', 'effects': {'strength_gain_bonus': 0.15}},
          ],
          'legendary': [
            {'name': 'Champion\'s Belt', 'description': 'Double all fitness rewards', 'effects': {'fitness_multiplier': 2.0}},
          ],
        };
      
      default:
        return {
          'common': [
            {'name': 'Experience Orb', 'description': '+10 bonus XP', 'effects': {'bonus_xp': 10}},
            {'name': 'Golden Coin', 'description': '+5 bonus gold', 'effects': {'bonus_gold': 5}},
          ],
          'rare': [
            {'name': 'Wisdom Stone', 'description': '+50 bonus XP', 'effects': {'bonus_xp': 50}},
          ],
          'legendary': [
            {'name': 'Mastery Crystal', 'description': '+200 bonus XP', 'effects': {'bonus_xp': 200}},
          ],
        };
    }
  }
  
  static String _generateItemId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}_${MathUtils.randomInt(1000, 9999)}';
  }
  
  /// Calculate achievement unlock status
  static Map<String, dynamic> checkAchievementUnlock(
    String achievementId,
    Map<String, dynamic> userStats,
    Map<String, dynamic> achievementCriteria,
  ) {
    final criteriaType = achievementCriteria['type'] as String;
    final targetValue = achievementCriteria['target'] as int;
    final currentValue = userStats[criteriaType] as int? ?? 0;
    
    final isUnlocked = currentValue >= targetValue;
    final progress = targetValue > 0 ? currentValue / targetValue : 0.0;
    
    return {
      'id': achievementId,
      'unlocked': isUnlocked,
      'progress': progress.clamp(0.0, 1.0),
      'current_value': currentValue,
      'target_value': targetValue,
      'unlocked_at': isUnlocked ? DateTime.now() : null,
    };
  }
  
  /// Generate quest based on user's current activities and level
  static Map<String, dynamic> generateDailyQuest(
    Map<String, dynamic> userProfile,
    List<String> availableCategories,
  ) {
    final random = math.Random();
    final userLevel = userProfile['level'] as int? ?? 1;
    
    // Select random category
    final category = availableCategories[random.nextInt(availableCategories.length)];
    
    // Generate quest difficulty based on user level
    String difficulty;
    if (userLevel < 5) {
      difficulty = 'easy';
    } else if (userLevel < 15) {
      difficulty = 'medium';
    } else if (userLevel < 30) {
      difficulty = 'hard';
    } else {
      difficulty = 'very_hard';
    }
    
    // Generate quest requirements
    final questTemplates = _getQuestTemplates(category, difficulty);
    final template = questTemplates[random.nextInt(questTemplates.length)];
    
    // Calculate rewards
    final baseReward = AppConstants.xpValues[difficulty] ?? 10;
    final goldReward = AppConstants.goldValues[difficulty] ?? 5;
    
    return {
      'id': 'quest_${DateTime.now().millisecondsSinceEpoch}',
      'title': template['title'],
      'description': template['description'],
      'category': category,
      'difficulty': difficulty,
      'requirements': template['requirements'],
      'rewards': {
        'xp': baseReward * 2, // Quests give double XP
        'gold': goldReward * 2,
        'items': random.nextDouble() < 0.3 ? 1 : 0, // 30% chance for item
      },
      'expires_at': DateTime.now().add(const Duration(hours: 24)),
      'progress': 0,
      'completed': false,
    };
  }
  
  static List<Map<String, dynamic>> _getQuestTemplates(String category, String difficulty) {
    final templates = <String, List<Map<String, dynamic>>>{
      'todo': [
        {
          'title': 'Task Master',
          'description': 'Complete ${_getQuestTarget(difficulty, 3)} tasks',
          'requirements': {'complete_tasks': _getQuestTarget(difficulty, 3)},
        },
        {
          'title': 'Priority Champion',
          'description': 'Complete ${_getQuestTarget(difficulty, 1)} high-priority task',
          'requirements': {'complete_high_priority_tasks': _getQuestTarget(difficulty, 1)},
        },
      ],
      'habits': [
        {
          'title': 'Habit Warrior',
          'description': 'Complete ${_getQuestTarget(difficulty, 3)} habits',
          'requirements': {'complete_habits': _getQuestTarget(difficulty, 3)},
        },
        {
          'title': 'Streak Guardian',
          'description': 'Maintain all habit streaks',
          'requirements': {'maintain_all_streaks': 1},
        },
      ],
      'fitness': [
        {
          'title': 'Fitness Hero',
          'description': 'Exercise for ${_getQuestTarget(difficulty, 30)} minutes',
          'requirements': {'exercise_minutes': _getQuestTarget(difficulty, 30)},
        },
        {
          'title': 'Step Champion',
          'description': 'Walk ${_getQuestTarget(difficulty, 5000)} steps',
          'requirements': {'steps': _getQuestTarget(difficulty, 5000)},
        },
      ],
    };
    
    return templates[category] ?? [
      {
        'title': 'Daily Explorer',
        'description': 'Complete any activity in $category',
        'requirements': {'${category}_activity': 1},
      }
    ];
  }
  
  static int _getQuestTarget(String difficulty, int baseValue) {
    switch (difficulty) {
      case 'easy':
        return baseValue;
      case 'medium':
        return (baseValue * 1.5).round();
      case 'hard':
        return (baseValue * 2).round();
      case 'very_hard':
        return (baseValue * 3).round();
      default:
        return baseValue;
    }
  }
  
  /// Calculate skill tree unlock requirements
  static bool canUnlockSkill(
    String skillId,
    Map<String, dynamic> skillData,
    Map<String, dynamic> userProgress,
  ) {
    final requirements = skillData['requirements'] as Map<String, dynamic>? ?? {};
    
    // Check level requirement
    final requiredLevel = requirements['level'] as int? ?? 0;
    final userLevel = userProgress['level'] as int? ?? 0;
    if (userLevel < requiredLevel) return false;
    
    // Check prerequisite skills
    final prerequisites = requirements['prerequisites'] as List<String>? ?? [];
    final unlockedSkills = userProgress['unlocked_skills'] as List<String>? ?? [];
    for (final prereq in prerequisites) {
      if (!unlockedSkills.contains(prereq)) return false;
    }
    
    // Check category progress
    final requiredCategoryXp = requirements['category_xp'] as Map<String, int>? ?? {};
    final userCategoryXp = userProgress['category_xp'] as Map<String, int>? ?? {};
    for (final entry in requiredCategoryXp.entries) {
      final requiredXp = entry.value;
      final currentXp = userCategoryXp[entry.key] ?? 0;
      if (currentXp < requiredXp) return false;
    }
    
    return true;
  }
  
  /// Apply skill effects to user stats
  static Map<String, dynamic> applySkillEffects(
    Map<String, dynamic> baseStats,
    List<String> activeSkills,
    Map<String, Map<String, dynamic>> skillEffects,
  ) {
    final modifiedStats = Map<String, dynamic>.from(baseStats);
    
    for (final skillId in activeSkills) {
      final effects = skillEffects[skillId];
      if (effects != null) {
        for (final entry in effects.entries) {
          final statName = entry.key;
          final effect = entry.value;
          
          if (effect is num) {
            // Additive effect
            modifiedStats[statName] = (modifiedStats[statName] ?? 0) + effect;
          } else if (effect is Map && effect.containsKey('multiplier')) {
            // Multiplicative effect
            final multiplier = effect['multiplier'] as num;
            modifiedStats[statName] = (modifiedStats[statName] ?? 0) * multiplier;
          }
        }
      }
    }
    
    return modifiedStats;
  }
  
  /// Calculate leaderboard ranking
  static Map<String, dynamic> calculateLeaderboardRank(
    String userId,
    int userScore,
    List<Map<String, dynamic>> leaderboardData,
  ) {
    // Sort leaderboard by score (descending)
    leaderboardData.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    // Find user's rank
    int rank = 1;
    for (int i = 0; i < leaderboardData.length; i++) {
      if (leaderboardData[i]['user_id'] == userId) {
        rank = i + 1;
        break;
      }
      rank = i + 2; // If not found, assume next position
    }
    
    // Calculate percentile
    final percentile = leaderboardData.isNotEmpty 
        ? ((leaderboardData.length - rank + 1) / leaderboardData.length) * 100 
        : 0.0;
    
    return {
      'rank': rank,
      'total_users': leaderboardData.length,
      'percentile': percentile.round(),
      'score': userScore,
      'rank_change': 0, // This would be calculated against previous period
    };
  }
  
  /// Generate motivational message based on progress
  static String getMotivationalMessage(
    Map<String, dynamic> userStats,
    String context,
  ) {
    final level = userStats['level'] as int? ?? 1;
    final streak = userStats['current_streak'] as int? ?? 0;
    final completionRate = userStats['completion_rate'] as double? ?? 0.0;
    
    final messages = <String>[];
    
    // Level-based messages
    if (level < 5) {
      messages.addAll([
        'You\'re just getting started on your epic journey!',
        'Every hero begins with a single step. Keep going!',
        'Your adventure is unfolding beautifully!',
      ]);
    } else if (level < 15) {
      messages.addAll([
        'You\'re becoming a true productivity warrior!',
        'Your dedication is paying off - level $level achieved!',
        'You\'re building unstoppable momentum!',
      ]);
    } else if (level < 30) {
      messages.addAll([
        'Incredible! You\'ve reached the ranks of productivity masters!',
        'Level $level shows your commitment to excellence!',
        'You\'re an inspiration to other heroes!',
      ]);
    } else {
      messages.addAll([
        'Legendary! You\'ve transcended ordinary productivity!',
        'Level $level - you\'re in the elite tier of achievers!',
        'Your mastery is unquestionable!',
      ]);
    }
    
    // Streak-based messages
    if (streak >= 30) {
      messages.add('Your $streak-day streak is absolutely phenomenal!');
    } else if (streak >= 7) {
      messages.add('A $streak-day streak shows true commitment!');
    }
    
    // Context-specific messages
    switch (context) {
      case 'level_up':
        messages.add('🎉 Level up! Your hard work has unlocked new possibilities!');
        break;
      case 'quest_complete':
        messages.add('⚔️ Quest completed! Your heroic deeds earn you glory!');
        break;
      case 'streak_milestone':
        messages.add('🔥 Streak milestone reached! Your consistency is legendary!');
        break;
    }
    
    return messages[MathUtils.randomInt(0, messages.length - 1)];
  }
  
  /// Get rarity color for UI display
  static String getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return '#74B9FF'; // Light blue
      case 'uncommon':
        return '#00B894'; // Green
      case 'rare':
        return '#FFB020'; // Orange
      case 'ultra_rare':
        return '#E17055'; // Red-orange
      case 'legendary':
        return '#6C5CE7'; // Purple
      case 'mythical':
        return '#FF7675'; // Pink-red
      default:
        return '#74B9FF';
    }
  }
  
  /// Get rarity display name
  static String getRarityDisplayName(String rarity) {
    switch (rarity) {
      case 'ultra_rare':
        return 'Ultra Rare';
      default:
        return rarity.split('_').map((word) => 
            word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }
}
