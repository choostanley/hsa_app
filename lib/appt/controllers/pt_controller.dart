import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:extended_masked_text/extended_masked_text.dart';

import '../app_owner.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import '../models/user.dart';
import '../pt_profile.dart';
import 'controllers.dart';
import 'user_controller.dart';

class PtController extends GetxController {
  static PtController instance = Get.find();
  late Rx<User?> _firebaseUser;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController ic =
      MaskedTextController(mask: '000000-00-0000', text: '');
  TextEditingController phone = TextEditingController();
  late firebase_storage.Reference storageRef;
  bool remindCompleteRegistration = false;
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
    // without this, session persist even if tab is closed
    // if (kIsWeb) auth.setPersistence(Persistence.SESSION);
    // if use this, pt not logged in after tab is closed...
    // what about notification...
    // https://firebase.google.com/docs/auth/web/auth-state-persistence
    if (user == null) {
      Get.offAll(() => const Login());
    } else if (!user.emailVerified) {
      appOwnerRef.doc(user.uid).get().then((ur) async {
        if (ur.exists) {
          // remindCompleteRegistration = true;
          // signOut();
          Get.offAll(() =>
              const AppOwner()); //...actually is not here de - just reminder
          _clearControllers();
        } else {
          // user.sendEmailVerification();
          icList = [];
          await appOwnerRef.get().then((val) {
            for (var doc in val.docs) {
              icList.add(doc.get('ic'));
            }
          });
          if (icList.contains(ptController.ic.text.trim())) {
            redSnackBar('Error', 'IC number has been registered.');
            await auth.currentUser!.delete();
            return;
          }
          if (name.text.trim().isNotEmpty) {
            print(name.text.trim().isNotEmpty);
            print(name.text.trim());
            await appOwnerRef.doc(user.uid).set({
              'name': name.text.trim(),
              'email': email.text.trim(),
              'ic': ic.text.trim(),
              'phone': phone.text.trim(),
              'mToken': '',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }
          // remindCompleteRegistration = true;
          // print('inside setinitialscreen');
          // print(auth.currentUser);
          if (auth.currentUser != null) signOut();
          _clearControllers();
        }
      });
    } else {
      Get.offAll(() => const AppOwner());
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
    print('inside sign in');
    try {
      await auth
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((result) {
        appOwnerRef.doc(result.user!.uid).get().then((ur) {
          if (!ur.exists) {
            signOut();
            Future.delayed(
                const Duration(milliseconds: 1500),
                () => redSnackBar(
                    'User UNDETECTED', 'User NOT registered as an App Owner'));
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
        await appOwnerRef.doc(auth.currentUser!.uid).get().then((ur) async {
          if (ur.exists) {
            await appOwnerRef.doc(auth.currentUser!.uid).update({'mToken': ''});
          }
        });
      }
      await auth.signOut();
      if (await messaging.isSupported()) await messaging.deleteToken();
      // Get.find<UserController>().clear();
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
    phone.clear();
  }
}
