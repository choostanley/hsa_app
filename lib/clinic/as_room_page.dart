import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/widgets/ref_letter_picker.dart';
import 'package:hsa_app/clinic/controllers/controllers.dart';

import '../common/firebase/firebase_const.dart';
import 'models/clinic_model.dart';
import 'models/room_model.dart';
import 'models/schedule_model.dart';

// ** need to check if room has dr before let delete
class AsRoomPage extends StatefulWidget {
  final ClinicModel cm;
  final List<ScheduleModel> scModels;

  const AsRoomPage(this.cm, this.scModels, {super.key});
  @override

  // ignore: library_private_types_in_public_api
  _AsRoomPageState createState() => _AsRoomPageState();
}

class _AsRoomPageState extends State<AsRoomPage> {
  final _formKey = GlobalKey<FormState>();
  late String uid;
  late String errorMessage;
  late ClinicModel clinic;
  late List<RoomModel> rms;

  List<String> roomIds = [];
  List<String> roomNames = [];
  List<String> scheduleIds = [];
  List<String> scheduleNames = [];

  int counter = 0;
  bool initialised = false;
  List<String> errorList = [];

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    clinic = widget.cm;
    super.initState();
  }

  Future<List> iniBedList() async {
    // rms = await clinic.getRooms();
    if (!initialised) {
      rms = await clinic.getRooms();
      for (var rm in rms) {
        roomIds.add(rm.id);
        roomNames.add(rm.name);
        scheduleIds.add(rm.scheduleId);
        scheduleNames.add(rm.scheduleName);
      }
      initialised = true;
    }
    return roomIds;
  }

  void updateClinicRoom() {
    _onLoading();
    if (roomIds.isNotEmpty) {
      createRoom(0);
    } else {
      _onLoadingDone();
    }
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("Loading"),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onLoadingDone() {
    Navigator.pop(context);
    Text message = const Text('All beds have been updated');
    roomIds.removeWhere((value) => value == '');
    print(roomIds);
    clinicRef.doc(clinic.id).update({
      'roomIdList': roomIds
    }); // i think must limit only ward owner can change beds
    ClinicModel thisMTFK = clinicListController.currentCl.value;
    thisMTFK.roomIdList = roomIds;
    clinicListController.currentCl.value = thisMTFK;
    if (errorList.isNotEmpty) {
      message = Text('Error occured when updating bed ${errorList.join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: message,
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } else {
      // Navigator.pop(context);
      Get.back();
    }
  }

  void createRoom(int index) async {
    String rId = roomIds[index];
    // print(rId);
    try {
      if (rId.isEmpty) {
        await roomRef.add({
          'name': roomNames[index],
          'clinicId': clinic.id,
          'scheduleId': scheduleIds[index],
          'scheduleName': scheduleNames[index],
          'lastUpdatedBy': uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }).then((DocumentReference<Object?> v) {
          roomIds[index] = v.id;
          if (index == roomIds.length - 1) {
            _onLoadingDone();
          } else {
            createRoom(++index);
          }
        });
      } else {
        await roomRef.doc(roomIds[index]).update({
          'name': roomNames[index],
          'scheduleId': scheduleIds[index],
          'scheduleName': scheduleNames[index],
          'lastUpdatedBy': uid,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }).then((v) {
          if (index == roomIds.length - 1) {
            _onLoadingDone();
          } else {
            createRoom(++index);
          }
        });
      }
    } catch (error) {
      errorList.add(roomNames[index]);
      if (index == roomIds.length - 1) {
        _onLoadingDone();
      } else {
        createRoom(++index);
      }
    }
  }

  void edit(int index) async {
    Map edited = await Get.defaultDialog(
      contentPadding: const EdgeInsets.all(15.0),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                validator: (val) {
                  if (val!.trim().isEmpty) {
                    return 'Room name is required!';
                  }
                  return null;
                },
                initialValue: roomNames[index],
                onSaved: (name) {
                  setState(() => roomNames[index] = name!.trim());
                },
              ),
              DropdownButtonFormField<ScheduleModel>(
                decoration: InputDecoration(
                  hoverColor: Theme.of(context).primaryColor,
                  labelText: 'Schedule',
                ),
                onChanged: (ScheduleModel? newValue) {
                  setState(() {
                    scheduleIds[index] = newValue!.id;
                    scheduleNames[index] = newValue.name;
                  });
                },
                // validator: (ScheduleModel? cm) {
                //   if (cm == ScheduleModel()) {
                //     return 'Schedule is required!';
                //   }
                //   return null;
                // },
                items: widget.scModels.map((ScheduleModel value) {
                  return DropdownMenuItem<ScheduleModel>(
                      value: value,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Text(value.name),
                      ));
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      child: const Text('Save'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Get.back(result: {
                            'rName': roomNames[index],
                            'sId': scheduleIds[index],
                            'sName': scheduleNames[index],
                          });
                        }
                      })
                ],
              )
            ],
          ),
        );
      }),
    );
    setState(() {
      roomNames[index] = edited['rName'];
      scheduleIds[index] = edited['sId'];
      scheduleNames[index] = edited['sName'];
      // bedNames[index] = edited['name'];
      // o2[index] = edited['o2'];
    });
  }

  void deleteBed(int i) async {
    String removeId = '';
    setState(() {
      removeId = roomIds.removeAt(i);
      roomNames.removeAt(i);
      scheduleIds.removeAt(i);
      scheduleNames.removeAt(i);
    });
    print(removeId);
    if (removeId.isNotEmpty) await roomRef.doc(removeId).delete();
    // print(clinicListController.currentCl.value.id);
  }

  void addBed() {
    counter++;
    setState(() {
      roomIds.add('');
      roomNames.add('New Room $counter');
      // these 2 maybe hv problem on selectionList, try out first?
      scheduleIds.add('');
      scheduleNames.add('');
    });
  }

  Widget buildRoom(int index, RoomModel bed) {
    return Card(
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        key: ValueKey(index),
        child: ListTile(
          tileColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              roomNames[index],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(scheduleNames[index]),
          leading: IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              edit(index);
            },
          ),
        ));
  }

  Widget buildNewRoom(int index) {
    return Card(
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      key: ValueKey(index),
      child: ListTile(
        tileColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            roomNames[index],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(scheduleNames[index]),
        leading: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () => edit(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: iniBedList(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Rooms in Clinic (${clinic.name})',
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // foreground
                    ),
                    onPressed: () => updateClinicRoom(),
                    child: const Text('Update'),
                  ),
                )
              ],
            ),
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    // key: Key(getRandomString(3)),
                    // shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                // fixedSize: const Size(50, 20)
                              ),
                              onPressed: () {
                                if (roomIds.isNotEmpty) deleteBed(0);
                              },
                              child: const Text('Remove\nFirst'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  fixedSize: const Size(50, 20)),
                              onPressed: () => addBed(),
                              child: const Icon(Icons.add),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                // fixedSize: const Size(50, 20)
                              ),
                              onPressed: () {
                                if (roomIds.isNotEmpty) {
                                  deleteBed(roomIds.length - 1);
                                }
                              },
                              child: const Text('Remove\nLast'),
                            ),
                          ]),
                      const SizedBox(
                        height: 15,
                      ),
                      ReorderableListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: roomIds.length,
                        itemBuilder: (context, index) {
                          Widget bedTile = roomIds[index].isEmpty
                              ? buildNewRoom(index)
                              : buildRoom(
                                  index,
                                  rms.firstWhere(
                                      (bm) => bm.id == roomIds[index]));
                          return bedTile;
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            var index =
                                newIndex > oldIndex ? newIndex - 1 : newIndex;
                            String bId = roomIds.removeAt(oldIndex);
                            roomIds.insert(index, bId);
                            String bName = roomNames.removeAt(oldIndex);
                            roomNames.insert(index, bName);
                            String oBool = scheduleIds.removeAt(oldIndex);
                            scheduleIds.insert(index, oBool);
                            String bBool = scheduleNames.removeAt(oldIndex);
                            scheduleNames.insert(index, bBool);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
