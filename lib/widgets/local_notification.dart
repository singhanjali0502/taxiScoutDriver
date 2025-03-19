import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print("🔔 Notification clicked with payload: ${response.payload}");
          // Handle notification click event (e.g., navigate to ride request details)
        }
      },
    );

    // Request permission for Android 13+ (API 33)
    await requestPermission();
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'request-meta', // Notification Channel ID
      'Ride Requests', // Channel Name
      channelDescription: 'Notifications for ride requests and updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID for multiple notifications
      title,
      body,
      details,
      payload: jsonEncode(payload), // Encode payload as JSON
    );
  }

  static Future<void> requestPermission() async {
    final bool? granted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    if (granted == false) {
      print("❌ Notification permission denied!");
    } else {
      print("✅ Notification permission granted!");
    }
  }
}
