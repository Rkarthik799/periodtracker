// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateNowBottomSheet extends StatefulWidget {
  const RateNowBottomSheet({Key? key}) : super(key: key);

  @override
  State<RateNowBottomSheet> createState() => _RateNowBottomSheetState();
}

class _RateNowBottomSheetState extends State<RateNowBottomSheet> {
  String _packageName = '';
  String _appName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageName = packageInfo.packageName;
      _appName = packageInfo.appName;
      _isLoading = false;
    });
  }

  Future<void> _rateNow() async {
    final Uri storeUrl =
        Platform.isIOS
            ? Uri.parse(
              'https://apps.apple.com/app/id6746266645',
            ) // ✅ Your App Store ID
            : Uri.parse(
              'https://play.google.com/store/apps/details?id=$_packageName',
            );

    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasRated', true);
      Navigator.of(context).pop(); // Close bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 158, 179),
            Color.fromARGB(255, 245, 73, 119),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Column(
                mainAxisSize: MainAxisSize.min, // Dynamically adjust height
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Rate 5 Stars if you like our app!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset("assets/icon.png", width: 80, height: 80),
                  const SizedBox(height: 8),
                  Text(
                    _appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your rating helps us keep delivering the best apps for you. If you love our app, please rate it 5 stars!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _rateNow,
                    icon: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0055FF),
                    ),
                    label: const Text("Rate Now"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF0055FF),
                      backgroundColor: Colors.white, // Blue text color
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Full-width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Maybe Later",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
    );
  }
}
