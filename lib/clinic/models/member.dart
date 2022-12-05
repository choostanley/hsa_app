import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class Member {
  late String id;
  late String drSnId;
  late String drSnName;
  late String drSnIc;
  late String addedById;
  late String clinicId;
  late bool valid;
  late DateTime createdAt;
  late DateTime updatedAt;

  Member();

  Member.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      drSnId = snapshot.get('drSnId');
      drSnName = snapshot.get('drSnName');
      drSnIc = snapshot.get('drSnIc');
      addedById = snapshot.get('addedById');
      clinicId = snapshot.get('clinicId');
      valid = snapshot.get('valid');
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
