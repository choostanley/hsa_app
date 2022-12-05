import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class AttachRoomModel {
  late String id;
  late String staffId;
  late String staffName;
  late String roomId;
  late String roomName;
  late bool active;
  late DateTime createdAt;
  late DateTime updatedAt;

  AttachRoomModel();

  AttachRoomModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      staffId = snapshot.get('staffId');
      staffName = snapshot.get('staffName');
      roomId = snapshot.get('roomId');
      roomName = snapshot.get('roomName');
      active = snapshot.get('active');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving room data', error.toString());
    }
  }
}
