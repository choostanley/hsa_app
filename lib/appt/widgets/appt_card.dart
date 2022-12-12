import 'package:flutter/material.dart';
import 'package:hsa_app/clinic/models/appt.dart';

import 'appt_card_tile.dart';

class ApptCard extends StatelessWidget {
  ApptCard({super.key, required this.apptList});
  final List<Appt> apptList;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    apptList.sort((a, b) => b.dateTimeStamp.compareTo(a.dateTimeStamp));
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      margin: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 0),
            color: Colors.orangeAccent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [Text('(Perubatan 91)')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [Text('(Pin. 7/75)')],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('KAD PESAKIT LUAR',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21))
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text('Nama: ${apptList.first.ptName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('No. Kad Pengenalan: ${apptList.first.ptIc}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Jabatan: ${apptList.first.clinicName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('PENJELASAN:'),
                  const SizedBox(height: 10),
                  const Text(
                      '1. Kad ini hendaklah disimpan dengan baik dan jangan dihilangkan.'),
                  const SizedBox(height: 10),
                  const Text(
                      '2. Tiap-tiap kali datang ke Hospital/Klinik untuk berjumpa Doktor, Kad ini hendaklah dibawa bersama dan ditunjukkan bila diminta.'),
                  const SizedBox(height: 40),
                  const Text('PNMB--JB'),
                  const Divider(color: Colors.black, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('TARIKH LAWATAN AKAN DATANG',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15))
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.orangeAccent),
            constraints: const BoxConstraints(minHeight: 0, maxHeight: 180),
            child:
                // Scrollbar(
                //   thumbVisibility: true,
                //   thickness: 10,
                //   controller: _scrollController,
                //   child:
                ListView(
                    shrinkWrap: true,
                    children: apptList
                        .map((appt) => ApptCardTile(appt: appt))
                        .toList()),
            // ),
          )
        ],
      ),
    );
  }
}
