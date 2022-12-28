import 'package:flutter/material.dart';
import 'package:hsa_app/appt/widgets/show_images.dart';
import 'models/schedule_model.dart';
import 'widgets/make_appt_bundle.dart';
import '../common/firebase/firebase_const.dart';
import '../appt/models/pt.dart';
import '../appt/models/appt_req.dart';

import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import '../common/functions.dart';
import 'controllers/controllers.dart';
import 'widgets/end_drawer.dart';

class ViewRefReceived extends StatefulWidget {
  const ViewRefReceived({super.key, required this.ar});
  final ApptReq ar;

  @override
  // ignore: library_private_types_in_public_api
  _ViewRefReceivedState createState() => _ViewRefReceivedState();
}

class _ViewRefReceivedState extends State<ViewRefReceived> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late ApptReq apptReq;
  late PtModel localPt;
  // late Future<void> _initPtData;

  Future<void> _initPt() async {
    PtModel pt = await ptRef.doc(apptReq.ptId).get().then((onValue) {
      // print(onValue.exists);
      return PtModel.fromSnapshot(onValue);
    });
    localPt = pt;
  }

  Future<void> _tryInitPt() async {
    PtModel pt = await ptRef
        .doc(apptReq.ptId)
        .get()
        .then((onValue) => PtModel.fromSnapshot(onValue));
    setState(() => localPt = pt);
  }

  @override
  void initState() {
    apptReq = widget.ar;
    // _initPtData = _initPt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('View Screened Referral'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        backgroundColor: Colors.white,
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        body: FutureBuilder(
          future: _initPt(), // _initPtData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _tryInitPt,
                  child: Center(
                      child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _tryInitPt,
                      child: Text(snapshot.error.toString()),
                    ),
                  )));
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      // shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      // mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Name: ${localPt.name}"),
                        Text("Ic: ${localPt.ic}"),
                        Text("Gender: ${localPt.genderWord}"),
                        Text('Address: ${localPt.address}'),
                        Text('Ref. note: ${apptReq.remarks}'),
                        const SizedBox(height: 5),
                        ShowImages(apptReq.refLetterUrl),
                        const SizedBox(height: 5),
                        // add schedule & duration & reject / redirect button --> need pt address? yes
                        FutureBuilder<List<ScheduleModel>>(
                            future: scheduleListController.getScheduleModels(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ScheduleModel>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return MakeApptBundle(
                                    ar: apptReq,
                                    smList: snapshot.data!,
                                    open: false);
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                        // add message component
                        // - belongs to apptReq (pt side & fromClinic) & apptReqDirect (toClinic)?
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        )

        // ListView(
        //   shrinkWrap: true,
        //   padding: const EdgeInsets.all(20),
        //   children: [
        //     Text("Clinic: ${apptReq.toClinicId}",
        //         style:
        //             const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        //     const SizedBox(height: 4),
        //     Text("Notes: ${apptReq.remarks}",
        //         style:
        //             const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        //     const SizedBox(height: 4),
        //     Text("Preferred Dates: $prefDate",
        //         style: const TextStyle(fontSize: 15)),
        //     const SizedBox(height: 4),
        //     const Text("Referral Letter:", style: TextStyle(fontSize: 15)),
        //     const SizedBox(height: 8),
        //     Image.network(apptReq.refLetterUrl),
        //   ],
        // ),

        );
  }
}
