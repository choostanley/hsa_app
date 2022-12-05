import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class RoomModel {
  late String id;
  late String name;
  late String clinicId;
  late String scheduleId;
  late String scheduleName;
  late String lastUpdatedBy;
  late DateTime createdAt;
  late DateTime updatedAt;

  RoomModel();

  RoomModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      name = snapshot.get('name');
      clinicId = snapshot.get('clinicId');
      scheduleId = snapshot.get('scheduleId');
      scheduleName = snapshot.get('scheduleName');
      lastUpdatedBy = snapshot.get('lastUpdatedBy');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving room data', error.toString());
    }
  }
}
