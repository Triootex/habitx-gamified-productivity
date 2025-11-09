/// Real Rive Animation URLs from Rive Community
/// These are direct download links to actual .riv files
class RealRiveAnimations {
  // ===== REAL RIVE ANIMATION DOWNLOAD URLS =====
  // From Rive Community - Free Licensed Animations
  
  // Button & Interactive Elements
  static const String downloadButtonAnimation = 'https://public.rive.app/community/runtime-files/8359-16034-download-button-animation.riv';
  static const String downloadIcon = 'https://public.rive.app/community/runtime-files/382-718-download-icon.riv';
  static const String downloadProgressBar = 'https://public.rive.app/community/runtime-files/3674-7674-download-progress-bar.riv';
  
  // Progress & Loading Animations
  static const String progressBar1 = 'https://public.rive.app/community/runtime-files/6578-12753-progress-bar.riv';
  static const String progressBar2 = 'https://public.rive.app/community/runtime-files/4485-9143-progress-bar.riv';
  static const String progressBar3 = 'https://public.rive.app/community/runtime-files/15497-29241-progress-bar.riv';
  static const String dynamicLoadingCollection = 'https://public.rive.app/community/runtime-files/8372-16070-dynamic-loading-animation-collection.riv';
  
  // Character & Mascot Animations  
  static const String mascotAnimation = 'https://public.rive.app/community/runtime-files/15883-29919-mascot-animation.riv';
  static const String avatarPack = 'https://public.rive.app/community/runtime-files/2195-4346-avatar-pack-use-case.riv';
  
  // State Machine Names (for interactive controls)
  static const String downloadButtonSM = 'Download Animation';
  static const String progressBarSM = 'State Machine 1';
  static const String mascotSM = 'Fly super';
  static const String avatarSM = 'avatar';
  
  // Artboard Names
  static const String downloadButtonArtboard = 'Download';
  static const String progressBarArtboard = 'DownloadIcon';
  static const String mascotArtboard = 'Artboard';
  static const String avatarArtboard = 'Avatar 1';
  
  // Animation Names
  static const String downloadAnim = 'Download Animation';
  static const String downloadIconAnim = 'DownloadIcon SM';
  static const String mascotFly = 'Fly super';
  static const String avatarIdle = 'idle';
  
  // Helper method to get all available real Rive animations
  static Map<String, RiveAnimationData> getAllRealAnimations() {
    return {
      'download_button': RiveAnimationData(
        url: downloadButtonAnimation,
        artboard: downloadButtonArtboard,
        stateMachine: downloadButtonSM,
        animation: downloadAnim,
        category: 'Interactive',
        description: 'Sophisticated download button with smooth animations',
        license: 'CC BY',
      ),
      'download_progress': RiveAnimationData(
        url: downloadProgressBar,
        artboard: progressBarArtboard,
        stateMachine: downloadIconAnim,
        animation: downloadIconAnim,
        category: 'Progress',
        description: 'Download progress bar with pause/resume states',
        license: 'CC BY',
      ),
      'progress_bar_1': RiveAnimationData(
        url: progressBar1,
        artboard: 'Artboard',
        stateMachine: progressBarSM,
        animation: 'progress',
        category: 'Progress',
        description: 'Clean progress bar animation',
        license: 'CC BY',
      ),
      'progress_bar_2': RiveAnimationData(
        url: progressBar2,
        artboard: 'Artboard',
        stateMachine: progressBarSM,
        animation: 'progress',
        category: 'Progress',
        description: 'Smooth progress bar with gradient',
        license: 'CC BY',
      ),
      'mascot_character': RiveAnimationData(
        url: mascotAnimation,
        artboard: mascotArtboard,
        stateMachine: mascotSM,
        animation: mascotFly,
        category: 'Character',
        description: 'Flying mascot character animation',
        license: 'CC BY',
      ),
      'avatar_pack': RiveAnimationData(
        url: avatarPack,
        artboard: avatarArtboard,
        stateMachine: avatarSM,
        animation: avatarIdle,
        category: 'Character',
        description: 'Interactive avatar with multiple states',
        license: 'CC BY',
      ),
      'loading_collection': RiveAnimationData(
        url: dynamicLoadingCollection,
        artboard: 'Artboard',
        stateMachine: 'State Machine 1',
        animation: 'loading',
        category: 'Loading',
        description: 'Collection of dynamic loading animations',
        license: 'CC BY',
      ),
    };
  }
  
  // Get animations by category
  static List<RiveAnimationData> getAnimationsByCategory(String category) {
    return getAllRealAnimations()
        .values
        .where((anim) => anim.category == category)
        .toList();
  }
  
  // Get all categories
  static List<String> getAllCategories() {
    return getAllRealAnimations()
        .values
        .map((anim) => anim.category)
        .toSet()
        .toList();
  }
}

/// Data class to hold Rive animation information
class RiveAnimationData {
  final String url;
  final String artboard;
  final String stateMachine;
  final String animation;
  final String category;
  final String description;
  final String license;
  
  const RiveAnimationData({
    required this.url,
    required this.artboard,
    required this.stateMachine,
    required this.animation,
    required this.category,
    required this.description,
    required this.license,
  });
  
  // Convert to local asset path (after download)
  String get localAssetPath {
    final filename = url.split('/').last;
    return 'assets/rive/$filename';
  }
  
  // Get animation ID from URL
  String get animationId {
    final parts = url.split('/').last.split('-');
    return parts.length >= 2 ? '${parts[0]}-${parts[1]}' : parts[0];
  }
}

/// Categories for organizing Rive animations
class RiveCategories {
  static const String interactive = 'Interactive';
  static const String progress = 'Progress';
  static const String character = 'Character';
  static const String loading = 'Loading';
  static const String ui = 'UI';
  static const String feedback = 'Feedback';
}
