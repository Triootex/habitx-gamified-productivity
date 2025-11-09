import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String priority; // high, medium, low
  final String status; // todo, in_progress, completed, cancelled
  final String? category;
  final List<String> tags;
  final DateTime? dueDate;
  final DateTime? remindAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  
  // Subtasks
  final List<SubtaskEntity> subtasks;
  final bool hasSubtasks;
  
  // Time tracking
  final int estimatedMinutes;
  final int actualMinutes;
  final List<TimeLogEntity> timeLogs;
  
  // Gamification
  final int xpReward;
  final bool xpClaimed;
  final int difficultyMultiplier;
  
  // Collaboration
  final List<String> assignedUsers;
  final String? createdBy;
  final List<CommentEntity> comments;
  
  // Recurring
  final bool isRecurring;
  final String? recurringPattern; // daily, weekly, monthly, custom
  final Map<String, dynamic>? recurringConfig;
  final String? parentTaskId; // For recurring instances
  
  // Attachments
  final List<AttachmentEntity> attachments;
  
  // Integration
  final Map<String, dynamic>? integrationData; // Gmail, Calendar, etc.
  final String? sourceType; // manual, gmail, calendar, etc.
  
  // Location
  final String? location;
  final double? latitude;
  final double? longitude;
  
  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'todo',
    this.category,
    this.tags = const [],
    this.dueDate,
    this.remindAt,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
    this.subtasks = const [],
    this.hasSubtasks = false,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    this.timeLogs = const [],
    this.xpReward = 0,
    this.xpClaimed = false,
    this.difficultyMultiplier = 1,
    this.assignedUsers = const [],
    this.createdBy,
    this.comments = const [],
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringConfig,
    this.parentTaskId,
    this.attachments = const [],
    this.integrationData,
    this.sourceType,
    this.location,
    this.latitude,
    this.longitude,
  });

  bool get isCompleted => status == 'completed';
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isDueToday => dueDate != null && _isSameDay(dueDate!, DateTime.now());
  bool get isInProgress => status == 'in_progress';
  
  double get completionPercentage {
    if (!hasSubtasks || subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    return completedSubtasks / subtasks.length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? category,
    List<String>? tags,
    DateTime? dueDate,
    DateTime? remindAt,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    List<SubtaskEntity>? subtasks,
    bool? hasSubtasks,
    int? estimatedMinutes,
    int? actualMinutes,
    List<TimeLogEntity>? timeLogs,
    int? xpReward,
    bool? xpClaimed,
    int? difficultyMultiplier,
    List<String>? assignedUsers,
    String? createdBy,
    List<CommentEntity>? comments,
    bool? isRecurring,
    String? recurringPattern,
    Map<String, dynamic>? recurringConfig,
    String? parentTaskId,
    List<AttachmentEntity>? attachments,
    Map<String, dynamic>? integrationData,
    String? sourceType,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      remindAt: remindAt ?? this.remindAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      hasSubtasks: hasSubtasks ?? this.hasSubtasks,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      timeLogs: timeLogs ?? this.timeLogs,
      xpReward: xpReward ?? this.xpReward,
      xpClaimed: xpClaimed ?? this.xpClaimed,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      createdBy: createdBy ?? this.createdBy,
      comments: comments ?? this.comments,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringConfig: recurringConfig ?? this.recurringConfig,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      attachments: attachments ?? this.attachments,
      integrationData: integrationData ?? this.integrationData,
      sourceType: sourceType ?? this.sourceType,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        priority,
        status,
        category,
        tags,
        dueDate,
        remindAt,
        createdAt,
        completedAt,
        updatedAt,
        subtasks,
        hasSubtasks,
        estimatedMinutes,
        actualMinutes,
        timeLogs,
        xpReward,
        xpClaimed,
        difficultyMultiplier,
        assignedUsers,
        createdBy,
        comments,
        isRecurring,
        recurringPattern,
        recurringConfig,
        parentTaskId,
        attachments,
        integrationData,
        sourceType,
        location,
        latitude,
        longitude,
      ];
}

class SubtaskEntity extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int order;

  const SubtaskEntity({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.order = 0,
  });

  SubtaskEntity copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? order,
  }) {
    return SubtaskEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, isCompleted, createdAt, completedAt, order];
}

class TimeLogEntity extends Equatable {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String? description;
  final DateTime createdAt;

  const TimeLogEntity({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.description,
    required this.createdAt,
  });

  bool get isActive => endTime == null;

  TimeLogEntity copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? description,
    DateTime? createdAt,
  }) {
    return TimeLogEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, startTime, endTime, durationMinutes, description, createdAt];
}

class CommentEntity extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  CommentEntity copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, userId, username, content, createdAt, updatedAt];
}

class AttachmentEntity extends Equatable {
  final String id;
  final String taskId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;

  const AttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });

  AttachmentEntity copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? fileType,
    String? fileUrl,
    int? fileSize,
    DateTime? uploadedAt,
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, fileName, fileType, fileUrl, fileSize, uploadedAt];
}
