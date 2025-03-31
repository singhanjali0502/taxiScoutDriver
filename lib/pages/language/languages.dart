import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import '../../functions/functions.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';

class Languages extends StatefulWidget {
  const Languages({Key? key}) : super(key: key);

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  late SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
    // _requestLocationPermission();
  }
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isDenied) {
      // Show an alert to ask for settings access
      _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      // Directly open settings if permanently denied
      openAppSettings();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text("Location access is required to proceed. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open phone settings
              Navigator.pop(context); // Close dialog
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }
  Future<void> _initializeLanguage() async {
    pref = await SharedPreferences.getInstance();

    // Get saved language preference
    String? savedLanguage = pref.getString('choosenLanguage');

    if (savedLanguage != null) {
      choosenLanguage = savedLanguage;
    } else {
      // If no preference is saved, get the device's locale
      Locale deviceLocale = window.locale;
      String languageCode = deviceLocale.languageCode;

      // Check if the detected language is supported; otherwise, default to 'en'
      if (languages.containsKey(languageCode)) {
        choosenLanguage = languageCode;
      } else {
        choosenLanguage = 'en'; // Default to English
      }
    }

    // Set language direction (RTL for Arabic, Urdu, Hebrew)
    languageDirection = (choosenLanguage == 'ar' || choosenLanguage == 'ur' || choosenLanguage == 'iw')
        ? 'rtl'
        : 'ltr';

    setState(() {});
  }

  // Navigate to Login page
  navigate() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
        textDirection:
        (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              media.width * 0.05, media.width * 0.05, media.width * 0.05, media.width * 0.05),
          height: media.height * 1,
          width: media.width * 1,
          color: page,
          child: Column(
            children: [
              Container(
                height: media.width * 0.11 + MediaQuery.of(context).padding.top,
                width: media.width * 1,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                color: topBar,
                child: Stack(
                  children: [
                    Container(
                      height: media.width * 0.11,
                      width: media.width * 1,
                      alignment: Alignment.center,
                      child: Text(
                        languages[choosenLanguage]['text_choose_language'] ?? "",
                        style: GoogleFonts.roboto(
                            color: textColor,
                            fontSize: media.width * sixteen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: media.width * 0.05),
              SizedBox(
                width: media.width * 0.9,
                height: media.height * 0.16,
                child: Image.asset(
                  'assets/images/chooselang.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: media.width * 0.1),

              // Language Selection List
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: languages.keys.map((i) {
                      return InkWell(
                        onTap: () async {
                          setState(() {
                            choosenLanguage = i;
                            languageDirection = (i == 'ar' || i == 'ur' || i == 'iw') ? 'rtl' : 'ltr';
                          });

                          // Save language preference
                          await pref.setString('choosenLanguage', choosenLanguage);
                          await pref.setString('languageDirection', languageDirection);
                        },
                        child: Container(
                          padding: EdgeInsets.all(media.width * 0.025),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                languagesCode.firstWhere((e) => e['code'] == i)['name'].toString(),
                                style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                              ),
                              Container(
                                height: media.width * 0.05,
                                width: media.width * 0.05,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xff222222), width: 1.2)),
                                alignment: Alignment.center,
                                child: (choosenLanguage == i)
                                    ? Container(
                                  height: media.width * 0.03,
                                  width: media.width * 0.03,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff222222)),
                                )
                                    : Container(),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Button
              if (choosenLanguage.isNotEmpty)
                Button(
                    onTap: () async {
                      await getlangid();
                      pref.setString('languageDirection', languageDirection);
                      pref.setString('choosenLanguage', choosenLanguage);
                      navigate();
                    },
                    text: languages[choosenLanguage]['text_confirm'])
            ],
          ),
        ),
      ),
    );
  }
}
