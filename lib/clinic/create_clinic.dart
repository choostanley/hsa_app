import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/clinic/widgets/end_drawer.dart';
// import 'package:form_field_validator/form_field_validator.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'helpers/routes.dart';
import 'loginc.dart';
import 'models/clinic_model.dart';

class CreateClinic extends StatefulWidget {
  const CreateClinic({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateClinicState createState() => _CreateClinicState();
}

class _CreateClinicState extends State<CreateClinic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController name = TextEditingController();
  TextEditingController shortName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _submitClinicForm() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        Map<String, dynamic> dataMap = {
          'name': name.text.trim(),
          'shortName': shortName.text.trim(),
          'approved': false,
          'createdBy': auth.currentUser!.uid,
          'createByName': userController.user.getName(),
          'roomIdList': <String>[],
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        Map<String, dynamic> memberMap = {
          'drSnId': auth.currentUser!.uid,
          'drSnName': userController.user.name,
          'drSnIc': userController.user.ic,
          'addedById': auth.currentUser!.uid,
          // 'clinicId': false,
          'valid': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await clinicRef.add(dataMap).then((val) {
          dataMap['id'] = val.id;
          ClinicModel newCm = ClinicModel.fromJson(dataMap);
          clinicListController.currentCl.value = newCm;
          clinicListController.addCli(newCm);
          memberMap['clinicId'] = val.id;
          memberRef.add(memberMap);
          Get.offAllNamed(clinicProfileRoute);
        });
      } on PlatformException catch (error) {
        redSnackBar('Creation Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        redSnackBar('Creation Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    drsnController.ctx = context;
    return WillPopScope(
        onWillPop: conWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Create Clinic'),
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
          backgroundColor: Theme.of(context).primaryColor,
          endDrawer: const EndDrawer(createClinicRoute),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Create Clinic',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
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
                          key: const ValueKey('shortname'),
                          keyboardType: TextInputType.name,
                          controller: shortName,
                          validator: (val) {
                            if (val!.trim().isEmpty) {
                              return 'Short Name is required!';
                            } else if (val.trim().length < 3) {
                              return 'Short Name must be at least 3 characters long';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Short Name',
                          ),
                          onSaved: (value) {
                            drsnController.name.text = value!.trim();
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (_isLoading) const CircularProgressIndicator(),
                        if (!_isLoading)
                          ElevatedButton(
                            onPressed: _submitClinicForm,
                            child: const Text('Create'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
