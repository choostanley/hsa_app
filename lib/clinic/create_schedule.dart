import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '/clinic/widgets/end_drawer.dart';
// import 'package:form_field_validator/form_field_validator.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'helpers/routes.dart';
import 'models/clinic_model.dart';
import 'package:intl/intl.dart';
import 'package:interval_time_picker/interval_time_picker.dart';

import 'models/schedule_model.dart';
import 'widgets/lead_drawer.dart';
import 'helpers/datetime_rounddown.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateScheduleState createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController apptPerHalfHour = TextEditingController();
  TextEditingController yearCont = TextEditingController(); // try leave empty
  List<int> daysNum = [7, 1, 2, 3, 4, 5, 6];
  Map<int, String> daysOfWeek = {
    1: 'Mon',
    2: 'Tues',
    3: 'Wed',
    4: 'Thurs',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun'
  };
  List<WorkTime> wtl = [];
  int whichTimeCounter = 0;
  List<String> workTimeName = [
    'startWork',
    'lunchTime',
    'lunchTimeOver',
    'finishWork'
  ];
  List<String> workTimeString = [
    'Start Work',
    'Lunch Time',
    'Lunch Time Over',
    'Finish Work'
  ];
  int sow = 0;
  AnimationController? animationController;
  Animation<double>? animation;
  OverlayEntry? overlayEntry;
  DateTime timely = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  DateTime timeHolder = DateTime.now();

  @override
  void initState() {
    wtl = [];
    for (var dow in daysNum) {
      WorkTime wt = WorkTime();
      wt.dayNum = dow;
      // wt.dayName = daysOfWeek[dow]!;
      wtl.add(wt);
    }
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(animationController!);
    super.initState();
  }

  void _submitScheduleForm() async {
    for (var wt in wtl) {
      if (wt.workDay) {
        List<int> asc = [];
        for (var help in workTimeName) {
          asc.add(
              int.parse(wt.workTime[help]!.replaceAll(RegExp(r'[^0-9]'), '')));
        }
        if (!(asc.toSet().length >= 3 &&
            asc.isSorted((a, b) => a.compareTo(b)))) {
          // 3 cos intend if no lunch time
          // setState(() {
          //   wt.enoa = ((getInHour(wt.getTime(3), wt.getTime(0)) -
          //               getInHour(wt.getTime(2), wt.getTime(1))) *
          //           (int.parse(apptPerHalfHour.text) * 2))
          //       .ceil();
          // });
          redSnackBar('Error', 'Inappropriate Timing of Schedule');
          return;
        }
      }
    }

    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        Map<String, dynamic> dataMap = {
          'name': name.text.trim(),
          'description': description.text.trim(),
          'apptPerHalfHour': int.parse(apptPerHalfHour.text.trim()),
          'clinicId': clinicListController.currentCl.value.id,
          'createdBy': auth.currentUser!.uid,
          'createByName': userController.user.getName(),
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await scheduleRef.add(dataMap).then((val) {
          dataMap['id'] = val.id;
          ScheduleModel scModel = ScheduleModel.fromJson(dataMap);
          scheduleListController.addAndCurrent(scModel);
          for (var wtt in wtl) {
            scheDayRef.add({
              'scheduleId': dataMap['id'],
              'dayOfWeek': wtt.dayNum,
              'holiday': !wtt.workDay,
              'startWork': wtt.workTime['startWork'],
              'lunchTime': wtt.workTime['lunchTime'],
              'lunchTimeOver': wtt.workTime['lunchTimeOver'],
              'finishWork': wtt.workTime['finishWork'],
              'apptPerHalfHour': int.parse(apptPerHalfHour.text.trim()),
              'maxAppt': wtt.enoa,
              'createdBy': auth.currentUser!.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }
          Get.offNamed(scheduleRoute);
        });
      } on PlatformException catch (error) {
        redSnackBar('Schedule Creation Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        redSnackBar('Schedule Creation Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DataTable leftSide() {
    return DataTable(
      columnSpacing: 0,
      headingRowColor: MaterialStateProperty.all(Colors.green[300]),
      dataRowHeight: 75,
      horizontalMargin: 10,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
          right: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
      columns: const [
        DataColumn(label: Text('DOW')),
      ],
      rows: daysNum
          .map((dn) => DataRow(
                cells: [
                  DataCell(Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(daysOfWeek[dn]!))),
                ],
              ))
          .toList(),
    );
  }

  WorkTime getWT(int dn) => wtl.firstWhere((wt) => wt.dayNum == dn);

  DataColumn dcText(String header) => DataColumn(
      label: Expanded(child: Text(header, textAlign: TextAlign.center)));

  Expanded rightSide() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.green[100]),
            columnSpacing: 15,
            dataRowHeight: 75,
            horizontalMargin: 10,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
                right: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            columns: [
              // DataColumn(
              //     label:
              //         SizedBox(width: 60, child: Center(child: Text('SOW')))),
              dcText('SOW'),
              dcText('WD'),
              dcText('SW'),
              dcText('LT'), // need to consider for clinic without lunch time?
              dcText('LTO'),
              dcText('FW'),
              dcText('ENOA'),
              // DataColumn(
              //     label: Expanded(
              //         child: Text('SOW', textAlign: TextAlign.center))),
            ],
            rows: daysNum
                .map((dn) => DataRow(
                      cells: [
                        DataCell(Container(
                            alignment: AlignmentDirectional.center,
                            child: Radio(
                                value: dn,
                                groupValue: sow,
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    for (var wt in wtl) {
                                      wt.startOfWeek = false;
                                    }
                                    sow = value!;
                                    getWT(value).startOfWeek = true;
                                  });
                                }))),
                        DataCell(Container(
                            alignment: AlignmentDirectional.center,
                            child: Checkbox(
                              checkColor: Colors.white,
                              value: getWT(dn).workDay,
                              onChanged: (bool? value) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  getWT(dn).workDay = value!;
                                });
                              },
                            ))),
                        DataCell(Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.watch_later),
                                onPressed: getWT(dn).workDay
                                    ? () {
                                        FocusScope.of(context).unfocus();
                                        _showOverlay(
                                            context, 0, getWT(dn).getTime(0),
                                            wt: getWT(dn));
                                      }
                                    : null,
                              ),
                              Text(getWT(dn).getTime(0))
                            ])),
                        DataCell(Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.watch_later),
                                onPressed: getWT(dn).workDay
                                    ? () {
                                        FocusScope.of(context).unfocus();
                                        _showOverlay(
                                            context, 1, getWT(dn).getTime(1),
                                            wt: getWT(dn));
                                      }
                                    : null,
                              ),
                              Text(getWT(dn).getTime(1))
                            ])),
                        DataCell(Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.watch_later),
                                onPressed: getWT(dn).workDay
                                    ? () {
                                        FocusScope.of(context).unfocus();
                                        _showOverlay(
                                            context, 2, getWT(dn).getTime(2),
                                            wt: getWT(dn));
                                      }
                                    : null,
                              ),
                              Text(getWT(dn).getTime(2))
                            ])),
                        DataCell(Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.watch_later),
                                onPressed: getWT(dn).workDay
                                    ? () {
                                        _showOverlay(
                                            context, 3, getWT(dn).getTime(3),
                                            wt: getWT(dn));
                                      }
                                    : null,
                              ),
                              Text(getWT(dn).getTime(3))
                            ])),
                        DataCell(Container(
                            alignment: AlignmentDirectional.center,
                            child: Text(getWT(dn).enoa.toString()))),
                      ],
                    ))
                .toList()),
      ),
    );
  }

  int getMin(String h24) =>
      int.parse(h24.replaceAll(RegExp(r'[^0-9]'), '').substring(2));

  int getHr(String h24) =>
      int.parse(h24.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 2));

  DateTime getDtFromString(String h24) =>
      DateTime(2022, 12, 31, getHr(h24), getMin(h24));

  double getInHour(String oneTime, String twoTime) {
    DateTime timi1 = getDtFromString(oneTime);
    DateTime timi2 = getDtFromString(twoTime);
    return timi1.difference(timi2).inMinutes / 60;
  }

  void calcAndSetEnoa(WorkTime wt) {
    if (apptPerHalfHour.text.isEmpty) return;
    List<int> asc = [];
    for (var help in workTimeName) {
      asc.add(int.parse(wt.workTime[help]!.replaceAll(RegExp(r'[^0-9]'), '')));
    }
    if (asc.toSet().length >= 3 && asc.isSorted((a, b) => a.compareTo(b))) {
      // 3 cos intend if no lunch time
      setState(() {
        wt.enoa = ((getInHour(wt.getTime(3), wt.getTime(0)) -
                    getInHour(wt.getTime(2), wt.getTime(1))) *
                (int.parse(apptPerHalfHour.text) * 2))
            .ceil();
      });
    }
  }

  bool atMost23(String checkTime) {
    if (getHr(checkTime) < 23 || checkTime == '23:00H') {
      return true;
    } else {
      return false;
    }
  }

  bool is24(String checkTime) => getHr(checkTime) == 24 ? true : false;

  bool moreThan24(String checkTime) =>
      (getHr(checkTime) == 24 && getMin(checkTime) != 0) ? true : false;

  void removeOverlay() {
    // ole.remove();
    overlayEntry!.remove();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // UX not nice
  }

  // param time is get pre-existing saved time string in WorkTime model
  void _showOverlay(BuildContext context, int whichTime, String time,
      {required WorkTime wt}) async {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    // overlays: [SystemUiOverlay.top]);
    whichTimeCounter = whichTime;
    OverlayState? overlayState = Overlay.of(context);
    DateTime prevDT = DateTime.now();

    if (time != '00:00H') {
      timely = getDtFromString(time);
    }
    if (whichTimeCounter > 0) {
      String prevTime = wt.getTime(whichTimeCounter - 1);
      prevDT = getDtFromString(prevTime);
    }

    // ****** Need to preset time to 15min interval
    if (isWebDesktop) {
      DateTime appropriateDT = time != '00:00H'
          ? timely
          : whichTimeCounter > 0
              ? prevDT
              : RD(DateTime.now()).roundDown();
      // print(appropriateDT);
      TimeOfDay ohYeah = TimeOfDay.fromDateTime(appropriateDT);
      var tod = await showIntervalTimePicker(
        context: context,
        initialTime: ohYeah,
        interval: 15,
        visibleStep: VisibleStep.fifteenths,
        helpText: workTimeString[whichTimeCounter],
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (tod != null) {
        var now = DateTime.now();
        timeHolder =
            DateTime(now.year, now.month, now.day, tod.hour, tod.minute);

        String gcts = whichTimeCounter == 0
            ? '${DateFormat('HH:mm').format(timeHolder)}H'
            : '${DateFormat('kk:mm').format(timeHolder)}H';
        if (moreThan24(gcts) ||
            (whichTimeCounter == 0 && !atMost23(gcts)) ||
            ([1, 2].contains(whichTimeCounter) && is24(gcts))) {
          // 1 or 2, is24 - true, cannot pass
          // 0 wont be 24 cos using HH
          // animationController!.forward();
          // await Future.delayed(const Duration(seconds: 3))
          //     .whenComplete(() => animationController!.reverse());
          Future.delayed(const Duration(milliseconds: 700))
              .whenComplete(() => redSnackBar('Inappropriate Timing', 'Error'));
          // redSnackBar('Inappropriate Timing', 'Error');
          _showOverlay(context, whichTimeCounter, wt.getTime(whichTimeCounter),
              wt: wt);
          return;
        }
        // 1 of 2 condition that can proceed
        if (whichTimeCounter == 0 ||
            (whichTimeCounter == 2 &&
                compareAtLeastSame(wt.getTime(whichTimeCounter - 1), gcts))) {
          // meaning 3rd can be same as second if no lunch time

          // moved from onTimeChange
          setState(() {
            wt.workTime[workTimeName[whichTimeCounter]] = gcts;
            whichTimeCounter += 1;
          });
          // setState(() => whichTimeCounter += 1);
          // removeOverlay();
          _showOverlay(context, whichTimeCounter, wt.getTime(whichTimeCounter),
              wt: wt);
        } else {
          // 1 of 2 condition that can proceed
          if (compareTimeString(wt.getTime(whichTimeCounter - 1), gcts)) {
            // can use gcts cos no change in whichTimeCounter

            // moved from onTimeChange
            setState(() {
              wt.workTime[workTimeName[whichTimeCounter]] = gcts;
            });

            if (whichTimeCounter == 3) {
              // removeOverlay();
              whichTimeCounter = 0;
              calcAndSetEnoa(wt);
              if (wt.startOfWeek) {
                for (var wtt in wtl) {
                  if (wtt.workDay) {
                    for (var wtn in workTimeName) {
                      setState(() {
                        wtt.workTime[wtn] = wt.workTime[wtn]!;
                      });
                    }
                    // calculate enoa - make eveything the same only
                    setState(() {
                      wtt.enoa = wt.enoa;
                    });
                  }
                }
              }
              // setState(() {}); -- dont really work if set after that shit
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
              );
            } else {
              // this only cater for 1 if not wrong

              // moved from onTimeChange
              setState(() {
                wt.workTime[workTimeName[whichTimeCounter]] = gcts;
                whichTimeCounter += 1;
              });
              // setState(() => whichTimeCounter += 1);
              // removeOverlay();
              _showOverlay(
                  context, whichTimeCounter, wt.getTime(whichTimeCounter),
                  wt: wt);
            }
          } else {
            // print(wt.getTime(whichTimeCounter - 1));
            // print(gcts);
            // print('at compare');
            // animationController!.forward();
            // await Future.delayed(const Duration(seconds: 3))
            //     .whenComplete(() => animationController!.reverse());
            Future.delayed(const Duration(milliseconds: 700))
              .whenComplete(() => redSnackBar('Inappropriate Timing', 'Error'));
            _showOverlay(
                context, whichTimeCounter, wt.getTime(whichTimeCounter),
                wt: wt);
          }
        }
      }
    } else {
      overlayEntry = OverlayEntry(builder: (context) {
        return Material(
          color: Colors.white.withOpacity(0.8),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // without cancel button easier to manage ba
                  // after adding everything, add cancel button should be okay?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => removeOverlay(),
                      ),
                      const SizedBox(width: 40)
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(workTimeString[whichTimeCounter],
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 10),
                  const Text('For optimal experience, SCROLL to pick time',
                      style: TextStyle(fontSize: 10, color: Colors.red)),
                  const Text('Do NOT drag scrollbar on web',
                      style: TextStyle(fontSize: 10, color: Colors.red)),
                  const SizedBox(height: 30),
                  TimePickerSpinner(
                    time: time != '00:00H'
                        ? timely
                        : whichTimeCounter > 0
                            ? prevDT
                            : null,
                    // take current value if not 00:00H, else if not first get prev time value
                    is24HourMode: true,
                    minutesInterval: 15,
                    spacing: 50,
                    itemHeight: 80,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      // tamade on desktop drag scroller does work
                      // print(time);
                      // print('you mei you on change ahhhhhhh');

                      // if dont want change real time make another holder variable
                      timeHolder = time;
                      // setState(() {
                      //   wt.workTime[workTimeName[whichTimeCounter]] =
                      //       whichTimeCounter == 0
                      //           ? '${DateFormat('HH:mm').format(time)}H'
                      //           : '${DateFormat('kk:mm').format(time)}H';
                      // });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.thumb_up,
                      size: 30,
                    ),
                    onPressed: () async {
                      // String gcts =
                      //     wt.getTime(whichTimeCounter); //getCurrentTimeString
                      String gcts = whichTimeCounter == 0
                          ? '${DateFormat('HH:mm').format(timeHolder)}H'
                          : '${DateFormat('kk:mm').format(timeHolder)}H';

                      if (moreThan24(gcts) ||
                          (whichTimeCounter == 0 && !atMost23(gcts)) ||
                          ([1, 2].contains(whichTimeCounter) && is24(gcts))) {
                        // 1 or 2, is24 - true, cannot pass
                        // 0 wont be 24 cos using HH
                        animationController!.forward();
                        await Future.delayed(const Duration(seconds: 3))
                            .whenComplete(() => animationController!.reverse());
                        return;
                      }
                      // 1 of 2 condition that can proceed
                      if (whichTimeCounter == 0 ||
                          (whichTimeCounter == 2 &&
                              compareAtLeastSame(
                                  wt.getTime(whichTimeCounter - 1), gcts))) {
                        // meaning 3rd can be same as second if no lunch time

                        // moved from onTimeChange
                        setState(() {
                          wt.workTime[workTimeName[whichTimeCounter]] = gcts;
                        });

                        setState(() => whichTimeCounter += 1);
                        removeOverlay();
                        _showOverlay(context, whichTimeCounter,
                            wt.getTime(whichTimeCounter),
                            wt: wt);
                      } else {
                        // 1 of 2 condition that can proceed
                        if (compareTimeString(
                            wt.getTime(whichTimeCounter - 1), gcts)) {
                          // can use gcts cos no change in whichTimeCounter

                          // moved from onTimeChange
                          setState(() {
                            wt.workTime[workTimeName[whichTimeCounter]] = gcts;
                          });

                          if (whichTimeCounter == 3) {
                            removeOverlay();
                            whichTimeCounter = 0;
                            calcAndSetEnoa(wt);
                            if (wt.startOfWeek) {
                              for (var wtt in wtl) {
                                if (wtt.workDay) {
                                  for (var wtn in workTimeName) {
                                    setState(() {
                                      wtt.workTime[wtn] = wt.workTime[wtn]!;
                                    });
                                  }
                                  // calculate enoa - make eveything the same only
                                  setState(() {
                                    wtt.enoa = wt.enoa;
                                  });
                                }
                              }
                            }
                            // setState(() {}); -- dont really work if set after that shit
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn,
                            );
                          } else {
                            // this oinly cater for 1 if not wrong

                            // moved from onTimeChange
                            setState(() {
                              wt.workTime[workTimeName[whichTimeCounter]] =
                                  gcts;
                            });

                            setState(() => whichTimeCounter += 1);
                            removeOverlay();
                            _showOverlay(context, whichTimeCounter,
                                wt.getTime(whichTimeCounter),
                                wt: wt);
                          }
                        } else {
                          animationController!.forward();
                          // print(wt.getTime(whichTimeCounter - 1));
                          // print(gcts);
                          // print('at compare');
                          await Future.delayed(const Duration(seconds: 3))
                              .whenComplete(
                                  () => animationController!.reverse());
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 15),
                  FadeTransition(
                    opacity: animation!,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.02),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: const Text(
                        'Time set inappropriate',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
      overlayState!.insert(overlayEntry!);
    }
    // Positioned(
    //   left: MediaQuery.of(context).size.width * 0.1,
    //   top: MediaQuery.of(context).size.height * 0.80,
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(10),
    //     child: Material(
    //       child: FadeTransition(
    //         opacity: animation!,
    //         child: Container(
    //           alignment: Alignment.center,
    //           color: Colors.grey.shade200,
    //           padding:
    //               EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
    //           width: MediaQuery.of(context).size.width * 0.8,
    //           height: MediaQuery.of(context).size.height * 0.06,
    //           child: Text(
    //             text,
    //             style: const TextStyle(color: Colors.black),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    // animationController!.addListener(() {
    //   overlayState!.setState(() {});
    // });
    // // inserting overlay entry
    // overlayState!.insert(overlayEntry);
    // animationController!.forward();
    // await Future.delayed(const Duration(seconds: 3))
    //     .whenComplete(() => animationController!.reverse())
    //     // removing overlay entry after stipulated time.
    //     .whenComplete(() => overlayEntry.remove());
  }

  bool compareTimeString(String firstTS, String secondTS) {
    if (getHr(firstTS) < getHr(secondTS)) {
      return true;
    } else if (getHr(firstTS) == getHr(secondTS) &&
        getMin(firstTS) < getMin(secondTS)) {
      return true;
    }
    return false;
  }

  bool compareAtLeastSame(String firstTS, String secondTS) =>
      getDtFromString(firstTS).isAtSameMomentAs(getDtFromString(secondTS)) ||
              getDtFromString(firstTS).isBefore(getDtFromString(secondTS))
          ? true
          : false;

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return WillPopScope(
        onWillPop: overlayEntry == null
            ? conWillPop
            : () async {
                removeOverlay();
                overlayEntry = null;
                return Future.value(false);
              },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Create Schedule'),
              leading: IconButton(
                icon: const Icon(Icons.local_hospital, size: 30),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    size: 30,
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                )
              ],
            ),
            drawer: const LeadingDrawer(createScheduleRoute),
            endDrawer: EndDrawer(clinicListController.currentCl.value.id),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          key: const ValueKey('name'),
                          keyboardType: TextInputType.name,
                          controller: name,
                          validator: (val) {
                            if (val!.trim().isEmpty) {
                              return 'Name is required!';
                            } else if (val.trim().length < 3) {
                              return 'Clinic Name must be at least 6 characters long';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                          onSaved: (value) {
                            drsnController.name.text = value!.trim();
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('description'),
                          keyboardType: TextInputType.name,
                          controller: description,
                          validator: (val) {
                            if (val!.trim().isEmpty) {
                              return 'Description is required!';
                            } else if (val.trim().length < 3) {
                              return 'Description must be at least 6 characters long';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          onSaved: (value) {
                            drsnController.name.text = value!.trim();
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('apptPerHalfHour'),
                          keyboardType: TextInputType.number,
                          controller: apptPerHalfHour,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (val) {
                            if (val!.trim().isEmpty) {
                              return 'Appt/0.5Hr is required!';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            for (var wt in wtl) {
                              if (wt.workDay) calcAndSetEnoa(wt);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Appt/0.5Hr',
                          ),
                          onSaved: (value) {
                            drsnController.name.text = value!.trim();
                          },
                        ),
                        const SizedBox(height: 7),
                        const Text('DOW - Days of Week'),
                        const Text('SOW - Start of Week'),
                        const Text('WD - Working Day'),
                        const Text('SW - Start Work'),
                        const Text('LT - Lunch Time'),
                        const Text('LTO - Lunch Time Over'),
                        const Text('FW - Finish Work'),
                        const Text('ENOA - Estimated no. of Appt per day'),
                        const Text(
                            '* if no Lunch Time, set LT & LTO to the SAME time'),
                        const SizedBox(height: 7),
                        Column(
                          // controller: sctrl,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                leftSide(),
                                rightSide(),
                              ],
                            )
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          // for illustration purpose
                          key: const ValueKey('year'),
                          decoration: InputDecoration(
                            hoverColor: Theme.of(context).primaryColor,
                            labelText: 'Create Year',
                          ),
                          value: yearCont.text,
                          validator: (String? val) {
                            if (val!.trim().isEmpty) {
                              return 'Year is required!';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              yearCont.text = newValue!;
                            });
                          },
                          items:
                              ['2022', '2023', '2024', ''].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // if (_isLoading) const CircularProgressIndicator(),
                        // if (!_isLoading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: !_isLoading
                              ? [
                                  ElevatedButton(
                                      onPressed: _submitScheduleForm,
                                      child: const Text('Create Schedule')),
                                  const ElevatedButton(
                                      onPressed: null,
                                      child: Text(
                                          'Create with\nNational Holiday')),
                                ]
                              : [
                                  const CircularProgressIndicator(),
                                ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}

class WorkTime {
  List<String> workTimeName = [
    'startWork',
    'lunchTime',
    'lunchTimeOver',
    'finishWork'
  ];
  int dayNum = 0;
  // String dayName = '';
  bool workDay = false;
  bool startOfWeek = false;
  Map<String, String> workTime = {
    'startWork': '00:00H',
    'lunchTime': '00:00H',
    'lunchTimeOver': '00:00H',
    'finishWork': '00:00H'
  };
  int enoa = 0;

  String getTime(int ii) => workTime[workTimeName[ii]]!;
}

extension on DateTime {
  DateTime roundDown({Duration delta = const Duration(seconds: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch - millisecondsSinceEpoch % delta.inMilliseconds);
  }
}
