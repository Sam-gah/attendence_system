// File generated by FlutterFire CLI.
// This file is a placeholder. You need to replace it with the actual configuration.
// To generate this file:
// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
// 2. Run: flutterfire configure --project=your-firebase-project-id

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        // Use Android configuration for Linux
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs-3gEhOpi8oy_V8MdtJmGIJR5B5Rnl-Y',
    appId: '1:360438571030:web:ffb6b76fd2a99fb5ed1537',
    messagingSenderId: '360438571030',
    projectId: 'attendence-bichitras-c89ef',
    authDomain: 'attendence-bichitras-c89ef.firebaseapp.com',
    storageBucket: 'attendence-bichitras-c89ef.firebasestorage.app',
    measurementId: 'G-0XQ088KR0Y',
  );

  // REPLACE THESE PLACEHOLDERS WITH YOUR ACTUAL FIREBASE CONFIGURATION VALUES

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARxDVnO-aCm0csrfQLYye1KPGAHQZNl0w',
    appId: '1:360438571030:android:e7dae32ac676a708ed1537',
    messagingSenderId: '360438571030',
    projectId: 'attendence-bichitras-c89ef',
    storageBucket: 'attendence-bichitras-c89ef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKfyh3IqVhL9sI3GsqPezG-EjqLbcsdBs',
    appId: '1:360438571030:ios:d8009779355caeb4ed1537',
    messagingSenderId: '360438571030',
    projectId: 'attendence-bichitras-c89ef',
    storageBucket: 'attendence-bichitras-c89ef.firebasestorage.app',
    iosClientId: '360438571030-5e6534nmjofoinstb60spbejvc4iq2ln.apps.googleusercontent.com',
    iosBundleId: 'com.example.attendenceSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
} 