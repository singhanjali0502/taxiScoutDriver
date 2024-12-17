import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:tagyourtaxi_driver/functions/functions.dart';

import '../pages/onTripPage/map_page.dart';

class DriverService {
  String url = "https://admin.taxiscout24.com/";

  Timer? locationTimer;

  Future<dynamic> driverStatus() async {
    dynamic result;
    try {
      var response = await http.post(
        Uri.parse('${url}api/v1/driver/online-offline'),
        headers: {
          'Authorization': 'Bearer  ${bearerToken[0].token}',
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

        if (userDetails['active'] == false) {
          userInactive();
          stopLocationUpdates(); // Stop location updates
        } else {
          userActive();
          startLocationUpdates(); // Start location updates
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

  void startLocationUpdates() {
    const updateInterval = Duration(seconds: 5);

    locationTimer?.cancel(); // Ensure no duplicate timers
    locationTimer = Timer.periodic(updateInterval, (timer) async {
      try {
        var response = await http.post(
          Uri.parse('${url}api/v1/driver/current-location'),
          headers: {
            'Authorization': 'Bearer ${bearerToken[0].token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "latitude": center.latitude, // Update with actual location
            "longitude": center.longitude,
          }),
        );

        if (response.statusCode == 200) {
          debugPrint("Location updated successfully: ${response.body}");
        } else {
          debugPrint("Failed to update location: ${response.body}");
        }
      } catch (e) {
        debugPrint("Error updating location: $e");
      }
    });
    debugPrint("Location updates started.");
  }

  void stopLocationUpdates() {
    if (locationTimer != null) {
      locationTimer?.cancel();
      locationTimer = null;
      debugPrint("Location updates stopped.");
    }
  }
}

