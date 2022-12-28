import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'utils.dart';

class MultiCalendar extends StatefulWidget {
  const MultiCalendar({super.key, required this.sd});
  final Set<DateTime> sd;

  @override
  // ignore: library_private_types_in_public_api
  _MultiCalendarState createState() => _MultiCalendarState();
}

class _MultiCalendarState extends State<MultiCalendar> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  late Set<DateTime> selectedDays;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    selectedDays = widget.sd;
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

  List<Event> _getEventsForDays(Set<DateTime> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    FocusScope.of(context).unfocus();
    if (selectedDays.length > 4) return;
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (selectedDays.contains(selectedDay)) {
        selectedDays.remove(selectedDay);
      } else {
        if (selectedDays.length < 4) selectedDays.add(selectedDay);
      }
    });
    // ignore: avoid_print
    // print(selectedDays.first);
    // _selectedEvents.value = _getEventsForDays(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar<Event>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(
            titleTextFormatter: (date, locale) =>
                DateFormat.yMMM(locale).format(date),
            // titleCentered: true,
            // formatButtonVisible: false,
            // titleTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.width*0.007)
          ),
          // eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          selectedDayPredicate: (day) {
            // Use values from Set to mark multiple days as selected
            return selectedDays.contains(day);
          },
          enabledDayPredicate: (dt) => [1, 2, 3, 4, 7].contains(dt.weekday),
          // holidayPredicate: (dt) => [5,6].contains(dt.weekday),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
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
            // markerBuilder: (context, day, events) => events.isNotEmpty
            //     ? Container(
            //         width: 16,
            //         height: 16,
            //         alignment: Alignment.center,
            //         decoration: const BoxDecoration(
            //           color: Colors.lightBlue,
            //         ),
            //         child: const Text(
            //           '288',
            //           style: TextStyle(color: Colors.white, fontSize: 8),
            //         ),
            //       )
            //     : null,
          ),
        ),
        // ElevatedButton(
        //   child: const Text('Clear selection'),
        //   onPressed: () {
        //     setState(() {
        //       selectedDays.clear();
        //       _selectedEvents.value = [];
        //     });
        //   },
        // ),
      ],
    );
  }
}
