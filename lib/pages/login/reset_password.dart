import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({key, required this.email});

  String? email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool passwordVisible = false;
  bool confirmPVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children:[
          Container(
            child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/36759121.png',
                        height: MediaQuery.of(context).size.height * 0.30,
                      ),
                    ),
                    Text(
                      languages[choosenLanguage]['text_resetPasswor'],
                      style: GoogleFonts.roboto(
                          fontSize: media.width * twentysix,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                   const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            }),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        labelText: "Password",
                      ),
                      onSaved: (String? value) {},
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(confirmPVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(
                                () {
                                  confirmPVisible = !confirmPVisible;
                                },
                              );
                            }),
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        labelText: "Confirm Password",
                      ),
                      onSaved: (String? value) {},
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF2F3F5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        labelText: "Otp",
                      ),
                      onSaved: (String? value) {},
                      validator: validateOtp,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: media.width * 1 - media.width * 0.08,
                      alignment: Alignment.center,
                      child: Button(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _errorMessage =
                                validatePassword(_passwordController.text);
                            _errorMessage = validateOtp(_otpController.text);
                            setState(() {
                              _errorMessage = null;
                              _isLoggingIn = true; // Show loading indicator
                            });
                            if (_errorMessage == null) {
                              var _resetPass = resetPassword(
                                email: widget.email,
                                password: _passwordController.text,
                                confirmPassword: _confirmPassword.text,
                                otp: _otpController.text,
                              );
                              setState(() {
                                _isLoggingIn = false; // Hide loading indicator
                              });
                              if (_resetPass) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()));
                              } else {
                                setState(() {
                                  _errorMessage = 'Invalid Otp';
                                });
                              }
                            } else {
                              setState(() {
                                _errorMessage = _errorMessage;
                              });
                            }
                            setState(() {
                              _isLoggingIn = false;
                            });
                          }
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        text: languages[choosenLanguage]['text_submit'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
          ),
          if (_isLoggingIn)
            Positioned.fill(
              // This ensures it covers the entire screen
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Loading(), // Your Loading widget or custom loader
                ),
              ),
            ),
      ]),

    );
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value!.isEmpty) {
      return "OTP is required";
    }
    return null;
  }
}
