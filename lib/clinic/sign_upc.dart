import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'loginc.dart';

class SignUpc extends StatefulWidget {
  const SignUpc({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpcState createState() => _SignUpcState();
}

class _SignUpcState extends State<SignUpc> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<String> _dropdownTitles = ['Dr', 'Sn', ''];
  PhoneNumber number = PhoneNumber(isoCode: 'MY');

  @override
  void initState() {
    super.initState();
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        await auth.createUserWithEmailAndPassword(
            email: drsnController.email.text.trim(),
            password: drsnController.password.text.trim());
      } on PlatformException catch (error) {
        redSnackBar('Registration Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        redSnackBar('Registration Error', error.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup - HSA Clinic'),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 6),
        //     child: IconButton(
        //       icon: Icon(Icons.report),
        //       onPressed: () => showReportDialog(),
        //     ),
        //   )
        // ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
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
                      controller: drsnController.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Name is required!';
                        } else if (val.trim().length < 3) {
                          return 'Name must be at least 3 characters long';
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
                      key: const ValueKey('ic'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'IC is required!';
                        } else if (val.trim().length != 14) {
                          return 'IC must be 14 characters long';
                        }
                        return null;
                      },
                      controller: drsnController.ic,
                      decoration: const InputDecoration(
                        labelText: 'IC',
                      ),
                      onSaved: (value) {
                        drsnController.ic.text = value!.trim();
                      },
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      key: const ValueKey('email'),
                      controller: drsnController.email,
                      enableInteractiveSelection: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s'))
                      ],
                      toolbarOptions: const ToolbarOptions(
                        copy: false,
                        paste: false,
                      ),
                      validator: EmailValidator(
                          errorText: 'Please enter a valid email address'),
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: 'Email address'),
                      onSaved: (value) {
                        drsnController.email.text = value!.trim();
                      },
                    ),
                    const SizedBox(height: 7),
                    // IntlPhoneField(
                    //   disableLengthCheck: true,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Phone Number',
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(),
                    //     ),
                    //   ),
                    //   initialCountryCode: 'MY',
                    //   onChanged: (phone) {
                    //     // print(phone.completeNumber);
                    //   },
                    //   controller: drsnController.phone,
                    //   onSaved: (value) {
                    //     drsnController.phone.text =
                    //         value!.completeNumber.trim();
                    //     // every time add +60 in front??
                    //   },
                    // ),
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        print(number.phoneNumber);
                      },
                      onInputValidated: (bool value) {
                        print(value);
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      initialValue: number,
                      countries: const [
                        'SG',
                        'MY',
                        'ID'
                      ], // apparent by alphabetical order
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: const TextStyle(color: Colors.black),
                      textFieldController: drsnController.phone,
                      hintText: '123456789',
                      formatInput: false, // experiment - type alphabets
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      inputBorder: const OutlineInputBorder(),
                      onSaved: (PhoneNumber number) {
                        print('On Saved: $number');
                        if (number.isoCode == 'MY' &&
                            drsnController.phone.text[0] == '0') {
                          drsnController.phone.text =
                              drsnController.phone.text.substring(1);
                        }
                        drsnController.phone.text =
                            number.phoneNumber!; // cannot if not valid
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('mmcLjm'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: drsnController.mmcLjm,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Registration Number is required!';
                        } else if (val.trim().length < 5) {
                          return 'Registration Number must be at least 5 characters long';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MMC / LJM no.',
                      ),
                      onSaved: (value) {
                        drsnController.mmcLjm.text = value!;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('title'),
                      decoration: InputDecoration(
                        hoverColor: Theme.of(context).primaryColor,
                        labelText: 'Title',
                      ),
                      value: drsnController.title.text,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return 'Title is required!';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          drsnController.title.text = newValue!;
                        });
                      },
                      items: _dropdownTitles.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: drsnController.password,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Password is required!';
                        } else if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Password', hintText: 'Numbers only'),
                      obscureText: true,
                      onSaved: (value) {
                        drsnController.password.text = value!.trim();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _submitAuthForm,
                        child: const Text('Sign Up'),
                      ),
                    if (!_isLoading)
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor),
                        child: const Text('Already have an account'),
                        onPressed: () => Get.off(const Loginc()),
                      )
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
