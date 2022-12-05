import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class PtNoti {
  late String id;
  late String ptId;
  late String appOwnerId;
  late bool seen;
  late String clinicId;
  late String title;
  late String body;
  late DateTime createdAt;
  late DateTime updatedAt;

  PtNoti();

  PtNoti.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      ptId = snapshot.get('ptId');
      appOwnerId = snapshot.get('appOwnerId');
      seen = snapshot.get('seen');
      clinicId = snapshot.get('clinicId');
      title = snapshot.get('title');
      body = snapshot.get('body');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving clinic data', error.toString());
    }
  }
}
