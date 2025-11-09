import 'package:injectable/injectable.dart';
import '../../domain/entities/social_entity.dart';
import '../datasources/local/social_local_data_source.dart';
import '../datasources/remote/social_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SocialRepository {
  Future<Either<Failure, SocialProfileEntity>> getUserProfile(String userId);
  Future<Either<Failure, SocialProfileEntity>> updateProfile(String userId, Map<String, dynamic> updates);
  Future<Either<Failure, SocialConnectionEntity>> followUser(String followerId, String followeeId);
  Future<Either<Failure, bool>> unfollowUser(String followerId, String followeeId);
  Future<Either<Failure, List<SocialProfileEntity>>> getFollowers(String userId);
  Future<Either<Failure, List<SocialProfileEntity>>> getFollowing(String userId);
  Future<Either<Failure, SocialPostEntity>> createPost(String userId, Map<String, dynamic> postData);
  Future<Either<Failure, List<SocialPostEntity>>> getFeed(String userId, {int? limit, String? cursor});
  Future<Either<Failure, bool>> likePost(String userId, String postId);
  Future<Either<Failure, SocialCommentEntity>> addComment(String userId, String postId, String content, {String? parentCommentId});
  Future<Either<Failure, SocialChallengeEntity>> createChallenge(String userId, Map<String, dynamic> challengeData);
  Future<Either<Failure, List<SocialChallengeEntity>>> getActiveChallenges({String? category});
  Future<Either<Failure, bool>> joinChallenge(String userId, String challengeId);
  Future<Either<Failure, SocialMessageEntity>> sendMessage(String senderId, String receiverId, String content);
  Future<Either<Failure, List<String>>> searchUsers(String query);
  Future<Either<Failure, bool>> syncSocialData(String userId);
}

@LazySingleton(as: SocialRepository)
class SocialRepositoryImpl implements SocialRepository {
  final SocialLocalDataSource localDataSource;
  final SocialRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SocialRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SocialProfileEntity>> getUserProfile(String userId) async {
    try {
      SocialProfileEntity? localProfile;
      
      try {
        localProfile = await localDataSource.getUserProfile(userId);
      } on CacheException {
        // No local profile
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteProfile = await remoteDataSource.getUserProfile(userId);
          // Update local cache with remote data
          await localDataSource.cacheProfile(remoteProfile);
          return Right(remoteProfile);
        } catch (e) {
          if (localProfile != null) {
            return Right(localProfile);
          } else {
            return Left(ServerFailure('Failed to fetch profile and no local cache available'));
          }
        }
      }
      
      if (localProfile != null) {
        return Right(localProfile);
      } else {
        return Left(CacheFailure('Profile not found'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialProfileEntity>> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Update profile locally first
      final localProfile = await localDataSource.updateProfile(userId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteProfile = await remoteDataSource.updateProfile(userId, updates);
          // Update local sync status
          await localDataSource.updateProfile(userId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteProfile);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateProfile(userId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localProfile);
        }
      }
      
      return Right(localProfile);
    } on CacheException {
      return Left(CacheFailure('Failed to update profile locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update profile on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialConnectionEntity>> followUser(String followerId, String followeeId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to follow users'));
      }

      // Follow user on server
      final remoteConnection = await remoteDataSource.followUser(followerId, followeeId);
      
      // Cache connection locally
      await localDataSource.cacheConnection(remoteConnection);
      
      return Right(remoteConnection);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to follow user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> unfollowUser(String followerId, String followeeId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to unfollow users'));
      }

      // Unfollow user on server
      await remoteDataSource.unfollowUser(followerId, followeeId);
      
      // Remove connection from local cache
      await localDataSource.removeConnection(followerId, followeeId);
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to unfollow user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SocialProfileEntity>>> getFollowers(String userId) async {
    try {
      List<SocialProfileEntity> localFollowers = [];
      
      try {
        localFollowers = await localDataSource.getFollowers(userId);
      } on CacheException {
        // No local followers
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteFollowers = await remoteDataSource.getFollowers(userId);
          await localDataSource.cacheProfiles(remoteFollowers);
          return Right(remoteFollowers);
        } catch (e) {
          if (localFollowers.isNotEmpty) {
            return Right(localFollowers);
          } else {
            return Left(ServerFailure('Failed to fetch followers'));
          }
        }
      }
      
      return Right(localFollowers);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SocialProfileEntity>>> getFollowing(String userId) async {
    try {
      List<SocialProfileEntity> localFollowing = [];
      
      try {
        localFollowing = await localDataSource.getFollowing(userId);
      } on CacheException {
        // No local following
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteFollowing = await remoteDataSource.getFollowing(userId);
          await localDataSource.cacheProfiles(remoteFollowing);
          return Right(remoteFollowing);
        } catch (e) {
          if (localFollowing.isNotEmpty) {
            return Right(localFollowing);
          } else {
            return Left(ServerFailure('Failed to fetch following'));
          }
        }
      }
      
      return Right(localFollowing);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialPostEntity>> createPost(String userId, Map<String, dynamic> postData) async {
    try {
      // Create post locally first for offline support
      final localPost = await localDataSource.createPost(userId, postData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remotePost = await remoteDataSource.createPost(userId, postData);
          // Update local with server ID and sync status
          await localDataSource.updatePost(localPost.id, {
            'server_id': remotePost.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remotePost);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updatePost(localPost.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localPost);
        }
      }
      
      return Right(localPost);
    } on CacheException {
      return Left(CacheFailure('Failed to create post locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create post on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SocialPostEntity>>> getFeed(String userId, {int? limit, String? cursor}) async {
    try {
      List<SocialPostEntity> localPosts = [];
      
      try {
        localPosts = await localDataSource.getFeed(userId, limit: limit, cursor: cursor);
      } on CacheException {
        // No local posts
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remotePosts = await remoteDataSource.getFeed(userId, limit: limit, cursor: cursor);
          await localDataSource.cachePosts(remotePosts);
          return Right(remotePosts);
        } catch (e) {
          if (localPosts.isNotEmpty) {
            return Right(localPosts);
          } else {
            return Left(ServerFailure('Failed to fetch feed'));
          }
        }
      }
      
      return Right(localPosts);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> likePost(String userId, String postId) async {
    try {
      // Like post locally first for immediate UI response
      await localDataSource.likePost(userId, postId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final isLiked = await remoteDataSource.likePost(userId, postId);
          return Right(isLiked);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markLikeForSync(userId, postId);
          return const Right(true); // Assume like succeeded locally
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markLikeForSync(userId, postId);
        return const Right(true);
      }
    } on CacheException {
      return Left(CacheFailure('Failed to like post locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialCommentEntity>> addComment(String userId, String postId, String content, {String? parentCommentId}) async {
    try {
      // Add comment locally first
      final localComment = await localDataSource.addComment(userId, postId, content, parentCommentId: parentCommentId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteComment = await remoteDataSource.addComment(userId, postId, content, parentCommentId: parentCommentId);
          // Update local with server ID and sync status
          await localDataSource.updateComment(localComment.id, {
            'server_id': remoteComment.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteComment);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateComment(localComment.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localComment);
        }
      }
      
      return Right(localComment);
    } on CacheException {
      return Left(CacheFailure('Failed to add comment locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to add comment on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialChallengeEntity>> createChallenge(String userId, Map<String, dynamic> challengeData) async {
    try {
      // Create challenge locally first
      final localChallenge = await localDataSource.createChallenge(userId, challengeData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteChallenge = await remoteDataSource.createChallenge(userId, challengeData);
          // Update local with server ID and sync status
          await localDataSource.updateChallenge(localChallenge.id, {
            'server_id': remoteChallenge.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteChallenge);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateChallenge(localChallenge.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localChallenge);
        }
      }
      
      return Right(localChallenge);
    } on CacheException {
      return Left(CacheFailure('Failed to create challenge locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create challenge on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SocialChallengeEntity>>> getActiveChallenges({String? category}) async {
    try {
      List<SocialChallengeEntity> localChallenges = [];
      
      try {
        localChallenges = await localDataSource.getActiveChallenges(category: category);
      } on CacheException {
        // No local challenges
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteChallenges = await remoteDataSource.getActiveChallenges(category: category);
          await localDataSource.cacheChallenges(remoteChallenges);
          return Right(remoteChallenges);
        } catch (e) {
          if (localChallenges.isNotEmpty) {
            return Right(localChallenges);
          } else {
            return Left(ServerFailure('Failed to fetch challenges'));
          }
        }
      }
      
      return Right(localChallenges);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> joinChallenge(String userId, String challengeId) async {
    try {
      // Join challenge locally first for immediate UI response
      await localDataSource.joinChallenge(userId, challengeId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.joinChallenge(userId, challengeId);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markChallengeJoinForSync(userId, challengeId);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markChallengeJoinForSync(userId, challengeId);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to join challenge locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SocialMessageEntity>> sendMessage(String senderId, String receiverId, String content) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required to send messages'));
      }

      // Send message on server
      final remoteMessage = await remoteDataSource.sendMessage(senderId, receiverId, content);
      
      // Cache message locally
      await localDataSource.cacheMessage(remoteMessage);
      
      return Right(remoteMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> searchUsers(String query) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteResults = await remoteDataSource.searchUsers(query);
          // Cache search results locally
          await localDataSource.cacheUserSearchResults(query, remoteResults);
          return Right(remoteResults);
        } catch (e) {
          // Fall back to local search
          try {
            final localResults = await localDataSource.searchUsers(query);
            return Right(localResults);
          } on CacheException {
            return Left(ServerFailure('Failed to search users and no local search capability available'));
          }
        }
      } else {
        // Offline - use local search
        final localResults = await localDataSource.searchUsers(query);
        return Right(localResults);
      }
    } on CacheException {
      return Left(CacheFailure('No user search capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncSocialData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get social data that needs sync
      final unsyncedPosts = await localDataSource.getUnsyncedPosts(userId);
      final unsyncedComments = await localDataSource.getUnsyncedComments(userId);
      final unsyncedChallenges = await localDataSource.getUnsyncedChallenges(userId);
      final unsyncedLikes = await localDataSource.getUnsyncedLikes(userId);
      final unsyncedJoins = await localDataSource.getUnsyncedChallengeJoins(userId);

      // Sync posts
      for (final post in unsyncedPosts) {
        try {
          if (post.serverId == null) {
            // Create on server
            final remotePost = await remoteDataSource.createPost(userId, post.toJson());
            await localDataSource.updatePost(post.id, {
              'server_id': remotePost.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updatePost(post.serverId!, post.toJson());
            await localDataSource.updatePost(post.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync comments
      for (final comment in unsyncedComments) {
        try {
          if (comment.serverId == null) {
            final remoteComment = await remoteDataSource.addComment(
              comment.authorId,
              comment.postId,
              comment.content,
              parentCommentId: comment.parentCommentId,
            );
            await localDataSource.updateComment(comment.id, {
              'server_id': remoteComment.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync challenges
      for (final challenge in unsyncedChallenges) {
        try {
          if (challenge.serverId == null) {
            final remoteChallenge = await remoteDataSource.createChallenge(userId, challenge.toJson());
            await localDataSource.updateChallenge(challenge.id, {
              'server_id': remoteChallenge.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync likes
      for (final like in unsyncedLikes) {
        try {
          await remoteDataSource.likePost(like['user_id'], like['post_id']);
          await localDataSource.markLikeSynced(like['id']);
        } catch (e) {
          continue;
        }
      }

      // Sync challenge joins
      for (final join in unsyncedJoins) {
        try {
          await remoteDataSource.joinChallenge(join['user_id'], join['challenge_id']);
          await localDataSource.markChallengeJoinSynced(join['id']);
        } catch (e) {
          continue;
        }
      }

      // Fetch latest social data from server
      final remoteFeed = await remoteDataSource.getFeed(userId);
      await localDataSource.cachePosts(remoteFeed);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync social data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }
}
