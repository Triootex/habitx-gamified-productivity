import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/meditation_providers.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final meditationState = ref.watch(meditationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.meditationPose,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Meditation'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sessions'),
            Tab(text: 'Guided'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionsTab(meditationState),
          _buildGuidedTab(meditationState),
          _buildProgressTab(meditationState),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.breathingExercise,
        onPressed: () => _startQuickMeditation(),
      ),
    );
  }

  Widget _buildSessionsTab(dynamic meditationState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentSession(meditationState),
          const SizedBox(height: 20),
          _buildRecentSessions(meditationState.sessions),
        ],
      ),
    );
  }

  Widget _buildCurrentSession(dynamic meditationState) {
    if (meditationState.isSessionActive) {
      return _buildActiveSessionCard(meditationState.currentSession);
    }
    
    return _buildStartSessionCard();
  }

  Widget _buildActiveSessionCard(dynamic session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.mindfulnessWave,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Meditation in Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '15:30 / 20:00',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.pause, color: Colors.white),
                iconSize: 32,
              ),
              IconButton(
                onPressed: () => _endSession(),
                icon: const Icon(Icons.stop, color: Colors.white),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartSessionCard() {
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
            assetPath: AnimationAssets.zenGarden,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to Meditate?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your inner peace with guided meditation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _startMeditation(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(List<dynamic> sessions) {
    if (sessions.isEmpty) {
      return EmptyStateWidget(
        title: 'No meditation sessions yet',
        message: 'Start your mindfulness journey today',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildSessionCard(sessions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSessionCard(dynamic session) {
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
            assetPath: AnimationAssets.peacefulMind,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.technique ?? 'Mindfulness',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.duration ?? 0} minutes',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(session.startTime),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedTab(dynamic meditationState) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: meditationState.guidedMeditations.length,
      itemBuilder: (context, index) {
        return _buildGuidedMeditationCard(meditationState.guidedMeditations[index]);
      },
    );
  }

  Widget _buildGuidedMeditationCard(dynamic meditation) {
    return MicroInteractionButton(
      onPressed: () => _startGuidedMeditation(meditation),
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
        child: Column(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.chakraHealing,
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 12),
            Text(
              meditation.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${meditation.duration} min',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(dynamic meditationState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressOverview(meditationState),
          const SizedBox(height: 20),
          _buildStreakCard(meditationState.streakData),
          const SizedBox(height: 20),
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(dynamic meditationState) {
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
            'Your Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Sessions',
                meditationState.totalSessions.toString(),
                AnimationAssets.meditationPose,
              ),
              _buildStatItem(
                'Minutes',
                meditationState.totalMinutes.toString(),
                AnimationAssets.breathingExercise,
              ),
              _buildStatItem(
                'Streak',
                (meditationState.streakData?['current_streak'] ?? 0).toString(),
                AnimationAssets.streakFire,
              ),
            ],
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

  Widget _buildStreakCard(dynamic streakData) {
    final currentStreak = streakData?['current_streak'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.orange.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.streakFire,
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$currentStreak days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Keep going!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
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
          // Add weekly progress visualization here
          AnimatedWidget(
            assetPath: AnimationAssets.statisticsView,
            width: double.infinity,
            height: 100,
          ),
        ],
      ),
    );
  }

  void _startMeditation() {
    // Implementation for starting meditation
  }

  void _startQuickMeditation() {
    // Implementation for quick meditation
  }

  void _startGuidedMeditation(dynamic meditation) {
    // Implementation for guided meditation
  }

  void _endSession() {
    // Implementation for ending session
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
