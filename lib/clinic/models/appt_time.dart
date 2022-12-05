import 'package:cloud_firestore/cloud_firestore.dart';
import '/common/functions.dart';

class ApptTime {
  late String id;
  late String apptId;
  late String dayId;
  late String hourId;
  late DateTime apptTime;
  late String rescReason;
  late bool active;
  late bool rescheduled;
  late DateTime createdAt;
  late DateTime updatedAt;

  ApptTime();

  ApptTime.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      apptId = snapshot.get('apptId');
      dayId = snapshot.get('dayId');
      hourId = snapshot.get('hourId');
      apptTime = snapshot.get('apptTime');
      rescReason = snapshot.get('rescReason');
      active = snapshot.get('active');
      rescheduled = snapshot.get('rescheduled');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // if (apptReqId.isNotEmpty) getApptReq();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving ApptTime data', error.toString());
    }
  }
}
