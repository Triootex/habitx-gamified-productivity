import 'dart:developer' as developer;

/// Simple logging utility for HabitX app
class Logger {
  static const String _tag = 'HabitX';

  static void debug(String message, [String? tag]) {
    developer.log(
      '🔍 $message',
      name: tag ?? _tag,
      time: DateTime.now(),
    );
  }

  static void info(String message, [String? tag]) {
    developer.log(
      'ℹ️ $message',
      name: tag ?? _tag,
      time: DateTime.now(),
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      '⚠️ $message',
      name: tag ?? _tag,
      time: DateTime.now(),
      level: 500,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      '❌ $message',
      name: tag ?? _tag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void success(String message, [String? tag]) {
    developer.log(
      '✅ $message',
      name: tag ?? _tag,
      time: DateTime.now(),
    );
  }
}