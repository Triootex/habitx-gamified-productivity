import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/rive_animated_widgets.dart';
import '../../widgets/comprehensive_asset_widgets.dart';
import '../../../core/animations/animation_assets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../../core/constants/web_asset_constants.dart';

class HealthWellnessScreen extends ConsumerStatefulWidget {
  const HealthWellnessScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthWellnessScreen> createState() => _HealthWellnessScreenState();
}

class _HealthWellnessScreenState extends ConsumerState<HealthWellnessScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late List<AnimationController> _featureControllers;

  final List<HealthFeature> _features = [
    HealthFeature(
      title: 'Habit Tracking',
      subtitle: 'Build positive habits daily',
      animation: AnimationAssets.successCelebration, // Real MCP Animation
      color: Colors.green,
      currentStreak: 15,
      targetDays: 30,
      todayCompleted: true,
    ),
    HealthFeature(
      title: 'Meditation',
      subtitle: 'Mindfulness and relaxation',
      animation: AnimationAssets.meditation, // Real MCP Animation
      color: Colors.purple,
      currentStreak: 7,
      targetDays: 21,
      todayCompleted: false,
    ),
    HealthFeature(
      title: 'Fitness Tracking',
      subtitle: 'Track workouts and activities',
      animation: AnimationAssets.healthyHabits, // Real MCP Animation
      color: Colors.red,
      currentStreak: 12,
      targetDays: 30,
      todayCompleted: true,
    ),
    HealthFeature(
      title: 'Sleep Monitoring',
      subtitle: 'Monitor sleep patterns',
      animation: AnimationAssets.relaxingHabits, // Real MCP Animation
      color: Colors.indigo,
      currentStreak: 5,
      targetDays: 14,
      todayCompleted: false,
    ),
    HealthFeature(
      title: 'Nutrition Logging',
      subtitle: 'Track meals and nutrition',
      animation: AnimationAssets.healthyHabits, // Real MCP Animation
      color: Colors.orange,
      currentStreak: 8,
      targetDays: 30,
      todayCompleted: true,
    ),
    HealthFeature(
      title: 'Water Intake',
      subtitle: 'Stay hydrated throughout the day',
      animation: AnimationAssets.loadingSpinner, // Real MCP Animation
      color: Colors.blue,
      currentStreak: 20,
      targetDays: 30,
      todayCompleted: true,
    ),
    HealthFeature(
      title: 'Heart Rate',
      subtitle: 'Monitor heart health',
      animation: AnimationAssets.loadingSpinner, // Real MCP Animation
      color: Colors.pink,
      currentStreak: 3,
      targetDays: 7,
      todayCompleted: false,
    ),
    HealthFeature(
      title: 'Mood Tracking',
      subtitle: 'Track emotional wellness',
      animation: AnimationAssets.meditation, // Real MCP Animation
      color: Colors.teal,
      currentStreak: 10,
      targetDays: 21,
      todayCompleted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _featureControllers = _features.map((feature) => 
      AnimationController(duration: const Duration(milliseconds: 800), vsync: this)
    ).toList();
    
    _startFeatureAnimations();
  }

  void _startFeatureAnimations() {
    for (int i = 0; i < _featureControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _featureControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
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
                _buildHealthOverview(),
                _buildTodayProgress(),
                _buildFeaturesGrid(),
                _buildWeeklyInsights(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: _showHealthLogger,
        animationAsset: AnimationAssets.healthyHabits, // Real MCP Animation
        backgroundColor: Colors.green,
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
            // Rive Animation for Health
            SizedBox(
              width: 30,
              height: 30,
              child: RiveAnimatedWidget(
                assetPath: RiveAnimationAssets.mascotFlying, // Real Rive Animation
                autoplay: true,
                loop: true,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Health & Wellness'),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade600,
                Colors.green.shade400,
              ],
            ),
            image: DecorationImage(
              image: AssetImage(WebAssetConstants.ImagesAssets.healthbg),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                right: 20,
                child: AnimatedWidget(
                  assetPath: AnimationAssets.meditation, // Real MCP Animation
                  width: 80,
                  height: 80,
                ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
              ),
              Positioned(
                top: 120,
                left: 30,
                child: AnimatedWidget(
                  assetPath: AnimationAssets.successCelebration, // Real MCP Animation
                  width: 60,
                  height: 60,
                ).animate().fadeIn(delay: 700.ms).rotate(delay: 700.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    final completedToday = _features.where((f) => f.todayCompleted).length;
    final totalFeatures = _features.length;
    final averageStreak = (_features.fold(0, (sum, f) => sum + f.currentStreak) / totalFeatures).round();

    return AnimatedCard(
      delay: 300.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.healthyHabits, // Real MCP Animation
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Health Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildHealthStat(
                  'Completed Today',
                  '$completedToday/$totalFeatures',
                  AnimationAssets.successCelebration, // Real MCP Animation
                  Colors.green,
                  completedToday / totalFeatures,
                ),
              ),
              Expanded(
                child: _buildHealthStat(
                  'Average Streak',
                  '$averageStreak days',
                  AnimationAssets.rocket, // Real MCP Animation
                  Colors.orange,
                  averageStreak / 30,
                ),
              ),
              Expanded(
                child: _buildHealthStat(
                  'Wellness Score',
                  '85%',
                  AnimationAssets.meditation, // Real MCP Animation
                  Colors.purple,
                  0.85,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, String animation, Color color, double progress) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                progress: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 4,
              ),
            ),
            AnimatedWidget(
              assetPath: animation,
              width: 30,
              height: 30,
            ).animate().scale().bounce(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildTodayProgress() {
    return AnimatedCard(
      delay: 400.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_features.length, (index) {
            final feature = _features[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  AnimatedWidget(
                    assetPath: feature.animation,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: feature.todayCompleted ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feature.todayCompleted ? 'Done' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: feature.todayCompleted ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 500 + (index * 50))).fadeIn().slideX(begin: -0.3);
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              
              return AnimatedBuilder(
                animation: _featureControllers[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _featureControllers[index].value,
                    child: Opacity(
                      opacity: _featureControllers[index].value,
                      child: AnimatedCard(
                        onTap: () => _openHealthFeature(feature),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AnimatedWidget(
                                    assetPath: feature.animation,
                                    width: 32,
                                    height: 32,
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: feature.todayCompleted ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                feature.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feature.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: feature.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${feature.currentStreak} day streak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: feature.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                progress: feature.currentStreak / feature.targetDays,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(feature.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsights() {
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
                'Weekly Health Insights',
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Health Insights Chart\n(Health analytics visualization here)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHealthFeature(HealthFeature feature) {
    AnimatedSnackbar.showInfo(
      context: context,
      message: 'Opening ${feature.title}...',
    );
  }

  void _showHealthLogger() {
    AnimatedDialog.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.healthyHabits, // Real MCP Animation
              width: 60,
              height: 60,
            ).animate().scale().bounce(),
            const SizedBox(height: 20),
            Text(
              'Log Health Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select an activity to log:'),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              final activities = ['Water Intake', 'Exercise', 'Meditation'];
              final animations = [AnimationAssets.loadingSpinner, AnimationAssets.healthyHabits, AnimationAssets.meditation];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: AnimatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AnimatedSnackbar.showSuccess(
                      context: context,
                      message: '${activities[index]} logged successfully!',
                    );
                  },
                  backgroundColor: Colors.green.shade50,
                  child: Row(
                    children: [
                      AnimatedWidget(
                        assetPath: animations[index],
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activities[index],
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class HealthFeature {
  final String title;
  final String subtitle;
  final String animation;
  final Color color;
  final int currentStreak;
  final int targetDays;
  final bool todayCompleted;

  HealthFeature({
    required this.title,
    required this.subtitle,
    required this.animation,
    required this.color,
    required this.currentStreak,
    required this.targetDays,
    required this.todayCompleted,
  });
}
