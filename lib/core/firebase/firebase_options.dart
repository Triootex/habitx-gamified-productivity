import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration for HabitX
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habitx-productivity-app',
    authDomain: 'habitx-productivity-app.firebaseapp.com',
    storageBucket: 'habitx-productivity-app.appspot.com',
    measurementId: 'your-measurement-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habitx-productivity-app',
    storageBucket: 'habitx-productivity-app.appspot.com',
    measurementId: 'your-measurement-id',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habitx-productivity-app',
    storageBucket: 'habitx-productivity-app.appspot.com',
    iosBundleId: 'com.habitx.app',
    measurementId: 'your-measurement-id',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habitx-productivity-app',
    storageBucket: 'habitx-productivity-app.appspot.com',
    iosBundleId: 'com.habitx.app',
    measurementId: 'your-measurement-id',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'habitx-productivity-app',
    authDomain: 'habitx-productivity-app.firebaseapp.com',
    storageBucket: 'habitx-productivity-app.appspot.com',
    measurementId: 'your-measurement-id',
  );
}