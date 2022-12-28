import 'package:cloud_firestore/cloud_firestore.dart';

import '../../appt/models/appt_req.dart'; // this okay??
import '/common/functions.dart';

class Appt {
  late String id;
  late String ptId;
  late String ptIc;
  late String scheduleId;
  late String scheduleName;
  late String clinicId;
  late String clinicName;
  late String dateString;
  late int dateTimeStampInt;
  late DateTime dateTimeStamp;
  // inside queue need scheduleId
  // first of all - how to check if pt is in any schedule...
  // take all appt under schedules under current clinic
  // after scan remove from a list
  // - if not in schedule can provide refresh button on scan page
  // where - scheduleIds, dateString, active & not attended, sort by dateTimeStamp
  // if in 1 clinic got 2 appt on the same day
  // - scan for nearest 1 & not after time first?
  // - or provide

  // if not on time?? - they would want to allow it
  late String staffId;
  late String apptReqId;
  late String approveRemarks;
  late bool active;
  late bool attended;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String hrId;
  late String ptName;
  late ApptReq apptReq; // no use for now
  bool getApptReq = false;
  bool getApptTime = false;

  Appt();

  Appt.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      ptId = snapshot.get('ptId');
      ptIc = snapshot.get('ptIc');
      scheduleId = snapshot.get('scheduleId');
      scheduleName = snapshot.get('scheduleName'); // for demo purpose
      clinicId = snapshot.get('clinicId');
      clinicName = snapshot.get('clinicName');
      dateString = snapshot.get('dateString');
      dateTimeStampInt = snapshot.get('dateTimeStampInt');
      dateTimeStamp = DateTime.fromMillisecondsSinceEpoch(dateTimeStampInt);
      staffId = snapshot.get('staffId');
      apptReqId = snapshot.get('apptReqId');
      approveRemarks = snapshot.get('approveRemarks');
      active = snapshot.get('active');
      attended = snapshot.get('attended');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      hrId = snapshot.get('hrId');
      ptName = snapshot.get('ptName');
      // if (apptReqId.isNotEmpty) getApptReq();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving Appt data', error.toString());
    }
  }

  Appt.fromJson(Map<String, dynamic> map) {
    try {
      id = map['id'];
      ptId = map['ptId'];
      ptIc = map['ptIc'];
      scheduleId = map['scheduleId'];
      scheduleName = map['scheduleName'];
      clinicId = map['clinicId'];
      clinicName = map['clinicName'];
      dateString = map['dateString'];
      dateTimeStampInt = map['dateTimeStampInt'];
      dateTimeStamp = DateTime.fromMillisecondsSinceEpoch(dateTimeStampInt);
      staffId = map['staffId'];
      apptReqId = map['apptReqId'];
      approveRemarks = map['approveRemarks'];
      active = map['active'];
      attended = map['attended'];
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
      hrId = map['hrId'];
    } catch (error) {
      redSnackBar('Error retrieving Appt data', error.toString());
    }
  }
}
