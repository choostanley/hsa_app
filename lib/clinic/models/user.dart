import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';

class UserModel {
  late String id;
  late String name;
  late String email;
  late String ic;
  late String phoneNum;
  late String title;
  late String mmcLjm;
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
      title = snapshot.get('title');
      mmcLjm = snapshot.get('mmcLjm');
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

  String getName() => '$title. $name';

  // void getClinicList() async {
  //   QuerySnapshot<Object?> apptReqObjs =
  //       await memberRef.where('memberId', isEqualTo: id).get();
  //   apptReqObjs.docs.map((apt) => ApptReq.fromSnapshot(apt)).toList();
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
