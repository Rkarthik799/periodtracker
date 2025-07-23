import 'dart:io';
import 'package:flutter/foundation.dart';

class AdUnits {
  // Android Live ids
  static const String _androidAppOpenAdUnitId =
      'ca-app-pub-5787710865160187/7531584583';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-5787710865160187/2171446690';

  // iOS Live ids
  static const String _iosAppOpenAdUnitId =
      'ca-app-pub-5787710865160187/9195661253';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-5787710865160187/8306069650';

  // You mentioned multiple interstitials for iOS in comments. If you plan to use different ones for different parts of your app,
  // you can add additional getters or parameters. For now, we'll use the main one for all interstitial placements.

  // Test ids (common for all interstitials)
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Returns the correct App Open Ad Unit ID based on platform.
  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return _testAppOpenAdUnitId;
    }
    if (Platform.isAndroid) {
      return _androidAppOpenAdUnitId;
    } else if (Platform.isIOS) {
      return _iosAppOpenAdUnitId;
    }
    // Fallback to test id if platform is unknown
    return _testAppOpenAdUnitId;
  }

  /// Returns the correct Interstitial Ad Unit Id based on the device and build mode.
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    }
    // Fallback to test id if platform is unknown
    return _testInterstitialAdUnitId;
  }
}
