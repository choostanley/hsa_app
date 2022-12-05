import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/appt/helpers/routes.dart';
import '/appt/pt_profile.dart';

import '../controllers/controllers.dart';
import '../models/pt.dart';
import '/common/firebase/firebase_const.dart';
import '/common/responsiveness.dart';
import '../login.dart';

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

  ListTile produceTile(
      BuildContext context, String title, String route, bool off) {
    return ListTile(
      title: Text(title),
      onTap: () => widget.currentPage == route
          ? Get.back()
          : off
              ? Get.offNamed(route)
              : Get.toNamed(route),
      tileColor: widget.currentPage == route
          ? Theme.of(context).primaryColorLight
          : null,
      // trailing: IconButton(
      //   icon: const Icon(Icons.volume_up),
      //   onPressed: () {},
      // ),
    );
  }

  ListTile langTile(String langCode, String countryCode, String displayLang) {
    return ListTile(
      title: Text(displayLang),
      onTap: () {
        if (box.read('langCode') == langCode) {
          Get.back();
        } else {
          var locale = Locale(langCode, countryCode);
          Get.updateLocale(locale);
          box.write('langCode', langCode);
          box.write('countryCode', countryCode);
          Get.back();
        }
      },
      tileColor: Get.locale!.languageCode == langCode
          ? Theme.of(context).primaryColorLight
          : null,
    );
  }

  ListTile ptTile(BuildContext context, PtModel pmod) {
    return ListTile(
      title: Text(pmod.name),
      subtitle: Text(pmod.ic),
      onTap: () {
        if (widget.currentPage == pmod.id) {
          Get.back();
        } else {
          ptListController.currentPt.value = pmod;
          apptController.clearApptnApptReq();
          Get.off(
              PtProfile(
                ptModel: pmod,
              ),
              preventDuplicates: false);
        }
      },
      tileColor: widget.currentPage == pmod.id
          ? Theme.of(context).primaryColorLight
          : null,
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
                  'directory'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: const Icon(
                  Icons.map,
                  color: Colors.black,
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              produceTile(context, 'app owner'.tr, appOwnerRoute, true),
              ExpansionTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'lang'.tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      const WidgetSpan(
                        child:
                            Icon(Icons.language, color: Colors.black, size: 18),
                      ),
                    ],
                  ),
                ),
                children: [
                  langTile('en', 'US', 'English'),
                  langTile('ms', 'MY', 'Melayu'),
                  langTile('zh', 'CN', '华语')
                ],
              ),
              produceTile(context, 'mpp'.tr, createPtRoute, true), // from false
              FutureBuilder(
                future: ptListController.getPtModels(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<PtModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ExpansionTile(
                      title: Text('pt list'.tr), //pt list in diff lang
                      children: snapshot.data!
                          .map((d) => ptTile(context, d))
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'logout'.tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      const WidgetSpan(
                        child:
                            Icon(Icons.logout, color: Colors.black, size: 18),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  ptController.signOut();
                  Get.offAll(const Login());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
