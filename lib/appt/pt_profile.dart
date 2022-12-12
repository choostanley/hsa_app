import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';
import 'package:hsa_app/appt/widgets/appt_card_style.dart';
import 'package:hsa_app/appt/widgets/end_drawer.dart';

import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/pt.dart';
import 'widgets/appt_list_style.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/lead_drawer.dart';

class PtProfile extends StatefulWidget {
  const PtProfile({super.key, required this.ptModel});
  final PtModel ptModel;

  @override
  // ignore: library_private_types_in_public_api
  _PtProfileState createState() => _PtProfileState();
}

class _PtProfileState extends State<PtProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PtModel pModel;
  late String gender;
  // late User user;
  // late UserModel userModel;
  // late Future<DocumentSnapshot> getUser;
  // var combining = RegExp(r"[^\\x00-\\x7F]/g");

  @override
  void initState() {
    pModel = widget.ptModel;
    print(pModel.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ptController.ctx = context;
    return WillPopScope(
        onWillPop: onWillPop,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('profile'.tr),
              // leading: IconButton(
              //   icon: const Icon(Icons.menu),
              //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              // ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    size: 30,
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                )
              ],
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.event_note)),
                Tab(icon: Icon(Icons.list))
              ]),
            ),
            // drawer: const LeadingDrawer(ptProfileRoute),
            endDrawer: EndDrawer(pModel.id),
            backgroundColor: Theme.of(context).primaryColor,
            body: TabBarView(
              children: [
                ApptCardStyle(pModel: pModel),
                ApptListStyle(pModel: pModel)
              ],
            ),
            bottomNavigationBar: const BottomNav(curIndex: 0),
          ),
        ));
  }
}
