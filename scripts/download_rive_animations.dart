import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Script to download real Rive animations from Rive Community
/// Run this during development to fetch actual .riv files
class RiveAnimationDownloader {
  static const String assetsDir = 'assets/rive/';
  
  // Real Rive animation URLs from Rive Community
  static const Map<String, String> riveAnimations = {
    'download_button.riv': 'https://public.rive.app/community/runtime-files/8359-16034-download-button-animation.riv',
    'download_progress_bar.riv': 'https://public.rive.app/community/runtime-files/3674-7674-download-progress-bar.riv',
    'progress_bar_clean.riv': 'https://public.rive.app/community/runtime-files/6578-12753-progress-bar.riv',
    'progress_bar_gradient.riv': 'https://public.rive.app/community/runtime-files/4485-9143-progress-bar.riv',
    'progress_bar_header.riv': 'https://public.rive.app/community/runtime-files/15497-29241-progress-bar.riv',
    'mascot_flying.riv': 'https://public.rive.app/community/runtime-files/15883-29919-mascot-animation.riv',
    'avatar_pack.riv': 'https://public.rive.app/community/runtime-files/2195-4346-avatar-pack-use-case.riv',
    'loading_collection.riv': 'https://public.rive.app/community/runtime-files/8372-16070-dynamic-loading-animation-collection.riv',
    'download_icon.riv': 'https://public.rive.app/community/runtime-files/382-718-download-icon.riv',
  };

  /// Download all Rive animations
  static Future<void> downloadAllAnimations() async {
    print('🎬 Starting Rive Animation Download...');
    print('📁 Target directory: $assetsDir');
    
    // Create assets/rive directory if it doesn't exist
    final directory = Directory(assetsDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✅ Created directory: $assetsDir');
    }

    int successCount = 0;
    int failCount = 0;

    for (final entry in riveAnimations.entries) {
      final filename = entry.key;
      final url = entry.value;
      
      try {
        print('\n🔄 Downloading: $filename');
        print('   URL: $url');
        
        final success = await downloadRiveFile(url, filename);
        if (success) {
          successCount++;
          print('✅ Successfully downloaded: $filename');
        } else {
          failCount++;
          print('❌ Failed to download: $filename');
        }
      } catch (e) {
        failCount++;
        print('❌ Error downloading $filename: $e');
      }
    }

    print('\n🎯 Download Summary:');
    print('   ✅ Successful: $successCount');
    print('   ❌ Failed: $failCount');
    print('   📊 Total: ${riveAnimations.length}');
    
    if (successCount > 0) {
      print('\n🚀 Ready to use real Rive animations in HabitX!');
      await _updatePubspecWithAssets();
    }
  }

  /// Download a single Rive file
  static Future<bool> downloadRiveFile(String url, String filename) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'HabitX-RiveDownloader/1.0',
          'Accept': 'application/octet-stream, */*',
        },
      );

      if (response.statusCode == 200) {
        final file = File('$assetsDir$filename');
        await file.writeAsBytes(response.bodyBytes);
        
        // Verify file was written and has content
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
        
        // Check if Rive assets section exists
        if (!content.contains('# Real Rive Animations')) {
          // Find the assets section and add our Rive files
          final riveAssetsSection = '''
    # Real Rive Animations (Downloaded from Rive Community)
${riveAnimations.keys.map((filename) => '    - assets/rive/$filename').join('\n')}''';
          
          // Insert after the existing rive folder line
          content = content.replaceAll(
            '    - assets/rive/',
            '    - assets/rive/\n$riveAssetsSection'
          );
          
          await pubspecFile.writeAsString(content);
          print('✅ Updated pubspec.yaml with real Rive assets');
        }
      }
    } catch (e) {
      print('⚠️  Could not update pubspec.yaml: $e');
    }
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Check if Rive files are already downloaded
  static Future<bool> areAnimationsDownloaded() async {
    final directory = Directory(assetsDir);
    if (!await directory.exists()) return false;
    
    int existingFiles = 0;
    for (final filename in riveAnimations.keys) {
      final file = File('$assetsDir$filename');
      if (await file.exists()) {
        final size = await file.length();
        if (size > 0) existingFiles++;
      }
    }
    
    return existingFiles == riveAnimations.length;
  }

  /// Get download status
  static Future<Map<String, dynamic>> getDownloadStatus() async {
    final directory = Directory(assetsDir);
    final status = <String, dynamic>{
      'total': riveAnimations.length,
      'downloaded': 0,
      'missing': <String>[],
      'sizes': <String, int>{},
    };
    
    if (!await directory.exists()) {
      status['missing'] = riveAnimations.keys.toList();
      return status;
    }
    
    for (final filename in riveAnimations.keys) {
      final file = File('$assetsDir$filename');
      if (await file.exists()) {
        final size = await file.length();
        if (size > 0) {
          status['downloaded']++;
          status['sizes'][filename] = size;
        } else {
          status['missing'].add(filename);
        }
      } else {
        status['missing'].add(filename);
      }
    }
    
    return status;
  }
}

/// Main function to run the download script
void main() async {
  print('🎬 HabitX Rive Animation Downloader');
  print('=====================================');
  
  // Check current status
  final status = await RiveAnimationDownloader.getDownloadStatus();
  print('📊 Current Status:');
  print('   Total animations: ${status['total']}');
  print('   Downloaded: ${status['downloaded']}');
  print('   Missing: ${status['missing'].length}');
  
  if (status['missing'].isNotEmpty) {
    print('\n🔄 Missing animations:');
    for (final filename in status['missing']) {
      print('   - $filename');
    }
    
    print('\n🚀 Starting download...');
    await RiveAnimationDownloader.downloadAllAnimations();
  } else {
    print('\n✅ All Rive animations already downloaded!');
    print('\n📦 Downloaded files:');
    for (final entry in status['sizes'].entries) {
      final size = RiveAnimationDownloader._formatBytes(entry.value);
      print('   - ${entry.key}: $size');
    }
  }
  
  print('\n🎯 To use these animations in your Flutter app:');
  print('   1. Run: flutter pub get');
  print('   2. Import: import "package:rive/rive.dart";');
  print('   3. Use: RiveAnimation.asset("assets/rive/filename.riv")');
  print('\n🎉 Ready to create amazing interactive experiences!');
}
