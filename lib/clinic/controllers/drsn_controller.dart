import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/clinic/helpers/routes.dart';
import 'package:hsa_app/clinic/loginc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:extended_masked_text/extended_masked_text.dart';

import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import '../models/user.dart';
import '../drsn_profile.dart';
import 'controllers.dart';
import 'user_controller.dart';

class DrsnController extends GetxController {
  static DrsnController instance = Get.find();
  late Rx<User?> _firebaseUser;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController ic =
      MaskedTextController(mask: '000000-00-0000', text: '');
  TextEditingController phone = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController mmcLjm = TextEditingController();
  late firebase_storage.Reference storageRef;
  bool remindCompleteRegistration = false;
  List<String> rnList = [];
  List<String> icList = [];

  late Future<DocumentSnapshot> getUserFuture;
  bool inited = false;
  // apparently getx controller has a initialized bool

  User? get user => _firebaseUser.value;

  late BuildContext ctx;

  @override
  void onReady() {
    super.onReady();
    _firebaseUser = Rx<User?>(auth.currentUser);
    _firebaseUser.bindStream(auth.userChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    // if (kIsWeb) auth.setPersistence(Persistence.SESSION);
    if (user == null) {
      Get.offAll(() => const Loginc());
    } else if (!user.emailVerified) {
      drsnReqRef.doc(user.uid).get().then((ur) async {
        if (ur.exists) {
          // remindCompleteRegistration = true;
          // signOut();
          // Get.offAllNamed(drsnProfileRoute);
          Get.offAll(() =>
              const DrsnProfile()); //...actually is not here de - just reminder
          _clearControllers();
        } else {
          // user.sendEmailVerification();
          rnList = [];
          icList = [];
          await drsnReqRef.get().then((val) {
            for (var doc in val.docs) {
              rnList.add(doc.get('mmcLjm'));
              icList.add(doc.get('ic'));
            }
          });
          if (icList.contains(drsnController.ic.text.trim()) ||
              rnList.contains(drsnController.mmcLjm.text.trim())) {
            redSnackBar(
                'Registration Error', 'IC/MMC/LJM number has been registered.');
            await auth.currentUser!.delete();
            return;
          }
          if (name.text.trim().isNotEmpty) {
            await drsnReqRef.doc(user.uid).set({
              'name': name.text.trim(),
              'email': email.text.trim(),
              'ic': ic.text.trim(),
              'phone': phone.text.trim(),
              'title': title.text.trim(),
              'mmcLjm': mmcLjm.text.trim(),
              'mToken': '',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }
          // remindCompleteRegistration = true;
          if (auth.currentUser != null) signOut();
          _clearControllers();
        }
      });
    } else {
      // Get.offAllNamed(drsnProfileRoute);
      Get.offAll(() => const DrsnProfile());
      remindCompleteRegistration = false;
    }
  }

  // void createUser(String name, String email, String password) async {
  //   try {
  //     UserCredential _authResult = await auth.createUserWithEmailAndPassword(
  //         email: email.trim(), password: password.trim());
  //   } catch (e) {
  //     Get.snackbar(
  //       "Error creating Account",
  //       e.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //     );
  //   }
  // }

  signIn() async {
    try {
      await auth
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((result) {
        drsnReqRef.doc(result.user!.uid).get().then((ur) {
          if (!ur.exists) {
            signOut();
            Future.delayed(
                const Duration(milliseconds: 1500),
                () => redSnackBar(
                    'User UNDETECTED', 'User NOT registered as Dr/Sn'));
          }
        });
        _clearControllers();
      });
    } catch (error) {
      redSnackBar('Sign In Failed', error.toString());
    }
  }

  void signOut() async {
    try {
      if (auth.currentUser != null) {
        await drsnReqRef.doc(auth.currentUser!.uid).get().then((ur) async {
          if (ur.exists) {
            await drsnReqRef.doc(auth.currentUser!.uid).update({'mToken': ''});
          }
        });
      }
      await auth.signOut();
      if (await messaging.isSupported()) await messaging.deleteToken();
      userController.clear();
    } catch (error) {
      redSnackBar('Error signing out', error.toString());
    }
  }

  void initializeUserModel(DocumentSnapshot ss) {
    UserModel ownerOfAccount = UserModel.fromSnapshot(ss);
    userController.setUser(ownerOfAccount);
    // ownerOfAccount.deptList(); // bring out so other user no need dept list
  }

  _clearControllers() {
    email.clear();
    password.clear();
    name.clear();
    ic.clear();
    mmcLjm.clear();
    title.clear();
    phone.clear();
  }
}
