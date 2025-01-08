import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/functions/notifications.dart';
import 'pages/loadingPage/loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  initMessaging();
  Future<void>  _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Optional: Handle onMessage before runApp
  FirebaseMessaging.onMessage.listen((event) {
    // _handleIncomingMessage(event);
  });
  // FirebaseMessaging.onBackgroundMessage((val){ return print(val.toString());});
  checkInternetConnection();

  currentPositionUpdate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
            debugShowCheckedModeBanner: false,
            title: 'TaxiScout24 Driver',
            theme: ThemeData(),
            home: const LoadingPage()));
  }
}
