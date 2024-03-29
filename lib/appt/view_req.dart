import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/appt_req.dart';
import 'package:hsa_app/clinic/models/appt.dart';
import 'package:hsa_app/common/firebase/firebase_const.dart';
import '../clinic/models/ar_dir.dart';
import 'view_appt.dart';
import 'widgets/end_drawer.dart';
import 'widgets/ref_letter_picker.dart';

import 'controllers/controllers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'widgets/show_images.dart';

class ViewReq extends StatefulWidget {
  const ViewReq(
      {super.key,
      required this.ar,
      required this.pd,
      this.fromViewAppt = false});
  final ApptReq ar;
  final String pd;
  final bool fromViewAppt;

  @override
  // ignore: library_private_types_in_public_api
  _ViewReqState createState() => _ViewReqState();
}

class _ViewReqState extends State<ViewReq> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late firebase_storage.Reference storageRef;

  late ApptReq apptReq;
  late String prefDate;
  late Future<Appt?> givenAppt;
  final yourScrollController = ScrollController();
  late Future<List<ArDir>> allArDir;

  @override
  void initState() {
    apptReq = widget.ar;
    prefDate = widget.pd;
    givenAppt = getAppt(apptReq.id);
    allArDir = getAllArDir();
    super.initState();
  }

  Future<Appt?> getAppt(String arId) async {
    QuerySnapshot<Object?> ar =
        await apptRef.where('apptReqId', isEqualTo: arId).get();
    if (ar.docs.isNotEmpty) {
      return Appt.fromSnapshot(ar.docs.first);
    } else {
      return null;
    }
  }

  Future<List<ArDir>> getAllArDir() async {
    List<ArDir> arDirs = [];
    await arDirRef.where('arId', isEqualTo: apptReq.id).get().then((onValue) {
      for (var ad in onValue.docs) {
        arDirs.add(ArDir.fromSnapshot(ad));
      }
    });
    return arDirs;
  }

  Container ardTile(ArDir ard, int no) {
    // add margin
    String apptGiven = ard.accepted ? '(appt given)' : '';
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(right: 3, top: 1.5, bottom: 2),
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      width: 160,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, top: 5, bottom: 0),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        title: Text(
          '${no.toString()}. ${ard.toClinicName} $apptGiven',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0), // this mtfk removed the listTile top padding wtf
          // style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ard.message, overflow: TextOverflow.ellipsis),
              Text(DateFormat('dd-MM-yyyy kk:mm').format(ard.createdAt)),
            ],
          ),
        ),
        onTap: apptGiven.isEmpty
            ? null
            : widget.fromViewAppt
                ? () => Get.back()
                : () async {
                    DocumentSnapshot<Object?> apptObj =
                        await apptRef.doc(ard.apptId).get();
                    Appt appt = Appt.fromSnapshot(apptObj);
                    Get.to(ViewAppt(apt: appt)); // go back here
                  },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('view appt req'.tr, overflow: TextOverflow.ellipsis),
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
      endDrawer: EndDrawer(ptListController.currentPt.value.id),
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Text("Clinic: ${apptReq.toClinicName}",
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Notes: ${apptReq.remarks}",
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Preferred Dates: $prefDate",
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          const Text("Referral Letter:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          ShowImages(apptReq.refLetterUrl),
          const SizedBox(height: 18),
          const Text('Handled by:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          FutureBuilder<List<ArDir>>(
              future: allArDir,
              builder:
                  (BuildContext context, AsyncSnapshot<List<ArDir>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<ArDir> adList = snapshot.data!;
                  adList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return Scrollbar(
                    thumbVisibility: true,
                    thickness: 10,
                    controller: yourScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: adList.length,
                        itemBuilder: (context, index) {
                          return ardTile(
                              adList[index], adList.length - (index));
                        },
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator());
                }
              })
          // FutureBuilder(
          //   future: givenAppt, // change to get arDir, check last if accepted
          //   builder: (BuildContext context, AsyncSnapshot<Appt?> snapshot) {
          //     if (snapshot.hasError) {
          //       return Center(child: Text(snapshot.error.toString()));
          //     } else if (snapshot.connectionState == ConnectionState.done) {
          //       if (snapshot.data != null) {
          //         return Container(
          //           decoration: BoxDecoration(
          //               border: Border.all(),
          //               borderRadius: BorderRadius.circular(5)),
          //           child: ListTile(
          //             dense: true,
          //             title: Text(snapshot.data!.scheduleName),
          //             subtitle: Text(DateFormat('dd-MM-yyyy kk:mm').format(
          //                 DateTime.fromMillisecondsSinceEpoch(
          //                     snapshot.data!.dateTimeStamp))),
          //           ),
          //         );
          //       } else {
          //         return const Text('Appointment not given yet');
          //       }
          //     } else {
          //       return const Center(child: CircularProgressIndicator());
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
