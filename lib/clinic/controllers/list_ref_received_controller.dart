// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';
import '../../appt/models/appt_req.dart';
import '/common/firebase/firebase_const.dart';

class RefReceivedListController extends GetxController {
  static RefReceivedListController instance = Get.find();

  final Rx<ApptReq> _apptReq = ApptReq().obs;

  final RxList<ApptReq> _apptReqList = <ApptReq>[].obs;

  // ignore: invalid_use_of_protected_member
  ApptReq get refReceived => _apptReq.value;

  // ignore: invalid_use_of_protected_member
  List<ApptReq> get refRecList => _apptReqList.value;

  void setRefRec(ApptReq value) => _apptReq.value = value;

  void setRefRecList(List<ApptReq> value) => _apptReqList.value = value;

  Future<List> getAllRefRec() async {
    List<ApptReq> rrList = [];
    await apptReqRef
        .where('toClinicId', isEqualTo: clinicListController.currentCl.value.id)
        .get()
        .then((qssl) {
      rrList = qssl.docs.map((aro) => ApptReq.fromSnapshot(aro)).toList();
      setRefRecList(rrList);
    });
    return rrList;
  }
}
