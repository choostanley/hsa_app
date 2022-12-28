import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../clinic_profile.dart';
import '/clinic/helpers/routes.dart';
import '/clinic/models/clinic_model.dart';

import '../controllers/controllers.dart';
import '/common/responsiveness.dart';
import '../loginc.dart';

class EndDrawer extends StatefulWidget {
  final String currentPage;
  const EndDrawer(this.currentPage, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EndDrawerState createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  late List<ListTile> deptTiles;

  @override
  void initState() {
    super.initState();
  }

  ListTile produceTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () =>
          widget.currentPage == route ? Get.back() : Get.offAllNamed(route),
      //Get.offNamedUntil(route, ModalRoute.withName(drsnProfileRoute)),
      // should be Get.offNamedUntil(route, ModalRoute.withName(ptProfileRoute))
      // -- if its how i exoect it be behave - no, this is kill route until
      tileColor: widget.currentPage == route
          ? Theme.of(context).primaryColorLight
          : null,
      // trailing: IconButton(
      //   icon: const Icon(Icons.volume_up),
      //   onPressed: () {},
      // ),
    );
  }

  ListTile clinicTile(BuildContext context, ClinicModel cmod) {
    return ListTile(
      title: Text(cmod.name),
      onTap: () {
        if (widget.currentPage == cmod.id) {
          Get.back();
        } else {
          clinicListController.currentCl.value = cmod;
          Get.offAll(ClinicProfile(
            cm: cmod,
          ));
        }
      },
      tileColor: widget.currentPage == cmod.id
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
                title: const Text(
                  'Directory',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: const Icon(
                  Icons.map,
                  color: Colors.black,
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              // produceTile(context, 'BlueTooth', bluetoothRoute),
              produceTile(context, 'Dr/Sn Profile', drsnProfileRoute),
              produceTile(context, 'Create Clinic', createClinicRoute),
              FutureBuilder(
                future: clinicListController.getClinicModels(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ClinicModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ExpansionTile(
                      title: const Text('Clinics',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      children: snapshot.data!
                          .map((d) => clinicTile(context, d))
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              ListTile(
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Logout  ',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      WidgetSpan(
                        child:
                            Icon(Icons.logout, color: Colors.black, size: 18),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  drsnController.signOut();
                  Get.offAll(const Loginc());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
