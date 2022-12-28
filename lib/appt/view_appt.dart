import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/appt_req.dart';
import 'package:hsa_app/appt/models/res_req.dart';
import 'package:hsa_app/clinic/models/appt.dart';
import 'package:hsa_app/common/firebase/firebase_const.dart';
import 'package:table_calendar/table_calendar.dart';
import '../clinic/controllers/controllers.dart';
import '../clinic/models/appt_time.dart';
import '../clinic/models/ar_dir.dart';
import '../clinic/models/day_model.dart';
import '../clinic/models/hour_model.dart';
import '../clinic/models/schedule_day.dart';
import '../clinic/models/schedule_model.dart';
import '../common/functions.dart';
import 'view_req.dart';
import 'widgets/end_drawer.dart';

import 'controllers/controllers.dart';
import 'package:intl/intl.dart';

import 'widgets/show_images.dart';

class ViewAppt extends StatefulWidget {
  const ViewAppt({super.key, required this.apt});
  final Appt apt;

  @override
  // ignore: library_private_types_in_public_api
  _ViewApptState createState() => _ViewApptState();
}

class _ViewApptState extends State<ViewAppt> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Appt appt;
  late String prefDate;
  late Future<List<ApptTime>> apptTimes;
  late Future<List<ApptReq>> refs;
  late Future<List<ResReq>> resReqs;
  final yourScrollController = ScrollController();

  @override
  void initState() {
    appt = widget.apt;
    apptTimes = getApptTimes(appt.id);
    refs = getReferrals();
    resReqs = getResReqs(appt.id);
    super.initState();
  }

  Future<List<ApptTime>> getApptTimes(String apptId) async {
    QuerySnapshot<Object?> aptT =
        await apptTimeRef.where('apptId', isEqualTo: apptId).get();
    if (aptT.docs.isNotEmpty) {
      return aptT.docs.map((dogg) => ApptTime.fromSnapshot(dogg)).toList();
    } else {
      return [];
    }
  }

  Future<List<ResReq>> getResReqs(String apptId) async {
    QuerySnapshot<Object?> rr =
        await resReqRef.where('apptId', isEqualTo: apptId).get();
    if (rr.docs.isNotEmpty) {
      return rr.docs.map((dogg) => ResReq.fromSnapshot(dogg)).toList();
    } else {
      return [];
    }
  }

  Future<List<ApptReq>> getReferrals() async {
    List<ApptReq> ars = [];
    await apptReqRef
        .where('ptId', isEqualTo: appt.ptId)
        .where('toClinicId', isEqualTo: appt.clinicId)
        .get()
        .then((onValue) {
      for (var aro in onValue.docs) {
        ars.add(ApptReq.fromSnapshot(aro));
      }
    });
    return ars;
  }

  List<ListTile> rrTiles(List<ResReq> rrList) => rrList.map((ar) {
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(ar.reason),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferred time: ${DateFormat('dd-MM-yyyy kk:mm').format(ar.prefApptTime)}',
                  overflow: TextOverflow.ellipsis,
                ),
                Text(ar.approved
                    ? 'Approved'
                    : ar.rejected
                        ? 'Rejected'
                        : 'Pending'),
                if (ar.response.isNotEmpty) Text('Reply: ${ar.response}'),
              ],
            ),
          ),
        );
      }).toList();

  List<ListTile> arTiles(List<ApptReq> arList) => arList.map((ar) {
        String prefDates = ar.prefApptTime
            .map((dt) => DateFormat('dd-MM-yyyy').format(dt))
            .join(' / ');
        return ListTile(
          onTap: () =>
              Get.to(ViewReq(ar: ar, pd: prefDates, fromViewAppt: true)),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(ar.toClinicName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar.remarks,
                overflow: TextOverflow.ellipsis,
              ),
              ShowImages(ar.refLetterUrl),
            ],
          ),
        );
      }).toList();

  Container atTile(ApptTime aptt, int no) {
    // add margin
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(right: 3, top: 1.5, bottom: 2),
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      width: 160,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, top: 5, bottom: 0),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        title: Text(
          '${no.toString()}. ${DateFormat('dd-MM-yyyy kk:mm').format(aptt.apptTime)}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0), // this mtfk removed the listTile top padding wtf
          // style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(aptt.rescheduled ? '    Rescheduled' : '    Active'),
      ),
    );
  }

  Future<List<HourModel>> storeDayAndloadHours(
      DayModel dm, ScheduleDay sDay) async {
    var result = await dm.getHourModelList(sDay);
    return result;
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
      _dayHours = await storeDayAndloadHours(day, sDay);
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
            _dayHours = await storeDayAndloadHours(day, sDay);
            _dayHours.sort((a, b) => a.startDT.compareTo(b.startDT));
            _hourRow.value = _dayHours;
          });
        }
      });
    }
  }

  List<HourModel> _dayHours = [];
  ScheduleModel generalSc = ScheduleModel();
  late Map<String, int> noOfAppts;
  late List<int> workingDays;
  DateTime _focusedDay = DateTime.now();
  late Set<DateTime> selectedDaySet = <DateTime>{};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ValueNotifier<List<HourModel>> _hourRow =
      ValueNotifier<List<HourModel>>([]);
  final ValueNotifier<Widget> calender = ValueNotifier<Widget>(Container());
  // Widget calender = Container();
  OverlayEntry? overlayEntry;
  final yourScrollController1 = ScrollController();
  DateTime? pickedHr;
  TextEditingController reaCont = TextEditingController(text: '');

  Future<TableCalendar> createCalender(ScheduleModel localSc) async {
    await localSc.getDayModelList();
    noOfAppts = {for (var e in localSc.days) e.date: e.curApptNum};
    workingDays = localSc.scheDays
        .where((sd) => !sd.holiday)
        .map((sdm) => sdm.dayOfWeek)
        .toList();
    return TableCalendar(
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
        // setState(() {
        calender.value = newCal;
        // });
      },
      onFormatChanged: (format) async {
        if (_calendarFormat != format) {
          _calendarFormat = format;
          Widget newCal = await createCalender(generalSc);
          // setState(() {
          calender.value = newCal;
          // });
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

        // later add pt already number of appt in markerBuilder

        // markerBuilder: (context, day, events) {
        //   List<String> dates =
        //       localAr.prefApptTime.map((aiyaa) => getDate(aiyaa)).toList();
        //   // print(dates);
        //   // print(getDate(day));
        //   return Container(
        //     width: 16,
        //     height: 16,
        //     alignment: Alignment.center,
        //     decoration: BoxDecoration(
        //         color: Colors.lightBlue,
        //         border: Border.all(
        //             width: 2.5,
        //             color: dates.contains(getDate(day))
        //                 ? Colors.red
        //                 : Colors.lightBlue)),
        //     child: Text(
        //       (noOfAppts[getDate(day)] ?? '-')
        //           .toString(), // this noOfAppts apparently updated after appt created
        //       style: const TextStyle(color: Colors.white, fontSize: 8),
        //     ),
        //   );
        // }
      ),
    );
  }

  void removeOverlay() {
    overlayEntry!.remove();
  }

  void _showOverlay(
    BuildContext context,
  ) async {
    OverlayState? overlayState = Overlay.of(context);
    DocumentSnapshot<Object?> scheObj =
        await scheduleRef.doc(appt.scheduleId).get();
    generalSc = ScheduleModel.fromSnapshot(scheObj);
    calender.value = await createCalender(generalSc);

    overlayEntry = OverlayEntry(builder: (context) {
      return StatefulBuilder(builder: (context, StateSetter setState) {
        return Material(
          color: Colors.white.withOpacity(0.95),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () => removeOverlay(),
                          ),
                        ],
                      ),
                      const Text('  Reschedule to same day in not allowed',
                          style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<Widget>(
                          valueListenable: calender,
                          builder: (context, value, _) {
                            return value;
                          }),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
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
                                          bool sameDay = appt.dateString ==
                                              getDate(localHr.startDateTime);
                                          String apptNo =
                                              localHr.lunchHour ? '[LHr]' : '';
                                          String apptMasa = DateFormat(
                                                  index == 0
                                                      ? 'HH:mm'
                                                      : 'kk:mm')
                                              .format(localHr.startDateTime);
                                          return Container(
                                            key: Key(getRandomString(4)),
                                            margin:
                                                const EdgeInsets.only(right: 2),
                                            decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: (!stillCanAdd || sameDay)
                                                    ? Colors.grey
                                                    : pickedHr ==
                                                            localHr
                                                                .startDateTime
                                                        ? Colors.blue
                                                        : Colors.white),
                                            width: 150,
                                            child: ListTile(
                                              title:
                                                  Text('${apptMasa}H  $apptNo'),
                                              dense: true,
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: -2,
                                                      vertical: -2),
                                              onTap: (!stillCanAdd || sameDay)
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        pickedHr = localHr
                                                            .startDateTime;
                                                      });
                                                      // _hourRow.value = _dayHours;
                                                    },
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
                      Text(
                          'Picked time: ${pickedHr == null ? '' : DateFormat('dd/MM/yyyy kk:mm').format(pickedHr!)}'),
                      const SizedBox(height: 5),
                      TextFormField(
                        key: const ValueKey('Reason'),
                        keyboardType: TextInputType.name,
                        controller: reaCont,
                        decoration: const InputDecoration(
                            labelText: 'Reason',
                            contentPadding: EdgeInsets.all(6)),
                        // validator: (val) {
                        //   if (val!.trim().isEmpty) {
                        //     return 'Remark is required!';
                        //   }
                        //   return null;
                        // },
                      ),
                      ElevatedButton(
                        onPressed: () => submitRes(),
                        child: const Text('Request'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
    overlayState!.insert(overlayEntry!);
  }

  void submitRes() async {
    if (pickedHr == null || reaCont.text.trim().isEmpty) {
      redSnackBar('Error', 'Please complete form before request');
      return;
    }
    int xianzai = DateTime.now().millisecondsSinceEpoch;
    await resReqRef.add({
      'ptName': appt.ptName,
      'apptId': appt.id,
      'clinicId': appt.clinicId,
      'scheduleId': appt.scheduleId,
      'attById': '',
      'attByName': '',
      'iniApptTimeInt': appt.dateTimeStampInt,
      'prefApptTimeInt': pickedHr!.millisecondsSinceEpoch,
      'reason': reaCont.text.trim(),
      'response': '',
      'approved': false,
      'rejected': false,
      'createdAt': xianzai,
      'updatedAt': xianzai,
      'screenedAt': 0,
    });
    removeOverlay();

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => resReqs = getResReqs(appt.id));
      greenSnackBar('Success', 'Reschedule request sent!');
    });
    // Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('view appt'.tr),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 30,
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          )
        ],
      ),
      endDrawer: EndDrawer(ptListController.currentPt.value.id),
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Text("Clinic: ${appt.clinicName}",
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Schedule: ${appt.scheduleName}",
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              "Notes: ${appt.approveRemarks}", // later give appt again whatever message save here
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(appt.attended ? 'Attended' : 'Not yet attend',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 10),
          Text("Patient: ${appt.ptName}", style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text("Pt Ic: ${appt.ptIc}", style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
              "Appt Time: ${DateFormat('dd/MM/yyyy kk:mm').format(appt.dateTimeStamp)}",
              style: const TextStyle(fontSize: 15)),
          ExpansionTile(
            title: const Text('List of Referrals'),
            children: [
              FutureBuilder<List<ApptReq>>(
                  future: refs,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ApptReq>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<ApptReq> arList = snapshot.data!;
                      arList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Column(children: arTiles(arList));
                    } else {
                      return const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator());
                    }
                  })
            ],
          ),
          ExpansionTile(
            leading: ElevatedButton(
                onPressed: !appt.attended
                    // appt.dateTimeStamp.isBefore(DateTime.now())
                    ? () => _showOverlay(context)
                    : null,
                child: const Text('Request')),
            title: const Text('Reschedules'),
            children: [
              FutureBuilder<List<ResReq>>(
                  future: resReqs,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ResReq>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<ResReq> rrList = snapshot.data!;
                      rrList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Column(children: rrTiles(rrList));
                    } else {
                      return const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator());
                    }
                  })
            ],
          ),
          // const SizedBox(height: 8),
          // ShowImages(apptReq.refLetterUrl),
          const SizedBox(height: 18),
          const Text('Appointment:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          FutureBuilder<List<ApptTime>>(
              future: apptTimes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ApptTime>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<ApptTime> atList = snapshot.data!;
                  atList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return Scrollbar(
                    thumbVisibility: true,
                    thickness: 10,
                    controller: yourScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ListView.builder(
                        controller: yourScrollController,
                        shrinkWrap: true,
                        itemCount: atList.length,
                        itemBuilder: (context, index) {
                          return atTile(atList[index], atList.length - (index));
                        },
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator());
                }
              })
        ],
      ),
    );
  }
}
