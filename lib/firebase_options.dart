// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCfsTNvBvfu1ok4tUXjQ8dWC4eCqGeclHk',
    appId: '1:931344943785:web:8452e90ec9b2f90b68b7b8',
    messagingSenderId: '931344943785',
    projectId: 'ea-connect-4f65f',
    authDomain: 'ea-connect-4f65f.firebaseapp.com',
    storageBucket: 'ea-connect-4f65f.firebasestorage.app',
    measurementId: 'G-XDP9D3DLNS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNH65OpvSSGs0MccxzF0TVXcAcB0T-Shk',
    appId: '1:931344943785:android:6b11bbc4f16df50968b7b8',
    messagingSenderId: '931344943785',
    projectId: 'ea-connect-4f65f',
    storageBucket: 'ea-connect-4f65f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQHcN86w5xV4bNpWzgpnrjuyE49onIq_I',
    appId: '1:931344943785:ios:be656ce9af2520a868b7b8',
    messagingSenderId: '931344943785',
    projectId: 'ea-connect-4f65f',
    storageBucket: 'ea-connect-4f65f.firebasestorage.app',
    iosBundleId: 'com.example.eaConnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQHcN86w5xV4bNpWzgpnrjuyE49onIq_I',
    appId: '1:931344943785:ios:be656ce9af2520a868b7b8',
    messagingSenderId: '931344943785',
    projectId: 'ea-connect-4f65f',
    storageBucket: 'ea-connect-4f65f.firebasestorage.app',
    iosBundleId: 'com.example.eaConnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCfsTNvBvfu1ok4tUXjQ8dWC4eCqGeclHk',
    appId: '1:931344943785:web:8452e90ec9b2f90b68b7b8',
    messagingSenderId: '931344943785',
    projectId: 'ea-connect-4f65f',
    authDomain: 'ea-connect-4f65f.firebaseapp.com',
    storageBucket: 'ea-connect-4f65f.firebasestorage.app',
    measurementId: 'G-XDP9D3DLNS',
  );
}
