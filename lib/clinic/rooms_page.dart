import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/models/room_model.dart';
import 'package:hsa_app/common/firebase/firebase_const.dart';
import '../clinic/helpers/routes.dart';
import '../appt/models/appt_req.dart';

import 'as_room_page.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/schedule_model.dart';
import 'room.dart';
import 'view_ref_received.dart';
import 'widgets/end_drawer.dart';
import 'widgets/lead_drawer.dart';
import 'package:intl/intl.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool enteredRoom = false;
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //     GlobalKey<RefreshIndicatorState>();
  // List<RoomModel> _roomList = [];
  List<String> roomList = [];

  @override
  void initState() {
    roomList = clinicListController.currentCl.value.roomIdList;
    // print('inside rooms_page punya roomList');
    // print(roomList);
    // print('i did mtfk initstate');
    // print(roomList);
    super.initState();
  }

  // Future<List> getAllRooms() async {
  //   List<RoomModel> emptyRooms = [];
  //   QuerySnapshot<Object?> roomObjs = await roomRef
  //       .where('clinicId', isEqualTo: clinicListController.currentCl.value.id)
  //       .get();
  //   for (var roomId in clinicListController.currentCl.value.roomIdList) {
  //     emptyRooms.add(RoomModel.fromSnapshot(
  //         roomObjs.docs.firstWhere((tt) => tt.id == roomId)));
  //   }
  //   setState(() => _roomList = emptyRooms);
  //   return emptyRooms;
  // }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    // print(clinicListController.currentCl.value.id);
    // print(clinicListController.currentCl.value.roomIdList);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Rooms'),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  List<ScheduleModel> scModels =
                      await scheduleListController.getScheduleModels();
                  // Get.to(AsRoomPage(
                  //     clinicListController.currentCl.value, scModels));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AsRoomPage(
                            clinicListController.currentCl.value, scModels)),
                  ).then((res) {
                    setState(() => roomList =
                        clinicListController.currentCl.value.roomIdList);
                  });
                }),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: const LeadingDrawer(roomsRoute),
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
            onWillPop: conWillPop,
            child: StreamBuilder<QuerySnapshot<Object?>>(
                stream: roomList.isNotEmpty
                    ? roomRef
                        .where(FieldPath.documentId, whereIn: roomList)
                        .snapshots()
                    : roomRef.where('name', isEqualTo: '').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  // print('before after');
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
                      List<RoomModel> freak =
                          ss.map((obj) => RoomModel.fromSnapshot(obj)).toList();
                      // print('rl = $roomList');
                      // print('robj = ${freak.map((fr) => fr.id).toList()}');
                      int index = 0;
                      for (var roomId in roomList) {
                        int position =
                            freak.indexWhere((fr) => fr.id == roomId);
                        if (!position.isNegative) {
                          RoomModel rm = freak.removeAt(position);
                          freak.insert(index, rm);
                          index += 1;
                        }
                      }
                      return Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  key: Key(getRandomString(4)),
                                  children: freak
                                      .map((room) => Container(
                                            key: Key(getRandomString(3)),
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: ListTile(
                                              title: Text(room.name),
                                              subtitle: Text(room.scheduleName),
                                              dense: true,
                                              tileColor: Colors.white,
                                              trailing: IconButton(
                                                color: Colors.black,
                                                icon: const Icon(
                                                  Icons.sensor_door_outlined,
                                                  size: 30,
                                                ),
                                                onPressed: enteredRoom
                                                    ? null
                                                    : () async {
                                                        setState(() =>
                                                            enteredRoom = true);
                                                        await attachRoomRef
                                                            .add({
                                                          'staffId':
                                                              userController
                                                                  .user.id,
                                                          'staffName':
                                                              userController
                                                                  .user
                                                                  .getName(),
                                                          'roomId': room.id,
                                                          'roomName': room.name,
                                                          'active': true,
                                                          'createdAt': DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch,
                                                          'updatedAt': DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch,
                                                        });

                                                        List<ScheduleModel>
                                                            scModels =
                                                            await scheduleListController
                                                                .getScheduleModels();
                                                        Get.to(Room(
                                                            room, scModels));
                                                        setState(() =>
                                                            enteredRoom =
                                                                false);
                                                      },
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )));
                    case ConnectionState.done:
                      return const Text('Done. That\'s all');
                  }
                })

            // FutureBuilder(
            //   future: roomList, // _initPtData,
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     if (snapshot.hasError) {
            //       return RefreshIndicator(
            //           key: _refreshIndicatorKey,
            //           onRefresh: () => getAllRooms(),
            //           child: Center(
            //               child: SizedBox(
            //             width: 150,
            //             child: ElevatedButton(
            //               onPressed: () => getAllRooms(),
            //               child: Text(snapshot.error.toString()),
            //             ),
            //           )));
            //     } else if (snapshot.connectionState == ConnectionState.done) {
            //       return Padding(
            //         padding: const EdgeInsets.all(10),
            //         child: RefreshIndicator(
            //           onRefresh: () => getAllRooms(),
            //           child: ListView(
            //             shrinkWrap: true,
            //             physics: const BouncingScrollPhysics(),
            //             children: _roomList
            //                 .map((room) => Container(
            //                       margin: const EdgeInsets.all(2),
            //                       decoration: BoxDecoration(
            //                           border: Border.all(),
            //                           borderRadius: BorderRadius.circular(5)),
            //                       child: ListTile(
            //                         title: Text(room.name),
            //                         subtitle: Text(room.scheduleName),
            //                         dense: true,
            //                         tileColor: Colors.white,
            //                         trailing: IconButton(
            //                           color: Colors.black,
            //                           icon: const Icon(
            //                               Icons.sensor_door_outlined, size: 30,),
            //                           onPressed: enteredRoom
            //                               ? null
            //                               : () async {
            //                                   setState(
            //                                       () => enteredRoom = true);
            //                                   await attachRoomRef.add({
            //                                     'staffId':
            //                                         userController.user.id,
            //                                     'staffName': userController.user
            //                                         .getName(),
            //                                     'roomId': room.id,
            //                                     'roomName': room.name,
            //                                     'active': true,
            //                                     'createdAt': DateTime.now()
            //                                         .millisecondsSinceEpoch,
            //                                     'updatedAt': DateTime.now()
            //                                         .millisecondsSinceEpoch,
            //                                   });
            //                                   // if (room.scheduleId.isNotEmpty) {

            //                                   // DocumentSnapshot<Object?> scSS = await scheduleRef.doc(room.scheduleId).get();

            //                                   // }
            //                                   // ScheduleModel roomSc =
            //                                   List<ScheduleModel> scModels =
            //                                       await scheduleListController
            //                                           .getScheduleModels();
            //                                   Get.to(Room(room, scModels));
            //                                   setState(
            //                                       () => enteredRoom = false);
            //                                 },
            //                         ),
            //                       ),
            //                     ))
            //                 .toList(),
            //           ),
            //         ),
            //       );
            //     } else {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //   },
            // )
            ));
  }
}
