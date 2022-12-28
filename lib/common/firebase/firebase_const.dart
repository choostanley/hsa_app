import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../../firebase_options.dart';

final Future<FirebaseApp> initialization =
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

final FirebaseAuth auth = FirebaseAuth.instance;
final messaging = FirebaseMessaging.instance;
final FirebaseStorage storage = FirebaseStorage.instance;
final ffi = FirebaseFirestore.instance;

final CollectionReference appOwnerRef = ffi.collection('appOwner');
final CollectionReference ptRef = ffi.collection('pts');
final CollectionReference apptReqRef = ffi.collection('apptReq');
final CollectionReference resReqRef = ffi.collection('resReq');
final CollectionReference arDirRef = ffi.collection('arDir');
final CollectionReference drsnReqRef = ffi.collection('drSn');
final CollectionReference apptRef = ffi.collection('appt');
final CollectionReference apptTimeRef = ffi.collection('apptTime');
final CollectionReference clinicRef = ffi.collection('clinic');
final CollectionReference memberRef = ffi.collection('member');
final CollectionReference scheduleRef = ffi.collection('schedule');
final CollectionReference dayRef = ffi.collection('day');
final CollectionReference scheDayRef = ffi.collection('scheDay');
final CollectionReference hourRef = ffi.collection('hour');
final CollectionReference roomRef = ffi.collection('room');
final CollectionReference attachRoomRef = ffi.collection('attachRoom');
final CollectionReference queueRef = ffi.collection('queue');
final CollectionReference ptNotiRef = ffi.collection('ptNoti');
final CollectionReference holidayRef = ffi.collection('holiday');
final CollectionReference clinicNotiRef = ffi.collection('clinicNoti');

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
final isApp = !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

final isWebDesktop = kIsWeb &&
    !(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

final box = GetStorage();
