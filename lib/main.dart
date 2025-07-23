// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:periodtracker/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:periodtracker/home.dart';
import 'package:periodtracker/entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hera Period Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
