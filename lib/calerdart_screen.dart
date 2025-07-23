import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalerdartSheet extends StatefulWidget {
  const CalerdartSheet({super.key});

  @override
  State<CalerdartSheet> createState() => _CalerdartSheetState();
}

class _CalerdartSheetState extends State<CalerdartSheet> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _periodDates = {};
  final Set<String> _ovulationDates = {};
  final Set<String> _nextPeriodDates = {};
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 60));
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now().add(const Duration(days: 365));
    _generateCycleHighlights();
  }

  void _generateCycleHighlights() {
    final today = DateTime.now();
    final cycleLength = 28;
    final periodLength = 5;

    DateTime current = today.subtract(Duration(days: cycleLength * 2));

    while (current.isBefore(_endDate)) {
      final ovulationDate = current.add(Duration(days: cycleLength - 14));
      final isFuture = current.isAfter(today);

      for (int i = 0; i < periodLength; i++) {
        final date = current.add(Duration(days: i));
        final key = _format(date);

        if (isFuture) {
          _nextPeriodDates.add(key);
        } else {
          _periodDates.add(key);
        }
      }

      _ovulationDates.add(_format(ovulationDate));
      current = current.add(Duration(days: cycleLength));
    }
  }

  String _format(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    final months = _generateMonthList();
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF2F7),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Your Cycle Calendar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Calendar
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: months.length,
                  itemBuilder: (_, i) => _buildMonth(months[i], context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DateTime> _generateMonthList() {
    final months = <DateTime>[];
    DateTime current = DateTime(_startDate.year, _startDate.month);
    while (current.isBefore(_endDate)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  Widget _buildMonth(DateTime month, BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday;
    final children = <Widget>[];

    for (int i = 1; i < startWeekday; i++) {
      children.add(const SizedBox(width: 40, height: 40));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = _format(date);
      final isToday = key == _format(DateTime.now());
      final isPeriod = _periodDates.contains(key);
      final isNext = _nextPeriodDates.contains(key);
      final isOvulation = _ovulationDates.contains(key);

      Color? bg;
      if (isPeriod) bg = const Color(0xFFFFC1D9);
      if (isNext) bg = const Color(0xFFFFD5A5);
      if (isOvulation) bg = const Color(0xFFCCEAE6);

      children.add(
        GestureDetector(
          onTap: () {
            String label = DateFormat('MMM d').format(date);
            if (isPeriod) {
              int dayOfPeriod = 1;
              for (int i = 1; i <= 10; i++) {
                final prev = date.subtract(Duration(days: i));
                if (_periodDates.contains(_format(prev))) {
                  dayOfPeriod++;
                } else {
                  break;
                }
              }
              label += " 🩸 Day $dayOfPeriod of Period";
            } else if (isOvulation) {
              label += " 🧬 Ovulation Day";
            }

            final color =
                isPeriod
                    ? const Color(0xFFFFC1D9)
                    : isNext
                    ? const Color(0xFFFFD5A5)
                    : isOvulation
                    ? const Color(0xFFCCEAE6)
                    : Colors.grey.shade200;

            final textColor =
                isPeriod
                    ? const Color(0xFFB44D6A)
                    : isNext
                    ? const Color(0xFFCC6B00)
                    : isOvulation
                    ? const Color(0xFF00796B)
                    : Colors.black;

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: color,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isToday
                        ? Colors.blue
                        : isPeriod
                        ? const Color(0xFFB44D6A)
                        : isNext
                        ? const Color(0xFFCC6B00)
                        : isOvulation
                        ? const Color(0xFF00796B)
                        : Colors.transparent,
                width:
                    isToday
                        ? 1.5
                        : bg != null
                        ? 1.2
                        : 0,
              ),
            ),
            child: Text(
              '$d',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color:
                    isToday
                        ? Colors.blue
                        : bg != null
                        ? Colors.black
                        : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            DateFormat.yMMMM().format(month),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
