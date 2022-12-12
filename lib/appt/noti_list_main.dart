import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:hsa_app/appt/helpers/routes.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/pt_noti.dart';
// import 'widgets/end_drawer.dart';
// import 'widgets/lead_drawer.dart';

import 'widgets/noti_listtile.dart';

class NotiListMain extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  NotiListMain({super.key});

  // need apptId in ptNoti object? ...hmm...
  // appt centric? [clicnic compulsory put hosp name if under hosp]
  // show 25, then only progressively load, okay ma?
  // click can go to pt appt show page, --> straight ba
  // there put a qr code too so that ppl can register appt
  // !!!!!!!!!!!!!!!!! - below statuses
  // upon get appt, upon cancel appt [appt model]
  // upon in queue, upon called into room [also appt model]
  // if come already still defer, put into clinical notes ba
  // upon confirm attendance - separate (scared after confirm then still defer)

  @override
  Widget build(BuildContext context) {
    ptController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('noti'.tr),
          // leading: IconButton(
          //   icon: const Icon(Icons.menu),
          //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          // ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(
          //       Icons.account_circle,
          //       size: 30,
          //     ),
          //     onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          //   )
          // ],
        ),
        // drawer: const LeadingDrawer(notiListRoute),
        // endDrawer: EndDrawer(ptListController.currentPt.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: StreamBuilder<QuerySnapshot<Object?>>(
            stream: ptNotiRef
                .where('appOwnerId', isEqualTo: auth.currentUser!.uid)
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
                  List<QueryDocumentSnapshot<Object?>> ss = snapshot.data!.docs;
                  List<PtNoti> notis =
                      ss.map((obj) => PtNoti.fromSnapshot(obj)).toList();
                  notis.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
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
                    ),
                  );
                case ConnectionState.done:
                  return const Text('Done. That\'s all');
              }
            }));
  }
}
