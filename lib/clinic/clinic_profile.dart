import 'package:flutter/material.dart';
import 'package:hsa_app/clinic/helpers/routes.dart';

import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/clinic_model.dart';
import 'widgets/lead_drawer.dart';
import 'widgets/end_drawer.dart';

class ClinicProfile extends StatefulWidget {
  const ClinicProfile({super.key, required this.cm});
  final ClinicModel cm;

  @override
  // ignore: library_private_types_in_public_api
  _ClinicProfileState createState() => _ClinicProfileState();
}

class _ClinicProfileState extends State<ClinicProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ClinicModel localCm;

  @override
  void initState() {
    localCm = widget.cm;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    print(clinicListController.currentCl.value.id);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Clinic Profile'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 30,
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(clinicProfileRoute),
        endDrawer: EndDrawer(localCm.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Text("Clinic Name: ${localCm.name}",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Short Name: ${localCm.shortName}",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            )));
  }
}
