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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMraMkxkVwozFhUNDXtWH83WkMnqWK4XI',
    appId: '1:781488307737:web:247c5cfcd08d12111f3488',
    messagingSenderId: '781488307737',
    projectId: 'bubu-dudu-admin-panel',
    authDomain: 'bubu-dudu-admin-panel.firebaseapp.com',
    storageBucket: 'bubu-dudu-admin-panel.firebasestorage.app',
    measurementId: 'G-PGT3KG2QVB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMraMkxkVwozFhUNDXtWH83WkMnqWK4XI',
    appId: '1:781488307737:android:247c5cfcd08d12111f3488',
    messagingSenderId: '781488307737',
    projectId: 'bubu-dudu-admin-panel',
    storageBucket: 'bubu-dudu-admin-panel.firebasestorage.app',
  );
}
