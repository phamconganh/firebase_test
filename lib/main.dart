import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/home_page.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const RemoteConfigApp());
    },
    recordError,
  );
}

void recordError(dynamic exception, StackTrace? stack) {
  print(exception);
}

class RemoteConfigApp extends StatelessWidget {
  const RemoteConfigApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Config Example',
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}
