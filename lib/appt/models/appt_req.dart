import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class ApptReq {
  late String id;
  late String ptId;
  late String ptIc;
  late String ptName;
  late String fromClinicId;
  late String reqById;
  late int urgency;
  late String screenedById; // screen by dr for duration
  late String screenedByName;
  late String screenedScheId;
  late String screenedScheName;
  late String screenedDurStart;
  late int screenedDurStartInt;
  late String screenedDurEnd;
  late int screenedDurEndInt;
  late String givenApptById;
  late String givenApptByName;
  late List<DateTime> prefApptTime;
  late String remarks;
  late List<String> refLetterUrl;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime screenedAt;
  late DateTime apptGivenAt;
  // late String toClinicId; - need an anchor here, easier to get list by clinic
  // .where('attById', isEqualTo: '')

  // this put in new model - ar_dir
  // here still maintain
  late String toClinicId;
  late String toClinicName;
  // string arId
  // bool active
  // bool accepted
  // directedById
  // directedByName
  // redirectedById
  // redirectedByName
  // String message
  // redirectedToClinicId
  // redirectedToClinicName
  // late DateTime updatedAt;
  // late DateTime createdAt;

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
      // attById = snapshot.get('attById') ?? '';

      urgency = snapshot.get('urgency');
      screenedById = snapshot.get('screenedById');
      screenedByName = snapshot.get('screenedByName');
      screenedScheId = snapshot.get('screenedScheId');
      screenedScheName = snapshot.get('screenedScheName');
      screenedDurStart = snapshot.get('screenedDurStart');
      screenedDurStartInt = snapshot.get('screenedDurStartInt');
      screenedDurEnd = snapshot.get('screenedDurEnd');
      screenedDurEndInt = snapshot.get('screenedDurEndInt');
      givenApptById = snapshot.get('givenApptById');
      givenApptByName = snapshot.get('givenApptByName');

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
      screenedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('screenedAt'));
      apptGivenAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('apptGivenAt'));
    } catch (error) {
      redSnackBar('Error retrieving request data', error.toString());
    }
  }
}
