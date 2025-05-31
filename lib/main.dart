import 'package:fantadiv/viewmodels/calendar_viewmodel.dart';
import 'package:fantadiv/viewmodels/file_picker_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'firebase_options.dart';
import 'view/homepage.dart';
import 'view/login_page.dart';

late final String firebaseSource;


void main() async {
  print('🚀 Inizio main()');
  log('🚀 Inizio main()');

  WidgetsFlutterBinding.ensureInitialized();
  print('✅ WidgetsFlutterBinding done');
  log('✅ WidgetsFlutterBinding done');

  try {
    if (kIsWeb) {
      print('🌐 Rilevato Web');
      log('🌐 Rilevato Web');

      firebaseSource = 'Firebase Web API';
      print('🔄 Inizializzazione Firebase Web...');
      log('🔄 Inizializzazione Firebase Web...');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );

      print('✅ Firebase Web inizializzato con successo');
      log('✅ Firebase Web inizializzato con successo');
    } else {
      print('📱 Rilevato Mobile');
      log('📱 Rilevato Mobile');

      firebaseSource = 'Firebase Mobile API';
      print('🔄 Inizializzazione Firebase Mobile...');
      log('🔄 Inizializzazione Firebase Mobile...');

      await Firebase.initializeApp();

      print('✅ Firebase Mobile inizializzato con successo');
      log('✅ Firebase Mobile inizializzato con successo');
    }
  } catch (e, stackTrace) {
    firebaseSource = 'Errore Firebase Init';
    print('❌ Errore durante Firebase.initializeApp: $e');
    log('❌ Errore durante Firebase.initializeApp: $e', stackTrace: stackTrace);
  }

  print('🏁 Chiamo runApp()');
  log('🏁 Chiamo runApp()');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => FilePickerViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Stack(
        children: [
          const AuthWrapper(),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                firebaseSource,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
