import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hsa_app/clinic/models/user.dart';

import '../common/firebase/firebase_const.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/clinic_model.dart';
import 'models/queue_model.dart';
import 'models/room_model.dart';
import 'models/schedule_model.dart';
import 'widgets/end_drawer.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Room extends StatefulWidget {
  const Room(this.room, this.scModels, {super.key});
  final RoomModel room;
  final List<ScheduleModel> scModels;

  @override
  // ignore: library_private_types_in_public_api
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late RoomModel localRoom;
  late List<ScheduleModel> localScList;
  late String generalScId;
  late Future<List<UserModel>> drs;
  final yourScrollController = ScrollController();

  @override
  void initState() {
    localRoom = widget.room;
    localScList = widget.scModels;
    generalScId = localRoom.scheduleId; // should be default empty string
    drs = getRoomDr();
    super.initState();
  }

  Future<List<UserModel>> getRoomDr() async {
    QuerySnapshot<Object?> roomAttObjs = await attachRoomRef
        .where('roomId', isEqualTo: localRoom.id)
        .where('active', isEqualTo: true)
        .get();
    List<String> drsId = roomAttObjs.docs
        .map((snapshot) => snapshot.get('staffId').toString())
        .toList();
    QuerySnapshot<Object?> drObjs =
        await drsnReqRef.where(FieldPath.documentId, whereIn: drsId).get();
    return drObjs.docs.map((drObjs) => UserModel.fromSnapshot(drObjs)).toList();
  }

  Future<bool> exitRoomPop(BuildContext context) async {
    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to leave this ROOM ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              QuerySnapshot<Object?> bbbs = await attachRoomRef
                  .where('roomId', isEqualTo: localRoom.id)
                  .where('staffId', isEqualTo: userController.user.id)
                  .where('active', isEqualTo: true)
                  .get();
              if (bbbs.docs.isNotEmpty) {
                for (var roomref in bbbs.docs) {
                  attachRoomRef.doc(roomref.id).update({'active': false});
                }
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(localRoom.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        body: WillPopScope(
            onWillPop: () => exitRoomPop(context),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder(
                        future: drs,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<UserModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<UserModel> drList = snapshot.data!;
                            return ExpansionTile(
                                title: Text('Drs in room = ${drList.length}'),
                                children: drList
                                    .map((um) => ListTile(title: Text(um.name)))
                                    .toList());
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 50,
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 10,
                          controller: yourScrollController,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ListView.builder(
                                controller: yourScrollController,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: localScList.length,
                                itemBuilder: (context, index) {
                                  ScheduleModel nowie = localScList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 2),
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5)),
                                    width: 150,
                                    child: RadioListTile<String>(
                                      selected: generalScId == nowie.id,
                                      title: Text(nowie.name,
                                          overflow: TextOverflow.ellipsis),
                                      value: nowie.id,
                                      groupValue: generalScId,
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                          horizontal: -3, vertical: -3),
                                      onChanged: (String? value) async {
                                        // generalScId = value!;
                                        // calender = await createCalender(generalScId);
                                        setState(() {
                                          generalScId = value!;
                                          // chosedSm = value;
                                        });
                                      },
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text('Patients: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot<Object?>>(
                            stream: queueRef
                                .where('scheduleId', isEqualTo: generalScId)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot<Object?>>
                                    snapshot) {
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
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: ss.length,
                                      itemBuilder: (context, index) {
                                        QueueModel qq =
                                            QueueModel.fromSnapshot(ss[index]);
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(right: 2),
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          width: 150,
                                          child: ListTile(
                                            title: Text(qq.ptName,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            subtitle: Text(qq.approveRemarks),
                                            dense: true,
                                            leading: IconButton(
                                              icon: const Icon(Icons.call,
                                                  size: 30),
                                              color: Colors.green,
                                              onPressed: qq.called
                                                  ? null
                                                  : () async {
                                                      DocumentSnapshot<Object?>
                                                          pt = await ptRef
                                                              .doc(qq.ptId)
                                                              .get();
                                                      String ownerId =
                                                          pt.get('ownerId');
                                                      DocumentSnapshot<Object?>
                                                          owner =
                                                          await appOwnerRef
                                                              .doc(ownerId)
                                                              .get();
                                                      String mToken =
                                                          owner.get('mToken');
                                                      ClinicModel
                                                          currentClinic =
                                                          clinicListController
                                                              .currentCl.value;
                                                      await ptNotiRef.add({
                                                        'ptId': qq.ptId,
                                                        'appOwnerId': ownerId,
                                                        'seen': false,
                                                        'clinicId':
                                                            currentClinic.id,
                                                        'title':
                                                            currentClinic.name,
                                                        'body':
                                                            '${qq.ptName} please go to ${localRoom.name}.',
                                                        'createdAt': DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch,
                                                        'updatedAt': DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch,
                                                      });
                                                      queueRef
                                                          .doc(qq.id)
                                                          .update({
                                                        'called': true,
                                                        'calledById':
                                                            userController
                                                                .user.id,
                                                        'updatedAt': DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch,
                                                      });
                                                      sendPushMessageToPt(
                                                          mToken,
                                                          currentClinic.name,
                                                          '${qq.ptName} please go to ${localRoom.name}.');
                                                      // qq.called = true; - no need ba, hopefully
                                                    },
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.note_alt,
                                                  size: 35,
                                                  color: Colors.blueAccent),
                                              onPressed: () {
                                                queueRef.doc(qq.id).update({
                                                  'entered': true,
                                                  'updatedAt': DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                // break;
                                case ConnectionState.done:
                                  return const Text('Done. That\'s all');
                                // break;
                              }
                            }),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
