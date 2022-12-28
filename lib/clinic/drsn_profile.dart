import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'helpers/routes.dart';
import 'models/user.dart';
import 'package:intl/intl.dart';

import 'widgets/end_drawer.dart';

class DrsnProfile extends StatefulWidget {
  const DrsnProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DrsnProfileState createState() => _DrsnProfileState();
}

class _DrsnProfileState extends State<DrsnProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // late User user;
  // late UserModel userModel;
  // late Future<DocumentSnapshot> getUser;
  // var combining = RegExp(r"[^\\x00-\\x7F]/g");

  @override
  void initState() {
    super.initState();
  }

  Future<UserModel> getUserData() async {
    await drsnReqRef.doc(auth.currentUser!.uid).get().then((user) async {
      drsnController.initializeUserModel(user);
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
          String? token = await messaging.getToken(
              vapidKey:
                  'BPs5rY2FGfNzEu2Z83xGFJEoNEADAGIljrTads9JsHpPpl5HBf23Avgyar1LHEXIBEnqi3wvUHtS1bJQxsqjrsk');
          drsnReqRef.doc(user.id).update({'mToken': token});
        } else {
          if (!drsnController.declinedNoti) {
            purpleSnackBar('Notification Failed',
                'User declined or has not accepted permission');
            drsnController.declinedNoti = true;
          }
        }
      }
    });
    return userController.user;
  }

  @override
  Widget build(BuildContext context) {
    // UserModel u = ac.getUserModel;
    // var platform = Theme.of(context).platform;
    drsnController.ctx = context;
    return
        // Obx(() =>
        FutureBuilder<UserModel>(
      future: getUserData(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.done) {
          // UserModel u = UserModel.fromSnapshot(snapshot.!data);
          UserModel useHere = snapshot.data!;
          return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: const Text('Dr/Sn Profile'),
                // leading: IconButton(
                //   icon: const Icon(Icons.menu),
                //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                // ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      size: 30,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  )
                ],
              ),
              endDrawer: const EndDrawer(drsnProfileRoute),
              backgroundColor: Theme.of(context).primaryColor,
              body: WillPopScope(
                  onWillPop: conWillPop,
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            Text("Name: ${useHere.getName()}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("MMC/LJM no: ${useHere.mmcLjm}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Ic: ${useHere.ic}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Hp no: ${useHere.phoneNum}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Email: ${useHere.email}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            QrImage(
                              padding: const EdgeInsets.all(0),
                              backgroundColor: Colors.white,
                              data: useHere.id,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
