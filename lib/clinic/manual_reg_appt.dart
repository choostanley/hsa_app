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
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';

class ManualRegAppt extends StatefulWidget {
  const ManualRegAppt({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ManualRegApptState createState() => _ManualRegApptState();
}

class _ManualRegApptState extends State<ManualRegAppt> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  // late QRViewController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Appt> fullAppt = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future justSimply;
  bool hasVibrator = false;
  TextEditingController localIc =
      MaskedTextController(mask: '000000-00-0000', text: '');
  List<String> scIds = [];

  @override
  void initState() {
    loadScheduleIds();
    justSimply = getTodayAppts();
    super.initState();
  }

  Future<void> loadScheduleIds() async {
    List<ScheduleModel> scModels =
        await scheduleListController.getScheduleModels();
    scIds = scModels.map((sm) => sm.id).toList();
  }

  Future<void> getTodayAppts() async {
    List<ScheduleModel> scModels =
        await scheduleListController.getScheduleModels();
    scIds = scModels.map((sm) => sm.id).toList();
    if (scIds.isNotEmpty) {
      QuerySnapshot<Object?> apptObjs = await apptRef
          .where('scheduleId', whereIn: scIds)
          .where('dateString', isEqualTo: getDate(DateTime.now()))
          .where('active', isEqualTo: true)
          .where('attended', isEqualTo: false)
          .get();
      setState(() {
        fullAppt = apptObjs.docs.map((ao) => Appt.fromSnapshot(ao)).toList();
      });
    }
    // print('+_+_+_+_+_+_+${fullAppt.length}_+_+_+_+_+_+_+_');
    if (!kIsWeb) {
      hasVibrator = (await Vibration.hasVibrator())!;
    }
  }

  void processApptId(String apptId) async {
    Appt? getAppt = fullAppt.firstWhereOrNull((appt) => appt.id == apptId);
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
      'body': 'Registered ${getAppt.ptName} in ${getAppt.scheduleName} queue.',
      'createdAt': now,
      'updatedAt': now,
    });
    sendPushMessageToPt(mToken, currentClinic.name,
        'Registered ${getAppt.ptName} in ${getAppt.scheduleName} queue.');
    apptRef.doc(getAppt.id).update({'attended': true});
    // .then((_) {
    // fullAppt.removeWhere((appt) => appt.ptIc == ptIc);
    // });
    greenSnackBar(getAppt.scheduleName, getAppt.ptName);
  }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Register Appointment'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh, size: 30),
                onPressed: () => getTodayAppts()),
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
              return Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Today\'s Appointment',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: const ValueKey('ic'),
                              keyboardType: TextInputType.number,
                              controller: localIc,
                              decoration: InputDecoration(
                                  labelText: 'Patient IC',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      if (localIc.text.isNotEmpty) {
                                        fullAppt.sort((a, b) {
                                          if (a.ptIc.startsWith(
                                              localIc.text.trim())) {
                                            return -1;
                                          }
                                          if (b.ptIc.startsWith(
                                              localIc.text.trim())) {
                                            return 1;
                                          }
                                          return a.dateTimeStamp
                                              .compareTo(b.dateTimeStamp);
                                        });
                                      }
                                    },
                                  )),
                              // onSaved: (value) {
                              //   localIc.text = value!.trim();
                              // },
                              onChanged: (String sth) {
                                if (sth.isNotEmpty) {
                                  fullAppt.sort((a, b) {
                                    if (a.ptIc.startsWith(sth.trim())) {
                                      return -1;
                                    }
                                    if (b.ptIc.startsWith(sth.trim())) {
                                      return 1;
                                    }
                                    return a.dateTimeStamp
                                        .compareTo(b.dateTimeStamp);
                                  });
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<QuerySnapshot<Object?>>(
                                stream: scIds.isNotEmpty
                                    ? apptRef
                                        .where('scheduleId', whereIn: scIds)
                                        .where('dateString',
                                            isEqualTo: getDate(DateTime.now()))
                                        .where('active', isEqualTo: true)
                                        .where('attended', isEqualTo: false)
                                        .snapshots()
                                    : apptRef
                                        .where('scheduleId', isEqualTo: '')
                                        .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot<Object?>>
                                        snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return const Text('No Stream :(');
                                    // break;
                                    case ConnectionState.waiting:
                                      return const Text('Still Waiting...');
                                    // break;
                                    case ConnectionState.active:
                                      List<QueryDocumentSnapshot<Object?>> ss =
                                          snapshot.data!.docs;
                                      fullAppt = ss
                                          .map((sAppt) =>
                                              Appt.fromSnapshot(sAppt))
                                          .toList();
                                      if (localIc.text.isNotEmpty) {
                                        fullAppt.sort((a, b) {
                                          if (a.ptIc.startsWith(
                                              localIc.text.trim())) {
                                            return -1;
                                          }
                                          if (b.ptIc.startsWith(
                                              localIc.text.trim())) {
                                            return 1;
                                          }
                                          return a.dateTimeStamp
                                              .compareTo(b.dateTimeStamp);
                                        });
                                      } else {
                                        fullAppt.sort((a, b) => a.dateTimeStamp
                                            .compareTo(b.dateTimeStamp));
                                      }
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: fullAppt.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: ListTile(
                                                title: Text(
                                                    fullAppt[index].ptName,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(fullAppt[index].ptIc),
                                                    Text(
                                                        '${fullAppt[index].scheduleName} ${DateFormat("HH:mm").format(fullAppt[index].dateTimeStamp)}'),
                                                    // Text( DateForma),
                                                  ],
                                                ),
                                                isThreeLine: true,
                                                // dense: true,
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                      Icons.check_box_outlined,
                                                      size: 35,
                                                      color: Colors.blueAccent),
                                                  onPressed: () =>
                                                      processApptId(
                                                          fullAppt[index].id),
                                                ),
                                              ),
                                            );
                                          });
                                    // break;
                                    case ConnectionState.done:
                                      return const Text('Done. That\'s all');
                                    // break;
                                  }
                                })
                          ],
                        ),
                      )));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
