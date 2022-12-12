import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/common/firebase/firebase_const.dart';
import '/common/responsiveness.dart';

class EndDrawerLogin extends StatefulWidget {
  const EndDrawerLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EndDrawerLoginState createState() => _EndDrawerLoginState();
}

class _EndDrawerLoginState extends State<EndDrawerLogin> {
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
                  'lang'.tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                leading: const Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              langTile('en', 'US', 'English'),
              langTile('ms', 'MY', 'Melayu'),
              langTile('zh', 'CN', '华语'),
              langTile('tm', 'IN', 'தமிழ்'),
            ],
          ),
        ),
      ),
    );
  }
}
