import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/about.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/driverdetails.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/editprofile.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/history.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/managevehicles.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/notification.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/selectlanguage.dart';
import 'package:tagyourtaxi_driver/pages/chatPage/chat_page.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import '../vehicleInformations/vehicle_type.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key, this.companyId,  this.serviceId}) : super(key: key);
  String? companyId;
  String? serviceId;
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  ScrollController controller = ScrollController();
  Timer? _timer;
  // var data;
  @override
  void initState() {
    super.initState();
    getCurrentMessagesCompany(); // Initial fetch
    // _startAutoRefresh();
  }



  //
  // void _startAutoRefresh() {
  //   _timer = Timer.periodic(Duration(seconds: 5), (timer) {
  //     getCurrentMessagesCompany();
  //   });
  // }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ Prevent memory leaks
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              width: media.width * 0.8,
              child: DrawerHeader(
                  child: Image.asset(
                "assets/images/splash1.png",
                // fit: BoxFit.fill,
              )),
            ),
            Container(
              decoration: BoxDecoration(color: yellowcolor),
              width: media.width * 0.8,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                userDetails['profile_picture'] != null
                    ? Container(
                        margin: const EdgeInsets.all(5),
                        height: media.width * 0.2,
                        width: media.width * 0.2,
                        child: CircleAvatar(
                            backgroundColor: Colors.grey.shade400,
                            backgroundImage: NetworkImage(userDetails[
                                        'profile_picture'] !=
                                    "/assets/images/default-profile-picture.jpeg"
                                ? userDetails['profile_picture']
                                : "https://cdn4.iconfinder.com/data/icons/green-shopper/1068/user.png")),
                      )
                    : Container(
                        margin: const EdgeInsets.all(5),
                        height: media.width * 0.2,
                        width: media.width * 0.2,
                        child: const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTu3_qIHtXBZ7vZeMQhyD8qLC1VRB9ImHadL09KET_iSQEX6ags4ICknfmqEKz8Nf6IOsA&usqp=CAU')),
                      ),
                SizedBox(
                  width: media.width * 0.025,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: media.width * 0.45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: media.width * 0.3,
                            child: Text(
                              userDetails['name'] ?? "",
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * eighteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              var val = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfile()));
                              if (val) {
                                setState(() {});
                              }
                            },
                            child: Icon(
                              Icons.edit,
                              size: media.width * eighteen,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.01,
                    ),
                    SizedBox(
                      width: media.width * 0.45,
                      child: Text(
                        /// 'driver@gmail.com',
                        userDetails['email'] ?? "",
                        style: GoogleFonts.roboto(
                            fontSize: media.width * fourteen,
                            color: textColor),
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ]),
            ),
            Container(
              padding: EdgeInsets.only(top: media.width * 0.02),
              width: media.width * 0.7,
              child: Column(
                children: [
                  //history
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const History()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.025),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/history.png',
                            fit: BoxFit.contain,
                            width: media.width * 0.075,
                          ),
                          SizedBox(
                            width: media.width * 0.025,
                          ),
                          SizedBox(
                            width: media.width * 0.55,
                            child: Text(
                              languages[choosenLanguage]
                                  ['text_enable_history'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (userDetails['role'] == 'driver')
                    //notification
                    ValueListenableBuilder(
                        valueListenable: valueNotifierNotification.value,
                        builder: (context, value, child) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationPage()));
                              setState(() {
                                userDetails['notifications_count'] = 0;
                              });
                            },
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.all(media.width * 0.025),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/notification.png',
                                        fit: BoxFit.contain,
                                        width: media.width * 0.075,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.025,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.49,
                                        child: Text(
                                          languages[choosenLanguage]
                                                  ['text_notification']
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: textColor),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                      // Reset the notification count when opening the chat
                      notificationCount.value = 0;
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(media.width * 0.025),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/walletImage.png',
                                fit: BoxFit.contain,
                                width: media.width * 0.075,
                              ),
                              SizedBox(width: media.width * 0.025),
                              SizedBox(
                                width: media.width * 0.55,
                                child: Text(
                                  'Chat',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🛑 Notification Badge (Only shows when count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: ValueListenableBuilder<int>(
                            valueListenable: notificationCount,
                            builder: (context, count, child) {
                              print("📌 Rebuilding Notification Badge - Count: $count");
                              return count > 0
                                  ? Container(
                                height: 18,
                                width: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                                  : SizedBox(); // Hide badge when no notifications
                            },
                          ),

                        ),
                      ],
                    ),
                  ),


                  userDetails['role'] == 'owner'
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                         ManageVehicles(companyId:widget.companyId,serviceId:widget.serviceId)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(media.width * 0.025),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/updateVehicleInfo.png',
                                  fit: BoxFit.contain,
                                  width: media.width * 0.075,
                                ),
                                SizedBox(
                                  width: media.width * 0.025,
                                ),
                                SizedBox(
                                  width: media.width * 0.55,
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_manage_vehicle'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: textColor),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),

                  //manage Driver

                  userDetails['role'] == 'owner'
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DriverList()));
                          },
                          child: Container(
                            padding: EdgeInsets.all(media.width * 0.025),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/managedriver.png',
                                  fit: BoxFit.contain,
                                  width: media.width * 0.075,
                                ),
                                SizedBox(
                                  width: media.width * 0.025,
                                ),
                                SizedBox(
                                  width: media.width * 0.55,
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_manage_drivers'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: textColor),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  //update vehicles

                  userDetails['owner_id'] != null &&
                      userDetails['role'] == 'driver'
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VehicleType(companyId:widget.companyId,serviceId:widget.serviceId)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(media.width * 0.025),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/updateVehicleInfo.png',
                                  fit: BoxFit.contain,
                                  width: media.width * 0.075,
                                ),
                                SizedBox(
                                  width: media.width * 0.025,
                                ),
                                SizedBox(
                                  width: media.width * 0.55,
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_updateVehicle'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: textColor),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  InkWell(
                    onTap: () async {
                      var nav = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectLanguage()));
                      if (nav) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.025),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/changeLanguage.png',
                            fit: BoxFit.contain,
                            width: media.width * 0.075,
                          ),
                          SizedBox(
                            width: media.width * 0.025,
                          ),
                          SizedBox(
                            width: media.width * 0.55,
                            child: Text(
                              languages[choosenLanguage]
                                  ['text_change_language'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var nav = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MakeComplaint(
                                    fromPage: 0,
                                  )));
                      if (nav) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.025),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/makecomplaint.png',
                            fit: BoxFit.contain,
                            width: media.width * 0.075,
                          ),
                          SizedBox(
                            width: media.width * 0.025,
                          ),
                          SizedBox(
                            width: media.width * 0.55,
                            child: Text(
                              languages[choosenLanguage]
                                  ['text_make_complaints'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  //about
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const About()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.025),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: media.width * 0.075),
                          SizedBox(
                            width: media.width * 0.025,
                          ),
                          SizedBox(
                            width: media.width * 0.55,
                            child: Text(
                              languages[choosenLanguage]['text_about'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        logout = true;
                      });
                      // valueNotifierHome.();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.025),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logout.png',
                            fit: BoxFit.contain,
                            width: media.width * 0.075,
                          ),
                          SizedBox(
                            width: media.width * 0.025,
                          ),
                          SizedBox(
                            width: media.width * 0.55,
                            child: Text(
                              languages[choosenLanguage]['text_logout'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
