// ignore_for_file: unused_local_variable, unused_element, curly_braces_in_flow_control_structures

import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:periodtracker/adservice.dart';
import 'package:periodtracker/appbar_actions.dart';
import 'package:periodtracker/calerdart_screen.dart';
import 'package:periodtracker/developer_apps_page.dart';
import 'package:periodtracker/log_symptoms_screen.dart';
import 'package:periodtracker/rate_now_bottom_sheet.dart';
import 'package:periodtracker/tips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'settings.dart';
import 'animated_wave.dart';

class CycleService {
  static final CycleService _instance = CycleService._internal();
  factory CycleService() => _instance;

  CycleService._internal();

  DateTime selectedDate = DateTime.now();
}

final cycleService = CycleService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  late PageController _pageController;
  int selectedDayIndex = DateTime.now().day - 1;
  DateTime selectedDate = DateTime.now(); // 🔥 stores actual date
  // Period tracking values
  int cycleLength = 28;
  int periodLength = 5;
  DateTime? lastPeriodDate;
  List<String> todaySymptoms = [];
  DateTime displayedMonth = DateTime.now();
  late DateTime nextPeriodDate;
  late DateTime ovulationDate;
  late int daysIntoCycle;
  late int daysUntilOvulation;
  final Set<String> _periodDates = {};
  final Set<String> _ovulationDates = {};
  final Set<String> _nextPeriodDates = {};
  String? highlightedType;
  static const int _defaultLutealDays = 14;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTrackingData();
    _loadTodaySymptoms();
    _loadSymptomsForDate(selectedDate);
    // AdManager.loadInterstitialAd();
    _maybePromptForRating();
  }

  /*──────────────── SHOW BOTTOM-SHEET IF NOT RATED ───────────────*/
  Future<void> _maybePromptForRating() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRated = prefs.getBool('hasRated') ?? false;
    if (hasRated) return;

    // Defer until the current frame is rendered to guarantee a valid context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent, // keep gradient corners
        builder: (_) => const RateNowBottomSheet(),
      );
    });
  }

  Future<void> _loadTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    final cycle = prefs.getInt('cycleLength') ?? 28;
    final period = prefs.getInt('periodLength') ?? 5;
    final lastPeriodStr = prefs.getString('lastPeriodDate');

    if (lastPeriodStr != null) {
      lastPeriodDate = DateTime.parse(lastPeriodStr);
    } else {
      lastPeriodDate = DateTime.now().subtract(Duration(days: 5));
    }
    if (!mounted) return;
    setState(() {
      cycleLength = cycle;
      periodLength = period;
    });

    _calculateTracking();
    _generateHighlights();
  }

  Future<void> _loadSymptomsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'symptoms_${date.year}_${date.month}_${date.day}';
    final saved = prefs.getStringList(key);
    if (!mounted) return;
    setState(() {
      todaySymptoms = saved ?? [];
    });
  }

  void _calculateTracking() {
    final today = DateTime.now();
    final start = lastPeriodDate!;
    final daysInCycle = cycleLength;

    // If today is before the logged period start, clamp to zero.
    daysIntoCycle = max(0, today.difference(start).inDays);

    nextPeriodDate = start.add(Duration(days: daysInCycle));
    ovulationDate = nextPeriodDate.subtract(Duration(days: _defaultLutealDays));

    daysUntilOvulation = ovulationDate
        .difference(today)
        .inDays
        .clamp(-daysInCycle, daysInCycle); // keeps value bounded

    setState(() {}); // safe, mounted check was added earlier
  }

  void _generateHighlights() {
    final now = DateTime.now();
    final startDate = lastPeriodDate!.subtract(const Duration(days: 60));
    final endDate = lastPeriodDate!.add(const Duration(days: 365));

    _periodDates.clear();
    _ovulationDates.clear();
    _nextPeriodDates.clear();

    DateTime current = lastPeriodDate!;

    // Go backward
    while (current.isAfter(startDate)) {
      current = current.subtract(Duration(days: cycleLength));
      for (int i = 0; i < periodLength; i++) {
        final date = current.add(Duration(days: i));
        if (date.isAfter(startDate)) {
          _periodDates.add(DateFormat('yyyy-MM-dd').format(date));
        }
      }
      final ovulationDate = current.add(Duration(days: cycleLength - 14));
      if (ovulationDate.isAfter(startDate)) {
        _ovulationDates.add(DateFormat('yyyy-MM-dd').format(ovulationDate));
      }
    }

    // Go forward
    bool markedNext = false;
    current = lastPeriodDate!;
    while (current.isBefore(endDate)) {
      final isFuture = current.isAfter(now);
      for (int i = 0; i < periodLength; i++) {
        final date = current.add(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(date);
        if (isFuture) {
          _nextPeriodDates.add(
            key,
          ); // ✅ All future period dates get next-period color
        } else {
          _periodDates.add(key);
        }
      }
      if (isFuture) markedNext = true;

      final ovulationDate = current.add(Duration(days: cycleLength - 14));
      if (ovulationDate.isBefore(endDate)) {
        _ovulationDates.add(DateFormat('yyyy-MM-dd').format(ovulationDate));
      }

      current = current.add(Duration(days: cycleLength));
    }
  }

  Future<void> _loadTodaySymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'symptoms_${today.year}_${today.month}_${today.day}';
    final saved = prefs.getStringList(key);
    if (saved != null) {
      setState(() => todaySymptoms = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2F7),
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: (i) => setState(() => currentPage = i),
        children: [
          _buildHomeTab(),
          _buildTipsTab(),
          const SettingsScreen(), // ✅ Full settings UI here
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          if (index == currentPage) return;

          // Show interstitial ad before navigating
          // AdManager.showInterstitialAd(
          //   onAdClosed: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        //   );
        // },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    if (lastPeriodDate == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = displayedMonth;
    final dayOfCycle = daysIntoCycle;
    final ovulationText =
        daysUntilOvulation > 0
            ? 'Ovulation in $daysUntilOvulation Days'
            : 'Ovulation Today';

    return SafeArea(
      child: Container(
        color: const Color(0xFFFFF2F7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 🔹 Center: Month and Year with chevrons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              displayedMonth = DateTime(
                                displayedMonth.year,
                                displayedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(displayedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              displayedMonth = DateTime(
                                displayedMonth.year,
                                displayedMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),

                    // 🔸 Left and Right: Calendar Icon + AppBarActions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 22,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (context) => const FractionallySizedBox(
                                    heightFactor: 0.75,
                                    child: CalerdartSheet(),
                                  ),
                            );
                          },
                        ),
                        const AppBarActions(
                          packageName: 'com.pixoplay.periodtracker',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCycleRing(
                  dayOfCycle,
                  ovulationText,
                  key: ValueKey(displayedMonth),
                ),
              ),
              if (todaySymptoms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        todaySymptoms.map((s) {
                          return Chip(
                            label: Text(
                              s,
                              style: const TextStyle(fontSize: 13),
                            ),
                            backgroundColor: Color(0xFFFFECF2),
                            side: BorderSide(color: Color(0xFFFF94C2)),
                          );
                        }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.pink.shade100,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(24),
              //     ),
              //   ),
              //   child: const Text(
              //     '+ Add Period',
              //     style: TextStyle(color: Colors.black),
              //   ),
              // ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  // AdManager.showInterstitialAd(
                  //   onAdClosed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => LogSymptomsScreen(selectedDate: selectedDate),
                    ),
                  );
                  await _loadSymptomsForDate(
                    selectedDate,
                  ); // 🔄 Refresh for selected day
                  setState(() {});
                },
                //   );
                // },
                child: const Text('Log Symptoms'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Developer Apps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'ADS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: DeveloperApps(mode: DeveloperAppsMode.horizontal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPregnancyChance(int day) {
    final fertileStart = cycleLength - _defaultLutealDays - 4;
    final fertileEnd = cycleLength - _defaultLutealDays + 1;

    if (day <= 0) return "Cycle not started";

    if (day <= periodLength) return "Very Low chance";
    if (day >= fertileStart && day <= fertileEnd) return "High chance";
    if (day > fertileEnd && day <= cycleLength) return "Low chance";
    return "Outside current cycle";
  }

  String _getOvulationText(int day) {
    final ovulationDay = cycleLength - _defaultLutealDays;
    final diff = ovulationDay - day;

    if (diff == 0) return 'Ovulation Today';
    if (diff > 0) return 'Ovulation in $diff day${diff == 1 ? '' : 's'}';
    return 'Ovulation ${-diff} day${diff == -1 ? '' : 's'} ago';
  }

  Widget _buildCycleRing(int dayOfCycle, String ovulationText, {Key? key}) {
    final DateTime now = displayedMonth;
    final int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final double angleStep = 2 * pi / daysInMonth;

    final DateTime current = selectedDate;
    final int virtualDayOfCycle = max(
      1,
      selectedDate.difference(lastPeriodDate!).inDays + 1,
    );
    final String ovulationTextSelected = _getOvulationText(virtualDayOfCycle);
    final pregnancyChance = _getPregnancyChance(virtualDayOfCycle);
    final periodStart = DateTime(
      lastPeriodDate!.year,
      lastPeriodDate!.month,
      lastPeriodDate!.day,
    );
    final periodEnd = periodStart.add(Duration(days: periodLength));
    return Column(
      key: key,
      children: [
        SizedBox(
          width: 360,
          height: 360,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: const AnimatedWave(),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: min(dayOfCycle / cycleLength, 1.0)),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: CircleProgressPainter(value),
                    size: const Size(280, 280),
                  );
                },
              ),
              // 🔁 Tappable days, pointer, ring, center text
              for (int i = 0; i < daysInMonth; i++)
                Transform.rotate(
                  angle: angleStep * i,
                  child: Transform.translate(
                    offset: const Offset(0, -170),
                    child: Transform.rotate(
                      angle: -angleStep * i, // ✅ Only added line
                      child: GestureDetector(
                        onTap: () async {
                          final newDate = DateTime(now.year, now.month, i + 1);
                          final prefs = await SharedPreferences.getInstance();
                          final key =
                              'symptoms_${newDate.year}_${newDate.month}_${newDate.day}';
                          final saved = prefs.getStringList(key);
                          setState(() {
                            final safeIndex = min(
                              i,
                              DateUtils.getDaysInMonth(now.year, now.month) - 1,
                            );
                            selectedDayIndex = safeIndex;
                            selectedDate = newDate;
                            todaySymptoms = saved ?? [];
                            cycleService.selectedDate = newDate;
                          });
                        },
                        child: Builder(
                          builder: (context) {
                            final day = i + 1;
                            final current = DateTime(now.year, now.month, day);
                            final key = DateFormat(
                              'yyyy-MM-dd',
                            ).format(current);
                            final isSelected = i == selectedDayIndex;
                            final isPeriodDay = _periodDates.contains(key);
                            final isOvulationDay = _ovulationDates.contains(
                              key,
                            );
                            final isNextPeriodDay = _nextPeriodDates.contains(
                              key,
                            );

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Container(
                                key: ValueKey<bool>(isSelected),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isSelected
                                          ? const Color.fromARGB(
                                            255,
                                            241,
                                            0,
                                            80,
                                          )
                                          : isNextPeriodDay
                                          ? Color(0xFFFFD5A5)
                                          : isPeriodDay
                                          ? Color(0xFFFFD4E5)
                                          : isOvulationDay
                                          ? Color(0xFF99D6CC)
                                          : Colors.transparent,
                                  border:
                                      isOvulationDay
                                          ? Border.all(
                                            color: Color(0xFF00897B),
                                            width: 1.2,
                                          )
                                          : null,
                                ),
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

              // 🔺 Pointer
              // if (selectedDate.month == now.month &&
              //     selectedDate.year == now.year)
              //   Transform.rotate(
              //     angle: -pi / 2 + angleStep * (selectedDate.day - 1),
              //     child: Transform.translate(
              //       offset: const Offset(0, -190),
              //       child: const Icon(
              //         Icons.arrow_drop_down,
              //         size: 30,
              //         color: Colors.pink,
              //       ),
              //     ),
              //   ),

              // 🌀 Ring

              // Center Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   'Cycle Day $virtualDayOfCycle',
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  Text(
                    'Next Period: ${DateFormat('MMM dd, yyyy').format(nextPeriodDate)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pregnancyChance,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 4),
                  if (selectedDate.isBefore(periodStart)) ...[
                    Text(
                      'Period in ${periodStart.difference(selectedDate).inDays} days',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ] else if (!selectedDate.isBefore(periodStart) &&
                      selectedDate.isBefore(periodEnd)) ...[
                    Text(
                      'Day ${selectedDate.difference(periodStart).inDays + 1} of Period',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF5CA8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _legendDot(Color(0xFFFFD4E5), "Period", type: 'period'),
              const SizedBox(width: 10),
              _legendDot(Color(0xFFCCEAE6), "Ovulation", type: 'ovulation'),
              const SizedBox(width: 10),
              _legendDot(Color(0xFFFFD5A5), "Next Period", type: 'nextPeriod'),
              const SizedBox(width: 10),
              _legendDot(Color(0xFFFF94C2), "Selected", type: 'selected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label, {String? type}) {
    final isSelected = highlightedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          highlightedType = (highlightedType == type) ? null : type;
        });
      },
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(color: Colors.black, width: 2) : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SafeArea(
      child: Container(
        color: const Color(0xFFFFF2F7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Put the tips content here:
              const TipsScreen(),
              // Then the Developer Apps
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Developer Apps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'ADS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: DeveloperApps(mode: DeveloperAppsMode.horizontal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> _loadHistoryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final historyWidgets = <Widget>[];

    final symptomKeys =
        allKeys.where((k) => k.startsWith("symptoms_")).toList();
    symptomKeys.sort((a, b) => b.compareTo(a)); // Newest first

    for (final key in symptomKeys) {
      final parts = key.split('_');
      if (parts.length != 4) continue;

      final year = int.parse(parts[1]);
      final month = int.parse(parts[2]);
      final day = int.parse(parts[3]);
      final date = DateTime(year, month, day);
      final symptoms = prefs.getStringList(key) ?? [];

      if (lastPeriodDate == null) continue;

      final cycleDay = date.difference(lastPeriodDate!).inDays + 1;
      final String dayLabel =
          cycleDay < 1
              ? "Before cycle start"
              : "Cycle Day $cycleDay / $cycleLength";
      final String ovulationText = _getOvulationText(cycleDay);
      final String pregnancyChance = _getPregnancyChance(cycleDay);

      historyWidgets.add(
        Container(
          key: ValueKey(key),
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFFF2F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFFFD4E5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(dayLabel),
              Text(ovulationText),
              Text(pregnancyChance),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    symptoms
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Color(0xFFFF94C2)),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      );
    }

    return historyWidgets;
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Widget>>(
      future: _loadHistoryEntries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text("No history yet"));
        return Container(
          color: const Color(0xFFFFF2F7),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // ✅ free GPU resources & listeners
    super.dispose();
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint =
        Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;

    final progressPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF94C2), Color(0xFFFF5CA8)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
