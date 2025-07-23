// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';

// import '../home.dart'; // for CircleProgressPainter

// class CycleRingWidget extends StatelessWidget {
//   final DateTime lastPeriodDate;
//   final int cycleLength;
//   final int periodLength;
//   final DateTime? dob;

//   const CycleRingWidget({
//     super.key,
//     required this.lastPeriodDate,
//     required this.cycleLength,
//     required this.periodLength,
//     this.dob,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final daysPassed = now.difference(lastPeriodDate).inDays;
//     final progress = (daysPassed / cycleLength).clamp(0.0, 1.0);
//     final nextPeriodDate = lastPeriodDate.add(Duration(days: cycleLength));
//     final ovulationDay = cycleLength - 14;

//     return Column(
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 260,
//               height: 260,
//               child: TweenAnimationBuilder<double>(
//                 tween: Tween(begin: 0, end: progress),
//                 duration: const Duration(milliseconds: 800),
//                 builder: (context, value, child) {
//                   return CustomPaint(
//                     painter: CircleProgressPainter(value),
//                     size: const Size(260, 260),
//                   );
//                 },
//               ),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Cycle Day $daysPassed",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "Next Period: ${DateFormat('MMM dd').format(nextPeriodDate)}",
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   daysPassed < ovulationDay
//                       ? "Ovulation in ${ovulationDay - daysPassed} days"
//                       : daysPassed == ovulationDay
//                       ? "Ovulation Today"
//                       : "Ovulation passed",
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _info(
//               "Date of Birth",
//               dob != null ? DateFormat('dd MMM, yyyy').format(dob!) : "--",
//             ),
//             _info(
//               "First 🩸 Day",
//               DateFormat('dd MMM, yyyy').format(lastPeriodDate),
//             ),
//             Column(
//               children: [
//                 const Text("Cycle", style: TextStyle(color: Colors.grey)),
//                 Text(
//                   "$daysPassed/$cycleLength",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _info(String label, String value) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(color: Colors.grey)),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }
