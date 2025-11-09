import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/page_transitions.dart';
import '../../core/animations/animation_assets.dart';
import '../dashboard/enhanced_dashboard_screen.dart';
import '../tasks/tasks_screen.dart';
import '../habits/habits_screen.dart';
import '../meditation/meditation_screen.dart';
import '../fitness/fitness_screen.dart';
import '../focus/focus_screen.dart';
import '../mental_health/mental_health_screen.dart';
import '../sleep/sleep_screen.dart';

class FullyAnimatedMainNavigation extends ConsumerStatefulWidget {
  const FullyAnimatedMainNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<FullyAnimatedMainNavigation> createState() => _FullyAnimatedMainNavigationState();
}

class _FullyAnimatedMainNavigationState extends ConsumerState<FullyAnimatedMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late AnimationController _bottomNavController;
  late List<AnimationController> _iconControllers;

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      animationAsset: AnimationAssets.dashboard,
      color: Colors.blue,
    ),
    NavigationItem(
      icon: Icons.work,
      activeIcon: Icons.work,
      label: 'Productivity',
      animationAsset: AnimationAssets.productivity,
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.health_and_safety,
      activeIcon: Icons.health_and_safety,
      label: 'Health',
      animationAsset: AnimationAssets.health,
      color: Colors.red,
    ),
    NavigationItem(
      icon: Icons.self_improvement,
      activeIcon: Icons.self_improvement,
      label: 'Wellness',
      animationAsset: AnimationAssets.meditationPose,
      color: Colors.purple,
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      animationAsset: AnimationAssets.userProfile,
      color: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bottomNavController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _iconControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _fabController.forward();
    _bottomNavController.forward();
    _iconControllers[0].forward(); // Initially active
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _bottomNavController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedLoadingOverlay(
      isLoading: false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            const EnhancedDashboardScreen().animate().fadeIn(),
            const TasksScreen().animate().slideX(begin: 0.3).fadeIn(),
            const HabitsScreen().animate().slideX(begin: 0.3).fadeIn(),
            _buildWellnessScreen().animate().slideX(begin: 0.3).fadeIn(),
            Container().animate().slideX(begin: 0.3).fadeIn(), // Profile screen
          ],
        ),
        bottomNavigationBar: _buildAnimatedBottomNav(),
        floatingActionButton: _buildAnimatedFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildAnimatedBottomNav() {
    return AnimatedBuilder(
      animation: _bottomNavController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 80 * (1 - _bottomNavController.value)),
          child: Container(
            height: 80,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navigationItems.length, (index) {
                if (index == 2) {
                  // Skip middle item for FAB
                  return const SizedBox(width: 56);
                }
                final adjustedIndex = index > 2 ? index - 1 : index;
                return _buildNavItem(adjustedIndex, index);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int adjustedIndex, int actualIndex) {
    final item = _navigationItems[adjustedIndex];
    final isActive = _currentIndex == adjustedIndex;
    
    return AnimatedBuilder(
      animation: _iconControllers[adjustedIndex],
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onItemTapped(adjustedIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? item.color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedWidget(
                  assetPath: item.animationAsset,
                  width: isActive ? 28 : 24,
                  height: isActive ? 28 : 24,
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isActive ? item.color : Colors.grey,
                    fontSize: isActive ? 12 : 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        )
        .animate(target: isActive ? 1 : 0)
        .scaleXY(begin: 1, end: 1.1, duration: 200.ms);
      },
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabController.value,
          child: Transform.rotate(
            angle: _fabController.value * 0.1,
            child: AnimatedFAB(
              onPressed: _showQuickActionsSheet,
              animationAsset: AnimationAssets.rocket,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWellnessScreen() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.mentalWellness,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              const Text('Wellness'),
            ],
          ).animate().fadeIn().slideX(begin: -0.2),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedWidget(
                      assetPath: AnimationAssets.meditationPose,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Meditation'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedWidget(
                      assetPath: AnimationAssets.workoutSession,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Fitness'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedWidget(
                      assetPath: AnimationAssets.focusMode,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Focus'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedWidget(
                      assetPath: AnimationAssets.sleepCycle,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sleep'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const MeditationScreen().animate().fadeIn().slideY(begin: 0.3),
            const FitnessScreen().animate().fadeIn().slideY(begin: 0.3),
            const FocusScreen().animate().fadeIn().slideY(begin: 0.3),
            const SleepScreen().animate().fadeIn().slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _updateIconAnimations();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _updateIconAnimations();
  }

  void _updateIconAnimations() {
    for (int i = 0; i < _iconControllers.length; i++) {
      if (i == _currentIndex) {
        _iconControllers[i].forward();
      } else {
        _iconControllers[i].reverse();
      }
    }
  }

  void _showQuickActionsSheet() {
    AnimatedBottomSheet.show(
      context: context,
      isScrollControlled: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().fadeIn().scaleX(),
            const SizedBox(height: 20),
            Row(
              children: [
                AnimatedWidget(
                  assetPath: AnimationAssets.rocket,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3),
            const SizedBox(height: 24),
            _buildQuickActionGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    final quickActions = [
      QuickAction(
        title: 'Add Task',
        icon: Icons.add_task,
        animationAsset: AnimationAssets.todoList,
        color: Colors.blue,
        onTap: () => _handleQuickAction('Add Task'),
      ),
      QuickAction(
        title: 'Log Habit',
        icon: Icons.check_circle,
        animationAsset: AnimationAssets.habitCheck,
        color: Colors.green,
        onTap: () => _handleQuickAction('Log Habit'),
      ),
      QuickAction(
        title: 'Start Meditation',
        icon: Icons.self_improvement,
        animationAsset: AnimationAssets.meditationPose,
        color: Colors.purple,
        onTap: () => _handleQuickAction('Start Meditation'),
      ),
      QuickAction(
        title: 'Quick Workout',
        icon: Icons.fitness_center,
        animationAsset: AnimationAssets.workoutSession,
        color: Colors.red,
      onTap: () => _handleQuickAction('Quick Workout'),
      ),
      QuickAction(
        title: 'Focus Session',
        icon: Icons.psychology,
        animationAsset: AnimationAssets.focusMode,
        color: Colors.orange,
        onTap: () => _handleQuickAction('Focus Session'),
      ),
      QuickAction(
        title: 'Log Mood',
        icon: Icons.sentiment_satisfied,
        animationAsset: AnimationAssets.moodTracker,
        color: Colors.pink,
        onTap: () => _handleQuickAction('Log Mood'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return AnimatedButton(
          onPressed: action.onTap,
          backgroundColor: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedWidget(
                assetPath: action.animationAsset,
                width: 32,
                height: 32,
              ),
              const SizedBox(height: 8),
              Text(
                action.title,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
         .fadeIn()
         .scale(begin: const Offset(0.8, 0.8))
         .slideY(begin: 0.3);
      },
    );
  }

  void _handleQuickAction(String action) {
    Navigator.pop(context);
    AnimatedSnackbar.showSuccess(
      context: context,
      message: '$action started!',
    );
    
    // Handle specific actions
    switch (action) {
      case 'Add Task':
        context.fadeToPage(const TasksScreen());
        break;
      case 'Log Habit':
        context.slideToPage(const HabitsScreen());
        break;
      case 'Start Meditation':
        context.scaleToPage(const MeditationScreen());
        break;
      case 'Quick Workout':
        context.slideToPage(const FitnessScreen());
        break;
      case 'Focus Session':
        context.fadeToPage(const FocusScreen());
        break;
      case 'Log Mood':
        context.slideToPage(const MentalHealthScreen());
        break;
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String animationAsset;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.animationAsset,
    required this.color,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final String animationAsset;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.animationAsset,
    required this.color,
    required this.onTap,
  });
}
