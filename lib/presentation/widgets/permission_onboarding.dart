import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions/permission_manager.dart';
import '../providers/permission_providers.dart';

class PermissionOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const PermissionOnboardingScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  ConsumerState<PermissionOnboardingScreen> createState() => _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState extends ConsumerState<PermissionOnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<PermissionOnboardingPage> _pages = [
    PermissionOnboardingPage(
      title: 'Welcome to HabitX',
      subtitle: 'Let\'s set up your personalized productivity experience',
      description: 'HabitX works best when it can integrate with your device features. We\'ll ask for a few permissions to unlock the full potential of your productivity journey.',
      icon: Icons.rocket_launch,
      color: Colors.blue,
    ),
    PermissionOnboardingPage(
      title: 'Stay on Track',
      subtitle: 'Never miss a habit or deadline',
      description: 'Get timely reminders for your habits, tasks, and focus sessions. You have full control over what notifications you receive.',
      permission: AppPermission.notifications,
      icon: Icons.notifications_active,
      color: Colors.orange,
    ),
    PermissionOnboardingPage(
      title: 'Quick Capture',
      subtitle: 'Scan, snap, and log instantly',
      description: 'Scan barcodes for books and food, take progress photos, and visually log your meals with your camera.',
      permission: AppPermission.camera,
      icon: Icons.camera_alt,
      color: Colors.green,
    ),
    PermissionOnboardingPage(
      title: 'Health Integration',
      subtitle: 'Comprehensive wellness tracking',
      description: 'Sync with your health apps to automatically track fitness, sleep, and wellness data for complete insights.',
      permission: AppPermission.health,
      icon: Icons.favorite,
      color: Colors.red,
    ),
    PermissionOnboardingPage(
      title: 'Smart Scheduling',
      subtitle: 'Plan your habits and tasks',
      description: 'Schedule your habits and tasks directly in your calendar for better time management and organization.',
      permission: AppPermission.calendar,
      icon: Icons.calendar_today,
      color: Colors.purple,
    ),
    PermissionOnboardingPage(
      title: 'You\'re All Set!',
      subtitle: 'Ready to build better habits',
      description: 'You can always change these permissions later in Settings. Now let\'s start your productivity journey!',
      icon: Icons.check_circle,
      color: Colors.green,
      isLastPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _pages.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1} of ${_pages.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return PermissionPageWidget(
                    page: _pages[index],
                    onPermissionRequested: () {
                      // Auto-advance after permission is handled
                      if (index < _pages.length - 1) {
                        _nextPage();
                      }
                    },
                  );
                },
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentPage < _pages.length - 1)
                    ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_pages[_currentPage].permission != null ? 'Skip' : 'Next'),
                    ),
                  if (_currentPage == _pages.length - 1)
                    ElevatedButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Get Started'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    ref.read(permissionProvider.notifier).markOnboardingShown();
    widget.onComplete?.call();
  }
}

class PermissionOnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final AppPermission? permission;
  final IconData icon;
  final Color color;
  final bool isLastPage;

  PermissionOnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    this.permission,
    required this.icon,
    required this.color,
    this.isLastPage = false,
  });
}

class PermissionPageWidget extends ConsumerWidget {
  final PermissionOnboardingPage page;
  final VoidCallback? onPermissionRequested;

  const PermissionPageWidget({
    Key? key,
    required this.page,
    this.onPermissionRequested,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionProvider);
    final permissionManager = ref.read(permissionManagerProvider);
    
    final isPermissionGranted = page.permission != null
        ? permissionState.isPermissionGranted(page.permission!)
        : false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Permission Action
          if (page.permission != null) ...[
            if (isPermissionGranted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Permission granted',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final granted = await ref.read(permissionProvider.notifier)
                          .requestPermission(page.permission!);
                      
                      if (granted) {
                        onPermissionRequested?.call();
                      }
                    },
                    icon: const Icon(Icons.security),
                    label: const Text('Grant Permission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: page.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Permission details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Why we need this permission:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          permissionManager.getPermissionRationale(page.permission!),
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
          
          // Features list for this permission
          if (page.permission != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features you\'ll unlock:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: page.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...PermissionFeatureMap.getFeaturesForPermission(page.permission!)
                      .map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: page.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getFeatureDisplayName(feature),
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFeatureDisplayName(String feature) {
    final displayNames = {
      'habit_reminders': 'Habit reminders',
      'task_deadlines': 'Task deadline alerts',
      'focus_timers': 'Focus session timers',
      'meditation_sessions': 'Meditation reminders',
      'barcode_scanning': 'Barcode scanning',
      'progress_photos': 'Progress photos',
      'meal_logging': 'Visual meal logging',
      'health_app_sync': 'Health app synchronization',
      'fitness_tracking': 'Automatic fitness tracking',
      'sleep_tracking': 'Sleep pattern analysis',
      'task_scheduling': 'Calendar integration',
      'habit_planning': 'Habit scheduling',
    };
    
    return displayNames[feature] ?? feature.replaceAll('_', ' ').toLowerCase();
  }
}

// Permission Request Dialog
class PermissionRequestDialog extends ConsumerWidget {
  final AppPermission permission;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const PermissionRequestDialog({
    Key? key,
    required this.permission,
    this.customTitle,
    this.customMessage,
    this.onGranted,
    this.onDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionManager = ref.read(permissionManagerProvider);
    
    return AlertDialog(
      title: Text(customTitle ?? 'Permission Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customMessage ?? permissionManager.getPermissionDescription(permission),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              permissionManager.getPermissionRationale(permission),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDenied?.call();
          },
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final granted = await ref.read(permissionProvider.notifier)
                .requestPermission(permission);
            
            if (granted) {
              onGranted?.call();
            } else {
              onDenied?.call();
            }
          },
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context,
    AppPermission permission, {
    String? customTitle,
    String? customMessage,
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => PermissionRequestDialog(
        permission: permission,
        customTitle: customTitle,
        customMessage: customMessage,
        onGranted: onGranted,
        onDenied: onDenied,
      ),
    );
  }
}
