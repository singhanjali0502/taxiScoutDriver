import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/widgets/local_notification.dart';
import 'pages/loadingPage/loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert'; // Required for encoding payloads


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background Message Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("💬 Background Message Received: ${message.messageId}");

  if (message.notification != null) {
    String encodedPayload = jsonEncode(message.data); // ✅ Encode Map to String
    LocalNotificationService.showLocalNotification(
      title: message.notification!.title ?? "New Ride Request",
      body: message.notification!.body ?? "You have a new ride request",
      payload: message.data, // Pass encoded payload
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Ensure Firebase is initialized
  await LocalNotificationService.requestPermission();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  // 🔹 Initialize local notifications
  LocalNotificationService.initialize();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("❌ Notifications permission denied! Please enable it in settings.");
  }

  print("🔔 Notification Permissions Status: ${settings.authorizationStatus}");

  // 🔹 Set up Firebase Messaging Handlers
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.subscribeToTopic("request-meta");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("💡 Foreground Message Received: ${message.messageId}");

    String encodedPayload = jsonEncode(message.data); // ✅ Encode Map to String

    // Ensure local notifications are displayed in foreground
    LocalNotificationService.showLocalNotification(
      title: message.notification?.title ?? "New Ride Request",
      body: message.notification?.body ?? "You have a new ride request",
      payload: message.data, // Pass encoded payload
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📬 User Opened App via Notification: ${message.messageId}");
    _handleNotificationTap(message);
  });

  checkInternetConnection();
  currentPositionUpdate();

  runApp(const MyApp());
}

/// Handles Notification Clicks & Navigates to MapScreen
void _handleNotificationTap(RemoteMessage message) {
  if (message.data.isNotEmpty) {
    print("🚖 Navigating to MapScreen with data: ${message.data}");

    // Decode message data and navigate
    Map<String, dynamic> rideData = message.data;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => Maps(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'TaxiScout24 Driver',
            theme: ThemeData(),
            routes: {
              '/login': (context) => Login(),
            },
            home: const LoadingPage()));
  }
}