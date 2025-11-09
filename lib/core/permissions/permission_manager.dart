import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

enum AppPermission {
  // Core Permissions
  notifications,
  storage,
  
  // Health & Fitness
  camera, // For barcode scanning, progress photos
  microphone, // For voice notes, meditation
  activityRecognition, // For fitness tracking
  location, // For location-based reminders
  
  // Health App Integration
  health, // iOS HealthKit
  
  // Social Features
  contacts, // For finding friends
  
  // Productivity
  calendar, // For scheduling tasks/habits
  
  // Media
  photos, // For saving/accessing images
}

class PermissionFeatureMap {
  static const Map<AppPermission, List<String>> _permissionFeatures = {
    AppPermission.notifications: [
      'habit_reminders',
      'task_deadlines',
      'focus_timers',
      'meditation_sessions',
      'meal_reminders',
      'sleep_bedtime_alerts',
    ],
    AppPermission.camera: [
      'barcode_scanning',
      'progress_photos',
      'meal_logging',
      'book_scanning',
      'document_scanning',
    ],
    AppPermission.microphone: [
      'voice_notes',
      'meditation_guidance',
      'voice_commands',
      'audio_journaling',
    ],
    AppPermission.location: [
      'location_based_reminders',
      'gym_check_ins',
      'weather_integration',
      'contextual_suggestions',
    ],
    AppPermission.health: [
      'health_app_sync',
      'fitness_tracking',
      'sleep_tracking',
      'heart_rate_monitoring',
      'step_counting',
    ],
    AppPermission.contacts: [
      'social_connections',
      'friend_invitations',
      'challenge_sharing',
    ],
    AppPermission.calendar: [
      'task_scheduling',
      'habit_planning',
      'appointment_integration',
    ],
    AppPermission.storage: [
      'offline_mode',
      'data_backup',
      'export_functionality',
    ],
    AppPermission.photos: [
      'progress_gallery',
      'meal_photos',
      'avatar_customization',
    ],
    AppPermission.activityRecognition: [
      'automatic_workout_detection',
      'activity_insights',
      'movement_reminders',
    ],
  };

  static List<String> getFeaturesForPermission(AppPermission permission) {
    return _permissionFeatures[permission] ?? [];
  }

  static List<AppPermission> getPermissionsForFeature(String feature) {
    final permissions = <AppPermission>[];
    _permissionFeatures.forEach((permission, features) {
      if (features.contains(feature)) {
        permissions.add(permission);
      }
    });
    return permissions;
  }
}

@singleton
class PermissionManager {
  final Map<AppPermission, PermissionStatus> _permissionCache = {};
  
  // Permission to system permission mapping
  static const Map<AppPermission, Permission> _permissionMap = {
    AppPermission.notifications: Permission.notification,
    AppPermission.camera: Permission.camera,
    AppPermission.microphone: Permission.microphone,
    AppPermission.location: Permission.locationWhenInUse,
    AppPermission.storage: Permission.storage,
    AppPermission.contacts: Permission.contacts,
    AppPermission.calendar: Permission.calendarFullAccess,
    AppPermission.photos: Permission.photos,
    AppPermission.activityRecognition: Permission.activityRecognition,
  };

  /// Check if a specific permission is granted
  Future<bool> isPermissionGranted(AppPermission permission) async {
    final systemPermission = _permissionMap[permission];
    if (systemPermission == null) return false;

    final status = await systemPermission.status;
    _permissionCache[permission] = status;
    return status.isGranted;
  }

  /// Check multiple permissions at once
  Future<Map<AppPermission, bool>> checkPermissions(List<AppPermission> permissions) async {
    final results = <AppPermission, bool>{};
    
    for (final permission in permissions) {
      results[permission] = await isPermissionGranted(permission);
    }
    
    return results;
  }

  /// Request a specific permission
  Future<PermissionStatus> requestPermission(AppPermission permission) async {
    final systemPermission = _permissionMap[permission];
    if (systemPermission == null) return PermissionStatus.denied;

    final status = await systemPermission.request();
    _permissionCache[permission] = status;
    return status;
  }

  /// Request multiple permissions
  Future<Map<AppPermission, PermissionStatus>> requestPermissions(List<AppPermission> permissions) async {
    final systemPermissions = permissions
        .map((p) => _permissionMap[p])
        .where((p) => p != null)
        .cast<Permission>()
        .toList();

    final statusMap = await systemPermissions.request();
    final results = <AppPermission, PermissionStatus>{};

    permissions.forEach((appPermission) {
      final systemPermission = _permissionMap[appPermission];
      if (systemPermission != null) {
        final status = statusMap[systemPermission] ?? PermissionStatus.denied;
        _permissionCache[appPermission] = status;
        results[appPermission] = status;
      }
    });

    return results;
  }

  /// Check if a feature is available based on required permissions
  Future<bool> isFeatureAvailable(String feature) async {
    final requiredPermissions = PermissionFeatureMap.getPermissionsForFeature(feature);
    
    if (requiredPermissions.isEmpty) return true;

    for (final permission in requiredPermissions) {
      if (!await isPermissionGranted(permission)) {
        return false;
      }
    }
    
    return true;
  }

  /// Get missing permissions for a feature
  Future<List<AppPermission>> getMissingPermissionsForFeature(String feature) async {
    final requiredPermissions = PermissionFeatureMap.getPermissionsForFeature(feature);
    final missingPermissions = <AppPermission>[];

    for (final permission in requiredPermissions) {
      if (!await isPermissionGranted(permission)) {
        missingPermissions.add(permission);
      }
    }

    return missingPermissions;
  }

  /// Open app settings for manual permission management
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get user-friendly permission description
  String getPermissionDescription(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return 'Send you reminders for habits, tasks, and focus sessions';
      case AppPermission.camera:
        return 'Scan barcodes, take progress photos, and log meals visually';
      case AppPermission.microphone:
        return 'Record voice notes and provide meditation guidance';
      case AppPermission.location:
        return 'Provide location-based reminders and contextual suggestions';
      case AppPermission.health:
        return 'Sync with health apps for comprehensive fitness tracking';
      case AppPermission.contacts:
        return 'Connect with friends and share challenges';
      case AppPermission.calendar:
        return 'Schedule tasks and habits in your calendar';
      case AppPermission.storage:
        return 'Store data locally for offline access and backups';
      case AppPermission.photos:
        return 'Access and save photos for progress tracking';
      case AppPermission.activityRecognition:
        return 'Automatically detect workouts and physical activities';
    }
  }

  /// Get permission rationale for better user understanding
  String getPermissionRationale(AppPermission permission) {
    switch (permission) {
      case AppPermission.notifications:
        return 'Stay on track with timely reminders for your habits and goals. You can customize which notifications you receive.';
      case AppPermission.camera:
        return 'Quickly log meals by scanning barcodes, track progress with photos, and add books by scanning ISBN codes.';
      case AppPermission.microphone:
        return 'Add voice notes to your journal entries and receive guided meditation instructions.';
      case AppPermission.location:
        return 'Get contextual reminders like "time for a walk" when you\'re at the office, or gym check-ins when nearby.';
      case AppPermission.health:
        return 'Automatically sync your fitness data, sleep patterns, and health metrics for comprehensive wellness tracking.';
      case AppPermission.contacts:
        return 'Find friends already using HabitX and participate in social challenges together.';
      case AppPermission.calendar:
        return 'Schedule your habits and tasks directly in your calendar for better time management.';
      case AppPermission.storage:
        return 'Keep your data accessible even when offline and enable secure backups of your progress.';
      case AppPermission.photos:
        return 'Save your progress photos and meal images to track your journey over time.';
      case AppPermission.activityRecognition:
        return 'Automatically detect when you\'re working out or being active for effortless fitness tracking.';
    }
  }

  /// Get cached permission status (non-async)
  PermissionStatus? getCachedPermissionStatus(AppPermission permission) {
    return _permissionCache[permission];
  }

  /// Clear permission cache
  void clearCache() {
    _permissionCache.clear();
  }

  /// Get all permissions with their current status
  Future<Map<AppPermission, PermissionStatus>> getAllPermissionStatuses() async {
    final results = <AppPermission, PermissionStatus>{};
    
    for (final permission in AppPermission.values) {
      final systemPermission = _permissionMap[permission];
      if (systemPermission != null) {
        final status = await systemPermission.status;
        _permissionCache[permission] = status;
        results[permission] = status;
      }
    }
    
    return results;
  }

  /// Check if permission should be requested (not permanently denied)
  Future<bool> shouldRequestPermission(AppPermission permission) async {
    final systemPermission = _permissionMap[permission];
    if (systemPermission == null) return false;

    final status = await systemPermission.status;
    return !status.isPermanentlyDenied;
  }

  /// Get critical permissions that should be requested on app start
  List<AppPermission> getCriticalPermissions() {
    return [
      AppPermission.notifications,
      AppPermission.storage,
    ];
  }

  /// Get optional permissions that enhance the experience
  List<AppPermission> getOptionalPermissions() {
    return [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.location,
      AppPermission.health,
      AppPermission.contacts,
      AppPermission.calendar,
      AppPermission.photos,
      AppPermission.activityRecognition,
    ];
  }

  /// Get permissions by priority level
  Map<String, List<AppPermission>> getPermissionsByPriority() {
    return {
      'critical': getCriticalPermissions(),
      'recommended': [
        AppPermission.camera,
        AppPermission.health,
        AppPermission.calendar,
      ],
      'optional': [
        AppPermission.microphone,
        AppPermission.location,
        AppPermission.contacts,
        AppPermission.photos,
        AppPermission.activityRecognition,
      ],
    };
  }
}
