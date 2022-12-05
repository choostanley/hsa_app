import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';
import 'package:hsa_app/clinic/models/member.dart';

import '../common/firebase/firebase_const.dart';
import 'add_member_camera.dart';
import 'add_member_keyboard.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class MembersPage extends StatelessWidget {
  MembersPage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Members'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard, size: 30),
              onPressed: () => Get.to(const AddMemberKeyboard()),
            ),
            if (isApp || isWebMobile)
              IconButton(
                icon: const Icon(Icons.qr_code, size: 30),
                onPressed: () => Get.to(const AddMemberCamera()),
              ),
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 30,
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(notiListRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: onWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: memberRef
                    .where('clinicId',
                        isEqualTo: clinicListController.currentCl.value.id)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Text('No Stream :(');
                    // break;
                    case ConnectionState.waiting:
                      return const Text('Still Waiting...');
                    // break;
                    case ConnectionState.active:
                      List<QueryDocumentSnapshot<Object?>> ss =
                          snapshot.data!.docs;
                      List<Member> members =
                          ss.map((obj) => Member.fromSnapshot(obj)).toList();
                      members
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  children: members
                                      .map((memb) => ListTile(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            title: Text(memb.drSnName),
                                            tileColor: Colors.white,
                                            key: Key(getRandomString(5)),
                                            leading: CircleAvatar(
                                              child: ClipOval(
                                                child: kIsWeb
                                                    ? Image.network(
                                                        'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg',
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      )
                                                    : CachedNetworkImage(
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            'https://www.drugs.com/health-guide/images/ddca3f92-4b8e-4672-bb6b-f3594ad4e304.jpg'),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )));
                    case ConnectionState.done:
                      return const Text('Done. That\'s all');
                  }
                })));
  }
}
