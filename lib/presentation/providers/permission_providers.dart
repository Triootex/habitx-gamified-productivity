import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/permissions/permission_manager.dart';
import '../../core/di/injection.dart';

// Permission Manager Provider
final permissionManagerProvider = Provider<PermissionManager>((ref) => getIt<PermissionManager>());

// Permission State
class PermissionState {
  final Map<AppPermission, PermissionStatus> permissions;
  final bool isLoading;
  final String? error;
  final bool hasShownOnboarding;
  final List<AppPermission> requestedPermissions;

  const PermissionState({
    this.permissions = const {},
    this.isLoading = false,
    this.error,
    this.hasShownOnboarding = false,
    this.requestedPermissions = const [],
  });

  PermissionState copyWith({
    Map<AppPermission, PermissionStatus>? permissions,
    bool? isLoading,
    String? error,
    bool? hasShownOnboarding,
    List<AppPermission>? requestedPermissions,
  }) {
    return PermissionState(
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasShownOnboarding: hasShownOnboarding ?? this.hasShownOnboarding,
      requestedPermissions: requestedPermissions ?? this.requestedPermissions,
    );
  }

  bool isPermissionGranted(AppPermission permission) {
    return permissions[permission]?.isGranted ?? false;
  }

  bool isPermissionDenied(AppPermission permission) {
    return permissions[permission]?.isDenied ?? false;
  }

  bool isPermissionPermanentlyDenied(AppPermission permission) {
    return permissions[permission]?.isPermanentlyDenied ?? false;
  }
}

// Permission State Notifier
class PermissionNotifier extends StateNotifier<PermissionState> {
  final PermissionManager permissionManager;

  PermissionNotifier(this.permissionManager) : super(const PermissionState()) {
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final permissions = await permissionManager.getAllPermissionStatuses();
      state = state.copyWith(
        permissions: permissions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load permissions: ${e.toString()}',
      );
    }
  }

  Future<bool> requestPermission(AppPermission permission) async {
    if (state.isPermissionGranted(permission)) return true;

    state = state.copyWith(isLoading: true);
    
    try {
      final status = await permissionManager.requestPermission(permission);
      final updatedPermissions = Map<AppPermission, PermissionStatus>.from(state.permissions);
      updatedPermissions[permission] = status;
      
      final updatedRequested = List<AppPermission>.from(state.requestedPermissions);
      if (!updatedRequested.contains(permission)) {
        updatedRequested.add(permission);
      }
      
      state = state.copyWith(
        permissions: updatedPermissions,
        requestedPermissions: updatedRequested,
        isLoading: false,
        error: null,
      );
      
      return status.isGranted;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to request permission: ${e.toString()}',
      );
      return false;
    }
  }

  Future<Map<AppPermission, bool>> requestMultiplePermissions(List<AppPermission> permissions) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final statusMap = await permissionManager.requestPermissions(permissions);
      final updatedPermissions = Map<AppPermission, PermissionStatus>.from(state.permissions);
      final results = <AppPermission, bool>{};
      
      statusMap.forEach((permission, status) {
        updatedPermissions[permission] = status;
        results[permission] = status.isGranted;
      });
      
      final updatedRequested = List<AppPermission>.from(state.requestedPermissions);
      for (final permission in permissions) {
        if (!updatedRequested.contains(permission)) {
          updatedRequested.add(permission);
        }
      }
      
      state = state.copyWith(
        permissions: updatedPermissions,
        requestedPermissions: updatedRequested,
        isLoading: false,
        error: null,
      );
      
      return results;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to request permissions: ${e.toString()}',
      );
      return {};
    }
  }

  Future<void> requestCriticalPermissions() async {
    final criticalPermissions = permissionManager.getCriticalPermissions();
    await requestMultiplePermissions(criticalPermissions);
  }

  Future<void> requestRecommendedPermissions() async {
    final permissionsByPriority = permissionManager.getPermissionsByPriority();
    final recommended = permissionsByPriority['recommended'] ?? [];
    await requestMultiplePermissions(recommended);
  }

  Future<bool> isFeatureAvailable(String feature) async {
    return await permissionManager.isFeatureAvailable(feature);
  }

  Future<List<AppPermission>> getMissingPermissionsForFeature(String feature) async {
    return await permissionManager.getMissingPermissionsForFeature(feature);
  }

  Future<void> openAppSettings() async {
    await permissionManager.openAppSettings();
  }

  void markOnboardingShown() {
    state = state.copyWith(hasShownOnboarding: true);
  }

  Future<void> refreshPermissions() async {
    await _initializePermissions();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Permission Provider
final permissionProvider = StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier(ref.read(permissionManagerProvider));
});

// Computed Providers for specific permissions
final notificationsPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.notifications);
});

final cameraPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.camera);
});

final locationPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.location);
});

final healthPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.health);
});

final microphonePermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.microphone);
});

final contactsPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.contacts);
});

final calendarPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.calendar);
});

final storagePermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.storage);
});

final photosPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.photos);
});

final activityRecognitionPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  return permissionState.isPermissionGranted(AppPermission.activityRecognition);
});

// Feature Availability Providers
final barcodeScanningAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('barcode_scanning');
});

final voiceNotesAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('voice_notes');
});

final healthSyncAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('health_app_sync');
});

final locationRemindersAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('location_based_reminders');
});

final socialFeaturesAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('social_connections');
});

final offlineModeAvailableProvider = FutureProvider<bool>((ref) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.isFeatureAvailable('offline_mode');
});

// Permission Groups
final criticalPermissionsStatusProvider = Provider<Map<AppPermission, bool>>((ref) {
  final permissionState = ref.watch(permissionProvider);
  final criticalPermissions = ref.read(permissionManagerProvider).getCriticalPermissions();
  
  return Map.fromEntries(
    criticalPermissions.map((permission) => MapEntry(
      permission,
      permissionState.isPermissionGranted(permission),
    )),
  );
});

final optionalPermissionsStatusProvider = Provider<Map<AppPermission, bool>>((ref) {
  final permissionState = ref.watch(permissionProvider);
  final optionalPermissions = ref.read(permissionManagerProvider).getOptionalPermissions();
  
  return Map.fromEntries(
    optionalPermissions.map((permission) => MapEntry(
      permission,
      permissionState.isPermissionGranted(permission),
    )),
  );
});

// Permission Summary
final permissionSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final permissionState = ref.watch(permissionProvider);
  final permissionManager = ref.read(permissionManagerProvider);
  
  final all = AppPermission.values;
  final granted = all.where((p) => permissionState.isPermissionGranted(p)).length;
  final denied = all.where((p) => permissionState.isPermissionDenied(p)).length;
  final permanentlyDenied = all.where((p) => permissionState.isPermissionPermanentlyDenied(p)).length;
  
  final critical = permissionManager.getCriticalPermissions();
  final criticalGranted = critical.where((p) => permissionState.isPermissionGranted(p)).length;
  
  return {
    'total_permissions': all.length,
    'granted': granted,
    'denied': denied,
    'permanently_denied': permanentlyDenied,
    'critical_total': critical.length,
    'critical_granted': criticalGranted,
    'completion_percentage': ((granted / all.length) * 100).round(),
    'critical_completion_percentage': ((criticalGranted / critical.length) * 100).round(),
  };
});

// Missing Permissions for Features
final missingPermissionsProvider = FutureProvider.family<List<AppPermission>, String>((ref, feature) async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  return await permissionNotifier.getMissingPermissionsForFeature(feature);
});

// Should Show Permission Onboarding
final shouldShowPermissionOnboardingProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(permissionProvider);
  final summary = ref.watch(permissionSummaryProvider);
  
  return !permissionState.hasShownOnboarding && 
         (summary['critical_completion_percentage'] as int) < 100;
});

// Permission Request Helper
final permissionRequestHelperProvider = Provider<PermissionRequestHelper>((ref) {
  return PermissionRequestHelper(ref.read(permissionProvider.notifier));
});

class PermissionRequestHelper {
  final PermissionNotifier permissionNotifier;
  
  PermissionRequestHelper(this.permissionNotifier);
  
  Future<bool> ensurePermissionForFeature(String feature) async {
    final isAvailable = await permissionNotifier.isFeatureAvailable(feature);
    if (isAvailable) return true;
    
    final missingPermissions = await permissionNotifier.getMissingPermissionsForFeature(feature);
    if (missingPermissions.isEmpty) return true;
    
    final results = await permissionNotifier.requestMultiplePermissions(missingPermissions);
    return results.values.every((granted) => granted);
  }
  
  Future<bool> requestPermissionWithFallback(AppPermission permission) async {
    final granted = await permissionNotifier.requestPermission(permission);
    if (!granted) {
      // Could show explanation dialog or redirect to settings
      return false;
    }
    return true;
  }
}
