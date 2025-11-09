import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mental_health_providers.dart';
import '../../widgets/animated_widgets.dart';
import '../../core/animations/animation_assets.dart';

class MentalHealthScreen extends ConsumerStatefulWidget {
  const MentalHealthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends ConsumerState<MentalHealthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final mentalHealthState = ref.watch(mentalHealthProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.mentalWellness,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            const Text('Mental Health'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mood'),
            Tab(text: 'CBT'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodTab(mentalHealthState),
          _buildCBTTab(mentalHealthState),
          _buildInsightsTab(mentalHealthState),
        ],
      ),
      floatingActionButton: FloatingActionAnimationButton(
        animationAsset: AnimationAssets.moodTracker,
        onPressed: () => _showMoodEntrySheet(),
      ),
    );
  }

  Widget _buildMoodTab(dynamic mentalHealthState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTodaysMood(mentalHealthState),
          const SizedBox(height: 20),
          _buildMoodTracker(),
          const SizedBox(height: 20),
          _buildRecentEntries(mentalHealthState.entries),
        ],
      ),
    );
  }

  Widget _buildTodaysMood(dynamic mentalHealthState) {
    final todaysMood = ref.watch(todaysMoodProvider);
    
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
            assetPath: AnimationAssets.emotionalBalance,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            todaysMood != null ? 'Today\'s Mood Logged' : 'How are you feeling today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (todaysMood != null) ...[
            Text(
              'Mood: ${_getMoodText(todaysMood.moodRating)}/10',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _getMoodColor(todaysMood.moodRating),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (todaysMood.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                todaysMood.notes!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ] else ...[
            Text(
              'Track your mood to understand patterns and improve wellbeing',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showMoodEntrySheet(),
              icon: const Icon(Icons.sentiment_satisfied),
              label: const Text('Log Mood'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    final wellnessScore = ref.watch(wellnessScoreProvider);
    final moodTrend = ref.watch(moodTrendProvider);
    
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
                assetPath: AnimationAssets.progressChart,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Wellness Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWellnessItem('Wellness Score', '$wellnessScore/100', Colors.blue),
              _buildWellnessItem('Trend', _getTrendText(moodTrend), _getTrendColor(moodTrend)),
              _buildWellnessItem('Consistency', '${ref.watch(consistencyScoreProvider)}/10', Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: wellnessScore / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              wellnessScore > 70 ? Colors.green : wellnessScore > 50 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildCBTTab(dynamic mentalHealthState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCBTIntro(),
          const SizedBox(height: 20),
          _buildThoughtRecordCard(),
          const SizedBox(height: 20),
          _buildCopingStrategies(mentalHealthState.copingStrategies),
        ],
      ),
    );
  }

  Widget _buildCBTIntro() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedWidget(
            assetPath: AnimationAssets.therapySession,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'Cognitive Behavioral Therapy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Challenge negative thoughts and develop healthier thinking patterns',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showThoughtRecordSheet(),
            icon: const Icon(Icons.psychology),
            label: const Text('Start Thought Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtRecordCard() {
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
            'Recent Thought Records',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildThoughtRecordItem('Negative self-talk', 'Work presentation', DateTime.now().subtract(Duration(hours: 2))),
          _buildThoughtRecordItem('Catastrophizing', 'Health concern', DateTime.now().subtract(Duration(days: 1))),
        ],
      ),
    );
  }

  Widget _buildThoughtRecordItem(String distortion, String situation, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  situation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  distortion,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(date),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(dynamic mentalHealthState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMoodPatterns(),
          const SizedBox(height: 20),
          _buildMentalHealthInsights(mentalHealthState),
          const SizedBox(height: 20),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildMoodPatterns() {
    final bestDay = ref.watch(bestDayProvider);
    final worstDay = ref.watch(worstDayProvider);
    
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
                'Mood Patterns',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bestDay != null) ...[
            _buildPatternItem('Best Day', bestDay, Colors.green, Icons.sentiment_very_satisfied),
            const SizedBox(height: 8),
          ],
          if (worstDay != null) ...[
            _buildPatternItem('Challenging Day', worstDay, Colors.orange, Icons.sentiment_dissatisfied),
            const SizedBox(height: 16),
          ],
          AnimatedWidget(
            assetPath: AnimationAssets.statisticsView,
            width: double.infinity,
            height: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentEntries(List<dynamic> entries) {
    final recentEntries = ref.watch(recentMoodEntriesProvider);
    
    if (recentEntries.isEmpty) {
      return EmptyStateWidget(
        title: 'No mood entries yet',
        message: 'Start tracking your mood to gain insights into your mental health patterns',
        action: ElevatedButton.icon(
          onPressed: () => _showMoodEntrySheet(),
          icon: const Icon(Icons.add),
          label: const Text('Add Mood Entry'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentEntries.length.clamp(0, 5),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildMoodEntryCard(recentEntries[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMoodEntryCard(dynamic entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMoodColor(entry.moodRating).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.moodRating}',
                style: TextStyle(
                  color: _getMoodColor(entry.moodRating),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMoodDescription(entry.moodRating),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.notes?.isNotEmpty == true)
                  Text(
                    entry.notes!,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            _formatDate(entry.recordedAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopingStrategies(List<String> strategies) {
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
                assetPath: AnimationAssets.stressRelief,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Coping Strategies',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (strategies.isEmpty) ...[
            Text(
              'Personalized coping strategies will appear here based on your mood patterns',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ] else ...[
            ...strategies.take(3).map((strategy) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(strategy)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMentalHealthInsights(dynamic mentalHealthState) {
    final insights = ref.watch(mentalHealthInsightsProvider);
    
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
            'AI Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty) ...[
            Text(
              'Continue tracking your mood to receive personalized insights',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ] else ...[
            ...insights.take(3).map((insight) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(child: Text(insight)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendation = ref.watch(recommendationProvider);
    
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
            'Recommendations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recommendation != null) ...[
            Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ] else ...[
            Text(
              'Keep logging your mood to receive personalized recommendations',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  String _getMoodText(int rating) {
    return rating.toString();
  }

  String _getMoodDescription(int rating) {
    if (rating >= 8) return 'Excellent';
    if (rating >= 6) return 'Good';
    if (rating >= 4) return 'Okay';
    if (rating >= 2) return 'Poor';
    return 'Very Poor';
  }

  Color _getMoodColor(int rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.lightGreen;
    if (rating >= 4) return Colors.orange;
    if (rating >= 2) return Colors.red;
    return Colors.red[800]!;
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'improving': return '📈';
      case 'declining': return '📉';
      default: return '➡️';
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving': return Colors.green;
      case 'declining': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _showMoodEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoodEntryBottomSheet(),
    );
  }

  void _showThoughtRecordSheet() {
    // Implementation for CBT thought record
  }
}

class MoodEntryBottomSheet extends ConsumerStatefulWidget {
  const MoodEntryBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<MoodEntryBottomSheet> createState() => _MoodEntryBottomSheetState();
}

class _MoodEntryBottomSheetState extends ConsumerState<MoodEntryBottomSheet> {
  double _moodRating = 5.0;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedWidget(
                    assetPath: AnimationAssets.moodTracker,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                '${_moodRating.round()}/10',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getMoodColor(_moodRating.round()),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getMoodDescription(_moodRating.round()),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _getMoodColor(_moodRating.round()),
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: _moodRating,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _moodRating = value;
                  });
                },
                activeColor: _getMoodColor(_moodRating.round()),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'What\'s on your mind?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMoodEntry,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMoodEntry() async {
    final entryData = {
      'mood_rating': _moodRating.round(),
      'notes': _notesController.text,
      'recorded_at': DateTime.now().toIso8601String(),
    };

    final success = await ref.read(mentalHealthProvider.notifier).createEntry(entryData);
    
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood entry saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getMoodDescription(int rating) {
    if (rating >= 8) return 'Excellent';
    if (rating >= 6) return 'Good';
    if (rating >= 4) return 'Okay';
    if (rating >= 2) return 'Poor';
    return 'Very Poor';
  }

  Color _getMoodColor(int rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.lightGreen;
    if (rating >= 4) return Colors.orange;
    if (rating >= 2) return Colors.red;
    return Colors.red[800]!;
  }
}
