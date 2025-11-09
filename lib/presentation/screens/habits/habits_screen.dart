import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habit_providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    Future.microtask(() {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        ref.read(habitProvider.notifier).setUserId(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    final todayCompleted = ref.watch(todayCompletedHabitsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.habitCheck,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Habits'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showHabitAnalytics(context),
            icon: const Icon(Icons.insights),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Today (${habitState.todayHabits.length})'),
            Tab(text: 'All (${habitState.habits.length})'),
            Tab(text: 'Streaks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayHabits(habitState.todayHabits),
          _buildAllHabits(habitState.habits),
          _buildStreaksView(habitState.streaks),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.habitStreak,
        onPressed: () => _showCreateHabitSheet(context),
      ),
    );
  }

  Widget _buildTodayHabits(List<dynamic> habits) {
    if (habits.isEmpty) {
      return EmptyStateWidget(
        title: 'No habits for today',
        message: 'Create your first habit to start building consistency!',
        action: ElevatedButton.icon(
          onPressed: () => _showCreateHabitSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Habit'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildHabitCard(habits[index]);
      },
    );
  }

  Widget _buildAllHabits(List<dynamic> habits) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildHabitCard(habits[index]);
      },
    );
  }

  Widget _buildStreaksView(Map<String, int> streaks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: streaks.length,
      itemBuilder: (context, index) {
        final entry = streaks.entries.elementAt(index);
        return _buildStreakCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildHabitCard(dynamic habit) {
    return MicroInteractionButton(
      onPressed: () => _showHabitDetails(context, habit),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _logHabit(habit),
              child: Container(
                width: 50,
                height: 50,
                child: SuccessAnimationWidget(size: 50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${habit.currentStreak} day streak',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedWidget(
              assetPath: AnimationAssets.streakFire,
              width: 30,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String habitId, int streak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.streakFire,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Streak',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$streak days',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logHabit(dynamic habit) async {
    final success = await ref.read(habitProvider.notifier).logCompletion(habit.id);
    
    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CelebrationAnimationWidget(
                onComplete: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Text(
                'Habit Logged!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showCreateHabitSheet(BuildContext context) {
    // Implementation for create habit sheet
  }

  void _showHabitDetails(BuildContext context, dynamic habit) {
    // Implementation for habit details
  }

  void _showHabitAnalytics(BuildContext context) {
    // Implementation for habit analytics
  }
}
