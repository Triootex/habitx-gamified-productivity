import 'package:equatable/equatable.dart';

class SocialProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final String? bannerImageUrl;
  final Map<String, String> socialLinks;
  final bool isPublic;
  final bool allowFollowing;
  final bool showStats;
  final bool showAchievements;
  
  // Stats and progress
  final int followerCount;
  final int followingCount;
  final int totalXP;
  final int currentLevel;
  final List<String> topAchievements;
  final Map<String, int> categoryStats;
  final int totalStreaks;
  final int longestStreak;
  
  // Privacy settings
  final Map<String, bool> privacySettings;
  final List<String> blockedUsers;
  final bool allowMessages;
  final bool allowChallenges;
  
  // Verification and badges
  final bool isVerified;
  final List<String> badges;
  final String? verificationReason;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SocialProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.username,
    this.bio,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.socialLinks = const {},
    this.isPublic = true,
    this.allowFollowing = true,
    this.showStats = true,
    this.showAchievements = true,
    this.followerCount = 0,
    this.followingCount = 0,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.topAchievements = const [],
    this.categoryStats = const {},
    this.totalStreaks = 0,
    this.longestStreak = 0,
    this.privacySettings = const {},
    this.blockedUsers = const [],
    this.allowMessages = true,
    this.allowChallenges = true,
    this.isVerified = false,
    this.badges = const [],
    this.verificationReason,
    required this.createdAt,
    this.updatedAt,
  });

  SocialProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? username,
    String? bio,
    String? profileImageUrl,
    String? bannerImageUrl,
    Map<String, String>? socialLinks,
    bool? isPublic,
    bool? allowFollowing,
    bool? showStats,
    bool? showAchievements,
    int? followerCount,
    int? followingCount,
    int? totalXP,
    int? currentLevel,
    List<String>? topAchievements,
    Map<String, int>? categoryStats,
    int? totalStreaks,
    int? longestStreak,
    Map<String, bool>? privacySettings,
    List<String>? blockedUsers,
    bool? allowMessages,
    bool? allowChallenges,
    bool? isVerified,
    List<String>? badges,
    String? verificationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      isPublic: isPublic ?? this.isPublic,
      allowFollowing: allowFollowing ?? this.allowFollowing,
      showStats: showStats ?? this.showStats,
      showAchievements: showAchievements ?? this.showAchievements,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      topAchievements: topAchievements ?? this.topAchievements,
      categoryStats: categoryStats ?? this.categoryStats,
      totalStreaks: totalStreaks ?? this.totalStreaks,
      longestStreak: longestStreak ?? this.longestStreak,
      privacySettings: privacySettings ?? this.privacySettings,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      allowMessages: allowMessages ?? this.allowMessages,
      allowChallenges: allowChallenges ?? this.allowChallenges,
      isVerified: isVerified ?? this.isVerified,
      badges: badges ?? this.badges,
      verificationReason: verificationReason ?? this.verificationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        username,
        bio,
        profileImageUrl,
        bannerImageUrl,
        socialLinks,
        isPublic,
        allowFollowing,
        showStats,
        showAchievements,
        followerCount,
        followingCount,
        totalXP,
        currentLevel,
        topAchievements,
        categoryStats,
        totalStreaks,
        longestStreak,
        privacySettings,
        blockedUsers,
        allowMessages,
        allowChallenges,
        isVerified,
        badges,
        verificationReason,
        createdAt,
        updatedAt,
      ];
}

class SocialConnectionEntity extends Equatable {
  final String id;
  final String followerId;
  final String followeeId;
  final DateTime followedAt;
  final String status; // pending, accepted, blocked
  final bool isMutual; // Both users follow each other
  final bool isClose; // Close friend designation
  final Map<String, dynamic> connectionData;

  const SocialConnectionEntity({
    required this.id,
    required this.followerId,
    required this.followeeId,
    required this.followedAt,
    this.status = 'accepted',
    this.isMutual = false,
    this.isClose = false,
    this.connectionData = const {},
  });

  SocialConnectionEntity copyWith({
    String? id,
    String? followerId,
    String? followeeId,
    DateTime? followedAt,
    String? status,
    bool? isMutual,
    bool? isClose,
    Map<String, dynamic>? connectionData,
  }) {
    return SocialConnectionEntity(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followeeId: followeeId ?? this.followeeId,
      followedAt: followedAt ?? this.followedAt,
      status: status ?? this.status,
      isMutual: isMutual ?? this.isMutual,
      isClose: isClose ?? this.isClose,
      connectionData: connectionData ?? this.connectionData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        followerId,
        followeeId,
        followedAt,
        status,
        isMutual,
        isClose,
        connectionData,
      ];
}

class SocialPostEntity extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final String postType; // text, achievement, progress, image, video
  final List<String> mediaUrls;
  final Map<String, dynamic> metadata; // Achievement data, progress data, etc.
  final List<String> tags;
  final List<String> mentions;
  
  // Engagement
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> likedBy;
  
  // Visibility
  final String visibility; // public, followers, friends, private
  final List<String> sharedWith; // Specific users for private posts
  final bool allowComments;
  final bool allowSharing;
  
  // Content moderation
  final bool isReported;
  final List<String> reportReasons;
  final bool isHidden;
  final String? moderationStatus;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const SocialPostEntity({
    required this.id,
    required this.authorId,
    required this.content,
    this.postType = 'text',
    this.mediaUrls = const [],
    this.metadata = const {},
    this.tags = const [],
    this.mentions = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likedBy = const [],
    this.visibility = 'public',
    this.sharedWith = const [],
    this.allowComments = true,
    this.allowSharing = true,
    this.isReported = false,
    this.reportReasons = const [],
    this.isHidden = false,
    this.moderationStatus,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get hasMedia => mediaUrls.isNotEmpty;

  SocialPostEntity copyWith({
    String? id,
    String? authorId,
    String? content,
    String? postType,
    List<String>? mediaUrls,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    List<String>? mentions,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<String>? likedBy,
    String? visibility,
    List<String>? sharedWith,
    bool? allowComments,
    bool? allowSharing,
    bool? isReported,
    List<String>? reportReasons,
    bool? isHidden,
    String? moderationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return SocialPostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      mentions: mentions ?? this.mentions,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likedBy: likedBy ?? this.likedBy,
      visibility: visibility ?? this.visibility,
      sharedWith: sharedWith ?? this.sharedWith,
      allowComments: allowComments ?? this.allowComments,
      allowSharing: allowSharing ?? this.allowSharing,
      isReported: isReported ?? this.isReported,
      reportReasons: reportReasons ?? this.reportReasons,
      isHidden: isHidden ?? this.isHidden,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        content,
        postType,
        mediaUrls,
        metadata,
        tags,
        mentions,
        likeCount,
        commentCount,
        shareCount,
        likedBy,
        visibility,
        sharedWith,
        allowComments,
        allowSharing,
        isReported,
        reportReasons,
        isHidden,
        moderationStatus,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}

class SocialCommentEntity extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String? parentCommentId; // For nested comments
  final String content;
  final List<String> mentions;
  final int likeCount;
  final List<String> likedBy;
  final bool isReported;
  final List<String> reportReasons;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const SocialCommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentCommentId,
    required this.content,
    this.mentions = const [],
    this.likeCount = 0,
    this.likedBy = const [],
    this.isReported = false,
    this.reportReasons = const [],
    this.isHidden = false,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get isReply => parentCommentId != null;

  SocialCommentEntity copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? parentCommentId,
    String? content,
    List<String>? mentions,
    int? likeCount,
    List<String>? likedBy,
    bool? isReported,
    List<String>? reportReasons,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return SocialCommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      mentions: mentions ?? this.mentions,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      isReported: isReported ?? this.isReported,
      reportReasons: reportReasons ?? this.reportReasons,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        parentCommentId,
        content,
        mentions,
        likeCount,
        likedBy,
        isReported,
        reportReasons,
        isHidden,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}

class SocialChallengeEntity extends Equatable {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final String category; // productivity, wellness, learning, etc.
  final String challengeType; // individual, group, vs_friends
  final Map<String, dynamic> rules;
  final Map<String, dynamic> goals;
  
  // Timing
  final DateTime startDate;
  final DateTime endDate;
  final Duration duration;
  final String frequency; // daily, weekly, custom
  
  // Participation
  final List<String> participants;
  final int maxParticipants;
  final bool isPublic;
  final bool allowJoining;
  final String joinRequirement; // open, request, invite_only
  
  // Progress and leaderboard
  final Map<String, dynamic> leaderboard;
  final Map<String, Map<String, dynamic>> participantProgress;
  final String? currentLeader;
  
  // Rewards
  final Map<String, dynamic> rewards; // Position -> reward
  final int xpReward;
  final List<String> badges;
  
  // Social features
  final bool allowChat;
  final bool allowEncouragement;
  final List<String> updates;
  final Map<String, dynamic> chatData;
  
  final String status; // upcoming, active, completed, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SocialChallengeEntity({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.category,
    this.challengeType = 'individual',
    this.rules = const {},
    this.goals = const {},
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.frequency = 'daily',
    this.participants = const [],
    this.maxParticipants = 100,
    this.isPublic = true,
    this.allowJoining = true,
    this.joinRequirement = 'open',
    this.leaderboard = const {},
    this.participantProgress = const {},
    this.currentLeader,
    this.rewards = const {},
    this.xpReward = 0,
    this.badges = const [],
    this.allowChat = true,
    this.allowEncouragement = true,
    this.updates = const [],
    this.chatData = const {},
    this.status = 'upcoming',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get canJoin => allowJoining && participants.length < maxParticipants;
  int get participantCount => participants.length;

  SocialChallengeEntity copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    String? category,
    String? challengeType,
    Map<String, dynamic>? rules,
    Map<String, dynamic>? goals,
    DateTime? startDate,
    DateTime? endDate,
    Duration? duration,
    String? frequency,
    List<String>? participants,
    int? maxParticipants,
    bool? isPublic,
    bool? allowJoining,
    String? joinRequirement,
    Map<String, dynamic>? leaderboard,
    Map<String, Map<String, dynamic>>? participantProgress,
    String? currentLeader,
    Map<String, dynamic>? rewards,
    int? xpReward,
    List<String>? badges,
    bool? allowChat,
    bool? allowEncouragement,
    List<String>? updates,
    Map<String, dynamic>? chatData,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialChallengeEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      challengeType: challengeType ?? this.challengeType,
      rules: rules ?? this.rules,
      goals: goals ?? this.goals,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isPublic: isPublic ?? this.isPublic,
      allowJoining: allowJoining ?? this.allowJoining,
      joinRequirement: joinRequirement ?? this.joinRequirement,
      leaderboard: leaderboard ?? this.leaderboard,
      participantProgress: participantProgress ?? this.participantProgress,
      currentLeader: currentLeader ?? this.currentLeader,
      rewards: rewards ?? this.rewards,
      xpReward: xpReward ?? this.xpReward,
      badges: badges ?? this.badges,
      allowChat: allowChat ?? this.allowChat,
      allowEncouragement: allowEncouragement ?? this.allowEncouragement,
      updates: updates ?? this.updates,
      chatData: chatData ?? this.chatData,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        name,
        description,
        category,
        challengeType,
        rules,
        goals,
        startDate,
        endDate,
        duration,
        frequency,
        participants,
        maxParticipants,
        isPublic,
        allowJoining,
        joinRequirement,
        leaderboard,
        participantProgress,
        currentLeader,
        rewards,
        xpReward,
        badges,
        allowChat,
        allowEncouragement,
        updates,
        chatData,
        status,
        createdAt,
        updatedAt,
      ];
}

class SocialMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String? conversationId;
  final String content;
  final String messageType; // text, image, achievement, challenge_invite
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime? readAt;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final DateTime sentAt;
  final DateTime? deletedAt;

  const SocialMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.conversationId,
    required this.content,
    this.messageType = 'text',
    this.attachments = const [],
    this.metadata = const {},
    this.isRead = false,
    this.readAt,
    this.isDelivered = false,
    this.deliveredAt,
    required this.sentAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  SocialMessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? conversationId,
    String? content,
    String? messageType,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? readAt,
    bool? isDelivered,
    DateTime? deliveredAt,
    DateTime? sentAt,
    DateTime? deletedAt,
  }) {
    return SocialMessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      sentAt: sentAt ?? this.sentAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        conversationId,
        content,
        messageType,
        attachments,
        metadata,
        isRead,
        readAt,
        isDelivered,
        deliveredAt,
        sentAt,
        deletedAt,
      ];
}
