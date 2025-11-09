import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Register User Use Case
@injectable
class RegisterUserUseCase implements UseCase<UserEntity, RegisterUserParams> {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterUserParams params) async {
    return await repository.registerUser(params.userData);
  }
}

class RegisterUserParams {
  final Map<String, dynamic> userData;

  RegisterUserParams({required this.userData});
}

// Login User Use Case
@injectable
class LoginUserUseCase implements UseCase<UserEntity, LoginUserParams> {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginUserParams params) async {
    return await repository.loginUser(params.email, params.password);
  }
}

class LoginUserParams {
  final String email;
  final String password;

  LoginUserParams({required this.email, required this.password});
}

// Logout User Use Case
@injectable
class LogoutUserUseCase implements UseCase<bool, String> {
  final UserRepository repository;

  LogoutUserUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.logoutUser(userId);
  }
}

// Get Current User Use Case
@injectable
class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

// Update User Use Case
@injectable
class UpdateUserUseCase implements UseCase<UserEntity, UpdateUserParams> {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUser(params.userId, params.updates);
  }
}

class UpdateUserParams {
  final String userId;
  final Map<String, dynamic> updates;

  UpdateUserParams({required this.userId, required this.updates});
}

// Delete User Use Case
@injectable
class DeleteUserUseCase implements UseCase<bool, String> {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}

// Change Password Use Case
@injectable
class ChangePasswordUseCase implements UseCase<bool, ChangePasswordParams> {
  final UserRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      params.userId,
      params.oldPassword,
      params.newPassword,
    );
  }
}

class ChangePasswordParams {
  final String userId;
  final String oldPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
  });
}

// Reset Password Use Case
@injectable
class ResetPasswordUseCase implements UseCase<bool, String> {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String email) async {
    return await repository.resetPassword(email);
  }
}

// Verify Email Use Case
@injectable
class VerifyEmailUseCase implements UseCase<bool, VerifyEmailParams> {
  final UserRepository repository;

  VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyEmailParams params) async {
    return await repository.verifyEmail(params.userId, params.token);
  }
}

class VerifyEmailParams {
  final String userId;
  final String token;

  VerifyEmailParams({required this.userId, required this.token});
}

// Refresh User Data Use Case
@injectable
class RefreshUserDataUseCase implements UseCase<UserEntity, String> {
  final UserRepository repository;

  RefreshUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.refreshUserData(userId);
  }
}

// Get User Analytics Use Case
@injectable
class GetUserAnalyticsUseCase implements UseCase<Map<String, dynamic>, String> {
  final UserRepository repository;

  GetUserAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getUserAnalytics(userId);
  }
}

// Get User Achievements Use Case
@injectable
class GetUserAchievementsUseCase implements UseCase<List<String>, String> {
  final UserRepository repository;

  GetUserAchievementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String userId) async {
    return await repository.getUserAchievements(userId);
  }
}

// Update User Preferences Use Case
@injectable
class UpdateUserPreferencesUseCase implements UseCase<bool, UpdateUserPreferencesParams> {
  final UserRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateUserPreferencesParams params) async {
    return await repository.updateUserPreferences(params.userId, params.preferences);
  }
}

class UpdateUserPreferencesParams {
  final String userId;
  final Map<String, dynamic> preferences;

  UpdateUserPreferencesParams({
    required this.userId,
    required this.preferences,
  });
}

// Sync User Data Use Case
@injectable
class SyncUserDataUseCase implements UseCase<bool, String> {
  final UserRepository repository;

  SyncUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncUserData(userId);
  }
}

// Export User Data Use Case
@injectable
class ExportUserDataUseCase implements UseCase<Map<String, dynamic>, String> {
  final UserRepository repository;

  ExportUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.exportUserData(userId);
  }
}

// Import User Data Use Case
@injectable
class ImportUserDataUseCase implements UseCase<bool, ImportUserDataParams> {
  final UserRepository repository;

  ImportUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ImportUserDataParams params) async {
    return await repository.importUserData(params.userId, params.userData);
  }
}

class ImportUserDataParams {
  final String userId;
  final Map<String, dynamic> userData;

  ImportUserDataParams({required this.userId, required this.userData});
}

// Calculate User Level Use Case
@injectable
class CalculateUserLevelUseCase implements UseCase<Map<String, dynamic>, String> {
  final UserRepository repository;

  CalculateUserLevelUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final userResult = await repository.getCurrentUser();
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) {
          final levelData = _calculateLevel(user.totalXP);
          return Right(levelData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate user level: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateLevel(int totalXP) {
    // XP requirements increase exponentially
    int level = 1;
    int xpForCurrentLevel = 0;
    int xpForNextLevel = 100;
    
    while (totalXP >= xpForNextLevel) {
      xpForCurrentLevel = xpForNextLevel;
      level++;
      xpForNextLevel = (xpForCurrentLevel * 1.5).round();
    }
    
    final xpInCurrentLevel = totalXP - xpForCurrentLevel;
    final xpNeededForNext = xpForNextLevel - xpForCurrentLevel;
    final progressPercent = (xpInCurrentLevel / xpNeededForNext * 100).round();
    
    return {
      'current_level': level,
      'total_xp': totalXP,
      'xp_in_current_level': xpInCurrentLevel,
      'xp_needed_for_next': xpNeededForNext - xpInCurrentLevel,
      'progress_percent': progressPercent,
      'level_title': _getLevelTitle(level),
    };
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Apprentice';
    if (level < 35) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 75) return 'Grandmaster';
    return 'Legend';
  }
}

// Get User Profile Summary Use Case
@injectable
class GetUserProfileSummaryUseCase implements UseCase<Map<String, dynamic>, String> {
  final UserRepository repository;

  GetUserProfileSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final userResult = await repository.getCurrentUser();
      final analyticsResult = await repository.getUserAnalytics(userId);
      final achievementsResult = await repository.getUserAchievements(userId);
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          final analytics = await analyticsResult.fold(
            (failure) => <String, dynamic>{},
            (data) => data,
          );
          
          final achievements = await achievementsResult.fold(
            (failure) => <String>[],
            (list) => list,
          );
          
          final levelData = _calculateLevel(user.totalXP);
          
          final summary = {
            'user': {
              'id': user.id,
              'display_name': user.displayName,
              'email': user.email,
              'profile_image_url': user.profileImageUrl,
              'joined_at': user.createdAt.toIso8601String(),
            },
            'level': levelData,
            'stats': {
              'total_xp': user.totalXP,
              'current_streak': user.currentStreak,
              'longest_streak': user.longestStreak,
              'achievements_count': achievements.length,
              'total_habits': analytics['total_habits'] ?? 0,
              'total_tasks': analytics['total_tasks'] ?? 0,
              'completion_rate': analytics['overall_completion_rate'] ?? 0.0,
            },
            'achievements': achievements.take(5).toList(), // Top 5 achievements
            'recent_activity': analytics['recent_activity'] ?? [],
          };
          
          return Right(summary);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get profile summary: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateLevel(int totalXP) {
    // Same level calculation logic as above
    int level = 1;
    int xpForCurrentLevel = 0;
    int xpForNextLevel = 100;
    
    while (totalXP >= xpForNextLevel) {
      xpForCurrentLevel = xpForNextLevel;
      level++;
      xpForNextLevel = (xpForCurrentLevel * 1.5).round();
    }
    
    final xpInCurrentLevel = totalXP - xpForCurrentLevel;
    final xpNeededForNext = xpForNextLevel - xpForCurrentLevel;
    final progressPercent = (xpInCurrentLevel / xpNeededForNext * 100).round();
    
    return {
      'current_level': level,
      'total_xp': totalXP,
      'xp_in_current_level': xpInCurrentLevel,
      'xp_needed_for_next': xpNeededForNext - xpInCurrentLevel,
      'progress_percent': progressPercent,
      'level_title': _getLevelTitle(level),
    };
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Apprentice';
    if (level < 35) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 75) return 'Grandmaster';
    return 'Legend';
  }
}
