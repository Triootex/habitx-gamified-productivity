import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // reminder, achievement, social, system, promotion
  final String category; // task, habit, meditation, etc.
  final String priority; // low, medium, high, urgent
  final DateTime scheduledTime;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? dismissedAt;
  final bool isRead;
  final bool isDismissed;
  final bool isSent;
  
  // Rich content
  final String? imageUrl;
  final String? iconUrl;
  final Map<String, dynamic> customData;
  final List<NotificationActionEntity> actions;
  
  // Delivery settings
  final List<String> channels; // push, email, in_app, sms
  final Map<String, bool> channelSettings;
  final bool requiresInteraction;
  final DateTime? expiresAt;
  
  // Targeting and personalization
  final Map<String, dynamic> targetingCriteria;
  final String? segmentId;
  final bool isPersonalized;
  final Map<String, dynamic> personalizationData;
  
  // Analytics
  final bool wasOpened;
  final DateTime? openedAt;
  final bool wasActedUpon;
  final String? actionTaken;
  final Map<String, dynamic> analytics;
  
  // Recurring notifications
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime? nextScheduledTime;
  final int occurrenceCount;
  final int? maxOccurrences;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.category,
    this.priority = 'medium',
    required this.scheduledTime,
    this.sentAt,
    this.readAt,
    this.dismissedAt,
    this.isRead = false,
    this.isDismissed = false,
    this.isSent = false,
    this.imageUrl,
    this.iconUrl,
    this.customData = const {},
    this.actions = const [],
    this.channels = const ['push'],
    this.channelSettings = const {},
    this.requiresInteraction = false,
    this.expiresAt,
    this.targetingCriteria = const {},
    this.segmentId,
    this.isPersonalized = false,
    this.personalizationData = const {},
    this.wasOpened = false,
    this.openedAt,
    this.wasActedUpon = false,
    this.actionTaken,
    this.analytics = const {},
    this.isRecurring = false,
    this.recurringPattern,
    this.nextScheduledTime,
    this.occurrenceCount = 0,
    this.maxOccurrences,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => !isSent && DateTime.now().isBefore(scheduledTime);
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => !isRead && !isDismissed && !isExpired;
  bool get shouldRecur => isRecurring && (maxOccurrences == null || occurrenceCount < maxOccurrences!);

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? category,
    String? priority,
    DateTime? scheduledTime,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? dismissedAt,
    bool? isRead,
    bool? isDismissed,
    bool? isSent,
    String? imageUrl,
    String? iconUrl,
    Map<String, dynamic>? customData,
    List<NotificationActionEntity>? actions,
    List<String>? channels,
    Map<String, bool>? channelSettings,
    bool? requiresInteraction,
    DateTime? expiresAt,
    Map<String, dynamic>? targetingCriteria,
    String? segmentId,
    bool? isPersonalized,
    Map<String, dynamic>? personalizationData,
    bool? wasOpened,
    DateTime? openedAt,
    bool? wasActedUpon,
    String? actionTaken,
    Map<String, dynamic>? analytics,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? nextScheduledTime,
    int? occurrenceCount,
    int? maxOccurrences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      isSent: isSent ?? this.isSent,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      customData: customData ?? this.customData,
      actions: actions ?? this.actions,
      channels: channels ?? this.channels,
      channelSettings: channelSettings ?? this.channelSettings,
      requiresInteraction: requiresInteraction ?? this.requiresInteraction,
      expiresAt: expiresAt ?? this.expiresAt,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      segmentId: segmentId ?? this.segmentId,
      isPersonalized: isPersonalized ?? this.isPersonalized,
      personalizationData: personalizationData ?? this.personalizationData,
      wasOpened: wasOpened ?? this.wasOpened,
      openedAt: openedAt ?? this.openedAt,
      wasActedUpon: wasActedUpon ?? this.wasActedUpon,
      actionTaken: actionTaken ?? this.actionTaken,
      analytics: analytics ?? this.analytics,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      nextScheduledTime: nextScheduledTime ?? this.nextScheduledTime,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        category,
        priority,
        scheduledTime,
        sentAt,
        readAt,
        dismissedAt,
        isRead,
        isDismissed,
        isSent,
        imageUrl,
        iconUrl,
        customData,
        actions,
        channels,
        channelSettings,
        requiresInteraction,
        expiresAt,
        targetingCriteria,
        segmentId,
        isPersonalized,
        personalizationData,
        wasOpened,
        openedAt,
        wasActedUpon,
        actionTaken,
        analytics,
        isRecurring,
        recurringPattern,
        nextScheduledTime,
        occurrenceCount,
        maxOccurrences,
        createdAt,
        updatedAt,
      ];
}

class NotificationActionEntity extends Equatable {
  final String id;
  final String label;
  final String actionType; // open_app, deep_link, api_call, dismiss
  final String? actionUrl;
  final Map<String, dynamic> actionData;
  final bool isPrimary;
  final String? iconUrl;

  const NotificationActionEntity({
    required this.id,
    required this.label,
    required this.actionType,
    this.actionUrl,
    this.actionData = const {},
    this.isPrimary = false,
    this.iconUrl,
  });

  NotificationActionEntity copyWith({
    String? id,
    String? label,
    String? actionType,
    String? actionUrl,
    Map<String, dynamic>? actionData,
    bool? isPrimary,
    String? iconUrl,
  }) {
    return NotificationActionEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      actionType: actionType ?? this.actionType,
      actionUrl: actionUrl ?? this.actionUrl,
      actionData: actionData ?? this.actionData,
      isPrimary: isPrimary ?? this.isPrimary,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  @override
  List<Object?> get props => [id, label, actionType, actionUrl, actionData, isPrimary, iconUrl];
}

class NotificationTemplateEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String type;
  final String titleTemplate;
  final String bodyTemplate;
  final Map<String, dynamic> defaultData;
  final List<String> requiredVariables;
  final Map<String, String> variableDescriptions;
  final bool isActive;
  final String? iconUrl;
  final List<NotificationActionEntity> defaultActions;
  final Map<String, dynamic> channelSpecificContent;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NotificationTemplateEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.defaultData = const {},
    this.requiredVariables = const [],
    this.variableDescriptions = const {},
    this.isActive = true,
    this.iconUrl,
    this.defaultActions = const [],
    this.channelSpecificContent = const {},
    required this.createdAt,
    this.updatedAt,
  });

  NotificationTemplateEntity copyWith({
    String? id,
    String? name,
    String? category,
    String? type,
    String? titleTemplate,
    String? bodyTemplate,
    Map<String, dynamic>? defaultData,
    List<String>? requiredVariables,
    Map<String, String>? variableDescriptions,
    bool? isActive,
    String? iconUrl,
    List<NotificationActionEntity>? defaultActions,
    Map<String, dynamic>? channelSpecificContent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      defaultData: defaultData ?? this.defaultData,
      requiredVariables: requiredVariables ?? this.requiredVariables,
      variableDescriptions: variableDescriptions ?? this.variableDescriptions,
      isActive: isActive ?? this.isActive,
      iconUrl: iconUrl ?? this.iconUrl,
      defaultActions: defaultActions ?? this.defaultActions,
      channelSpecificContent: channelSpecificContent ?? this.channelSpecificContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        type,
        titleTemplate,
        bodyTemplate,
        defaultData,
        requiredVariables,
        variableDescriptions,
        isActive,
        iconUrl,
        defaultActions,
        channelSpecificContent,
        createdAt,
        updatedAt,
      ];
}

class NotificationSettingsEntity extends Equatable {
  final String id;
  final String userId;
  final bool globalEnabled;
  final Map<String, bool> categorySettings; // category -> enabled
  final Map<String, bool> typeSettings; // type -> enabled
  final Map<String, bool> channelSettings; // channel -> enabled
  final Map<String, Map<String, bool>> categoryChannelSettings; // category -> channel -> enabled
  
  // Time-based settings
  final bool enableQuietHours;
  final String? quietHoursStart; // HH:mm format
  final String? quietHoursEnd; // HH:mm format
  final List<int> quietDays; // 1=Monday, 7=Sunday
  final String timezone;
  
  // Frequency settings
  final Map<String, int> maxDailyNotifications; // category -> max count
  final int globalMaxDaily;
  final bool enableBatching;
  final int batchIntervalMinutes;
  
  // Smart settings
  final bool enableSmartTiming;
  final bool enableAdaptivePriority;
  final bool enableContextualFiltering;
  final Map<String, dynamic> smartSettings;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationSettingsEntity({
    required this.id,
    required this.userId,
    this.globalEnabled = true,
    this.categorySettings = const {},
    this.typeSettings = const {},
    this.channelSettings = const {},
    this.categoryChannelSettings = const {},
    this.enableQuietHours = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.quietDays = const [],
    this.timezone = 'UTC',
    this.maxDailyNotifications = const {},
    this.globalMaxDaily = 50,
    this.enableBatching = false,
    this.batchIntervalMinutes = 60,
    this.enableSmartTiming = true,
    this.enableAdaptivePriority = true,
    this.enableContextualFiltering = true,
    this.smartSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool isEnabledForCategory(String category) {
    return globalEnabled && (categorySettings[category] ?? true);
  }

  bool isEnabledForType(String type) {
    return globalEnabled && (typeSettings[type] ?? true);
  }

  bool isEnabledForChannel(String channel) {
    return globalEnabled && (channelSettings[channel] ?? true);
  }

  NotificationSettingsEntity copyWith({
    String? id,
    String? userId,
    bool? globalEnabled,
    Map<String, bool>? categorySettings,
    Map<String, bool>? typeSettings,
    Map<String, bool>? channelSettings,
    Map<String, Map<String, bool>>? categoryChannelSettings,
    bool? enableQuietHours,
    String? quietHoursStart,
    String? quietHoursEnd,
    List<int>? quietDays,
    String? timezone,
    Map<String, int>? maxDailyNotifications,
    int? globalMaxDaily,
    bool? enableBatching,
    int? batchIntervalMinutes,
    bool? enableSmartTiming,
    bool? enableAdaptivePriority,
    bool? enableContextualFiltering,
    Map<String, dynamic>? smartSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      globalEnabled: globalEnabled ?? this.globalEnabled,
      categorySettings: categorySettings ?? this.categorySettings,
      typeSettings: typeSettings ?? this.typeSettings,
      channelSettings: channelSettings ?? this.channelSettings,
      categoryChannelSettings: categoryChannelSettings ?? this.categoryChannelSettings,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietDays: quietDays ?? this.quietDays,
      timezone: timezone ?? this.timezone,
      maxDailyNotifications: maxDailyNotifications ?? this.maxDailyNotifications,
      globalMaxDaily: globalMaxDaily ?? this.globalMaxDaily,
      enableBatching: enableBatching ?? this.enableBatching,
      batchIntervalMinutes: batchIntervalMinutes ?? this.batchIntervalMinutes,
      enableSmartTiming: enableSmartTiming ?? this.enableSmartTiming,
      enableAdaptivePriority: enableAdaptivePriority ?? this.enableAdaptivePriority,
      enableContextualFiltering: enableContextualFiltering ?? this.enableContextualFiltering,
      smartSettings: smartSettings ?? this.smartSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        globalEnabled,
        categorySettings,
        typeSettings,
        channelSettings,
        categoryChannelSettings,
        enableQuietHours,
        quietHoursStart,
        quietHoursEnd,
        quietDays,
        timezone,
        maxDailyNotifications,
        globalMaxDaily,
        enableBatching,
        batchIntervalMinutes,
        enableSmartTiming,
        enableAdaptivePriority,
        enableContextualFiltering,
        smartSettings,
        createdAt,
        updatedAt,
      ];
}
