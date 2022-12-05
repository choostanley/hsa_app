import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controllers.dart';
import '../helpers/routes.dart';
// import 'package:mahospital/routing/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  redirect(String? route) =>
      ptController.user == null ? const RouteSettings(name: loginRoute) : null;
}
