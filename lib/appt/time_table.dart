// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_timetable/flutter_timetable.dart';
// import 'package:intl/intl.dart';
// import 'package:timetable/timetable.dart';

// /// Plain old default time table screen.
// class TimeTable extends StatefulWidget {
//   const TimeTable({Key? key}) : super(key: key);

//   @override
//   State<TimeTable> createState() => _TimeTableState();
// }

// class _TimeTableState extends State<TimeTable> {
//   // final items = generateItems();
//   final controller = TimetableController(
//     start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7)),
//     initialColumns: 3,
//     cellHeight: 100.0,
//   );

//   final myDateController = DateController(
//   // All parameters are optional and displayed with their default value.
//   initialDate: DateTimeTimetable.today(),
//   visibleRange: VisibleDateRange.days(),
// );

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.grey,
//           actions: [
//             TextButton(
//               onPressed: () async => Navigator.pushNamed(context, '/custom'),
//               child: Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: const [
//                   Icon(Icons.celebration_outlined, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text("Custom builders",
//                       style: TextStyle(color: Colors.white, fontSize: 16)),
//                   SizedBox(width: 8),
//                   Icon(Icons.chevron_right_outlined, color: Colors.white),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: 
//         // Timetable<String>(
//         //   controller: controller,
//         //   headerCellBuilder: (datetime) {
//         //     return Container();
//         //   },
//         //   cornerBuilder: (datetime) => Container(),
//         //   hourLabelBuilder: (time) {
//         //     final hour = time.hour == 12 ? 12 : time.hour % 12;
//         //     final period = time.hour < 12 ? "am" : "pm";
//         //     final isCurrentHour = time.hour == DateTime.now().hour;
//         //     return (time.hour < 8 || time.hour > 17)
//         //         ? Container()
//         //         : Text(
//         //             "$hour$period",
//         //             style: TextStyle(
//         //               fontSize: 14,
//         //               fontWeight:
//         //                   isCurrentHour ? FontWeight.bold : FontWeight.normal,
//         //             ),
//         //           );
//         //   },
//         //   cellBuilder: (datetime) => (datetime.hour < 8 || datetime.hour > 17)
//         //       ? Container()
//         //       : Container(
//         //           decoration: BoxDecoration(
//         //             border: Border.all(color: Colors.blueGrey, width: 0.2),
//         //           ),
//         //           child: Center(
//         //             child: Text(
//         //               DateFormat("MM/d/yyyy\nha").format(datetime),
//         //               style: TextStyle(
//         //                 color: Color(0xff000000 +
//         //                         (0x002222 * datetime.hour) +
//         //                         (0x110000 * datetime.day))
//         //                     .withOpacity(0.5),
//         //               ),
//         //               textAlign: TextAlign.center,
//         //             ),
//         //           ),
//         //         ),
//         // ),
//       );
// }
