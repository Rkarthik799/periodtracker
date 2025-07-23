// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:periodtracker/adunits.dart';
import 'package:periodtracker/entry_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppOpenAd? _appOpenAd;
  bool _adShown = false;

  @override
  void initState() {
    super.initState();

    // Wait 4 seconds before starting ad flow
    Future.delayed(const Duration(seconds: 4), () {
      _loadAndShowAppOpenAd();
    });

    // Fallback: If ad doesn't load within 8 seconds, go to home
    Future.delayed(const Duration(seconds: 8), () {
      if (!_adShown) {
        _goToHome();
      }
    });
  }

  void _loadAndShowAppOpenAd() {
    debugPrint("📢 Attempting to load App Open Ad...");
    AppOpenAd.load(
      adUnitId: AdUnits.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          debugPrint("✅ App Open Ad Loaded");
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("👋 Ad dismissed");
              ad.dispose();
              _goToHome();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Ad failed to show: $error");
              ad.dispose();
              _goToHome();
            },
          );
          ad.show();
          _adShown = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Failed to load App Open Ad: $error");
          _goToHome();
        },
      ),
    );
  }

  Future<void> _goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool('entry_complete') ?? false; // ← keep this key

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => completed ? const HomeScreen() : const EntryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset('assets/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}
