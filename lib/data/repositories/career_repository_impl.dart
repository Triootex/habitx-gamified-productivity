import '../../domain/repositories/career_repository.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/achievement.dart';
import '../datasources/career_local_data_source.dart';
import '../datasources/career_remote_data_source.dart';

class CareerRepositoryImpl implements CareerRepository {
  final CareerLocalDataSource localDataSource;
  final CareerRemoteDataSource remoteDataSource;

  CareerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Career> getCareerProfile(String userId) async {
    try {
      // Try to get from remote first for latest data
      final career = await remoteDataSource.getCareerProfile(userId);
      // Cache locally
      await localDataSource.cacheCareerProfile(career);
      return career;
    } catch (e) {
      // Fallback to local cache
      return await localDataSource.getCareerProfile(userId);
    }
  }

  @override
  Future<List<Skill>> getUserSkills(String userId) async {
    try {
      final skills = await remoteDataSource.getUserSkills(userId);
      await localDataSource.cacheSkills(userId, skills);
      return skills;
    } catch (e) {
      return await localDataSource.getUserSkills(userId);
    }
  }

  @override
  Future<void> updateSkillProgress(String userId, String skillId, double progress) async {
    await localDataSource.updateSkillProgress(userId, skillId, progress);
    try {
      await remoteDataSource.updateSkillProgress(userId, skillId, progress);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<List<Achievement>> getCareerAchievements(String userId) async {
    try {
      final achievements = await remoteDataSource.getCareerAchievements(userId);
      await localDataSource.cacheAchievements(userId, achievements);
      return achievements;
    } catch (e) {
      return await localDataSource.getCareerAchievements(userId);
    }
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    await localDataSource.unlockAchievement(userId, achievementId);
    try {
      await remoteDataSource.unlockAchievement(userId, achievementId);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<Map<String, dynamic>> getCareerInsights(String userId) async {
    try {
      final insights = await remoteDataSource.getCareerInsights(userId);
      await localDataSource.cacheCareerInsights(userId, insights);
      return insights;
    } catch (e) {
      return await localDataSource.getCareerInsights(userId);
    }
  }

  @override
  Future<void> setCareerGoal(String userId, String goalType, Map<String, dynamic> goalData) async {
    await localDataSource.setCareerGoal(userId, goalType, goalData);
    try {
      await remoteDataSource.setCareerGoal(userId, goalType, goalData);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<List<String>> getRecommendedSkills(String userId) async {
    try {
      return await remoteDataSource.getRecommendedSkills(userId);
    } catch (e) {
      // Return cached recommendations or empty list
      return [];
    }
  }

  @override
  Future<void> syncCareerData(String userId) async {
    try {
      // Sync all local changes to remote
      await localDataSource.syncPendingChanges(remoteDataSource);
    } catch (e) {
      throw Exception('Failed to sync career data: $e');
    }
  }
}
