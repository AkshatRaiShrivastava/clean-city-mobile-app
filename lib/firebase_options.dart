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
    apiKey: 'AIzaSyDY9pec0pY3y-rEGixMNbLdsG39Y4mjfW0',
    appId: '1:945788378062:web:c31fe1f8f0882f53d3699f',
    messagingSenderId: '945788378062',
    projectId: 'clean-city-75895',
    authDomain: 'clean-city-75895.firebaseapp.com',
    storageBucket: 'clean-city-75895.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtdfnGAAYcj9IrdOLSmLF3UHu0cX81WDA',
    appId: '1:945788378062:android:de051f036b609ec3d3699f',
    messagingSenderId: '945788378062',
    projectId: 'clean-city-75895',
    storageBucket: 'clean-city-75895.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDP-hxulsefmLLRKutlPox-i0YB7GkOZiw',
    appId: '1:945788378062:ios:1de602f50204b15cd3699f',
    messagingSenderId: '945788378062',
    projectId: 'clean-city-75895',
    storageBucket: 'clean-city-75895.firebasestorage.app',
    iosBundleId: 'com.example.cleancity',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDP-hxulsefmLLRKutlPox-i0YB7GkOZiw',
    appId: '1:945788378062:ios:1de602f50204b15cd3699f',
    messagingSenderId: '945788378062',
    projectId: 'clean-city-75895',
    storageBucket: 'clean-city-75895.firebasestorage.app',
    iosBundleId: 'com.example.cleancity',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDY9pec0pY3y-rEGixMNbLdsG39Y4mjfW0',
    appId: '1:945788378062:web:ab553b99562f632fd3699f',
    messagingSenderId: '945788378062',
    projectId: 'clean-city-75895',
    authDomain: 'clean-city-75895.firebaseapp.com',
    storageBucket: 'clean-city-75895.firebasestorage.app',
  );
}
