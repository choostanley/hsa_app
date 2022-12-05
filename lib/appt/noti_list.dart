import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';

import '../clinic/models/appt.dart';
import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
// import 'models/appt.dart';
import 'models/pt_noti.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

import 'widgets/noti_listtile.dart';

class NotiList extends StatelessWidget {
//   const NotiList({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _NotiListState createState() => _NotiListState();
// }

// class _NotiListState extends State<NotiList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  NotiList({super.key});

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    ptController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('noti'.tr),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
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
        drawer: const LeadingDrawer(notiListRoute),
        endDrawer: EndDrawer(ptListController.currentPt.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: onWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: ptNotiRef
                    .where('ptId',
                        isEqualTo: ptListController.currentPt.value.id)
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
                      List<PtNoti> notis =
                          ss.map((obj) => PtNoti.fromSnapshot(obj)).toList();
                      notis.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: notis
                              .map((noti) => NotiListTile(
                                    setColor: true,
                                    ptNoti: noti,
                                    key: Key(getRandomString(5)),
                                  ))
                              .toList(),
                        ),
                      );
                    case ConnectionState.done:
                      return const Text('Done. That\'s all');
                  }
                })));
  }
}
