import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for different platforms.
/// 
/// IMPORTANT: Replace the placeholder values below with your actual Firebase
/// project configuration. You can get these values from:
/// 1. Go to https://console.firebase.google.com/
/// 2. Create a new project or select existing one
/// 3. Add a Web app to your project
/// 4. Copy the configuration values
/// 
/// For detailed setup instructions, see:
/// https://firebase.google.com/docs/flutter/setup
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

  // ============================================================
  // 🔥 REPLACE THESE VALUES WITH YOUR FIREBASE PROJECT CONFIG
  // ============================================================
  // 
  // To get your Firebase configuration:
  // 1. Go to Firebase Console: https://console.firebase.google.com/
  // 2. Create a new project (or use existing)
  // 3. Click "Add app" and select Web (</>)
  // 4. Register your app with a nickname
  // 5. Copy the firebaseConfig values below
  // 
  // ============================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBcdSgVRPAZIrz1WdpPy9yRtItU2o8X3iw',
    appId: '1:912684194110:web:3a5162a0bb1fd0d2bff46f',
    messagingSenderId: '912684194110',
    projectId: 'insurance-claim-app-gk',
    authDomain: 'insurance-claim-app-gk.firebaseapp.com',
    storageBucket: 'insurance-claim-app-gk.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBMlDzG5jyK8M-17aiF38cqfWsE8_RJ2Q',
    appId: '1:912684194110:android:4d4995f2435b4ebebff46f',
    messagingSenderId: '912684194110',
    projectId: 'insurance-claim-app-gk',
    storageBucket: 'insurance-claim-app-gk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE',
    appId: 'YOUR_IOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_PROJECT_ID_HERE.appspot.com',
    iosBundleId: 'com.example.insuranceClaimApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY_HERE',
    appId: 'YOUR_MACOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_PROJECT_ID_HERE.appspot.com',
    iosBundleId: 'com.example.insuranceClaimApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY_HERE',
    appId: 'YOUR_WINDOWS_APP_ID_HERE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'YOUR_PROJECT_ID_HERE',
    storageBucket: 'YOUR_PROJECT_ID_HERE.appspot.com',
  );
}