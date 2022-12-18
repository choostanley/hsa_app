import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controllers.dart';
import '../helpers/routes.dart';
import '../models/schedule_model.dart';
import '../schedule_page.dart';
import '/common/firebase/firebase_const.dart';
import '/common/responsiveness.dart';

class LeadingDrawer extends StatefulWidget {
  final String currentPage;
  const LeadingDrawer(this.currentPage, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LeadingDrawerState createState() => _LeadingDrawerState();
}

class _LeadingDrawerState extends State<LeadingDrawer> {
  late List<ListTile> deptTiles;
  late AssetsAudioPlayer assetsAudioPlayer;

  @override
  void initState() {
    assetsAudioPlayer = AssetsAudioPlayer();
    super.initState();
  }

  ListTile produceTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () => widget.currentPage == route
          ? Get.back()
          : Get.offNamed(route), //Get.toNamed(route),
      tileColor: widget.currentPage == route
          ? Theme.of(context).primaryColorLight
          : null,
    );
  }

  ListTile scheduleTile(BuildContext context, ScheduleModel smod) {
    return ListTile(
      title: Text(smod.name),
      onTap: () {
        if (widget.currentPage == smod.id) {
          Get.back();
        } else {
          scheduleListController.currentSchedule.value = smod;
          Get.off(
              SchedulePage(
                sc: smod,
              ),
              preventDuplicates: false);
        }
      },
      tileColor: widget.currentPage == smod.id
          ? Theme.of(context).primaryColorLight
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width /
            ResponsiveWidget.getDenominator(context),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: RichText(
                  text: const TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.local_hospital,
                            color: Colors.black, size: 20),
                      ),
                      TextSpan(
                          text: ' Clinic Menu',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              produceTile(context, '1. Clinic Profile', clinicProfileRoute),
              produceTile(context, '2. Manual Register Appt', regApptRoute),
              isApp || isWebMobile
                  ? produceTile(context, '2.1. Register Appt [SCAN]', scanApptRoute)
                  : Container(),
              // scan to get pt ptofile - then... make appt for him? send docs?
              // isApp
              //     ? produceTile(context, 'Pt Profile [SCAN]', scanPtRoute)
              //     : Container(),
              // produceTile(context, 'Pt search', searchPtRoute),
              produceTile(context, '3. Consultation Rooms', roomsRoute),
              produceTile(context, '4. Create Schedule', createScheduleRoute),
              FutureBuilder(
                future: scheduleListController.getScheduleModels(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ScheduleModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ExpansionTile(
                      title: const Text('5. Schedules',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      children: snapshot.data!
                          .map((d) => scheduleTile(context, d))
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              produceTile(context, '6. Received Referrals', receivedRefRoute),
              // produceTile(context, 'Screened Referrals', screenedRefRoute),
              // produceTile(context, 'Sent Referrals', sentRefRoute),
              produceTile(context, '7. Colleagues', membersRoute),
              // produceTile(context, 'Time Table', tTableRoute),
            ],
          ),
        ),
      ),
    );
  }
}
