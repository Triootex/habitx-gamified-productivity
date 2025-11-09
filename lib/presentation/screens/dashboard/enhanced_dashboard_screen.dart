import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';
import '../../providers/user_providers.dart';
import '../../providers/permission_providers.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/hybrid_animated_widgets.dart';
import '../../../core/animations/animation_assets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../widgets/page_transitions.dart';

class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends ConsumerState<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late AnimationController _headerController;
  bool _showFab = true;
  bool _isScrollingUp = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
    _headerController.forward();
    _fabController.forward();
  }

  void _onScroll() {
    final currentScroll = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (currentScroll <= 0) {
      if (!_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      }
    } else if (currentScroll >= maxScroll) {
      if (_showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    } else {
      if (_scrollController.position.userScrollDirection.name == 'forward') {
        if (!_isScrollingUp) {
          setState(() => _isScrollingUp = true);
          _fabController.forward();
        }
      } else {
        if (_isScrollingUp) {
          setState(() => _isScrollingUp = false);
          _fabController.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final permissionsGranted = ref.watch(allPermissionsGrantedProvider);

    return AnimatedLoadingOverlay(
      isLoading: user == null,
      loadingText: 'Loading your dashboard...',
      loadingWidget: AnimatedWidget(
        assetPath: AnimationAssets.loadingSpinner,
        width: 50,
        height: 50,
      ),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAnimatedAppBar(user),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildPermissionBanner(permissionsGranted),
                    _buildWelcomeSection(user),
                    _buildMascotSection(),
                    _buildStatsOverview(),
                    _buildQuickActions(),
                    _buildTodaysProgress(),
                    _buildRecentActivity(),
                    _buildInsightsCard(),
                    const SizedBox(height: 100), // FAB spacing
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _fabController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabController.value,
              child: HybridAnimatedFAB(
                onPressed: _showQuickActions,
                riveAssetPath: RiveAnimationAssets.downloadButton,
                lottieAssetPath: AnimationAssets.rocket,
                backgroundColor: Colors.blue,
                animateOnPress: true,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMascotSection() {
    return AnimatedCard(
      delay: 200.ms,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ComprehensiveMascotWidget(
              category: 'productivity',
              emotion: 'happy',
              size: 80,
            ),
            const SizedBox(height: 12),
            Text(
              'Hi! I\'m your productivity companion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMascotAction('Working', 'working', Icons.work),
                _buildMascotAction('Celebrating', 'celebrating', Icons.celebration),
                _buildMascotAction('Meditating', 'meditating', Icons.self_improvement),
                _buildMascotAction('Exercising', 'exercising', Icons.fitness_center),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotAction(String label, String emotion, IconData icon) {
    return GestureDetector(
      onTap: () => ComprehensiveAudioManager.playSound('productivity', 'complete'),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ComprehensiveMascotWidget(
              category: 'productivity',
              emotion: emotion,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
          ),
        ],
      ),
    ).animate().scale().bounce();
  }

  Widget _buildAnimatedAppBar(dynamic user) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Good ${_getTimeOfDay()}, ${user?.displayName?.split(' ').first ?? 'User'}!',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage(WebAssetConstants.ImagesAssets.dashboardhero),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 20,
                child: AnimatedWidget(
                  assetPath: _getTimeOfDayAnimation(),
                  width: 60,
                  height: 60,
                ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
              ),
            ],
          ),
        ),
      ),
      actions: [
        AnimatedBadge(
          badgeText: '3',
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: _showNotifications,
          ),
        ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
        AnimatedAvatar(
          imageUrl: user?.avatarUrl,
          initials: user?.displayName?.substring(0, 2).toUpperCase(),
          radius: 18,
          delay: 700.ms,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildPermissionBanner(bool permissionsGranted) {
    if (permissionsGranted) return const SizedBox.shrink();

    return AnimatedContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.warningAlert,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Permissions Required',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Grant permissions to unlock all features',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          AnimatedButton(
            onPressed: _requestPermissions,
            animationAsset: AnimationAssets.buttonPress,
            child: const Text('Grant', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orange,
          ),
        ],
      ),
      delay: 800.ms,
    );
  }

  Widget _buildWelcomeSection(dynamic user) {
    return AnimatedCard(
      delay: 900.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.celebration,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
                    Text(
                      'You\'re doing great! Keep up the momentum.',
                      style: TextStyle(color: Colors.grey[600]),
                    ).animate().fadeIn(delay: 1100.ms).slideX(begin: -0.2),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return AnimatedCard(
      delay: 1000.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 1100.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tasks',
                  '8/12',
                  0.67,
                  AnimationAssets.taskComplete,
                  Colors.blue,
                  1200.ms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Habits',
                  '5/7',
                  0.71,
                  AnimationAssets.habitCheck,
                  Colors.green,
                  1300.ms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Focus',
                  '2h 30m',
                  0.83,
                  AnimationAssets.focusMode,
                  Colors.purple,
                  1400.ms,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, double progress, 
      String animationAsset, Color color, Duration delay) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      delay: delay,
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: animationAsset,
            width: 30,
            height: 30,
          ).animate(delay: delay + 200.ms).scale().fadeIn(),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ).animate(delay: delay + 300.ms).fadeIn().slideY(begin: 0.3),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ).animate(delay: delay + 400.ms).fadeIn(),
          const SizedBox(height: 8),
          AnimatedProgressBar(
            progress: progress,
            progressColor: color,
            delay: delay + 500.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Add Task', 'icon': Icons.add_task, 'animation': AnimationAssets.todoList, 'color': Colors.blue},
      {'title': 'Log Habit', 'icon': Icons.check_circle, 'animation': AnimationAssets.habitCheck, 'color': Colors.green},
      {'title': 'Meditate', 'icon': Icons.self_improvement, 'animation': AnimationAssets.meditationPose, 'color': Colors.purple},
      {'title': 'Workout', 'icon': Icons.fitness_center, 'animation': AnimationAssets.workoutSession, 'color': Colors.red},
    ];

    return AnimatedCard(
      delay: 1500.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 1600.ms),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return AnimatedButton(
                onPressed: () => _handleQuickAction(index),
                backgroundColor: (action['color'] as Color).withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedWidget(
                      assetPath: action['animation'] as String,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: TextStyle(
                        color: action['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 1700 + (index * 100)))
               .fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysProgress() {
    return AnimatedCard(
      delay: 2100.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.progressChart,
                width: 24,
                height: 24,
              ).animate().fadeIn(delay: 2200.ms).scale(),
              const SizedBox(width: 12),
              Text(
                'Today\'s Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 2200.ms),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Completion'),
                    const SizedBox(height: 8),
                    AnimatedProgressBar(
                      progress: 0.75,
                      delay: 2300.ms,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '75% Complete',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ).animate().fadeIn(delay: 2800.ms),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              AnimatedWidget(
                assetPath: AnimationAssets.trendingUp,
                width: 60,
                height: 60,
              ).animate().fadeIn(delay: 2400.ms).scale(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'Completed morning workout', 'time': '2 hours ago', 'icon': AnimationAssets.workoutSession},
      {'title': 'Finished meditation session', 'time': '4 hours ago', 'icon': AnimationAssets.meditationPose},
      {'title': 'Logged healthy breakfast', 'time': '6 hours ago', 'icon': AnimationAssets.nutritionApple},
      {'title': 'Completed daily reading', 'time': '1 day ago', 'icon': AnimationAssets.bookReading},
    ];

    return AnimatedCard(
      delay: 2500.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 2600.ms),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return AnimatedListTile(
                leading: AnimatedWidget(
                  assetPath: activity['icon'] as String,
                  width: 24,
                  height: 24,
                ),
                title: Text(activity['title'] as String),
                subtitle: Text(activity['time'] as String),
                delay: Duration(milliseconds: 2700 + (index * 100)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return AnimatedCard(
      delay: 3100.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.insightsGeneration,
                width: 24,
                height: 24,
              ).animate().fadeIn(delay: 3200.ms).rotate(),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 3200.ms),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '🎯 You\'re most productive in the mornings! Try scheduling important tasks between 8-11 AM.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 3300.ms).slideX(begin: -0.2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        onPressed: _viewDetailedInsights,
                        child: const Text('View Details'),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedButton(
                      onPressed: _dismissInsight,
                      child: const Icon(Icons.close, size: 16),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                    ),
                  ],
                ).animate().fadeIn(delay: 3400.ms).slideY(begin: 0.3),
              ],
            ),
          ).animate().fadeIn(delay: 3300.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getTimeOfDayAnimation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AnimationAssets.sunrise;
    if (hour < 17) return AnimationAssets.sunshine;
    return AnimationAssets.moonStars;
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Refresh data
  }

  void _showQuickActions() {
    AnimatedBottomSheet.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Quick action buttons here
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    context.fadeToPage(Container()); // Notification screen
  }

  void _requestPermissions() {
    // Request permissions
  }

  void _handleQuickAction(int index) {
    // Handle quick action
    AnimatedSnackbar.showSuccess(
      context: context,
      message: 'Quick action ${index + 1} triggered!',
    );
  }

  void _viewDetailedInsights() {
    context.slideToPage(Container()); // Insights screen
  }

  void _dismissInsight() {
    AnimatedSnackbar.showInfo(
      context: context,
      message: 'Insight dismissed',
    );
  }
}
