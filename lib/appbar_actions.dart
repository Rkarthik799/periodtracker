// appbar_actions.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:periodtracker/developer_apps_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class AppBarActions extends StatelessWidget {
  final String packageName;

  const AppBarActions({Key? key, required this.packageName}) : super(key: key);

  // Launches a URL using url_launcher.
  Future<void> launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Shares the app's Google Play link using share_plus.
  void shareApp(BuildContext context) {
    String shareLink;

    if (Platform.isAndroid) {
      shareLink = 'https://play.google.com/store/apps/details?id=$packageName';
    } else if (Platform.isIOS) {
      shareLink = 'https://apps.apple.com/app/id6746266645'; // Your iOS App ID
    } else {
      shareLink = 'https://pixoplayusa.com'; // fallback website or landing page
    }

    Share.share('Check out this awesome app: $shareLink');
  }

  // Shows the "License Details" popup.
  void showLicenseDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C1826),
          title: const Text(
            'License Details',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Note',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'This app features licensed content from Storyblocks, '
                  'Envato, and Freepik, providing trusted, high-quality media '
                  'for an enhanced experience.\n\n'
                  'All assets are carefully selected to meet copyright '
                  'standards, ensuring secure and compliant usage within '
                  'the app.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'American Calendar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Shows the "About Us" popup.
  void showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C1826),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'About Us',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to PixoPlay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'With over 11 years of industry experience, PixoPlay is dedicated to delivering exceptional mobile applications and digital solutions. Our team of highly skilled professionals combines innovative design with robust development practices to create high-quality apps that consistently exceed client expectations.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                const Text(
                  'We have developed numerous apps for our clients with fully satisfied deliveries. We offer bespoke app development services tailored to your unique business needs. To learn more about our work, please visit our website at pixoplayusa.com, or check out our portfolio on Google Play and the App Store.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                const Text(
                  'For inquiries or custom projects, please contact us at:',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 8),
                // Email row with copy icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: const Text(
                        'avinash@pixoplayusa.com',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(text: 'avinash@pixoplayusa.com'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email address copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // WhatsApp row with copy icon using Font Awesome
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: const Text(
                        '+919885731220',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(text: '+919885731220'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'WhatsApp number copied to clipboard',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thank you for considering PixoPlay. We look forward to partnering with you to deliver outstanding digital solutions.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) {
        switch (value) {
          case 0: // License Details
            showLicenseDetailsDialog(context);
            break;
          case 1:
            launchURL(context, 'https://pixoplayusa.com/privacy.html');
            break;

          case 2:
            launchURL(context, 'https://pixoplayusa.com/terms.html');
            break;
          case 3: // More Apps
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        const DeveloperApps(mode: DeveloperAppsMode.vertical),
              ),
            );
            break;
          case 4:
            if (Platform.isAndroid) {
              launchURL(
                context,
                'https://play.google.com/store/apps/details?id=$packageName',
              );
            } else if (Platform.isIOS) {
              launchURL(context, 'https://apps.apple.com/app/id6746266645');
            }
            break;
          case 5: // Share
            shareApp(context);
            break;
          case 6: // About Us
            showAboutUsDialog(context);
            break;
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(value: 0, child: Text("License Details")),
            const PopupMenuItem<int>(value: 1, child: Text("Privacy Policy")),
            const PopupMenuItem<int>(value: 2, child: Text("Terms")),
            const PopupMenuItem<int>(value: 3, child: Text("More Apps")),
            const PopupMenuItem<int>(value: 4, child: Text("Rate Now")),
            const PopupMenuItem<int>(value: 5, child: Text("Share")),
            const PopupMenuItem<int>(value: 6, child: Text("About Us")),
          ],
    );
  }
}
