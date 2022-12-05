import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'appt.dart';
import 'appt_req.dart';

class UserModel {
  late String id;
  late String name;
  late String email;
  late String ic;
  late String phoneNum;
  late List<Appt> apptList;
  late List<ApptReq> apptReqList;
  late DateTime createdAt;
  late DateTime updatedAt;

  UserModel();

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      email = snapshot.get('email');
      name = snapshot.get('name');
      ic = snapshot.get('ic');
      phoneNum = snapshot.get('phone');
      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // getApptList();
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving user data', error.toString());
    }
  }

  // void getApptList() async { // not in use anymore since using PtModel
  //   QuerySnapshot<Object?> apptReqObjs =
  //       await apptRef.where('ptId', isEqualTo: id).get();
  //   apptReqList =
  //       apptReqObjs.docs.map((apt) => ApptReq.fromSnapshot(apt)).toList();
  //   apptController.setApptReqList(apptReqList);

  //   QuerySnapshot<Object?> apptObjs =
  //       await apptRef.where('ptId', isEqualTo: id).get();
  //   apptObjs.docs.map((apt) => Appt.fromSnapshot(apt)).toList();
  //   apptList = apptObjs.docs.map((apt) => Appt.fromSnapshot(apt)).toList();
  //   apptController.setApptList(apptList);
  // }
}
