import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  
  // Gamification
  final int totalXp;
  final int currentLevel;
  final Map<String, int> categoryXp;
  final List<String> unlockedAchievements;
  final Map<String, int> streaks;
  final String? currentAvatar;
  final List<String> unlockedAvatars;
  final Map<String, int> skillPoints;
  
  // Preferences
  final String timezone;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final Map<String, bool> categoryNotifications;
  final Map<String, dynamic> preferences;
  
  // Statistics
  final Map<String, dynamic> statistics;
  final DateTime? lastActiveDate;
  final int consecutiveDays;
  final int totalSessions;
  
  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.categoryXp = const {},
    this.unlockedAchievements = const [],
    this.streaks = const {},
    this.currentAvatar,
    this.unlockedAvatars = const [],
    this.skillPoints = const {},
    this.timezone = 'UTC',
    this.language = 'en',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.categoryNotifications = const {},
    this.preferences = const {},
    this.statistics = const {},
    this.lastActiveDate,
    this.consecutiveDays = 0,
    this.totalSessions = 0,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    int? totalXp,
    int? currentLevel,
    Map<String, int>? categoryXp,
    List<String>? unlockedAchievements,
    Map<String, int>? streaks,
    String? currentAvatar,
    List<String>? unlockedAvatars,
    Map<String, int>? skillPoints,
    String? timezone,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    Map<String, bool>? categoryNotifications,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? statistics,
    DateTime? lastActiveDate,
    int? consecutiveDays,
    int? totalSessions,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      categoryXp: categoryXp ?? this.categoryXp,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      streaks: streaks ?? this.streaks,
      currentAvatar: currentAvatar ?? this.currentAvatar,
      unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
      skillPoints: skillPoints ?? this.skillPoints,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      categoryNotifications: categoryNotifications ?? this.categoryNotifications,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        displayName,
        profileImageUrl,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        isPremium,
        premiumExpiresAt,
        totalXp,
        currentLevel,
        categoryXp,
        unlockedAchievements,
        streaks,
        currentAvatar,
        unlockedAvatars,
        skillPoints,
        timezone,
        language,
        theme,
        notificationsEnabled,
        categoryNotifications,
        preferences,
        statistics,
        lastActiveDate,
        consecutiveDays,
        totalSessions,
      ];
}
