import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';

import '/common/firebase/firebase_const.dart';
import '/common/responsiveness.dart';
import '../login.dart';

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
          : Get.offNamedUntil(route, ModalRoute.withName(ptProfileRoute)),
      tileColor: widget.currentPage == route
          ? Theme.of(context).primaryColorLight
          : null,
      // trailing: IconButton(
      //   icon: const Icon(Icons.volume_up),
      //   onPressed: () {
      //     assetsAudioPlayer.open(
      //       Audio("assets/audios/${box.read('langCode')}_appt.mp3"),
      //     );
      //   },
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width /
            (ResponsiveWidget.isSmallScreen(context)
                ? 1.5
                : ResponsiveWidget.isMediumScreen(context)
                    ? 3
                    : 5),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text(
                  'menu'.tr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              produceTile(context, 'profile'.tr, ptProfileRoute),
              produceTile(context, 'appt'.tr, apptListRoute),
              produceTile(context, 'req appt'.tr, reqApptRoute),
              produceTile(context, 'noti'.tr, notiListRoute),
              // produceTile(context, 'Time Table', tTableRoute),
            ],
          ),
        ),
      ),
    );
  }
}
