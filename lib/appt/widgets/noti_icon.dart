import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/firebase/firebase_const.dart';
import '../noti_list_main.dart';

class NotiIcon extends StatelessWidget {
  const NotiIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(NotiListMain()),
          child: StreamBuilder<QuerySnapshot<Object?>>(
          stream: ptNotiRef
              .where('appOwnerId', isEqualTo: auth.currentUser!.uid)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Icon(Icons.notification_important);
              // break;
              case ConnectionState.waiting:
                return const Icon(Icons.notifications_paused);
              // break;
              case ConnectionState.active:
                List<QueryDocumentSnapshot<Object?>> ss = snapshot.data!.docs;
                int unseen = ss.where((obj) => obj.get('seen') == false).length;
                // List<PtNoti> notis =
                //     ss.map((obj) => PtNoti.fromSnapshot(obj)).toList();
                // notis.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return Badge(
                  position: BadgePosition.bottomStart(bottom: 6),
                  badgeContent: Text(unseen.toString()),
                  child: const Icon(Icons.notifications_on),
                );
              case ConnectionState.done:
                return const Icon(Icons.notifications_on);
            }
          }),
    );
  }
}

// StreamBuilder<QuerySnapshot<Object?>>(
//     stream: ptNotiRef
//         .where('appOwnerId', isEqualTo: useHere.id)
//         .snapshots(),
//     builder: (BuildContext context,
//         AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
//       switch (snapshot.connectionState) {
//         case ConnectionState.none:
//           return const Text('No Stream :(');
//         // break;
//         case ConnectionState.waiting:
//           return const Text('Still Waiting...');
//         // break;
//         case ConnectionState.active:
//           List<QueryDocumentSnapshot<Object?>> ss =
//               snapshot.data!.docs;
//           int unseen = ss
//               .where((obj) => obj.get('seen') == false)
//               .length;
//           List<PtNoti> notis = ss
//               .map((obj) => PtNoti.fromSnapshot(obj))
//               .toList();
//           notis.sort((a, b) =>
//               b.createdAt.compareTo(a.createdAt));
//           return Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                   color: Colors.black, width: 1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: ExpansionTile(
//                 collapsedBackgroundColor: Colors.white,
//                 backgroundColor: Colors.white,
//                 title: Text(
//                     'Unread Notifications = $unseen'),
//                 children: [
//                   ConstrainedBox(
//                     constraints: const BoxConstraints(
//                         minHeight: 0, maxHeight: 200),
//                     child: ListView(
//                       shrinkWrap: true,
//                       children: notis
//                           .map((noti) => NotiListTile(
//                                 setColor: false,
//                                 ptNoti: noti,
//                                 key: Key(
//                                     getRandomString(5)),
//                               ))
//                           .toList(),
//                     ),
//                   )
//                 ]),
//           );
//         case ConnectionState.done:
//           return const Text('Done. That\'s all');
//       }
//     }),
