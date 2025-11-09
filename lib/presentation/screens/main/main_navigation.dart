import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../profile/profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      animationAsset: AnimationAssets.dataAnalytics,
    ),
    NavigationItem(
      icon: Icons.task_alt,
      activeIcon: Icons.task_alt,
      label: 'Tasks',
      animationAsset: AnimationAssets.todoList,
    ),
    NavigationItem(
      icon: Icons.check_circle,
      activeIcon: Icons.check_circle,
      label: 'Habits',
      animationAsset: AnimationAssets.habitCheck,
    ),
    NavigationItem(
      icon: Icons.self_improvement,
      activeIcon: Icons.self_improvement,
      label: 'Wellness',
      animationAsset: AnimationAssets.meditationPose,
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      animationAsset: AnimationAssets.trophy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          const DashboardScreen(),
          const TasksScreen(),
          const HabitsScreen(),
          const WellnessScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _navigationItems.length; i++)
                if (i == 2)
                  const SizedBox(width: 56) // Space for FAB
                else
                  _buildNavItem(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? CategoryIconAnimation(
                      category: item.label.toLowerCase(),
                      size: 24,
                      isSelected: true,
                    )
                  : Icon(
                      item.icon,
                      color: Colors.grey[600],
                      size: 24,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionAnimationButton(
      animationAsset: AnimationAssets.habitCheck,
      onPressed: () => _showQuickActionsSheet(),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionsBottomSheet(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String animationAsset;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.animationAsset,
  });
}

class WellnessScreen extends ConsumerWidget {
  const WellnessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wellness'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Fitness'),
              Tab(icon: Icon(Icons.psychology), text: 'Mental Health'),
              Tab(icon: Icon(Icons.bedtime), text: 'Sleep'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MeditationScreen(),
            FitnessScreen(),
            MentalHealthScreen(),
            SleepScreen(),
          ],
        ),
      ),
    );
  }
}

class QuickActionsBottomSheet extends ConsumerWidget {
  const QuickActionsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActions = ref.watch(quickActionsProvider);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: quickActions.length,
                    itemBuilder: (context, index) {
                      final action = quickActions[index];
                      return _buildQuickActionItem(context, action);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, Map<String, dynamic> action) {
    final color = Color(int.parse(action['color']));
    
    return MicroInteractionButton(
      onPressed: () {
        Navigator.of(context).pop();
        _handleQuickAction(context, action['action']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIconAnimation(
              category: action['action'],
              size: 40,
              isSelected: false,
            ),
            const SizedBox(height: 8),
            Text(
              action['title'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, String action) {
    switch (action) {
      case 'add_task':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TaskCreationScreen()),
        );
        break;
      case 'log_habit':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HabitLogScreen()),
        );
        break;
      case 'start_focus':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FocusScreen()),
        );
        break;
      case 'start_meditation':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MeditationScreen()),
        );
        break;
      case 'track_sleep':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SleepScreen()),
        );
        break;
      case 'add_expense':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetScreen()),
        );
        break;
    }
  }
}

// Placeholder screens - will be implemented separately
class TaskCreationScreen extends StatelessWidget {
  const TaskCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: const Center(child: Text('Task Creation Screen')),
    );
  }
}

class HabitLogScreen extends StatelessWidget {
  const HabitLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Habit')),
      body: const Center(child: Text('Habit Log Screen')),
    );
  }
}

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: const Center(child: Text('Budget Screen')),
    );
  }
}
