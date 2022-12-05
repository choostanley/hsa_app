import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/appt_req.dart';
import 'package:hsa_app/clinic/models/appt.dart';
import 'package:hsa_app/common/firebase/firebase_const.dart';
import 'widgets/end_drawer.dart';
import 'widgets/ref_letter_picker.dart';

import 'controllers/controllers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'widgets/show_images.dart';

class ViewReq extends StatefulWidget {
  const ViewReq({super.key, required this.ar, required this.pd});
  final ApptReq ar;
  final String pd;

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

  @override
  void initState() {
    apptReq = widget.ar;
    prefDate = widget.pd;
    givenAppt = getAppt(apptReq.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('View Request'),
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
          const Text('Appointment:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          FutureBuilder(
            future: givenAppt,
            builder: (BuildContext context, AsyncSnapshot<Appt?> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(5)),
                    child: ListTile(
                      dense: true,
                      title: Text(snapshot.data!.scheduleName),
                      subtitle: Text(DateFormat('dd-MM-yyyy kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              snapshot.data!.dateTimeStamp))),
                    ),
                  );
                } else {
                  return const Text('Appointment not given yet');
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
