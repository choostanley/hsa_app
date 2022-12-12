import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/routes.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.curIndex});
  final int curIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (index) {
        switch (index) {
          case 0:
            if (curIndex != 0) Get.offAllNamed(ptProfileRoute);
            break;
          case 1:
            if (curIndex != 1) Get.offAllNamed(apptListRoute);
            break;
          case 2:
            if (curIndex != 2) Get.offAllNamed(reqApptRoute);
            break;
          case 3:
            if (curIndex != 3) Get.offAllNamed(notiListRoute);
            break;
          default:
            break;
        }
      },
      elevation: 16.0,
      currentIndex: curIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.cyan,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Appointment'),
        BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add), label: 'Request'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notification'),
      ],
    );
  }
}
