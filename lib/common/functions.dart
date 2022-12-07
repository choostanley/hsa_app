import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/controllers/controllers.dart';

import '../clinic/controllers/controllers.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

Future<bool> onWillPop() async {
  final shouldPop = await showDialog(
    context: ptController.ctx,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you want to leave app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );

  return shouldPop ?? false;
}

Future<bool> conWillPop() async {
  final shouldPop = await showDialog(
    context: drsnController.ctx,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you want to leave app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );

  return shouldPop ?? false;
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }
}

void redSnackBar(String m0, String m1) {
  Get.snackbar(m0, m1,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
}

void greenSnackBar(String m0, String m1) {
  Get.snackbar(m0, m1,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
}

void blueSnackBar(String m0, String m1) {
  Get.snackbar(m0, m1,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue);
}

void purpleSnackBar(String m0, String m1) {
  Get.snackbar(m0, m1,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.purple);
}

void topBlueSnackBar(String m0, String m1) {
  Get.snackbar(m0, m1,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green);
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String getDate(DateTime dt) =>
    DateFormat('dd-MM-yyyy').format(dt); // get date from DateTime

String getMonth(DateTime dt) =>
    DateFormat('MM/yyyy').format(dt); // get month from DateTime

void sendPushMessageToPt(String token, String title, String body) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAzvKz-NQ:APA91bFoJlr0AAMP0vpqazM7rkZA-kZGwUlM3DllGmkSIYp0c0erG2njGrohHaY046L2T6Ok9ci_P_bFCRqJtQhPApvJRBmG05yv0oX81A9LHSpfyNuZOhmuHJEeCJ_8bvp16h2EFlmR'
      },
      body: jsonEncode(<String, dynamic>{
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'body': body,
          'title': title,
        },
        "notification": <String, dynamic>{
          'body': body,
          'title': title,
          "android_channel_id": "dbfood"
        },
        "to": token,
        "topic": 'pt'
      }),
    );
  } catch (error) {
    redSnackBar('Unable to send Notification', 'Internal error');
  }
}
