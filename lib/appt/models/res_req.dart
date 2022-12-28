import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class ResReq {
  late String id;
  late String ptName;
  late String apptId;
  late String clinicId;
  late String scheduleId;
  late String attById;
  late String attByName;
  late int iniApptTimeInt;
  late DateTime iniApptTime;
  late int prefApptTimeInt;
  late DateTime prefApptTime;
  late String reason;
  late String response;
  late bool approved;
  late bool rejected;
  late DateTime screenedAt;
  late DateTime createdAt;
  late DateTime updatedAt;

  // approval of rescheduling is case-based
  // * picked date and time subject to availability

  // appt
  // late String dateString;
  // late int dateTimeStampInt;
  // late DateTime dateTimeStamp;

  // dayModel
  // curApptNum
  // hourmodel
  // curApptNum

  // create new apptTime - & make old ones active: false

  ResReq();

  ResReq.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      ptName = snapshot.get('ptName');
      apptId = snapshot.get('apptId');
      clinicId = snapshot.get('clinicId');
      scheduleId = snapshot.get('scheduleId');
      attById = snapshot.get('attById');
      attByName = snapshot.get('attByName');
      iniApptTimeInt = snapshot.get('iniApptTimeInt');
      iniApptTime = DateTime.fromMillisecondsSinceEpoch(iniApptTimeInt);
      prefApptTimeInt = snapshot.get('prefApptTimeInt');
      prefApptTime = DateTime.fromMillisecondsSinceEpoch(prefApptTimeInt);
      reason = snapshot.get('reason');
      response = snapshot.get('response');
      approved = snapshot.get('approved');
      rejected = snapshot.get('rejected');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      screenedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('screenedAt'));
    } catch (error) {
      redSnackBar('Error retrieving request data', error.toString());
    }
  }
}
