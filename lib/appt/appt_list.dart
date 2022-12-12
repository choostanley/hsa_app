import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';

import '../clinic/models/appt.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
// import 'models/appt.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class ApptList extends StatefulWidget {
  const ApptList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApptListState createState() => _ApptListState();
}

class _ApptListState extends State<ApptList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<ListTile> apptTiles;

  @override
  void initState() {
    apptTiles = getAllAppt();
    // print(ptListController.currentPt.value.id);
    super.initState();
  }

  List<ListTile> getAllAppt() {
    List<ListTile> allAppt = [];
    List<Appt> allApp = apptController.appts;
    allApp.sort((a, b) => b.dateTimeStamp.compareTo(a.dateTimeStamp));

    for (var apt in allApp) {
      allAppt.add(ListTile(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        tileColor: Colors.white,
        title: Text(apt.clinicName),
        subtitle: Text(DateFormat('dd-MM-yyyy kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(apt.dateTimeStamp))),
      ));
    }
    return allAppt;
  }

  @override
  Widget build(BuildContext context) {
    ptController.ctx = context;

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('appt'.tr),
          // leading: IconButton(
          //   icon: const Icon(Icons.menu),
          //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          // ),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh, size: 30),
                onPressed: () async {
                  await apptController.refreshApptList();
                  setState(() => apptTiles = getAllAppt());
                }),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        // drawer: const LeadingDrawer(apptListRoute),
        endDrawer: EndDrawer(ptListController.currentPt.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: apptTiles.isEmpty
              ? Center(
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // background
                  ),
                  onPressed: () async {
                    await apptController.refreshApptList();
                    setState(() {
                      apptTiles = getAllAppt();
                    });
                  },
                  child: Text('no appt'.tr,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ))
              : RefreshIndicator(
                  onRefresh: () async {
                    await apptController.refreshApptList();
                    // return Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      apptTiles = getAllAppt();
                    });
                    // });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: apptTiles,
                  ),
                ),
        ),
        bottomNavigationBar: const BottomNav(curIndex: 1));
  }
}
