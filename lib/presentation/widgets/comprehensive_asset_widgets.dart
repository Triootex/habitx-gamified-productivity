import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/web_asset_constants.dart';
import 'hybrid_animated_widgets.dart';
import '../../core/animations/rive_animation_assets.dart';
import '../../core/animations/animation_assets.dart';

/// Comprehensive Asset Widget System
/// Integrates Icons, Images, Sounds, Fonts, Rive, and Lottie animations
class ComprehensiveAssetWidget extends StatefulWidget {
  final String category; // productivity, health, mental, social, learning, life
  final String feature;  // specific feature name
  final Widget child;
  final bool playSound;
  final bool showIcon;
  final bool showBackground;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ComprehensiveAssetWidget({
    Key? key,
    required this.category,
    required this.feature,
    required this.child,
    this.playSound = false,
    this.showIcon = true,
    this.showBackground = false,
    this.onTap,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ComprehensiveAssetWidget> createState() => _ComprehensiveAssetWidgetState();
}

class _ComprehensiveAssetWidgetState extends State<ComprehensiveAssetWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.playSound) {
          _playInteractionSound();
        }
        _triggerHapticFeedback();
        widget.onTap?.call();
      },
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          image: widget.showBackground ? DecorationImage(
            image: AssetImage(_getBackgroundImage()),
            fit: BoxFit.cover,
            opacity: 0.1,
          ) : null,
        ),
        child: Stack(
          children: [
            // Main content
            widget.child,
            
            // Category icon overlay
            if (widget.showIcon)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HybridAnimatedWidget(
                    riveAssetPath: _getRiveAnimation(),
                    lottieAssetPath: _getLottieAnimation(),
                    width: 20,
                    height: 20,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  String _getBackgroundImage() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return WebAssetConstants.ImagesAssets.productivitybg;
      case 'health':
        return WebAssetConstants.ImagesAssets.healthbg;
      case 'mental':
        return WebAssetConstants.ImagesAssets.mindfulnessbg;
      case 'social':
        return WebAssetConstants.ImagesAssets.socialbg;
      case 'learning':
        return WebAssetConstants.ImagesAssets.learningbg;
      default:
        return WebAssetConstants.ImagesAssets.dashboardhero;
    }
  }

  String? _getRiveAnimation() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return RiveAnimationAssets.taskComplete;
      case 'health':
        return RiveAnimationAssets.mascotFlying;
      case 'mental':
        return RiveAnimationAssets.avatarPack;
      case 'social':
        return RiveAnimationAssets.downloadButton;
      case 'learning':
        return RiveAnimationAssets.progressBar;
      default:
        return RiveAnimationAssets.loadingIndicator;
    }
  }

  String? _getLottieAnimation() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return AnimationAssets.workingHours;
      case 'health':
        return AnimationAssets.healthyHabits;
      case 'mental':
        return AnimationAssets.meditation;
      case 'social':
        return AnimationAssets.successCelebration;
      case 'learning':
        return AnimationAssets.rocket;
      default:
        return AnimationAssets.loadingSpinner;
    }
  }

  Color _getCategoryColor() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return Colors.blue;
      case 'health':
        return Colors.green;
      case 'mental':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'learning':
        return Colors.teal;
      case 'life':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _playInteractionSound() async {
    try {
      switch (widget.feature.toLowerCase()) {
        case 'task_complete':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.taskcomplete));
          break;
        case 'goal_achieved':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.goalachieved));
          break;
        case 'timer_alert':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.timeralert));
          break;
        case 'meditation':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.meditationbell));
          break;
        case 'level_up':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.levelup));
          break;
        case 'achievement':
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.achievementunlock));
          break;
        default:
          await _audioPlayer.play(AssetSource(WebAssetConstants.SoundsAssets.swipesound));
      }
    } catch (e) {
      // Fallback to haptic feedback if sound fails
      _triggerHapticFeedback();
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }
}

/// Enhanced Feature Card with comprehensive assets
class ComprehensiveFeatureCard extends StatelessWidget {
  final String category;
  final String feature;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isActive;

  const ComprehensiveFeatureCard({
    Key? key,
    required this.category,
    required this.feature,
    required this.title,
    required this.description,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ComprehensiveAssetWidget(
      category: category,
      feature: feature,
      playSound: true,
      showIcon: true,
      showBackground: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Feature Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  _getFeatureIcon(),
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getFeatureFallbackIcon(),
                    color: _getCategoryColor(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive ? _getCategoryColor() : null,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress/Status indicator with Rive animation
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 4,
                        width: isActive ? double.infinity : 0,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HybridAnimatedWidget(
                riveAssetPath: _getRiveAnimation(),
                lottieAssetPath: _getLottieAnimation(),
                width: 16,
                height: 16,
                autoplay: isActive,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  String _getFeatureIcon() {
    // Map features to downloaded icons
    switch (feature.toLowerCase()) {
      case 'task_management':
        return WebAssetConstants.IconsAssets.taskicon;
      case 'time_tracking':
        return WebAssetConstants.IconsAssets.timericon;
      case 'goal_setting':
        return WebAssetConstants.IconsAssets.goalicon;
      case 'project_management':
        return WebAssetConstants.IconsAssets.projecticon;
      case 'analytics':
        return WebAssetConstants.IconsAssets.analyticsicon;
      case 'pomodoro':
        return WebAssetConstants.IconsAssets.pomodoroicon;
      
      case 'habit_tracking':
        return WebAssetConstants.IconsAssets.hearticon;
      case 'meditation':
        return WebAssetConstants.IconsAssets.meditationicon;
      case 'fitness':
        return WebAssetConstants.IconsAssets.fitnessicon;
      case 'sleep_tracking':
        return WebAssetConstants.IconsAssets.sleepicon;
      case 'nutrition':
        return WebAssetConstants.IconsAssets.nutritionicon;
      case 'water_intake':
        return WebAssetConstants.IconsAssets.watericon;
      case 'mood_tracking':
        return WebAssetConstants.IconsAssets.moodicon;
      case 'exercise':
        return WebAssetConstants.IconsAssets.exerciseicon;
      
      case 'mindfulness':
        return WebAssetConstants.IconsAssets.mindfulnessicon;
      case 'stress_management':
        return WebAssetConstants.IconsAssets.stressicon;
      case 'focus_training':
        return WebAssetConstants.IconsAssets.focusicon;
      case 'gratitude':
        return WebAssetConstants.IconsAssets.gratitudeicon;
      case 'breathing_exercises':
        return WebAssetConstants.IconsAssets.breathingicon;
      case 'brain_training':
        return WebAssetConstants.IconsAssets.brainicon;
      
      case 'community':
        return WebAssetConstants.IconsAssets.communityicon;
      case 'challenges':
        return WebAssetConstants.IconsAssets.challengeicon;
      case 'leaderboards':
        return WebAssetConstants.IconsAssets.leaderboardicon;
      case 'social_sharing':
        return WebAssetConstants.IconsAssets.shareicon;
      case 'achievements':
        return WebAssetConstants.IconsAssets.achievementicon;
      case 'groups':
        return WebAssetConstants.IconsAssets.groupicon;
      
      case 'skill_development':
        return WebAssetConstants.IconsAssets.skillicon;
      case 'reading':
        return WebAssetConstants.IconsAssets.bookicon;
      case 'courses':
        return WebAssetConstants.IconsAssets.courseicon;
      case 'languages':
        return WebAssetConstants.IconsAssets.languageicon;
      case 'creativity':
        return WebAssetConstants.IconsAssets.creativeicon;
      case 'knowledge_base':
        return WebAssetConstants.IconsAssets.knowledgeicon;
      
      case 'calendar':
        return WebAssetConstants.IconsAssets.calendaricon;
      case 'reminders':
        return WebAssetConstants.IconsAssets.remindericon;
      case 'notes':
        return WebAssetConstants.IconsAssets.notesicon;
      case 'file_management':
        return WebAssetConstants.IconsAssets.filesicon;
      case 'contacts':
        return WebAssetConstants.IconsAssets.contactsicon;
      case 'travel':
        return WebAssetConstants.IconsAssets.travelicon;
      
      default:
        return WebAssetConstants.IconsAssets.taskicon;
    }
  }

  IconData _getFeatureFallbackIcon() {
    switch (category.toLowerCase()) {
      case 'productivity':
        return Icons.work;
      case 'health':
        return Icons.health_and_safety;
      case 'mental':
        return Icons.psychology;
      case 'social':
        return Icons.people;
      case 'learning':
        return Icons.school;
      case 'life':
        return Icons.calendar_today;
      default:
        return Icons.apps;
    }
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'productivity':
        return Colors.blue;
      case 'health':
        return Colors.green;
      case 'mental':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'learning':
        return Colors.teal;
      case 'life':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String? _getRiveAnimation() {
    switch (category.toLowerCase()) {
      case 'productivity':
        return RiveAnimationAssets.taskComplete;
      case 'health':
        return RiveAnimationAssets.mascotFlying;
      case 'mental':
        return RiveAnimationAssets.avatarPack;
      case 'social':
        return RiveAnimationAssets.downloadButton;
      case 'learning':
        return RiveAnimationAssets.progressBar;
      default:
        return RiveAnimationAssets.loadingIndicator;
    }
  }

  String? _getLottieAnimation() {
    switch (category.toLowerCase()) {
      case 'productivity':
        return AnimationAssets.workingHours;
      case 'health':
        return AnimationAssets.healthyHabits;
      case 'mental':
        return AnimationAssets.meditation;
      case 'social':
        return AnimationAssets.successCelebration;
      case 'learning':
        return AnimationAssets.rocket;
      default:
        return AnimationAssets.loadingSpinner;
    }
  }
}

/// Audio Manager for playing category-specific sounds
class ComprehensiveAudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static Future<void> playSound(String category, String action) async {
    try {
      String soundPath;
      
      switch (action.toLowerCase()) {
        case 'complete':
          soundPath = WebAssetConstants.SoundsAssets.taskcomplete;
          break;
        case 'achieve':
          soundPath = WebAssetConstants.SoundsAssets.goalachieved;
          break;
        case 'alert':
          soundPath = WebAssetConstants.SoundsAssets.timeralert;
          break;
        case 'meditation':
          soundPath = WebAssetConstants.SoundsAssets.meditationbell;
          break;
        case 'levelup':
          soundPath = WebAssetConstants.SoundsAssets.levelup;
          break;
        case 'unlock':
          soundPath = WebAssetConstants.SoundsAssets.achievementunlock;
          break;
        default:
          soundPath = WebAssetConstants.SoundsAssets.swipesound;
      }
      
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      // Fallback to haptic feedback
      HapticFeedback.lightImpact();
    }
  }
  
  static Future<void> playAmbientSound(String category) async {
    try {
      String soundPath;
      
      switch (category.toLowerCase()) {
        case 'productivity':
          soundPath = WebAssetConstants.SoundsAssets.productivityambient;
          break;
        case 'meditation':
          soundPath = WebAssetConstants.SoundsAssets.meditationambient;
          break;
        case 'focus':
          soundPath = WebAssetConstants.SoundsAssets.focusambient;
          break;
        default:
          return; // No ambient sound
      }
      
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      // Silent fail for ambient sounds
    }
  }
  
  static void dispose() {
    _audioPlayer.dispose();
  }
}

/// Mascot Widget with dynamic expressions
class ComprehensiveMascotWidget extends StatefulWidget {
  final String category;
  final String emotion;
  final double size;

  const ComprehensiveMascotWidget({
    Key? key,
    required this.category,
    this.emotion = 'happy',
    this.size = 100,
  }) : super(key: key);

  @override
  State<ComprehensiveMascotWidget> createState() => _ComprehensiveMascotWidgetState();
}

class _ComprehensiveMascotWidgetState extends State<ComprehensiveMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mascot Image
        Image.asset(
          _getMascotImage(),
          width: widget.size,
          height: widget.size,
          errorBuilder: (context, error, stackTrace) => Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(widget.size / 2),
            ),
            child: Icon(
              _getMascotFallbackIcon(),
              size: widget.size * 0.6,
              color: _getCategoryColor(),
            ),
          ),
        ),
        
        // Rive Animation Overlay
        HybridAnimatedWidget(
          riveAssetPath: _getRiveAnimation(),
          lottieAssetPath: _getLottieAnimation(),
          width: widget.size * 0.8,
          height: widget.size * 0.8,
          autoplay: true,
          loop: true,
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05));
  }

  String _getMascotImage() {
    switch (widget.emotion.toLowerCase()) {
      case 'happy':
        return WebAssetConstants.ImagesAssets.mascothappy;
      case 'working':
        return WebAssetConstants.ImagesAssets.mascotworking;
      case 'celebrating':
        return WebAssetConstants.ImagesAssets.mascotcelebrating;
      case 'meditating':
        return WebAssetConstants.ImagesAssets.mascotmeditating;
      case 'exercising':
        return WebAssetConstants.ImagesAssets.mascotexercising;
      case 'sleeping':
        return WebAssetConstants.ImagesAssets.mascotsleeping;
      default:
        return WebAssetConstants.ImagesAssets.mascothappy;
    }
  }

  IconData _getMascotFallbackIcon() {
    switch (widget.emotion.toLowerCase()) {
      case 'working':
        return Icons.work;
      case 'celebrating':
        return Icons.celebration;
      case 'meditating':
        return Icons.self_improvement;
      case 'exercising':
        return Icons.fitness_center;
      case 'sleeping':
        return Icons.bedtime;
      default:
        return Icons.sentiment_very_satisfied;
    }
  }

  Color _getCategoryColor() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return Colors.blue;
      case 'health':
        return Colors.green;
      case 'mental':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'learning':
        return Colors.teal;
      case 'life':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String? _getRiveAnimation() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return RiveAnimationAssets.taskComplete;
      case 'health':
        return RiveAnimationAssets.mascotFlying;
      case 'mental':
        return RiveAnimationAssets.avatarPack;
      default:
        return RiveAnimationAssets.mascotFlying;
    }
  }

  String? _getLottieAnimation() {
    switch (widget.category.toLowerCase()) {
      case 'productivity':
        return AnimationAssets.workingHours;
      case 'health':
        return AnimationAssets.healthyHabits;
      case 'mental':
        return AnimationAssets.meditation;
      default:
        return AnimationAssets.successCelebration;
    }
  }
}
