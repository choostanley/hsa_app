import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../common/color_extension.dart';
import 'appt/noti_list.dart';
import 'appt/create_pt.dart';
import 'appt/app_owner.dart';
import 'appt/controllers/controllers.dart';
import 'appt/controllers/list_pt_controller.dart';
import 'appt/create_ar.dart';
import 'appt/controllers/appt_controller.dart';
import 'appt/controllers/clinic_controller.dart';
import 'appt/controllers/pt_controller.dart';
import 'appt/controllers/user_controller.dart';
import '/common/firebase/firebase_const.dart';
import 'appt/helpers/locale_string.dart';
import 'appt/middleware/auth_middleware.dart';
import 'appt/sign_up.dart';
import 'appt/login.dart';
import 'appt/pt_profile.dart';
import 'appt/appt_list.dart';
import 'appt/req_appt.dart';
// import 'appt/time_table.dart';
import 'common/page_not_found.dart';
import 'appt/helpers/routes.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// from tutorial
Future<void> _fbMessagingBackgroudHandler(RemoteMessage rm) async {
  // ignore: avoid_print
  print(
      '<><><><><><><><><><><><><>background handler<><><><><><><><><><><><><><><><><><>');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if not configured any phone token, send to all phones i guess
  // - both phones get notification, and app opened on notification clicked
  // this worked even without implementing initInfo in appOwner
  // if specify mToken, then only 1 phone

  // when app in background & phone received notification
  // D/FLTFireMsgReceiver( 4090): broadcast received for message
  // W/FLTFireMsgService( 4090): A background message could not be handled in Dart as no onBackgroundMessage handler has been registered.

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // this happened when app in background & app opened with notification clicked
    if (kDebugMode) {
      print(
          '<><><><><><>main_appt FB onMessageOpenedApp<><><><><><><><>${message.data}<><><><><><><><><><><><><><><><><><>');
    }
    // ignore: avoid_print
    print(
        '${message.notification?.title} // ${message.notification?.body} // // ${message.notification?.bodyLocKey}');
  });
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put<PtController>(PtController(), permanent: true);
  await initialization.then((value) {
    Get.put(UserController());
    Get.put(ApptController());
    Get.put(ClinicController());
    Get.put(PtListController());
  });
  if (await messaging.isSupported()) {
    await messaging.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroudHandler);
    if (kIsWeb) {
      Map<String, String> header = <String, String>{
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authorization':
            'key=AAAAzvKz-NQ:APA91bFoJlr0AAMP0vpqazM7rkZA-kZGwUlM3DllGmkSIYp0c0erG2njGrohHaY046L2T6Ok9ci_P_bFCRqJtQhPApvJRBmG05yv0oX81A9LHSpfyNuZOhmuHJEeCJ_8bvp16h2EFlmR'
      };
      messaging.getToken().then((value) {
        String token = value!;
        http.post(
          Uri.parse('https://iid.googleapis.com/iid/v1/$token/rel/topics/pt'),
          headers: header,
        );
      });
    } else {
      await messaging.subscribeToTopic('pt');
    }
  }
  await GetStorage.init();
  runApp(const MyApp());
}

// Light High Contrast Theme
// Generally for this version anything not white gets lighten by a percentage
// ignore: avoid_redundant_argument_values
final Color lightHighContrastPrimaryToneColor =
    // ignore: avoid_redundant_argument_values
    Colors.purple.shade50.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastPrimaryColor = Colors.purple.shade200.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastPrimaryVariantColor =
    // ignore: avoid_redundant_argument_values
    Colors.purple.shade700.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastSecondaryToneColor =
    // ignore: avoid_redundant_argument_values
    Colors.teal.shade50.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastSecondaryColor = Colors.teal.shade200.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastSecondaryVariantColor =
    // ignore: avoid_redundant_argument_values
    Colors.teal.shade700.lighten(10);
// ignore: avoid_redundant_argument_values
final Color lightHighContrastErrorColor = Colors.red.shade700.lighten(10);
const Color lightHighContrastBackgroundColor = Colors.white;
const Color lightHighContrastSurfaceColor = Colors.white;

const Color lightHighContrastOnPrimaryToneColor = Colors.black;
const Color lightHighContrastOnPrimaryColor = Colors.black;
const Color lightHighContrastOnPrimaryVariantColor = Colors.black;
const Color lightHighContrastOnSecondaryToneColor = Colors.black;
const Color lightHighContrastOnSecondaryColor = Colors.black;
const Color lightHighContrastOnSecondaryVariantColor = Colors.black;
const Color lightHighContrastOnSurfaceColor = Colors.black;
const Color lightHighContrastOnBackgroundColor = Colors.black;
const Color lightHighContrastOnErrorColor = Colors.black;


// Light Palette Theme
final Color lightPrimaryToneColor = Colors.purple.shade50;
final Color lightPrimaryColor = Colors.purple.shade200;
final Color lightPrimaryVariantColor = Colors.purple.shade700;
final Color lightSecondaryToneColor = Colors.teal.shade50;
final Color lightSecondaryColor = Colors.teal.shade200;
final Color lightSecondaryVariantColor = Colors.teal.shade700;
final Color lightErrorColor = Colors.red.shade700;
const Color lightBackgroundColor = Colors.white;
const Color lightSurfaceColor = Colors.white;

const Color lightOnPrimaryToneColor = Colors.black;
const Color lightOnPrimaryColor = Colors.black;
const Color lightOnPrimaryVariantColor = Colors.black;
const Color lightOnSecondaryToneColor = Colors.black;
const Color lightOnSecondaryColor = Colors.black;
const Color lightOnSecondaryVariantColor = Colors.black;
const Color lightOnSurfaceColor = Colors.black;
const Color lightOnBackgroundColor = Colors.black;
const Color lightOnErrorColor = Colors.black;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ColorScheme appColorSchemeLightHighContrast = ColorScheme(
      primary: lightHighContrastPrimaryColor,
      primaryContainer: lightHighContrastPrimaryVariantColor,
      secondary: lightHighContrastSecondaryColor,
      secondaryContainer: lightHighContrastSecondaryVariantColor,
      surface: lightHighContrastSurfaceColor,
      background: lightHighContrastBackgroundColor,
      error: lightHighContrastErrorColor,
      onPrimary: lightHighContrastOnPrimaryColor,
      onSecondary: lightHighContrastOnSecondaryColor,
      onSurface: lightHighContrastOnSurfaceColor,
      onBackground: lightHighContrastOnBackgroundColor,
      onError: lightHighContrastOnErrorColor,
      brightness: Brightness.light,
    );

    ColorScheme appColorSchemeLight = ColorScheme(
      primary: lightPrimaryColor,
      primaryVariant: lightPrimaryVariantColor,
      secondary: lightSecondaryColor,
      secondaryVariant: lightSecondaryVariantColor,
      surface: lightSurfaceColor,
      background: lightBackgroundColor,
      error: lightErrorColor,
      onPrimary: lightOnPrimaryColor,
      onSecondary: lightOnSecondaryColor,
      onSurface: lightOnSurfaceColor,
      onBackground: lightOnBackgroundColor,
      onError: lightOnErrorColor,
      brightness: Brightness.light,
    );

    return GetMaterialApp(
      key: const Key('Appt'),
      initialRoute: loginRoute,
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => const PageNotFound(),
          transition: Transition.fadeIn),
      getPages: [
        GetPage(name: loginRoute, page: () => const Login()),
        GetPage(name: signupRoute, page: () => const SignUp()),
        GetPage(
            name: appOwnerRoute,
            page: () => const AppOwner(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: ptProfileRoute,
            page: () => PtProfile(
                  ptModel: ptListController.currentPt.value,
                )),
        GetPage(name: reqApptRoute, page: () => const ReqAppt()),
        GetPage(name: apptListRoute, page: () => const ApptList()),
        GetPage(name: createArRoute, page: () => const CreateAr()),
        GetPage(name: createPtRoute, page: () => const CreatePt()),
        GetPage(name: notiListRoute, page: () => NotiList()),
        // GetPage(name: tTableRoute, page: () => const TimeTable()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'HSA Appt',
      locale:
          Locale(box.read('langCode') ?? 'en', box.read('countryCode') ?? 'US'),
      translations: LocaleString(),
      theme: ThemeData(
        // scaffoldBackgroundColor: light,
        // textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme)
        //     .apply(bodyColor: Colors.black),
        // colorScheme: appColorSchemeLight,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
        primarySwatch: Colors.cyan,
        // backgroundColor: lightHighContrastPrimaryVariantColor
      ),
      // home: Root(),
    );
  }
}
