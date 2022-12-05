import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/helpers/routes.dart';
import 'package:hsa_app/common/functions.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../common/firebase/firebase_const.dart';
import '/clinic/models/appt.dart';

import 'controllers/controllers.dart';
import 'models/clinic_model.dart';
import 'models/schedule_model.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
// import 'package:vibration_web/vibration_web.dart';

class ApptQrCamera extends StatefulWidget {
  // final String instruction;

  const ApptQrCamera({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ApptQrCameraState createState() => _ApptQrCameraState();
}

class _ApptQrCameraState extends State<ApptQrCamera> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  // late QRViewController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Appt> fullAppt = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future justSimply;
  bool hasVibrator = false;

  Future<void> getTodayAppts() async {
    List<ScheduleModel> scModels =
        await scheduleListController.getScheduleModels();
    List<String> scIds = scModels.map((sm) => sm.id).toList();
    if (scIds.isNotEmpty) {
      QuerySnapshot<Object?> apptObjs = await apptRef
          .where('scheduleId', whereIn: scIds)
          .where('dateString', isEqualTo: getDate(DateTime.now()))
          .where('active', isEqualTo: true)
          .where('attended', isEqualTo: false)
          .get();
      // Add ic into appt model
      fullAppt = apptObjs.docs.map((ao) => Appt.fromSnapshot(ao)).toList();
    }
    // print('+_+_+_+_+_+_+${fullAppt.length}_+_+_+_+_+_+_+_');
    if (!kIsWeb) {
      hasVibrator = (await Vibration.hasVibrator())!;
    }
  }

  void processPtIc(String ptIc) async {
    Appt? getAppt = fullAppt.firstWhereOrNull((appt) => appt.ptIc == ptIc);
    if (getAppt == null) {
      redSnackBar('No Appt found', 'Please recheck appt schedule.');
      return;
    }
    DocumentSnapshot<Object?> pt = await ptRef.doc(getAppt.ptId).get();
    String ownerId = pt.get('ownerId');
    DocumentSnapshot<Object?> owner = await appOwnerRef.doc(ownerId).get();
    String mToken = owner.get('mToken');
    ClinicModel currentClinic = clinicListController.currentCl.value;
    int now = DateTime.now().millisecondsSinceEpoch;
    await queueRef.add({
      'ptId': getAppt.ptId,
      'ptIc': getAppt.ptIc,
      'ptName': getAppt.ptName,
      'scheduleId': getAppt.scheduleId,
      'calledById': '',
      'approveRemarks': getAppt.approveRemarks,
      'called': false,
      'entered': false,
      'createdAt': now,
      'updatedAt': now,
    });
    await ptNotiRef.add({
      'ptId': getAppt.ptId,
      'appOwnerId': ownerId,
      'seen': false,
      'clinicId': currentClinic.id,
      'title': currentClinic.name,
      'body': '${getAppt.ptName} in ${getAppt.scheduleName} queue.',
      'createdAt': now,
      'updatedAt': now,
    });
    sendPushMessageToPt(mToken, currentClinic.name,
        '${getAppt.ptName} in ${getAppt.scheduleName} queue.');
    apptRef.doc(getAppt.id).update({'attended': true}).then((_) {
      fullAppt.removeWhere((appt) => appt.ptIc == ptIc);
    });
    greenSnackBar(getAppt.scheduleName, getAppt.ptName);
  }

  @override
  void initState() {
    justSimply = getTodayAppts();
    super.initState();
  }

  // void sendPushMessage(String token, String title, String body) async {
  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization':
  //             'key=AAAAzvKz-NQ:APA91bFoJlr0AAMP0vpqazM7rkZA-kZGwUlM3DllGmkSIYp0c0erG2njGrohHaY046L2T6Ok9ci_P_bFCRqJtQhPApvJRBmG05yv0oX81A9LHSpfyNuZOhmuHJEeCJ_8bvp16h2EFlmR'
  //       },
  //       body: jsonEncode(<String, dynamic>{
  //         'priority': 'high',
  //         'data': <String, dynamic>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'status': 'done',
  //           'body': body,
  //           'title': title,
  //         },
  //         "notification": <String, dynamic>{
  //           'body': body,
  //           'title': title,
  //           "android_channel_id": "dbfood"
  //         },
  //         "to": token,
  //         "topic": 'pt'
  //       }),
  //     );
  //   } catch (error) {
  //     print('notification error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('QR Scan'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(scanApptRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        body: FutureBuilder(
          future: justSimply, // _initPtData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () => getTodayAppts(),
                  child: Center(
                      child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () => getTodayAppts(),
                      child: Text(snapshot.error.toString()),
                    ),
                  )));
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                  alignment: FractionalOffset.bottomCenter,
                  children: <Widget>[
                    Positioned.fill(
                      child: MobileScanner(
                          allowDuplicates: false,
                          controller: MobileScannerController(
                              facing: CameraFacing.back, torchEnabled: false),
                          onDetect: (barcode, args) async {
                            if (!kIsWeb && hasVibrator) {
                              Vibration.vibrate();
                            } else {
                              HapticFeedback.lightImpact();
                            }
                            if (barcode.rawValue == null) {
                              redSnackBar(
                                  'Failed to scan Barcode', 'Try Again');
                            } else {
                              final String code = barcode.rawValue!;
                              // debugPrint('Barcode found! $code');
                              greenSnackBar('Success', code);
                              processPtIc(code);
                            }
                          }),
                    ),
                    Positioned(
                      width: 60,
                      height: 40,
                      bottom: 40,
                      child: ElevatedButton(
                          child: const Icon(Icons.refresh),
                          onPressed: () => getTodayAppts()),
                    )
                  ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     print(scanData.code);
  //     // setState(() {
  //     //   result = scanData;
  //     // });
  //     // Navigator.pop(context, result.code);
  //     // Get.back(result: 'success');
  //   });
  // }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }
}
