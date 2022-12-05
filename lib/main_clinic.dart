import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'clinic/appt_qr_camera.dart';
import 'clinic/manual_reg_appt.dart';
import 'clinic/members_page.dart';
import 'clinic/rooms_page.dart';
import 'clinic/create_schedule.dart';
import 'clinic/ref_received.dart';
import 'clinic/schedule_page.dart';
import 'clinic/controllers/controllers.dart';
import 'clinic/controllers/list_clinic_controller.dart';
import 'clinic/controllers/list_day_controller.dart';
import 'clinic/controllers/list_hour_appt_controller.dart';
import 'clinic/controllers/list_schedule_controller.dart';
import 'clinic/create_clinic.dart';
import 'common/firebase/firebase_const.dart';
import 'clinic/controllers/list_ref_received_controller.dart';
import 'clinic/controllers/drsn_controller.dart';
import 'clinic/controllers/user_controller.dart';
import 'clinic/middleware/auth_middleware.dart';
import 'clinic/sign_upc.dart';
import 'clinic/loginc.dart';

import 'clinic/drsn_profile.dart';
import 'clinic/send_ref.dart';
import 'clinic/clinic_profile.dart'; //with appt list
import 'clinic/helpers/routes.dart';
import 'common/page_not_found.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      print(message.data);
    }
  });
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put<DrsnController>(DrsnController(), permanent: true);
  // Get.put<PtController>(PtController(), permanent: true);
  await GetStorage.init();
  await initialization.then((value) {
    Get.put(UserController());
    Get.put(RefReceivedListController());
    Get.put(ClinicListController());
    Get.put(ScheduleListController());
    Get.put(DayListController());
    Get.put(HourApptListController());
  });
  await FirebaseMessaging.instance.getInitialMessage();
  if (kIsWeb) {
    Map<String, String> header = <String, String>{
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAzvKz-NQ:APA91bFoJlr0AAMP0vpqazM7rkZA-kZGwUlM3DllGmkSIYp0c0erG2njGrohHaY046L2T6Ok9ci_P_bFCRqJtQhPApvJRBmG05yv0oX81A9LHSpfyNuZOhmuHJEeCJ_8bvp16h2EFlmR'
    };
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value!;
      http.post(
        Uri.parse('https://iid.googleapis.com/iid/v1/$token/rel/topics/clinic'),
        headers: header,
      );
    });
  } else {
    await FirebaseMessaging.instance.subscribeToTopic('clinic');
  }
  // await FirebaseMessaging.instance.subscribeToTopic('clinic');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      key: const Key('Clinic'),
      initialRoute: cloginRoute,
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => const PageNotFound(),
          transition: Transition.fadeIn),
      getPages: [
        GetPage(name: cloginRoute, page: () => const Loginc()),
        GetPage(name: csignupRoute, page: () => const SignUpc()),
        GetPage(
            name: drsnProfileRoute,
            page: () => const DrsnProfile(),
            middlewares: [AuthMiddleware()]),
        GetPage(name: createClinicRoute, page: () => const CreateClinic()),
        GetPage(
            name: clinicProfileRoute,
            page: () =>
                ClinicProfile(cm: clinicListController.currentCl.value)),
        GetPage(name: createScheduleRoute, page: () => const CreateSchedule()),
        GetPage(
            name: scheduleRoute,
            page: () => SchedulePage(
                  sc: scheduleListController.currentSchedule.value,
                )),
        GetPage(name: receivedRefRoute, page: () => RefReceived()),
        GetPage(name: roomsRoute, page: () => const RoomsPage()),
        GetPage(name: membersRoute, page: () => MembersPage()),
        GetPage(name: scanApptRoute, page: () => const ApptQrCamera()),
        GetPage(name: regApptRoute, page: () => const ManualRegAppt()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'HSA Clinic',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
        primarySwatch: Colors.blue,
      ),
      // home: Root(),
    );
  }
}
