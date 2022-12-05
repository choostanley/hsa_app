import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
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
import 'models/user.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
// import 'package:vibration_web/vibration_web.dart';

class AddMemberKeyboard extends StatefulWidget {
  // final String instruction;

  const AddMemberKeyboard({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AddMemberKeyboardState createState() => _AddMemberKeyboardState();
}

class _AddMemberKeyboardState extends State<AddMemberKeyboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController localIc =
      MaskedTextController(mask: '000000-00-0000', text: '');
  List<UserModel> users = [];

  // void processUserId(String userId) async {
  //   if (memberIds.contains(userId)) {
  //     Get.back();
  //     Future.delayed(const Duration(milliseconds: 1500),
  //         () => blueSnackBar('User Detected', 'User already a member'));
  //   }
  //   drsnReqRef.doc(userId).get().then((doc) async {
  //     if (doc.exists) {
  //       await memberRef.add({
  //         'drSnId': userId,
  //         'drSnName': doc.get('name'),
  //         'addedById': auth.currentUser!.uid,
  //         'clinicId': clinicListController.currentCl.value.id,
  //         'valid': true,
  //         'createdAt': DateTime.now().millisecondsSinceEpoch,
  //         'updatedAt': DateTime.now().millisecondsSinceEpoch,
  //       });
  //       Get.back();
  //       Future.delayed(const Duration(milliseconds: 1500),
  //           () => greenSnackBar('Success', 'User added as member'));
  //     } else {
  //       Get.back();
  //       Future.delayed(const Duration(milliseconds: 1500),
  //           () => redSnackBar('Error', 'User profile does not exist'));
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   justSimply = getTodayAppts();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Add Member'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        body: StreamBuilder<QuerySnapshot<Object?>>(
            stream: memberRef
                .where('clinicId',
                    isEqualTo: clinicListController.currentCl.value.id)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
              // print('before after');
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Text('No Stream :(');
                // break;
                case ConnectionState.waiting:
                  return const Text('Still Waiting...');
                // break;
                case ConnectionState.active:
                  List<QueryDocumentSnapshot<Object?>> ss = snapshot.data!.docs;
                  List<String> freaks =
                      ss.map((obj) => obj.get('drSnIc').toString()).toList();
                  return Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  key: const ValueKey('ic'),
                                  keyboardType: TextInputType.number,
                                  // validator: (val) {
                                  //   if (val!.trim().isEmpty) {
                                  //     return 'IC is required!';
                                  //   } else if (val.trim().length != 14) {
                                  //     return 'IC must be 14 characters long';
                                  //   }
                                  //   return null;
                                  // },
                                  controller: localIc,
                                  decoration: InputDecoration(
                                      labelText: 'IC',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: () async {
                                          if (localIc.text.length == 14) {
                                            QuerySnapshot<Object?> drsnObjs =
                                                await drsnReqRef
                                                    .where('ic',
                                                        isEqualTo: localIc.text)
                                                    .get();
                                            setState(() {
                                              users = drsnObjs.docs
                                                  .map((ss) =>
                                                      UserModel.fromSnapshot(
                                                          ss))
                                                  .toList();
                                            });
                                          }
                                        },
                                      )),
                                  onSaved: (value) {
                                    localIc.text = value!.trim();
                                  },
                                  onChanged: (String sth) async {
                                    if (sth.length == 14) {
                                      QuerySnapshot<Object?> drsnObjs =
                                          await drsnReqRef
                                              .where('ic', isEqualTo: sth)
                                              .get();
                                      setState(() {
                                        users = drsnObjs.docs
                                            .map((ss) =>
                                                UserModel.fromSnapshot(ss))
                                            .toList();
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                ListView(
                                  shrinkWrap: true,
                                  children: users
                                      .map((u) => Container(
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: ListTile(
                                              dense: true,
                                              title: Text(u.name),
                                              subtitle: Text(u.ic),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                    Icons.add_rounded),
                                                color: Colors.blueAccent,
                                                onPressed: freaks.contains(u.ic)
                                                    ? null
                                                    : () {
                                                        memberRef.add({
                                                          'drSnId': u.id,
                                                          'drSnName': u.name,
                                                          'drSnIc': u.ic,
                                                          'addedById': auth
                                                              .currentUser!.uid,
                                                          'clinicId':
                                                              clinicListController
                                                                  .currentCl
                                                                  .value
                                                                  .id,
                                                          'valid': true,
                                                          'createdAt': DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch,
                                                          'updatedAt': DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch,
                                                        });
                                                      },
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                )
                              ],
                            ),
                          )));
                case ConnectionState.done:
                  return const Text('Done. That\'s all');
              }
            })

        // FutureBuilder(
        //   future: justSimply, // _initPtData,
        //   builder: (BuildContext context, AsyncSnapshot snapshot) {
        //     if (snapshot.hasError) {
        //       return RefreshIndicator(
        //           key: _refreshIndicatorKey,
        //           onRefresh: () => getTodayAppts(),
        //           child: Center(
        //               child: SizedBox(
        //             width: 150,
        //             child: ElevatedButton(
        //               onPressed: () => getTodayAppts(),
        //               child: Text(snapshot.error.toString()),
        //             ),
        //           )));
        //     } else if (snapshot.connectionState == ConnectionState.done) {
        //       return Stack(
        //           alignment: FractionalOffset.bottomCenter,
        //           children: <Widget>[
        //             Positioned.fill(
        //               child: MobileScanner(
        //                   allowDuplicates: false,
        //                   controller: MobileScannerController(
        //                       facing: CameraFacing.back, torchEnabled: false),
        //                   onDetect: (barcode, args) async {
        //                     if (!kIsWeb && hasVibrator) {
        //                       Vibration.vibrate();
        //                     } else {
        //                       HapticFeedback.lightImpact();
        //                     }
        //                     if (barcode.rawValue == null) {
        //                       redSnackBar(
        //                           'Failed to scan Barcode', 'Try Again');
        //                     } else {
        //                       final String code = barcode.rawValue!;
        //                       // debugPrint('Barcode found! $code');
        //                       Future.delayed(const Duration(milliseconds: 1500),
        //                           () => greenSnackBar('Success', code));
        //                       processUserId(code);
        //                     }
        //                   }),
        //             ),
        //           ]);
        //     } else {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //   },
        // )

        );
  }
}
