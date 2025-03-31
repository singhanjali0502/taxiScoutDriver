import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocs;
import 'package:location/location.dart';
// import 'package:location/location.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/editprofile.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/history.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loadingpage.dart';
import 'package:tagyourtaxi_driver/pages/login/get_started.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/digitalsignature.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/droplocation.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/invoice.dart';
// import 'package:tagyourtaxi_driver/pages/login/ownerregister.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/review_page.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/referral_code.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/service_area.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_color.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_make.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_model.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_number.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_type.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_year.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../modals/vehicle_type.dart';
import '../pages/NavigatorPages/fleetdocuments.dart';
import '../pages/NavigatorPages/subscriptions.dart';
import '../pages/login/ownerregister.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/local_notification.dart';
import 'geohash.dart';
import 'dart:developer' as dev;

import 'location_update_controller.dart';

//languages code
dynamic phcode;
dynamic platform;
dynamic pref;
String isActive = '';
double duration = 0.0;
AudioCache audioPlayer = AudioCache();
AudioPlayer audioPlayers = AudioPlayer();
String audio = 'audio/notification_sound.mp3';
bool internet = true;
dynamic centerCheck;

String ischeckownerordriver = '';
String transportType = '';
String smokingType = '';
String petsType = '';
String drinkingType = '';
String handicaType = '';

//base url
// String url = 'https://www.mobrilz.digital/admin/public/';
String url = 'https://admin.taxiscout24.com/';

String mapkey = 'AIzaSyAL0hd3a2l1k1uLSAxQNN511PWkguNxzE4';
String mapStyle = '';
DriverService driverService = DriverService();

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('BearerToken', token); // ✅ Save token persistently

  // ✅ Verify token is saved
  String? storedToken = prefs.getString('BearerToken');
  if (storedToken == null || storedToken.isEmpty) {
    print('❌ Token saving failed!');
  } else {
    print('✅ Token saved successfully: $storedToken');
  }
}


getDetailsOfDevice() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    rootBundle.loadString('assets/map_style.json').then((value) {
      mapStyle = value;
    });

    pref = await SharedPreferences.getInstance();
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//validate email already exist

validateEmail(email) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/driver/validate-mobile'), body: {
      'email': email,
      "role": userDetails.isNotEmpty
          ? userDetails['role'].toString()
          : ischeckownerordriver
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//lang
getlangid() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/update-my-lang'), headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'lang': choosenLanguage,
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//language code
var choosenLanguage = '';
var languageDirection = '';

List languagesCode = [
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'English (UK)', 'code': 'en-GB'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {
    'name': 'Portuguese (Portugal)',
    'code': 'pt' //pt-PT
  },
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {
    'name': 'Chinese (PRC)',
    'code': 'zh' //zh-CN
  },
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-TW'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

//upload docs

uploadDocs() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/upload/documents'));
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.files
        .add(await http.MultipartFile.fromPath('document', imageFile));
    if (documentsNeeded[choosenDocs]['has_expiry_date'] == true) {
      response.fields['expiry_date'] = expDate.toString().substring(0, 19);
    }

    if (documentsNeeded[choosenDocs]['has_identify_number'] == true) {
      response.fields['identify_number'] = docIdNumber;
    }

    response.fields['document_id'] = docsId.toString();

    var request = await response.send();

    var respon = await http.Response.fromStream(request);

    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = val['message'];
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = val['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

uploadFleetDocs(fleetid) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/upload/documents'));
    response.headers
        .addAll({'Authorization': 'Bearer $token}'});

    response.files
        .add(await http.MultipartFile.fromPath('document', fleetimageFile));

    if (fleetdocumentsNeeded[fleetchoosenDocs]['has_expiry_date'] == true) {
      response.fields['expiry_date'] = fleetexpDate.toString().substring(0, 19);
    }
    if (fleetdocumentsNeeded[fleetchoosenDocs]['has_identify_number'] == true) {
      response.fields['identify_number'] = fleetdocIdNumber;
    }

    response.fields['fleet_id'] = fleetid.toString();

    response.fields['document_id'] = fleetdocsId.toString();
    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    final val = jsonDecode(respon.body);

    if (request.statusCode == 200) {
      result = val['message'];
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = val['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//getting country code

List countries = [];
getCountryCode() async {
  dynamic result;
  try {
    final response = await http.get(Uri.parse('${url}api/v1/countries'));

    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data'];
      phcode =
          (countries.where((element) => element['default'] == true).isNotEmpty)
              ? countries.indexWhere((element) => element['default'] == true)
              : 0;
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//login firebase

String userUid = '';
var verId = '';
int? resendTokenId;
bool phoneAuthCheck = false;
dynamic credentials;

phoneAuth(String phone) async {
  try {
    credentials = null;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
        valueNotifierHome.incrementNotifier();
      },
      forceResendingToken: resendTokenId,
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verId = verificationId;
        resendTokenId = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get local bearer token

String lastNotification = '';

getLocalData() async {
  dynamic result;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    if (pref.containsKey('lastNotification')) {
      lastNotification = pref.getString('lastNotification');
    }
    if (pref.containsKey('autoAddress')) {
      var val = pref.getString('autoAddress');
      storedAutoAddress = jsonDecode(val);
    }
    if (pref.containsKey('choosenLanguage')) {
      choosenLanguage = pref.getString('choosenLanguage');
      languageDirection = pref.getString('languageDirection');

      if (choosenLanguage.isNotEmpty) {
        if (pref.containsKey('BearerToken')) {
          var tokens = pref.getString('BearerToken');

          if (tokens != null) {
            print('✅ Token retrieved successfully: $tokens'); // Debugging
            bearerToken.add(BearerClass(type: 'Bearer', token: tokens));

            var response = await getUserDetails();
            if (response == true) {
              if (userDetails['role'] != 'owner') {
                platforms.invokeMethod('login');
              }
              result = '3';
            } else if (response == false) {
              result = '2';
            }
          } else {
            print('❌ Token is null after retrieval');
            result = '2'; // Logout
          }
        } else {
          print('❌ No token found in SharedPreferences');
          result = '2'; // Logout
        }

      } else {
        result = '1';
      }
    } else {
      result = '1';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get service locations

List serviceLocations = [];

getServiceLocation() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/servicelocation'),
    );

    if (response.statusCode == 200) {
      serviceLocations = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle type






//get vehicle make

List vehicleMake = [];

getVehicleMake() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse(
          '${url}api/v1/common/car/makes?transport_type=$transportType&vehicle_type=$myVehicleIconFor'),
    );

    if (response.statusCode == 200) {
      vehicleMake = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle model

List vehicleModel = [];

getVehicleModel() async {
  dynamic res;
  dev.log(vehicleMakeId.toString(), name: "VehicleMakeID");
  try {
    final response = await http.get(
      Uri.parse('${url}api/v1/common/car/models/${vehicleMakeId.toString()}'),
    );

    if (response.statusCode == 200) {
      vehicleModel = jsonDecode(response.body)['data'];
      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//register driver

List<BearerClass> bearerToken = <BearerClass>[];

List vehicleType = [];

Future<VechicalType> getvehicleType(String serviceId, String companyId) async {
  try {
    final String baseUrl = '${url}api/v1/types/$serviceId';
    final Map<String, String> queryParams = {
      'company_id': companyId ?? "",
    };
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return VechicalType.fromJson(jsonData);
    } else {
      debugPrint('Failed to load vehicle types: ${response.body}');
      throw Exception('Failed to load vehicle types');
    }
  } catch (e) {
    debugPrint('Error fetching vehicle types: $e');
    throw e;
  }
}




Future<VechicalType?> fetchDriverTypes() async {
  final String url = 'https://admin.taxiscout24.com/api/v1/driver/types'; // ✅ Define URL
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // ✅ Added content type
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
        print('Response Data: ${jsonData['driver_vehicle']}');
        return VechicalType.fromJson(jsonData); // ✅ Extract only `driver_vehicle`
      } else {
        print('Error: Unexpected API response');
        return null;
      }
    } else {
      print('Failed: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load vehicle types');
    }
  } catch (e) {
    print('Error fetching vehicle types: $e');
    return null;
  }
}


Future<String> registerDriver({
  String? name,
  String? email,
  String? password,
  String? confPassword,
  String? phNumber,
  String? serviceId,
  String? myVehicleId,
  String? driverLicence,
  String? companyId,
}) async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    final response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/driver/register'));

    response.headers.addAll({'Content-Type': 'application/json'});

    if (proImageFile1 != null) {
      response.files.add(
          await http.MultipartFile.fromPath('profile_picture', proImageFile1));
    }
    response.fields.addAll({
      "name": name ?? "",
      "mobile": phNumber ?? "",
      "email": email ?? "",
      "password": password ?? "",
      "device_token": fcm,
      "country": countries[phcode]['dial_code'],
      "service_location_id": serviceId ?? "",
      "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
      "vehicle_type": myVehicleId ?? "",
      // "vehicle_types": '["${myVehicleId}"]',  // Make sure this is the correct format
      // "car_color": vehicleColor ?? "Red",
      // "car_number": vehicleNumber ?? "1234",
      // "vehicle_year": modelYear ?? "Frari",
      'lang': choosenLanguage ?? "",
      // 'transport_type': transportType ?? "Taxi",
      'driving_license':driverLicence ??"",
      'gender':'',
      'owner_id':companyId ?? "",
    });

    print("Request Fields: ${response.fields}"); // Debugging line

    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (request.statusCode == 200) {
      var jsonVal = jsonDecode(respon.body);

      if (ischeckownerordriver == 'driver') {
        platforms.invokeMethod('login');
      }

      String token = jsonVal['access_token'].toString();
      await saveToken(token);// Debugging

      // Fetch user details after saving token
      await getUserDetails();

      // ✅ Firebase Database Update (Ensure package is not null)
      if (package != null) {
        if (platform == TargetPlatform.android) {
          await FirebaseDatabase.instance
              .ref()
              .update({'driver_package_name': package.packageName.toString()});
        } else {
          await FirebaseDatabase.instance
              .ref()
              .update({'driver_bundle_id': package.packageName.toString()});
        }
      }

      result = 'true';
    }
    else if (respon.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    } else {
      result = 'An error occurred: $e';
    }
  }
  return result;
}

Future<String> updateDriverCar({
  String? name,
  String? email,
  String? profile,
  String? phNumber,
  String? country,
  String? myVehicleId,
  String? serviceId,
}) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var fcm = await FirebaseMessaging.instance.getToken();

    final response = http.MultipartRequest(
      'POST', Uri.parse('${url}api/v1/user/profile'),
    );

    response.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ✅ Now safe
    });

    if (proImageFile1 != null) {
      response.files.add(
        await http.MultipartFile.fromPath('profile_picture', proImageFile1),
      );
    }

    response.fields.addAll({
      "name": name ?? "",
      "email": email ?? "",
      "country": "+91",
      "mobile": phNumber ?? "",
      "vehicle_type": myVehicleId ?? "",
      // "service_location_id": serviceId ?? "",
      // "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
    });

    print("✅ Request Fields: ${response.fields}");

    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (request.statusCode == 200) {
      var jsonVal = jsonDecode(respon.body);
      print('✅ Profile Updated Successfully');

      await getUserDetails();

      result = 'true';
    } else if (respon.statusCode == 422) {
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '');
    } else {
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    } else {
      result = 'An error occurred: $e';
    }
  }
  return result;
}


// registerDriver({ String? name,
//   String? email,
//   String? password,
//   String? confPassword,
//   String? phNumber,
//   String? serviceId,
//   String? myVehicleId,
//   // String? driverLicence,
//   // String? companyId,
//
// }) async {
//   bearerToken.clear();
//   dynamic result;
//   try {
//     var token = await FirebaseMessaging.instance.getToken();
//     var fcm = token.toString();
//     final response = http.MultipartRequest(
//         'POST', Uri.parse('${url}api/v1/driver/register'));
//
//     response.headers.addAll({'Content-Type': 'application/json'});
//     // if (image != null) {
//     //   response.files.add(
//     //     await http.MultipartFile.fromPath('profile_picture', image.path),
//     //   );
//     // }
//     response.fields.addAll({
//       "name": name ?? "",
//       "mobile": phNumber ?? "",
//       "email": email ?? "",
//       "password": password ?? "",
//       "device_token": fcm,
//       "country": countries[phcode]['dial_code'],
//       "service_location_id": serviceId ?? "",
//       "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
//       "vehicle_types": myVehicleId ?? "",  // Ensure this is not null
//     });
//
//     var request = await response.send();
//     var respon = await http.Response.fromStream(request);
//
//     if (request.statusCode == 200) {
//       print('driver registered on spclties ${respon.body}');
//       var jsonVal = jsonDecode(respon.body);
//       if (ischeckownerordriver == 'driver') {
//         platforms.invokeMethod('login');
//       }
//       bearerToken.add(BearerClass(
//           type: jsonVal['token_type'].toString(),
//           token: jsonVal['access_token'].toString()));
//       pref.setString('Bearer', bearerToken[0].token);
//       await getUserDetails();
//       if (name == null || email == null || password == null || confPassword == null || phNumber == null || serviceId == null || myVehicleId == null) {
//         print('Missing required fields');
//         return;
//       }
//       if (platform == TargetPlatform.android && package != null) {
//         await FirebaseDatabase.instance
//             .ref()
//             .update({'driver_package_name': package.packageName.toString()});
//       } else if (package != null) {
//         await FirebaseDatabase.instance
//             .ref()
//             .update({'driver_bundle_id': package.packageName.toString()});
//       }
//       result = 'true';
//     } else if (respon.statusCode == 422) {
//       debugPrint(respon.body);
//       var error = jsonDecode(respon.body)['errors'];
//       result = error[error.keys.toList()[0]]
//           .toString()
//           .replaceAll('[', '')
//           .replaceAll(']', '')
//           .toString();
//     } else {
//       debugPrint(respon.body);
//       result = jsonDecode(respon.body)['message'];
//     }
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//       result = 'no internet';
//     }
//   }
//   return result;
// }

Future<bool> emailVerify({
  required String email,
  required String otp,
}) async {
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();

    var response = await http.post(
      Uri.parse('${url}api/v1/validate-email-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "device_token": fcm,
      }),
    );

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      String token = jsonVal['access_token'].toString();
      await saveToken(token);

      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }

      return true; // ✅ Always return `true` on success
    } else {
      debugPrint(response.body);
      return false; // ✅ Always return `false` on failure
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
    return false; // ✅ Always return `false` if an exception occurs
  }
}

resendOtpRegister({
  String? email,
}) async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/send-mail-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "device_token": fcm,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
loginemailVerify({
  String? email,
  String? otp,
}) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/driver/login/validate-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "otp":otp,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
resendOtpLogin({
  String? email,
}) async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/send-mail-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "device_token": fcm,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}
addDriver() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response = await http.post(Uri.parse('${url}api/v1/owner/add-fleet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "vehicle_type": myVehicleId,
          "car_make": vehicleMakeId,
          "car_model": vehicleModelId,
          "car_color": vehicleColor,
          "car_number": vehicleNumber,
        }));

    if (response.statusCode == 200) {
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//register owner

registerOwner() async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    final response =
        http.MultipartRequest('POST', Uri.parse('${url}api/v1/owner/register'));
    response.headers.addAll({'Content-Type': 'application/json'});
    if (proImageFile1 != null) {
      response.files.add(
          await http.MultipartFile.fromPath('profile_picture', proImageFile1));
    }
    response.fields.addAll({
      "name": ownerName,
      "mobile": phnumber,
      "email": ownerEmail,
      "address": companyAddress,
      "postal_code": postalCode,
      "city": city,
      "tax_number": taxNumber,
      "company_name": companyName,
      "device_token": fcm,
      "country": countries[phcode]['dial_code'],
      "service_location_id": ownerServiceLocation,
      "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
      'lang': choosenLanguage,
      'transport_type': transportType
    });
    var request = await response.send();
    var respon = await http.Response.fromStream(request);

    if (respon.statusCode == 200) {
      var jsonVal = jsonDecode(respon.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      await getUserDetails();
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'driver_bundle_id': package.packageName.toString()});
      }
      result = 'true';
    } else if (respon.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

List fleetdriverList = [];
fleetDriverDetails({fleetid, bool? isassigndriver}) async {
  dynamic result;
  fleetdriverList.clear();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse(isassigndriver == true
          ? '${url}api/v1/owner/list-drivers?fleet_id=$fleetid'
          : '${url}api/v1/owner/list-drivers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // // printWrapped(response.body);
      fleetdriverList = jsonDecode(response.body)['data'];
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

assignDriver(driverid, fleet) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response =
        await http.post(Uri.parse('${url}api/v1/owner/assign-driver/$fleet'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'driver_id': driverid}));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//request notification
List notificationHistory = [];
Map<String, dynamic> notificationHistoryPage = {};

getnotificationHistory() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      // // printWrapped(response.body);
      notificationHistory = jsonDecode(response.body)['data'];
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getNotificationPages(id) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification?$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        notificationHistory.add(element);
      });
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//delete notification
deleteNotification(id) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/delete-notification/$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      // notificationHistory = jsonDecode(response.body)['data'];
      // notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

sharewalletfun({mobile, role, amount}) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/transfer-money-from-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'mobile': mobile, 'role': role, 'amount': amount}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

fleetDriver(Map<String, dynamic> map) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response =
        await http.post(Uri.parse('${url}api/v1/owner/add-drivers'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(map));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      result = 'true';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//update referral code

updateReferral() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/update/driver/referral'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"refferal_code": referralCode}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'true';
      } else {
        debugPrint(response.body);
        result = 'false';
      }
    } else {
      debugPrint(response.body);
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get documents needed

List documentsNeeded = [];
bool enableDocumentSubmit = false;

getDocumentsNeeded() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response = await http
        .get(Uri.parse('${url}api/v1/driver/documents/needed'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      documentsNeeded = jsonDecode(response.body)['data'];
      enableDocumentSubmit = jsonDecode(response.body)['enable_submit_button'];

      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

List fleetdocumentsNeeded = [];
bool enablefleetDocumentSubmit = false;

getFleetDocumentsNeeded(fleetid) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    final response = await http.get(
        Uri.parse(
            '${url}api/v1/owner/fleet/documents/needed?fleet_id=$fleetid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      fleetdocumentsNeeded = jsonDecode(response.body)['data'];
      enablefleetDocumentSubmit =
          jsonDecode(response.body)['enable_submit_button'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}
//call firebase otp

otpCall() async {
  dynamic result;
  try {
    var otp = await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
    result = otp;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no Internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

// verify user already exist

verifyUser(String number) async {
  dynamic val;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/validate-mobile-for-login'),
        body: {"mobile": number, "role": ischeckownerordriver});

    if (response.statusCode == 200) {
      val = jsonDecode(response.body)['success'];
      if (val == true) {
        var check = await driverLogin();
        if (check == true) {
          var uCheck = await getUserDetails();
          val = uCheck;
        } else {
          val = false;
        }
      } else {
        val = false;
      }
    } else {
      debugPrint(response.body);
      val = false;
    }
  } catch (e) {
    if (e is SocketException) {
      val = 'no internet';
      internet = false;
    }
  }
  return val;
}

//driver login


Future<bool> driverLogin({String? email, String? password}) async {
  try {
    var response = await http.post(
      Uri.parse('${url}api/v1/driver/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      String token = jsonVal['access_token'].toString();

      await saveToken(token); // ✅ Save token globally
      getUserDetails();
      return true;
    } else {
      print('❌ Login Failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Error during login: $e');
    return false;
  }
}


forgotPassword({
  String? email,
}) async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/password/forgot'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "user_type":"driver"
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// reset password
resetPassword({
  String? email,
  String? password,
  String? confirmPassword,
  String? otp,
}) async {
  dynamic result;
  try {
    var token = await FirebaseMessaging.instance.getToken();
    var fcm = token.toString();
    var response = await http.post(Uri.parse('${url}api/v1/password/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email":email,
          "password":password,
          "password_confirmation":confirmPassword,
          "otp":otp,
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
      if (platform == TargetPlatform.android && package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_package_name': package.packageName.toString()});
      } else if (package != null) {
        await FirebaseDatabase.instance
            .ref()
            .update({'user_bundle_id': package.packageName.toString()});
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// background(){
//   isBackground = true;
//   valueNotifierHome.incrementNotifier();
// }

Map<String, dynamic> userDetails = {};
List tripStops = [];
bool isBackground = false;

void startTimer() {
  Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
    // Code snippet to run every 2 seconds
    await getUserDetails();
  });
}



getUserDetails() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');

  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      userDetails = jsonDecode(response.body)['data'];
      if (userDetails['notifications_count'] != 0 &&
          userDetails['notifications_count'] != null) {
        valueNotifierNotification.incrementNotifier();
      }
      var transportType = userDetails['transport_type'];
      if (transportType != null) {
        // userDetails['transport_type'] is not null, so assign it to transportType
        transportType = transportType.toString(); // Optional if 'transport_type' can be other types than String
      } else {
        transportType = "";
      }
      if (userDetails['role'] != 'owner') {
        if (userDetails['sos']['data'] != null) {
          sosData = userDetails['sos']['data'];
        }


        if (userDetails['onTripRequest'] != null) {
          driverReq = userDetails['onTripRequest']['data'];


          if (payby == 0 && driverReq['is_paid'] == 1) {
            payby = 1;
            audioPlayer.play(audio);
          }


          if (driverReq['is_driver_arrived'] == 1 &&
              driverReq['is_trip_start'] == 0 &&
              arrivedTimer == null &&
              driverReq['is_rental'] != true) {
            waitingBeforeStart();
          }
          if (driverReq['is_completed'] == 0 &&
              driverReq['is_trip_start'] == 1 &&
              rideTimer == null &&
              driverReq['is_rental'] != true) {
            waitingAfterStart();
          }


          if (driverReq['accepted_at'] != null) {
            getCurrentMessagesUser();
            getCurrentMessagesCompany();
          }
          tripStops =
          userDetails['onTripRequest']['data']['requestStops']['data'];
          valueNotifierHome.incrementNotifier();
        } else if (userDetails['metaRequest'] != null) {
          driverReject = false;
          userReject = false;
          driverReq = userDetails['metaRequest']['data'];
          tripStops =
          userDetails['metaRequest']['data']['requestStops']['data'];


          if (duration == 0 || duration == 0.0) {
            if (isBackground == true && platform == TargetPlatform.android) {
              platforms.invokeMethod('awakeapp');
            }
            duration = double.parse(
                userDetails['trip_accept_reject_duration_for_driver']
                    .toString());
            sound();
          }


          valueNotifierHome.incrementNotifier();
        } else {
          duration = 0;
          if (driverReq.isNotEmpty) {
            audioPlayer.play(audio);
          }
          chatList.clear();
          driverReq = {};
          valueNotifierHome.incrementNotifier();
        }


        if (userDetails['active'] == false) {
          isActive = 'false';
        } else {
          isActive = 'true';
        }
      }
      result = true;
    } else if (response.statusCode == 401) {
      userLogout();
      return 404;
     }

    else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}




class BearerClass {
  final String type;
  final String token;
  BearerClass({required this.type, required this.token});

  BearerClass.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        token = json['token'];

  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

Map<String, dynamic> driverReq = {};
bool userReject = false;

class ValueNotifying {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifier = ValueNotifying();

class ValueNotifyingHome {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingNotification {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifierHome = ValueNotifying();
ValueNotifying valueNotifiercheck = ValueNotifying();
ValueNotifyingNotification valueNotifierNotification =
    ValueNotifyingNotification();

//driver online offline status
// driverStatus() async {
//   dynamic result;
//   try {
//     var response = await http.post(
//       Uri.parse('${url}api/v1/driver/online-offline'),
//       headers: {
//         'Authorization': 'Bearer ${bearerToken[0].token}',
//         'Content-Type': 'application/json',  // Added Content-Type
//       },
//       body: jsonEncode({
//         "latitude": center.latitude,  // Ensure these are numbers
//         "longitude": center.longitude,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       userDetails = jsonDecode(response.body)['data'];
//       result = true;
//       if (userDetails['active'] == false) {
//         userInactive();
//       } else {
//         userActive();
//       }
//       valueNotifierHome.incrementNotifier();
//     } else {
//       debugPrint(response.body);
//       result = false;
//     }
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//       result = 'no internet';
//     }
//   }
//   return result;
// }

const platforms = MethodChannel('flutter.app/awake');

//update driver location in firebase

Location location = Location();

currentPositionUpdate() async {
  geolocs.LocationPermission permission;
  GeoHasher geo = GeoHasher();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (userDetails.isNotEmpty && userDetails['role'] == 'driver') {
      serviceEnabled =
      await geolocs.GeolocatorPlatform.instance.isLocationServiceEnabled();
      permission = await geolocs.GeolocatorPlatform.instance.checkPermission();

      if (userDetails['active'] == true &&
          serviceEnabled == true &&
          permission != geolocs.LocationPermission.denied &&
          permission != geolocs.LocationPermission.deniedForever) {

        if (driverReq.isEmpty) {
          if (requestStreamStart == null ||
              requestStreamStart?.isPaused == true) {
            streamRequest();
          }
        } else if (driverReq.isNotEmpty && driverReq['accepted_at'] != null) {
          if (rideStreamStart == null ||
              rideStreamStart?.isPaused == true ||
              rideStreamChanges == null ||
              rideStreamChanges?.isPaused == true) {
            streamRide();
          }
        }

        if (positionStream == null || positionStream!.isPaused) {
          positionStreamData();
        }

        final firebase = FirebaseDatabase.instance.ref();

        try {
          firebase.child('drivers/${userDetails['id']}').update({
            'bearing': heading,
            'date': DateTime.now().toString(),
            'id': userDetails['id'],
            'g': geo.encode(double.parse(center.longitude.toString()),
                double.parse(center.latitude.toString())),
            'is_active': userDetails['active'] == true ? 1 : 0,
            'is_available': userDetails['available'],
            'l': {'0': center.latitude, '1': center.longitude},
            'mobile': userDetails['mobile'],
            'name': userDetails['name'],
            'vehicle_type_icon': userDetails['vehicle_type_icon_for'],
            'updated_at': ServerValue.timestamp,
            'vehicle_number': userDetails['car_number'],
            'vehicle_type_name': userDetails['car_make_name'],
            'vehicle_type': userDetails['vehicle_type_id'],
            'ownerid': userDetails['owner_id'],
            'service_location_id': userDetails['service_location_id'],
            'transport_type': userDetails['transport_type']
          });

          // ✅ Send Notification when a new ride request is assigned
          if (driverReq.isNotEmpty) {
            if (driverReq['accepted_at'] != null &&
                driverReq['is_completed'] == 0) {
              requestDetailsUpdate(
                  double.parse(heading.toString()),
                  double.parse(center.latitude.toString()),
                  double.parse(center.longitude.toString()));

              // 🔔 Show Local Notification for Ride Update
              // LocalNotificationService.showLocalNotification(
              //   title: "New Ride Assigned",
              //   body: "You have a new ride request. Please check your app.",
              //   payload: driverReq,
              // );
            }
          }

          valueNotifierHome.incrementNotifier();
        } catch (e) {
          if (e is SocketException) {
            internet = false;
            valueNotifierHome.incrementNotifier();
          }
        }
      }

      // ✅ Notify driver if their approval status changes
      if (userDetails['role'] == 'driver') {
        var driverState = await FirebaseDatabase.instance
            .ref('drivers/${userDetails['id']}')
            .get();

        if (driverState.child('approve').value == 0 &&
            userDetails['approve'] == true) {
          await getUserDetails();
          valueNotifierHome.incrementNotifier();
          audioPlayer.play(audio);

          // 🔔 Send Notification for Approval Change
          LocalNotificationService.showLocalNotification(
            title: "Account Approval Revoked",
            body: "Your account approval has been revoked. Please contact support.", payload: {},
          );
        } else if (driverState.child('approve').value == 1 &&
            userDetails['approve'] == false) {
          await getUserDetails();
          valueNotifierHome.incrementNotifier();
          audioPlayer.play(audio);

          // 🔔 Notify about re-approval
          LocalNotificationService.showLocalNotification(
            title: "Account Approved",
            body: "Your account has been approved. You can now accept rides.", payload: {},
          );
        }
      }
    }
  });
}


//add request details in firebase realtime database

List latlngArray = [];
dynamic lastLat;
dynamic lastLong;
dynamic totalDistance;

requestDetailsUpdate(
  double bearing,
  double lat,
  double lng,
) async {
  final firebase = FirebaseDatabase.instance.ref();
  if (driverReq['is_trip_start'] == 1 && driverReq['is_completed'] == 0) {
    if (totalDistance == null) {
      var dist = await FirebaseDatabase.instance
          .ref('requests/${driverReq['id']}')
          .get();
      var array = await FirebaseDatabase.instance
          .ref('requests/${driverReq['id']}')
          .get();
      if (dist.child('distance').value != null) {
        totalDistance = dist.child('distance').value;
      }
      if (array.child('lat_lng_array').value != null) {
        latlngArray =
            jsonDecode(jsonEncode(array.child('lat_lng_array').value));
        lastLat = latlngArray[latlngArray.length - 1]['lat'];
        lastLong = latlngArray[latlngArray.length - 1]['lng'];
      }
    }
    if (latlngArray.isEmpty) {
      latlngArray.add({'lat': lat, 'lng': lng});
      lastLat = lat;
      lastLong = lng;
    } else {
      var distance = await calculateDistance(lastLat, lastLong, lat, lng);
      if (distance >= 150.0) {
        latlngArray.add({'lat': lat, 'lng': lng});
        lastLat = lat;
        lastLong = lng;

        if (totalDistance == null) {
          totalDistance = distance / 1000;
        } else {
          totalDistance = ((totalDistance * 1000) + distance) / 1000;
        }
      }
    }
  }

  try {
    firebase.child('requests/${driverReq['id']}').update({
      'bearing': bearing,
      'distance': (totalDistance == null) ? 0.0 : totalDistance,
      'driver_id': userDetails['id'],
      'user_id': driverReq['userDetail']['data']['id'],
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': (driverReq['is_completed'] == 0) ? false : true,
      'lat': lat,
      'lng': lng,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': (driverReq['is_driver_arrived'] == 0) ? "0" : "1",
      'trip_start': (driverReq['is_trip_start'] == 0) ? "0" : "1",
      'vehicle_type_icon': userDetails['vehicle_type_icon_for'],
      'transport_type': userDetails['transport_type']
    });
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//calculate distance

calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

userInactive() {
  final firebase = FirebaseDatabase.instance.ref();
  firebase.child('drivers/${userDetails['id']}').update({
    'is_active': 0,
  });
}

userActive() {
  final firebase = FirebaseDatabase.instance.ref();
  firebase.child('drivers/${userDetails['id']}').update({
    'is_active': 1,
    'l': {'0': center.latitude, '1': center.longitude},
    'updated_at': ServerValue.timestamp,
    'is_available': userDetails['available'],
  });
}

calculateIdleDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

//driver request accept

requestAccept() async {
  dev.log("${{'request_id': driverReq['id'], 'is_accept': 1}}",
      name: "Accept Request===============>");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 1}));

    if (response.statusCode == 200) {
      // AwesomeNotifications().cancel(7425);

      if (jsonDecode(response.body)['message'] == 'success') {
        if (audioPlayers.state != PlayerState.STOPPED) {
          audioPlayers.stop();
          audioPlayers.dispose();
        }
        dropDistance = '';

        await getUserDetails();

        if (driverReq.isNotEmpty) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/${userDetails['id']}')
              .update({'is_available': false});
          duration = 0;
          requestStreamStart?.cancel();
          requestStreamStart = null;
          requestStreamEnd?.cancel();
          requestStreamEnd = null;
          if (rideStreamStart == null ||
              rideStreamStart?.isPaused == true ||
              rideStreamChanges == null ||
              rideStreamChanges?.isPaused == true) {
            streamRide();
          }
          requestDetailsUpdate(double.parse(heading.toString()),
              center.latitude, center.longitude);
        }
        valueNotifierHome.incrementNotifier();
        FirebaseDatabase.instance
            .ref('requests/${driverReq['id']}')
            .remove();
      }
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//driver request reject

bool driverReject = false;

requestReject() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 0}));

    if (response.statusCode == 200) {
      // AwesomeNotifications().cancel(7425);
      if (jsonDecode(response.body)['message'] == 'success') {
        if (audioPlayers.state != PlayerState.STOPPED) {
          audioPlayers.stop();
          audioPlayers.dispose();
        }
        driverReject = true;
        await getUserDetails();
        duration = 0;
        userActive();
        valueNotifierHome.incrementNotifier();
      }
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

audioPlay() async {
  audioPlayers = await audioPlayer.play('audio/request_sound.mp3');
}

//sound

sound() async {
  audioPlay();

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (duration > 0.0 &&
        driverReq['accepted_at'] == null &&
        driverReq.isNotEmpty) {
      duration--;

      if (audioPlayers.state == PlayerState.COMPLETED) {
        audioPlay();
      }
      valueNotifierHome.incrementNotifier();
    } else if (driverReq.isNotEmpty &&
        driverReq['accepted_at'] == null &&
        duration <= 0.0) {
      timer.cancel();
      if (audioPlayers.state != PlayerState.STOPPED) {
        audioPlayers.stop();
        audioPlayers.dispose();
      }
      Future.delayed(const Duration(seconds: 2), () {
        requestReject();
      });
      duration = 0;
    } else {
      if (audioPlayers.state != PlayerState.STOPPED) {
        audioPlayers.stop();
        audioPlayers.dispose();
      }
      timer.cancel();
      duration = 0;
    }
  });
}

//driver arrived

driverArrived() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/arrived'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id']}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'driver_arrived') {
        waitingBeforeTime = 0;
        waitingTime = 0;
        await getUserDetails();
        FirebaseDatabase.instance
            .ref('requests')
            .child(driverReq['id'])
            .update({'trip_arrived': '1'});
        valueNotifierHome.incrementNotifier();
      }
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//opening google map

openMap(lat, lng) async {
  try {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//trip start with otp

tripStart() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng'],
          'ride_otp': driverOtp
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(driverReq['id'])
          .update({'trip_start': '1'});
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//trip start without otp

tripStartDispatcher() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng']
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(driverReq['id'])
          .update({'trip_start': '1'});
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

class AddressList {
  String address;
  LatLng latlng;
  String id;

  AddressList({required this.id, required this.address, required this.latlng});
}

Map etaDetails = {};

//eta request

etaRequest() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'ride_type': 1
        }));

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      result = true;
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] ==
          "service not available with this location") {
        serviceNotAvailable = true;
      }
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//geocodeing location

geoCodingForLatLng(placeid) async {
  dynamic location;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeid&key=$mapkey'));

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body)['result']['geometry']['location'];
      location = LatLng(val['lat'], val['lng']);
    } else {
      debugPrint(response.body);
    }
    return location;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//create instant ride

//create request

createRequest(name, phone) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/request/create-instant-ride'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'ride_type': 1,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'drop_address': addressList.firstWhere((e) => e.id == 'drop').address,
          'name': name,
          'mobile': phone
        }));
    if (response.statusCode == 200) {
      // print(response.body);
      await getUserDetails();
      result = 'success';
      // valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);

      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get auto fill address

List storedAutoAddress = [];
List addAutoFill = [];

getAutoAddress(input, sessionToken, lat, lng) async {
  dynamic response;
  var countryCode = userDetails['country_code'];
  try {
    if (userDetails['enable_country_restrict_on_map'] == '1' &&
        userDetails['country_code'] != null) {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&location=$lat%2C$lng&radius=2000&components=country:$countryCode&key=$mapkey&sessiontoken=$sessionToken'));
    } else {
      response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&library=places&key=$mapkey&sessiontoken=$sessionToken'));
    }
    if (response.statusCode == 200) {
      addAutoFill = jsonDecode(response.body)['predictions'];
      // ignore: avoid_function_literals_in_foreach_calls
      addAutoFill.forEach((element) {
        if (storedAutoAddress
            .where((e) =>
                e['description'].toString().toLowerCase() ==
                element['description'].toString().toLowerCase())
            .isEmpty) {
          storedAutoAddress.add(element);
        }
      });
      pref.setString('autoAddress', jsonEncode(storedAutoAddress).toString());
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

geoCoding(double lat, double lng) async {
  dynamic result;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'));

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body);
      result = val['results'][0]['formatted_address'];
    } else {
      debugPrint(response.body);
      result = '';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//ending trip

endTrip() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    await requestDetailsUpdate(
        double.parse(heading.toString()), center.latitude, center.longitude);
    var dropAddress = await geoCoding(center.latitude, center.longitude);
    var db = await FirebaseDatabase.instance
        .ref('requests/${driverReq['id']}')
        .get();

    double dist = double.parse(
        double.parse(db.child('distance').value.toString()).toStringAsFixed(2));
    var reqId = driverReq['id'];

    final firebase = FirebaseDatabase.instance.ref();
    firebase.child('requests/${driverReq['id']}').update({
      'bearing': heading,
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': false,
      'lat': center.latitude,
      'lng': center.longitude,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': "1",
      'trip_start': "1",
    });

    var response = await http.post(Uri.parse('${url}api/v1/request/end'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'distance': dist,
          'before_arrival_waiting_time': 0,
          'after_arrival_waiting_time': 0,
          'drop_lat': center.latitude,
          'drop_lng': center.longitude,
          'drop_address': dropAddress,
          'before_trip_start_waiting_time': (waitingBeforeTime != null &&
                  waitingBeforeTime > 60 &&
                  driverReq['is_rental'] != true)
              ? (waitingBeforeTime / 60).toInt()
              : 0,
          'after_trip_start_waiting_time': (waitingAfterTime != null &&
                  waitingAfterTime > 60 &&
                  driverReq['is_rental'] != true)
              ? (waitingAfterTime / 60).toInt()
              : 0
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      FirebaseDatabase.instance
          .ref('requests')
          .child(reqId)
          .update({'is_completed': true});
      totalDistance = null;
      lastLat = null;
      lastLong = null;
      waitingTime = null;
      waitingBeforeTime = null;
      waitingAfterTime = null;
      latlngArray.clear();
      polyList.clear();
      chatList.clear();
      driverOtp = '';
      waitingAfterTime = null;
      waitingBeforeTime = null;
      waitingTime = null;

      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// upload drop goods image

uploadSignatureImage() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/request/upload-proof'));
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.files.add(
        await http.MultipartFile.fromPath('proof_image', signatureFile.path));
    response.fields['after_unload'] = '1';
    response.fields['request_id'] = driverReq['id'];
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      await endTrip();
      result = 'success';
    } else {
      debugPrint(val);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

dynamic heading = 0.0;

//get polylines

List<LatLng> polyList = [];
String dropDistance = '';

getPolylines() async {
  polyList.clear();
  String pickLat;
  String pickLng;
  String dropLat;
  String dropLng;
  if (tripStops.isEmpty) {
    pickLat = driverReq['pick_lat'].toString();
    pickLng = driverReq['pick_lng'].toString();
    dropLat = driverReq['drop_lat'].toString();
    dropLng = driverReq['drop_lng'].toString();
    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
      if (response.statusCode == 200) {
        var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']
            ['points'];
        dropDistance = jsonDecode(response.body)['routes'][0]['legs'][0]
            ['distance']['text'];

        decodeEncodedPolyline(steps);
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  } else {
    for (var i = 0; i < tripStops.length; i++) {
      if (i == 0) {
        pickLat = driverReq['pick_lat'].toString();
        pickLng = driverReq['pick_lng'].toString();
        dropLat = tripStops[i]['latitude'].toString();
        dropLng = tripStops[i]['longitude'].toString();
      } else {
        pickLat = tripStops[i - 1]['latitude'].toString();
        pickLng = tripStops[i - 1]['longitude'].toString();
        dropLat = tripStops[i]['latitude'].toString();
        dropLng = tripStops[i]['longitude'].toString();
      }
      try {
        var response = await http.get(Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
        if (response.statusCode == 200) {
          var steps = jsonDecode(response.body)['routes'][0]
              ['overview_polyline']['points'];

          decodeEncodedPolyline(steps);
        } else {
          debugPrint(response.body);
        }
      } catch (e) {
        if (e is SocketException) {
          internet = false;
        }
      }
    }
  }

  return polyList;
}

// Set<Polyline> historyPolyLine = {};
// List<PointLatLng> decodeEncodedHistoryPolyline(
//     String encoded, List<LatLng> twoPoints) {

//   List<PointLatLng> poly = [];
//   int index = 0, len = encoded.length;
//   int lat = 0, lng = 0;

//   while (index < len) {
//     int b, shift = 0, result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lat += dlat;

//     shift = 0;
//     result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lng += dlng;
//     LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
//     polyList.add(p);
//   }

//   if (polyList != twoPoints) {
//     historyPolyLine.add(Polyline(
//       polylineId: const PolylineId('1'),
//       visible: true,
//       color: const Color(0xffFD9898),
//       width: 4,
//       points: polyList,
//     ));
//   }

//   valueNotifierHome.incrementNotifier();
//   return poly;
// }

//polyline decode

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  polyline.clear();
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }
  polyline.add(Polyline(
    polylineId: const PolylineId('1'),
    visible: true,
    color: const Color(0xffFD9898),
    width: 4,
    points: polyList,
  ));
  valueNotifierHome.incrementNotifier();
  return poly;
}

/// Note instead of using the class,
/// you can use Google LatLng() by importing it from their library.
class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),

        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

//add user rating

userRating() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/rating'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'rating': review,
          'comment': feedback
        }));
    if (response.statusCode == 200) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/${userDetails['id']}')
          .update({'is_available': true});
      await getUserDetails();
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//making call to user

makingPhoneCall(phnumber) async {
  var mobileCall = 'tel:$phnumber';
  if (await canLaunch(mobileCall)) {
    await launch(mobileCall);
  } else {
    throw 'Could not launch $mobileCall';
  }
}

//request cancel by driver

cancelRequestDriver(reason) async {
  dev.log("${{'request_id': driverReq['id'], 'custom_reason': reason}}",
      name: "Aquib Raw");
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/request/cancel/by-driver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'request_id': driverReq['id'], 'custom_reason': reason}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        await FirebaseDatabase.instance
            .ref()
            .child('requests/${driverReq['id']}')
            .update({'cancelled_by_driver': true});
        result = true;
        await getUserDetails();
        userActive();
        valueNotifierHome.incrementNotifier();
      } else {
        result = false;
      }
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//sos data
List sosData = [];

getSosData(lat, lng) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/common/sos/list/$lat/$lng'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      sosData = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

// chat between driver and company

List chatList = [];

Future<List<dynamic>> getCurrentMessagesCompany() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');

  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/chat-history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true) {
        // Ensure 'data' is always a valid list
        List<dynamic> newChatList = responseBody['data'] ?? [];

        // Check if new messages arrived
        if (chatList.where((element) => element['from_type'] == 1).length !=
            newChatList.where((element) => element['from_type'] == 1).length) {
          audioPlayer.play(audio);
        }

        chatList = newChatList;
        valueNotifierHome.incrementNotifier();
        return chatList; // ✅ Return the chat messages
      }
    } else {
      debugPrint("Error Response: ${response.body}");
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
    debugPrint("Error fetching messages: $e");
  }

  return []; // ✅ Always return a valid list
}



sendMessageCompany(chat) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/driver/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'message': chat}));
    if (response.statusCode == 200) {
      getCurrentMessagesCompany();
      // FirebaseDatabase.instance
      //     .ref('requests/${driverReq['id']}')
      //     .update({'message_by_driver': chatList.length});
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

messageSeenCompany() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  var response = await http.post(Uri.parse('${url}api/v1/driver/seen'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': driverReq['id']}));
  if (response.statusCode == 200) {
    getCurrentMessagesCompany();
  } else {
    debugPrint(response.body);
  }
}

// chat between user and driver
List chatListUser = [];
 getCurrentMessagesUser() {
  if (driverReq['id'] == null) {
    print("❌ Driver request ID is null. Cannot fetch messages.");
    return;
  }



  DatabaseReference chatRef = FirebaseDatabase.instance.ref("messages/${driverReq['id']}");

  // ✅ Cancel previous listener to prevent duplicates
  messageStream?.cancel();

  // ✅ Listen for new messages in real-time
  messageStream = chatRef.onChildAdded.listen((event) {
    if (event.snapshot.exists) {
      Map<String, dynamic> messageData = Map<String, dynamic>.from(event.snapshot.value as Map);

      print("📩 New Message Received: ${messageData['message']} from ${messageData['sender']}");

      // ✅ Prevent duplicate messages using unique ID
      if (!chatListUser.any((msg) => msg['id'] == messageData['id'])) {
        chatListUser.add(messageData);
        valueNotifierHome.incrementNotifier();

        // ✅ Update message as "Seen" if it's from the driver
        if (messageData['sender'] == "user" && messageData['seen'] == 0) {
          chatRef.child(event.snapshot.key!).update({"seen": 1});
          print("👀 Message marked as seen.");
        }

        // ✅ Show notification only if the message is from the driver
        if (messageData['sender'] == "user") {
          LocalNotificationService.showLocalNotification(
            title: "New Message from Driver",
            body: messageData['message'],
            payload: messageData,
          );

          // ✅ Play sound for new messages
          audioPlayer.play(audio);
        }
      } else {
        print("🚫 Duplicate message detected. Ignoring.");
      }
    }
  }, onError: (error) {
    print("🚨 Error listening for messages: $error");
  });
}


Future<void> sendMessageForDriver(String chat) async {
  try {
    // ✅ Ensure the request ID exists
    if (driverReq['id'] == null) {
      print("❌ Request ID is null. Cannot send message.");
      return;
    }

    // ✅ Generate Unique Message ID
    String messageId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ Store Message in Firebase Realtime Database
    DatabaseReference chatRef =
    FirebaseDatabase.instance.ref("messages").child(driverReq['id']);

    print("🚀 Sending message to Firebase...");

    await chatRef.push().set({
      "message": chat,
      "sender": "driver",
      "timestamp": ServerValue.timestamp,
      "id": messageId,
      "from_type": 2, // 1 = User, 2 = Driver
      "request_id": driverReq["id"],
      "driver_id": userDetails['id'],  // ✅ Fixed this
      "delivered": 0,
      "seen": 0,
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String(),
      "message_status": "sent",
      "converted_created_at": formatTime(DateTime.now()),
    });

    print("✅ Message sent successfully!");

    // ✅ Notify User about the New Message
    FirebaseDatabase.instance.ref('requests/${driverReq['id']}').update({
      'message_by_driver': chatListUser.length + 1, // Increment message count
    });

    // ✅ Add Message to Local Chat List for Instant UI Update
    // chatListUser.add({
    //   'message': chat,
    //   'from_type': 2, // Driver
    //   'converted_created_at': formatTime(DateTime.now()),
    // });

    // ✅ Update UI
    valueNotifiercheck.incrementNotifier();
  } catch (e) {
    print("🚨 Error sending message: ${e.toString()}");
  }
}

String formatTime(DateTime time) {
  return "${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
}


messageSeenUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  var response = await http.post(Uri.parse('${url}api/v1/request/seen'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': driverReq['id']}));
  if (response.statusCode == 200) {
    getCurrentMessagesUser();
  } else {
    debugPrint(response.body);
  }
}

//cancellation reason
List cancelReasonsList = [];
cancelReason(reason) async {
  dev.log(
      "${url}api/v1/common/cancallation/reasons?arrived=$reason?transport_type=${userDetails['transport_type']}",
      name: "Cancel Reason here!=================>");
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse(
          '${url}api/v1/common/cancallation/reasons?arrived=$reason?transport_type=${userDetails['transport_type']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      cancelReasonsList = jsonDecode(response.body)['data'];
      result = true;
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//open url in browser

openBrowser(browseUrl) async {
  try {
    if (await canLaunch(browseUrl)) {
      await launch(browseUrl);
    } else {
      throw 'Could not launch $browseUrl';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//manage vehicle

List vehicledata = [];

getVehicleInfo() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/owner/list-fleets'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      // // printWrapped(response.body);
      result = 'success';
      vehicledata = jsonDecode(response.body)['data'];
    } else {
      debugPrint(vehicledata.toString());
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

deletefleetdriver(driverid) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/owner/delete-driver/$driverid'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/$driverid')
          .update({'is_deleted': 1});
      result = 'success';
    } else {
      debugPrint(vehicledata.toString());
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//update driver vehicle

updateVehicle() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/user/driver-profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "service_location_id": myServiceId,
              "is_company_driver": false,
              "vehicle_type": myVehicleId,
              "car_make": vehicleMakeId,
              "car_model": vehicleModelId,
              "car_color": vehicleColor,
              "car_number": vehicleNumber,
              "vehicle_year": modelYear
            }));
    debugPrint("body ${jsonEncode({
          "service_location_id": myServiceId,
          "is_company_driver": false,
          "vehicle_type": myVehicleId,
          "car_make": vehicleMakeId,
          "car_model": vehicleModelId,
          "car_color": vehicleColor,
          "car_number": vehicleNumber,
          "vehicle_year": modelYear
        })}");
    debugPrint('token ${bearerToken[0].token}');
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//edit user profile

updateProfile(name, email) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.files.add(
        await http.MultipartFile.fromPath('profile_picture', proImageFile));
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(val);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

updateProfileWithoutImage(name, email) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('${url}api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else if (request.statusCode == 422) {
      debugPrint(respon.body);
      var error = jsonDecode(respon.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(respon.body);
      result = jsonDecode(respon.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

//get faq
List faqData = [];

getFaqData(lat, lng) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  dynamic result;
  dev.log("${url}api/v1/common/faq/list/$lat/$lng", name: "FAQ List");
  dev.log("Bearer ${bearerToken[0].token}");
  try {
    var response = await http
        .get(Uri.parse('${url}api/v1/common/faq/list/$lat/$lng'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      faqData = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

List<SubscriptionModel> packages = [];
getVipPackages() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  dynamic result;
  dev.log("${url}api/v1/common/vip-driver-plans", name: "VIP List");
  dev.log("Bearer ${bearerToken[0].token}");
  try {
    var response = await http
        .get(Uri.parse('${url}api/v1/common/vip-driver-plans'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      var responseDecoded = jsonDecode(response.body);

      dev.log("$responseDecoded", name: "JSON Response");
      packages.clear();

      responseDecoded['data'].forEach((item) {
        packages.add(SubscriptionModel.fromJson(item));
      });

      dev.log("$packages", name: "Subscription Model");

      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

//purchase VIP Package
purchaseVIPPackage(String planId) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/vip-plan-subscription'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'driverid': userDetails['id'], 'planid': planId}));

    if (response.statusCode == 200) {
      dev.log("${response.body}", name: "Aquib====================>");
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map userSubscriptionDetail = {};
getSubscriptionDetails() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/driver/vip-driver-detail'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'driverid': userDetails['id']}));

    if (response.statusCode == 200) {
      userSubscriptionDetail = jsonDecode(response.body)['data'];
      dev.log("${userSubscriptionDetail}", name: "USer Data");
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//request history
List myHistory = [];
Map<String, dynamic> myHistoryPage = {};

getHistory(id) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      myHistory = jsonDecode(response.body)['data'];
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getHistoryPages(id) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        myHistory.add(element);
      });
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//get wallet history

Map<String, dynamic> walletBalance = {};
List walletHistory = [];
Map<String, dynamic> walletPages = {};

//  printWrapped(String text) {
//   final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
//   pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
// }

getWalletHistory() async {
  walletBalance.clear();
  walletHistory.clear();
  walletPages.clear();
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      walletHistory = walletBalance['wallet_history']['data'];
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getWalletHistoryPage(page) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/wallet/history?page=$page'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      List list = walletBalance['wallet_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        walletHistory.add(element);
      });
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//add sos

addSos(name, number) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/common/sos/store'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'name': name, 'number': number}));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//remove sos

deleteSos(id) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/common/sos/delete/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get user referral

Map<String, dynamic> myReferralCode = {};
getReferral() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.get(Uri.parse('${url}api/v1/get/referral'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      result = 'success';
      myReferralCode = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//stripe payment

Map<String, dynamic> stripeToken = {};

getStripePayment(money) async {
  dynamic results;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/stripe/intent'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      results = 'success';
      stripeToken = jsonDecode(response.body)['data'];
    } else {
      debugPrint(response.body);
      results = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

//stripe add money

addMoneyStripe(amount, nonce) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/stripe/add/money'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//paystack payment
Map<String, dynamic> paystackCode = {};

getPaystackPayment(money) async {
  dynamic results;
  paystackCode.clear();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/payment/paystack/initialize'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == false) {
        results = jsonDecode(response.body)['message'];
      } else {
        // // printWrapped(response.body);
        results = 'success';
        paystackCode = jsonDecode(response.body)['data'];
      }
    } else {
      debugPrint(response.body);
      results = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

addMoneyPaystack(amount, nonce) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/paystack/add-money'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      paystackCode.clear();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//flutterwave

addMoneyFlutterwave(amount, nonce) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/flutter-wave/add-money'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//razorpay

addMoneyRazorpay(amount, nonce) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/razerpay/add-money'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      await getUserDetails();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//braintree

dynamic brainTreeToken;

getBrianTreeToken() async {
  brainTreeToken = null;
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/payment/braintree/client/token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        brainTreeToken = jsonDecode(response.body)['data']['client_token'];
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//cashfree

Map<String, dynamic> cftToken = {};

getCfToken(money, currency) async {
  cftToken.clear();
  cfSuccessList.clear();
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/generate-cftoken'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'order_amount': money, 'order_currency': currency}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['status'] == 'OK') {
        cftToken = jsonDecode(response.body);
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String, dynamic> cfSuccessList = {};

cashFreePaymentSuccess() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/cashfree/add-money-to-wallet-webhooks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'orderId': cfSuccessList['orderId'],
          'orderAmount': cfSuccessList['orderAmount'],
          'referenceId': cfSuccessList['referenceId'],
          'txStatus': cfSuccessList['txStatus'],
          'paymentMode': cfSuccessList['paymentMode'],
          'txMsg': cfSuccessList['txMsg'],
          'txTime': cfSuccessList['txTime'],
          'signature': cfSuccessList['signature']
        }));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
        await getWalletHistory();
        await getUserDetails();
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//user logout

userLogout() async {
  dynamic result;
  var id = userDetails['id'];
  var role = userDetails['role'];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(Uri.parse('${url}api/v1/logout'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      FirebaseMessaging.instance.unsubscribeFromTopic("requests");
      FirebaseMessaging.instance.unsubscribeFromTopic("messages");
      platforms.invokeMethod('logout');
      // print(id);
      if (role != 'owner') {
        final position = FirebaseDatabase.instance.ref();
        position.child('drivers/$id').update({
          'is_active': 0,
        });
      }
      rideStreamStart?.cancel();
      rideStreamChanges?.cancel();
      requestStreamEnd?.cancel();
      requestStreamStart?.cancel();
      rideStreamStart = null;
      rideStreamChanges = null;
      requestStreamStart = null;
      requestStreamEnd = null;
      pref.remove('Bearer');
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//check internet connection

checkInternetConnection() async {
  Connectivity().onConnectivityChanged.listen((connectionState) {
    if (connectionState == ConnectivityResult.none) {
      internet = false;
      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    } else {
      internet = true;

      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    }
  });
}

//internet true
internetTrue() {
  internet = true;
  valueNotifierHome.incrementNotifier();
}

//driver earnings

Map<String, dynamic> driverTodayEarnings = {};
Map<String, dynamic> driverWeeklyEarnings = {};
Map<String, dynamic> weekDays = {};
Map<String, dynamic> driverReportEarnings = {};

driverTodayEarning() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/today-earnings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverTodayEarnings = jsonDecode(response.body)['data'];
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverWeeklyEarning() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/weekly-earnings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverWeeklyEarnings = jsonDecode(response.body)['data'];
      weekDays = jsonDecode(response.body)['data']['week_days'];
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverEarningReport(fromdate, todate) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/earnings-report/$fromdate/$todate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      driverReportEarnings = jsonDecode(response.body)['data'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw request

requestWithdraw(amount) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/request-for-withdrawal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'requested_amount': amount}));
    if (response.statusCode == 200) {
      await getWithdrawList();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw list

Map<String, dynamic> withDrawList = {};
List withDrawHistory = [];
Map<String, dynamic> withDrawHistoryPages = {};

getWithdrawList() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/payment/wallet/withdrawal-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      withDrawHistory = jsonDecode(response.body)['withdrawal_history']['data'];
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

getWithdrawListPages(page) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/payment/wallet/withdrawal-requests?page=$page'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      List val = jsonDecode(response.body)['withdrawal_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      val.forEach((element) {
        withDrawHistory.add(element);
      });
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get bank info
Map<String, dynamic> bankData = {};

getBankInfo() async {
  bankData.clear();
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/user/get-bank-info'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      bankData = jsonDecode(response.body)['data'];
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

addBankData(accName, accNo, bankCode, bankName) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/user/update-bank-info'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'account_name': accName,
              'account_no': accNo,
              'bank_code': bankCode,
              'bank_name': bankName
            }));

    if (response.statusCode == 200) {
      await getBankInfo();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//sos admin notification

notifyAdmin() async {
  var db = FirebaseDatabase.instance.ref();
  dynamic result;
  try {
    await db.child('SOS/${driverReq['id']}').update({
      "is_driver": "1",
      "is_user": "0",
      "req_id": driverReq['id'],
      "serv_loc_id": driverReq['service_location_id'],
      "updated_at": ServerValue.timestamp
    });
    result = true;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = false;
    }
  }
  return result;
}

//make complaint

List generalComplaintList = [];
getGeneralComplaint(type) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.get(
      Uri.parse(
          '${url}api/v1/common/complaint-titles?complaint_type=$type&transport_type=${userDetails['transport_type']}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      generalComplaintList = jsonDecode(response.body)['data'];
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeGeneralComplaint() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
            }));
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeRequestComplaint() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
              'request_id': myHistory[selectedHistory]['id']
            }));
    if (response.statusCode == 200) {
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//waiting time

//waiting before start
dynamic waitingTime;
dynamic waitingBeforeTime;
dynamic waitingAfterTime;
dynamic arrivedTimer;
dynamic rideTimer;
waitingBeforeStart() async {
  var bWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_before_start')
      .get();
  var waitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('total_waiting_time')
      .get();
  if (bWaitingTimes.child('waiting_time_before_start').value != null) {
    waitingBeforeTime = bWaitingTimes.child('waiting_time_before_start').value;
  } else {
    waitingBeforeTime = 0;
  }
  if (waitingTimes.child('total_waiting_time').value != null) {
    waitingTime = waitingTimes.child('total_waiting_time').value;
  } else {
    waitingTime = 0;
  }
  await Future.delayed(const Duration(seconds: 10), () {});

  arrivedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (driverReq['is_driver_arrived'] == 1 &&
        driverReq['is_trip_start'] == 0) {
      waitingBeforeTime++;
      waitingTime++;
      if (waitingTime % 60 == 0) {
        FirebaseDatabase.instance
            .ref()
            .child('requests/${driverReq['id']}')
            .update({
          'waiting_time_before_start': waitingBeforeTime,
          'total_waiting_time': waitingTime
        });
      }
      valueNotifierHome.incrementNotifier();
    } else {
      timer.cancel();
      arrivedTimer = null;
    }
  });
}

dynamic currentRidePosition;

waitingAfterStart() async {
  var bWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_before_start')
      .get();
  var waitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('total_waiting_time')
      .get();
  var aWaitingTimes = await FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      // .child('waiting_time_after_start')
      .get();
  if (bWaitingTimes.child('waiting_time_before_start').value != null &&
      waitingBeforeTime == null) {
    waitingBeforeTime = bWaitingTimes.child('waiting_time_before_start').value;
  }
  if (waitingTimes.child('total_waiting_time').value != null) {
    waitingTime = waitingTimes.child('total_waiting_time').value;
    // ignore: prefer_conditional_assignment
  } else if (waitingTime == null) {
    waitingTime = 0;
  }
  if (aWaitingTimes.child('waiting_time_after_start').value != null) {
    waitingAfterTime = aWaitingTimes.child('waiting_time_after_start').value;
  } else {
    waitingAfterTime = 0;
  }
  await Future.delayed(const Duration(seconds: 10), () {});
  rideTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
    if (currentRidePosition == null &&
        driverReq['is_completed'] == 0 &&
        driverReq['is_trip_start'] == 1) {
      currentRidePosition = center;
    } else if (currentRidePosition != null &&
        driverReq['is_completed'] == 0 &&
        driverReq['is_trip_start'] == 1) {
      var dist = await calculateIdleDistance(currentRidePosition.latitude,
          currentRidePosition.longitude, center.latitude, center.longitude);
      if (dist < 150) {
        waitingAfterTime = waitingAfterTime + 60;
        waitingTime = waitingTime + 60;
        if (waitingTime % 60 == 0) {
          FirebaseDatabase.instance
              .ref()
              .child('requests/${driverReq['id']}')
              .update({
            'waiting_time_after_start': waitingAfterTime,
            'total_waiting_time': waitingTime
          });
        }
        valueNotifierHome.incrementNotifier();
      } else {
        currentRidePosition = center;
      }
    } else {
      timer.cancel();
      rideTimer = null;
    }
  });
}

//requestStream
StreamSubscription<DatabaseEvent>? requestStreamStart;
StreamSubscription<DatabaseEvent>? requestStreamEnd;
StreamSubscription<DatabaseEvent>? rideStreamStart;
StreamSubscription<DatabaseEvent>? rideStreamChanges;
StreamSubscription<DatabaseEvent>? messageStream;
void streamRequest() {
  // Cancel existing streams to prevent duplicates
  rideStreamStart?.cancel();
  rideStreamChanges?.cancel();
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  messageStream?.cancel(); // Cancel existing message stream

  rideStreamStart = null;
  rideStreamChanges = null;
  requestStreamStart = null;
  requestStreamEnd = null;
  messageStream = null; // Reset message stream

  if (userDetails['id'] == null) {
    print("User ID is null. Cannot listen for requests or messages.");
    return;
  }

  // ✅ Listen for new ride requests
  requestStreamStart = FirebaseDatabase.instance
      .ref('request-meta')
      .orderByChild('driver_id')
      .equalTo(userDetails['id'])
      .onChildAdded
      .listen((event) {
    if (event.snapshot.exists) {
      Map<String, dynamic> requestData =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      if (driverReq.isEmpty) {
        print("New ride request detected: ${event.snapshot.key}");
        streamEnd(event.snapshot.key.toString());
        getUserDetails();

        // ✅ Notify the driver for ride request
        notifyDriver(requestData);
      }
    }
  });

  // ✅ Listen for ride status updates
  rideStreamChanges = FirebaseDatabase.instance
      .ref('request-meta')
      .orderByChild('driver_id')
      .equalTo(userDetails['id'])
      .onChildChanged
      .listen((event) {
    if (event.snapshot.exists) {
      Map<String, dynamic> updatedData =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      print("Ride request updated: ${event.snapshot.key}");
      notifyDriver(updatedData);
    }
  });

  // ✅ Listen for new chat messages
  messageStream = FirebaseDatabase.instance
      .ref('messages')
      .orderByChild('receiver_id') // Filter messages for the driver
      .equalTo(userDetails['id'])
      .onChildAdded
      .listen((event) {
    if (event.snapshot.exists) {
      Map<String, dynamic> messageData =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      print("📩 New message received: ${messageData['message']}");

      // ✅ Notify the driver for new message
      notifyDriverMessage(messageData);
    }
  });
}

void notifyDriverMessage(Map<String, dynamic> messageData) {
  if (messageData.isEmpty) return;

  LocalNotificationService.showLocalNotification(
    title: "📩 New Message",
    body: "You have a new message: ${messageData['message']}",
    payload: messageData,
  );
}

void notifyDriver(Map<String, dynamic> rideRequest) {
  if (rideRequest.isEmpty) return;

  LocalNotificationService.showLocalNotification(
    title: "🚖 New Ride Assigned",
    body: "A new ride has been assigned to you. Tap to view details.",
    payload: rideRequest,
  );

  // Update UI if needed
  valueNotifierHome.incrementNotifier();
}



streamEnd(id) {
  requestStreamEnd = FirebaseDatabase.instance
      .ref('requests')
      .child(id)
      .onChildRemoved
      .handleError((onError) {
    requestStreamEnd?.cancel();
  }).listen((event) {
    if (driverReject != true && driverReq['accepted_at'] == null) {
      // userReject = true;
      // AwesomeNotifications().cancel(7425);
      driverReq.clear();
      getUserDetails();
    }
  });
}

streamRide() {
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamStart?.cancel();
  rideStreamChanges?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamStart = null;
  rideStreamChanges = null;
  rideStreamChanges = FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      .onChildChanged
      .handleError((onError) {
    rideStreamChanges?.cancel();
  }).listen((DatabaseEvent event) {
    if (event.snapshot.key.toString() == 'cancelled_by_user') {
      getUserDetails();
      if (driverReq.isEmpty) {
        userReject = true;
      }
    } else if (event.snapshot.key.toString() == 'message_by_user') {
      getCurrentMessagesCompany();
    } else if (event.snapshot.key.toString() == 'is_paid') {
      getUserDetails();
    }
  });
  rideStreamStart = FirebaseDatabase.instance
      .ref('requests/${driverReq['id']}')
      .onChildAdded
      .handleError((onError) {
    rideStreamChanges?.cancel();
  }).listen((DatabaseEvent event) async {
    if (event.snapshot.key.toString() == 'cancelled_by_user') {
      getUserDetails();

      userReject = true;
    } else if (event.snapshot.key.toString() == 'message_by_user') {
      getCurrentMessagesCompany();
    } else if (event.snapshot.key.toString() == 'is_paid') {
      getUserDetails();
    }
  });
}

//location stream
bool positionStreamStarted = false;
StreamSubscription<geolocs.Position>? positionStream;

geolocs.LocationSettings locationSettings = (platform == TargetPlatform.android)
    ? geolocs.AndroidSettings(
        accuracy: geolocs.LocationAccuracy.high,
        distanceFilter: 50,
        foregroundNotificationConfig:
            const geolocs.ForegroundNotificationConfig(
          notificationText:
              "product name will continue to receive your location in background",
          notificationTitle: "Location background service running",
          enableWakeLock: true,
        ))
    : geolocs.AppleSettings(
        accuracy: geolocs.LocationAccuracy.high,
        activityType: geolocs.ActivityType.otherNavigation,
        distanceFilter: 50,
        showBackgroundLocationIndicator: true,
      );

//after load image
uploadLoadingImage(image) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/request/upload-proof'));
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.files.add(await http.MultipartFile.fromPath('proof_image', image));
    response.fields['before_load'] = '1';
    response.fields['request_id'] = driverReq['id'];
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      debugPrint('testing $val');
      result = 'success';
    } else {
      debugPrint(respon.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

// unload image
uploadUnloadingImage(image) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse('${url}api/v1/request/upload-proof'));
    response.headers
        .addAll({'Authorization': 'Bearer $token'});
    response.files.add(await http.MultipartFile.fromPath('proof_image', image));
    response.fields['after_load'] = '1';
    response.fields['request_id'] = driverReq['id'];
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      debugPrint('testing $val');
      result = 'success';
    } else {
      debugPrint(val);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

dynamic testDistance = 0;
// Location location = Location();

positionStreamData() {
  positionStream =
      geolocs.Geolocator.getPositionStream(locationSettings: locationSettings)
          .handleError((error) {
    positionStream = null;
    positionStream?.cancel();
  }).listen((geolocs.Position? position) {
    if (position != null) {
      center = LatLng(position.latitude, position.longitude);
    } else {
      positionStream!.cancel();
    }
  });
}

userDelete() async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http
        .post(Uri.parse('${url}api/v1/user/delete-user-account'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      pref.remove('Bearer');

      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

addHomeAddress(lat, lng, add) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/add-my-route-address'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'my_route_lat': lat,
          'my_route_lng': lng,
          'my_route_address': add
        }));
    if (response.statusCode == 200) {
      // printWrapped(response.body);
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

enableMyRouteBookings(lat, lng) async {
  dynamic result;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('BearerToken');
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/driver/enable-my-route-booking'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'is_enable': (userDetails['enable_my_route_booking'] == 1) ? 0 : 1,
          'current_lat': lat,
          'current_lng': lng
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}
