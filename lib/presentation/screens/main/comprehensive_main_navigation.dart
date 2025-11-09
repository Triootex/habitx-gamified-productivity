import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/hybrid_animated_widgets.dart';
import '../../widgets/comprehensive_asset_widgets.dart';
import '../../widgets/page_transitions.dart';
import '../../../core/animations/animation_assets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../../core/constants/web_asset_constants.dart';
import '../dashboard/enhanced_dashboard_screen.dart';
import '../features/productivity/productivity_hub_screen.dart';
import '../features/health/health_wellness_screen.dart';
import '../features/rive_showcase_screen.dart';
import '../comprehensive_features_screen.dart';
import '../../widgets/animation_integration.dart';

class ComprehensiveMainNavigation extends ConsumerStatefulWidget {
  const ComprehensiveMainNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<ComprehensiveMainNavigation> createState() => _ComprehensiveMainNavigationState();
}

class _ComprehensiveMainNavigationState extends ConsumerState<ComprehensiveMainNavigation>
    with TickerProviderStateMixin, ScreenTransitionMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late AnimationController _bottomNavController;
  late List<AnimationController> _iconControllers;

  static const List<NavigationTab> _navigationTabs = [
    NavigationTab(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      animationAsset: AnimationAssets.rocket, // Real MCP Animation
      color: Colors.blue,
    ),
    NavigationTab(
      icon: Icons.work,
      activeIcon: Icons.work,
      label: 'Productivity',
      animationAsset: AnimationAssets.workingHours, // Real MCP Animation
      color: Colors.orange,
    ),
    NavigationTab(
      icon: Icons.health_and_safety,
      activeIcon: Icons.health_and_safety,
      label: 'Health',
      animationAsset: AnimationAssets.healthyHabits, // Real MCP Animation
      color: Colors.green,
    ),
    NavigationTab(
      icon: Icons.animation,
      activeIcon: Icons.animation,
      label: 'Rive',
      animationAsset: AnimationAssets.successCelebration, // Real MCP Animation
      color: Colors.purple,
    ),
    NavigationTab(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      animationAsset: AnimationAssets.meditation, // Real MCP Animation
      color: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bottomNavController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _iconControllers = List.generate(
      _navigationTabs.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _initializeAnimations();
  }

  void _initializeAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _bottomNavController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _fabController.forward();
      await Future.delayed(const Duration(milliseconds: 50));
      _iconControllers[0].forward(); // Initially active tab
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _bottomNavController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedLoadingOverlay(
      isLoading: false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            // Dashboard - Real MCP Animations
            const EnhancedDashboardScreen()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, duration: 600.ms),
            
            // Productivity Hub - Real MCP Animations
            const ProductivityHubScreen()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.3, duration: 600.ms),
            
            // Health & Wellness - Real MCP Animations
            const HealthWellnessScreen()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.3, duration: 600.ms),
            
            // Rive Showcase - Real Rive Animations
            const RiveShowcaseScreen()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.3, duration: 600.ms),
            
            // Profile Screen - Real MCP Animations
            _buildProfileScreen()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.3, duration: 600.ms),
          ],
        ),
        bottomNavigationBar: _buildComprehensiveBottomNav(),
        floatingActionButton: _buildRiveSmartFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildComprehensiveBottomNav() {
    return AnimatedBuilder(
      animation: _bottomNavController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _bottomNavController.value)),
          child: Container(
            height: 90,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navigationTabs.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final tab = _navigationTabs[index];
    final isActive = _currentIndex == index;
    
    return AnimatedBuilder(
      animation: _iconControllers[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onTabTapped(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon with Real MCP Animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow effect
                    if (isActive)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: tab.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.2, 1.2),
                          duration: 1500.ms,
                        ),
                    
                    // Hybrid Animation Icon (Rive + Lottie)
                    HybridAnimatedWidget(
                      riveAssetPath: _getNavRiveAnimation(index),
                      lottieAssetPath: tab.animationAsset,
                      width: isActive ? 28 : 24,
                      height: isActive ? 28 : 24,
                      autoplay: isActive,
                      loop: true,
                    )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Label with animation
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: isActive ? 12 : 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? tab.color : Colors.grey[600],
                  ),
                )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 200.ms,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiveSmartFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabController.value,
          child: Transform.rotate(
            angle: _fabController.value * 2 * 3.14159,
            child: HybridAnimatedFAB(
              onPressed: _onFABPressed,
              riveAssetPath: _getRiveFABAnimation(), // Real Rive Animation
              lottieAssetPath: _getFABAnimation(),   // Lottie Fallback
              backgroundColor: _getFABColor(),
              animateOnPress: true,
              child: Icon(
                _getFABIcon(),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFABAnimation() {
    switch (_currentIndex) {
      case 0: return AnimationAssets.rocket; // Dashboard
      case 1: return AnimationAssets.workingHours; // Productivity
      case 2: return AnimationAssets.healthyHabits; // Health
      case 3: return AnimationAssets.successCelebration; // Rive Showcase
      case 4: return AnimationAssets.meditation; // Profile
      default: return AnimationAssets.rocket;
    }
  }

  String _getRiveFABAnimation() {
    switch (_currentIndex) {
      case 0: return RiveAnimationAssets.loadingIndicator; // Dashboard
      case 1: return RiveAnimationAssets.taskComplete; // Productivity
      case 2: return RiveAnimationAssets.mascotFlying; // Health
      case 3: return RiveAnimationAssets.downloadButton; // Rive Showcase
      case 4: return RiveAnimationAssets.avatarPack; // Profile
      default: return RiveAnimationAssets.downloadButton;
    }
  }

  String? _getNavRiveAnimation(int index) {
    switch (index) {
      case 0: return RiveAnimationAssets.progressBar; // Dashboard
      case 1: return RiveAnimationAssets.taskComplete; // Productivity
      case 2: return RiveAnimationAssets.mascotFlying; // Health
      case 3: return RiveAnimationAssets.downloadButton; // Rive Showcase
      case 4: return RiveAnimationAssets.avatarPack; // Profile
      default: return RiveAnimationAssets.downloadIcon;
    }
  }

  Color _getFABColor() {
    return _navigationTabs[_currentIndex].color;
  }

  IconData _getFABIcon() {
    switch (_currentIndex) {
      case 0: return Icons.dashboard_customize; // Dashboard
      case 1: return Icons.add_task; // Productivity
      case 2: return Icons.health_and_safety; // Health
      case 3: return Icons.explore; // Features
      case 4: return Icons.person_add; // Profile
      default: return Icons.add;
    }
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.meditation, // Real MCP Animation
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('Profile'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            AnimatedCard(
              delay: 200.ms,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade100,
                    child: AnimatedWidget(
                      assetPath: AnimationAssets.meditation, // Real MCP Animation
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HabitX User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level 15 Productivity Master',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Stats
            AnimatedCard(
              delay: 400.ms,
              child: Row(
                children: [
                  Expanded(
                    child: _buildProfileStat(
                      'Streak',
                      '45 days',
                      AnimationAssets.rocket, // Real MCP Animation
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildProfileStat(
                      'Achievements',
                      '23',
                      AnimationAssets.successCelebration, // Real MCP Animation
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildProfileStat(
                      'Points',
                      '12,450',
                      AnimationAssets.loadingSpinner, // Real MCP Animation
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Options
            ...List.generate(5, (index) {
              final options = [
                'Settings', 'Achievements', 'Statistics', 'Help & Support', 'About'
              ];
              final icons = [
                AnimationAssets.workingHours,
                AnimationAssets.successCelebration,
                AnimationAssets.loadingSpinner,
                AnimationAssets.meditation,
                AnimationAssets.rocket,
              ];
              
              return AnimatedCard(
                delay: Duration(milliseconds: 600 + (index * 100)),
                child: ListTile(
                  leading: AnimatedWidget(
                    assetPath: icons[index],
                    width: 24,
                    height: 24,
                  ),
                  title: Text(options[index]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    AnimatedSnackbar.showInfo(
                      context: context,
                      message: '${options[index]} opened!',
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, String animation, Color color) {
    return Column(
      children: [
        AnimatedWidget(
          assetPath: animation,
          width: 32,
          height: 32,
        ).animate().scale().bounce(),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Animate icons
    for (int i = 0; i < _iconControllers.length; i++) {
      if (i == index) {
        _iconControllers[i].forward();
      } else {
        _iconControllers[i].reverse();
      }
    }
    
    // Animate FAB
    _fabController.reset();
    _fabController.forward();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onFABPressed() {
    switch (_currentIndex) {
      case 0: // Dashboard
        AnimatedSnackbar.showInfo(
          context: context,
          message: '🚀 Quick Dashboard Action!',
        );
        break;
      case 1: // Productivity
        AnimatedSnackbar.showSuccess(
          context: context,
          message: '💼 New Productivity Task Created!',
        );
        break;
      case 2: // Health
        AnimatedSnackbar.showSuccess(
          context: context,
          message: '💚 Health Activity Logged!',
        );
        break;
      case 3: // Features
        AnimatedSnackbar.showInfo(
          context: context,
          message: '🎯 Exploring New Features!',
        );
        break;
      case 4: // Profile
        AnimatedSnackbar.showInfo(
          context: context,
          message: '👤 Profile Action Triggered!',
        );
        break;
    }
  }
}

class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String animationAsset;
  final Color color;

  const NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.animationAsset,
    required this.color,
  });
}
