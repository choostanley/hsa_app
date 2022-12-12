import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/pt.dart';
import 'package:hsa_app/common/functions.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../clinic/models/appt.dart';
import '../controllers/controllers.dart';
import 'package:intl/intl.dart';

class ApptListStyle extends StatelessWidget {
  // initially in PtPorfile page;
  const ApptListStyle({super.key, required this.pModel});
  final PtModel pModel;

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 12),
        ExpansionTile(
          // leading: const Icon(Icons.qr_code),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          title: Text(pModel.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          subtitle: Text(pModel.ic,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('gender'.tr + pModel.genderWord,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('race'.tr + pModel.race,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('address'.tr + pModel.address,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // Text('today appt'.tr),
        FutureBuilder<List>(
          future: apptController.refreshApptList(), //getAllClinic(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ExpansionTile(
                  initiallyExpanded: true,
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  title: Text('${'today appt'.tr}${getApptToday().length}'),
                  children: [
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minHeight: 0, maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        children: getApptToday(),
                      ),
                    )
                  ]);
            } else {
              return const CircularProgressIndicator(color: Colors.white);
            }
          },
        ),
      ]),
    );
  }
}
