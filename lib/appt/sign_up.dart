import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'controllers/controllers.dart';
import '/common/firebase/firebase_const.dart';
import '/common/functions.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    // _formKey.currentState!.save();
    if (isValid) {
      _formKey.currentState!.save(); // should be like this ba
      try {
        setState(() {
          _isLoading = true;
        });

        await auth.createUserWithEmailAndPassword(
            email: ptController.email.text.trim(),
            password: ptController.password.text.trim());
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
        title: const Text('Signup - HSA Appt'),
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
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Name is required!';
                        } else if (val.trim().length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        return null;
                      },
                      controller: ptController.name,
                      decoration: const InputDecoration(
                        labelText: 'Name as per IC',
                      ),
                      onSaved: (value) {
                        ptController.name.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      key: const ValueKey('ic'),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'IC is required!';
                        } else if (val.trim().length != 14) {
                          return 'IC must be 14 characters long';
                        }
                        return null;
                      },
                      controller: ptController.ic,
                      decoration: const InputDecoration(
                        labelText: 'IC',
                      ),
                      onSaved: (value) {
                        ptController.ic.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      key: const ValueKey('email'),
                      // enableInteractiveSelection: false,
                      toolbarOptions: const ToolbarOptions(
                        copy: false,
                        paste: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s'))
                      ],
                      validator: EmailValidator(
                          errorText: 'Please enter a valid email address'),
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: 'Email address'),
                      onSaved: (value) {
                        ptController.email.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 7),
                    IntlPhoneField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      disableLengthCheck: true,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'MY',
                      onChanged: (phone) {
                        print(phone);
                      },
                      // controller: ptController.phone,
                      onSaved: (value) {
                        print(value);
                        String holder = '';
                        holder = value!.completeNumber.trim();
                        holder = holder.replaceAll(RegExp(r'\+600'), '+60');
                        ptController.phone.text = holder;
                        print(ptController.phone.text);
                        // change on... dataMap side, test a bit
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Password is required!';
                        } else if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Numbers only',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      onSaved: (value) {
                        ptController.password.text = value!.trim();
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (val) => _submitAuthForm(),
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
                        onPressed: () => Get.off(const Login()),
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
