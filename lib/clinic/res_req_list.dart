import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appt/models/res_req.dart';
import '../clinic/helpers/routes.dart';
import '../appt/models/appt_req.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'view_ref_received.dart';
import 'view_res_req.dart';
import 'view_unscreened_ref.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

// RefReceived
// RefReceived

class ResReqList extends StatelessWidget {
  ResReqList({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Reschedule Requests'),
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
        drawer: const LeadingDrawer(resReqListRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: resReqRef
                    .where('clinicId',
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
                      List<ResReq> resReqs =
                          ss.map((obj) => ResReq.fromSnapshot(obj)).toList();
                      resReqs
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  children: resReqs
                                      .map((apt) => ListTile(
                                            // this one later - iron out new public holiday first
                                            // onTap: () =>
                                            //     Get.to(ViewResReq(rr: apt)),
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
                                              'Reason: ${apt.reason}',
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
