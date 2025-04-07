import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tagyourtaxi_driver/pages/chatPage/chat_driver_user.dart';
import 'package:tagyourtaxi_driver/pages/chatPage/chat_page.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loadingpage.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/widgets/local_notification.dart';
import 'dart:convert';

import 'functions/functions.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
ValueNotifier<int> unreadMessageCount = ValueNotifier<int>(0);

/// Background Handler for All Notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 Background Notification Received: ${message.messageId}");

  if (message.data["type"] == "request-meta") {
    _showNotification(message, "request-meta");
  } else if (message.data["type"] == "messages") {
    _showNotification(message, "messages");
  }
  else if (message.data["type"] == "companyChats") {
    _showNotification(message, "companyChats");
  }
}

/// Show Local Notification
void _showNotification(RemoteMessage message, String type) {
  if (message.notification != null) {
    String encodedPayload = jsonEncode(message.data);

    LocalNotificationService.showLocalNotification(
      title: message.notification!.title ?? (type == "request-meta" ? "New Ride Request" : "New Message"),
      body: message.notification!.body ?? (type == "request-meta" ? "You have a new ride request" : "You have received a new message"),
      payload: message.data,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.requestPermission();
  LocalNotificationService.initialize(); // 🔥 Ensure this is called
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);


  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("🔔 Notification Permissions Status: ${settings.authorizationStatus}");

  // ✅ Subscribe to Separate Topics
  FirebaseMessaging.instance.subscribeToTopic("request-meta"); // Ride requests
  FirebaseMessaging.instance.subscribeToTopic("messages"); // Chat messages
  FirebaseMessaging.instance.subscribeToTopic("companyChats");
  // 🔹 Handle Background Messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Handle Foreground Messages (Both Ride & Chat)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔔 Foreground Notification: ${message.messageId}");

    if (message.data["type"] == "request-meta") {
      _showNotification(message, "request-meta");
    } else if (message.data["type"] == "messages") {
      unreadMessageCount.value += 1; // Increment badge count for chat
      _showNotification(message, "message");
    }else if(message.data["type"] == "companyChats"){
      unreadMessageCount.value += 1; // Increment badge count for chat
    _showNotification(message, "companyChats");}
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatPageUser()));

  });

  // 🔹 Handle Notification Clicks
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data["type"] == "request-meta") {
      print("🚖 User Opened Ride Notification: ${message.messageId}");
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => Maps()));
    } else if (message.data["type"] == "messages") {
      print("💬 User Opened Chat Notification: ${message.messageId}");
      unreadMessageCount.value = 0; // ✅ Reset message badge count
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatPageUser()));
    }else if (message.data["type"] == "companyChats") {
      print("💬 User Opened Chat Notification: ${message.messageId}");
      unreadMessageCount.value = 0; // ✅ Reset message badge count
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatPage()));
    }
  });

  checkInternetConnection();
  currentPositionUpdate();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'TaxiScout24 Driver',
      theme: ThemeData(),
      routes: {
        '/login': (context) => Login(),
      },
      home: const LoadingPage(),
    );
  }
}
