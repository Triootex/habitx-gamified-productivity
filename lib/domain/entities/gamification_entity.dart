import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category; // productivity, social, milestone, streak, etc.
  final String type; // bronze, silver, gold, platinum, diamond
  final String iconUrl;
  final int xpReward;
  final String rarity; // common, uncommon, rare, epic, legendary
  final List<String> requirements; // Text descriptions of requirements
  final Map<String, dynamic> criteria; // Actual criteria data
  final bool isSecret; // Hidden achievement
  final bool isRepeatable;
  final DateTime? validUntil; // For time-limited achievements
  final List<String> prerequisites; // Achievement IDs that must be completed first
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AchievementEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.type = 'bronze',
    required this.iconUrl,
    this.xpReward = 100,
    this.rarity = 'common',
    this.requirements = const [],
    this.criteria = const {},
    this.isSecret = false,
    this.isRepeatable = false,
    this.validUntil,
    this.prerequisites = const [],
    this.metadata = const {},
    required this.createdAt,
  });

  AchievementEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? type,
    String? iconUrl,
    int? xpReward,
    String? rarity,
    List<String>? requirements,
    Map<String, dynamic>? criteria,
    bool? isSecret,
    bool? isRepeatable,
    DateTime? validUntil,
    List<String>? prerequisites,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      iconUrl: iconUrl ?? this.iconUrl,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
      requirements: requirements ?? this.requirements,
      criteria: criteria ?? this.criteria,
      isSecret: isSecret ?? this.isSecret,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      validUntil: validUntil ?? this.validUntil,
      prerequisites: prerequisites ?? this.prerequisites,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        type,
        iconUrl,
        xpReward,
        rarity,
        requirements,
        criteria,
        isSecret,
        isRepeatable,
        validUntil,
        prerequisites,
        metadata,
        createdAt,
      ];
}

class UserAchievementEntity extends Equatable {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final double progress; // 0.0 to 1.0
  final Map<String, dynamic> progressData;
  final bool isCompleted;
  final DateTime? completedAt;
  final int timesCompleted; // For repeatable achievements
  final Map<String, dynamic> completionContext; // Additional data when completed

  const UserAchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.progress = 0.0,
    this.progressData = const {},
    this.isCompleted = false,
    this.completedAt,
    this.timesCompleted = 0,
    this.completionContext = const {},
  });

  UserAchievementEntity copyWith({
    String? id,
    String? userId,
    String? achievementId,
    DateTime? unlockedAt,
    double? progress,
    Map<String, dynamic>? progressData,
    bool? isCompleted,
    DateTime? completedAt,
    int? timesCompleted,
    Map<String, dynamic>? completionContext,
  }) {
    return UserAchievementEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      progressData: progressData ?? this.progressData,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      completionContext: completionContext ?? this.completionContext,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        achievementId,
        unlockedAt,
        progress,
        progressData,
        isCompleted,
        completedAt,
        timesCompleted,
        completionContext,
      ];
}

class QuestEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category; // daily, weekly, monthly, special
  final String type; // single, chain, repeatable
  final int difficulty; // 1-5 scale
  final List<QuestTaskEntity> tasks;
  final int totalXpReward;
  final Map<String, int> itemRewards; // Item ID -> Quantity
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> prerequisites; // Quest IDs
  final bool isActive;
  final bool isCompleted;
  final String? nextQuestId; // For quest chains
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const QuestEntity({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'daily',
    this.type = 'single',
    this.difficulty = 1,
    this.tasks = const [],
    this.totalXpReward = 0,
    this.itemRewards = const {},
    this.startTime,
    this.endTime,
    this.prerequisites = const [],
    this.isActive = true,
    this.isCompleted = false,
    this.nextQuestId,
    this.metadata = const {},
    required this.createdAt,
  });

  double get completionProgress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  bool get isExpired => endTime != null && DateTime.now().isAfter(endTime!);

  QuestEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? type,
    int? difficulty,
    List<QuestTaskEntity>? tasks,
    int? totalXpReward,
    Map<String, int>? itemRewards,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? prerequisites,
    bool? isActive,
    bool? isCompleted,
    String? nextQuestId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return QuestEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      tasks: tasks ?? this.tasks,
      totalXpReward: totalXpReward ?? this.totalXpReward,
      itemRewards: itemRewards ?? this.itemRewards,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      prerequisites: prerequisites ?? this.prerequisites,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      nextQuestId: nextQuestId ?? this.nextQuestId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        type,
        difficulty,
        tasks,
        totalXpReward,
        itemRewards,
        startTime,
        endTime,
        prerequisites,
        isActive,
        isCompleted,
        nextQuestId,
        metadata,
        createdAt,
      ];
}

class QuestTaskEntity extends Equatable {
  final String id;
  final String questId;
  final String description;
  final String targetType; // complete_tasks, meditate_minutes, read_pages, etc.
  final int targetValue;
  final int currentValue;
  final bool isCompleted;
  final int order;
  final DateTime? completedAt;

  const QuestTaskEntity({
    required this.id,
    required this.questId,
    required this.description,
    required this.targetType,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    this.order = 0,
    this.completedAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  QuestTaskEntity copyWith({
    String? id,
    String? questId,
    String? description,
    String? targetType,
    int? targetValue,
    int? currentValue,
    bool? isCompleted,
    int? order,
    DateTime? completedAt,
  }) {
    return QuestTaskEntity(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questId,
        description,
        targetType,
        targetValue,
        currentValue,
        isCompleted,
        order,
        completedAt,
      ];
}

class RewardEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // xp, item, avatar, title, etc.
  final String sourceType; // task, habit, achievement, quest, etc.
  final String sourceId;
  final int? xpAmount;
  final String? itemId;
  final int? itemQuantity;
  final String? title;
  final String? description;
  final DateTime earnedAt;
  final bool isClaimed;
  final DateTime? claimedAt;
  final String? rarity; // common, rare, epic, legendary
  final Map<String, dynamic> metadata;

  const RewardEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.sourceType,
    required this.sourceId,
    this.xpAmount,
    this.itemId,
    this.itemQuantity,
    this.title,
    this.description,
    required this.earnedAt,
    this.isClaimed = false,
    this.claimedAt,
    this.rarity,
    this.metadata = const {},
  });

  RewardEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? sourceType,
    String? sourceId,
    int? xpAmount,
    String? itemId,
    int? itemQuantity,
    String? title,
    String? description,
    DateTime? earnedAt,
    bool? isClaimed,
    DateTime? claimedAt,
    String? rarity,
    Map<String, dynamic>? metadata,
  }) {
    return RewardEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      xpAmount: xpAmount ?? this.xpAmount,
      itemId: itemId ?? this.itemId,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      title: title ?? this.title,
      description: description ?? this.description,
      earnedAt: earnedAt ?? this.earnedAt,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      rarity: rarity ?? this.rarity,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        sourceType,
        sourceId,
        xpAmount,
        itemId,
        itemQuantity,
        title,
        description,
        earnedAt,
        isClaimed,
        claimedAt,
        rarity,
        metadata,
      ];
}

class LeaderboardEntity extends Equatable {
  final String id;
  final String name;
  final String type; // global, weekly, monthly, friends, category
  final String category; // overall, habits, tasks, meditation, etc.
  final String period; // daily, weekly, monthly, all_time
  final List<LeaderboardEntryEntity> entries;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const LeaderboardEntity({
    required this.id,
    required this.name,
    required this.type,
    this.category = 'overall',
    this.period = 'weekly',
    this.entries = const [],
    required this.startDate,
    required this.endDate,
    required this.updatedAt,
    this.metadata = const {},
  });

  LeaderboardEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? period,
    List<LeaderboardEntryEntity>? entries,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      period: period ?? this.period,
      entries: entries ?? this.entries,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, type, category, period, entries, startDate, endDate, updatedAt, metadata];
}

class LeaderboardEntryEntity extends Equatable {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int rank;
  final int score;
  final int level;
  final Map<String, dynamic> stats; // Category-specific stats
  final DateTime lastActiveAt;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.rank,
    required this.score,
    this.level = 1,
    this.stats = const {},
    required this.lastActiveAt,
  });

  LeaderboardEntryEntity copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? rank,
    int? score,
    int? level,
    Map<String, dynamic>? stats,
    DateTime? lastActiveAt,
  }) {
    return LeaderboardEntryEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      level: level ?? this.level,
      stats: stats ?? this.stats,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [userId, username, displayName, avatarUrl, rank, score, level, stats, lastActiveAt];
}
