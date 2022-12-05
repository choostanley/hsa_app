import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hsa_app/clinic/models/appt.dart';

import '../../common/firebase/firebase_const.dart';
import '/common/functions.dart';

class HourModel {
  late String id;
  late String scheduleId;
  late String dayId;
  late int startDT;
  late int endDT;
  late DateTime startDateTime;
  // late int hour;
  late double durationHour;
  late bool lunchHour;
  late int apptPerHalfHour; // maxAppt for hour
  late int maxForThisSlot; // change to half hour
  late int curApptNum;
  late List<Appt> appts;
  late DateTime createdAt;
  late DateTime updatedAt;

  bool apptInitiated = false;

  // durationHour - double

  HourModel();

  HourModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      scheduleId = snapshot.get('scheduleId');
      dayId = snapshot.get('dayId');
      startDT = snapshot.get('startDT');
      endDT = snapshot.get('endDT');
      startDateTime = DateTime.fromMillisecondsSinceEpoch(startDT);
      durationHour = snapshot.get('durationHour');
      lunchHour = snapshot.get('lunchHour');
      apptPerHalfHour = snapshot.get('apptPerHalfHour');
      maxForThisSlot = snapshot.get('maxForThisSlot');
      curApptNum = snapshot.get('curApptNum');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // if (apptReqId.isNotEmpty) getApptReq();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving hour data', error.toString());
    }
  }

  HourModel.fromJson(Map<String, dynamic> map) {
    try {
      id = map['id'];
      scheduleId = map['scheduleId'];
      dayId = map['dayId'];
      startDT = map['startDT'];
      endDT = map['endDT'];
      startDateTime = DateTime.fromMillisecondsSinceEpoch(startDT);
      durationHour = map['durationHour'];
      lunchHour = map['lunchHour'];
      apptPerHalfHour = map['apptPerHalfHour'];
      maxForThisSlot = map['maxForThisSlot'];
      curApptNum = map['curApptNum'];

      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
    } catch (error) {
      redSnackBar('Error retrieving hour data', error.toString());
    }
  }

  // fuck initiated for now
  Future<List<Appt>> getApptList() async {
    // if (apptInitiated) {
    //   return appts;
    // } else {
    QuerySnapshot<Object?> apptObjs =
        await apptRef.where('hrId', isEqualTo: id).get();

    appts = apptObjs.docs.map((apt) => Appt.fromSnapshot(apt)).toList();
    // apptInitiated = true;
    return appts;
    // }
  }
}
