import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/todo_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';

abstract class TaskService {
  Future<List<TaskEntity>> getTasks(String userId, {String? status, String? category});
  Future<TaskEntity> createTask(String userId, Map<String, dynamic> taskData);
  Future<TaskEntity> updateTask(String taskId, Map<String, dynamic> updates);
  Future<bool> completeTask(String taskId);
  Future<bool> deleteTask(String taskId);
  Future<List<SubtaskEntity>> generateSubtasks(String taskId, String taskTitle);
  Future<List<TaskEntity>> getOverdueTasks(String userId);
  Future<List<TaskEntity>> getTasksDueToday(String userId);
  Future<Map<String, dynamic>> getTaskAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<List<TaskEntity>> searchTasks(String userId, String query);
  Future<bool> bulkUpdateTasks(List<String> taskIds, Map<String, dynamic> updates);
}

@LazySingleton(as: TaskService)
class TaskServiceImpl implements TaskService {
  @override
  Future<List<TaskEntity>> getTasks(String userId, {String? status, String? category}) async {
    try {
      // Mock task retrieval - in real implementation, this would query database
      await Future.delayed(const Duration(milliseconds: 200));
      
      final mockTasks = _generateMockTasks(userId);
      
      // Apply filters
      List<TaskEntity> filteredTasks = mockTasks;
      
      if (status != null) {
        filteredTasks = filteredTasks.where((task) => task.status == status).toList();
      }
      
      if (category != null) {
        filteredTasks = filteredTasks.where((task) => task.category == category).toList();
      }
      
      // Sort by priority and due date
      filteredTasks.sort((a, b) {
        // Priority order: high -> medium -> low
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        final aPriority = priorityOrder[a.priority] ?? 1;
        final bPriority = priorityOrder[b.priority] ?? 1;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // Then by due date
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        
        return a.createdAt.compareTo(b.createdAt);
      });
      
      return filteredTasks;
    } catch (e) {
      throw Exception('Failed to retrieve tasks: ${e.toString()}');
    }
  }

  @override
  Future<TaskEntity> createTask(String userId, Map<String, dynamic> taskData) async {
    try {
      // Validate required fields
      final validation = ValidationUtils.validateTaskData(taskData);
      if (validation.isNotEmpty) {
        throw Exception('Validation failed: ${validation.values.first}');
      }
      
      final now = DateTime.now();
      final taskId = 'task_${now.millisecondsSinceEpoch}';
      
      // Calculate XP reward based on task complexity
      final xpReward = TodoUtils.calculateTaskXP(
        priority: taskData['priority'] as String? ?? 'medium',
        estimatedMinutes: taskData['estimated_minutes'] as int? ?? 30,
        hasSubtasks: taskData['subtasks'] != null,
        tags: (taskData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );
      
      final task = TaskEntity(
        id: taskId,
        userId: userId,
        title: taskData['title'] as String,
        description: taskData['description'] as String?,
        priority: taskData['priority'] as String? ?? 'medium',
        status: 'todo',
        category: taskData['category'] as String?,
        tags: (taskData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        dueDate: taskData['due_date'] != null 
            ? DateTime.parse(taskData['due_date'] as String)
            : null,
        remindAt: taskData['remind_at'] != null 
            ? DateTime.parse(taskData['remind_at'] as String)
            : null,
        estimatedMinutes: taskData['estimated_minutes'] as int? ?? 30,
        xpReward: xpReward,
        createdAt: now,
        updatedAt: now,
      );
      
      // Generate subtasks if requested
      if (taskData['auto_generate_subtasks'] == true) {
        final subtasks = await _generateSubtasksForTask(task);
        return task.copyWith(
          subtasks: subtasks,
          hasSubtasks: subtasks.isNotEmpty,
        );
      }
      
      return task;
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  @override
  Future<TaskEntity> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // Mock task update - fetch existing task first
      final existingTask = await _getTaskById(taskId);
      if (existingTask == null) {
        throw Exception('Task not found');
      }
      
      // Apply updates
      final updatedTask = existingTask.copyWith(
        title: updates['title'] as String? ?? existingTask.title,
        description: updates['description'] as String?,
        priority: updates['priority'] as String? ?? existingTask.priority,
        status: updates['status'] as String? ?? existingTask.status,
        category: updates['category'] as String? ?? existingTask.category,
        tags: (updates['tags'] as List<dynamic>?)?.cast<String>() ?? existingTask.tags,
        dueDate: updates['due_date'] != null 
            ? DateTime.parse(updates['due_date'] as String)
            : existingTask.dueDate,
        estimatedMinutes: updates['estimated_minutes'] as int? ?? existingTask.estimatedMinutes,
        updatedAt: DateTime.now(),
      );
      
      return updatedTask;
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<bool> completeTask(String taskId) async {
    try {
      final task = await _getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }
      
      final now = DateTime.now();
      final updatedTask = task.copyWith(
        status: 'completed',
        completedAt: now,
        actualMinutes: task.estimatedMinutes, // Mock actual time
        xpClaimed: true,
        updatedAt: now,
      );
      
      // Award XP to user (in real implementation, this would update user's XP)
      await _awardTaskXP(task.userId, updatedTask.xpReward);
      
      return true;
    } catch (e) {
      throw Exception('Failed to complete task: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    try {
      final task = await _getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }
      
      // In real implementation, this would delete from database
      // For now, we'll just return success
      return true;
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  @override
  Future<List<SubtaskEntity>> generateSubtasks(String taskId, String taskTitle) async {
    try {
      final suggestions = TodoUtils.generateSubtasks(taskTitle);
      final now = DateTime.now();
      
      return suggestions.asMap().entries.map((entry) {
        return SubtaskEntity(
          id: 'subtask_${taskId}_${entry.key}',
          taskId: taskId,
          title: entry.value,
          order: entry.key,
          createdAt: now,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to generate subtasks: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskEntity>> getOverdueTasks(String userId) async {
    try {
      final tasks = await getTasks(userId);
      final now = DateTime.now();
      
      return tasks.where((task) {
        return task.dueDate != null && 
               task.dueDate!.isBefore(now) && 
               task.status != 'completed';
      }).toList();
    } catch (e) {
      throw Exception('Failed to get overdue tasks: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskEntity>> getTasksDueToday(String userId) async {
    try {
      final tasks = await getTasks(userId);
      final today = DateTime.now();
      
      return tasks.where((task) {
        if (task.dueDate == null) return false;
        return DateUtils.isSameDay(task.dueDate!, today);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tasks due today: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getTaskAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      final tasks = await getTasks(userId);
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final tasksInPeriod = tasks.where((task) {
        return task.createdAt.isAfter(start) && task.createdAt.isBefore(end);
      }).toList();
      
      final completedTasks = tasksInPeriod.where((task) => task.status == 'completed').length;
      final totalTasks = tasksInPeriod.length;
      final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
      
      // Category breakdown
      final categoryBreakdown = <String, int>{};
      for (final task in tasksInPeriod) {
        final category = task.category ?? 'Uncategorized';
        categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + 1;
      }
      
      // Priority breakdown
      final priorityBreakdown = <String, int>{};
      for (final task in tasksInPeriod) {
        priorityBreakdown[task.priority] = (priorityBreakdown[task.priority] ?? 0) + 1;
      }
      
      // Productivity trends
      final dailyCompletion = <String, int>{};
      for (final task in tasksInPeriod.where((t) => t.status == 'completed')) {
        final dateKey = DateUtils.formatDate(task.completedAt ?? task.createdAt, 'yyyy-MM-dd');
        dailyCompletion[dateKey] = (dailyCompletion[dateKey] ?? 0) + 1;
      }
      
      return {
        'period': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
        'summary': {
          'total_tasks': totalTasks,
          'completed_tasks': completedTasks,
          'completion_rate': completionRate,
          'average_daily_completion': completedTasks / (end.difference(start).inDays + 1),
        },
        'breakdown': {
          'by_category': categoryBreakdown,
          'by_priority': priorityBreakdown,
        },
        'trends': {
          'daily_completion': dailyCompletion,
        },
        'insights': _generateTaskInsights(tasksInPeriod),
      };
    } catch (e) {
      throw Exception('Failed to get task analytics: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskEntity>> searchTasks(String userId, String query) async {
    try {
      final tasks = await getTasks(userId);
      final lowerQuery = query.toLowerCase();
      
      return tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
               (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
               task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
               (task.category?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: ${e.toString()}');
    }
  }

  @override
  Future<bool> bulkUpdateTasks(List<String> taskIds, Map<String, dynamic> updates) async {
    try {
      for (final taskId in taskIds) {
        await updateTask(taskId, updates);
      }
      return true;
    } catch (e) {
      throw Exception('Failed to bulk update tasks: ${e.toString()}');
    }
  }

  // Private helper methods
  List<TaskEntity> _generateMockTasks(String userId) {
    final now = DateTime.now();
    
    return [
      TaskEntity(
        id: 'task_1',
        userId: userId,
        title: 'Complete project proposal',
        description: 'Write and review the Q4 project proposal',
        priority: 'high',
        status: 'in_progress',
        category: 'Work',
        tags: ['project', 'proposal', 'q4'],
        dueDate: now.add(const Duration(days: 2)),
        estimatedMinutes: 120,
        xpReward: 50,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskEntity(
        id: 'task_2',
        userId: userId,
        title: 'Review team performance',
        description: 'Monthly team performance review',
        priority: 'medium',
        status: 'todo',
        category: 'Work',
        tags: ['review', 'team'],
        dueDate: now.add(const Duration(days: 5)),
        estimatedMinutes: 90,
        xpReward: 30,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      TaskEntity(
        id: 'task_3',
        userId: userId,
        title: 'Buy groceries',
        description: 'Weekly grocery shopping',
        priority: 'low',
        status: 'todo',
        category: 'Personal',
        tags: ['shopping', 'groceries'],
        dueDate: now.add(const Duration(days: 1)),
        estimatedMinutes: 60,
        xpReward: 15,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  Future<TaskEntity?> _getTaskById(String taskId) async {
    // Mock task retrieval by ID
    final mockTasks = _generateMockTasks('user_id');
    return mockTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );
  }

  Future<List<SubtaskEntity>> _generateSubtasksForTask(TaskEntity task) async {
    final suggestions = TodoUtils.generateSubtasks(task.title);
    final now = DateTime.now();
    
    return suggestions.asMap().entries.map((entry) {
      return SubtaskEntity(
        id: 'subtask_${task.id}_${entry.key}',
        taskId: task.id,
        title: entry.value,
        order: entry.key,
        createdAt: now,
      );
    }).toList();
  }

  Future<void> _awardTaskXP(String userId, int xpAmount) async {
    // Mock XP awarding - in real implementation, this would update user XP
    print('Awarded $xpAmount XP to user $userId');
  }

  List<String> _generateTaskInsights(List<TaskEntity> tasks) {
    final insights = <String>[];
    
    if (tasks.isEmpty) {
      insights.add('No tasks in this period. Consider setting some goals!');
      return insights;
    }
    
    final completedTasks = tasks.where((task) => task.status == 'completed').length;
    final completionRate = completedTasks / tasks.length;
    
    if (completionRate > 0.8) {
      insights.add('Excellent task completion rate! You\'re staying on top of your goals.');
    } else if (completionRate > 0.6) {
      insights.add('Good progress on tasks. Consider breaking down larger tasks for better completion.');
    } else {
      insights.add('Room for improvement on task completion. Try setting smaller, more achievable goals.');
    }
    
    // Priority insights
    final highPriorityTasks = tasks.where((task) => task.priority == 'high').length;
    if (highPriorityTasks > tasks.length * 0.5) {
      insights.add('You have many high-priority tasks. Consider if all are truly urgent.');
    }
    
    // Overdue insights
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    if (overdueTasks > 0) {
      insights.add('$overdueTasks tasks are overdue. Consider adjusting deadlines or breaking them down.');
    }
    
    return insights;
  }
}
