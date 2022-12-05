import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';
import 'package:hsa_app/appt/widgets/end_drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../clinic/models/appt.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
// import 'models/appt.dart';
import 'models/pt.dart';
import 'widgets/lead_drawer.dart';
import 'models/user.dart';
import 'package:intl/intl.dart';

class PtProfile extends StatefulWidget {
  const PtProfile({super.key, required this.ptModel});
  final PtModel ptModel;

  @override
  // ignore: library_private_types_in_public_api
  _PtProfileState createState() => _PtProfileState();
}

class _PtProfileState extends State<PtProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PtModel pModel;
  late String gender;
  // late User user;
  // late UserModel userModel;
  // late Future<DocumentSnapshot> getUser;
  // var combining = RegExp(r"[^\\x00-\\x7F]/g");

  @override
  void initState() {
    // ignore: avoid_print
    print(box.read('quote'));
    // ignore: avoid_print
    print('quote mtfk');
    pModel = widget.ptModel;
    print(pModel.id);
    super.initState();
  }

  List<Container> getApptToday() {
    List<Container> todayAppt = [];
    List<Appt> todayApp = apptController.appts
        .where((appt) =>
            DateTime.fromMillisecondsSinceEpoch(appt.dateTimeStamp).isToday())
        .toList();
    for (var apt in todayApp) {
      todayAppt.add(Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          dense: true,
          // this shape doesnt really work, masked by background colour
          // shape: RoundedRectangleBorder(
          //   side: const BorderSide(color: Colors.black, width: 1),
          //   borderRadius: BorderRadius.circular(5),
          // ),
          // tileColor: Colors.white,
          title: Text(apt.clinicName),
          subtitle: Text(DateFormat('dd/MM/yyyy kk:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(apt.dateTimeStamp))),
        ),
      ));
    }
    return todayAppt;
  }

  @override
  Widget build(BuildContext context) {
    ptController.ctx = context;
    // return
    //     FutureBuilder<UserModel>(
    //   future: getUserData(),
    //   builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
    //     if (snapshot.hasError) {
    //       return Center(child: Text(snapshot.error.toString()));
    //     } else if (snapshot.connectionState == ConnectionState.done) {
    //       UserModel useHere = snapshot.data!;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('profile'.tr),
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
        drawer: const LeadingDrawer(ptProfileRoute),
        endDrawer: EndDrawer(pModel.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: onWillPop,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(children: [
                const SizedBox(height: 12),
                Card(
                  // margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        // Row(
                        // children: [
                        Text('name'.tr + pModel.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        // Text(pModel.name,
                        // style: const TextStyle(
                        // fontSize: 20, fontWeight: FontWeight.bold)),
                        // ],
                        // ),
                        const SizedBox(height: 4),
                        // Row(
                        // children: [
                        Text('ic no'.tr + pModel.ic,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        // Text(pModel.ic,
                        // style: const TextStyle(
                        // fontSize: 20, fontWeight: FontWeight.bold)),
                        // ],
                        // ),
                        const SizedBox(height: 4),
                        // Row(
                        // children: [
                        Text('gender'.tr + pModel.genderWord,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        // Text(pModel.genderWord,
                        // style: const TextStyle(
                        // fontSize: 20, fontWeight: FontWeight.bold)),
                        // ],
                        // ),
                        const SizedBox(height: 4),
                        // Row(
                        // children: [
                        Text('race'.tr + pModel.race,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        // Text(pModel.race,
                        // style: const TextStyle(
                        // fontSize: 20, fontWeight: FontWeight.bold)),
                        // ],
                        // ),
                        const SizedBox(height: 4),
                        Text('address'.tr + pModel.address,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QrImage(
                              padding: const EdgeInsets.all(0),
                              backgroundColor: Colors.white,
                              data: pModel.ic,
                              version: QrVersions.auto,
                              size: 150.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Text('today appt'.tr),
                FutureBuilder<List>(
                  future: apptController.refreshApptList(), //getAllClinic(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ExpansionTile(
                          collapsedBackgroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          title: Text(
                              '${'today appt'.tr}${getApptToday().length}'),
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minHeight: 0, maxHeight: 200),
                              child: ListView(
                                shrinkWrap: true,
                                children: getApptToday(),
                              ),
                            )
                          ]);
                    } else {
                      return const CircularProgressIndicator(
                          color: Colors.white);
                    }
                  },
                ),

                // Expanded(
                //   child: ListView(
                //     padding: const EdgeInsets.all(20),
                //     children: [
                //       ListTile(
                //         // onTap: () => Get.to(ViewReq(ar: apt, pd: prefDates)),
                //         tileColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           side: const BorderSide(color: Colors.black, width: 1),
                //           borderRadius: BorderRadius.circular(5),
                //         ),
                //         title: const Text('SFUC'),
                //         subtitle: const Text('17-10-2022'),
                //       ),
                //       ListTile(
                //         // onTap: () => Get.to(ViewReq(ar: apt, pd: prefDates)),
                //         tileColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           side: const BorderSide(color: Colors.black, width: 1),
                //           borderRadius: BorderRadius.circular(5),
                //         ),
                //         title: const Text('SFUC'),
                //         subtitle: const Text('17-10-2022'),
                //       ),
                //       ListTile(
                //         // onTap: () => Get.to(ViewReq(ar: apt, pd: prefDates)),
                //         tileColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           side: const BorderSide(color: Colors.black, width: 1),
                //           borderRadius: BorderRadius.circular(5),
                //         ),
                //         title: const Text('SFUC'),
                //         subtitle: const Text('17-10-2022'),
                //       ),
                //     ],
                //   ),
                // )
              ]),
            )));
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //   },
    // );
  }
}
