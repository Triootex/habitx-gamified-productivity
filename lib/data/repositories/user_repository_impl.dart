import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/local/user_local_data_source.dart';
import '../datasources/remote/user_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/security/encryption_service.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> registerUser(Map<String, dynamic> userData);
  Future<Either<Failure, UserEntity>> loginUser(String email, String password);
  Future<Either<Failure, bool>> logoutUser(String userId);
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateUser(String userId, Map<String, dynamic> updates);
  Future<Either<Failure, bool>> deleteUser(String userId);
  Future<Either<Failure, bool>> changePassword(String userId, String oldPassword, String newPassword);
  Future<Either<Failure, bool>> resetPassword(String email);
  Future<Either<Failure, bool>> verifyEmail(String userId, String token);
  Future<Either<Failure, UserEntity>> refreshUserData(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getUserAnalytics(String userId);
  Future<Either<Failure, List<String>>> getUserAchievements(String userId);
  Future<Either<Failure, bool>> updateUserPreferences(String userId, Map<String, dynamic> preferences);
  Future<Either<Failure, bool>> syncUserData(String userId);
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(String userId);
  Future<Either<Failure, bool>> importUserData(String userId, Map<String, dynamic> userData);
}

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final EncryptionService encryptionService;

  UserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.encryptionService,
  });

  @override
  Future<Either<Failure, UserEntity>> registerUser(Map<String, dynamic> userData) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for registration'));
      }

      // Encrypt sensitive data
      final encryptedData = await _encryptUserData(userData);
      
      // Register on server
      final remoteUser = await remoteDataSource.registerUser(encryptedData);
      
      // Cache user data locally
      await localDataSource.cacheUser(remoteUser);
      
      // Store authentication tokens
      await localDataSource.storeAuthTokens(
        remoteUser.id,
        remoteUser.authToken ?? '',
        remoteUser.refreshToken ?? '',
      );
      
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginUser(String email, String password) async {
    try {
      if (!await networkInfo.isConnected) {
        // Try offline login with cached credentials
        try {
          final cachedUser = await localDataSource.getCachedUserByEmail(email);
          final isValidPassword = await encryptionService.verifyPassword(password, cachedUser.passwordHash ?? '');
          
          if (isValidPassword) {
            return Right(cachedUser);
          } else {
            return Left(AuthenticationFailure('Invalid credentials'));
          }
        } on CacheException {
          return Left(NetworkFailure('Internet connection required for first login'));
        }
      }

      // Online login
      final remoteUser = await remoteDataSource.loginUser(email, password);
      
      // Cache user data locally
      await localDataSource.cacheUser(remoteUser);
      
      // Store authentication tokens
      await localDataSource.storeAuthTokens(
        remoteUser.id,
        remoteUser.authToken ?? '',
        remoteUser.refreshToken ?? '',
      );
      
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> logoutUser(String userId) async {
    try {
      // Clear local cache and tokens
      await localDataSource.clearUserCache(userId);
      await localDataSource.clearAuthTokens(userId);
      
      // Logout from server if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logoutUser(userId);
        } catch (e) {
          // Don't fail logout if server logout fails
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to clear local user data'));
    } catch (e) {
      return Left(UnexpectedFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Try to get current user from local cache first
      try {
        final cachedUser = await localDataSource.getCurrentUser();
        
        // If online and user data is stale, refresh
        if (await networkInfo.isConnected && _shouldRefreshUser(cachedUser.lastSynced)) {
          try {
            final refreshedUser = await remoteDataSource.getUserById(cachedUser.id);
            await localDataSource.cacheUser(refreshedUser);
            return Right(refreshedUser);
          } catch (e) {
            // Return cached user if refresh fails
            return Right(cachedUser);
          }
        }
        
        return Right(cachedUser);
      } on CacheException {
        // No cached user found
        return Left(AuthenticationFailure('No authenticated user found'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Update locally first
      final localUser = await localDataSource.updateUser(userId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Encrypt sensitive updates
          final encryptedUpdates = await _encryptUserData(updates);
          
          // Update on server
          final remoteUser = await remoteDataSource.updateUser(userId, encryptedUpdates);
          
          // Update local cache with server response
          await localDataSource.cacheUser(remoteUser);
          
          return Right(remoteUser);
        } catch (e) {
          // Mark for later sync if remote update fails
          await localDataSource.markUserForSync(userId);
          return Right(localUser);
        }
      }
      
      // Mark for sync when back online
      await localDataSource.markUserForSync(userId);
      
      return Right(localUser);
    } on CacheException {
      return Left(CacheFailure('Failed to update user locally'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for account deletion'));
      }

      // Delete from server first
      await remoteDataSource.deleteUser(userId);
      
      // Clear all local data
      await localDataSource.clearAllUserData(userId);
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return Left(CacheFailure('Failed to clear local user data'));
    } catch (e) {
      return Left(UnexpectedFailure('Account deletion failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for password change'));
      }

      // Change password on server
      await remoteDataSource.changePassword(userId, oldPassword, newPassword);
      
      // Update local password hash
      final newPasswordHash = await encryptionService.hashPassword(newPassword);
      await localDataSource.updateUser(userId, {
        'password_hash': newPasswordHash,
        'password_changed_at': DateTime.now().toIso8601String(),
      });
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Password change failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String email) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for password reset'));
      }

      await remoteDataSource.resetPassword(email);
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Password reset failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String userId, String token) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for email verification'));
      }

      await remoteDataSource.verifyEmail(userId, token);
      
      // Update local user verification status
      await localDataSource.updateUser(userId, {
        'is_email_verified': true,
        'email_verified_at': DateTime.now().toIso8601String(),
      });
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Email verification failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshUserData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        // Return cached user if offline
        try {
          final cachedUser = await localDataSource.getUserById(userId);
          return Right(cachedUser);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no cached user data'));
        }
      }

      // Fetch fresh user data from server
      final remoteUser = await remoteDataSource.getUserById(userId);
      
      // Update local cache
      await localDataSource.cacheUser(remoteUser);
      
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to refresh user data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserAnalytics(String userId) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getUserAnalytics(userId);
          // Cache analytics locally
          await localDataSource.cacheUserAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getUserAnalytics(userId);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getUserAnalytics(userId);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserAchievements(String userId) async {
    try {
      List<String> localAchievements = [];
      
      try {
        localAchievements = await localDataSource.getUserAchievements(userId);
      } on CacheException {
        // No local achievements
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteAchievements = await remoteDataSource.getUserAchievements(userId);
          await localDataSource.cacheUserAchievements(userId, remoteAchievements);
          return Right(remoteAchievements);
        } catch (e) {
          if (localAchievements.isNotEmpty) {
            return Right(localAchievements);
          } else {
            return Left(ServerFailure('Failed to fetch achievements'));
          }
        }
      }
      
      return Right(localAchievements);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      // Update preferences locally first
      await localDataSource.updateUserPreferences(userId, preferences);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to server
          await remoteDataSource.updateUserPreferences(userId, preferences);
        } catch (e) {
          // Mark for later sync if remote update fails
          await localDataSource.markPreferencesForSync(userId);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markPreferencesForSync(userId);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to update preferences locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncUserData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get user data that needs sync
      final userNeedsSync = await localDataSource.doesUserNeedSync(userId);
      final preferencesNeedSync = await localDataSource.doPreferencesNeedSync(userId);

      if (userNeedsSync) {
        // Sync user profile updates
        final localUser = await localDataSource.getUserById(userId);
        await remoteDataSource.updateUser(userId, localUser.toJson());
        await localDataSource.markUserSynced(userId);
      }

      if (preferencesNeedSync) {
        // Sync preferences updates
        final localPreferences = await localDataSource.getUserPreferences(userId);
        await remoteDataSource.updateUserPreferences(userId, localPreferences);
        await localDataSource.markPreferencesSynced(userId);
      }

      // Fetch latest user data from server
      final remoteUser = await remoteDataSource.getUserById(userId);
      await localDataSource.cacheUser(remoteUser);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync user data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for data export'));
      }

      // Request data export from server
      final exportedData = await remoteDataSource.exportUserData(userId);
      
      return Right(exportedData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Data export failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> importUserData(String userId, Map<String, dynamic> userData) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for data import'));
      }

      // Import data to server
      await remoteDataSource.importUserData(userId, userData);
      
      // Refresh local cache with imported data
      final refreshedUser = await remoteDataSource.getUserById(userId);
      await localDataSource.cacheUser(refreshedUser);
      
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Data import failed: ${e.toString()}'));
    }
  }

  // Helper methods
  bool _shouldRefreshUser(DateTime? lastSynced) {
    if (lastSynced == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSynced);
    return difference.inMinutes > 10; // Refresh if older than 10 minutes
  }

  Future<Map<String, dynamic>> _encryptUserData(Map<String, dynamic> userData) async {
    final encryptedData = Map<String, dynamic>.from(userData);
    
    // Encrypt sensitive fields
    if (userData.containsKey('password')) {
      encryptedData['password_hash'] = await encryptionService.hashPassword(userData['password'] as String);
      encryptedData.remove('password');
    }
    
    if (userData.containsKey('phone_number')) {
      encryptedData['phone_number'] = await encryptionService.encrypt(userData['phone_number'] as String);
    }
    
    if (userData.containsKey('date_of_birth')) {
      encryptedData['date_of_birth'] = await encryptionService.encrypt(userData['date_of_birth'] as String);
    }
    
    return encryptedData;
  }
}
