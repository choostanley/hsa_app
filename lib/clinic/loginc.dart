import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'controllers/controllers.dart';
import '/common/functions.dart';
import 'sign_upc.dart';

class Loginc extends StatefulWidget {
  const Loginc({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogincState createState() => _LogincState();
}

class _LogincState extends State<Loginc> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void initState() {
    if (drsnController.remindCompleteRegistration) {
      Future.delayed(
          const Duration(milliseconds: 1000), () => remindSnackbar());
    }
    super.initState();
  }

  void remindSnackbar() {
    blueSnackBar('An EMAIL has been sent to you',
        'Click the link provided to complete registration');
  }

  void _tryLogin() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      await drsnController.signIn();
      setState(() => _isLoading = false);
    }
  }

  final focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Login - HSA Clinic'),
      ),
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
                    AutofillGroup(
                      child: TextFormField(
                        autofocus: true,
                        controller: drsnController.email,
                        textCapitalization: TextCapitalization.none,
                        key: const ValueKey('email'),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s'))
                        ],
                        validator: EmailValidator(
                            errorText: 'Please enter a valid email address'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(focus);
                        },
                        autofillHints: const [AutofillHints.email],
                      ),
                    ),
                    TextFormField(
                      focusNode: focus,
                      controller: drsnController.password,
                      keyboardType: TextInputType.number,
                      key: const ValueKey('password'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: MinLengthValidator(6,
                          errorText: 'Password must be at least 6 digits long'),
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
                      onFieldSubmitted: (val) => _tryLogin(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () => _tryLogin(),
                        child: const Text('Login'),
                      ),
                    if (!_isLoading)
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor),
                        onPressed: () => Get.to(const SignUpc()),
                        child: const Text('Create an account'),
                      ),
                    // TextButton(
                    //   style: TextButton.styleFrom(
                    //       primary: Theme.of(context).primaryColor),
                    //   onPressed: () => Get.to(ResetPWScreen()),
                    //   child: Text('Reset Password'),
                    // ),
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
