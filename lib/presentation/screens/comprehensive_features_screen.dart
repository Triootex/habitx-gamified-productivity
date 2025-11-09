import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/universal_animated_widgets.dart';
import '../widgets/hybrid_animated_widgets.dart';
import '../widgets/comprehensive_asset_widgets.dart';
import '../../../core/animations/animation_assets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../../core/constants/web_asset_constants.dart';

class ComprehensiveFeaturesScreen extends ConsumerStatefulWidget {
  const ComprehensiveFeaturesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ComprehensiveFeaturesScreen> createState() => _ComprehensiveFeaturesScreenState();
}

class _ComprehensiveFeaturesScreenState extends ConsumerState<ComprehensiveFeaturesScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late List<AnimationController> _categoryControllers;

  final List<FeatureCategory> _categories = [
    FeatureCategory(
      title: 'Productivity & Tasks',
      icon: Icons.work,
      animation: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.blue,
      features: [
        Feature('Task Management', AnimationAssets.workingHours, 'Create, organize, and complete tasks', 
                icon: WebAssetConstants.IconsAssets.taskicon, category: 'productivity', featureId: 'task_management'),
        Feature('Time Tracking', AnimationAssets.workingHours, 'Track time spent on activities',
                icon: WebAssetConstants.IconsAssets.timericon, category: 'productivity', featureId: 'time_tracking'),
        Feature('Pomodoro Timer', AnimationAssets.workingHours, '25-minute focused work sessions',
                icon: WebAssetConstants.IconsAssets.pomodoroicon, category: 'productivity', featureId: 'pomodoro'),
        Feature('Project Planning', AnimationAssets.rocket, 'Plan and manage projects',
                icon: WebAssetConstants.IconsAssets.projecticon, category: 'productivity', featureId: 'project_management'),
        Feature('Goal Setting', AnimationAssets.successCelebration, 'Set and achieve your goals',
                icon: WebAssetConstants.IconsAssets.goalicon, category: 'productivity', featureId: 'goal_setting'),
        Feature('Progress Analytics', AnimationAssets.loadingSpinner, 'Visualize your progress',
                icon: WebAssetConstants.IconsAssets.analyticsicon, category: 'productivity', featureId: 'analytics'),
      ],
    ),
    FeatureCategory(
      title: 'Health & Wellness',
      icon: Icons.health_and_safety,
      animation: AnimationAssets.healthyHabits, // Real MCP Animation
      color: Colors.green,
      features: [
        Feature('Habit Tracking', AnimationAssets.successCelebration, 'Build positive habits daily',
                icon: WebAssetConstants.IconsAssets.hearticon, category: 'health', featureId: 'habit_tracking'),
        Feature('Meditation', AnimationAssets.meditation, 'Mindfulness and relaxation',
                icon: WebAssetConstants.IconsAssets.meditationicon, category: 'health', featureId: 'meditation'),
        Feature('Fitness Tracking', AnimationAssets.healthyHabits, 'Track workouts and activities',
                icon: WebAssetConstants.IconsAssets.fitnessicon, category: 'health', featureId: 'fitness'),
        Feature('Sleep Monitoring', AnimationAssets.relaxingHabits, 'Monitor sleep patterns',
                icon: WebAssetConstants.IconsAssets.sleepicon, category: 'health', featureId: 'sleep_tracking'),
        Feature('Nutrition Logging', AnimationAssets.healthyHabits, 'Track meals and nutrition',
                icon: WebAssetConstants.IconsAssets.nutritionicon, category: 'health', featureId: 'nutrition'),
        Feature('Water Intake', AnimationAssets.loadingSpinner, 'Stay hydrated throughout the day',
                icon: WebAssetConstants.IconsAssets.watericon, category: 'health', featureId: 'water_intake'),
        Feature('Heart Rate', AnimationAssets.loadingSpinner, 'Monitor heart health',
                icon: WebAssetConstants.IconsAssets.hearticon, category: 'health', featureId: 'heart_rate'),
        Feature('Exercise Planner', AnimationAssets.healthyHabits, 'Plan workout routines',
                icon: WebAssetConstants.IconsAssets.exerciseicon, category: 'health', featureId: 'exercise'),
      ],
    ),
    FeatureCategory(
      title: 'Mental Wellness',
      icon: Icons.psychology,
      animation: AnimationAssets.mentalWellness,
      color: Colors.purple,
      features: [
        Feature('Relaxation', AnimationAssets.relaxingHabits, 'Find calm and peace'),
        Feature('Breathing Exercises', AnimationAssets.meditation, 'Guided breathing sessions'),
        Feature('Stress Management', AnimationAssets.relaxingHabits, 'Manage daily stress'),
        Feature('Focus Training', AnimationAssets.meditation, 'Improve concentration'),
        Feature('Mindfulness', AnimationAssets.relaxingHabits, 'Present moment awareness'),
        Feature('Gratitude Journal', AnimationAssets.relaxingHabits, 'Daily gratitude practice'),
      ],
    ),
    FeatureCategory(
      title: 'Social & Community',
      icon: Icons.people,
      animation: AnimationAssets.successCelebration, // Real MCP Animation
      color: Colors.orange,
      features: [
        Feature('Friend Challenges', AnimationAssets.rocket, 'Compete with friends'),
        Feature('Community Groups', AnimationAssets.successCelebration, 'Join like-minded groups'),
        Feature('Achievements', AnimationAssets.successCelebration, 'Celebrate milestones'),
        Feature('Leaderboards', AnimationAssets.rocket, 'See top performers'),
        Feature('Social Sharing', AnimationAssets.rocket, 'Share your progress'),
        Feature('Motivational Quotes', AnimationAssets.successCelebration, 'Daily inspiration'),
      ],
    ),
    FeatureCategory(
      title: 'Learning & Growth',
      icon: Icons.school,
      animation: AnimationAssets.meditation, // Real MCP Animation (reading/studying)
      color: Colors.indigo,
      features: [
        Feature('Skill Development', AnimationAssets.successCelebration, 'Learn new skills'),
        Feature('Reading Tracker', AnimationAssets.meditation, 'Track reading progress'),
        Feature('Course Management', AnimationAssets.rocket, 'Manage learning courses'),
        Feature('Knowledge Base', AnimationAssets.workingHours, 'Store important information'),
        Feature('Creative Projects', AnimationAssets.rocket, 'Boost creativity'),
        Feature('Language Learning', AnimationAssets.meditation, 'Learn new languages'),
      ],
    ),
    FeatureCategory(
      title: 'Life Management',
      icon: Icons.home,
      animation: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.teal,
      features: [
        Feature('Calendar Integration', AnimationAssets.workingHours, 'Sync with calendars'),
        Feature('Reminder System', AnimationAssets.successCelebration, 'Never forget important tasks'),
        Feature('Note Taking', AnimationAssets.meditation, 'Capture thoughts and ideas'),
        Feature('File Organization', AnimationAssets.rocket, 'Organize documents'),
        Feature('Contact Management', AnimationAssets.successCelebration, 'Manage relationships'),
        Feature('Travel Planning', AnimationAssets.rocket, 'Plan trips and adventures'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _categoryControllers = _categories.map((category) => 
      AnimationController(duration: const Duration(milliseconds: 500), vsync: this)
    ).toList();
    
    _startCategoryAnimations();
  }

  void _startCategoryAnimations() {
    for (int i = 0; i < _categoryControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _categoryControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _categoryControllers) {
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
                _buildHeaderSection(),
                ..._buildCategorySections(),
                _buildFooterSection(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: _showQuickFeatures,
        animationAsset: AnimationAssets.rocket,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.explore, color: Colors.white),
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
            AnimatedWidget(
              assetPath: AnimationAssets.rocket,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('HabitX Features'),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                right: 20,
                child: AnimatedWidget(
                  assetPath: AnimationAssets.celebration,
                  width: 80,
                  height: 80,
                ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
              ),
              Positioned(
                top: 120,
                left: 30,
                child: AnimatedWidget(
                  assetPath: AnimationAssets.trendingUp,
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

  Widget _buildHeaderSection() {
    return AnimatedCard(
      delay: 800.ms,
      child: Column(
        children: [
          Text(
            'Comprehensive Life Enhancement',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
          const SizedBox(height: 16),
          Text(
            'Transform every aspect of your life with our integrated feature ecosystem',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
          const SizedBox(height: 24),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Features', 'value': '50+', 'animation': AnimationAssets.dashboard},
      {'label': 'Categories', 'value': '6', 'animation': AnimationAssets.categoryIcon},
      {'label': 'Animations', 'value': '100+', 'animation': AnimationAssets.magicWand},
      {'label': 'Users', 'value': '1M+', 'animation': AnimationAssets.userProfile},
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> stat = entry.value;
        
        return Expanded(
          child: AnimatedContainer(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            delay: Duration(milliseconds: 1100 + (index * 100)),
            child: Column(
              children: [
                AnimatedWidget(
                  assetPath: stat['animation']!,
                  width: 32,
                  height: 32,
                ).animate().scale(delay: Duration(milliseconds: 1200 + (index * 100))),
                const SizedBox(height: 8),
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 1300 + (index * 100))),
                Text(
                  stat['label']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 1400 + (index * 100))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildCategorySections() {
    return _categories.asMap().entries.map((entry) {
      int index = entry.key;
      FeatureCategory category = entry.value;
      
      return AnimatedBuilder(
        animation: _categoryControllers[index],
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0, 
              50 * (1 - _categoryControllers[index].value),
            ),
            child: Opacity(
              opacity: _categoryControllers[index].value,
              child: _buildCategorySection(category, index),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildCategorySection(FeatureCategory category, int categoryIndex) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category),
          const SizedBox(height: 16),
          _buildFeatureGrid(category.features, categoryIndex),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(FeatureCategory category) {
    return AnimatedCard(
      backgroundColor: category.color.withOpacity(0.1),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: category.animation,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
                Text(
                  '${category.features.length} powerful features',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          AnimatedChip(
            label: 'Explore',
            backgroundColor: category.color,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(List<Feature> features, int categoryIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final delay = Duration(milliseconds: 200 * (categoryIndex + 1) + (index * 100));
        
        return AnimatedCard(
          delay: delay,
          onTap: () => _showFeatureDetail(feature),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedWidget(
                assetPath: feature.animation,
                width: 48,
                height: 48,
              ).animate(delay: delay + 200.ms).scale().bounce(),
              const SizedBox(height: 12),
              Text(
                feature.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: delay + 300.ms).fadeIn(),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate(delay: delay + 400.ms).fadeIn(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.successCelebration,
            width: 60,
            height: 60,
          ).animate().scale().bounce(),
          const SizedBox(height: 16),
          Text(
            'Ready to Transform Your Life?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3),
          const SizedBox(height: 8),
          Text(
            'Join millions of users who have already started their journey',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 20),
          AnimatedButton(
            onPressed: _startJourney,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Start Your Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().scale(delay: 400.ms).bounce(),
        ],
      ),
    ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.5);
  }

  void _showFeatureDetail(Feature feature) {
    AnimatedDialog.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedWidget(
              assetPath: feature.animation,
              width: 80,
              height: 80,
            ).animate().scale().bounce(),
            const SizedBox(height: 20),
            Text(
              feature.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              feature.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _activateFeature(feature);
                    },
                    child: const Text('Try It', style: TextStyle(color: Colors.white)),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickFeatures() {
    AnimatedBottomSheet.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AnimatedWidget(
                  assetPath: AnimationAssets.magicWand,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Features',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quick feature shortcuts here
          ],
        ),
      ),
    );
  }

  void _activateFeature(Feature feature) {
    AnimatedSnackbar.showSuccess(
      context: context,
      message: '${feature.name} activated! Let\'s get started.',
    );
  }

  void _startJourney() {
    AnimatedSnackbar.showSuccess(
      context: context,
      message: 'Welcome to your transformation journey! 🚀',
    );
  }
}

class FeatureCategory {
  final String title;
  final IconData icon;
  final String animation;
  final Color color;
  final List<Feature> features;

  FeatureCategory({
    required this.title,
    required this.icon,
    required this.animation,
    required this.color,
    required this.features,
  });
}

class Feature {
  final String name;
  final String animation;
  final String description;

  Feature(this.name, this.animation, this.description);
}
