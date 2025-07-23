// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CalendarSheet extends StatefulWidget {
//   const CalendarSheet({super.key});

//   @override
//   State<CalendarSheet> createState() => _CalendarSheetState();
// }

// class _CalendarSheetState extends State<CalendarSheet> {
//   final Map<String, Color> _highlightedDates = {};
//   final ScrollController _scrollController = ScrollController();
//   final Set<String> _periodDates = {};
//   final Set<String> _ovulationDates = {};
//   final Set<String> _nextPeriodDates = {};
//   bool _isLoading = true;
//   DateTime _startDate = DateTime.now().subtract(const Duration(days: 60));
//   DateTime? _endDate; // ✅ keep this only
//   @override
//   void initState() {
//     super.initState();
//     _loadTrackingData();
//   }

//   bool isToday(DateTime date) {
//     final now = DateTime.now();
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }

//   Future<void> _loadTrackingData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastPeriodStr = prefs.getString('lastPeriodDate');
//     final cycleLength = prefs.getInt('cycleLength') ?? 28;
//     final periodLength = prefs.getInt('periodLength') ?? 5;

//     if (lastPeriodStr == null) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     final lastPeriodDate = DateTime.parse(lastPeriodStr);
//     _startDate = DateTime(lastPeriodDate.year, lastPeriodDate.month - 2, 1);
//     _endDate = lastPeriodDate.add(const Duration(days: 365));

//     DateTime current = lastPeriodDate;
//     while (current.isAfter(_startDate)) {
//       final previous = current.subtract(Duration(days: cycleLength));
//       for (int i = 0; i < periodLength; i++) {
//         final date = previous.add(Duration(days: i));
//         final key = DateFormat('yyyy-MM-dd').format(date);
//         if (date.isAfter(_startDate)) {
//           _highlightedDates[key] = Colors.pink.shade100;
//           _periodDates.add(key);
//         }
//       }

//       final ovulationDate = previous.add(Duration(days: cycleLength - 14));
//       final ovKey = DateFormat('yyyy-MM-dd').format(ovulationDate);
//       if (ovulationDate.isAfter(_startDate)) {
//         _highlightedDates[ovKey] = Colors.teal.shade200;
//         _ovulationDates.add(ovKey);
//       }

//       current = previous;
//     }

//     // 🔼 Forward future periods
//     current = lastPeriodDate;
//     bool reachedFuture = false;

//     if (_endDate == null) return;
//     while (current.isBefore(_endDate!)) {
//       final isFuture = current.isAfter(DateTime.now());
//       if (isFuture && !reachedFuture) {
//         reachedFuture = true;
//       }

//       for (int i = 0; i < periodLength; i++) {
//         final date = current.add(Duration(days: i));
//         final key = DateFormat('yyyy-MM-dd').format(date);

//         if (_endDate != null && date.isBefore(_endDate!)) {
//           if (reachedFuture) {
//             _highlightedDates[key] = Colors.deepOrange.shade100;
//             _nextPeriodDates.add(key);
//           } else {
//             _highlightedDates[key] = Colors.pink.shade100;
//           }
//           _periodDates.add(key);
//         }
//       }

//       final ovulationDate = current.add(Duration(days: cycleLength - 14));
//       final ovKey = DateFormat('yyyy-MM-dd').format(ovulationDate);
//       if (_endDate != null && ovulationDate.isBefore(_endDate!)) {
//         _highlightedDates[ovKey] = Colors.teal.shade200;
//         _ovulationDates.add(ovKey);
//       }

//       current = current.add(Duration(days: cycleLength));
//     }

//     // 👇 only one scroll to current month
//     setState(() {
//       _isLoading = false;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final now = DateTime.now();
//       final index = _generateMonthList().indexWhere(
//         (month) => month.year == now.year && month.month == now.month,
//       );

//       if (index != -1) {
//         _scrollController.animateTo(
//           index * 300,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//         );
//       }
//     });

//     setState(() {
//       _isLoading = false; // ✅ mark complete only at the end
//     });
//   }

//   void _showSmoothSnackBar(
//     BuildContext context,
//     String message, {
//     required Color backgroundColor,
//     required Color textColor,
//   }) {
//     final snackBar = SnackBar(
//       content: Text(
//         message,
//         style: TextStyle(
//           color: textColor,
//           fontWeight: FontWeight.w600,
//           fontSize: 15,
//         ),
//       ),
//       duration: const Duration(milliseconds: 1800),
//       elevation: 8,
//       backgroundColor: backgroundColor,
//       behavior: SnackBarBehavior.floating,
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       animation: CurvedAnimation(
//         parent: ModalRoute.of(context)!.animation!,
//         curve: Curves.easeInOut,
//       ),
//     );

//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading || _endDate == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Container(
//           padding: const EdgeInsets.only(top: 20, bottom: 30),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       "Your Cycle Calendar",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(),

//               // 📅 Calendar content only shown if we have data
//               Expanded(
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   itemCount: _generateMonthList().length,
//                   itemBuilder: (_, index) {
//                     final month = _generateMonthList()[index];
//                     return _buildMonthCalendar(month, context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<DateTime> _generateMonthList() {
//     final months = <DateTime>[];
//     if (_endDate == null) return [];
//     DateTime month = DateTime(_startDate.year, _startDate.month);
//     while (month.isBefore(_endDate!)) {
//       months.add(month);
//       month = DateTime(month.year, month.month + 1);
//     }
//     return months;
//   }

//   Widget _buildMonthCalendar(DateTime month, BuildContext context) {
//     final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
//     final firstDay = DateTime(month.year, month.month, 1);
//     final startingWeekday = firstDay.weekday;

//     final List<Widget> dayWidgets = [];

//     for (int i = 1; i < startingWeekday; i++) {
//       dayWidgets.add(const SizedBox(width: 40, height: 40));
//     }

//     for (int day = 1; day <= daysInMonth; day++) {
//       final date = DateTime(month.year, month.month, day);
//       final dateStr = DateFormat('yyyy-MM-dd').format(date);
//       final color = _highlightedDates[dateStr];

//       String? label;
//       if (_periodDates.contains(dateStr)) {
//         label = "$day Period";
//       } else if (_ovulationDates.contains(dateStr)) {
//         label = "$day Ovulation";
//       }

//       dayWidgets.add(
//         GestureDetector(
//           onTap: () {
//             final theme = Theme.of(context);
//             final isDark = theme.brightness == Brightness.dark;

//             if (_periodDates.contains(dateStr)) {
//               int dayOfPeriod = 1;
//               for (int offset = 1; offset <= 10; offset++) {
//                 final prevDate = date.subtract(Duration(days: offset));
//                 final prevStr = DateFormat('yyyy-MM-dd').format(prevDate);
//                 if (_periodDates.contains(prevStr)) {
//                   dayOfPeriod++;
//                 } else {
//                   break;
//                 }
//               }

//               final label =
//                   "${DateFormat('MMM d').format(date)} 🩸 Day $dayOfPeriod of Period";

//               final isFuture = _nextPeriodDates.contains(dateStr);
//               _showSmoothSnackBar(
//                 context,
//                 label,
//                 backgroundColor:
//                     isFuture
//                         ? (isDark
//                             ? Colors.deepOrange.shade200
//                             : Colors.deepOrange.shade50)
//                         : (isDark ? Colors.pink.shade200 : Colors.pink.shade50),
//                 textColor:
//                     isFuture
//                         ? (isDark ? Colors.black : Colors.deepOrange.shade800)
//                         : (isDark ? Colors.black : Colors.pink.shade800),
//               );
//             } else if (_ovulationDates.contains(dateStr)) {
//               final label =
//                   "${DateFormat('MMM d').format(date)} 🧬 Ovulation Day";

//               _showSmoothSnackBar(
//                 context,
//                 label,
//                 backgroundColor:
//                     isDark ? Colors.teal.shade200 : Colors.teal.shade50,
//                 textColor: isDark ? Colors.black : Colors.teal.shade800,
//               );
//             }
//           },
//           child: Container(
//             margin: const EdgeInsets.all(4),
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color ?? Colors.transparent,
//               shape: BoxShape.circle,
//               border:
//                   color != null
//                       ? Border.all(
//                         color:
//                             _ovulationDates.contains(dateStr)
//                                 ? Colors.teal
//                                 : _nextPeriodDates.contains(dateStr)
//                                 ? Colors.deepOrange
//                                 : Colors.pink,
//                         width: 1.2,
//                       )
//                       : date.year == DateTime.now().year &&
//                           date.month == DateTime.now().month &&
//                           date.day == DateTime.now().day
//                       ? Border.all(color: Colors.blue, width: 1.5)
//                       : null,
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               '$day',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color:
//                     color != null
//                         ? Colors.black
//                         : date.year == DateTime.now().year &&
//                             date.month == DateTime.now().month &&
//                             date.day == DateTime.now().day
//                         ? Colors.blue
//                         : Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           child: Text(
//             DateFormat.yMMMM().format(month),
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Wrap(children: dayWidgets),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );s
//   }
// }
