import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../clinic/models/appt.dart';
import '/common/firebase/firebase_const.dart';
import '../models/appt_req.dart';
// import '../models/appt.dart';
import 'controllers.dart';

// Create appt & Appt List tgt haha
class ApptController extends GetxController {
  static ApptController instance = Get.find();

  final TextEditingController clinic = TextEditingController(text: '');
  final TextEditingController notes = TextEditingController(text: '');

  final RxList<Appt> _appts = <Appt>[].obs;

  // ignore: invalid_use_of_protected_member
  List<Appt> get appts => _appts.value;

  void setApptList(List<Appt> value) => _appts.value = value;

  final RxList<ApptReq> _apptReqs = <ApptReq>[].obs;

  // ignore: invalid_use_of_protected_member
  List<ApptReq> get apptReqs => _apptReqs.value;

  void setApptReqList(List<ApptReq> value) => _apptReqs.value = value;

  Future<List> refreshApptReqList() async {
    List<ApptReq> renew = [];
    await apptReqRef
        .where('ptId', isEqualTo: ptListController.currentPt.value.id)
        .get()
        .then((qssl) {
      renew = qssl.docs.map((aro) => ApptReq.fromSnapshot(aro)).toList();
      setApptReqList(renew);
    });
    return renew;
  }

  Future<List> refreshApptList() async {
    List<Appt> renew = [];
    await apptRef
        .where('ptId', isEqualTo: ptListController.currentPt.value.id)
        .get()
        .then((qssl) {
      renew = qssl.docs.map((aro) => Appt.fromSnapshot(aro)).toList();
      setApptList(renew);
    });
    return renew;
  }

  void clearApptnApptReq() {
    setApptList([]);
    setApptReqList([]);
  }
}
