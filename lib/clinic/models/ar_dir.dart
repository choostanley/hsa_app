import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class ArDir {
  late String id;
  late String arId;
  late String toClinicId;
  late String toClinicName;
  late bool active;
  late bool accepted;
  late String apptId;
  late String directedById; // if staff only record, pt no need record
  late String directedByName;
  late String redirectedById;
  late String redirectedByName;
  late String message;
  late String redirectedToClinicId;
  late String redirectedToClinicName;
  late DateTime updatedAt;
  late DateTime createdAt;

  ArDir();

  ArDir.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      arId = snapshot.get('arId');
      directedById = snapshot.get('directedById');
      directedByName = snapshot.get('directedByName');
      toClinicId = snapshot.get('toClinicId');
      toClinicName = snapshot.get('toClinicName');
      message = snapshot.get('message'); // record message to toClinic better ba
      active = snapshot.get('active');
      apptId = snapshot.get('apptId');
      accepted = snapshot.get('accepted');
      redirectedById = snapshot.get('redirectedById');
      redirectedByName = snapshot.get('redirectedByName');
      redirectedToClinicId = snapshot.get('redirectedToClinicId');
      redirectedToClinicName = snapshot.get('redirectedToClinicName');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving request data', error.toString());
    }
  }
}
