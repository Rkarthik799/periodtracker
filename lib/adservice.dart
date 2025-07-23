// ignore_for_file: avoid_print

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adunits.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  // Set cooldown to 40 seconds.
  static const int adCooldownSeconds = 30;

  /// Loads the interstitial ad.
  static Future<void> loadInterstitialAd() async {
    if (_interstitialAd != null) {
      print(
        "Goldratelogs: Interstitial ad is already loaded. Not loading a new one.",
      );
      return;
    }
    print(
      "Goldratelogs: Loading interstitial ad using unit id: ${AdUnits.interstitialAdUnitId}",
    );
    InterstitialAd.load(
      adUnitId:
          AdUnits.interstitialAdUnitId, // Use your interstitial ad unit ID.
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print("Goldratelogs: Interstitial ad loaded successfully.");
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Goldratelogs: Interstitial ad failed to load: $error");
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows the interstitial ad if the cooldown period (40 seconds) has passed.
  /// Otherwise, immediately calls [onAdClosed].
  static Future<void> showInterstitialAd({required Function onAdClosed}) async {
    final prefs = await SharedPreferences.getInstance();
    final adTimestampStr = prefs.getString('ad_close_timestamp');
    DateTime lastAdClose = DateTime.fromMillisecondsSinceEpoch(0);
    if (adTimestampStr != null) {
      lastAdClose =
          DateTime.tryParse(adTimestampStr) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    final now = DateTime.now();
    print(
      "Goldratelogs: Checking ad cooldown: now: $now, lastAdClose: $lastAdClose, diff: ${now.difference(lastAdClose).inSeconds} seconds",
    );

    // If less than 40 seconds have passed or the ad isn't loaded, call the callback.
    if (now.difference(lastAdClose).inSeconds < adCooldownSeconds ||
        _interstitialAd == null) {
      print(
        "Goldratelogs: Cooldown not passed or ad not available. Calling onAdClosed immediately.",
      );
      onAdClosed();
      return;
    }

    // Setup callbacks for the full-screen ad.
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) async {
        print("Goldratelogs: Interstitial ad dismissed.");
        ad.dispose();
        _interstitialAd = null; // Set to null so a new ad can be loaded.
        await prefs.setString(
          'ad_close_timestamp',
          DateTime.now().toIso8601String(),
        );
        onAdClosed();
        loadInterstitialAd(); // Load a fresh ad after closing.
      },
      onAdFailedToShowFullScreenContent: (
        InterstitialAd ad,
        AdError error,
      ) async {
        print("Goldratelogs: Interstitial ad failed to show: $error");
        ad.dispose();
        _interstitialAd = null; // Set to null so a new ad can be loaded.
        await prefs.setString(
          'ad_close_timestamp',
          DateTime.now().toIso8601String(),
        );
        onAdClosed();
        loadInterstitialAd();
      },
    );
    print("Goldratelogs: Showing interstitial ad now.");
    _interstitialAd!.show();
  }
}
