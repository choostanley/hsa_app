import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:hsa_app/appt/helpers/routes.dart';
import 'package:hsa_app/appt/models/pt.dart';
import 'package:hsa_app/appt/pt_profile.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'login.dart';
import 'widgets/end_drawer.dart';

class CreatePt extends StatefulWidget {
  const CreatePt({super.key, this.name = '', this.icNo = ''});
  final String name;
  final String icNo;

  @override
  // ignore: library_private_types_in_public_api
  _CreatePtState createState() => _CreatePtState();
}

class _CreatePtState extends State<CreatePt> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String gender;
  List<bool> isSelected = [true, false, false];
  final nameCont = TextEditingController();
  final icCont = MaskedTextController(mask: '000000-00-0000-00', text: '');
  final raceCont = TextEditingController();
  final addCont = TextEditingController();

  @override
  void initState() {
    if (widget.name.isNotEmpty) nameCont.text = widget.name;
    if (widget.icNo.isNotEmpty) {
      icCont.text = widget.icNo;
      if (int.parse(widget.icNo.substring(13)).isEven) {
        isSelected = [false, true, false];
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameCont.dispose();
    icCont.dispose();
    raceCont.dispose();
    addCont.dispose();
    super.dispose();
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    _formKey.currentState!.save();
    QuerySnapshot<Object?> ptList = await ptRef.get();
    List<String> ptIcList =
        ptList.docs.map((pt) => pt.get('ic').toString()).toList();
    if (ptIcList.contains(icCont.text.trim())) {
      redSnackBar('Error', 'Duplicate IC number.');
      return;
    }
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        int genderIndex = isSelected.indexWhere((g) => g);
        Map<String, dynamic> dataMap = {
          'name': nameCont.text.trim(),
          'ic': icCont.text.trim(),
          'gender': genderIndex,
          'race': raceCont.text.trim(),
          'address': addCont.text.trim(),
          'ownerId': userController.user.id,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await ptRef.add(dataMap).then((val) {
          dataMap['id'] = val.id;
          ptListController.addPt(PtModel.fromJson(dataMap));
          ptListController.currentPt.value = PtModel.fromJson(dataMap);
        });
        // remindCompleteRegistration = true;
        // signOut();
        Get.off(PtProfile(
          ptModel: PtModel.fromJson(dataMap),
        ));
        // _clearControappownellers();
      } on PlatformException catch (error) {
        redSnackBar('Create Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        redSnackBar('Create Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('mpp'.tr),
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
      endDrawer: const EndDrawer(createPtRoute),
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
                    TextFormField(
                      key: const ValueKey('name'),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Name is required!';
                        } else if (val.trim().length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        return null;
                      },
                      controller: nameCont,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onSaved: (value) {
                        nameCont.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      key: const ValueKey('ic'),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'IC is required!';
                        } else if (val.trim().length < 14) {
                          return 'IC must be at least 14 characters long';
                        }
                        return null;
                      },
                      controller: icCont,
                      decoration: const InputDecoration(
                        labelText: 'IC',
                      ),
                      onChanged: (value) {
                        if (value.length >= 14) {
                          if (int.parse(value.substring(13, 14)).isEven) {
                            setState(() {
                              isSelected = [false, true, false];
                            });
                          } else if (int.parse(value.substring(13, 14)).isOdd) {
                            setState(() {
                              isSelected = [true, false, false];
                            });
                          }
                        }
                      },
                      onSaved: (value) {
                        icCont.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 7),
                    Text('gender'.tr, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 7),
                    ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0;
                              buttonIndex < isSelected.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                      isSelected: isSelected,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 65),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(Icons.male),
                                Text('male'.tr)
                              ],
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 65),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(Icons.female),
                                Text('female'.tr)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Icon(Icons.transgender),
                              Text('ambiguous'.tr)
                            ],
                          ),
                        ),
                        // Icon(Icons.female),
                        // Icon(Icons.transgender),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      key: const ValueKey('race'),
                      controller: raceCont,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Race',
                        // prefixIcon: isApp
                        //     ? IconButton(
                        //         icon: Icon(Icons.paste),
                        //         onPressed: () async {
                        //           String data = localCont.selection
                        //               .textInside(localCont.text);
                        //           nameCont.text += data + ' ';
                        //         },
                        //       )
                        //     : null
                      ),
                      onSaved: (value) {
                        raceCont.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      key: const ValueKey('address'),
                      controller: addCont,
                      keyboardType: TextInputType.name,
                      validator: MultiValidator([
                        MinLengthValidator(8,
                            errorText:
                                'Patient\'s Address must be at least 8 characters or shorter'),
                        PatternValidator(r'^[\x00-\x7F]+$',
                            errorText: 'Contains illegal character!'),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Patient\'s Address',
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        addCont.text = value!;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _submitAuthForm,
                        child: Text('mpp'.tr),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
