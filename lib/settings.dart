// ignore_for_file: unused_import, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:periodtracker/adservice.dart';
import 'package:periodtracker/calendar_sheet.dart';
import 'package:periodtracker/calerdart_screen.dart';
import 'package:periodtracker/developer_apps_page.dart';
import 'package:periodtracker/supporting/developer_apps_page.dart';
import 'package:periodtracker/home.dart';
import 'package:periodtracker/symptom_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:periodtracker/entry_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime? dob;
  DateTime? lastPeriodDate;
  late DateTime ovulationDate;
  int cycleLength = 28;
  int daysPassed = 0;
  double progress = 0.0;

  String? _profilePicPath; // ← resolved at runtime
  static const _kProfileKey = 'profilePicPath';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final dobStr = prefs.getString('dateOfBirth');
    final lastPeriodStr = prefs.getString('lastPeriodDate');
    _profilePicPath =
        prefs.getString(_kProfileKey) ??
        'assets/profile_pics/profile_pic1.png'; // default fallback

    if (dobStr != null) dob = DateTime.parse(dobStr);
    if (lastPeriodStr != null) lastPeriodDate = DateTime.parse(lastPeriodStr);

    cycleLength = prefs.getInt('cycleLength') ?? 28;

    if (lastPeriodDate != null) {
      final now = DateTime.now();
      final ovulationDay = cycleLength - 14;
      ovulationDate = lastPeriodDate!.add(Duration(days: ovulationDay));
      daysPassed = now.difference(lastPeriodDate!).inDays;
      progress = daysPassed / cycleLength;
      if (progress > 1) progress = 1;
    }

    setState(() {});
  }

  Future<void> _showAvatarPicker() async {
    final List<String> avatars = List.generate(
      22,
      (i) => 'assets/profile_pics/profile_pic${i + 1}.png',
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    itemCount: avatars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemBuilder: (_, index) {
                      final path = avatars[index];
                      final bool isSelected = path == _profilePicPath;

                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(_kProfileKey, path);

                          setState(
                            () => _profilePicPath = path,
                          ); // refresh parent
                          setModalState(() {}); // refresh grid
                          Navigator.pop(context); // close sheet
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(path, fit: BoxFit.cover),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFF4081),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final contentWidth = MediaQuery.of(context).size.width - 40;
    final progressLeft = contentWidth * progress;
    final ovulationLeft = contentWidth * (14 / cycleLength);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (_) => const FractionallySizedBox(
                                heightFactor: 0.85,
                                child: CalerdartSheet(),
                              ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16),
                          const SizedBox(width: 6),
                          Text(DateFormat("MMM dd").format(now)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (lastPeriodDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12), // space below "My Profile"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ─── inside the build() method, replace the old Center+ClipRRect ───
                      GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                _profilePicPath!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Change Photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB44D6A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background ring
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 800),
                                  builder: (context, value, child) {
                                    return CustomPaint(
                                      painter: CircleProgressPainter(value),
                                      size: const Size(260, 260),
                                    );
                                  },
                                ),
                                // Inner label
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Cycle Day $daysPassed",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Next Period: ${DateFormat('MMM dd').format(lastPeriodDate!.add(Duration(days: cycleLength)))}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFB44D6A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      daysPassed <= (cycleLength - 14)
                                          ? "Ovulation in ${cycleLength - 14 - daysPassed} days"
                                          : daysPassed == (cycleLength - 14)
                                          ? "Ovulation Today"
                                          : "Ovulation passed",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFB44D6A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoColumn("Date of Birth", dob),
                      _infoColumn("First 🩸 Day", lastPeriodDate),
                      Column(
                        children: [
                          const Text(
                            "Cycle",
                            style: TextStyle(color: Color(0xFFB44D6A)),
                          ),
                          Text(
                            "$daysPassed/$cycleLength",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 30),

            const Text(
              "General",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _settingsItem(
              context,
              "Cycle Settings",
              Icons.settings,
              '',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EntryScreen(isEditing: true),
                    ),
                  ),
            ),
            _settingsItem(
              context,
              "History",
              Icons.history,
              null,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
            ),
            _settingsItem(
              context,
              "Privacy Policy",
              Icons.privacy_tip_outlined,
              null,
              onTap: () => _launchURL('https://pixoplayusa.com/privacy.html'),
            ),
            _settingsItem(
              context,
              "Terms of Use",
              Icons.article_outlined,
              null,
              onTap: () => _launchURL('https://pixoplayusa.com/terms.html'),
            ),
            _settingsItem(
              context,
              "Our Apps",
              Icons.apps,
              null,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const DeveloperApps(
                            mode: DeveloperAppsMode.vertical,
                          ),
                    ),
                  ),
            ),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Version 1.3.2+3",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                SizedBox(height: 4),
                Text(
                  "© 2025 Pixoplay IT Services",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Inside _SettingsScreenState:
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _infoColumn(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB44D6A), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? DateFormat('dd MMM, yyyy').format(date) : "--",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(
    BuildContext context,
    String title,
    IconData icon,
    String? route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFFE94278)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Show interstitial ad first, then do the tap action
        AdManager.showInterstitialAd(
          onAdClosed: () {
            if (onTap != null) {
              onTap();
            } else if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
        );
      },
    );
  }
}
