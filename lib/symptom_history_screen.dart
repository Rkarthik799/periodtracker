// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> allKeys = [];
  Set<String> selectedKeys = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith('symptoms_')).toList();
    keys.sort((a, b) => b.compareTo(a)); // Newest first
    setState(() {
      allKeys = keys;
    });
  }

  Future<void> _deleteSelected() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in selectedKeys) {
      await prefs.remove(key);
    }
    selectedKeys.clear();
    await _loadHistory();
  }

  String _getPregnancyChance(int cycleLength, int periodLength, int day) {
    final fertileStart = cycleLength - 14 - 4;
    final fertileEnd = cycleLength - 14 + 1;
    if (day <= periodLength) return "Very Low chance of getting pregnant";
    if (day >= fertileStart && day <= fertileEnd) return "High chance";
    if (day > fertileEnd && day <= cycleLength) return "Low chance";
    return "Moderate chance";
  }

  String _getOvulationText(int cycleLength, int day) {
    final ovulationDay = cycleLength - 14;
    final diff = ovulationDay - day;
    if (diff == 0) return 'Ovulation Today';
    if (diff > 0) return 'Ovulation in $diff Days';
    return 'Ovulation passed';
  }

  Widget _buildCard(String key) {
    final parts = key.split('_');
    final date = DateTime(
      int.parse(parts[1]),
      int.parse(parts[2]),
      int.parse(parts[3]),
    );

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final prefs = snapshot.data as SharedPreferences;
        final cycleLength = prefs.getInt('cycleLength') ?? 28;
        final periodLength = prefs.getInt('periodLength') ?? 5;
        final lastPeriodStr = prefs.getString('lastPeriodDate');
        if (lastPeriodStr == null) return const SizedBox();

        final lastPeriod = DateTime.parse(lastPeriodStr);
        final cycleDay = date.difference(lastPeriod).inDays + 1;
        final ovulationText = _getOvulationText(cycleLength, cycleDay);
        final pregnancyChance = _getPregnancyChance(
          cycleLength,
          periodLength,
          cycleDay,
        );
        final symptoms = prefs.getStringList(key) ?? [];
        final isSelected = selectedKeys.contains(key);

        return GestureDetector(
          onLongPress: () {
            setState(() {
              selectedKeys.add(key);
            });
          },
          onTap: () {
            if (selectedKeys.isNotEmpty) {
              setState(() {
                if (selectedKeys.contains(key)) {
                  selectedKeys.remove(key);
                } else {
                  selectedKeys.add(key);
                }
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFFFFD4E5).withOpacity(0.3)
                      : const Color(0xFFFFFCFE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFFFF5CA8)
                        : const Color(0xFFFFD4E5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFECF2),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM dd, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD4E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cycleDay < 1 ? "Before Cycle" : "Day $cycleDay",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.egg_outlined,
                      size: 18,
                      color: Color(0xFF00897B),
                    ),
                    const SizedBox(width: 6),
                    Text(ovulationText),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(pregnancyChance),
                  ],
                ),
                const SizedBox(height: 10),
                if (symptoms.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        symptoms.map((s) {
                          return Chip(
                            label: Text(s),
                            backgroundColor: const Color(0xFFFFECF2),
                            side: const BorderSide(color: Color(0xFFFF94C2)),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Selected?'),
            content: Text(
              'You are about to delete ${selectedKeys.length} record(s). Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteSelected();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDelete = selectedKeys.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom History"),
        backgroundColor: const Color(0xFFFF5CA8),
        actions: [
          if (showDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body:
          allKeys.isEmpty
              ? const Center(child: Text("No history yet"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allKeys.length,
                itemBuilder: (_, i) => _buildCard(allKeys[i]),
              ),
    );
  }
}
