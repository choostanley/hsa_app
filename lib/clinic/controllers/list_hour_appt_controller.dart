import 'package:get/get.dart';
import 'package:hsa_app/clinic/models/appt.dart';
import '../models/hour_model.dart';

class HourApptListController extends GetxController {
  static HourApptListController instance = Get.find();

  List<HourModel> _loadedHourModelList = [];

  List<HourModel> get hourModels => _loadedHourModelList;

  // HourModel hrModel(String hrId) =>
  //     _loadedHourModelList.firstWhere((hr) => hr.id == hrId);

  List<Appt> _apptsOfHour(String hourId) =>
      hourModels.firstWhere((hr) => hr.id == hourId).appts;

  bool hourIdInCont(String hourId) =>
      hourModels.map((hm) => hm.id).contains(hourId);

  void addHour(HourModel value) => _loadedHourModelList.add(value);

  Future<List<Appt>> storeHourAndloadAppts(HourModel hr) async {
    // if (hourIdInCont(hr.id)) {
    //   return _apptsOfHour(hr.id);
    // } else {
    var result = await hr.getApptList();
    addHour(hr);
    return result;
    // }
  }

  void updateHourModel(HourModel hr, Appt apptModelInstant) async {
    if (hourIdInCont(hr.id)) {
      List<String> hrIds = _loadedHourModelList.map((hr) => hr.id).toList();
      int position = hrIds.indexOf(hr.id);
      HourModel target = _loadedHourModelList.removeAt(position);
      target.appts.add(apptModelInstant);
      _loadedHourModelList.add(target);
    } else {
      await hr.getApptList();
      addHour(hr);
    }
  }

  void clear() => _loadedHourModelList = [];
}
