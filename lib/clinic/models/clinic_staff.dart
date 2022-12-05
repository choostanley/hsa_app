import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class ClinicStaff {
  late String id;
  late DateTime createdAt;
  late DateTime updatedAt;

  ClinicStaff();

  ClinicStaff.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // getApptList();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving Clinic Staff data', error.toString());
    }
  }
}
