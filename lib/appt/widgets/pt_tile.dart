import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/models/pt.dart';

import '../controllers/controllers.dart';
import '../pt_profile.dart';

class PtTile extends StatelessWidget {
  final PtModel ptModel;
  const PtTile({super.key, required this.ptModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      child: ListTile(
        // dense: true,
        title: Text(ptModel.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(ptModel.ic,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          ptListController.currentPt.value = ptModel;
          apptController.clearApptnApptReq();
          Get.off(
              PtProfile(
                ptModel: ptModel,
              ),
              preventDuplicates: false);
        },
      ),
    );
  }
}
