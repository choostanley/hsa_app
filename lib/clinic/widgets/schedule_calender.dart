import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';
import 'package:hsa_app/clinic/models/day_model.dart';
import 'package:hsa_app/clinic/models/schedule_day.dart';
import 'package:hsa_app/clinic/models/schedule_model.dart';
import 'package:hsa_app/common/functions.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../common/firebase/firebase_const.dart';
import 'utils.dart';

class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key, required this.sm, required this.dayFn});
  final ScheduleModel sm;
  final void Function(DayModel pickedDay, ScheduleDay scheduleDay) dayFn;

  @override
  // ignore: library_private_types_in_public_api
  _ScheduleCalendarState createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  late Set<DateTime> selectedDaySet = <DateTime>{};
  late Map<String, int> noOfAppts;
  late ScheduleModel localSm;
  late List<int> workingDays;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    localSm = widget.sm;
    // print(localSm.scheDays.length);
    noOfAppts = {for (var e in localSm.days) e.date: e.curApptNum};
    workingDays = localSm.scheDays
        .where((sd) => !sd.holiday)
        .map((sdm) => sdm.dayOfWeek)
        .toList();
    super.initState();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // create DayModel if missing
    setState(() => _focusedDay = focusedDay);
    if (noOfAppts.keys.contains(getDate(selectedDay))) {
      DayModel dMod = localSm.days
          .firstWhere((day) => getDate(_focusedDay) == getDate(day.dayDT));
      // dunno what to put for orElse lol
      widget.dayFn(
          dMod,
          localSm.scheDays
              .firstWhere((sd) => sd.dayOfWeek == dMod.dayDT.weekday));
    } else {
      dayRef
          .where('date', isEqualTo: getDate(selectedDay))
          .where('scheduleId', isEqualTo: localSm.id)
          .get()
          .then((day) {
        if (day.docs.isNotEmpty) {
          DayModel localDm = DayModel.fromSnapshot(day.docs.first);
          localSm.addDayModel(localDm);
          noOfAppts[localDm.date] = localDm.curApptNum;
          setState(() {});
        } else {
          Map<String, dynamic> dayData = {
            'scheduleId': localSm.id,
            'year': selectedDay.year,
            'month': selectedDay.month,
            'day': selectedDay.day,
            'date': getDate(selectedDay),
            'dateInt': int.parse(DateFormat('yyyyMMdd').format(selectedDay)),
            'maxAppt': localSm.scheDays
                .firstWhere((sd) => sd.dayOfWeek == selectedDay.weekday)
                .maxAppt,
            'curApptNum': 0,
            'isHoliday': false,
            'holiName': '',
            'notes': '',
            'createdBy': auth.currentUser!.uid,
            'updatedBy': auth.currentUser!.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          };
          dayRef.add(dayData).then((onValue) {
            dayData['id'] = onValue.id;
            DayModel dayM = DayModel.fromJson(dayData);
            // dayListController.storeDayAndloadHours(dayM);
            widget.dayFn(
                dayM,
                localSm.scheDays
                    .firstWhere((sd) => sd.dayOfWeek == dayM.dayDT.weekday));
          });
        }
      });
    }

    setState(() {
      _focusedDay = focusedDay;
      selectedDaySet = {_focusedDay};
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text("Description: ${localSm.description}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: Text('Selected Date: ${getDate(_focusedDay)}'),
        initiallyExpanded: true,
        children: [
          // ElevatedButton(
          //     onPressed: () {
          //       // generate dayModels in back end
          //       setState(() {}); // change from '-' to 0
          //       // pop up to ask if wants to follow national holiday - oh yeahhh
          //     },
          //     child: Text('Generate ${getMonth(_focusedDay)}')),
          TableCalendar<Event>(
            // onPageChanged: (dt) {
            //   print(getDate(
            //       dt)); // try this oh yeahhh, hopefully it's what im expecting it to be
            // },
            firstDay: DateTime.now(), // kFirstDay,
            lastDay: DateTime(2023, 12, 31), // kLastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMM(locale).format(date),
              // titleCentered: true,
              // formatButtonVisible: false,
              // titleTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.width*0.007)
            ),
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            selectedDayPredicate: (day) {
              return selectedDaySet.contains(day);
            },
            enabledDayPredicate: (dt) => workingDays.contains(dt.weekday),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            calendarStyle: const CalendarStyle(
              markersAlignment: Alignment.bottomRight,
            ),
            calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
                defaultBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        // color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black)),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.black),
                    )),
                dowBuilder: (context, day) {
                  if ([5, 6].contains(day.weekday)) {
                    final text = DateFormat.E().format(day);
                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return null;
                },
                markerBuilder: (context, day, events) => Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlue,
                      ),
                      child: Text(
                        (noOfAppts[getDate(day)] ?? '-').toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    )),
          ),
          const SizedBox(height: 15),
        ]);
  }
}
