import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// import 'package:hsa_app/clinic/controllers/controllers.dart';
import '../../common/firebase/firebase_const.dart';
import '../models/clinic_model.dart';

class ClinicListController extends GetxController {
  static ClinicListController instance = Get.find();
  bool loaded = false;
  Rx<ClinicModel> currentCl = ClinicModel().obs;

  List<ClinicModel> _clinicModelList = [];

  List<ClinicModel> get clinicModels => _clinicModelList;

  ClinicModel userModel(String clId) =>
      _clinicModelList.firstWhere((um) => um.id == clId);

  bool clIdInCont(String clId) =>
      clinicModels.map((hm) => hm.id).contains(clId);

  void addCli(ClinicModel value) => _clinicModelList.add(value);

  String ptName(String clId) =>
      _clinicModelList.firstWhere((um) => um.id == clId).name;

  String ptShortName(String clId) =>
      _clinicModelList.firstWhere((um) => um.id == clId).shortName;

  void addCls(List<ClinicModel> diss) {
    _clinicModelList.addAll(diss);
  }

  Future<List<ClinicModel>> getClinicModels() async {
    // Dont use loaded for now first
    // - so that right after create clinic can list out in endDrawer
    // if (loaded) {
    //   return _clinicModelList;
    // } else {

    List<ClinicModel> emptyToFull = [];
    // havent make remove membership - valid = false
    QuerySnapshot<Object?> membObjs =
        await memberRef.where('drSnId', isEqualTo: auth.currentUser!.uid).get();
    List<String> clinicIds =
        membObjs.docs.map((ss) => ss.get('clinicId').toString()).toList();
    if (clinicIds.isEmpty) return []; // else ...
    QuerySnapshot<Object?> clinicObjs = await clinicRef
        .where(FieldPath.documentId, whereIn: clinicIds)
        //previously use userController should be find ah, since initialised in appOwnerProfile already???? Need to mtfk test it out
        .get();
    print(clinicObjs.docs.length);
    for (var doc in clinicObjs.docs) {
      emptyToFull.add(ClinicModel.fromSnapshot(doc));
    }
    addCls(emptyToFull);
    loaded = true;
    return emptyToFull;
    // }
  }

  void clear() => _clinicModelList = [];
}
