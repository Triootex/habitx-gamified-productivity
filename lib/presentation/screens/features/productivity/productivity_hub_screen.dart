import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/rive_animated_widgets.dart';
import '../../widgets/comprehensive_asset_widgets.dart';
import '../../../core/animations/animation_assets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../../core/constants/web_asset_constants.dart';

class ProductivityHubScreen extends ConsumerStatefulWidget {
  const ProductivityHubScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductivityHubScreen> createState() => _ProductivityHubScreenState();
}

class _ProductivityHubScreenState extends ConsumerState<ProductivityHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late ScrollController _scrollController;

  final List<ProductivityFeature> _features = [
    ProductivityFeature(
      title: 'Task Management',
      subtitle: 'Create, organize, and complete tasks',
      animation: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.blue,
      progress: 0.75,
      tasks: 12,
      completed: 9,
    ),
    ProductivityFeature(
      title: 'Time Tracking',
      subtitle: 'Track time spent on activities',
      animation: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.orange,
      progress: 0.60,
      tasks: 8,
      completed: 5,
    ),
    ProductivityFeature(
      title: 'Pomodoro Timer',
      subtitle: '25-minute focused work sessions',
      animation: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.red,
      progress: 0.90,
      tasks: 6,
      completed: 5,
    ),
    ProductivityFeature(
      title: 'Project Planning',
      subtitle: 'Plan and manage projects',
      animation: AnimationAssets.rocket, // Real MCP Animation
      color: Colors.purple,
      progress: 0.45,
      tasks: 15,
      completed: 7,
    ),
    ProductivityFeature(
      title: 'Goal Setting',
      subtitle: 'Set and achieve your goals',
      animation: AnimationAssets.successCelebration, // Real MCP Animation
      color: Colors.green,
      progress: 0.80,
      tasks: 10,
      completed: 8,
    ),
    ProductivityFeature(
      title: 'Progress Analytics',
      subtitle: 'Visualize your progress',
      animation: AnimationAssets.loadingSpinner, // Real MCP Animation
      color: Colors.indigo,
      progress: 0.85,
      tasks: 20,
      completed: 17,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scrollController = ScrollController();
    
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsOverview(),
                _buildQuickActions(),
                _buildFeaturesGrid(),
                _buildProgressSection(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: _showNewTaskDialog,
        animationAsset: AnimationAssets.rocket, // Real MCP Animation
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            // Rive Animation for Productivity
            SizedBox(
              width: 30,
              height: 30,
              child: RiveAnimatedWidget(
                assetPath: RiveAnimationAssets.taskComplete, // Real Rive Animation
                autoplay: true,
                loop: true,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Productivity Hub'),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade400,
              ],
            ),
            image: DecorationImage(
              image: AssetImage(WebAssetConstants.ImagesAssets.productivitybg),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                right: 20,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: RiveAnimatedWidget(
                    assetPath: RiveAnimationAssets.goalProgress, // Real Rive Animation
                    autoplay: true,
                    loop: true,
                  ),
                ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
              ),
              Positioned(
                top: 120,
                left: 30,
                child: ComprehensiveMascotWidget(
                  category: 'productivity',
                  emotion: 'working',
                  size: 60,
                ).animate().fadeIn(delay: 700.ms).rotate(delay: 700.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalTasks = _features.fold(0, (sum, feature) => sum + feature.tasks);
    final completedTasks = _features.fold(0, (sum, feature) => sum + feature.completed);
    final completionRate = (completedTasks / totalTasks * 100).round();

    return AnimatedCard(
      delay: 300.ms,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Tasks',
                totalTasks.toString(),
                AnimationAssets.workingHours, // Real MCP Animation
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Completed',
                completedTasks.toString(),
                AnimationAssets.successCelebration, // Real MCP Animation
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Success Rate',
                '$completionRate%',
                AnimationAssets.loadingSpinner, // Real MCP Animation
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String animation, Color color) {
    return Column(
      children: [
        // Use Rive Animation for stats
        SizedBox(
          width: 40,
          height: 40,
          child: RiveAnimatedWidget(
            assetPath: RiveAnimationAssets.progressBar, // Real Rive Animation
            autoplay: true,
            loop: true,
          ),
        ).animate().scale().bounce(),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildQuickActions() {
    return AnimatedCard(
      delay: 400.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HybridAnimatedButton(
                  onPressed: _startPomodoro,
                  riveAssetPath: RiveAnimationAssets.timerCountdown, // Real Rive Animation
                  lottieAssetPath: AnimationAssets.workingHours,      // Lottie Fallback
                  backgroundColor: Colors.red.shade500,
                  showAnimationOnHover: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HybridAnimatedWidget(
                        riveAssetPath: RiveAnimationAssets.timerCountdown, // Real Rive Animation
                        lottieAssetPath: AnimationAssets.workingHours,      // Lottie Fallback
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('Start Pomodoro', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HybridAnimatedButton(
                  onPressed: _createProject,
                  riveAssetPath: RiveAnimationAssets.taskComplete, // Real Rive Animation
                  lottieAssetPath: AnimationAssets.rocket,          // Lottie Fallback
                  backgroundColor: Colors.purple.shade500,
                  showAnimationOnHover: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HybridAnimatedWidget(
                        riveAssetPath: RiveAnimationAssets.taskComplete, // Real Rive Animation
                        lottieAssetPath: AnimationAssets.rocket,          // Lottie Fallback
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('New Project', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityFeatures() {
    return AnimatedCard(
      delay: 600.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                WebAssetConstants.IconsAssets.taskicon,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.work, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Text(
                'Productivity Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Feature Grid using comprehensive asset widgets
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'task_management',
                title: 'Task Management',
                description: 'Organize and track your daily tasks',
                onTap: _openTaskManagement,
                isActive: true,
              ),
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'time_tracking',
                title: 'Time Tracking',
                description: 'Monitor your productive hours',
                onTap: _openTimeTracking,
              ),
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'goal_setting',
                title: 'Goal Setting',
                description: 'Define and achieve your objectives',
                onTap: _openGoalSetting,
              ),
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'project_management',
                title: 'Project Management',
                description: 'Manage complex projects efficiently',
                onTap: _openProjectManagement,
              ),
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'analytics',
                title: 'Analytics & Reports',
                description: 'Visualize your productivity data',
                onTap: _openAnalytics,
              ),
              ComprehensiveFeatureCard(
                category: 'productivity',
                feature: 'pomodoro',
                title: 'Pomodoro Timer',
                description: 'Focus with time-boxed sessions',
                onTap: _openPomodoro,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, String animation, Color color, VoidCallback onTap) {
    return ComprehensiveAssetWidget(
      category: 'productivity',
      feature: title.toLowerCase().replaceAll(' ', '_'),
      playSound: true,
      showIcon: true,
      showBackground: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HybridAnimatedWidget(
              riveAssetPath: RiveAnimationAssets.taskComplete,
              lottieAssetPath: animation,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).animate(delay: delay + 400.ms).fadeIn(),
                      const Spacer(),
                      LinearProgressIndicator(
                        progress: feature.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(feature.color),
                      ).animate(delay: delay + 500.ms).scaleX(),
                      const SizedBox(height: 8),
                      Text(
                        '${(feature.progress * 100).round()}% Complete',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: feature.color,
                        ),
                      ).animate(delay: delay + 600.ms).fadeIn(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return AnimatedCard(
      delay: 800.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.loadingSpinner, // Real MCP Animation
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Progress Chart\n(Chart visualization here)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFeature(ProductivityFeature feature) {
    AnimatedSnackbar.showInfo(
      context: context,
      message: 'Opening ${feature.title}...',
    );
  }

  void _showNewTaskDialog() {
    AnimatedDialog.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.rocket, // Real MCP Animation
              width: 60,
              height: 60,
            ).animate().scale().bounce(),
            const SizedBox(height: 20),
            Text(
              'Create New Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter task title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      AnimatedSnackbar.showSuccess(
                        context: context,
                        message: 'Task created successfully!',
                      );
                    },
                    child: const Text('Create', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startPomodoro() {
    AnimatedSnackbar.showInfo(
      context: context,
      message: '🍅 Pomodoro timer started! Focus for 25 minutes.',
    );
  }

  void _createProject() {
    AnimatedSnackbar.showInfo(
      context: context,
      message: '🚀 New project creation started!',
    );
  }
}

class ProductivityFeature {
  final String title;
  final String subtitle;
  final String animation;
  final Color color;
  final double progress;
  final int tasks;
  final int completed;

  ProductivityFeature({
    required this.title,
    required this.subtitle,
    required this.animation,
    required this.color,
    required this.progress,
    required this.tasks,
    required this.completed,
  });
}
