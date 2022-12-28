import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../appt/models/holiday.dart';
import '../clinic/helpers/routes.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class NewHoliday extends StatefulWidget {
  const NewHoliday({super.key});

  @override
  State<NewHoliday> createState() => _NewHolidayState();
}

class _NewHolidayState extends State<NewHoliday> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TextEditingController nameCont = TextEditingController(text: '');
  bool loading = false;

  void submitHoliday() async {
    DateTime? startDate = _selectedDay ?? _rangeStart;
    String endString = _rangeEnd == null ? '' : getDate(_rangeEnd!);
    if (startDate == null || nameCont.text.trim().isEmpty) {
      redSnackBar('Error', 'Please complete form before request');
      return;
    }
    setState(() => loading = true);
    int xianzai = DateTime.now().millisecondsSinceEpoch;
    try {
      await holidayRef.add({
        'holidayName': nameCont.text.trim(),
        'startDateTimeInt': startDate.millisecondsSinceEpoch,
        'startDate': getDate(startDate),
        'endDate': endString,
        'endDateTimeInt':
            endString == '' ? 0 : _rangeEnd!.millisecondsSinceEpoch,
        'clinicId': clinicListController.currentCl.value.id,
        'clinicName': clinicListController.currentCl.value.name,
        'createdById': userController.user.id,
        'createdByName': userController.user.name,
        'createdAt': xianzai,
        'updatedAt': xianzai,
      });
    } catch (e) {
      redSnackBar('Error', 'Unable to create holiday');
    }
    setState(() {
      loading = false;
      _selectedDay = null;
      _rangeStart = null;
      _rangeEnd = null;
      nameCont.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('New Public Holiday'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(newHolidayRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Colors.white,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        key: const ValueKey('name'),
                        keyboardType: TextInputType.name,
                        controller: nameCont,
                        decoration: const InputDecoration(
                            labelText: 'Holiday Name',
                            contentPadding: EdgeInsets.all(6)),
                      ),
                      TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime(2023, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        calendarFormat: _calendarFormat,
                        rangeSelectionMode: _rangeSelectionMode,
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _rangeStart = null; // Important to clean those
                              _rangeEnd = null;
                              _rangeSelectionMode =
                                  RangeSelectionMode.toggledOff;
                            });
                          }
                        },
                        onRangeSelected: (start, end, focusedDay) {
                          setState(() {
                            _selectedDay = null;
                            _focusedDay = focusedDay;
                            _rangeStart = start;
                            _rangeEnd = end;
                            _rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },
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
                      ),
                      ElevatedButton(
                          onPressed: loading ? null : () => submitHoliday(),
                          child: const Text('Create Holiday')),
                      const SizedBox(height: 10),
                      Text(
                          'Holidays under ${clinicListController.currentCl.value.name}:'),
                      StreamBuilder<QuerySnapshot<Object?>>(
                          stream: holidayRef
                              .where('clinicId',
                                  isEqualTo:
                                      clinicListController.currentCl.value.id)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return const Text('No Stream :(');
                              // break;
                              case ConnectionState.waiting:
                                return const Text('Still Waiting...');
                              // break;
                              case ConnectionState.active:
                                List<QueryDocumentSnapshot<Object?>> ss =
                                    snapshot.data!.docs;
                                List<Holiday> holidays = ss
                                    .map((obj) => Holiday.fromSnapshot(obj))
                                    .toList();
                                holidays.sort((a, b) => a.startDateTimeInt
                                    .compareTo(b.startDateTimeInt));
                                return Center(
                                    child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 500),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: holidays
                                                .map((apt) => ListTile(
                                                      tileColor: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                            color: Colors.black,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      title:
                                                          Text(apt.holidayName),
                                                      subtitle: Text(
                                                        apt.getTimeFrame(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        )));
                              case ConnectionState.done:
                                return const Text('Done. That\'s all');
                            }
                          })
                    ],
                  ),
                ),
              ),
            )));
  }
}
