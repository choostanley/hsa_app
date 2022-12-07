import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';
import 'package:hsa_app/appt/models/pt_noti.dart';
import 'package:hsa_app/appt/widgets/end_drawer.dart';
import 'package:hsa_app/appt/widgets/noti_listtile.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'create_pt.dart';
import 'models/appt.dart';
import 'models/pt.dart';
import 'widgets/lead_drawer.dart';
import 'models/user.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'widgets/pt_tile.dart';

class AppOwner extends StatefulWidget {
  const AppOwner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppOwnerState createState() => _AppOwnerState();
}

class _AppOwnerState extends State<AppOwner> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // late User user;
  // late UserModel userModel;
  // late Future<DocumentSnapshot> getUser;
  // var combining = RegExp(r"[^\\x00-\\x7F]/g");

  // Is it this is for android?
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  /// A notification action which triggers a App navigation event
  static const String navigationActionId = 'id_3';
  late Future<UserModel> gud;

  @override
  void initState() {
    // hmm... seems okay now...
    // ignore: avoid_print
    print(box.read('quote'));
    // ignore: avoid_print
    print('quote mtfk');
    // gud = getUserData();
    initInfo();
    // _configureSelectNotificationSubject();
    // after commenting this line,
    // initState reduced to being called 2 times from 3 times
    super.initState();
  }

  Future<UserModel> getUserData() async {
    await appOwnerRef.doc(auth.currentUser!.uid).get().then((user) async {
      ptController.initializeUserModel(user);
      if (await messaging.isSupported()) {
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          String? token = await messaging.getToken();
          print('token:    $token');
          appOwnerRef.doc(user.id).update({'mToken': token});
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          blueSnackBar('Provisional Notification', '~~~~~~~~');
        } else {
          purpleSnackBar('Notification Failed',
              'User declined or has not accepted permission');
        }
      }
    });
    return userController.user;
  }

  void initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var iniSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
      iniSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // this happened when app is opened when phone received notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ignore: avoid_print
      print(
          '<><><><><><><><><><><><><><>onMessage<><><><><><><><><><><><><><><><><><>');
      // ignore: avoid_print
      print(
          '${message.notification?.title} // ${message.notification?.body} // // ${message.notification?.bodyLocKey}');
      BigTextStyleInformation btsi = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
        contentTitle: message.notification!.title.toString(),
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('dbfood', 'dbfood',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              styleInformation: btsi);
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);

      if (message.notification != null) {
        topBlueSnackBar(
            message.notification!.title!, message.notification!.body!);
        // showDialog( // this showed error - because not in appOwner i guess
        //     context: context,
        //     builder: ((BuildContext context) {
        //       return DynamicDialog(
        //           title: message.notification!.title,
        //           body: message.notification!.body);
        //     }));
      }
    });
  }

  // this happened when clicked on notification
  // Is it this is for android?
  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      // ignore: avoid_print
      print(
          '<><><><><>inside appowner<><><><><><><><><>$payload<><><><><><><><><><><><><><><><><>');
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => SecondPage(payload),
      // ));
    });
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print(
        '<><><><><>inside appowner background<><><><><><>><><><><><><><><><><><><><><><>');
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  // List<ListTile> getApptToday() {
  //   List<ListTile> todayAppt = [];
  //   List<Appt> todayApp =
  //       apptController.appts.where((appt) => appt.apptTime.isToday()).toList();
  //   for (var apt in todayApp) {
  //     todayAppt.add(ListTile(
  //       title: Text(clinicController.clinicName(apt.clinicId)),
  //       subtitle: Text(DateFormat('dd/MM/yyyy kk:mm').format(apt.apptTime)),
  //     ));
  //   }
  //   return todayAppt;
  // }

  void sendPushMessage(String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAzvKz-NQ:APA91bFoJlr0AAMP0vpqazM7rkZA-kZGwUlM3DllGmkSIYp0c0erG2njGrohHaY046L2T6Ok9ci_P_bFCRqJtQhPApvJRBmG05yv0oX81A9LHSpfyNuZOhmuHJEeCJ_8bvp16h2EFlmR'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },
          "notification": <String, dynamic>{
            'body': body,
            'title': title,
            "android_channel_id": "dbfood"
          },
          "to":
              'fxsDA4uHSZmz9RemlSYeJf:APA91bEBVruGSM2de_Zs5YSTutdQEoBRtcXJZi0krMfIqzABzU0ljN0Zivc58H3IlHYgfrkI1KJS9AUr0EP6DpnZhcCISEt5sQ6ucPNvy_0cpPzooom0kKviN-Yt996fjGOmDnqtBQ4c',
          "topic": 'clinic'
        }),
      );
    } catch (error) {
      print('notification error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserModel u = ac.getUserModel;
    // var platform = Theme.of(context).platform;
    ptController.ctx = context;
    return
        // Obx(() =>
        FutureBuilder<UserModel>(
      future: getUserData(), // getUserData(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.done) {
          // UserModel u = UserModel.fromSnapshot(snapshot.!data);
          UserModel useHere = snapshot.data!;
          return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('app owner'.tr),
                // leading: IconButton(
                //   icon: const Icon(Icons.menu),
                //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                // ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      size: 30,
                    ),
                    onPressed: () => Get.toNamed(createPtRoute),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      size: 30,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  )
                ],
              ),
              // drawer: const LeadingDrawer(ptProfileRoute),
              endDrawer: const EndDrawer(appOwnerRoute),
              backgroundColor: Theme.of(context).primaryColor,
              body: WillPopScope(
                onWillPop: onWillPop,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ExpansionTile(
                        expandedAlignment: Alignment.centerLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        collapsedBackgroundColor: Colors.white,
                        backgroundColor: Colors.white,
                        title: Text('name'.tr + useHere.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Text('ic no'.tr + useHere.ic,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const SizedBox(height: 8),
                                Text('hp no'.tr + useHere.phoneNum,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('email'.tr + useHere.email,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(CreatePt(
                                        name: useHere.name, icNo: useHere.ic));
                                  },
                                  child: Text('mspp'.tr),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          )
                        ],
                      ),
                      // Card(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(10),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: <Widget>[
                      //         const SizedBox(height: 10),
                      //         // Row(
                      //         // children: [
                      //         Text('name'.tr + useHere.name,
                      //             style: const TextStyle(
                      //                 fontSize: 20,
                      //                 fontWeight: FontWeight.bold)),
                      //         // Text(useHere.name,
                      //         // style: const TextStyle(
                      //         // fontSize: 20,
                      //         // fontWeight: FontWeight.bold)),
                      //         // ],
                      //         // ),
                      //         const SizedBox(height: 4),
                      //         Text('ic no'.tr + useHere.ic,
                      //             style: const TextStyle(
                      //                 fontSize: 20,
                      //                 fontWeight: FontWeight.bold)),
                      //         const SizedBox(height: 4),
                      //         Text('hp no'.tr + useHere.phoneNum,
                      //             style: const TextStyle(
                      //                 fontSize: 20,
                      //                 fontWeight: FontWeight.bold)),
                      //         const SizedBox(height: 10),
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             ElevatedButton(
                      //               onPressed: () {
                      //                 Get.to(CreatePt(
                      //                     name: useHere.name,
                      //                     icNo: useHere.ic));
                      //               },
                      //               child: Text('mspp'.tr),
                      //             )
                      //           ],
                      //         ),
                      //         const SizedBox(height: 4),
                      //         // Row(
                      //         //   mainAxisAlignment: MainAxisAlignment.center,
                      //         //   children: [
                      //         //     ElevatedButton(
                      //         //       onPressed: () {
                      //         //         Get.to(const CreatePt());
                      //         //       },
                      //         //       child: Text('mpp'.tr),
                      //         //     )
                      //         //   ],
                      //         // ),

                      //         // ElevatedButton(
                      //         //   onPressed: () {
                      //         //     sendPushMessage('Please success click title',
                      //         //         'Please success same phone');
                      //         //   },
                      //         //   child: const Text('Success go to clinic app'),
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      // StreamBuilder<QuerySnapshot<Object?>>(
                      //     stream: ptNotiRef
                      //         .where('appOwnerId', isEqualTo: useHere.id)
                      //         .snapshots(),
                      //     builder: (BuildContext context,
                      //         AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                      //       switch (snapshot.connectionState) {
                      //         case ConnectionState.none:
                      //           return const Text('No Stream :(');
                      //         // break;
                      //         case ConnectionState.waiting:
                      //           return const Text('Still Waiting...');
                      //         // break;
                      //         case ConnectionState.active:
                      //           List<QueryDocumentSnapshot<Object?>> ss =
                      //               snapshot.data!.docs;
                      //           int unseen = ss
                      //               .where((obj) => obj.get('seen') == false)
                      //               .length;
                      //           List<PtNoti> notis = ss
                      //               .map((obj) => PtNoti.fromSnapshot(obj))
                      //               .toList();
                      //           notis.sort((a, b) =>
                      //               b.createdAt.compareTo(a.createdAt));
                      //           return Container(
                      //             decoration: BoxDecoration(
                      //               border: Border.all(
                      //                   color: Colors.black, width: 1),
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: ExpansionTile(
                      //                 collapsedBackgroundColor: Colors.white,
                      //                 backgroundColor: Colors.white,
                      //                 title: Text(
                      //                     'Unread Notifications = $unseen'),
                      //                 children: [
                      //                   ConstrainedBox(
                      //                     constraints: const BoxConstraints(
                      //                         minHeight: 0, maxHeight: 200),
                      //                     child: ListView(
                      //                       shrinkWrap: true,
                      //                       children: notis
                      //                           .map((noti) => NotiListTile(
                      //                                 setColor: false,
                      //                                 ptNoti: noti,
                      //                                 key: Key(
                      //                                     getRandomString(5)),
                      //                               ))
                      //                           .toList(),
                      //                     ),
                      //                   )
                      //                 ]),
                      //           );
                      //         case ConnectionState.done:
                      //           return const Text('Done. That\'s all');
                      //       }
                      //     }),
                      FutureBuilder(
                        future: ptListController.getPtModels(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<PtModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<PtModel> sth = snapshot.data!;
                            return Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                  initiallyExpanded: true,
                                  collapsedBackgroundColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  title: Text('pt list'.tr),
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          minHeight: 0, maxHeight: 350),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: sth
                                            .map((ptm) => PtTile(ptModel: ptm))
                                            .toList(),
                                      ),
                                    )
                                  ]),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// class DynamicDialog extends StatefulWidget {
//   final title;
//   final body;
//   const DynamicDialog({super.key, this.title, this.body});
//   @override
//   // ignore: library_private_types_in_public_api
//   _DynamicDialogState createState() => _DynamicDialogState();
// }

// class _DynamicDialogState extends State<DynamicDialog> {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.title),
//       actions: <Widget>[
//         OutlinedButton.icon(
//             label: const Text('Close'),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close))
//       ],
//       content: Text(widget.body),
//     );
//   }
// }
