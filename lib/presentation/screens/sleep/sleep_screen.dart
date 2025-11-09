import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSleeping = false;
  DateTime? _bedtime;
  DateTime? _wakeTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.sleepCycle,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Sleep Tracking'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tonight'),
            Tab(text: 'History'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTonightTab(),
          _buildHistoryTab(),
          _buildInsightsTab(),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: _isSleeping ? AnimationAssets.wakeUp : AnimationAssets.bedtimeRoutine,
        onPressed: () => _toggleSleep(),
      ),
    );
  }

  Widget _buildTonightTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSleepTracker(),
          const SizedBox(height: 20),
          _buildBedtimeRoutine(),
          const SizedBox(height: 20),
          _buildSleepGoals(),
        ],
      ),
    );
  }

  Widget _buildSleepTracker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isSleeping 
              ? [Colors.indigo[900]!, Colors.indigo[700]!]
              : [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: _isSleeping ? AnimationAssets.dreamState : AnimationAssets.sleepCycle,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            _isSleeping ? 'Sweet Dreams' : 'Ready for Bed?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_isSleeping && _bedtime != null) ...[
            Text(
              'Sleeping since ${_formatTime(_bedtime!)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_getSleepDuration()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ] else ...[
            Text(
              'Track your sleep to improve your rest quality',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _toggleSleep(),
            icon: Icon(_isSleeping ? Icons.wb_sunny : Icons.bedtime),
            label: Text(_isSleeping ? 'Wake Up' : 'Go to Sleep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _isSleeping ? Colors.orange : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedtimeRoutine() {
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
                assetPath: AnimationAssets.bedtimeRoutine,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Bedtime Routine',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoutineItem('Take a warm shower', true),
          _buildRoutineItem('Read a book', false),
          _buildRoutineItem('Practice meditation', false),
          _buildRoutineItem('Set phone aside', false),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.25, // 1 out of 4 completed
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1 of 4 completed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineItem(String activity, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Toggle completion
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: completed ? Colors.green : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity,
              style: TextStyle(
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? Colors.grey[600] : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepGoals() {
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
            'Sleep Goals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalItem('Sleep Duration', '8 hours', '7h 30m', 0.94),
          const SizedBox(height: 12),
          _buildGoalItem('Bedtime Consistency', '11:00 PM', '11:15 PM', 0.85),
          const SizedBox(height: 12),
          _buildGoalItem('Wake Time', '7:00 AM', '7:10 AM', 0.90),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String goal, String target, String current, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(goal, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              '$current / $target',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeeklySummary(),
          const SizedBox(height: 20),
          _buildSleepHistory(),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
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
                assetPath: AnimationAssets.sleepQuality,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Average: 7h 45m',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Quality', '8.2/10', Colors.green),
              _buildStatItem('Consistency', '85%', Colors.blue),
              _buildStatItem('Efficiency', '92%', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepHistory() {
    final sleepData = [
      {'date': 'Today', 'duration': '7h 30m', 'quality': 8.5, 'bedtime': '11:15 PM'},
      {'date': 'Yesterday', 'duration': '8h 15m', 'quality': 9.0, 'bedtime': '10:45 PM'},
      {'date': '2 days ago', 'duration': '7h 00m', 'quality': 7.5, 'bedtime': '11:30 PM'},
      {'date': '3 days ago', 'duration': '8h 30m', 'quality': 8.8, 'bedtime': '10:30 PM'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sleepData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sleep = sleepData[index];
            return _buildSleepCard(sleep);
          },
        ),
      ],
    );
  }

  Widget _buildSleepCard(Map<String, dynamic> sleep) {
    final quality = sleep['quality'] as double;
    final qualityColor = quality >= 8.0 ? Colors.green : quality >= 6.0 ? Colors.orange : Colors.red;

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
            assetPath: AnimationAssets.dreamState,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sleep['date'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${sleep['duration']} • Bedtime: ${sleep['bedtime']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${quality}/10',
                  style: TextStyle(
                    color: qualityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quality',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSleepPatterns(),
          const SizedBox(height: 20),
          _buildSleepTips(),
          const SizedBox(height: 20),
          _buildSleepChart(),
        ],
      ),
    );
  }

  Widget _buildSleepPatterns() {
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
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Patterns',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPatternItem('Best Sleep Day', 'Tuesday', Colors.green),
          _buildPatternItem('Average Bedtime', '11:05 PM', Colors.blue),
          _buildPatternItem('Sleep Debt', '2h 15m', Colors.orange),
          const SizedBox(height: 16),
          Text(
            '💡 You sleep best when you go to bed before 11 PM',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTips() {
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
            'Sleep Tips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipItem('🌙', 'Keep a consistent sleep schedule'),
          _buildTipItem('📱', 'Avoid screens 1 hour before bed'),
          _buildTipItem('☕', 'No caffeine after 2 PM'),
          _buildTipItem('🏃', 'Exercise regularly, but not before bed'),
          _buildTipItem('🛏️', 'Keep your bedroom cool and dark'),
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

  Widget _buildSleepChart() {
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
            'Sleep Trend (Last 7 Days)',
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

  void _toggleSleep() {
    setState(() {
      if (_isSleeping) {
        // Wake up
        _isSleeping = false;
        _wakeTime = DateTime.now();
        // Show sleep summary
        _showSleepSummary();
      } else {
        // Go to sleep
        _isSleeping = true;
        _bedtime = DateTime.now();
      }
    });
  }

  void _showSleepSummary() {
    if (_bedtime != null && _wakeTime != null) {
      final duration = _wakeTime!.difference(_bedtime!);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Good Morning!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.wakeUp,
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text('You slept for ${_formatDuration(duration)}'),
              const SizedBox(height: 8),
              Text('How was your sleep quality?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSleepRating();
              },
              child: const Text('Rate Sleep'),
            ),
          ],
        ),
      );
    }
  }

  void _showSleepRating() {
    // Implementation for sleep quality rating
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _getSleepDuration() {
    if (_bedtime != null) {
      final duration = DateTime.now().difference(_bedtime!);
      return _formatDuration(duration);
    }
    return '0h 0m';
  }
}
