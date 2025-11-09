import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/social_entity.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Get User Social Profile Use Case
@injectable
class GetUserSocialProfileUseCase implements UseCase<SocialProfileEntity, String> {
  final SocialRepository repository;

  GetUserSocialProfileUseCase(this.repository);

  @override
  Future<Either<Failure, SocialProfileEntity>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}

// Update Social Profile Use Case
@injectable
class UpdateSocialProfileUseCase implements UseCase<SocialProfileEntity, UpdateSocialProfileParams> {
  final SocialRepository repository;

  UpdateSocialProfileUseCase(this.repository);

  @override
  Future<Either<Failure, SocialProfileEntity>> call(UpdateSocialProfileParams params) async {
    return await repository.updateProfile(params.userId, params.updates);
  }
}

class UpdateSocialProfileParams {
  final String userId;
  final Map<String, dynamic> updates;

  UpdateSocialProfileParams({required this.userId, required this.updates});
}

// Follow User Use Case
@injectable
class FollowUserUseCase implements UseCase<SocialConnectionEntity, FollowUserParams> {
  final SocialRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, SocialConnectionEntity>> call(FollowUserParams params) async {
    return await repository.followUser(params.followerId, params.followeeId);
  }
}

class FollowUserParams {
  final String followerId;
  final String followeeId;

  FollowUserParams({required this.followerId, required this.followeeId});
}

// Unfollow User Use Case
@injectable
class UnfollowUserUseCase implements UseCase<bool, UnfollowUserParams> {
  final SocialRepository repository;

  UnfollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UnfollowUserParams params) async {
    return await repository.unfollowUser(params.followerId, params.followeeId);
  }
}

class UnfollowUserParams {
  final String followerId;
  final String followeeId;

  UnfollowUserParams({required this.followerId, required this.followeeId});
}

// Get Followers Use Case
@injectable
class GetFollowersUseCase implements UseCase<List<SocialProfileEntity>, String> {
  final SocialRepository repository;

  GetFollowersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SocialProfileEntity>>> call(String userId) async {
    return await repository.getFollowers(userId);
  }
}

// Get Following Use Case
@injectable
class GetFollowingUseCase implements UseCase<List<SocialProfileEntity>, String> {
  final SocialRepository repository;

  GetFollowingUseCase(this.repository);

  @override
  Future<Either<Failure, List<SocialProfileEntity>>> call(String userId) async {
    return await repository.getFollowing(userId);
  }
}

// Create Social Post Use Case
@injectable
class CreateSocialPostUseCase implements UseCase<SocialPostEntity, CreateSocialPostParams> {
  final SocialRepository repository;

  CreateSocialPostUseCase(this.repository);

  @override
  Future<Either<Failure, SocialPostEntity>> call(CreateSocialPostParams params) async {
    return await repository.createPost(params.userId, params.postData);
  }
}

class CreateSocialPostParams {
  final String userId;
  final Map<String, dynamic> postData;

  CreateSocialPostParams({required this.userId, required this.postData});
}

// Get Social Feed Use Case
@injectable
class GetSocialFeedUseCase implements UseCase<List<SocialPostEntity>, GetSocialFeedParams> {
  final SocialRepository repository;

  GetSocialFeedUseCase(this.repository);

  @override
  Future<Either<Failure, List<SocialPostEntity>>> call(GetSocialFeedParams params) async {
    return await repository.getFeed(params.userId, limit: params.limit, cursor: params.cursor);
  }
}

class GetSocialFeedParams {
  final String userId;
  final int? limit;
  final String? cursor;

  GetSocialFeedParams({required this.userId, this.limit, this.cursor});
}

// Like Post Use Case
@injectable
class LikePostUseCase implements UseCase<bool, LikePostParams> {
  final SocialRepository repository;

  LikePostUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(LikePostParams params) async {
    return await repository.likePost(params.userId, params.postId);
  }
}

class LikePostParams {
  final String userId;
  final String postId;

  LikePostParams({required this.userId, required this.postId});
}

// Add Comment Use Case
@injectable
class AddCommentUseCase implements UseCase<SocialCommentEntity, AddCommentParams> {
  final SocialRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, SocialCommentEntity>> call(AddCommentParams params) async {
    return await repository.addComment(
      params.userId, 
      params.postId, 
      params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}

class AddCommentParams {
  final String userId;
  final String postId;
  final String content;
  final String? parentCommentId;

  AddCommentParams({
    required this.userId,
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}

// Create Social Challenge Use Case
@injectable
class CreateSocialChallengeUseCase implements UseCase<SocialChallengeEntity, CreateSocialChallengeParams> {
  final SocialRepository repository;

  CreateSocialChallengeUseCase(this.repository);

  @override
  Future<Either<Failure, SocialChallengeEntity>> call(CreateSocialChallengeParams params) async {
    return await repository.createChallenge(params.userId, params.challengeData);
  }
}

class CreateSocialChallengeParams {
  final String userId;
  final Map<String, dynamic> challengeData;

  CreateSocialChallengeParams({required this.userId, required this.challengeData});
}

// Get Active Challenges Use Case
@injectable
class GetActiveChallengesUseCase implements UseCase<List<SocialChallengeEntity>, GetActiveChallengesParams> {
  final SocialRepository repository;

  GetActiveChallengesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SocialChallengeEntity>>> call(GetActiveChallengesParams params) async {
    return await repository.getActiveChallenges(category: params.category);
  }
}

class GetActiveChallengesParams {
  final String? category;

  GetActiveChallengesParams({this.category});
}

// Join Challenge Use Case
@injectable
class JoinChallengeUseCase implements UseCase<bool, JoinChallengeParams> {
  final SocialRepository repository;

  JoinChallengeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(JoinChallengeParams params) async {
    return await repository.joinChallenge(params.userId, params.challengeId);
  }
}

class JoinChallengeParams {
  final String userId;
  final String challengeId;

  JoinChallengeParams({required this.userId, required this.challengeId});
}

// Send Message Use Case
@injectable
class SendMessageUseCase implements UseCase<SocialMessageEntity, SendMessageParams> {
  final SocialRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, SocialMessageEntity>> call(SendMessageParams params) async {
    return await repository.sendMessage(params.senderId, params.receiverId, params.content);
  }
}

class SendMessageParams {
  final String senderId;
  final String receiverId;
  final String content;

  SendMessageParams({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });
}

// Search Users Use Case
@injectable
class SearchUsersUseCase implements UseCase<List<String>, String> {
  final SocialRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String query) async {
    return await repository.searchUsers(query);
  }
}

// Sync Social Data Use Case
@injectable
class SyncSocialDataUseCase implements UseCase<bool, String> {
  final SocialRepository repository;

  SyncSocialDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncSocialData(userId);
  }
}

// Calculate Social Score Use Case
@injectable
class CalculateSocialScoreUseCase implements UseCase<Map<String, dynamic>, String> {
  final SocialRepository repository;

  CalculateSocialScoreUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final profileResult = await repository.getUserProfile(userId);
      final followersResult = await repository.getFollowers(userId);
      final followingResult = await repository.getFollowing(userId);
      
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          final followers = await followersResult.fold(
            (failure) => <SocialProfileEntity>[],
            (list) => list,
          );
          
          final following = await followingResult.fold(
            (failure) => <SocialProfileEntity>[],
            (list) => list,
          );
          
          final socialScore = _calculateSocialScore(profile, followers, following);
          return Right(socialScore);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate social score: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateSocialScore(
    SocialProfileEntity profile,
    List<SocialProfileEntity> followers,
    List<SocialProfileEntity> following,
  ) {
    // Calculate engagement metrics
    final followerCount = followers.length;
    final followingCount = following.length;
    final postCount = profile.postCount ?? 0;
    final likesReceived = profile.totalLikesReceived ?? 0;
    final commentsReceived = profile.totalCommentsReceived ?? 0;
    
    // Calculate engagement rate
    final engagementRate = postCount > 0 
        ? ((likesReceived + commentsReceived) / (postCount * followerCount.clamp(1, double.infinity))) * 100
        : 0.0;
    
    // Calculate follower-to-following ratio (influence score)
    final influenceRatio = followingCount > 0 ? followerCount / followingCount : followerCount.toDouble();
    
    // Calculate social score components (0-100 scale)
    final networkSize = _calculateNetworkScore(followerCount);
    final engagementScore = engagementRate.clamp(0, 100);
    final influenceScore = _calculateInfluenceScore(influenceRatio);
    final activityScore = _calculateActivityScore(postCount, profile.joinedAt);
    
    // Overall social score (weighted average)
    final socialScore = (
      (networkSize * 0.25) + // 25% network size
      (engagementScore * 0.30) + // 30% engagement
      (influenceScore * 0.25) + // 25% influence
      (activityScore * 0.20) // 20% activity
    ).round();
    
    final socialLevel = _getSocialLevel(socialScore);
    final recommendations = _generateSocialRecommendations(
      followerCount, engagementRate, postCount, influenceRatio
    );
    
    return {
      'social_score': socialScore,
      'network_size_score': networkSize.round(),
      'engagement_score': engagementScore.round(),
      'influence_score': influenceScore.round(),
      'activity_score': activityScore.round(),
      'social_level': socialLevel,
      'followers_count': followerCount,
      'following_count': followingCount,
      'posts_count': postCount,
      'engagement_rate': double.parse(engagementRate.toStringAsFixed(2)),
      'influence_ratio': double.parse(influenceRatio.toStringAsFixed(2)),
      'recommendations': recommendations,
    };
  }

  double _calculateNetworkScore(int followerCount) {
    // Logarithmic scoring for network size
    if (followerCount <= 0) return 0;
    if (followerCount >= 1000) return 100;
    
    // Scale from 0-100 based on follower milestones
    if (followerCount >= 500) return 90;
    if (followerCount >= 100) return 70;
    if (followerCount >= 50) return 50;
    if (followerCount >= 10) return 30;
    return followerCount * 3.0; // 3 points per follower up to 10
  }

  double _calculateInfluenceScore(double influenceRatio) {
    // Score based on follower-to-following ratio
    if (influenceRatio >= 10) return 100; // High influence
    if (influenceRatio >= 5) return 80;
    if (influenceRatio >= 2) return 60;
    if (influenceRatio >= 1) return 40;
    if (influenceRatio >= 0.5) return 20;
    return 10; // Follow more than followers
  }

  double _calculateActivityScore(int postCount, DateTime? joinedAt) {
    if (joinedAt == null) return 50; // Default for unknown join date
    
    final daysSinceJoined = DateTime.now().difference(joinedAt).inDays;
    if (daysSinceJoined <= 0) return 0;
    
    final postsPerDay = postCount / daysSinceJoined;
    
    // Optimal posting frequency: 0.5-2 posts per day
    if (postsPerDay >= 0.5 && postsPerDay <= 2) return 100;
    if (postsPerDay >= 0.2 && postsPerDay < 0.5) return 70;
    if (postsPerDay > 2 && postsPerDay <= 5) return 80;
    if (postsPerDay > 5) return 50; // Too much posting
    return (postsPerDay * 100).clamp(0, 50); // Low activity
  }

  String _getSocialLevel(int score) {
    if (score >= 90) return 'Social Influencer';
    if (score >= 80) return 'Community Leader';
    if (score >= 70) return 'Active Member';
    if (score >= 60) return 'Regular User';
    if (score >= 40) return 'Casual User';
    if (score >= 20) return 'Newcomer';
    return 'Getting Started';
  }

  List<String> _generateSocialRecommendations(
    int followerCount,
    double engagementRate,
    int postCount,
    double influenceRatio,
  ) {
    final recommendations = <String>[];
    
    if (followerCount < 10) {
      recommendations.add('Connect with friends and follow users with similar interests');
    } else if (followerCount < 50) {
      recommendations.add('Engage with others\' content to grow your network');
    }
    
    if (engagementRate < 5) {
      recommendations.add('Post more engaging content to increase likes and comments');
    } else if (engagementRate > 50) {
      recommendations.add('Great engagement! Consider posting more frequently');
    }
    
    if (postCount == 0) {
      recommendations.add('Share your first post to start building your social presence');
    } else if (postCount < 10) {
      recommendations.add('Keep posting regularly to maintain visibility');
    }
    
    if (influenceRatio < 0.5) {
      recommendations.add('Focus on creating quality content to attract more followers');
    }
    
    recommendations.addAll([
      'Join challenges to meet like-minded people',
      'Comment thoughtfully on others\' posts',
      'Share your productivity achievements and milestones',
    ]);
    
    return recommendations.take(5).toList();
  }
}

// Get Social Insights Use Case
@injectable
class GetSocialInsightsUseCase implements UseCase<Map<String, dynamic>, String> {
  final SocialRepository repository;

  GetSocialInsightsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final feedResult = await repository.getFeed(userId, limit: 50);
      
      return feedResult.fold(
        (failure) => Left(failure),
        (posts) {
          final insights = _generateSocialInsights(posts);
          return Right(insights);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to generate social insights: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _generateSocialInsights(List<SocialPostEntity> posts) {
    if (posts.isEmpty) {
      return {
        'insights': ['Follow more users to see content in your feed'],
        'engagement_patterns': {},
        'content_analysis': {},
        'suggestions': [
          'Follow users with similar productivity goals',
          'Engage with posts by liking and commenting',
          'Share your own progress and achievements'
        ],
      };
    }
    
    final insights = <String>[];
    
    // Analyze engagement patterns
    final hourlyEngagement = <int, int>{};
    final contentTypes = <String, int>{};
    
    for (final post in posts) {
      final hour = post.createdAt.hour;
      hourlyEngagement[hour] = (hourlyEngagement[hour] ?? 0) + (post.likesCount + post.commentsCount);
      
      final type = post.contentType ?? 'text';
      contentTypes[type] = (contentTypes[type] ?? 0) + 1;
    }
    
    // Find peak engagement hours
    if (hourlyEngagement.isNotEmpty) {
      final peakHour = hourlyEngagement.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Most engagement happens around ${_formatHour(peakHour.key)}');
    }
    
    // Analyze content types
    if (contentTypes.isNotEmpty) {
      final topContentType = contentTypes.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('${topContentType.key} posts are most common in your feed');
    }
    
    // Calculate average engagement
    final totalEngagement = posts.fold<int>(0, (sum, post) => sum + post.likesCount + post.commentsCount);
    final avgEngagement = totalEngagement / posts.length;
    insights.add('Average post engagement: ${avgEngagement.round()} interactions');
    
    final suggestions = _generateSocialSuggestions(posts, hourlyEngagement, contentTypes);
    
    return {
      'insights': insights,
      'engagement_patterns': {
        'hourly_engagement': hourlyEngagement,
        'peak_hour': hourlyEngagement.isNotEmpty 
            ? hourlyEngagement.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'average_engagement': avgEngagement.round(),
      },
      'content_analysis': {
        'content_types': contentTypes,
        'total_posts': posts.length,
        'posts_with_media': posts.where((p) => p.mediaUrls?.isNotEmpty == true).length,
      },
      'suggestions': suggestions,
    };
  }

  List<String> _generateSocialSuggestions(
    List<SocialPostEntity> posts,
    Map<int, int> hourlyEngagement,
    Map<String, int> contentTypes,
  ) {
    final suggestions = <String>[];
    
    if (hourlyEngagement.isNotEmpty) {
      final peakHour = hourlyEngagement.entries.reduce((a, b) => a.value > b.value ? a : b);
      suggestions.add('Post around ${_formatHour(peakHour.key)} for maximum engagement');
    }
    
    final mediaPercentage = posts.isNotEmpty 
        ? (posts.where((p) => p.mediaUrls?.isNotEmpty == true).length / posts.length) * 100
        : 0;
    
    if (mediaPercentage < 30) {
      suggestions.add('Posts with images or videos tend to get more engagement');
    }
    
    suggestions.addAll([
      'Ask questions in your posts to encourage comments',
      'Share your productivity tips and tricks',
      'Celebrate others\' achievements in the community',
      'Use relevant hashtags to increase discoverability',
    ]);
    
    return suggestions.take(5).toList();
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}
