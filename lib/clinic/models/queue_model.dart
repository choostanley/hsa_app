import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class QueueModel {
  late String id;
  late String ptId;
  late String ptName;
  late String scheduleId;
  late String calledById; // - doctor
  late String approveRemarks; // so that calling dr knows little bit on case
  late bool called;
  late bool entered;
  late DateTime createdAt;
  late DateTime updatedAt;

  QueueModel();

  QueueModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      ptId = snapshot.get('ptId');
      ptName = snapshot.get('ptName');
      scheduleId = snapshot.get('scheduleId');
      calledById = snapshot.get('calledById');
      approveRemarks = snapshot.get('approveRemarks'); 
      called = snapshot.get('called');
      entered = snapshot.get('entered');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving queue data', error.toString());
    }
  }
}
