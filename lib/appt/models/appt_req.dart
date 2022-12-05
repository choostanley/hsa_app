import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class ApptReq {
  late String id;
  late String ptId;
  late String ptIc;
  late String ptName;
  late String fromClinicId;
  late String reqById;
  late String attById; // when first seen by someone
  late List<DateTime> prefApptTime;
  late String remarks;
  late List<String> refLetterUrl;
  late DateTime createdAt;
  late DateTime updatedAt;
  // late String toClinicId; - need an anchor here, easier to get list by clinic


  // this put in new model - ar_dir
  late String toClinicId;
  late String toClinicName;


  // late String acceptedByClinic;
  // late bool screened;
  // late String screenBy;
  // late int duration;
  // late String scheduleId;

  ApptReq();

  ApptReq.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      ptId = snapshot.get('ptId');
      ptIc = snapshot.get('ptIc');
      ptName = snapshot.get('ptName');
      toClinicId = snapshot.get('toClinicId');
      toClinicName = snapshot.get('toClinicName');
      fromClinicId = snapshot.get('fromClinicId') ?? '';
      reqById = snapshot.get('reqById') ?? '';
      attById = snapshot.get('attById') ?? '';
      remarks = snapshot.get('remarks');
      List<dynamic> urlList = snapshot.get('refLetterUrl');
      refLetterUrl = urlList.map((url) => url.toString().trim()).toList();
      // refLetterUrl = snapshot.get('refLetterUrl');

      List<DateTime> pat = [];
      List<dynamic> prefTime = snapshot.get('prefApptTime');
      List<int> pTime = prefTime.map((rn) => rn as int).toList();
      for (var pt in pTime) {
        pat.add(DateTime.fromMillisecondsSinceEpoch(pt));
      }
      prefApptTime = pat;

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
    } catch (error) {
      redSnackBar('Error retrieving request data', error.toString());
    }
  }
}
