import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/pt.dart';
import 'package:hsa_app/common/functions.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../clinic/models/appt.dart';
import '../controllers/controllers.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'appt_card.dart';

class ApptCardStyle extends StatelessWidget {
  // initially in PtPorfile page;
  const ApptCardStyle({super.key, required this.pModel});
  final PtModel pModel;

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
        FutureBuilder<List<Appt>>(
          future: apptController.refreshApptList(),
          builder: (BuildContext context, AsyncSnapshot<List<Appt>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Appt> arranged = snapshot.data!;
              arranged
                  .sort((a, b) => b.dateTimeStamp.compareTo(a.dateTimeStamp));
              Map<String, List<Appt>> arrangededAppt =
                  arranged.groupListsBy((a) => a.clinicId);
              // hospefully sorted
              return Column(
                children: arrangededAppt.values
                    .toList()
                    .map((aa) => ApptCard(apptList: aa))
                    .toList(),
              );
            } else {
              return const CircularProgressIndicator(color: Colors.white);
            }
          },
        ),
      ]),
    );
  }
}
