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

class AddMemberCamera extends StatefulWidget {
  // final String instruction;

  const AddMemberCamera({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AddMemberCameraState createState() => _AddMemberCameraState();
}

class _AddMemberCameraState extends State<AddMemberCamera> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  // late QRViewController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future justSimply;
  bool hasVibrator = false;
  late List<String> memberIds;

  Future<void> getTodayAppts() async {
    // List<ScheduleModel> scModels =
    //     await scheduleListController.getScheduleModels();
    QuerySnapshot<Object?> memberObjs = await memberRef
        .where('clinicId', isEqualTo: clinicListController.currentCl.value.id)
        .get();
    memberIds =
        memberObjs.docs.map((mo) => mo.get('drSnId').toString()).toList();
    if (!kIsWeb) {
      hasVibrator = (await Vibration.hasVibrator())!;
    }
  }

  void processUserId(String userId) async {
    if (memberIds.contains(userId)) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 1500),
          () => blueSnackBar('User Detected', 'User already a member'));
    }
    drsnReqRef.doc(userId).get().then((doc) async {
      if (doc.exists) {
        await memberRef.add({
          'drSnId': userId,
          'drSnName': doc.get('name'),
          'drSnIc': doc.get('ic'),
          'addedById': auth.currentUser!.uid,
          'clinicId': clinicListController.currentCl.value.id,
          'valid': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        Get.back();
        Future.delayed(const Duration(milliseconds: 1500),
            () => greenSnackBar('Success', 'User added as member'));
      } else {
        Get.back();
        Future.delayed(const Duration(milliseconds: 1500),
            () => redSnackBar('Error', 'User profile does not exist'));
      }
    });
  }

  @override
  void initState() {
    justSimply = getTodayAppts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('QR Scan Add Member'),
          // leading: IconButton(
          //   icon: const Icon(Icons.local_hospital, size: 30),
          //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          // ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        // drawer: const LeadingDrawer(scanApptRoute),
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
                              Future.delayed(const Duration(milliseconds: 1500),
                                  () => greenSnackBar('Success', code));
                              processUserId(code);
                            }
                          }),
                    ),
                    // Positioned(
                    //   width: 60,
                    //   height: 40,
                    //   bottom: 40,
                    //   child: ElevatedButton(
                    //       child: const Icon(Icons.refresh),
                    //       onPressed: () => getTodayAppts()),
                    // )
                  ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
