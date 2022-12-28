import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/view_appt.dart';
import '../../clinic/models/appt.dart';
import 'package:intl/intl.dart';

class ApptCardTile extends StatelessWidget {
  final Appt appt;
  const ApptCardTile({super.key, required this.appt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          border: Border.all(width: 1.5),
          borderRadius: BorderRadius.circular(5),
          color: Colors.orangeAccent),
      child: ListTile(
        dense: true,
        isThreeLine: false,
        contentPadding: const EdgeInsets.all(2),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        // tileColor: Colors.orangeAccent,
        title: Text(
          '   ${DateFormat("dd/MM/yyyy kk:mm").format(appt.dateTimeStamp)}H',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
        subtitle: Text('    ${appt.approveRemarks}'),
        onTap: () => Get.to(ViewAppt(apt: appt,)),
      ),
    );
  }
}
