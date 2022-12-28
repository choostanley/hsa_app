import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/widgets/show_images.dart';
import 'models/ar_dir.dart';
import 'models/clinic_model.dart';
import 'models/schedule_model.dart';
import 'widgets/make_appt_bundle.dart';
import '../common/firebase/firebase_const.dart';
import '../appt/models/pt.dart';
import '../appt/models/appt_req.dart';

import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import '../common/functions.dart';
import 'controllers/controllers.dart';
import 'widgets/end_drawer.dart';

class ViewUnscreenedRef extends StatefulWidget {
  const ViewUnscreenedRef({super.key, required this.ar});
  final ApptReq ar;

  @override
  // ignore: library_private_types_in_public_api
  _ViewUnscreenedRefState createState() => _ViewUnscreenedRefState();
}

class _ViewUnscreenedRefState extends State<ViewUnscreenedRef> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late ApptReq apptReq;
  late PtModel localPt;

  final Map<String, int> durUnit = {
    'Day': 1,
    'Week': 7,
    'Month': 30,
  };
  final Map<int, String> durUnitString = {
    1: 'Day',
    7: 'Week',
    30: 'Month',
  };
  int startUnit = 1;
  int endUnit = 1;
  int startProduct = 0;
  int endProduct = 0;
  final TextEditingController start =
      TextEditingController(); // if end range is 0, allow +/- 4 - 5 days
  final TextEditingController end = TextEditingController();
  bool durLoading = false;
  bool redLoading = false;
  final TextEditingController redirect = TextEditingController();
  ScheduleModel generalSc = ScheduleModel();
  late Future<List<ScheduleModel>> durScheList;

  Future<void> _initPt() async {
    PtModel pt = await ptRef.doc(apptReq.ptId).get().then((onValue) {
      return PtModel.fromSnapshot(onValue);
    });
    localPt = pt;
  }

  Future<void> _tryInitPt() async {
    PtModel pt = await ptRef
        .doc(apptReq.ptId)
        .get()
        .then((onValue) => PtModel.fromSnapshot(onValue));
    setState(() => localPt = pt);
  }

  Future<List<ClinicModel>> getAllClinic() async {
    List<ClinicModel> clinics = [];
    await clinicRef.get().then((onValue) {
      for (var clin in onValue.docs) {
        clinics.add(ClinicModel.fromSnapshot(clin));
      }
    });
    return clinics;
  }

  Future<List<ArDir>> getAllArDir() async {
    List<ArDir> arDirs = [];
    await arDirRef.where('arId', isEqualTo: apptReq.id).get().then((onValue) {
      for (var ad in onValue.docs) {
        arDirs.add(ArDir.fromSnapshot(ad));
      }
    });
    return arDirs;
  }

  late Future<List<ClinicModel>> allClinics;
  late Future<List<ArDir>> allArDir;
  ClinicModel cm = ClinicModel();
  late List<String> durList;
  final yourScrollController = ScrollController();
  late Text urgency;

  Future<void> redirection() async {
    if (cm == ClinicModel()) {
      redSnackBar('Error', 'Clinic is required!');
      return;
    } else if (redirect.text.trim().isEmpty) {
      redSnackBar('Error', 'Message is required!');
      return;
    }
    setState(() => redLoading = true);
    QuerySnapshot<Object?> arDir = await arDirRef
        .where('arId', isEqualTo: apptReq.id)
        .where('active', isEqualTo: true)
        .where('accepted', isEqualTo: false)
        .get();
    int nownow = DateTime.now().millisecondsSinceEpoch;
    if (arDir.docs.isNotEmpty) {
      String arDirId = arDir.docs.first.id;
      await arDirRef.doc(arDirId).update({
        'active': false,
        'redirectedById': userController.user.id,
        'redirectedByName': userController.user.name,
        'redirectedToClinicId': cm.id,
        'redirectedToClinicName': cm.shortName,
        'updatedAt': nownow,
      });
    }
    await apptReqRef
        .doc(apptReq.id)
        .update({'toClinicId': cm.id, 'toClinicName': cm.shortName});
    await arDirRef.add({
      'arId': apptReq.id,
      'toClinicId': cm.id,
      'toClinicName': cm.shortName,
      'message': redirect.text.trim(),
      'active': true,
      'accepted': false,
      'apptId': '',
      'directedById': userController.user.id,
      'directedByName': userController.user.name,
      'redirectedById': '',
      'redirectedByName': '',
      'redirectedToClinicId': '',
      'redirectedToClinicName': '',
      'createdAt': nownow,
      'updatedAt': nownow,
    });
    setState(() => redLoading = false);
    if (mounted) Get.back();
  }

  Future<void> setDuration() async {
    if (generalSc == ScheduleModel()) {
      redSnackBar('Error', 'Please set schedule');
      return;
    }
    if (endProduct <= startProduct) {
      redSnackBar('Error', 'Till day must be more than From day');
      return;
    }
    setState(() => durLoading = true);
    await apptReqRef.doc(apptReq.id).update({
      'screenedById': userController.user.id,
      'screenedByName': userController.user.name,
      'screenedScheId': generalSc.id,
      'screenedScheName': generalSc.name,
      'screenedDurStart': '${start.text} ${durUnitString[startUnit]}',
      'screenedDurStartInt': startProduct,
      'screenedDurEnd': '${end.text} ${durUnitString[endUnit]}',
      'screenedDurEndInt': endProduct,
      'screenedAt': DateTime.now().millisecondsSinceEpoch,
    });
    setState(() => durLoading = false);
    if (mounted) Get.back();
  }

  Tooltip ardTile(ArDir ard, int no) {
    // add margin
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 7),
      message: ard.message,
      child: Container(
        // padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.only(right: 3, top: 1.5, bottom: 2),
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(5)),
        width: 160,
        child: ListTile(
          dense: true,
          isThreeLine: false,
          contentPadding: const EdgeInsets.only(left: 10),
          minVerticalPadding: 8, // because bottom space dunno why can't remove
          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
          title: Text(
            '${no.toString()}. ${ard.toClinicName}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    15.0), // this mtfk removed the listTile top padding wtf
            // style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ard.message, overflow: TextOverflow.ellipsis),
                Text(DateFormat('dd-MM-yyyy kk:mm').format(ard.createdAt)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    apptReq = widget.ar;
    switch (apptReq.urgency) {
      case 0:
        urgency = const Text('');
        break;
      case 1:
        urgency = const Text('Not Urgent',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
        break;
      case 2:
        urgency = const Text('Semi-E',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.orange));
        break;
      case 3:
        urgency = const Text('Emergency',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
        break;
      default:
        urgency = const Text('');
    }
    durScheList = scheduleListController
                                      .getScheduleModels();
    durList = durUnit.keys.toList();
    allClinics = getAllClinic();
    allArDir = getAllArDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('View New Referral'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        backgroundColor: Colors.white,
        endDrawer: EndDrawer(clinicListController.currentCl.value.id),
        body: FutureBuilder(
          future: _initPt(), // _initPtData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _tryInitPt,
                  child: Center(
                      child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _tryInitPt,
                      child: Text(snapshot.error.toString()),
                    ),
                  )));
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      // shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      // mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Name: ${localPt.name}"),
                        Text("Ic: ${localPt.ic}"),
                        Text("Gender: ${localPt.genderWord}"),
                        Text('Address: ${localPt.address}'),
                        Text('Ref. note: ${apptReq.remarks}'),
                        urgency,
                        const SizedBox(height: 5),
                        ShowImages(apptReq.refLetterUrl),
                        const SizedBox(height: 5),
                        // add schedule & duration & reject / redirect button --> need pt address? yes
                        ExpansionTile(
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            childrenPadding:
                                const EdgeInsets.only(left: 12, right: 12),
                            initiallyExpanded: true,
                            title: const Text('Set duration'),
                            children: [
                              FutureBuilder<List<ScheduleModel>>(
                                  future: durScheList,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<ScheduleModel>>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      List<ScheduleModel> localScList =
                                          snapshot.data!;
                                      return SizedBox(
                                        height: 50,
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          thickness: 10,
                                          controller: yourScrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: ListView.builder(
                                                controller:
                                                    yourScrollController,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: localScList.length,
                                                itemBuilder: (context, index) {
                                                  ScheduleModel nowie =
                                                      localScList[index];
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 2),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    width: 150,
                                                    child: RadioListTile<
                                                        ScheduleModel>(
                                                      selected:
                                                          generalSc == nowie,
                                                      title: Text(nowie.name,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      value: nowie,
                                                      groupValue: generalSc,
                                                      dense: true,
                                                      visualDensity:
                                                          const VisualDensity(
                                                              horizontal: -3,
                                                              vertical: -3),
                                                      onChanged: (ScheduleModel?
                                                          value) async {
                                                        setState(() {
                                                          generalSc = value!;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  }),
                              const Text(
                                  '* If no Till-day is given, a default buffer of +/- 4 days is given'),
                              Row(
                                children: [
                                  TextFormField(
                                    controller: start,
                                    keyboardType: TextInputType.number,
                                    key: const ValueKey('start'),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    // validator: (val) {
                                    //   if (val!.trim().isEmpty) {
                                    //     return 'A number is required!';
                                    //   } else if (int.parse(val) < 1) {
                                    //     return 'Value must not be less than 1';
                                    //   }
                                    //   return null;
                                    // },
                                    onChanged: (val) {
                                      // print(start
                                      //     .text); // do i need ti update this? - no need
                                      if (val.isNotEmpty) {
                                        startProduct =
                                            int.parse(val) * startUnit;
                                      } else {
                                        startProduct = 0;
                                      }
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'From',
                                        hintText: 'Numbers only',
                                        constraints:
                                            BoxConstraints(maxWidth: 120)),
                                  ),
                                  const SizedBox(width: 15),
                                  DropdownButtonFormField<int>(
                                    key: const ValueKey('startUnit'),
                                    decoration: const InputDecoration(
                                        constraints:
                                            BoxConstraints(maxWidth: 100)),
                                    value: startUnit,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        startUnit = newValue!;
                                      });
                                      startProduct =
                                          int.parse(start.text) * startUnit;
                                    },
                                    items: durList.map((String value) {
                                      return DropdownMenuItem<int>(
                                        value: durUnit[value],
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  TextFormField(
                                    controller: end,
                                    keyboardType: TextInputType.number,
                                    key: const ValueKey('end'),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    // validator: (val) {
                                    //   if (val!.trim().isEmpty) {
                                    //     return 'A number is required!';
                                    //   } else if (int.parse(val) < 1) {
                                    //     return 'Value must not be less than 1';
                                    //   }
                                    //   return null;
                                    // },
                                    onChanged: (val) {
                                      if (val.isNotEmpty) {
                                        endProduct = int.parse(val) * endUnit;
                                      } else {
                                        endProduct = 0;
                                      }
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Till',
                                        hintText: 'Numbers only',
                                        constraints:
                                            BoxConstraints(maxWidth: 120)),
                                  ),
                                  const SizedBox(width: 15),
                                  DropdownButtonFormField<int>(
                                    key: const ValueKey('endUnit'),
                                    decoration: const InputDecoration(
                                        constraints:
                                            BoxConstraints(maxWidth: 100)),
                                    value: endUnit,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        endUnit = newValue!;
                                      });
                                      endProduct =
                                          int.parse(end.text) * endUnit;
                                    },
                                    items: durList.map((String value) {
                                      return DropdownMenuItem<int>(
                                        value: durUnit[value],
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              durLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => setDuration(),
                                      child: const Text('Set Duration'),
                                    ),
                              const SizedBox(height: 5),
                            ]),
                        const SizedBox(height: 5),
                        ExpansionTile(
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            childrenPadding:
                                const EdgeInsets.only(left: 12, right: 12),
                            title: const Text('Redirect referral to: '),
                            children: [
                              SizedBox(
                                height: 80,
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Text('Journey:  '),
                                      Expanded(
                                        child: FutureBuilder<List<ArDir>>(
                                            future: allArDir,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<ArDir>>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                List<ArDir> adList =
                                                    snapshot.data!;
                                                adList.sort((a, b) => b
                                                    .createdAt
                                                    .compareTo(a.createdAt));
                                                return Scrollbar(
                                                  thumbVisibility: true,
                                                  thickness: 10,
                                                  controller:
                                                      yourScrollController,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10.0),
                                                    child: ListView.builder(
                                                      controller:
                                                          yourScrollController,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: adList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ardTile(
                                                            adList[index],
                                                            adList.length -
                                                                (index));
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            }),
                                      )
                                    ]),
                              ),
                              FutureBuilder<List<ClinicModel>>(
                                future: allClinics, //getAllClinic(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<ClinicModel>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return DropdownButtonFormField<ClinicModel>(
                                      decoration: InputDecoration(
                                          hoverColor:
                                              Theme.of(context).primaryColor,
                                          labelText: 'Clinic',
                                          constraints: const BoxConstraints(
                                              maxWidth: 250)),
                                      onChanged: (ClinicModel? newValue) {
                                        cm = newValue!;
                                      },
                                      // validator: (ClinicModel? cm) {
                                      //   if (cm == ClinicModel()) {
                                      //     return 'Clinic is required!';
                                      //   }
                                      //   return null;
                                      // },
                                      items: snapshot.data!
                                          .map((ClinicModel value) {
                                        return DropdownMenuItem<ClinicModel>(
                                            value: value,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.7),
                                              child: Text(value.name),
                                            ));
                                      }).toList(),
                                    );
                                  } else {
                                    return const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                              TextFormField(
                                controller: redirect,
                                keyboardType: TextInputType.text,
                                key: const ValueKey('redirect'),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return 'A message is required!';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    labelText: 'Message',
                                    constraints: BoxConstraints(maxWidth: 250)),
                              ),
                              const SizedBox(height: 5),
                              redLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => redirection(),
                                      child: const Text('Redirect')),
                              const SizedBox(height: 5),
                            ]),

                        FutureBuilder<List<ScheduleModel>>(
                            future: scheduleListController.getScheduleModels(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ScheduleModel>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return MakeApptBundle(
                                    ar: apptReq,
                                    smList: snapshot.data!,
                                    open: false);
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                        // add message component
                        // - belongs to apptReq (pt side & fromClinic) & apptReqDirect (toClinic)?
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
