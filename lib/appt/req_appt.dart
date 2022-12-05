import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appt/helpers/routes.dart';
import '../appt/models/appt_req.dart';

import 'controllers/controllers.dart';
import 'create_ar.dart';
import '/common/functions.dart';
import 'view_req.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class ReqAppt extends StatefulWidget {
  const ReqAppt({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReqApptState createState() => _ReqApptState();
}

class _ReqApptState extends State<ReqAppt> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<ListTile> reqApptTiles;

  @override
  void initState() {
    reqApptTiles = getrAllAppt();
    super.initState();
  }

  List<ListTile> getrAllAppt() {
    List<ListTile> allrAppt = [];
    List<ApptReq> allrApp = apptController.apptReqs;
    allrApp.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var apt in allrApp) {
      String prefDates = apt.prefApptTime
          .map((dt) => DateFormat('dd-MM-yyyy').format(dt))
          .join(' / ');
      allrAppt.add(ListTile(
        onTap: () => Get.to(ViewReq(ar: apt, pd: prefDates)),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        // title: Text(clinicController.clinicName(apt.toClinicId)),
        title: Text(apt.toClinicName),
        subtitle: Text(
          // prefDates,
          apt.remarks,
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }
    return allrAppt;
  }

  @override
  Widget build(BuildContext context) {
    // UserModel u = ac.getUserModel;
    // var platform = Theme.of(context).platform;
    ptController.ctx = context;
    // return
    //     // Obx(() =>
    //     FutureBuilder<List>(
    //   future: getAllAppt(),
    //   builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
    //     if (snapshot.hasError) {
    //       return Center(child: Text(snapshot.error.toString()));
    //     } else if (snapshot.connectionState == ConnectionState.done) {
    //       // UserModel u = UserModel.fromSnapshot(snapshot.!data);
    //       UserModel useHere = snapshot.data!;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('req appt'.tr),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.to(const CreateAr()),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 30),
              onPressed: () async {
                await apptController.refreshApptReqList();
                setState(() => reqApptTiles = getrAllAppt());
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(reqApptRoute),
        endDrawer: EndDrawer(ptListController.currentPt.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: reqApptTiles.isEmpty
              ? Center(
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // background
                  ),
                  onPressed: () async {
                    await apptController.refreshApptReqList();
                    setState(() {
                      reqApptTiles = getrAllAppt();
                    });
                  },
                  child: Text('no req'.tr,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ))
              : RefreshIndicator(
                  onRefresh: () async {
                    await apptController.refreshApptReqList();
                    // return Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      reqApptTiles = getrAllAppt();
                    });
                    // });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: reqApptTiles,
                  ),
                ),
        ));
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //   },
    // );
  }
}
