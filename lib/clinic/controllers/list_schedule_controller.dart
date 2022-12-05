import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';
import '../../common/firebase/firebase_const.dart';
import '../models/schedule_model.dart';

class ScheduleListController extends GetxController {
  static ScheduleListController instance = Get.find();
  bool loaded = false;
  Rx<ScheduleModel> currentSchedule = ScheduleModel().obs;
  List<String> loadedClinicId = [];

  List<ScheduleModel> _scheduleModelList = [];

  List<ScheduleModel> get scheduleModels => _scheduleModelList;

  ScheduleModel scheduleModel(String scId) =>
      _scheduleModelList.firstWhere((um) => um.id == scId);

  bool scIdInCont(String scId) =>
      scheduleModels.map((hm) => hm.id).contains(scId);

  void addSchedule(ScheduleModel value) => _scheduleModelList.add(value);

  void addAndCurrent(ScheduleModel value) {
    addSchedule(value);
    currentSchedule.value = value;
  }

  String scheduleName(String scId) =>
      _scheduleModelList.firstWhere((um) => um.id == scId).name;

  String scDescription(String scId) =>
      _scheduleModelList.firstWhere((um) => um.id == scId).description;

  void addSchedules(List<ScheduleModel> diss) {
    _scheduleModelList.addAll(diss);
  }

  // no need first lah, this is just demo
  void saveLoadedClinicId(String clinicId) {
    if (!loadedClinicId.contains(clinicId)) loadedClinicId.add(clinicId);
  }

  // there is no point saving this list?...
  Future<List<ScheduleModel>> getScheduleModels() async {
    // String curClinicId = clinicListController.currentCl.value.id;
    // if (loaded) {
    //   return _scheduleModelList;
    // } else {
    List<ScheduleModel> emptyToFull = [];
    QuerySnapshot<Object?> scObjs = await scheduleRef
        .where('clinicId', isEqualTo: clinicListController.currentCl.value.id)
        .get();
    for (var doc in scObjs.docs) {
      emptyToFull.add(ScheduleModel.fromSnapshot(doc));
    }
    addSchedules(emptyToFull);
    loaded = true;
    return emptyToFull;
    // }
  }

  void clear() => _scheduleModelList = [];
}
