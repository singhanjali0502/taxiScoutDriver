import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/login/reset_password.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../onTripPage/map_page.dart';
import '../vehicleInformations/vehicle_type.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoggingIn = false; // Track loading state
  final _formKey = GlobalKey<FormState>();
  final _emailRegex = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');

  // Function to handle API call and set loading state
  Future<void> _handleAPICall() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating API call with a delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Ensure the Form takes full height
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/email.png',
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          languages[choosenLanguage]['email_verify'] ?? "",
                          style: GoogleFonts.roboto(
                            fontSize: media.width * twentysix,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF2F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          labelText: "Email",
                        ),
                        validator: validateOtp,
                      ),
                      const SizedBox(height: 50),
                      Container(
                        width: media.width * 1 - media.width * 0.08,
                        alignment: Alignment.center,
                        child: Button(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              FocusManager.instance.primaryFocus
                                  ?.unfocus(); // Dismiss keyboard
                              setState(() {
                                _errorMessage = null;
                                _isLoggingIn = true; // Show loading indicator
                              });

                              // Simulate API call
                              bool resetPassword = await forgotPassword(
                                  email: _emailController.text);

                              setState(() {
                                _isLoggingIn = false; // Hide loading indicator
                              });
                              if (resetPassword) {
                                // Show dialog after successful login
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Check Your Email"),
                                      content: Text(
                                          "Please check your email for OTP verification."),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ResetPassword(
                                                  email: _emailController.text,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  _errorMessage =
                                      'Email or password is incorrect';
                                });
                              }
                            } else {
                              // Show error if validation fails
                              setState(() {
                                _errorMessage = _errorMessage;
                              });
                            }

                            // Hide loading indicator
                            setState(() {
                              _isLoggingIn = false;
                            });
                          },
                          text: languages[choosenLanguage]['text_resetPasswor'],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Display loader if API call is in progress
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
        ],
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Email is required";
    } else if (!_emailRegex.hasMatch(value)) {
      return "Invalid email format";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Otp is required";
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value!.isEmpty) {
      return "Otp is required";
    }
    return null;
  }
}
