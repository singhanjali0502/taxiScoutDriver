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
      body: SizedBox(
        height: double.infinity, // Ensure Stack takes full screen height
        child: Stack(
          children: [
            Form(
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
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              }),
                          filled: true,
                          fillColor: const Color(0xffF2F3F5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          labelText: "Password",
                        ),
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
                                setState(() {
                                  confirmPVisible = !confirmPVisible;
                                });
                              }),
                          filled: true,
                          fillColor: const Color(0xffF2F3F5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          labelText: "Confirm Password",
                        ),
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
                          labelText: "OTP",
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
                              setState(() {
                                _errorMessage = null;
                                _isLoggingIn = true; // Show loader
                              });

                              String? passwordError = validatePassword(_passwordController.text);
                              String? otpError = validateOtp(_otpController.text);

                              if (passwordError != null || otpError != null) {
                                setState(() {
                                  _errorMessage = passwordError ?? otpError;
                                  _isLoggingIn = false; // Hide loader
                                });
                                return;
                              }

                              bool _resetPass = await resetPassword(
                                email: widget.email,
                                password: _passwordController.text,
                                confirmPassword: _confirmPassword.text,
                                otp: _otpController.text,
                              );

                              setState(() {
                                _isLoggingIn = false;
                                _errorMessage = _resetPass ? null : 'Invalid OTP';
                              });

                              if (_resetPass) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              }
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

            // **Full-Screen Loader Overlay**
            if (_isLoggingIn)
              Positioned.fill(
                child: Container(
                  color: Colors.black54, // Semi-transparent background
                  alignment: Alignment.center,
                  child: const Loading(), // Your Loading widget
                ),
              ),
          ],
        ),
      ),
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
