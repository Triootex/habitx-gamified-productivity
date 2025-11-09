import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../datasources/local/task_local_data_source.dart';
import '../datasources/remote/task_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskEntity>> createTask(String userId, Map<String, dynamic> taskData);
  Future<Either<Failure, TaskEntity>> updateTask(String taskId, Map<String, dynamic> updates);
  Future<Either<Failure, bool>> deleteTask(String taskId);
  Future<Either<Failure, TaskEntity>> getTask(String taskId);
  Future<Either<Failure, List<TaskEntity>>> getUserTasks(String userId, {String? status, String? category});
  Future<Either<Failure, TaskEntity>> completeTask(String taskId, Map<String, dynamic> completionData);
  Future<Either<Failure, List<TaskEntity>>> getTasksByProject(String projectId);
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks(String userId);
  Future<Either<Failure, List<TaskEntity>>> getTasksDueToday(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getTaskAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String userId, String query, Map<String, dynamic> filters);
  Future<Either<Failure, bool>> syncTasks(String userId);
}

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TaskEntity>> createTask(String userId, Map<String, dynamic> taskData) async {
    try {
      // Always create locally first for offline support
      final localTask = await localDataSource.createTask(userId, taskData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteTask = await remoteDataSource.createTask(userId, taskData);
          // Update local with server ID and sync status
          await localDataSource.updateTask(localTask.id, {
            'server_id': remoteTask.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteTask);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateTask(localTask.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localTask);
        }
      }
      
      return Right(localTask);
    } on CacheException {
      return Left(CacheFailure('Failed to create task locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create task on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // Update locally first
      final localTask = await localDataSource.updateTask(taskId, updates);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteTask = await remoteDataSource.updateTask(taskId, updates);
          // Update local sync status
          await localDataSource.updateTask(taskId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteTask);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateTask(taskId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localTask);
        }
      }
      
      return Right(localTask);
    } on CacheException {
      return Left(CacheFailure('Failed to update task locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to update task on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String taskId) async {
    try {
      // Delete locally first
      await localDataSource.deleteTask(taskId);
      
      if (await networkInfo.isConnected) {
        try {
          // Delete from remote
          await remoteDataSource.deleteTask(taskId);
        } catch (e) {
          // Mark for later sync deletion
          await localDataSource.markTaskForDeletion(taskId);
        }
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to delete task locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to delete task on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(String taskId) async {
    try {
      // Try local first for speed
      try {
        final localTask = await localDataSource.getTask(taskId);
        
        // If online and task needs sync, fetch from remote
        if (await networkInfo.isConnected && (!localTask.isSynced || _shouldRefresh(localTask.lastSynced))) {
          try {
            final remoteTask = await remoteDataSource.getTask(taskId);
            // Update local cache
            await localDataSource.cacheTask(remoteTask);
            return Right(remoteTask);
          } catch (e) {
            // Return local if remote fails
            return Right(localTask);
          }
        }
        
        return Right(localTask);
      } on CacheException {
        // If not in local cache and online, fetch from remote
        if (await networkInfo.isConnected) {
          final remoteTask = await remoteDataSource.getTask(taskId);
          // Cache locally
          await localDataSource.cacheTask(remoteTask);
          return Right(remoteTask);
        } else {
          return Left(CacheFailure('Task not found locally and device is offline'));
        }
      }
    } on ServerException {
      return Left(ServerFailure('Failed to fetch task from server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getUserTasks(String userId, {String? status, String? category}) async {
    try {
      // Always return local tasks first for immediate UI response
      List<TaskEntity> localTasks = [];
      
      try {
        localTasks = await localDataSource.getUserTasks(userId, status: status, category: category);
      } on CacheException {
        // No local tasks, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteTasks = await remoteDataSource.getUserTasks(userId, status: status, category: category);
          
          // Update local cache with remote data
          await localDataSource.cacheTasks(remoteTasks);
          
          return Right(remoteTasks);
        } catch (e) {
          // Return local tasks if remote fails
          if (localTasks.isNotEmpty) {
            return Right(localTasks);
          } else {
            return Left(ServerFailure('Failed to fetch tasks and no local cache available'));
          }
        }
      }
      
      return Right(localTasks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(String taskId, Map<String, dynamic> completionData) async {
    try {
      // Complete locally first
      final localTask = await localDataSource.completeTask(taskId, completionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteTask = await remoteDataSource.completeTask(taskId, completionData);
          // Update local sync status
          await localDataSource.updateTask(taskId, {
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteTask);
        } catch (e) {
          // Mark for later sync
          await localDataSource.updateTask(taskId, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localTask);
        }
      }
      
      return Right(localTask);
    } on CacheException {
      return Left(CacheFailure('Failed to complete task locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to complete task on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByProject(String projectId) async {
    try {
      List<TaskEntity> localTasks = [];
      
      try {
        localTasks = await localDataSource.getTasksByProject(projectId);
      } on CacheException {
        // No local tasks
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasksByProject(projectId);
          await localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          if (localTasks.isNotEmpty) {
            return Right(localTasks);
          } else {
            return Left(ServerFailure('Failed to fetch project tasks'));
          }
        }
      }
      
      return Right(localTasks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks(String userId) async {
    try {
      List<TaskEntity> localTasks = [];
      
      try {
        localTasks = await localDataSource.getOverdueTasks(userId);
      } on CacheException {
        // No local tasks
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getOverdueTasks(userId);
          await localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          if (localTasks.isNotEmpty) {
            return Right(localTasks);
          } else {
            return Left(ServerFailure('Failed to fetch overdue tasks'));
          }
        }
      }
      
      return Right(localTasks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksDueToday(String userId) async {
    try {
      List<TaskEntity> localTasks = [];
      
      try {
        localTasks = await localDataSource.getTasksDueToday(userId);
      } on CacheException {
        // No local tasks
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasksDueToday(userId);
          await localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          if (localTasks.isNotEmpty) {
            return Right(localTasks);
          } else {
            return Left(ServerFailure('Failed to fetch today\'s tasks'));
          }
        }
      }
      
      return Right(localTasks);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getTaskAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheTaskAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getTaskAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getTaskAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String userId, String query, Map<String, dynamic> filters) async {
    try {
      List<TaskEntity> localResults = [];
      
      try {
        localResults = await localDataSource.searchTasks(userId, query, filters);
      } on CacheException {
        // No local results
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteResults = await remoteDataSource.searchTasks(userId, query, filters);
          // Cache search results
          await localDataSource.cacheSearchResults(query, remoteResults);
          return Right(remoteResults);
        } catch (e) {
          if (localResults.isNotEmpty) {
            return Right(localResults);
          } else {
            return Left(ServerFailure('Failed to search tasks'));
          }
        }
      }
      
      return Right(localResults);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncTasks(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get tasks that need sync
      final unsyncedTasks = await localDataSource.getUnsyncedTasks(userId);
      final deletedTasks = await localDataSource.getTasksMarkedForDeletion(userId);

      // Sync creations and updates
      for (final task in unsyncedTasks) {
        try {
          if (task.serverId == null) {
            // Create on server
            final remoteTask = await remoteDataSource.createTask(userId, task.toJson());
            await localDataSource.updateTask(task.id, {
              'server_id': remoteTask.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateTask(task.serverId!, task.toJson());
            await localDataSource.updateTask(task.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Continue with other tasks if one fails
          continue;
        }
      }

      // Sync deletions
      for (final taskId in deletedTasks) {
        try {
          await remoteDataSource.deleteTask(taskId);
          await localDataSource.removeDeletedTask(taskId);
        } catch (e) {
          // Continue with other deletions
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remoteTasks = await remoteDataSource.getUserTasks(userId);
      await localDataSource.cacheTasks(remoteTasks);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync tasks with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  // Helper method to determine if data should be refreshed
  bool _shouldRefresh(DateTime? lastSynced) {
    if (lastSynced == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSynced);
    return difference.inMinutes > 5; // Refresh if older than 5 minutes
  }
}
