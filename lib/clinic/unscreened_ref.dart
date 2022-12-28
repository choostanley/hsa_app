import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../clinic/helpers/routes.dart';
import '../appt/models/appt_req.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'view_ref_received.dart';
import 'view_unscreened_ref.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

// RefReceived
// RefReceived

class UnscreenedRef extends StatelessWidget {
  UnscreenedRef({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('New Referrals'),
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
        drawer: const LeadingDrawer(unscreenedRefRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: apptReqRef
                    .where('toClinicId',
                        isEqualTo: clinicListController.currentCl.value.id)
                    .where('screenedById', isEqualTo: '')
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
                                                ViewUnscreenedRef(ar: apt)),
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
                })));
  }
}
