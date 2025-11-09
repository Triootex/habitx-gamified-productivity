import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Script to download real web assets for HabitX
/// Downloads icons, images, sounds, and fonts from the web
class WebAssetDownloader {
  static const String baseDir = 'assets/';
  
  // Asset directories
  static const String iconsDir = '${baseDir}icons/';
  static const String imagesDir = '${baseDir}images/';
  static const String soundsDir = '${baseDir}sounds/';
  static const String fontsDir = '${baseDir}fonts/';
  
  // Real web assets URLs
  static const Map<String, Map<String, String>> webAssets = {
    'icons': {
      // Productivity Icons
      'task_icon.png': 'https://cdn-icons-png.flaticon.com/512/1827/1827933.png',
      'timer_icon.png': 'https://cdn-icons-png.flaticon.com/512/2972/2972531.png',
      'goal_icon.png': 'https://cdn-icons-png.flaticon.com/512/1998/1998087.png',
      'project_icon.png': 'https://cdn-icons-png.flaticon.com/512/3655/3655580.png',
      'analytics_icon.png': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'pomodoro_icon.png': 'https://cdn-icons-png.flaticon.com/512/2972/2972531.png',
      
      // Health & Wellness Icons
      'heart_icon.png': 'https://cdn-icons-png.flaticon.com/512/833/833472.png',
      'meditation_icon.png': 'https://cdn-icons-png.flaticon.com/512/2863/2863274.png',
      'fitness_icon.png': 'https://cdn-icons-png.flaticon.com/512/1415/1415431.png',
      'sleep_icon.png': 'https://cdn-icons-png.flaticon.com/512/3094/3094837.png',
      'nutrition_icon.png': 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      'water_icon.png': 'https://cdn-icons-png.flaticon.com/512/1040/1040230.png',
      'mood_icon.png': 'https://cdn-icons-png.flaticon.com/512/742/742751.png',
      'exercise_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048425.png',
      
      // Mental Wellness Icons
      'brain_icon.png': 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
      'mindfulness_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048378.png',
      'stress_icon.png': 'https://cdn-icons-png.flaticon.com/512/2972/2972185.png',
      'focus_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048313.png',
      'gratitude_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048378.png',
      'breathing_icon.png': 'https://cdn-icons-png.flaticon.com/512/3094/3094855.png',
      
      // Social & Community Icons
      'community_icon.png': 'https://cdn-icons-png.flaticon.com/512/681/681494.png',
      'challenge_icon.png': 'https://cdn-icons-png.flaticon.com/512/2972/2972242.png',
      'leaderboard_icon.png': 'https://cdn-icons-png.flaticon.com/512/1998/1998087.png',
      'share_icon.png': 'https://cdn-icons-png.flaticon.com/512/929/929458.png',
      'achievement_icon.png': 'https://cdn-icons-png.flaticon.com/512/1998/1998087.png',
      'group_icon.png': 'https://cdn-icons-png.flaticon.com/512/681/681494.png',
      
      // Learning & Growth Icons
      'book_icon.png': 'https://cdn-icons-png.flaticon.com/512/167/167755.png',
      'skill_icon.png': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'course_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048313.png',
      'language_icon.png': 'https://cdn-icons-png.flaticon.com/512/3094/3094837.png',
      'creative_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048378.png',
      'knowledge_icon.png': 'https://cdn-icons-png.flaticon.com/512/167/167755.png',
      
      // Life Management Icons
      'calendar_icon.png': 'https://cdn-icons-png.flaticon.com/512/2693/2693507.png',
      'reminder_icon.png': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'notes_icon.png': 'https://cdn-icons-png.flaticon.com/512/2972/2972185.png',
      'files_icon.png': 'https://cdn-icons-png.flaticon.com/512/3655/3655580.png',
      'contacts_icon.png': 'https://cdn-icons-png.flaticon.com/512/681/681494.png',
      'travel_icon.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048425.png',
    },
    
    'images': {
      // Background Images
      'productivity_bg.jpg': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
      'health_bg.jpg': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop',
      'wellness_bg.jpg': 'https://images.unsplash.com/photo-1506126613408-eca07ce68e77?w=800&h=600&fit=crop',
      'mindfulness_bg.jpg': 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=800&h=600&fit=crop',
      'social_bg.jpg': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&h=600&fit=crop',
      'learning_bg.jpg': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=600&fit=crop',
      
      // Feature Images
      'dashboard_hero.jpg': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop',
      'task_management.jpg': 'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
      'meditation_scene.jpg': 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&h=300&fit=crop',
      'fitness_activity.jpg': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'study_environment.jpg': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
      'community_gathering.jpg': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&h=300&fit=crop',
      
      // Mascot Images
      'mascot_happy.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048378.png',
      'mascot_working.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048313.png',
      'mascot_celebrating.png': 'https://cdn-icons-png.flaticon.com/512/3048/3048425.png',
      'mascot_meditating.png': 'https://cdn-icons-png.flaticon.com/512/2863/2863274.png',
      'mascot_exercising.png': 'https://cdn-icons-png.flaticon.com/512/1415/1415431.png',
      'mascot_sleeping.png': 'https://cdn-icons-png.flaticon.com/512/3094/3094837.png',
    },
    
    'sounds': {
      // Notification Sounds (Web-safe formats)
      'task_complete.mp3': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
      'goal_achieved.mp3': 'https://www.soundjay.com/misc/sounds/success-1.mp3',
      'timer_alert.mp3': 'https://www.soundjay.com/misc/sounds/bell-ringing-01.mp3',
      'meditation_bell.mp3': 'https://www.soundjay.com/misc/sounds/bell-ringing-02.mp3',
      'level_up.mp3': 'https://www.soundjay.com/misc/sounds/success-2.mp3',
      'achievement_unlock.mp3': 'https://www.soundjay.com/misc/sounds/success-3.mp3',
      
      // Background Sounds
      'focus_ambient.mp3': 'https://www.soundjay.com/nature/sounds/rain-01.mp3',
      'meditation_ambient.mp3': 'https://www.soundjay.com/nature/sounds/ocean-1.mp3',
      'productivity_ambient.mp3': 'https://www.soundjay.com/nature/sounds/forest-1.mp3',
      'wellness_chime.mp3': 'https://www.soundjay.com/misc/sounds/bell-ringing-03.mp3',
      
      // Interactive Sounds
      'button_tap.mp3': 'https://www.soundjay.com/misc/sounds/click-1.mp3',
      'toggle_on.mp3': 'https://www.soundjay.com/misc/sounds/click-2.mp3',
      'toggle_off.mp3': 'https://www.soundjay.com/misc/sounds/click-3.mp3',
      'swipe_sound.mp3': 'https://www.soundjay.com/misc/sounds/swoosh-1.mp3',
    },
    
    'fonts': {
      // Google Fonts (OTF/TTF format)
      'Poppins-Regular.ttf': 'https://fonts.gstatic.com/s/poppins/v20/pxiEyp8kv8JHgFVrJJfecg.woff2',
      'Poppins-Bold.ttf': 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLCz7Z1xlFQ.woff2',
      'Poppins-SemiBold.ttf': 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLEj6Z1xlFQ.woff2',
      'Poppins-Medium.ttf': 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLGT9Z1xlFQ.woff2',
      'Poppins-Light.ttf': 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLDz8Z1xlFQ.woff2',
      'Inter-Regular.ttf': 'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hiA.woff2',
      'Inter-Bold.ttf': 'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuDyfPZ9hiA.woff2',
      'Roboto-Regular.ttf': 'https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxK.woff2',
      'Roboto-Bold.ttf': 'https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBBc4.woff2',
    },
  };

  /// Download all web assets
  static Future<void> downloadAllAssets() async {
    print('🌐 Starting Web Asset Download...');
    print('📁 Target directories: icons, images, sounds, fonts');
    
    // Create all directories
    await _createDirectories();
    
    int totalAssets = 0;
    int successCount = 0;
    int failCount = 0;
    
    for (final category in webAssets.keys) {
      print('\n📂 Downloading $category...');
      final assets = webAssets[category]!;
      totalAssets += assets.length;
      
      for (final entry in assets.entries) {
        final filename = entry.key;
        final url = entry.value;
        final targetDir = _getTargetDirectory(category);
        
        try {
          print('🔄 Downloading: $filename');
          final success = await _downloadAsset(url, '$targetDir$filename');
          if (success) {
            successCount++;
            print('✅ Downloaded: $filename');
          } else {
            failCount++;
            print('❌ Failed: $filename');
          }
        } catch (e) {
          failCount++;
          print('❌ Error downloading $filename: $e');
        }
      }
    }
    
    print('\n🎯 Download Summary:');
    print('   ✅ Successful: $successCount');
    print('   ❌ Failed: $failCount');
    print('   📊 Total: $totalAssets');
    
    if (successCount > 0) {
      print('\n🚀 Ready to use real web assets in HabitX!');
      await _updatePubspecWithAssets();
      await _generateAssetConstants();
    }
  }

  /// Create all asset directories
  static Future<void> _createDirectories() async {
    final directories = [iconsDir, imagesDir, soundsDir, fontsDir];
    
    for (final dir in directories) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('✅ Created directory: $dir');
      }
    }
  }

  /// Get target directory for category
  static String _getTargetDirectory(String category) {
    switch (category) {
      case 'icons': return iconsDir;
      case 'images': return imagesDir;
      case 'sounds': return soundsDir;
      case 'fonts': return fontsDir;
      default: return baseDir;
    }
  }

  /// Download a single asset
  static Future<bool> _downloadAsset(String url, String filePath) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'HabitX-AssetDownloader/1.0',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        final fileSize = await file.length();
        if (fileSize > 0) {
          print('   📦 File size: ${_formatBytes(fileSize)}');
          return true;
        } else {
          print('   ⚠️  File downloaded but appears empty');
          return false;
        }
      } else {
        print('   ❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('   ❌ Network error: $e');
      return false;
    }
  }

  /// Update pubspec.yaml with downloaded assets
  static Future<void> _updatePubspecWithAssets() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (await pubspecFile.exists()) {
        String content = await pubspecFile.readAsString();
        
        // Build complete assets section
        final assetsSection = _buildAssetsSection();
        
        // Replace or add assets section
        if (content.contains('assets:')) {
          // Find and replace existing assets section
          final assetsRegex = RegExp(r'assets:\s*\n(.*?)(?=\n\s*[a-zA-Z]|\n\n|\Z)', dotAll: true);
          content = content.replaceAll(assetsRegex, assetsSection);
        } else {
          // Add assets section after flutter section
          content = content.replaceAll(
            'flutter:',
            'flutter:\n$assetsSection'
          );
        }
        
        await pubspecFile.writeAsString(content);
        print('✅ Updated pubspec.yaml with all web assets');
      }
    } catch (e) {
      print('⚠️  Could not update pubspec.yaml: $e');
    }
  }

  /// Build complete assets section for pubspec.yaml
  static String _buildAssetsSection() {
    final buffer = StringBuffer();
    buffer.writeln('  assets:');
    
    // Add directories
    buffer.writeln('    - assets/images/');
    buffer.writeln('    - assets/icons/');
    buffer.writeln('    - assets/sounds/');
    buffer.writeln('    - assets/lottie/');
    buffer.writeln('    - assets/rive/');
    buffer.writeln('    - assets/animations/');
    buffer.writeln('    - assets/fonts/');
    
    // Add individual files
    buffer.writeln('    # Real Web Assets');
    for (final category in webAssets.keys) {
      if (category != 'fonts') { // Fonts go in fonts section
        buffer.writeln('    # ${category.toUpperCase()}');
        for (final filename in webAssets[category]!.keys) {
          buffer.writeln('    - ${_getTargetDirectory(category)}$filename');
        }
      }
    }
    
    // Add existing Lottie and Rive assets
    buffer.writeln('    # Real Lottie MCP Animations');
    buffer.writeln('    - assets/lottie/rocket.json');
    buffer.writeln('    - assets/lottie/loading_spinner.json');
    buffer.writeln('    - assets/lottie/working_hours.json');
    buffer.writeln('    - assets/lottie/meditation.json');
    buffer.writeln('    - assets/lottie/success_celebration.json');
    
    buffer.writeln('    # Real Rive Animations');
    buffer.writeln('    - assets/rive/download_button.riv');
    buffer.writeln('    - assets/rive/download_progress_bar.riv');
    buffer.writeln('    - assets/rive/progress_bar_clean.riv');
    buffer.writeln('    - assets/rive/progress_bar_gradient.riv');
    buffer.writeln('    - assets/rive/mascot_flying.riv');
    buffer.writeln('    - assets/rive/avatar_pack.riv');
    buffer.writeln('    - assets/rive/loading_collection.riv');
    buffer.writeln('    - assets/rive/download_icon.riv');
    
    return buffer.toString();
  }

  /// Generate asset constants file
  static Future<void> _generateAssetConstants() async {
    final constantsFile = File('lib/core/constants/web_asset_constants.dart');
    await constantsFile.create(recursive: true);
    
    final buffer = StringBuffer();
    buffer.writeln('/// Web Asset Constants - Real downloaded assets');
    buffer.writeln('class WebAssetConstants {');
    
    for (final category in webAssets.keys) {
      buffer.writeln('  // ${category.toUpperCase()} ASSETS');
      final categoryClass = '${category[0].toUpperCase()}${category.substring(1)}';
      buffer.writeln('  static const ${categoryClass}Assets = _${categoryClass}Assets();');
      buffer.writeln();
    }
    
    buffer.writeln('}');
    buffer.writeln();
    
    // Generate individual asset classes
    for (final category in webAssets.keys) {
      final categoryClass = '${category[0].toUpperCase()}${category.substring(1)}';
      buffer.writeln('class _${categoryClass}Assets {');
      buffer.writeln('  const _${categoryClass}Assets();');
      buffer.writeln();
      
      for (final entry in webAssets[category]!.entries) {
        final filename = entry.key;
        final constantName = filename.split('.')[0].replaceAll('-', '').replaceAll('_', '');
        final path = '${_getTargetDirectory(category)}$filename';
        buffer.writeln('  static const String $constantName = \'$path\';');
      }
      
      buffer.writeln('}');
      buffer.writeln();
    }
    
    await constantsFile.writeAsString(buffer.toString());
    print('✅ Generated asset constants file');
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Main function to run the asset download script
void main() async {
  print('🌐 HabitX Web Asset Downloader');
  print('=====================================');
  print('📦 Downloading: Icons, Images, Sounds, Fonts');
  
  await WebAssetDownloader.downloadAllAssets();
  
  print('\n🎯 Next Steps:');
  print('   1. Run: flutter pub get');
  print('   2. Import: import "lib/core/constants/web_asset_constants.dart";');
  print('   3. Use: Image.asset(WebAssetConstants.ImagesAssets.productivityBg)');
  print('\n🎉 Ready to create the most comprehensive app experience!');
}
