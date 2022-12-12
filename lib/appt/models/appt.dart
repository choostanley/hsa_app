// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../controllers/controllers.dart';
// import '/common/functions.dart';
// import 'appt_req.dart';

// class Appt {
//   late String id;
//   late String ptId;
//   late String clinicId;
//   late String staffId;
//   late String apptReqId;
//   late DateTime apptTime;
//   // late String reqRemarks;
//   late String approveRemarks;
//   late ApptReq apptReq;
//   late bool attended;
//   late DateTime createdAt;
//   late DateTime updatedAt;

//   Appt();

//   Appt.fromSnapshot(DocumentSnapshot snapshot) {
//     try {
//       id = snapshot.id;
//       ptId = snapshot.get('ptId');
//       clinicId = snapshot.get('clinicId');
//       staffId = snapshot.get('staffId');
//       apptReqId = snapshot.get('apptReqId') ?? '';
//       apptTime = snapshot.get('apptTime');
//       approveRemarks = snapshot.get('approveRemarks');
//       attended = snapshot.get('attended');
//       createdAt =
//           DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
//       updatedAt =
//           DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
//       if (apptReqId.isNotEmpty) getApptReq();
//       // initialized = true;
//     } catch (error) {
//       redSnackBar('Error retrieving appt data', error.toString());
//     }
//   }

//   void getApptReq() {
//     apptReq = apptController.apptReqs.firstWhere((apptR) => apptR.id == id);
//   }
// }
