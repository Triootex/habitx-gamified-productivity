import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import '../utils/logger.dart';

@singleton
class FirebaseManager {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;
  late final FirebaseRemoteConfig _remoteConfig;
  late final FirebaseMessaging _messaging;

  // Getters for Firebase services
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;
  FirebaseMessaging get messaging => _messaging;

  /// Initialize all Firebase services
  Future<void> initialize() async {
    try {
      Logger.info('Initializing Firebase services...');

      // Initialize Auth
      _auth = FirebaseAuth.instance;
      Logger.info('Firebase Auth initialized');

      // Initialize Firestore
      _firestore = FirebaseFirestore.instance;
      Logger.info('Cloud Firestore initialized');

      // Initialize Storage
      _storage = FirebaseStorage.instance;
      Logger.info('Firebase Storage initialized');

      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;
      await _analytics.setAnalyticsCollectionEnabled(true);
      Logger.info('Firebase Analytics initialized');

      // Initialize Crashlytics
      _crashlytics = FirebaseCrashlytics.instance;
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      Logger.info('Firebase Crashlytics initialized');

      // Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _initializeRemoteConfig();
      Logger.info('Firebase Remote Config initialized');

      // Initialize Cloud Messaging
      _messaging = FirebaseMessaging.instance;
      await _initializeMessaging();
      Logger.info('Firebase Cloud Messaging initialized');

      Logger.info('All Firebase services initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Firebase services: $e');
      rethrow;
    }
  }

  /// Initialize Remote Config with default values
  Future<void> _initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults({
        'feature_social_enabled': true,
        'feature_premium_enabled': true,
        'max_free_habits': 10,
        'xp_multiplier_easy': 1.0,
        'xp_multiplier_medium': 1.5,
        'xp_multiplier_hard': 2.0,
        'daily_reset_hour': 0,
        'streak_bonus_multiplier': 1.2,
        'show_tutorial_onboarding': true,
        'maintenance_mode': false,
      });

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      Logger.error('Failed to initialize Remote Config: $e');
    }
  }

  /// Initialize Cloud Messaging
  Future<void> _initializeMessaging() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info('User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Logger.info('User granted provisional notification permissions');
      } else {
        Logger.info('User declined or has not accepted notification permissions');
      }

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        Logger.info('FCM Token: $token');
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((token) {
        Logger.info('FCM Token refreshed: $token');
      });
    } catch (e) {
      Logger.error('Failed to initialize Cloud Messaging: $e');
    }
  }

  /// Check if Firebase is properly initialized
  bool get isInitialized {
    try {
      // Try to access a Firebase service
      final app = Firebase.app();
      return app.options.apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current Firebase app
  FirebaseApp get app {
    return Firebase.app();
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Logger.info('User signed out successfully');
    } catch (e) {
      Logger.error('Failed to sign out user: $e');
      rethrow;
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if user is authenticated
  bool get isUserAuthenticated {
    return _auth.currentUser != null;
  }

  /// Get current user
  User? get currentUser {
    return _auth.currentUser;
  }

  /// Reload user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      Logger.error('Failed to reload user: $e');
    }
  }
}