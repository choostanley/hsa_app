import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../clinic/helpers/routes.dart';
import '../appt/models/appt_req.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'view_ref_received.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class RefReceived extends StatelessWidget {
  RefReceived({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _RefReceivedState createState() => _RefReceivedState();
// }

// class _RefReceivedState extends State<RefReceived> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // late List<ListTile> _reqApptTiles;

  // @override
  // void initState() {
  //   _reqApptTiles = getrAllAppt();
  //   super.initState();
  // }

  // List<ListTile> getrAllAppt() {
  //   List<ListTile> allrAppt = [];
  //   List<ApptReq> allrApp = refReceivedListController.refRecList;
  //   allrApp.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  //   for (var apt in allrApp) {
  //     if (apt.toClinicId == clinicListController.currentCl.value.id &&
  //         apt.attById.isEmpty) {
  //       allrAppt.add(ListTile(
  //         onTap: () => Get.to(ViewRefReceived(ar: apt)),
  //         tileColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           side: const BorderSide(color: Colors.black, width: 1),
  //           borderRadius: BorderRadius.circular(5),
  //         ),
  //         title: Text(apt.ptName),
  //         subtitle: Text(
  //           apt.remarks,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ));
  //     }
  //   }
  //   return allrAppt;
  // }

  @override
  Widget build(BuildContext context) {
    // UserModel u = ac.getUserModel;
    // var platform = Theme.of(context).platform;
    drsnController.ctx = context;
    print(clinicListController.currentCl.value.id);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Received Referrals'),
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
        drawer: const LeadingDrawer(receivedRefRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: apptReqRef
                    .where('toClinicId',
                        isEqualTo: clinicListController.currentCl.value.id)
                    .where('attById', isEqualTo: '')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
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
                      List<ApptReq> apptReqs =
                          ss.map((obj) => ApptReq.fromSnapshot(obj)).toList();
                      apptReqs
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  children: apptReqs
                                      .map((apt) => ListTile(
                                            onTap: () => Get.to(
                                                ViewRefReceived(ar: apt)),
                                            tileColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            title: Text(apt.ptName),
                                            subtitle: Text(
                                              apt.remarks,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )));
                    case ConnectionState.done:
                      return const Text('Done. That\'s all');
                  }
                })
            // _reqApptTiles.isEmpty
            //     ? Center(
            //         child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.white, // background
            //         ),
            //         onPressed: () async {
            //           await refReceivedListController.getAllRefRec();
            //           setState(() {
            //             _reqApptTiles = getrAllAppt();
            //           });
            //         },
            //         child: const Text('No Referral Received',
            //             style: TextStyle(
            //                 fontSize: 15,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black)),
            //       ))
            //     : Center(
            //       child: ConstrainedBox(
            //           constraints: const BoxConstraints(maxWidth: 500),
            //           child: RefreshIndicator(
            //             onRefresh: () async {
            //               await refReceivedListController.getAllRefRec();
            //               // return Future.delayed(const Duration(seconds: 1), () {
            //               setState(() {
            //                 _reqApptTiles = getrAllAppt();
            //               });
            //               // });
            //             },
            //             child: ListView(
            //               padding: const EdgeInsets.all(20),
            //               children: _reqApptTiles,
            //             ),
            //           ),
            //         ),
            //     ),
            ));
  }
}
