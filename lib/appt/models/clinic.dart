import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class Clinic {
  late String id;
  late String name;
  late String deptId;
  late String staffId;
  late DateTime createdAt;
  late DateTime updatedAt;

  Clinic();

  Clinic.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      name = snapshot.get('name');
      deptId = snapshot.get('deptId');
      staffId = snapshot.get('staffId');
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
