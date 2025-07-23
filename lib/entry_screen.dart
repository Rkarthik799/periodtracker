import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:periodtracker/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryScreen extends StatefulWidget {
  final bool isEditing;
  const EntryScreen({super.key, this.isEditing = false});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late int _currentStep;

  int selectedDay = 1;
  int selectedMonth = 1;
  int selectedYear = 2000;

  int selectedCycleLength = 28;
  int selectedPeriodLength = 5;

  DateTime selectedLastPeriodDate = DateTime.now();
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;
  final int currentYear = DateTime.now().year;
  late final PageController _pageController;
  static const _kOnboardingFlag = 'entry_complete'; // ← use everywhere

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _currentStep = widget.isEditing ? 1 : 0;
    _pageController = PageController(initialPage: _currentStep);

    selectedDay = now.day;
    selectedMonth = now.month;
    selectedYear = now.year;
    selectedPeriodLength = 5;
    selectedLastPeriodDate = now.subtract(const Duration(days: 5));

    _monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _yearController = FixedExtentScrollController(
      initialItem: selectedYear - 1950,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // Persist profile
    prefs
      ..setString(
        'dateOfBirth',
        DateTime(selectedYear, selectedMonth, selectedDay).toIso8601String(),
      )
      ..setInt('cycleLength', selectedCycleLength)
      ..setInt('periodLength', selectedPeriodLength)
      ..setString('lastPeriodDate', selectedLastPeriodDate.toIso8601String())
      ..setBool(_kOnboardingFlag, true); // ✅ SAME KEY

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(); // ✅ single choke-point
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStepControls({String nextLabel = "Next"}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Previous",
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            const SizedBox(width: 100),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF56E3C1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              nextLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientContainer({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD4E5), Color(0xFFFF94C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return _buildGradientContainer(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.water_drop_outlined, size: 48, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            "Set Your Date\nof Birth",
            textAlign: TextAlign.center,
            style: _titleStyle,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 110,
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _monthController,
                    onSelectedItemChanged:
                        (index) => setState(() => selectedMonth = index + 1),
                    children: List.generate(
                      12,
                      (i) => Center(
                        child: Text(
                          DateFormat.MMMM().format(DateTime(0, i + 1)),
                          style: _pickerText,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _dayController,
                    onSelectedItemChanged:
                        (index) => setState(() => selectedDay = index + 1),
                    children: List.generate(
                      31,
                      (i) =>
                          Center(child: Text("${i + 1}", style: _pickerText)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _yearController,
                    onSelectedItemChanged:
                        (index) => setState(() => selectedYear = 1950 + index),
                    children: List.generate(
                      currentYear - 1950 + 1,
                      (i) => Center(
                        child: Text("${1950 + i}", style: _pickerText),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStepControls(),
        ],
      ),
    );
  }

  Widget _buildCycleLengthPicker() {
    return _buildGradientContainer(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (widget.isEditing)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context), // ✅ Back to settings
              ),
            ),
          const SizedBox(height: 16),
          const Icon(Icons.repeat, size: 48, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            "Set Your\nCycle Length",
            textAlign: TextAlign.center,
            style: _titleStyle,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: selectedCycleLength - 5,
              ),
              onSelectedItemChanged:
                  (index) => setState(() => selectedCycleLength = 5 + index),
              children: List.generate(
                71,
                (i) => Center(child: Text("${5 + i} days", style: _pickerText)),
              ),
            ),
          ),
          _buildStepControls(),
        ],
      ),
    );
  }

  Widget _buildPeriodLengthPicker() {
    return _buildGradientContainer(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.opacity, size: 48, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            "Set Your\nPeriod Length",
            textAlign: TextAlign.center,
            style: _titleStyle,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: selectedPeriodLength - 1,
              ),
              onSelectedItemChanged:
                  (index) => setState(() => selectedPeriodLength = 1 + index),
              children: List.generate(
                15,
                (i) => Center(child: Text("${1 + i} days", style: _pickerText)),
              ),
            ),
          ),
          _buildStepControls(),
        ],
      ),
    );
  }

  Widget _buildLastPeriodPicker() {
    final DateTime start = DateTime.now().subtract(const Duration(days: 60));
    final List<DateTime> dates = List.generate(
      61,
      (i) => start.add(Duration(days: i)),
    );

    return _buildGradientContainer(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.calendar_today, size: 48, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            "First Day of\nYour Last Period",
            textAlign: TextAlign.center,
            style: _titleStyle,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: dates.length - 5,
              ),
              onSelectedItemChanged:
                  (index) =>
                      setState(() => selectedLastPeriodDate = dates[index]),
              children:
                  dates
                      .map(
                        (date) => Center(
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(date),
                            style: _pickerText,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          _buildStepControls(),
        ],
      ),
    );
  }

  Widget _buildSummaryScreen() {
    final dob = DateTime(selectedYear, selectedMonth, selectedDay);

    return _buildGradientContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              if (widget.isEditing) {
                Navigator.pop(context); // back to settings
              } else {
                setState(() => _currentStep--); // back to last step
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          const Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Summary",
                  textAlign: TextAlign.center,
                  style: _titleStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!widget.isEditing)
            _summaryRow(
              "Date of Birth",
              DateFormat('MMM dd, yyyy').format(dob),
            ),
          _summaryRow("Cycle Length", "$selectedCycleLength days"),
          _summaryRow("Period Length", "$selectedPeriodLength days"),
          _summaryRow(
            "Last Period",
            DateFormat('MMM dd, yyyy').format(selectedLastPeriodDate),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final dob = DateTime(
                    selectedYear,
                    selectedMonth,
                    selectedDay,
                  );
                  final prefs = await SharedPreferences.getInstance();

                  prefs
                    ..setString('dateOfBirth', dob.toIso8601String())
                    ..setInt('cycleLength', selectedCycleLength)
                    ..setInt('periodLength', selectedPeriodLength)
                    ..setString(
                      'lastPeriodDate',
                      selectedLastPeriodDate.toIso8601String(),
                    )
                    ..setBool(
                      'entry_complete',
                      true,
                    ); // ✅ FIXED: match SplashScreen

                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56E3C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.isEditing ? "Update" : "Start",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDateOfBirthPicker(),
      _buildCycleLengthPicker(),
      _buildPeriodLengthPicker(),
      _buildLastPeriodPicker(),
      _buildSummaryScreen(),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, index) => pages[index],
      ),
    );
  }
}

const TextStyle _titleStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.4,
);

const TextStyle _pickerText = TextStyle(color: Colors.white, fontSize: 20);
