import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../models/hour_model.dart';
import '../models/appt.dart';

import '../controllers/controllers.dart';
import '../models/schedule_model.dart';
import '../schedule_page.dart';
import '../helpers/routes.dart';
import '/common/firebase/firebase_const.dart';
import '/common/responsiveness.dart';
import 'package:intl/intl.dart';

class HourRow extends StatefulWidget {
  final HourModel hour;
  final bool first;
  const HourRow(this.hour, this.first, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HourRowState createState() => _HourRowState();
}

class _HourRowState extends State<HourRow> {
  ValueNotifier<List<Appt>> appts = ValueNotifier<List<Appt>>([]);
  late HourModel localHr;
  late bool first;
  final yourScrollController = ScrollController();

  @override
  void initState() {
    localHr = widget.hour;
    first = widget.first;
    super.initState();
  }

  Container apptTile(Appt appt, int no) {
    // add margin
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      width: 160,
      height: 20,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, top: 5),
        visualDensity: const VisualDensity(vertical: -4),
        title: Text(
          '${no.toString()}. ${appt.ptName}', //${appt.name}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:
                  15.0),
          // this mtfk removed the listTile top padding wtf
          // style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(appt.approveRemarks,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.normal)),
        // onTap: () {
        //   // apptController.setAppt(appt); -- yeah we need an apptCont in clinic too
        //   Get.to(apptPageRoute);
        // }
      ),
    );
  }

  Container timeTile() {
    // where to put noa/maxAppt
    String apptNo = localHr.lunchHour
        ? '[LHr]'
        : '[${localHr.curApptNum.toString()}/${localHr.maxForThisSlot.toString()}]';
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(5)),
        height: 70,
        width: 128,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 8, right: 8),
          title: Text(
              '${DateFormat(first ? 'HH:mm' : 'kk:mm').format(localHr.startDateTime)}H  $apptNo'),
          subtitle: ElevatedButton(
            onPressed: localHr.lunchHour
                ? null
                : () async {
                    List<Appt> hourAppts = await hourApptListController
                        .storeHourAndloadAppts(localHr);
                    hourAppts
                        .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    appts.value = hourAppts;
                    setState(() {
                      localHr.curApptNum = hourAppts.length;
                    });
                  },
            style: ButtonStyle(
                // padding: MaterialStateProperty.all<EdgeInsets>(1.0) //const EdgeInsets.all(1),
                backgroundColor: localHr.lunchHour
                    ? MaterialStateProperty.all<Color>(Colors.grey)
                    : MaterialStateProperty.all<Color>(Colors.blue),
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4)),
            child: const Text('Load Appt'),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // 60,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          timeTile(),
          Expanded(
            child: ValueListenableBuilder<List<Appt>>(
              valueListenable: appts,
              builder: (context, value, _) {
                return value.isEmpty
                    ? Container()
                    : Scrollbar(
                        thumbVisibility: true,
                        thickness: 10,
                        controller: yourScrollController,
                        child:
                            // Padding(
                            //   padding: const EdgeInsets.only(bottom: 10.0),
                            //   child:
                            SizedBox(
                              height: 70,
                              child: ListView.builder(
                          controller: yourScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                              return apptTile(
                                  value[index], value.length - (index));
                          },
                          // ),
                        ),
                            ),
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
