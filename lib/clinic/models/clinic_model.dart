import 'package:cloud_firestore/cloud_firestore.dart';
import '../../common/firebase/firebase_const.dart';
import 'room_model.dart';

import '/common/functions.dart';

class ClinicModel {
  late String id;
  late String name;
  late String shortName;
  late bool approved;
  late String createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;
  late List<String> roomIdList;
  late List<RoomModel> rooms;
  bool roomInit = false;

  ClinicModel();

  ClinicModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      name = snapshot.get('name');
      shortName = snapshot.get('shortName');
      approved = snapshot.get('approved');
      createdBy = snapshot.get('createdBy');
      List<dynamic> ril = snapshot.get('roomIdList');
      roomIdList = ril.map((url) => url.toString().trim()).toList();
      // print('heres roomIdList');
      // print(roomIdList);
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving Clinic data', error.toString());
    }
  }

  ClinicModel.fromJson(Map map) {
    try {
      id = map['id'];
      name = map['name'];
      shortName = map['shortName'];
      approved = map['approved'];
      createdBy = map['createdBy'];
      roomIdList = map['roomIdList'];
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt']);
    } catch (error) {
      redSnackBar('Error retrieving patient data', error.toString());
    }
  }

  Future<List<RoomModel>> getRooms() async {
    // give as sequenced
    // if (roomInit) return rooms;
    List<RoomModel> fullList = [];
    QuerySnapshot<Object?> roomObjs =
        await roomRef.where('clinicId', isEqualTo: id).get();
    List<String> rObjIds = roomObjs.docs.map((fk) => fk.id).toList();
    if (roomIdList.isNotEmpty) {
      for (var rid in roomIdList) {
        if (rObjIds.contains(rid)) {
          fullList.add(RoomModel.fromSnapshot(
              roomObjs.docs.firstWhere((bod) => bod.id == rid)));
        }
      }
    }
    rooms = fullList;
    roomInit = true;
    return fullList;
  }
}
