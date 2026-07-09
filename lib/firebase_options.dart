import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzJEFM8AbkzmExAPQ5P-BxcuRpzjCJbx8',
    appId: '1:761138702242:android:5e8f0150a97fbcb0d074fb',
    messagingSenderId: '761138702242',
    projectId: 'carecompanion-4c1a8',
    storageBucket: 'carecompanion-4c1a8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzJEFM8AbkzmExAPQ5P-BxcuRpzjCJbx8',
    appId: '1:761138702242:ios:a1b2c3d4e5f678901234567',
    messagingSenderId: '761138702242',
    projectId: 'carecompanion-4c1a8',
    storageBucket: 'carecompanion-4c1a8.firebasestorage.app',
    iosBundleId: 'com.example.caregiverApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzJEFM8AbkzmExAPQ5P-BxcuRpzjCJbx8',
    appId: '1:761138702242:android:5e8f0150a97fbcb0d074fb',
    messagingSenderId: '761138702242',
    projectId: 'carecompanion-4c1a8',
    storageBucket: 'carecompanion-4c1a8.firebasestorage.app',
  );
}
