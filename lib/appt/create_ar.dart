import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/models/clinic_model.dart';
import 'widgets/end_drawer.dart';
import 'widgets/ref_letter_picker.dart';
import 'widgets/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_calendar/table_calendar.dart';

import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'widgets/multi_calendar.dart';

class CreateAr extends StatefulWidget {
  const CreateAr({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateArState createState() => _CreateArState();
}

class _CreateArState extends State<CreateAr> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<XFile> imageFiles = [];

  late firebase_storage.Reference storageRef;
  // final List<String> _dropdownTitles = [
  //   'SFUC - HSA',
  //   'MOPC - HSA',
  //   'MOC - HSA',
  //   ''
  // ];
  late String clinic;
  // Using a `LinkedHashSet` is recommended due to equality comparison override
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  ClinicModel cm = ClinicModel();
  final Map<String, int> urgency = {
    'Emergency': 3,
    'Semi-E': 2,
    'Not Urgent': 1,
  };
  late int generalUrg = 0;
  late List<String> urgList;

  final yourScrollController = ScrollController();

  @override
  void initState() {
    allClinics = getAllClinic();
    urgList = urgency.keys.toList();
    super.initState();
  }

  void _pickedImage(List<XFile> images) {
    imageFiles = images;
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!
        .validate(); // like not working, tmr check firebase if created empty apptReq
    if (imageFiles.isEmpty) {
      // no need?
      redSnackBar(
          'Referral Letter required!', 'Please provide a referral letter.');
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        storageRef = storage.ref().child('ref_letters');
        List<String> downloadURLs = [];
        for (var imageFile in imageFiles) {
          firebase_storage.Reference newRef =
              storageRef.child(path.basename('${imageFile.path}.jpg'));
          Uint8List bytes = await imageFile.readAsBytes();
          await newRef.putData(bytes);
          String url = await newRef.getDownloadURL();
          downloadURLs.add(url);
        }

        int skrg = DateTime.now().millisecondsSinceEpoch;
        apptReqRef.add({
          'ptId': ptListController.currentPt.value.id,
          'ptIc': ptListController.currentPt.value.ic,
          'ptName': ptListController.currentPt.value.name,
          'toClinicId': cm.id, // apptController.clinic.text,
          'toClinicName': cm.name,
          'fromClinicId': '',
          'reqById': '',
          // 'attById': '',
          'urgency': generalUrg,
          'screenedById': '',
          'screenedByName': '',
          'screenedScheId': '',
          'screenedScheName': '',
          'screenedDurStart': '',
          'screenedDurStartInt': 0,
          'screenedDurEnd': '',
          'screenedDurEndInt': 0,
          'givenApptById': '',
          'givenApptByName': '',

          'prefApptTime':
              _selectedDays.map((dt) => dt.millisecondsSinceEpoch).toList(),
          'remarks': apptController.notes.text,
          'refLetterUrl': downloadURLs, //url,
          'createdAt': skrg,
          'updatedAt': skrg,
          'screenedAt': 0,
          'apptGivenAt': 0,
        }).then((r) {
          // this is by pt
          arDirRef.add({
            'arId': r.id,
            'toClinicId': cm.id,
            'toClinicName': cm.name,
            'active': true,
            'accepted': false,
            'apptId': '',
            'message': apptController.notes.text,
            'directedById': '',
            'directedByName': '',
            'redirectedById': '',
            'redirectedByName': '',
            'redirectedToClinicId': '',
            'redirectedToClinicName': '',
            'createdAt': skrg,
            'updatedAt': skrg,
          });
        }).then((r) {
          Get.back();
          greenSnackBar('Request Sent', 'Please wait for confirmation');
          apptController.clinic.text = '';
          apptController.notes.text = '';
        });
        setState(() => _isLoading = false);
      } catch (error) {
        redSnackBar('Request Error', error.toString());
        setState(() => _isLoading = false);
      }
    }
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

  late Future<List<ClinicModel>> allClinics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('new req'.tr, overflow: TextOverflow.ellipsis),
        actions: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _submitAuthForm(),
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
      endDrawer: EndDrawer(ptListController.currentPt.value.id),
      backgroundColor: Colors.white,
      body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: [
              // DropdownButtonFormField<String>(
              //   key: const ValueKey('Clinic'),
              //   decoration: InputDecoration(
              //     hoverColor: Theme.of(context).primaryColor,
              //     labelText: 'Clinic',
              //   ),
              //   validator: (String? val) {
              //     if (val!.trim().isEmpty) {
              //       return 'Clinic is required!';
              //     }
              //     return null;
              //   },
              //   value: apptController.clinic.text,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       apptController.clinic.text = newValue!;
              //     });
              //   },
              //   onSaved: (String? what) => clinic = what!,
              //   items: _dropdownTitles.map((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              // ),
              FutureBuilder<List<ClinicModel>>(
                future: allClinics, //getAllClinic(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ClinicModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return DropdownButtonFormField<ClinicModel>(
                      decoration: InputDecoration(
                        hoverColor: Theme.of(context).primaryColor,
                        labelText: 'Clinic',
                      ),
                      onChanged: (ClinicModel? newValue) {
                        cm = newValue!;
                      },
                      validator: (ClinicModel? cm) {
                        if (cm == ClinicModel()) {
                          return 'Clinic is required!';
                        }
                        return null;
                      },
                      items: snapshot.data!.map((ClinicModel value) {
                        return DropdownMenuItem<ClinicModel>(
                            value: value,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              child: Text(value.name),
                            ));
                      }).toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                key: const ValueKey('notes'),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
                onSaved: (value) {
                  apptController.notes.text = value!.trim();
                },
              ),
              const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: const [
              //     Tooltip(
              //       triggerMode: TooltipTriggerMode.tap,
              //       showDuration: Duration(seconds: 10),
              //       message:
              //           'Emergency = Within a day,\nSemi-E = 1-2 Week,\nNot Urgent = More than 2 weeks',
              //       child: Icon(Icons.info), //Text
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 5),
              // SizedBox(
              //   height: 50,
              //   child: Scrollbar(
              //     thumbVisibility: true,
              //     thickness: 10,
              //     controller: yourScrollController,
              //     child: Padding(
              //       padding: const EdgeInsets.only(bottom: 10.0),
              //       child: ListView.builder(
              //           controller: yourScrollController,
              //           shrinkWrap: true,
              //           scrollDirection: Axis.horizontal,
              //           itemCount: urgency.length,
              //           itemBuilder: (context, index) {
              //             return Container(
              //               margin: const EdgeInsets.only(right: 2),
              //               decoration: BoxDecoration(
              //                   border: Border.all(),
              //                   borderRadius: BorderRadius.circular(5)),
              //               width: 180,
              //               child: RadioListTile<int>(
              //                 selected: generalUrg == urgency[urgList[index]],
              //                 title: Text(urgList[index],
              //                     overflow: TextOverflow.ellipsis),
              //                 value: urgency[urgList[index]]!,
              //                 groupValue: generalUrg,
              //                 dense: true,
              //                 visualDensity: const VisualDensity(
              //                     horizontal: -3, vertical: -3),
              //                 onChanged: (int? value) async {
              //                   setState(() {
              //                     generalUrg = value!;
              //                   });
              //                 },
              //               ),
              //             );
              //           }),
              //     ),
              //   ),
              // ),
              const Text('Choose preferred dates:'),
              MultiCalendar(sd: _selectedDays),
              const SizedBox(height: 15),
              RefLetterPicker(_pickedImage),
            ],
          )),
    );
  }
}
