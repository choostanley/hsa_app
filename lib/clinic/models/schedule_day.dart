import 'package:cloud_firestore/cloud_firestore.dart';
import '/common/functions.dart';

class ScheduleDay {
  late String id;
  late String scheduleId;
  late int dayOfWeek;
  late bool holiday;
  late String startWork;
  late String lunchTime;
  late String lunchTimeOver;
  late String finishWork;
  late int apptPerHalfHour;
  late int maxAppt;
  late String createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;

  ScheduleDay();

  ScheduleDay.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      scheduleId = snapshot.get('scheduleId');
      dayOfWeek = snapshot.get('dayOfWeek');
      holiday = snapshot.get('holiday');
      startWork = snapshot.get('startWork');
      lunchTime = snapshot.get('lunchTime');
      lunchTimeOver = snapshot.get('lunchTimeOver');
      finishWork = snapshot.get('finishWork');
      apptPerHalfHour = snapshot.get('apptPerHalfHour');
      maxAppt = snapshot.get('maxAppt');
      createdBy = snapshot.get('createdBy');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // if (apptReqId.isNotEmpty) getApptReq();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving schedule data', error.toString());
    }
  }
}
