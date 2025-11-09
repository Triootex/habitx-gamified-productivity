import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/fitness_providers.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class FitnessScreen extends ConsumerStatefulWidget {
  const FitnessScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends ConsumerState<FitnessScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final fitnessState = ref.watch(fitnessProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.workoutSession,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Fitness'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Workouts'),
            Tab(text: 'Nutrition'),
            Tab(text: 'Progress'),
            Tab(text: 'Goals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutsTab(fitnessState),
          _buildNutritionTab(fitnessState),
          _buildProgressTab(fitnessState),
          _buildGoalsTab(fitnessState),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.runningPerson,
        onPressed: () => _startQuickWorkout(),
      ),
    );
  }

  Widget _buildWorkoutsTab(dynamic fitnessState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentWorkout(fitnessState),
          const SizedBox(height: 20),
          _buildWorkoutPlan(fitnessState),
          const SizedBox(height: 20),
          _buildRecentWorkouts(fitnessState.workouts),
        ],
      ),
    );
  }

  Widget _buildCurrentWorkout(dynamic fitnessState) {
    if (fitnessState.isWorkoutActive) {
      return _buildActiveWorkoutCard(fitnessState.currentWorkout);
    }
    
    return _buildStartWorkoutCard();
  }

  Widget _buildActiveWorkoutCard(dynamic workout) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.muscleGrowth,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Workout in Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '25:30 elapsed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
              ),
              ElevatedButton(
                onPressed: () => _endWorkout(),
                child: const Text('Finish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartWorkoutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.fitnessGoal,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to Exercise?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your workout and track your progress',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _startWorkout(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlan(dynamic fitnessState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.yogaPose,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExerciseItem('Push-ups', '3 sets x 15 reps', Icons.fitness_center),
          _buildExerciseItem('Squats', '3 sets x 20 reps', Icons.accessibility_new),
          _buildExerciseItem('Plank', '3 sets x 45 sec', Icons.timer),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _viewFullPlan(),
            child: const Text('View Full Plan'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String name, String details, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab(dynamic fitnessState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalorieCard(),
          const SizedBox(height: 20),
          _buildMacroChart(),
          const SizedBox(height: 20),
          _buildMealsList(fitnessState.nutritionEntries),
        ],
      ),
    );
  }

  Widget _buildCalorieCard() {
    final todaysCalories = ref.watch(todaysCaloriesProvider);
    const targetCalories = 2000;
    final progress = todaysCalories / targetCalories;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.healthyFood,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Today\'s Calories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$todaysCalories / $targetCalories cal',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', '65g', '120g', Colors.blue),
              _buildMacroItem('Carbs', '180g', '250g', Colors.orange),
              _buildMacroItem('Fats', '45g', '70g', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String name, String current, String target, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              current,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.bodySmall),
        Text('/ $target', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildProgressTab(dynamic fitnessState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressOverview(fitnessState),
          const SizedBox(height: 20),
          _buildBMICard(),
          const SizedBox(height: 20),
          _buildWeeklyStats(),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(dynamic fitnessState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.progressChart,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Fitness Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Workouts', '${fitnessState.totalWorkouts}', AnimationAssets.workoutSession),
              _buildStatItem('Calories', '${fitnessState.totalCaloriesBurned}', AnimationAssets.caloriesBurn),
              _buildStatItem('Streak', '${ref.watch(fitnessStreakProvider)}', AnimationAssets.streakFire),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    final currentBMI = ref.watch(currentBMIProvider);
    final bmiCategory = ref.watch(bmiCategoryProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.heartRate,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bmiCategory ?? 'Normal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                currentBMI?.toStringAsFixed(1) ?? '22.5',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(dynamic fitnessState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGoalCard('Weight Loss', '5 kg', '2 kg', 0.4),
          const SizedBox(height: 16),
          _buildGoalCard('Weekly Workouts', '5 times', '3 times', 0.6),
          const SizedBox(height: 16),
          _buildGoalCard('Daily Steps', '10,000', '7,500', 0.75),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String target, String current, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.fitnessGoal,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$current / $target',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts(List<dynamic> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Workouts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length.clamp(0, 5),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildWorkoutCard(workouts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(dynamic workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.runningPerson,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type ?? 'Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${workout.duration ?? 0} minutes • ${workout.caloriesBurned ?? 0} cal',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(workout.startTime),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<dynamic> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Meals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _logMeal(),
          icon: const Icon(Icons.add),
          label: const Text('Log Meal'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedWidget(
            assetPath: AnimationAssets.statisticsView,
            width: double.infinity,
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String animationAsset) {
    return Column(
      children: [
        AnimatedWidget(
          assetPath: animationAsset,
          width: 30,
          height: 30,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _startWorkout() {
    // Implementation for starting workout
  }

  void _startQuickWorkout() {
    // Implementation for quick workout
  }

  void _endWorkout() {
    // Implementation for ending workout
  }

  void _viewFullPlan() {
    // Implementation for viewing full workout plan
  }

  void _logMeal() {
    // Implementation for logging meals
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
