import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/functions.dart';

class Holiday {
  late String id;
  late String holidayName;
  late int startDateTimeInt;
  late DateTime startDateTime;
  late int endDateTimeInt;
  late DateTime endDateTime;
  late String startDate;
  late String endDate;
  late String clinicId;
  late String clinicName;
  late String createdById;
  late String createdByName;
  late DateTime createdAt;
  late DateTime updatedAt;

  Holiday();

  Holiday.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      id = snapshot.id;
      holidayName = snapshot.get('holidayName');
      startDateTimeInt = snapshot.get('startDateTimeInt');
      startDateTime = DateTime.fromMillisecondsSinceEpoch(startDateTimeInt);
      endDateTimeInt = snapshot.get('endDateTimeInt');
      endDateTime = DateTime.fromMillisecondsSinceEpoch(endDateTimeInt);
      startDate = snapshot.get('startDate');
      endDate = snapshot.get('endDate');
      clinicId = snapshot.get('clinicId');
      clinicName = snapshot.get('clinicName');
      createdById = snapshot.get('createdById');
      createdByName = snapshot.get('createdByName');

      createdAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('createdAt'));
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.get('updatedAt'));
      // initialized = true;
    } catch (error) {
      redSnackBar('Error retrieving clinic data', error.toString());
    }
  }

  String getTimeFrame() {
    String till = endDate == '' ? '' : 'till $endDate';
    return '$startDate $till';
  }

  DateTime getLatest() {
    if (endDateTimeInt != 0) return endDateTime;
    return startDateTime;
  }
}
