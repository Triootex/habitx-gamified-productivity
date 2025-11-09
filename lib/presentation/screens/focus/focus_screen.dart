import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/focus_providers.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.focusMode,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Focus'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pomodoro'),
            Tab(text: 'Deep Work'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPomodoroTab(focusState),
          _buildDeepWorkTab(focusState),
          _buildAnalyticsTab(focusState),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.pomodoroTimer,
        onPressed: () => _startFocusSession(),
      ),
    );
  }

  Widget _buildPomodoroTab(dynamic focusState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPomodoroTimer(focusState),
          const SizedBox(height: 24),
          _buildPomodoroSettings(),
          const SizedBox(height: 24),
          _buildTodaysSessions(focusState.todaysSessions),
        ],
      ),
    );
  }

  Widget _buildPomodoroTimer(dynamic focusState) {
    final isActive = focusState.isSessionActive;
    final remainingTime = focusState.remainingTime ?? 25 * 60; // 25 minutes default
    final totalTime = focusState.sessionDuration ?? 25 * 60;
    final progress = 1 - (remainingTime / totalTime);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isActive ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              AnimatedWidget(
                assetPath: isActive ? AnimationAssets.pomodoroTimer : AnimationAssets.deepWork,
                width: 120,
                height: 120,
              ),
              Positioned(
                bottom: 20,
                child: Text(
                  _formatTime(remainingTime),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            isActive ? 'Focus Time' : 'Ready to Focus?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive 
                ? 'Stay focused until the timer ends'
                : 'Start a Pomodoro session to boost your productivity',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pauseSession(),
                  child: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _stopSession(),
                  child: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => _startPomodoroSession(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Pomodoro'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(200, 56),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPomodoroSettings() {
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
                assetPath: AnimationAssets.timeManagement,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Timer Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingItem('Focus Time', '25 minutes', Icons.timer),
          _buildSettingItem('Short Break', '5 minutes', Icons.coffee),
          _buildSettingItem('Long Break', '15 minutes', Icons.bed),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showSettingsSheet(),
            child: const Text('Customize'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepWorkTab(dynamic focusState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDeepWorkTimer(focusState),
          const SizedBox(height: 24),
          _buildDistractionsCard(focusState),
          const SizedBox(height: 24),
          _buildProductivityTips(),
        ],
      ),
    );
  }

  Widget _buildDeepWorkTimer(dynamic focusState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.productivityBoost,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            'Deep Work Mode',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Eliminate distractions and focus deeply on important work',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _startDeepWorkSession(),
            icon: const Icon(Icons.psychology),
            label: const Text('Start Deep Work'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistractionsCard(dynamic focusState) {
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
                assetPath: AnimationAssets.focusMode,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Distractions Blocked Today',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDistractionItem('Social Media', 12),
          _buildDistractionItem('News Websites', 5),
          _buildDistractionItem('Entertainment', 8),
          const SizedBox(height: 16),
          Text(
            'Great job staying focused! 🎯',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistractionItem(String type, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count blocked',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(dynamic focusState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProductivityScore(focusState),
          const SizedBox(height: 20),
          _buildWeeklyFocusChart(),
          const SizedBox(height: 20),
          _buildFocusInsights(focusState),
        ],
      ),
    );
  }

  Widget _buildProductivityScore(dynamic focusState) {
    final productivityScore = ref.watch(productivityScoreProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.trendingUp,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Productivity Score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(productivityScore * 100).toInt()}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: productivityScore,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            productivityScore > 0.8 
                ? 'Excellent focus today! 🌟'
                : productivityScore > 0.6
                    ? 'Good progress! 👍'
                    : 'Room for improvement 📈',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSessions(List<dynamic> sessions) {
    if (sessions.isEmpty) {
      return EmptyStateWidget(
        title: 'No focus sessions today',
        message: 'Start your first Pomodoro session to boost productivity!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Sessions',
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
            assetPath: session.isCompleted 
                ? AnimationAssets.successCheck 
                : AnimationAssets.pomodoroTimer,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.type ?? 'Focus Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.duration} minutes',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (session.isCompleted)
            Icon(Icons.check_circle, color: Colors.green)
          else
            Icon(Icons.timer, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProductivityTips() {
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
                assetPath: AnimationAssets.insightsGeneration,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Productivity Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('🎯', 'Set clear goals before each session'),
          _buildTipItem('📱', 'Put your phone in another room'),
          _buildTipItem('💧', 'Stay hydrated during breaks'),
          _buildTipItem('🚶', 'Take a walk during long breaks'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyFocusChart() {
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
            'Weekly Focus Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedWidget(
            assetPath: AnimationAssets.statisticsView,
            width: double.infinity,
            height: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildFocusInsights(dynamic focusState) {
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
            'Focus Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '✨ Your most productive time is between 9-11 AM',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '📈 You\'ve improved focus by 23% this week',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '🎯 Monday is your most focused day',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startFocusSession() {
    _startPomodoroSession();
  }

  void _startPomodoroSession() {
    ref.read(focusProvider.notifier).startSession('pomodoro', 25);
  }

  void _startDeepWorkSession() {
    ref.read(focusProvider.notifier).startSession('deep_work', 60);
  }

  void _pauseSession() {
    ref.read(focusProvider.notifier).pauseSession();
  }

  void _stopSession() {
    ref.read(focusProvider.notifier).endSession({});
  }

  void _showSettingsSheet() {
    // Implementation for settings sheet
  }
}
