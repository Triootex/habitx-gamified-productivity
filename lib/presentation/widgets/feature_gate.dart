import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions/permission_manager.dart';
import '../providers/permission_providers.dart';
import 'permission_onboarding.dart';

/// A widget that conditionally shows its child based on permission availability
/// If permissions are missing, shows fallback UI or permission request
class FeatureGate extends ConsumerWidget {
  final String feature;
  final Widget child;
  final Widget? fallback;
  final bool showPermissionRequest;
  final String? customPermissionMessage;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const FeatureGate({
    Key? key,
    required this.feature,
    required this.child,
    this.fallback,
    this.showPermissionRequest = true,
    this.customPermissionMessage,
    this.onPermissionGranted,
    this.onPermissionDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureAvailable = ref.watch(
      missingPermissionsProvider(feature),
    );

    return featureAvailable.when(
      data: (missingPermissions) {
        if (missingPermissions.isEmpty) {
          // All permissions granted, show the feature
          return child;
        } else {
          // Missing permissions, show fallback or request
          return _buildMissingPermissionWidget(
            context,
            ref,
            missingPermissions,
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => fallback ?? _buildErrorWidget(error),
    );
  }

  Widget _buildMissingPermissionWidget(
    BuildContext context,
    WidgetRef ref,
    List<AppPermission> missingPermissions,
  ) {
    if (!showPermissionRequest && fallback != null) {
      return fallback!;
    }

    return PermissionRequestWidget(
      permissions: missingPermissions,
      feature: feature,
      customMessage: customPermissionMessage,
      onPermissionsGranted: () {
        onPermissionGranted?.call();
      },
      onPermissionsDenied: () {
        onPermissionDenied?.call();
      },
      fallback: fallback,
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Feature unavailable',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Widget that requests permissions for a specific feature
class PermissionRequestWidget extends ConsumerWidget {
  final List<AppPermission> permissions;
  final String feature;
  final String? customMessage;
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;
  final Widget? fallback;

  const PermissionRequestWidget({
    Key? key,
    required this.permissions,
    required this.feature,
    this.customMessage,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionManager = ref.read(permissionManagerProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFeatureIcon(feature),
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Enable ${_getFeatureDisplayName(feature)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            customMessage ?? _getFeatureDescription(feature),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Permissions list
          if (permissions.length > 1) ...[
            Text(
              'Required permissions:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...permissions.map((permission) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _getPermissionIcon(permission),
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      permissionManager.getPermissionDescription(permission),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          
          // Action buttons
          Row(
            children: [
              if (fallback != null)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      onPermissionsDenied?.call();
                    },
                    child: const Text('Use Limited Mode'),
                  ),
                ),
              if (fallback != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final results = await ref.read(permissionProvider.notifier)
                        .requestMultiplePermissions(permissions);
                    
                    final allGranted = results.values.every((granted) => granted);
                    
                    if (allGranted) {
                      onPermissionsGranted?.call();
                    } else {
                      onPermissionsDenied?.call();
                    }
                  },
                  child: Text(permissions.length > 1 ? 'Grant Permissions' : 'Grant Permission'),
                ),
              ),
            ],
          ),
          
          // Settings link for permanently denied permissions
          if (permissions.any((p) => ref.read(permissionProvider)
              .isPermissionPermanentlyDenied(p))) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                await ref.read(permissionProvider.notifier).openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    final icons = {
      'barcode_scanning': Icons.qr_code_scanner,
      'voice_notes': Icons.mic,
      'health_app_sync': Icons.favorite,
      'location_based_reminders': Icons.location_on,
      'social_connections': Icons.people,
      'offline_mode': Icons.cloud_off,
      'progress_photos': Icons.camera_alt,
      'meal_logging': Icons.restaurant,
      'habit_reminders': Icons.notifications,
      'task_deadlines': Icons.schedule,
      'focus_timers': Icons.timer,
    };
    
    return icons[feature] ?? Icons.extension;
  }

  String _getFeatureDisplayName(String feature) {
    final names = {
      'barcode_scanning': 'Barcode Scanning',
      'voice_notes': 'Voice Notes',
      'health_app_sync': 'Health App Sync',
      'location_based_reminders': 'Location Reminders',
      'social_connections': 'Social Features',
      'offline_mode': 'Offline Mode',
      'progress_photos': 'Progress Photos',
      'meal_logging': 'Meal Logging',
      'habit_reminders': 'Habit Reminders',
      'task_deadlines': 'Task Reminders',
      'focus_timers': 'Focus Timers',
    };
    
    return names[feature] ?? feature.replaceAll('_', ' ').toUpperCase();
  }

  String _getFeatureDescription(String feature) {
    final descriptions = {
      'barcode_scanning': 'Scan barcodes to quickly add books and food items to your tracking.',
      'voice_notes': 'Add voice notes to your journal entries and meditation sessions.',
      'health_app_sync': 'Automatically sync your fitness and health data from your device.',
      'location_based_reminders': 'Get contextual reminders based on your location.',
      'social_connections': 'Connect with friends and participate in challenges.',
      'offline_mode': 'Access your data even when you\'re not connected to the internet.',
      'progress_photos': 'Take and save photos to track your progress over time.',
      'meal_logging': 'Visually log your meals by taking photos.',
      'habit_reminders': 'Receive notifications to help you stay consistent with your habits.',
      'task_deadlines': 'Get reminded about important task deadlines.',
      'focus_timers': 'Use timer notifications during focus sessions.',
    };
    
    return descriptions[feature] ?? 'This feature requires additional permissions to work properly.';
  }

  IconData _getPermissionIcon(AppPermission permission) {
    final icons = {
      AppPermission.camera: Icons.camera_alt,
      AppPermission.microphone: Icons.mic,
      AppPermission.location: Icons.location_on,
      AppPermission.notifications: Icons.notifications,
      AppPermission.health: Icons.favorite,
      AppPermission.contacts: Icons.contacts,
      AppPermission.calendar: Icons.calendar_today,
      AppPermission.storage: Icons.storage,
      AppPermission.photos: Icons.photo_library,
      AppPermission.activityRecognition: Icons.directions_run,
    };
    
    return icons[permission] ?? Icons.security;
  }
}

/// Specific feature gates for common use cases
class CameraScannerGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CameraScannerGate({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeatureGate(
      feature: 'barcode_scanning',
      fallback: fallback ?? _buildCameraFallback(context),
      child: child,
    );
  }

  Widget _buildCameraFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Manual Entry Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You can still add items manually without camera access.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class VoiceNotesGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const VoiceNotesGate({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeatureGate(
      feature: 'voice_notes',
      fallback: fallback ?? _buildVoiceFallback(context),
      child: child,
    );
  }

  Widget _buildVoiceFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.keyboard, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Text Input Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You can still add notes by typing them out.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class HealthSyncGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const HealthSyncGate({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeatureGate(
      feature: 'health_app_sync',
      fallback: fallback ?? _buildHealthFallback(context),
      child: child,
    );
  }

  Widget _buildHealthFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.input, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Manual Tracking Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You can still track your fitness data by entering it manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
