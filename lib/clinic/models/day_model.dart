import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_day.dart';
import '../../common/firebase/firebase_const.dart';
import 'hour_model.dart';

import '/common/functions.dart';

class DayModel {
  late String id;
  late String scheduleId;
  late int year;
  late int month;
  late int day;
  late String date;
  late DateTime dayDT;
  late int dateInt; // yyyymmdd 20221231 to get larger than this date
  late int maxAppt;
  late int curApptNum;
  late List<HourModel> hours;
  late bool isHoliday;
  late String holiName;
  late String notes;
  late String createdBy;
  late String updatedBy;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool hoursInitiated = false;

  DayModel();

  DayModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      scheduleId = snapshot.get('scheduleId');
      year = snapshot.get('year');
      month = snapshot.get('month');
      day = snapshot.get('day');
      date = snapshot.get('date');
      dayDT = DateTime(year, month, day);
      dateInt = snapshot.get('dateInt');
      maxAppt = snapshot.get('maxAppt');
      curApptNum = snapshot.get('curApptNum');
      isHoliday = snapshot.get('isHoliday');
      holiName = snapshot.get('holiName');
      notes = snapshot.get('notes');
      createdBy = snapshot.get('createdBy');
      updatedBy = snapshot.get('updatedBy');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // if (apptReqId.isNotEmpty) getApptReq();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving day data', error.toString());
    }
  }

  DayModel.fromJson(Map<String, dynamic> map) {
    try {
      id = map['id'];
      scheduleId = map['scheduleId'];
      year = map['year'];
      month = map['month'];
      day = map['day'];
      date = map['date'];
      dayDT = DateTime(year, month, day);
      dateInt = map['dateInt'];
      maxAppt = map['maxAppt'];
      curApptNum = map['curApptNum'];
      isHoliday = map['isHoliday'];
      holiName = map['holiName'];
      notes = map['notes'];
      createdBy = map['createdBy'];
      updatedBy = map['updatedBy'];

      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
    } catch (error) {
      redSnackBar('Error retrieving day data', error.toString());
    }
  }

  Future<List<HourModel>> getHourModelList(ScheduleDay sDay) async {
    if (isHoliday) return [];
    if (hoursInitiated) {
      return hours;
    } else {
      QuerySnapshot<Object?> hourObjs =
          await hourRef.where('dayId', isEqualTo: id).get();
      if (hourObjs.docs.isEmpty) {
        hours = await createHours(sDay);
      } else {
        hours =
            hourObjs.docs.map((apt) => HourModel.fromSnapshot(apt)).toList();
        hours.sort((a, b) => a.startDT.compareTo(b.startDT));
      }
      hoursInitiated = true;
      return hours;
    }
  }

  int getMin(String h24) =>
      int.parse(h24.replaceAll(RegExp(r'[^0-9]'), '').substring(2));

  int getHr(String h24) =>
      int.parse(h24.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 2));

  DateTime getDT(String startWork) =>
      DateTime(year, month, day, getHr(startWork), getMin(startWork));

  DateTime getNextHalfHour(DateTime prevHr) => DateTime(
      year,
      month,
      day,
      prevHr.minute >= 30 ? prevHr.hour + 1 : prevHr.hour,
      prevHr.minute >= 30 ? 0 : 30);

  Future<List<HourModel>> createHours(ScheduleDay sDay) async {
    List<HourModel> newList = [];
    DateTime marker = getDT(sDay.startWork);
    DateTime lunch = getDT(sDay.lunchTime);
    DateTime lunchOver = getDT(sDay.lunchTimeOver);
    DateTime finishWork = getDT(sDay.finishWork);
    bool lunchTime = false;
    bool ltDone = false;
    while (marker != finishWork) {
      // think what of no lunch time
      DateTime nextHalf = getNextHalfHour(marker);
      if (lunchTime) {
        nextHalf = lunchOver;
        ltDone = true;
      }
      if (nextHalf.isAfter(finishWork)) {
        nextHalf = finishWork;
      } else if (!lunch.isAtSameMomentAs(lunchOver) &&
          (nextHalf.isAtSameMomentAs(lunch) || nextHalf.isAfter(lunch))) {
        if (!ltDone) {
          lunchTime = true;
          nextHalf = lunch;
        }
      }
      double durationHour = nextHalf.difference(marker).inMinutes / 60;
      Map<String, dynamic> hourData = {
        'scheduleId': scheduleId,
        'dayId': id,
        'startDT': marker.millisecondsSinceEpoch,
        'endDT': nextHalf.millisecondsSinceEpoch,
        'durationHour': durationHour,
        'lunchHour': (lunchTime && ltDone),
        'apptPerHalfHour': (lunchTime && ltDone) ? 0 : sDay.apptPerHalfHour,
        'maxForThisSlot': (lunchTime && ltDone)
            ? 0
            : ((sDay.apptPerHalfHour * 2) * durationHour).ceil(),
        'curApptNum': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch
      };
      hourRef.add(hourData).then((onValue) {
        hourData['id'] = onValue.id;
        newList.add(HourModel.fromJson(hourData));
      });
      if (lunchTime && ltDone) lunchTime = false;
      marker = nextHalf;
    }
    return newList;
  }
}
