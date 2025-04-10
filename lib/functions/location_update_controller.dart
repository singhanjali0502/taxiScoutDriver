import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';

import '../pages/login/login.dart';
import '../pages/onTripPage/map_page.dart';

class DriverService {
  String url = "https://admin.taxiscout24.com/";

  Timer? locationTimer;
  bool isLocationUpdating = false;

  Future<dynamic> driverStatus() async {
    dynamic result;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('BearerToken');
    try {
      var response = await http.post(
        Uri.parse('${url}api/v1/driver/online-offline'),
        headers: {
          'Authorization': 'Bearer  $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "latitude": center.latitude,
          "longitude": center.longitude,
        }),
      );

      if (response.statusCode == 200) {
        var userDetails = jsonDecode(response.body)['data'];
        result = true;

        if (userDetails['available'] == true) {
          userInactive();
          stopLocationUpdates(); // Stop location updates
        } else {
          userActive();
          // startLocationUpdates(); // Start location updates
        }

      } else {
        debugPrint(response.body);
        result = false;
      }
    } catch (e) {
      if (e is SocketException) {
        debugPrint("No Internet Connection");
        result = 'no internet';
      }
    }
    return result;
  }

  bool _shouldUpdateLocation = false;



  void startLocationUpdates(BuildContext context) async {
    if (isLocationUpdating) {
      debugPrint("⛔ Location updates already running.");
      return;
    }

    debugPrint("✅ Starting location updates...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('BearerToken');

    if (token == null) {
      debugPrint("🚫 Cannot start location updates without token.");
      return;
    }

    isLocationUpdating = true;
    _shouldUpdateLocation = true;

    while (_shouldUpdateLocation) {
      debugPrint("📍 Sending location update...");

      try {
        var response = await http.post(
          Uri.parse('${url}api/v1/driver/current-location'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "latitude": center.latitude,
            "longitude": center.longitude,
          }),
        );

        if (response.statusCode == 200) {
          debugPrint("✅ Location updated: ${response.body}");
          getUserDetails();
          getCurrentMessagesCompany();
        } else if (response.statusCode == 401) {
          debugPrint("🔐 Unauthorized - logging out...");

          // Stop location updates
          stopLocationUpdates();

          // // Clear token and redirect to login screen
          // await prefs.clear();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
                  (route) => false,
            );
          }

          return; // Break out of the loop
        } else {
          debugPrint("❌ Failed to update location: ${response.body}");
        }
      } catch (e) {
        debugPrint("❗ Error sending location: $e");
      }

      await Future.delayed(const Duration(seconds: 5));
    }

    isLocationUpdating = false;
  }



  void stopLocationUpdates() {
    _shouldUpdateLocation = false;
    isLocationUpdating = false;
    locationTimer?.cancel();
    locationTimer = null;
    isLocationUpdating = false;
    debugPrint("🛑 Location updates stopped (if running).");
  }




}

