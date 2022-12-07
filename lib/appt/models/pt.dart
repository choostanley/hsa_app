import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/common/functions.dart';

class PtModel {
  late String id;
  late String name;
  late String ic;
  late int gender;
  late String genderWord;
  late String race;
  late String address;
  late String ownerId;
  late DateTime createdAt;
  late DateTime updatedAt;

  PtModel();

  PtModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      name = snapshot.get('name');
      ic = snapshot.get('ic');
      gender = snapshot.get('gender');
      genderWord = gw(gender);
      race = snapshot.get('race');
      address = snapshot.get('address');
      ownerId = snapshot.get('ownerId');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving patient data', error.toString());
    }
  }

  PtModel.fromJson(Map map) {
    try {
      id = map['id'];
      name = map['name'];
      ic = map['ic'];
      gender = map['gender'];
      genderWord = gw(map['gender']);
      race = map['race'];
      address = map['address'];
      ownerId = map['ownerId'];
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
    } catch (error) {
      redSnackBar('Error retrieving patient data', error.toString());
    }
  }

  String gw(int ii) {
    switch (ii) {
      case 0:
        return 'male'.tr;
      case 2:
        return 'female'.tr;
      default:
        return 'ambiguous'.tr;
    }
  }
}
