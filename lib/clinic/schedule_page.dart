import 'package:flutter/material.dart';
import 'package:hsa_app/clinic/helpers/routes.dart';
import 'package:hsa_app/clinic/models/schedule_day.dart';

import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'models/day_model.dart';
import 'models/hour_model.dart';
import 'models/schedule_model.dart';
import 'widgets/hour_row.dart';
import 'widgets/lead_drawer.dart';
import 'widgets/end_drawer.dart';
import 'widgets/schedule_calender.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.sc});
  final ScheduleModel sc;

  @override
  // ignore: library_private_types_in_public_api
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScheduleModel localSc;
  late DayModel scDay;
  List<HourModel> _dayHours = [];
  final ValueNotifier<List<HourModel>> _hourRows =
      ValueNotifier<List<HourModel>>([]);

  @override
  void initState() {
    localSc = widget.sc;
    super.initState();
  }

  void _pickedDate(DayModel day, ScheduleDay sDay) async {
    // scDay = day; - for now no use?
    _dayHours = await dayListController.storeDayAndloadHours(
        day, sDay); // DayModel stores hours model
    // insert into dayListController - so that schedule model not too huge
    // how to manage hours & appts?
    // for (var hr in _dayHours) {
    //   print(DateFormat('HH:mm').format(hr.startDateTime));
    // }
    _dayHours.sort((a, b) => a.startDT.compareTo(b.startDT));
    _hourRows.value = _dayHours; // need to assign new variable to listenable
    // setState(() {}); - setstate calender cant correspond
  }

  Widget redBox() => SizedBox(
      height: 80,
      child: Container(
          padding: const EdgeInsets.fromLTRB(2, 3, 2, 3),
          width: 90,
          child: ListTile(
            title:
                Text('${localSc.description.toString().padLeft(2, '0')}:00H'),
            subtitle: const Text('End of day'),
            tileColor: Theme.of(context).primaryColorLight,
          )));

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(localSc.name),
          leading: IconButton(
            icon: const Icon(Icons.local_hospital, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        drawer: LeadingDrawer(localSc.id),
        endDrawer: EndDrawer(clinicListController
            .currentCl.value.id), // need to change in clinic profile?
        body: WillPopScope(
            onWillPop: conWillPop,
            child: Center(
              // child: ConstrainedBox(
              //   constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                // try out
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: FutureBuilder(
                        future: localSc.getDayModelList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<DayModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ScheduleCalendar(
                              sm: localSc,
                              dayFn: _pickedDate,
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // This expanded when first create schedule, press date hourRow not showing
                    // If change date then only show
                    Expanded(
                      child: ValueListenableBuilder<List<HourModel>>(
                        valueListenable: _hourRows,
                        builder: (context, value, _) {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: ListView.builder(
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                return HourRow(
                                  value[index],
                                  index == 0,
                                  key: Key(getRandomString(5)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              // ),
            )));
  }
}
