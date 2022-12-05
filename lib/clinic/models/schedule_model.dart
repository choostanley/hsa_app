import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'day_model.dart';
import 'schedule_day.dart';

class ScheduleModel {
  late String id;
  late String name;
  late String description;
  late String clinicId;
  // late List<int> openDays; // how to save in MySql
  // late int startDayOfWeek; do we need this - nah let's standardize
  // late int maxAppt;
  // late int startHour; // inclusive
  // late int lunchStart;
  // late int lunchEnd;
  // late int endHour; // exclusive
  late int apptPerHalfHour;
  late String createdBy;
  late String createByName;
  late DateTime createdAt;
  late DateTime updatedAt;
  late List<ScheduleDay> scheDays;
  List<DayModel> days = [];
  bool daysInitiated = false;
  bool scheDayInitiated = false;

  ScheduleModel();

  ScheduleModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      name = snapshot.get('name');
      description = snapshot.get('description');
      clinicId = snapshot.get('clinicId');
      apptPerHalfHour = snapshot.get('apptPerHalfHour');
      createdBy = snapshot.get('createdBy');
      createByName = snapshot.get('createByName');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving schedule data', error.toString());
    }
  }

  ScheduleModel.fromJson(Map<String, dynamic> map) {
    try {
      id = map['id'];
      name = map['name'];
      description = map['description'];
      clinicId = map['clinicId'];
      apptPerHalfHour = map['apptPerHalfHour'];
      createdBy = map['createdBy'];
      createByName = map['createByName'];
      

      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
    } catch (error) {
      redSnackBar('Error retrieving schedule data', error.toString());
    }
  }

  Future<List<DayModel>> getDayModelList() async {
    await getScheDayList(); // because at SchedulePage, only called getDayModelList()
    if (daysInitiated) {
      return days;
    } else {
      QuerySnapshot<Object?> dayReqObjs =
          await dayRef.where('scheduleId', isEqualTo: id).get();

      days = dayReqObjs.docs.map((apt) => DayModel.fromSnapshot(apt)).toList();
      daysInitiated = true;
      return days;
    }
  }

  Future<List<ScheduleDay>> getScheDayList() async {
    if (scheDayInitiated) {
      return scheDays;
    } else {
      QuerySnapshot<Object?> scheDayReqObjs =
          await scheDayRef.where('scheduleId', isEqualTo: id).get();

      scheDays = scheDayReqObjs.docs
          .map((apt) => ScheduleDay.fromSnapshot(apt))
          .toList();
      scheDayInitiated = true;
      return scheDays;
    }
  }

  void addDayModel(DayModel dm) => days.add(dm);
}
