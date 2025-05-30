import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyD2OMttcjwaq4zVc52U4C4y3hKpr8yUmqY",
    authDomain: "fantadiv.firebaseapp.com",
    projectId: "fantadiv",
    storageBucket: "fantadiv.appspot.com",
    messagingSenderId: "244659699647",
    appId: "1:244659699647:web:de45d77f0af231a7ef2b0a",
    measurementId: "G-7Q3WSKR59B",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyA6cKleRATqDMbD3kmnEYzChMuIf1pAMak",
    appId: "1:244659699647:android:3ccc0576848630e0ef2b0a",
    messagingSenderId: "244659699647",
    projectId: "fantadiv",
    storageBucket: "fantadiv.appspot.com",
  );
}
