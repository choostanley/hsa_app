import 'package:get/get.dart';
import 'package:hsa_app/clinic/models/hour_model.dart';
import 'package:hsa_app/clinic/models/schedule_day.dart';
import '../models/day_model.dart';

class DayListController extends GetxController {
  static DayListController instance = Get.find();

  List<DayModel> _loadedDayModelList = [];

  List<DayModel> get dayModels => _loadedDayModelList;

  List<HourModel> _hourModelsOfDay(String dayId) =>
      dayModels.firstWhere((dm) => dm.id == dayId).hours;

  bool dayIdInCont(String dayId) =>
      dayModels.map((hm) => hm.id).contains(dayId);

  void addDay(DayModel value) => _loadedDayModelList.add(value);

  Future<List<HourModel>> storeDayAndloadHours(
      DayModel dm, ScheduleDay sDay) async {
    if (dayIdInCont(dm.id)) {
      return _hourModelsOfDay(dm.id);
    } else {
      var result = await dm.getHourModelList(sDay);
      addDay(dm);
      return result;
    }
  }

  void clear() => _loadedDayModelList = [];

  void updateHourAppt(String dayId, String hourId) {
    List<HourModel> hrs = dayModels.firstWhere((dm) => dm.id == dayId).hours;
    List<String> ids = hrs.map((hr) => hr.id).toList();
    int position = ids.indexOf(hourId);
    HourModel hm =
        dayModels.firstWhere((dm) => dm.id == dayId).hours.removeAt(position);
    int can = hm.curApptNum;
    hm.curApptNum = can + 1;
    dayModels.firstWhere((dm) => dm.id == dayId).hours.add(hm);
  }

  // void downdateHourAppt
}
