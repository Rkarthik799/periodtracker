// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:periodtracker/adservice.dart';

class LogSymptomsScreen extends StatefulWidget {
  final DateTime selectedDate;
  const LogSymptomsScreen({super.key, required this.selectedDate});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  final Map<String, List<String>> symptoms = {
    '🩸 Menstrual Flow': [
      '🩸 None',
      '🔴 Spotting',
      '🟠 Light',
      '🟡 Medium',
      '🔴 Heavy',
      '⚠️ Clots',
    ],
    '🔞 Sexual Activity': [
      '❤️ Had Sex',
      '🛡️ With Protection',
      '❌ Without Protection',
      '😣 Painful',
      '🔥 High Libido',
      '😐 Low Libido',
    ],
    '💧 Vaginal Discharge': [
      '🚫 None',
      '💧 Watery',
      '🥛 Creamy',
      '🍳 Egg White',
      '🧴 Sticky',
      '🟤 Brown',
      '🔥 Itchy/Irritated',
    ],
    '😵 Mood / Emotional': [
      '😄 Happy',
      '😢 Sad',
      '😰 Anxious',
      '😤 Irritable',
      '😭 Crying',
      '💃 Energetic',
      '🥱 Low Motivation',
    ],
    '💪 Physical Symptoms': [
      '😖 Cramps',
      '🤕 Headache',
      '🤰 Tender Breasts',
      '🤢 Nausea',
      '😮‍💨 Fatigue',
      '💨 Bloating',
      '🩹 Back Pain',
    ],
    '😋 Cravings': [
      '🍫 Chocolate',
      '🍟 Salty',
      '🍰 Sugar',
      '🍞 Carbs',
      '🚫 No Appetite',
    ],
    '💤 Sleep': ['😴 Slept Well', '😵 Insomnia', '😬 Restless', '🛌 Overslept'],
    '💩 Digestion': [
      '💩 Constipation',
      '🚽 Diarrhea',
      '💨 Gassy',
      '🤢 Stomach Pain',
    ],
  };

  final Map<String, Set<String>> selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    for (var key in symptoms.keys) {
      selectedSymptoms[key] = {};
    }
    _loadSavedSymptoms();
  }

  Future<void> _loadSavedSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'symptoms_${widget.selectedDate.year}_${widget.selectedDate.month}_${widget.selectedDate.day}';
    final savedSymptoms = prefs.getStringList(key) ?? [];

    // Map saved symptoms into categories
    for (var entry in symptoms.entries) {
      for (var option in entry.value) {
        if (savedSymptoms.contains(option)) {
          selectedSymptoms[entry.key]?.add(option);
        }
      }
    }

    setState(() {});
  }

  Widget _buildCategory(String title, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                options.map((option) {
                  final selected = selectedSymptoms[title]!.contains(option);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          selectedSymptoms[title]!.remove(option);
                        } else {
                          selectedSymptoms[title]!.add(option);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? Colors.pink.shade50
                                : Colors.grey.shade100,
                        border: Border.all(
                          color:
                              selected
                                  ? Colors.pinkAccent
                                  : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.pinkAccent : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'symptoms_${widget.selectedDate.year}_${widget.selectedDate.month}_${widget.selectedDate.day}';

    // Flatten selectedSymptoms into a list
    final all = selectedSymptoms.values.expand((set) => set).toList();
    await prefs.setStringList(key, all);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Log Symptoms'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children:
            symptoms.entries
                .map((e) => _buildCategory(e.key, e.value))
                .toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            AdManager.showInterstitialAd(
              onAdClosed: () {
                _handleSave(); // ✅ Call your save logic after ad is closed
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Save Symptoms',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
