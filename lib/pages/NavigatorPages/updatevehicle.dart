import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/service_area.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

import '../loadingPage/loading.dart';
import '../vehicleInformations/vehicle_type.dart';

class UpdateVehicle extends StatefulWidget {
   UpdateVehicle({Key? key, this.companyId, this.serviceId}) : super(key: key );
  String? companyId;
  String? serviceId;

  @override
  State<UpdateVehicle> createState() => _UpdateVehicleState();
}

class _UpdateVehicleState extends State<UpdateVehicle> {

  Future<Map<String, String>> _getStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? companyId = prefs.getString('companyId');
    String? serviceId = prefs.getString('serviceId');

    if (companyId == null || serviceId == null) {
      throw Exception("Data not found");
    }

    return {
      'companyId': companyId,
      'serviceId': serviceId,
    };
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.05,
              media.width * 0.05, media.width * 0.05),
          height: media.height * 1,
          width: media.width * 1,
          color: page,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: media.width * 0.05),
                    width: media.width * 1,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: media.width * 0.7,
                      child: Text(
                        languages[choosenLanguage]['text_updateVehicle'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)))
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Expanded(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: media.width * 0.9,
                        padding: EdgeInsets.all(media.width * 0.025),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2),
                            ],
                            color: page),
                        child: Column(
                          children: [
                            Text(
                              languages[choosenLanguage]['text_type'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Text(
                              userDetails['vehicle_type_name'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Text(
                              languages[choosenLanguage]['text_make'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Text(
                              userDetails['car_make_name'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Text(
                              languages[choosenLanguage]['text_model'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Text(
                              userDetails['car_model_name'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Text(
                              languages[choosenLanguage]['text_number'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Text(
                              userDetails['car_number'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Text(
                              languages[choosenLanguage]['text_color'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: hintColor),
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Text(
                              userDetails['car_color'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                          ],
                        ),
                      ))),

              //navigate to pick service page
              Button(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FutureBuilder(
                            future: _getStoredData(),
                            builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // Show a loading indicator while data is being retrieved
                                return const Center(child: Loading());
                              }

                              if (snapshot.hasError || !snapshot.hasData) {
                                // Handle errors or if no data is found
                                return const Center(child: Text("Failed to load data"));
                              }

                              // Retrieve data from the snapshot
                              String companyId = snapshot.data!['companyId']!;
                              String serviceId = snapshot.data!['serviceId']!;

                              return VehicleType(
                                companyId: userDetails['companyId'],
                                serviceId: serviceId,
                              );
                            },
                          ),
                        )
                    );
                  },
                  text: languages[choosenLanguage]['text_edit'])
            ],
          ),
        ),
      ),
    );
  }
}
