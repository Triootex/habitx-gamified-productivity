import 'package:equatable/equatable.dart';

class ALIConversationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String conversationType; // help, coaching, agent, tutorial, casual
  final String context; // productivity, wellness, learning, general
  final List<ALIMessageEntity> messages;
  final bool isActive;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime lastMessageAt;
  
  // Agent mode specific
  final bool isAgentMode;
  final List<String> grantedPermissions;
  final String? currentTask;
  final Map<String, dynamic> agentState;
  final List<String> toolsUsed;
  
  // Conversation analytics
  final int messageCount;
  final int userSatisfactionRating; // 1-5
  final List<String> topicsDiscussed;
  final Map<String, dynamic> conversationInsights;
  final double engagementScore;
  
  // Personalization
  final Map<String, dynamic> userContext;
  final List<String> userGoals;
  final String personalityProfile; // adaptive, supportive, direct, etc.
  final String preferredTone; // casual, professional, encouraging
  
  // Learning and adaptation
  final Map<String, dynamic> learnedPreferences;
  final List<String> effectiveStrategies;
  final Map<String, int> topicExpertise;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ALIConversationEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.conversationType = 'help',
    this.context = 'general',
    this.messages = const [],
    this.isActive = true,
    required this.startedAt,
    this.endedAt,
    required this.lastMessageAt,
    this.isAgentMode = false,
    this.grantedPermissions = const [],
    this.currentTask,
    this.agentState = const {},
    this.toolsUsed = const [],
    this.messageCount = 0,
    this.userSatisfactionRating = 0,
    this.topicsDiscussed = const [],
    this.conversationInsights = const {},
    this.engagementScore = 0.0,
    this.userContext = const {},
    this.userGoals = const [],
    this.personalityProfile = 'adaptive',
    this.preferredTone = 'casual',
    this.learnedPreferences = const {},
    this.effectiveStrategies = const [],
    this.topicExpertise = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasMessages => messages.isNotEmpty;
  bool get isOngoing => isActive && endedAt == null;
  Duration get conversationDuration => (endedAt ?? DateTime.now()).difference(startedAt);

  ALIConversationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? conversationType,
    String? context,
    List<ALIMessageEntity>? messages,
    bool? isActive,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? lastMessageAt,
    bool? isAgentMode,
    List<String>? grantedPermissions,
    String? currentTask,
    Map<String, dynamic>? agentState,
    List<String>? toolsUsed,
    int? messageCount,
    int? userSatisfactionRating,
    List<String>? topicsDiscussed,
    Map<String, dynamic>? conversationInsights,
    double? engagementScore,
    Map<String, dynamic>? userContext,
    List<String>? userGoals,
    String? personalityProfile,
    String? preferredTone,
    Map<String, dynamic>? learnedPreferences,
    List<String>? effectiveStrategies,
    Map<String, int>? topicExpertise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ALIConversationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      conversationType: conversationType ?? this.conversationType,
      context: context ?? this.context,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isAgentMode: isAgentMode ?? this.isAgentMode,
      grantedPermissions: grantedPermissions ?? this.grantedPermissions,
      currentTask: currentTask ?? this.currentTask,
      agentState: agentState ?? this.agentState,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      messageCount: messageCount ?? this.messageCount,
      userSatisfactionRating: userSatisfactionRating ?? this.userSatisfactionRating,
      topicsDiscussed: topicsDiscussed ?? this.topicsDiscussed,
      conversationInsights: conversationInsights ?? this.conversationInsights,
      engagementScore: engagementScore ?? this.engagementScore,
      userContext: userContext ?? this.userContext,
      userGoals: userGoals ?? this.userGoals,
      personalityProfile: personalityProfile ?? this.personalityProfile,
      preferredTone: preferredTone ?? this.preferredTone,
      learnedPreferences: learnedPreferences ?? this.learnedPreferences,
      effectiveStrategies: effectiveStrategies ?? this.effectiveStrategies,
      topicExpertise: topicExpertise ?? this.topicExpertise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        conversationType,
        context,
        messages,
        isActive,
        startedAt,
        endedAt,
        lastMessageAt,
        isAgentMode,
        grantedPermissions,
        currentTask,
        agentState,
        toolsUsed,
        messageCount,
        userSatisfactionRating,
        topicsDiscussed,
        conversationInsights,
        engagementScore,
        userContext,
        userGoals,
        personalityProfile,
        preferredTone,
        learnedPreferences,
        effectiveStrategies,
        topicExpertise,
        createdAt,
        updatedAt,
      ];
}

class ALIMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String role; // user, assistant, system
  final String content;
  final String messageType; // text, action, suggestion, question
  final DateTime timestamp;
  
  // Message formatting and display
  final String? formattedContent; // Markdown or rich text
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final String? referencedMessageId;
  
  // Agent mode actions
  final Map<String, dynamic>? actionData;
  final String? actionType; // create_task, set_reminder, etc.
  final String? actionStatus; // pending, completed, failed
  final Map<String, dynamic>? actionResult;
  
  // Interactive elements
  final List<String> quickReplies;
  final List<Map<String, dynamic>> suggestions;
  final Map<String, dynamic>? interactiveElements;
  
  // Analytics and feedback
  final bool isHelpful;
  final int? helpfulnessRating;
  final String? userFeedback;
  final double? confidenceScore;
  final List<String> intents;
  final Map<String, double> sentiment;
  
  // Voice and audio
  final String? audioUrl;
  final Duration? audioDuration;
  final bool isVoiceMessage;
  final Map<String, dynamic>? speechData;
  
  final bool isEdited;
  final DateTime? editedAt;

  const ALIMessageEntity({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.messageType = 'text',
    required this.timestamp,
    this.formattedContent,
    this.attachments = const [],
    this.metadata = const {},
    this.referencedMessageId,
    this.actionData,
    this.actionType,
    this.actionStatus,
    this.actionResult,
    this.quickReplies = const [],
    this.suggestions = const [],
    this.interactiveElements,
    this.isHelpful = false,
    this.helpfulnessRating,
    this.userFeedback,
    this.confidenceScore,
    this.intents = const [],
    this.sentiment = const {},
    this.audioUrl,
    this.audioDuration,
    this.isVoiceMessage = false,
    this.speechData,
    this.isEdited = false,
    this.editedAt,
  });

  bool get isFromUser => role == 'user';
  bool get isFromAssistant => role == 'assistant';
  bool get hasAction => actionData != null;
  bool get hasAudio => audioUrl != null;
  bool get hasSuggestions => suggestions.isNotEmpty;

  ALIMessageEntity copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? messageType,
    DateTime? timestamp,
    String? formattedContent,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? referencedMessageId,
    Map<String, dynamic>? actionData,
    String? actionType,
    String? actionStatus,
    Map<String, dynamic>? actionResult,
    List<String>? quickReplies,
    List<Map<String, dynamic>>? suggestions,
    Map<String, dynamic>? interactiveElements,
    bool? isHelpful,
    int? helpfulnessRating,
    String? userFeedback,
    double? confidenceScore,
    List<String>? intents,
    Map<String, double>? sentiment,
    String? audioUrl,
    Duration? audioDuration,
    bool? isVoiceMessage,
    Map<String, dynamic>? speechData,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return ALIMessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      formattedContent: formattedContent ?? this.formattedContent,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      referencedMessageId: referencedMessageId ?? this.referencedMessageId,
      actionData: actionData ?? this.actionData,
      actionType: actionType ?? this.actionType,
      actionStatus: actionStatus ?? this.actionStatus,
      actionResult: actionResult ?? this.actionResult,
      quickReplies: quickReplies ?? this.quickReplies,
      suggestions: suggestions ?? this.suggestions,
      interactiveElements: interactiveElements ?? this.interactiveElements,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulnessRating: helpfulnessRating ?? this.helpfulnessRating,
      userFeedback: userFeedback ?? this.userFeedback,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      intents: intents ?? this.intents,
      sentiment: sentiment ?? this.sentiment,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      isVoiceMessage: isVoiceMessage ?? this.isVoiceMessage,
      speechData: speechData ?? this.speechData,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        messageType,
        timestamp,
        formattedContent,
        attachments,
        metadata,
        referencedMessageId,
        actionData,
        actionType,
        actionStatus,
        actionResult,
        quickReplies,
        suggestions,
        interactiveElements,
        isHelpful,
        helpfulnessRating,
        userFeedback,
        confidenceScore,
        intents,
        sentiment,
        audioUrl,
        audioDuration,
        isVoiceMessage,
        speechData,
        isEdited,
        editedAt,
      ];
}

class ALIKnowledgeEntity extends Equatable {
  final String id;
  final String userId;
  final String category; // personal_facts, preferences, goals, expertise
  final String knowledgeType; // fact, preference, goal, skill, relationship
  final String title;
  final String content;
  final String? source; // conversation, user_input, inferred, imported
  final double confidence; // 0.0 to 1.0
  final DateTime learnedAt;
  final DateTime? lastConfirmed;
  final int confirmationCount;
  final bool isActive;
  final List<String> relatedTopics;
  final Map<String, dynamic> metadata;
  final DateTime? expiresAt; // For time-sensitive knowledge

  const ALIKnowledgeEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.knowledgeType,
    required this.title,
    required this.content,
    this.source,
    this.confidence = 1.0,
    required this.learnedAt,
    this.lastConfirmed,
    this.confirmationCount = 1,
    this.isActive = true,
    this.relatedTopics = const [],
    this.metadata = const {},
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isHighConfidence => confidence >= 0.8;
  bool get needsConfirmation => confirmationCount < 3 && confidence < 0.7;

  ALIKnowledgeEntity copyWith({
    String? id,
    String? userId,
    String? category,
    String? knowledgeType,
    String? title,
    String? content,
    String? source,
    double? confidence,
    DateTime? learnedAt,
    DateTime? lastConfirmed,
    int? confirmationCount,
    bool? isActive,
    List<String>? relatedTopics,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
  }) {
    return ALIKnowledgeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      knowledgeType: knowledgeType ?? this.knowledgeType,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      learnedAt: learnedAt ?? this.learnedAt,
      lastConfirmed: lastConfirmed ?? this.lastConfirmed,
      confirmationCount: confirmationCount ?? this.confirmationCount,
      isActive: isActive ?? this.isActive,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      metadata: metadata ?? this.metadata,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        knowledgeType,
        title,
        content,
        source,
        confidence,
        learnedAt,
        lastConfirmed,
        confirmationCount,
        isActive,
        relatedTopics,
        metadata,
        expiresAt,
      ];
}

class ALIAgentTaskEntity extends Equatable {
  final String id;
  final String conversationId;
  final String userId;
  final String taskType; // create_task, set_reminder, analyze_data, etc.
  final String description;
  final Map<String, dynamic> parameters;
  final String status; // pending, in_progress, completed, failed, cancelled
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? result;
  final String? errorMessage;
  final List<String> permissionsRequired;
  final bool userApprovalRequired;
  final bool isApproved;
  final DateTime? approvedAt;
  final String? approvalNote;
  final int priority; // 1-5, higher is more urgent
  final Map<String, dynamic> metadata;

  const ALIAgentTaskEntity({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.taskType,
    required this.description,
    this.parameters = const {},
    this.status = 'pending',
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.result,
    this.errorMessage,
    this.permissionsRequired = const [],
    this.userApprovalRequired = false,
    this.isApproved = false,
    this.approvedAt,
    this.approvalNote,
    this.priority = 3,
    this.metadata = const {},
  });

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
  bool get needsApproval => userApprovalRequired && !isApproved;
  bool get canExecute => !needsApproval || isApproved;

  ALIAgentTaskEntity copyWith({
    String? id,
    String? conversationId,
    String? userId,
    String? taskType,
    String? description,
    Map<String, dynamic>? parameters,
    String? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? result,
    String? errorMessage,
    List<String>? permissionsRequired,
    bool? userApprovalRequired,
    bool? isApproved,
    DateTime? approvedAt,
    String? approvalNote,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return ALIAgentTaskEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      taskType: taskType ?? this.taskType,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionsRequired: permissionsRequired ?? this.permissionsRequired,
      userApprovalRequired: userApprovalRequired ?? this.userApprovalRequired,
      isApproved: isApproved ?? this.isApproved,
      approvedAt: approvedAt ?? this.approvedAt,
      approvalNote: approvalNote ?? this.approvalNote,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        userId,
        taskType,
        description,
        parameters,
        status,
        createdAt,
        startedAt,
        completedAt,
        result,
        errorMessage,
        permissionsRequired,
        userApprovalRequired,
        isApproved,
        approvedAt,
        approvalNote,
        priority,
        metadata,
      ];
}

class ALIInsightEntity extends Equatable {
  final String id;
  final String userId;
  final String category; // productivity, wellness, patterns, recommendations
  final String insightType; // trend, prediction, anomaly, suggestion
  final String title;
  final String description;
  final double confidence; // 0.0 to 1.0
  final String priority; // low, medium, high, urgent
  final Map<String, dynamic> data; // Supporting data for the insight
  final List<String> actionSuggestions;
  final DateTime generatedAt;
  final bool isViewed;
  final DateTime? viewedAt;
  final bool isActedUpon;
  final DateTime? actedUponAt;
  final String? userFeedback;
  final int? helpfulnessRating;
  final Map<String, dynamic> metadata;

  const ALIInsightEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.insightType,
    required this.title,
    required this.description,
    this.confidence = 1.0,
    this.priority = 'medium',
    this.data = const {},
    this.actionSuggestions = const [],
    required this.generatedAt,
    this.isViewed = false,
    this.viewedAt,
    this.isActedUpon = false,
    this.actedUponAt,
    this.userFeedback,
    this.helpfulnessRating,
    this.metadata = const {},
  });

  bool get isHighPriority => priority == 'high' || priority == 'urgent';
  bool get isReliable => confidence >= 0.7;
  bool get hasActions => actionSuggestions.isNotEmpty;

  ALIInsightEntity copyWith({
    String? id,
    String? userId,
    String? category,
    String? insightType,
    String? title,
    String? description,
    double? confidence,
    String? priority,
    Map<String, dynamic>? data,
    List<String>? actionSuggestions,
    DateTime? generatedAt,
    bool? isViewed,
    DateTime? viewedAt,
    bool? isActedUpon,
    DateTime? actedUponAt,
    String? userFeedback,
    int? helpfulnessRating,
    Map<String, dynamic>? metadata,
  }) {
    return ALIInsightEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      insightType: insightType ?? this.insightType,
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      actionSuggestions: actionSuggestions ?? this.actionSuggestions,
      generatedAt: generatedAt ?? this.generatedAt,
      isViewed: isViewed ?? this.isViewed,
      viewedAt: viewedAt ?? this.viewedAt,
      isActedUpon: isActedUpon ?? this.isActedUpon,
      actedUponAt: actedUponAt ?? this.actedUponAt,
      userFeedback: userFeedback ?? this.userFeedback,
      helpfulnessRating: helpfulnessRating ?? this.helpfulnessRating,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        insightType,
        title,
        description,
        confidence,
        priority,
        data,
        actionSuggestions,
        generatedAt,
        isViewed,
        viewedAt,
        isActedUpon,
        actedUponAt,
        userFeedback,
        helpfulnessRating,
        metadata,
      ];
}
