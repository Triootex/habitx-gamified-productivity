import '../../domain/repositories/creativity_repository.dart';
import '../../domain/entities/creative_project.dart';
import '../../domain/entities/inspiration.dart';
import '../../domain/entities/creative_challenge.dart';
import '../datasources/creativity_local_data_source.dart';
import '../datasources/creativity_remote_data_source.dart';

class CreativityRepositoryImpl implements CreativityRepository {
  final CreativityLocalDataSource localDataSource;
  final CreativityRemoteDataSource remoteDataSource;

  CreativityRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<CreativeProject>> getUserProjects(String userId) async {
    try {
      final projects = await remoteDataSource.getUserProjects(userId);
      await localDataSource.cacheProjects(userId, projects);
      return projects;
    } catch (e) {
      return await localDataSource.getUserProjects(userId);
    }
  }

  @override
  Future<CreativeProject> createProject(String userId, CreativeProject project) async {
    final createdProject = await localDataSource.createProject(userId, project);
    try {
      await remoteDataSource.createProject(userId, createdProject);
    } catch (e) {
      // Handle offline sync later
    }
    return createdProject;
  }

  @override
  Future<void> updateProject(String userId, CreativeProject project) async {
    await localDataSource.updateProject(userId, project);
    try {
      await remoteDataSource.updateProject(userId, project);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<void> deleteProject(String userId, String projectId) async {
    await localDataSource.deleteProject(userId, projectId);
    try {
      await remoteDataSource.deleteProject(userId, projectId);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<List<Inspiration>> getDailyInspiration() async {
    try {
      final inspirations = await remoteDataSource.getDailyInspiration();
      await localDataSource.cacheInspiration(inspirations);
      return inspirations;
    } catch (e) {
      return await localDataSource.getDailyInspiration();
    }
  }

  @override
  Future<List<CreativeChallenge>> getActiveChallenges() async {
    try {
      final challenges = await remoteDataSource.getActiveChallenges();
      await localDataSource.cacheChallenges(challenges);
      return challenges;
    } catch (e) {
      return await localDataSource.getActiveChallenges();
    }
  }

  @override
  Future<void> joinChallenge(String userId, String challengeId) async {
    await localDataSource.joinChallenge(userId, challengeId);
    try {
      await remoteDataSource.joinChallenge(userId, challengeId);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<void> submitChallengeEntry(String userId, String challengeId, Map<String, dynamic> entry) async {
    await localDataSource.submitChallengeEntry(userId, challengeId, entry);
    try {
      await remoteDataSource.submitChallengeEntry(userId, challengeId, entry);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<Map<String, dynamic>> getCreativityStats(String userId) async {
    try {
      final stats = await remoteDataSource.getCreativityStats(userId);
      await localDataSource.cacheCreativityStats(userId, stats);
      return stats;
    } catch (e) {
      return await localDataSource.getCreativityStats(userId);
    }
  }

  @override
  Future<List<String>> getCreativeIdeas(String category) async {
    try {
      return await remoteDataSource.getCreativeIdeas(category);
    } catch (e) {
      return await localDataSource.getCreativeIdeas(category);
    }
  }

  @override
  Future<void> saveCreativeSession(String userId, Map<String, dynamic> sessionData) async {
    await localDataSource.saveCreativeSession(userId, sessionData);
    try {
      await remoteDataSource.saveCreativeSession(userId, sessionData);
    } catch (e) {
      // Handle offline sync later
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCreativeSessions(String userId) async {
    try {
      final sessions = await remoteDataSource.getCreativeSessions(userId);
      await localDataSource.cacheCreativeSessions(userId, sessions);
      return sessions;
    } catch (e) {
      return await localDataSource.getCreativeSessions(userId);
    }
  }

  @override
  Future<void> shareProject(String userId, String projectId, List<String> platforms) async {
    try {
      await remoteDataSource.shareProject(userId, projectId, platforms);
      await localDataSource.markProjectShared(userId, projectId, platforms);
    } catch (e) {
      throw Exception('Failed to share project: $e');
    }
  }

  @override
  Future<void> syncCreativityData(String userId) async {
    try {
      await localDataSource.syncPendingChanges(remoteDataSource);
    } catch (e) {
      throw Exception('Failed to sync creativity data: $e');
    }
  }
}
