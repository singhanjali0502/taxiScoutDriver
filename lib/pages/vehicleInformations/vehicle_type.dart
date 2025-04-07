import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/signupPage/signup_screen.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_make.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

import '../../modals/vehicle_type.dart';
import '../onTripPage/map_page.dart';

class VehicleType extends StatefulWidget {
   VehicleType({Key? key,  this.companyId, this.serviceId, this.name, this.email, this.password, this.phNumber, this.confPassword, this.driverLicence}) : super(key: key);
  String? companyId;
  String? serviceId;
   String? name;
   String? email;
   String? password;
   String? phNumber;
   String? confPassword;
   String? driverLicence;
  @override
  State<VehicleType> createState() => _VehicleTypeState();
}

dynamic myVehicalType;
dynamic myVehicleId;
dynamic myVehicleIconFor;
dynamic vehicleTypes;

class _VehicleTypeState extends State<VehicleType> {
  bool _loaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    _fetchVehicleTypes();
    getUserDetails();
    super.initState();
  }

//get vehicle type
  Future<void> _fetchVehicleTypes() async {
    setState(() => _isLoading = true);

    try {
      VechicalType? vehicleResponse = await fetchDriverTypes();
      if (vehicleResponse != null) {
        setState(() {
          myVehicalType = vehicleResponse.driverVehicle; // Pre-selected vehicle
          myVehicleId = myVehicalType?.id;
          myVehicleIconFor = myVehicalType?.icon;
          vehicleTypes = vehicleResponse.data ?? []; // Store vehicle list
          _loaded = true;
        });
      } else {
        print('Error: No vehicle data received');
      }
    } catch (e) {
      print('Error fetching vehicle types: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery
        .of(context)
        .size;

    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: media.width * 0.08,
                right: media.width * 0.08,
                top: media.width * 0.05 + MediaQuery
                    .of(context)
                    .padding
                    .top,
              ),
              height: media.height,
              width: media.width,
              color: page,
              child: Column(
                children: [
                  // 🔹 Top Bar
                  Container(
                    width: media.width,
                    color: topBar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: media.height * 0.04),

                  // 🔹 Title
                  SizedBox(
                    width: media.width,
                    child: Text(
                      languages[choosenLanguage]['text_vehicle_type'],
                      style: GoogleFonts.roboto(
                        fontSize: media.width * twenty,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔸 Pre-selected Vehicle (Yellow Card)
                  if (myVehicalType != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      width: media.width,
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700, // Yellow background
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          (myVehicalType.icon != null)
                              ? Image.network(
                            myVehicalType.icon!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          )
                              : const SizedBox(width: 50, height: 50),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myVehicalType.name ?? "Unknown Vehicle",
                                style: GoogleFonts.roboto(
                                  fontSize: media.width * twenty,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                               "Capacity : ${myVehicalType.capacity.toString()}" ?? "Unknown Vehicle",
                                style: GoogleFonts.roboto(
                                  fontSize: media.width * twenty,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Modal : ${myVehicalType.modelName}" ?? "Unknown Vehicle",
                                style: GoogleFonts.roboto(
                                  fontSize: media.width * twenty,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Size : ${myVehicalType.size.toString()}" ?? "Unknown Vehicle",
                                style: GoogleFonts.roboto(
                                  fontSize: media.width * twenty,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                         // const Spacer(),
                         //  const Icon(Icons.check_circle, color: Colors.green)
                        ],
                      ),
                    ),

                  // 🔹 Selectable Vehicle List
                  (vehicleTypes != null && vehicleTypes.isNotEmpty)
                      ? Expanded(
                    child: ListView.builder(
                      itemCount: vehicleTypes.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicleTypes[index];
                        bool isSelected = myVehicleId == vehicle.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              myVehicleId = vehicle.id;
                              myVehicleIconFor = vehicle.icon;
                            });
                          },
                          child:
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            width: media.width,
                            decoration: BoxDecoration(
                              color: Colors.white, // Yellow background
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                (vehicle.icon != null)
                                    ? Image.network(
                                  vehicle.icon!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                )
                                    : const SizedBox(width: 50, height: 50),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicle.name ?? "Unknown Vehicle",
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Capacity : ${vehicle.capacity.toString()}" ?? "Unknown Vehicle",
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      "Modal : ${vehicle.modelName}" ?? "Unknown Vehicle",
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      "Size : ${vehicle.size.toString()}" ?? "Unknown Vehicle",
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green)
                              ],
                            ),
                          )
                        );
                      },
                    ),
                  )
                      : Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                 const Spacer(),
                  // 🔹 Next Button
                  (myVehicleId != null)
                      ? Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Button(
                      onTap: () async {
                        setState(() => _isLoading = true);

                        var registrationResult = await updateDriverCar(
                          name: userDetails['name'],
                          email: userDetails['email'],
                          phNumber: userDetails['mobile'],
                          myVehicleId: myVehicleId,
                          profile: userDetails['profile_picture'],
                          serviceId:userDetails['service_location_id'],
                        );

                        setState(() => _isLoading = false);

                        if (registrationResult == "true") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Maps()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(registrationResult.toString()),
                            ),
                          );
                        }

                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      text: languages[choosenLanguage]['text_next'],
                    ),
                  )
                      : Container(),
                ],
              ),
            ),

            // 🔹 No Internet Widget
            if (!internet)
              Positioned(
                top: 0,
                child: NoInternet(
                  onTap: () => setState(() => internetTrue()),
                ),
              ),

            // 🔹 Loading Overlay
            if (_isLoading) const Positioned(top: 0, child: Loading()),
          ],
        ),
      ),
    );
  }

}