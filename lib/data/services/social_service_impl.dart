import 'package:injectable/injectable.dart';
import '../../domain/entities/social_entity.dart';
import '../../core/utils/social_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class SocialService {
  Future<SocialProfileEntity> getUserProfile(String userId);
  Future<SocialProfileEntity> updateProfile(String userId, Map<String, dynamic> updates);
  Future<SocialConnectionEntity> followUser(String followerId, String followeeId);
  Future<bool> unfollowUser(String followerId, String followeeId);
  Future<List<SocialProfileEntity>> getFollowers(String userId);
  Future<List<SocialProfileEntity>> getFollowing(String userId);
  Future<SocialPostEntity> createPost(String userId, Map<String, dynamic> postData);
  Future<List<SocialPostEntity>> getFeed(String userId, {int? limit, String? cursor});
  Future<bool> likePost(String userId, String postId);
  Future<SocialCommentEntity> addComment(String userId, String postId, String content, {String? parentCommentId});
  Future<SocialChallengeEntity> createChallenge(String userId, Map<String, dynamic> challengeData);
  Future<List<SocialChallengeEntity>> getActiveChallenges({String? category});
  Future<bool> joinChallenge(String userId, String challengeId);
  Future<SocialMessageEntity> sendMessage(String senderId, String receiverId, String content);
  Future<List<String>> searchUsers(String query);
}

@LazySingleton(as: SocialService)
class SocialServiceImpl implements SocialService {
  @override
  Future<SocialProfileEntity> getUserProfile(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _generateMockProfile(userId);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<SocialProfileEntity> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final profile = await getUserProfile(userId);
      final now = DateTime.now();
      
      final updatedProfile = profile.copyWith(
        displayName: updates['display_name'] as String? ?? profile.displayName,
        username: updates['username'] as String? ?? profile.username,
        bio: updates['bio'] as String? ?? profile.bio,
        profileImageUrl: updates['profile_image_url'] as String? ?? profile.profileImageUrl,
        bannerImageUrl: updates['banner_image_url'] as String? ?? profile.bannerImageUrl,
        socialLinks: Map<String, String>.from(updates['social_links'] ?? profile.socialLinks),
        isPublic: updates['is_public'] as bool? ?? profile.isPublic,
        allowFollowing: updates['allow_following'] as bool? ?? profile.allowFollowing,
        showStats: updates['show_stats'] as bool? ?? profile.showStats,
        showAchievements: updates['show_achievements'] as bool? ?? profile.showAchievements,
        allowMessages: updates['allow_messages'] as bool? ?? profile.allowMessages,
        allowChallenges: updates['allow_challenges'] as bool? ?? profile.allowChallenges,
        privacySettings: Map<String, bool>.from(updates['privacy_settings'] ?? profile.privacySettings),
        updatedAt: now,
      );
      
      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<SocialConnectionEntity> followUser(String followerId, String followeeId) async {
    try {
      if (followerId == followeeId) {
        throw Exception('Cannot follow yourself');
      }
      
      final now = DateTime.now();
      final connectionId = 'conn_${now.millisecondsSinceEpoch}';
      
      // Check if already following
      final existingConnection = await _getConnection(followerId, followeeId);
      if (existingConnection != null) {
        throw Exception('Already following this user');
      }
      
      final connection = SocialConnectionEntity(
        id: connectionId,
        followerId: followerId,
        followeeId: followeeId,
        followedAt: now,
        status: 'accepted',
      );
      
      // Update follower/following counts
      await _updateFollowerCounts(followerId, followeeId);
      
      return connection;
    } catch (e) {
      throw Exception('Failed to follow user: ${e.toString()}');
    }
  }

  @override
  Future<bool> unfollowUser(String followerId, String followeeId) async {
    try {
      final connection = await _getConnection(followerId, followeeId);
      if (connection == null) {
        throw Exception('Not following this user');
      }
      
      // Remove connection and update counts
      await _removeConnection(connection.id);
      await _updateFollowerCounts(followerId, followeeId, isUnfollow: true);
      
      return true;
    } catch (e) {
      throw Exception('Failed to unfollow user: ${e.toString()}');
    }
  }

  @override
  Future<List<SocialProfileEntity>> getFollowers(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateMockFollowers(userId);
    } catch (e) {
      throw Exception('Failed to get followers: ${e.toString()}');
    }
  }

  @override
  Future<List<SocialProfileEntity>> getFollowing(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateMockFollowing(userId);
    } catch (e) {
      throw Exception('Failed to get following: ${e.toString()}');
    }
  }

  @override
  Future<SocialPostEntity> createPost(String userId, Map<String, dynamic> postData) async {
    try {
      final now = DateTime.now();
      final postId = 'post_${now.millisecondsSinceEpoch}';
      
      final post = SocialPostEntity(
        id: postId,
        authorId: userId,
        content: postData['content'] as String,
        postType: postData['post_type'] as String? ?? 'text',
        mediaUrls: (postData['media_urls'] as List<dynamic>?)?.cast<String>() ?? [],
        metadata: Map<String, dynamic>.from(postData['metadata'] ?? {}),
        tags: (postData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        mentions: (postData['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
        visibility: postData['visibility'] as String? ?? 'public',
        allowComments: postData['allow_comments'] as bool? ?? true,
        allowSharing: postData['allow_sharing'] as bool? ?? true,
        createdAt: now,
      );
      
      return post;
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<List<SocialPostEntity>> getFeed(String userId, {int? limit, String? cursor}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final mockPosts = _generateMockPosts();
      
      // Apply limit
      final feedLimit = limit ?? 20;
      return mockPosts.take(feedLimit).toList();
    } catch (e) {
      throw Exception('Failed to get feed: ${e.toString()}');
    }
  }

  @override
  Future<bool> likePost(String userId, String postId) async {
    try {
      final post = await _getPostById(postId);
      if (post == null) {
        throw Exception('Post not found');
      }
      
      final alreadyLiked = post.likedBy.contains(userId);
      
      if (alreadyLiked) {
        // Unlike
        final updatedLikedBy = post.likedBy.where((id) => id != userId).toList();
        final updatedPost = post.copyWith(
          likedBy: updatedLikedBy,
          likeCount: post.likeCount - 1,
        );
      } else {
        // Like
        final updatedLikedBy = [...post.likedBy, userId];
        final updatedPost = post.copyWith(
          likedBy: updatedLikedBy,
          likeCount: post.likeCount + 1,
        );
      }
      
      return !alreadyLiked; // Return new like status
    } catch (e) {
      throw Exception('Failed to like/unlike post: ${e.toString()}');
    }
  }

  @override
  Future<SocialCommentEntity> addComment(String userId, String postId, String content, {String? parentCommentId}) async {
    try {
      final now = DateTime.now();
      final commentId = 'comment_${now.millisecondsSinceEpoch}';
      
      final comment = SocialCommentEntity(
        id: commentId,
        postId: postId,
        authorId: userId,
        parentCommentId: parentCommentId,
        content: content,
        mentions: _extractMentions(content),
        createdAt: now,
      );
      
      // Update post comment count
      await _incrementPostCommentCount(postId);
      
      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<SocialChallengeEntity> createChallenge(String userId, Map<String, dynamic> challengeData) async {
    try {
      final now = DateTime.now();
      final challengeId = 'challenge_${now.millisecondsSinceEpoch}';
      
      final challenge = SocialChallengeEntity(
        id: challengeId,
        creatorId: userId,
        name: challengeData['name'] as String,
        description: challengeData['description'] as String,
        category: challengeData['category'] as String,
        challengeType: challengeData['challenge_type'] as String? ?? 'group',
        rules: Map<String, dynamic>.from(challengeData['rules'] ?? {}),
        goals: Map<String, dynamic>.from(challengeData['goals'] ?? {}),
        startDate: DateTime.parse(challengeData['start_date'] as String),
        endDate: DateTime.parse(challengeData['end_date'] as String),
        duration: DateTime.parse(challengeData['end_date'] as String)
            .difference(DateTime.parse(challengeData['start_date'] as String)),
        maxParticipants: challengeData['max_participants'] as int? ?? 100,
        isPublic: challengeData['is_public'] as bool? ?? true,
        allowJoining: challengeData['allow_joining'] as bool? ?? true,
        joinRequirement: challengeData['join_requirement'] as String? ?? 'open',
        xpReward: challengeData['xp_reward'] as int? ?? 0,
        badges: (challengeData['badges'] as List<dynamic>?)?.cast<String>() ?? [],
        allowChat: challengeData['allow_chat'] as bool? ?? true,
        allowEncouragement: challengeData['allow_encouragement'] as bool? ?? true,
        status: 'upcoming',
        createdAt: now,
      );
      
      return challenge;
    } catch (e) {
      throw Exception('Failed to create challenge: ${e.toString()}');
    }
  }

  @override
  Future<List<SocialChallengeEntity>> getActiveChallenges({String? category}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      final mockChallenges = _generateMockChallenges();
      
      List<SocialChallengeEntity> activeChallenges = mockChallenges
          .where((challenge) => challenge.isActive)
          .toList();
      
      if (category != null) {
        activeChallenges = activeChallenges
            .where((challenge) => challenge.category == category)
            .toList();
      }
      
      return activeChallenges;
    } catch (e) {
      throw Exception('Failed to get active challenges: ${e.toString()}');
    }
  }

  @override
  Future<bool> joinChallenge(String userId, String challengeId) async {
    try {
      final challenge = await _getChallengeById(challengeId);
      if (challenge == null) {
        throw Exception('Challenge not found');
      }
      
      if (!challenge.canJoin) {
        throw Exception('Cannot join this challenge');
      }
      
      if (challenge.participants.contains(userId)) {
        throw Exception('Already participating in this challenge');
      }
      
      // Add user to challenge participants
      final updatedChallenge = challenge.copyWith(
        participants: [...challenge.participants, userId],
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to join challenge: ${e.toString()}');
    }
  }

  @override
  Future<SocialMessageEntity> sendMessage(String senderId, String receiverId, String content) async {
    try {
      if (senderId == receiverId) {
        throw Exception('Cannot send message to yourself');
      }
      
      final now = DateTime.now();
      final messageId = 'msg_${now.millisecondsSinceEpoch}';
      
      // Check if user allows messages
      final receiverProfile = await getUserProfile(receiverId);
      if (!receiverProfile.allowMessages) {
        throw Exception('User does not accept messages');
      }
      
      final message = SocialMessageEntity(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        messageType: 'text',
        isDelivered: true,
        deliveredAt: now,
        sentAt: now,
      );
      
      return message;
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> searchUsers(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Mock user search
      final mockUsers = [
        'john_doe',
        'jane_smith',
        'fitness_guru',
        'productivity_pro',
        'meditation_master',
      ];
      
      if (query.isEmpty) return mockUsers.take(5).toList();
      
      return mockUsers
          .where((username) => username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  // Private helper methods
  SocialProfileEntity _generateMockProfile(String userId) {
    final now = DateTime.now();
    
    return SocialProfileEntity(
      id: 'profile_$userId',
      userId: userId,
      displayName: 'Productivity Enthusiast',
      username: 'prod_user_${userId.substring(0, 4)}',
      bio: 'Building better habits one day at a time! 🚀',
      profileImageUrl: 'https://example.com/profile_${userId}.jpg',
      socialLinks: {
        'twitter': '@prod_user',
        'linkedin': 'linkedin.com/in/prod-user',
      },
      isPublic: true,
      allowFollowing: true,
      showStats: true,
      showAchievements: true,
      followerCount: 145,
      followingCount: 89,
      totalXP: 2350,
      currentLevel: 12,
      topAchievements: ['habit_master', 'consistency_king', 'social_butterfly'],
      categoryStats: {
        'productivity': 85,
        'fitness': 72,
        'mindfulness': 68,
      },
      totalStreaks: 15,
      longestStreak: 45,
      allowMessages: true,
      allowChallenges: true,
      badges: ['verified_user', 'top_contributor'],
      createdAt: now.subtract(const Duration(days: 90)),
    );
  }

  List<SocialProfileEntity> _generateMockFollowers(String userId) {
    final now = DateTime.now();
    
    return [
      SocialProfileEntity(
        id: 'profile_follower_1',
        userId: 'follower_1',
        displayName: 'Jane Smith',
        username: 'jane_s',
        bio: 'Fitness enthusiast and habit tracker',
        profileImageUrl: 'https://example.com/jane.jpg',
        followerCount: 234,
        followingCount: 156,
        totalXP: 1890,
        currentLevel: 9,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      SocialProfileEntity(
        id: 'profile_follower_2',
        userId: 'follower_2',
        displayName: 'Mike Johnson',
        username: 'mike_j',
        bio: 'Meditation practitioner',
        profileImageUrl: 'https://example.com/mike.jpg',
        followerCount: 89,
        followingCount: 67,
        totalXP: 1245,
        currentLevel: 7,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  List<SocialProfileEntity> _generateMockFollowing(String userId) {
    return _generateMockFollowers(userId); // Simplified for mock
  }

  List<SocialPostEntity> _generateMockPosts() {
    final now = DateTime.now();
    
    return [
      SocialPostEntity(
        id: 'post_1',
        authorId: 'user_1',
        content: 'Just completed my 30-day meditation streak! Feeling more focused and calm than ever. 🧘‍♂️ #meditation #mindfulness',
        postType: 'achievement',
        metadata: {
          'achievement_id': 'meditation_streak_30',
          'streak_count': 30,
        },
        tags: ['meditation', 'mindfulness', 'streak'],
        likeCount: 24,
        commentCount: 8,
        shareCount: 5,
        likedBy: ['user_2', 'user_3', 'user_4'],
        visibility: 'public',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      SocialPostEntity(
        id: 'post_2',
        authorId: 'user_2',
        content: 'Who wants to join my 7-day reading challenge? Let\'s read for at least 30 minutes each day! 📚',
        postType: 'text',
        tags: ['reading', 'challenge', 'books'],
        likeCount: 12,
        commentCount: 15,
        shareCount: 3,
        likedBy: ['user_1', 'user_5'],
        visibility: 'public',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<SocialChallengeEntity> _generateMockChallenges() {
    final now = DateTime.now();
    
    return [
      SocialChallengeEntity(
        id: 'challenge_1',
        creatorId: 'user_creator_1',
        name: '30-Day Fitness Challenge',
        description: 'Work out for at least 30 minutes every day for 30 days',
        category: 'fitness',
        challengeType: 'group',
        rules: {
          'min_workout_duration': 30,
          'daily_requirement': true,
          'rest_days_allowed': 2,
        },
        goals: {
          'total_workouts': 28,
          'total_minutes': 840,
        },
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 31)),
        duration: const Duration(days: 30),
        participants: ['user_1', 'user_2', 'user_3'],
        maxParticipants: 50,
        currentLeader: 'user_1',
        xpReward: 500,
        badges: ['fitness_warrior', 'consistency_champion'],
        status: 'upcoming',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<SocialConnectionEntity?> _getConnection(String followerId, String followeeId) async {
    // Mock connection lookup
    return null; // Simplified for demo
  }

  Future<SocialPostEntity?> _getPostById(String postId) async {
    final posts = _generateMockPosts();
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  Future<SocialChallengeEntity?> _getChallengeById(String challengeId) async {
    final challenges = _generateMockChallenges();
    try {
      return challenges.firstWhere((challenge) => challenge.id == challengeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateFollowerCounts(String followerId, String followeeId, {bool isUnfollow = false}) async {
    // Mock follower count update
    print('Updated follower counts: $followerId -> $followeeId (unfollow: $isUnfollow)');
  }

  Future<void> _removeConnection(String connectionId) async {
    // Mock connection removal
    print('Removed connection: $connectionId');
  }

  Future<void> _incrementPostCommentCount(String postId) async {
    // Mock comment count increment
    print('Incremented comment count for post: $postId');
  }

  List<String> _extractMentions(String content) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }
}
