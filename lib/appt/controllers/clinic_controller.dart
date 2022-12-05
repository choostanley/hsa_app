import 'package:get/get.dart';
import '../models/clinic.dart';

class ClinicController extends GetxController {
  static ClinicController instance = Get.find();

  late RxList<Clinic> _clinics;

  // ignore: invalid_use_of_protected_member
  List<Clinic> get clinics => _clinics.value;

  void setClinics(List<Clinic> value) => _clinics.value = value;

  String clinicName(String clinicId) =>
      _clinics.firstWhere((clinic) => clinic.id == clinicId).name;
}
