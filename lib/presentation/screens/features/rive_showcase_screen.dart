import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';
import '../../widgets/universal_animated_widgets.dart';
import '../../widgets/rive_animated_widgets.dart';
import '../../widgets/comprehensive_asset_widgets.dart';
import '../../../core/animations/rive_animation_assets.dart';
import '../../../core/animations/real_rive_animations.dart';
import '../../../core/constants/web_asset_constants.dart';
import '../../../core/animations/animation_assets.dart';

class RiveShowcaseScreen extends ConsumerStatefulWidget {
  const RiveShowcaseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RiveShowcaseScreen> createState() => _RiveShowcaseScreenState();
}

class _RiveShowcaseScreenState extends ConsumerState<RiveShowcaseScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerController;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'Interactive',
    'Progress',
    'Character',
    'Loading',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
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
                _buildCategorySelector(),
                _buildRiveShowcase(),
                _buildInteractiveDemo(),
                _buildImplementationGuide(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: _showRiveInfo,
        animationAsset: RiveAnimationAssets.downloadIcon,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.play_arrow, color: Colors.white),
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
            // Use real Rive animation in app bar
            SizedBox(
              width: 30,
              height: 30,
              child: RiveAnimatedWidget(
                assetPath: RiveAnimationAssets.mascotFlying,
                autoplay: true,
                loop: true,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Rive Showcase'),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade600,
                Colors.purple.shade400,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Rive animations
              Positioned(
                top: 80,
                right: 20,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: RiveAnimatedWidget(
                    assetPath: RiveAnimationAssets.loadingIndicator,
                    autoplay: true,
                    loop: true,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
              Positioned(
                top: 120,
                left: 30,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: RiveAnimatedWidget(
                    assetPath: RiveAnimationAssets.avatarPack,
                    autoplay: true,
                    loop: true,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).rotate(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return AnimatedCard(
      delay: 200.ms,
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedCategory == index;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: RiveInteractiveButton(
                  assetPath: RiveAnimationAssets.downloadButton,
                  width: 120,
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRiveShowcase() {
    final animations = RealRiveAnimations.getAnimationsByCategory(
      _categories[_selectedCategory]
    );

    return AnimatedCard(
      delay: 400.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_categories[_selectedCategory]} Animations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: animations.length,
            itemBuilder: (context, index) {
              final animation = animations[index];
              return _buildRiveAnimationCard(animation, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiveAnimationCard(RiveAnimationData animation, int index) {
    return RiveAnimatedCard(
      delay: Duration(milliseconds: 500 + (index * 100)),
      onTap: () => _showAnimationDetails(animation),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RiveAnimation.network(
                animation.url,
                artboard: animation.artboard,
                animations: [animation.animation],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            animation.animationId,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            animation.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              animation.license,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveDemo() {
    return AnimatedCard(
      delay: 600.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Rive Components',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Interactive Progress Bar
          Row(
            children: [
              const Text('Progress: '),
              Expanded(
                child: RiveProgressBar(
                  assetPath: RiveAnimationAssets.progressBar,
                  progress: 0.7,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('70%'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Interactive Toggle
          Row(
            children: [
              const Text('Toggle Switch: '),
              RiveToggleSwitch(
                assetPath: RiveAnimationAssets.toggleSwitch,
                value: true,
                width: 60,
                height: 30,
                onChanged: (value) {
                  AnimatedSnackbar.showInfo(
                    context: context,
                    message: 'Toggle switched to ${value ? "ON" : "OFF"}',
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Interactive Button
          Center(
            child: RiveInteractiveButton(
              assetPath: RiveAnimationAssets.downloadButton,
              width: 200,
              height: 60,
              onPressed: () {
                AnimatedSnackbar.showSuccess(
                  context: context,
                  message: 'Rive button pressed! 🎉',
                );
              },
              child: const Text(
                'Interactive Rive Button',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationGuide() {
    return AnimatedCard(
      delay: 800.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Implementation Guide',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📁 Real Rive Files Downloaded:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...RealRiveAnimations.getAllRealAnimations().keys.map(
                  (key) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $key.riv'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '💻 Usage in Code:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '''RiveAnimatedWidget(
  assetPath: RiveAnimationAssets.downloadButton,
  width: 100,
  height: 100,
  autoplay: true,
  loop: true,
)''',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnimationDetails(RiveAnimationData animation) {
    AnimatedDialog.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: RiveAnimation.network(
                animation.url,
                artboard: animation.artboard,
                animations: [animation.animation],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              animation.animationId,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              animation.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${animation.category}'),
                  Text('License: ${animation.license}'),
                  Text('Artboard: ${animation.artboard}'),
                  Text('Animation: ${animation.animation}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.purple,
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRiveInfo() {
    AnimatedSnackbar.showInfo(
      context: context,
      message: '🎬 Real Rive animations downloaded and integrated!',
    );
  }
}
