import 'package:get/get.dart';
import '../models/user.dart';

class UserController extends GetxController {
  static UserController instance = Get.find();

  final Rx<UserModel> _userModel = UserModel().obs;

  UserModel get user => _userModel.value;

  void setUser(UserModel value) => _userModel.value = value;

  void clear() {
    _userModel.value = UserModel();
  }
}