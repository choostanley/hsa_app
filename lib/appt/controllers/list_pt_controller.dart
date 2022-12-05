import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';
import '../../common/firebase/firebase_const.dart';
import '../models/pt.dart';

class PtListController extends GetxController {
  static PtListController instance = Get.find();
  bool loaded = false;
  Rx<PtModel> currentPt = PtModel().obs;

  List<PtModel> _ptModelList = [];

  List<PtModel> get ptModels => _ptModelList;

  PtModel userModel(String ptId) =>
      _ptModelList.firstWhere((um) => um.id == ptId);

  bool ptIdInCont(String ptId) => ptModels.map((hm) => hm.id).contains(ptId);

  void addPt(PtModel value) => _ptModelList.add(value);

  String ptName(String ptId) =>
      _ptModelList.firstWhere((um) => um.id == ptId).name;

  String ptIc(String ptId) => _ptModelList.firstWhere((um) => um.id == ptId).ic;

  void addPts(List<PtModel> diss) {
    _ptModelList.addAll(diss);
  }

  Future<List<PtModel>> getPtModels() async {
    // print(auth.currentUser!.uid);
    // if (loaded) {
    //   return _ptModelList;
    // } else {
    List<PtModel> emptyToFull = [];
    QuerySnapshot<Object?> ptObjs = await ptRef
        .where('ownerId', isEqualTo: auth.currentUser!.uid)
        //previously use userController should be find ah, since initialised in appOwnerProfile already???? Need to mtfk test it out
        .get();
    for (var doc in ptObjs.docs) {
      emptyToFull.add(PtModel.fromSnapshot(doc));
    }
    addPts(emptyToFull);
    loaded = true;
    return emptyToFull;
    // }
  }

  void clear() => _ptModelList = [];
}
