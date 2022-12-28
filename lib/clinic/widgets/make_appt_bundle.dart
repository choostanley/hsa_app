import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/appt_req.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';
import 'package:hsa_app/clinic/models/day_model.dart';
import 'package:hsa_app/clinic/models/schedule_day.dart';
import 'package:hsa_app/clinic/models/schedule_model.dart';
import 'package:hsa_app/common/functions.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../common/firebase/firebase_const.dart';
import '../helpers/routes.dart';
import '../models/appt.dart';
import '../models/hour_model.dart';
import 'utils.dart';
import '../helpers/between_range_datetime.dart';

class MakeApptBundle extends StatefulWidget {
  const MakeApptBundle(
      {super.key, required this.ar, required this.smList, this.open = true});
  final ApptReq ar;
  final List<ScheduleModel> smList;
  final bool open;
  // final void Function(DayModel pickedDay, ScheduleDay scheduleDay) dayFn;

  @override
  // ignore: library_private_types_in_public_api
  _MakeApptBundleState createState() => _MakeApptBundleState();
}

class _MakeApptBundleState extends State<MakeApptBundle> {
  late Set<DateTime> selectedDaySet = <DateTime>{};
  late Map<String, int> noOfAppts;
  late List<int> workingDays;
  final ValueNotifier<List<HourModel>> _hourRow =
      ValueNotifier<List<HourModel>>([]);
  Widget calender = Container();
  ScheduleModel? chosedSm;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  bool creatingAppt = false;
  late ApptReq localAr;
  TextEditingController remCont = TextEditingController(text: '');
  ScheduleModel generalSc = ScheduleModel();
  List<HourModel> _dayHours = [];
  final yourScrollController = ScrollController();
  final yourScrollController1 = ScrollController();
  bool screened = false;
  late DateTimeRange range; // try use

  @override
  void initState() {
    localAr = widget.ar;
    if (localAr.screenedById != '') {
      if (localAr.screenedDurEndInt != 0) {
        DateTime sAnchor =
            localAr.createdAt.add(Duration(days: localAr.screenedDurStartInt));
        DateTime eAnchor =
            localAr.createdAt.add(Duration(days: localAr.screenedDurEndInt));
        range = DateTimeRange(
            start: DateTime(sAnchor.year, sAnchor.month, sAnchor.day),
            end:
                DateTime(eAnchor.year, eAnchor.month, eAnchor.day, 23, 59, 59));
      } else {
        DateTime expectedAnchor =
            localAr.createdAt.add(Duration(days: localAr.screenedDurStartInt));
        DateTime sDate = expectedAnchor.subtract(const Duration(days: 4));
        DateTime eDate = expectedAnchor.add(const Duration(days: 4));
        range = DateTimeRange(
            start: DateTime(sDate.year, sDate.month, sDate.day),
            end: DateTime(eDate.year, eDate.month, eDate.day, 23, 59, 59));
      }
    }
    if ((widget.smList.length == 1) || localAr.screenedScheId.isNotEmpty) {
      onlyOneSm();
    }
    super.initState();
  }

  void onlyOneSm() async {
    generalSc = widget.smList.first;
    if (localAr.screenedScheId.isNotEmpty) {
      generalSc =
          widget.smList.firstWhere((sm) => sm.id == localAr.screenedScheId);
    }
    Widget onlyCal = await createCalender(generalSc);
    setState(() {
      chosedSm = widget.smList.first;
      calender = onlyCal;
    });
  }

  @override
  void dispose() {
    _hourRow.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _focusedDay = focusedDay;
      selectedDaySet = {_focusedDay};
    });
    if (noOfAppts.keys.contains(getDate(selectedDay))) {
      DayModel day = generalSc.days
          .firstWhere((day) => getDate(_focusedDay) == getDate(day.dayDT));
      ScheduleDay sDay = generalSc.scheDays
          .firstWhere((sd) => sd.dayOfWeek == day.dayDT.weekday);
      _dayHours = await dayListController.storeDayAndloadHours(day, sDay);
      _dayHours.sort((a, b) => a.startDT.compareTo(b.startDT));
      _hourRow.value = _dayHours;
    } else {
      dayRef
          .where('date', isEqualTo: getDate(selectedDay))
          .where('scheduleId', isEqualTo: generalSc.id)
          .get()
          .then((day) {
        if (day.docs.isNotEmpty) {
          DayModel localDm = DayModel.fromSnapshot(day.docs.first);
          generalSc.addDayModel(localDm);
          noOfAppts[localDm.date] = localDm.curApptNum;
          setState(() {});
        } else {
          Map<String, dynamic> dayData = {
            'scheduleId': generalSc.id,
            'year': selectedDay.year,
            'month': selectedDay.month,
            'day': selectedDay.day,
            'date': getDate(selectedDay),
            'dateInt': int.parse(DateFormat('yyyyMMdd').format(selectedDay)),
            'maxAppt': generalSc.scheDays
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
          dayRef.add(dayData).then((onValue) async {
            dayData['id'] = onValue.id;
            DayModel day = DayModel.fromJson(dayData);
            ScheduleDay sDay = generalSc.scheDays
                .firstWhere((sd) => sd.dayOfWeek == day.dayDT.weekday);
            // dayListController.storeDayAndloadHours(day, sDay);
            _dayHours = await dayListController.storeDayAndloadHours(day, sDay);
            _dayHours.sort((a, b) => a.startDT.compareTo(b.startDT));
            _hourRow.value = _dayHours;
          });
        }
      });
    }

    // setState(() {
    //   _focusedDay = focusedDay;
    //   selectedDaySet = {_focusedDay};
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        tilePadding: const EdgeInsets.all(8),
        title: Text(chosedSm != null ? chosedSm!.name : 'Choose a Schedule',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: chosedSm != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected Date: ${getDate(_focusedDay)}'),
                  Row(children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          border: Border.all(width: 2.5, color: Colors.red)),
                    ),
                    const Text(' = Patient preferred dates.'),
                  ]),
                  if (localAr.screenedById != '')
                    const Text('Appt to be given between:'),
                  if (localAr.screenedById != '')
                    Text(
                        '   ${getDate(range.start)}  till  ${getDate(range.end)}'),
                  // insert here
                ],
              )
            : null,
        initiallyExpanded: widget.open,
        children: [
          SizedBox(
            height: 50,
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 10,
              controller: yourScrollController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    controller: yourScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.smList.length,
                    itemBuilder: (context, index) {
                      ScheduleModel nowie = widget.smList[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5)),
                        width: 150,
                        child: RadioListTile<ScheduleModel>(
                          selected: generalSc == nowie,
                          title:
                              Text(nowie.name, overflow: TextOverflow.ellipsis),
                          value: nowie,
                          groupValue: generalSc,
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: -3, vertical: -3),
                          onChanged: (ScheduleModel? value) async {
                            // setState(() async {
                            generalSc = value!;
                            Widget newCal = await createCalender(generalSc);
                            setState(() {
                              generalSc = value;
                              chosedSm = value;
                              calender = newCal;
                              _hourRow.value = [];
                            });
                          },
                        ),
                      );
                    }),
              ),
            ),
          ),
          calender,
          const SizedBox(height: 5),
          ValueListenableBuilder<List<HourModel>>(
            valueListenable: _hourRow,
            builder: (context, value, _) {
              return value.isEmpty
                  ? Container()
                  : SizedBox(
                      height: 55,
                      child: Scrollbar(
                        thumbVisibility: true,
                        thickness: 10,
                        controller: yourScrollController1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ListView.builder(
                            // shrinkWrap: true,
                            controller: yourScrollController1,
                            scrollDirection: Axis.horizontal,
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              HourModel localHr = value[index];
                              int curNo = localHr.curApptNum;
                              int maxNo = localHr.maxForThisSlot;
                              bool stillCanAdd = (maxNo > curNo) &&
                                  (localHr.startDateTime
                                      .isAfter(DateTime.now()));
                              String apptNo = localHr.lunchHour
                                  ? '[LHr]'
                                  : '[$curNo/$maxNo]';
                              String apptTime =
                                  DateFormat(index == 0 ? 'HH:mm' : 'kk:mm')
                                      .format(localHr.startDateTime);
                              return Container(
                                margin: const EdgeInsets.only(right: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(5)),
                                width: 150,
                                child: ListTile(
                                  title: Text('${apptTime}H  $apptNo'),
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                      horizontal: -2, vertical: -2),
                                  trailing: IconButton(
                                    color: Colors.lightBlueAccent,
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: stillCanAdd
                                        ? () {
                                            Get.defaultDialog(
                                              barrierDismissible:
                                                  creatingAppt ? false : true,
                                              title: 'Make Appointment',
                                              content: StatefulBuilder(builder:
                                                  (context,
                                                      StateSetter setState) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                        'Make appointment under ${generalSc.name} \n at ${apptTime}H on ${getDate(localHr.startDateTime)}'),
                                                    TextFormField(
                                                      key: const ValueKey(
                                                          'remark'),
                                                      keyboardType:
                                                          TextInputType.name,
                                                      controller: remCont,
                                                      validator: (val) {
                                                        if (val!
                                                            .trim()
                                                            .isEmpty) {
                                                          return 'Remark is required!';
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Remark',
                                                      ),
                                                      onSaved: (value) {
                                                        remCont.text =
                                                            value!.trim();
                                                      },
                                                    ),
                                                    const SizedBox(height: 8),
                                                    creatingAppt
                                                        ? const CircularProgressIndicator()
                                                        : ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                creatingAppt =
                                                                    true;
                                                              });
                                                              String that =
                                                                  await createAppt(
                                                                      localHr);
                                                              Get.back();
                                                              if (that ==
                                                                  'Good Shit') {
                                                                creatingAppt =
                                                                    false;
                                                                Get.offNamedUntil(
                                                                    receivedRefRoute,
                                                                    (route) =>
                                                                        false);
                                                              }
                                                            },
                                                            child: const Text(
                                                                'Confirm'))
                                                  ],
                                                );
                                              }),
                                              // ),
                                              // confirm:
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
            },
          ),
          const SizedBox(height: 5),
        ]);
  }

  Future<String> createAppt(HourModel hr) async {
    try {
      Map<String, dynamic> apptData = {
        'ptId': localAr.ptId,
        'ptIc': localAr.ptIc,
        'clinicName': clinicListController.currentCl.value.name,
        'clinicId': clinicListController.currentCl.value.id,
        'scheduleId': generalSc.id,
        'scheduleName': generalSc.name,
        'dateString': getDate(hr.startDateTime),
        'dateTimeStampInt': hr.startDateTime.millisecondsSinceEpoch,
        'staffId': auth.currentUser!.uid,
        'apptReqId': localAr.id,
        'approveRemarks': remCont.text.trim(),
        'active': true,
        'attended': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'hrId': hr.id, // temporary
        'ptName': localAr.ptName, // temporary
      };
      Map<String, dynamic> apptTimeData = {
        'dayId': hr.dayId,
        'hourId': hr.id,
        'apptTimeInt': hr.startDateTime.millisecondsSinceEpoch,
        'rescReason': '', // reschedule reason
        'active': true,
        'rescheduled': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      Map<String, dynamic> arData = {
        'givenApptById': userController.user.id,
        'givenApptByName': userController.user.name,
      };
      if (localAr.screenedById == '') {
        int screenDur = hr.startDateTime.difference(localAr.createdAt).inDays;
        arData['screenedById'] = userController.user.id;
        arData['screenedByName'] = userController.user.name;
        arData['screenedDurStart'] = '$screenDur Day';
        arData['screenedDurStartInt'] = screenDur;
        // apptGivenAt
        // screenedAt
        // screenedScheId
        // screenedScheName
      }
      Appt apptModelInstant = Appt();
      await apptRef.add(apptData).then((onValue) {
        // print('reached');
        apptData['id'] = onValue.id;
        apptModelInstant = Appt.fromJson(apptData);
        apptTimeData['apptId'] = onValue.id;
        apptTimeRef.add(apptTimeData);
      });
      int han = await hourRef
              .doc(hr.id)
              .get()
              .then((snapshot) => snapshot.get('curApptNum'))
          as int; // hour appt no.
      int dan = await dayRef
              .doc(hr.dayId)
              .get()
              .then((snapshot) => snapshot.get('curApptNum'))
          as int; // day appt no.
      QuerySnapshot<Object?> arDir = await arDirRef
          .where('arId', isEqualTo: localAr.id)
          .where('active', isEqualTo: true)
          .where('accepted', isEqualTo: false)
          .get();
      if (arDir.docs.isNotEmpty) {
        String arDirId = arDir.docs.first.id;
        await arDirRef
            .doc(arDirId)
            .update({'accepted': true, 'apptId': apptData['id']});
      }
      await hourRef.doc(hr.id).update({'curApptNum': han + 1});
      await dayRef.doc(hr.dayId).update({'curApptNum': dan + 1});
      await apptReqRef.doc(localAr.id).update(arData);
      //   {'givenApptById': userController.user.id,
      //   'givenApptByName': userController.user.name,}
      // .update({'attById': auth.currentUser!.uid});
      dayListController.updateHourAppt(hr.dayId, hr.id);
      hourApptListController.updateHourModel(hr, apptModelInstant);
      return 'Good Shit';
    } catch (error) {
      redSnackBar('Error Creating Appointment', error.toString());
      return error.toString();
    }
  }

  Future<TableCalendar> createCalender(ScheduleModel localSc) async {
    await localSc.getDayModelList();
    noOfAppts = {for (var e in localSc.days) e.date: e.curApptNum};
    workingDays = localSc.scheDays
        .where((sd) => !sd.holiday)
        .map((sdm) => sdm.dayOfWeek)
        .toList();
    return TableCalendar<Event>(
      firstDay: DateTime.now(), // kFirstDay,
      lastDay: DateTime(2023, 12, 31), // kLastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      headerStyle: HeaderStyle(
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMM(locale).format(date),
      ),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      selectedDayPredicate: (day) {
        return selectedDaySet.contains(day);
      },
      enabledDayPredicate: (dt) => workingDays.contains(dt.weekday),
      onDaySelected: (dt1, dt2) async {
        _onDaySelected(dt1, dt2);
        Widget newCal = await createCalender(generalSc);
        setState(() {
          calender = newCal;
        });
      },
      onFormatChanged: (format) async {
        if (_calendarFormat != format) {
          _calendarFormat = format;
          Widget newCal = await createCalender(generalSc);
          setState(() {
            calender = newCal;
          });
        }
      },
      // onPageChanged: (focusedDay) {
      //   setState(() => _focusedDay = focusedDay);
      // },
      calendarStyle: const CalendarStyle(
        markersAlignment: Alignment.bottomRight,
      ),
      calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, events) => Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: localAr.screenedById == ''
                      ? Theme.of(context).primaryColor
                      : range.isWithinRange(date)
                          ? Theme.of(context).primaryColor
                          : Colors.pink,
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
          markerBuilder: (context, day, events) {
            List<String> dates =
                localAr.prefApptTime.map((aiyaa) => getDate(aiyaa)).toList();
            // print(dates);
            // print(getDate(day));
            return Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  border: Border.all(
                      width: 2.5,
                      color: dates.contains(getDate(day))
                          ? Colors.red
                          : Colors.lightBlue)),
              child: Text(
                (noOfAppts[getDate(day)] ?? '-')
                    .toString(), // this noOfAppts apparently updated after appt created
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            );
          }),
    );
  }
}
