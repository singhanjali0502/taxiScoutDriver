import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

double review = 0.0;
String feedback = '';

class _ReviewState extends State<Review> {
  bool _loading = false;

  @override
  void initState() {
    review = 0.0;
    super.initState();
  }

//navigate
  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  Maps()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(
                children: [
                  Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    padding: EdgeInsets.all(media.width * 0.05),
                    color: page,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (driverReq.isNotEmpty)
                            ? Container(
                                height: media.width * 0.25,
                                width: media.width * 0.25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            driverReq['userDetail']['data']
                                                ['profile_picture']),
                                        fit: BoxFit.cover)),
                              )
                            : Container(),
                        SizedBox(
                          height: media.height * 0.02,
                        ),
                        Text(
                          (driverReq.isNotEmpty)
                              ? driverReq['userDetail']['data']['name']
                              : '',
                          style: GoogleFonts.roboto(
                              fontSize: media.width * twenty, color: textColor),
                        ),
                        SizedBox(
                          height: media.height * 0.02,
                        ),

                        //stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    review = 1.0;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: media.width * 0.1,
                                  color:
                                      (review >= 1) ? buttonColor : Colors.grey,
                                )),
                            SizedBox(
                              width: media.width * 0.02,
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    review = 2.0;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: media.width * 0.1,
                                  color:
                                      (review >= 2) ? buttonColor : Colors.grey,
                                )),
                            SizedBox(
                              width: media.width * 0.02,
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    review = 3.0;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: media.width * 0.1,
                                  color:
                                      (review >= 3) ? buttonColor : Colors.grey,
                                )),
                            SizedBox(
                              width: media.width * 0.02,
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    review = 4.0;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: media.width * 0.1,
                                  color:
                                      (review >= 4) ? buttonColor : Colors.grey,
                                )),
                            SizedBox(
                              width: media.width * 0.02,
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    review = 5.0;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: media.width * 0.1,
                                  color:
                                      (review == 5) ? buttonColor : Colors.grey,
                                ))
                          ],
                        ),
                        SizedBox(
                          height: media.height * 0.05,
                        ),

                        //feedbact textfield
                        Container(
                          padding: EdgeInsets.all(media.width * 0.05),
                          width: media.width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 1.5, color: Colors.grey)),
                          child: TextField(
                            maxLines: 4,
                            onChanged: (val) {
                              setState(() {
                                feedback = val;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: languages[choosenLanguage]
                                    ['text_feedback'],
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          height: media.height * 0.05,
                        ),
                        Button(
                            onTap: () async {
                              if (review >= 1.0) {
                                setState(() {
                                  _loading = true;
                                });
                                var result = await userRating();

                                if (result == true) {
                                  _loading = false;
                                  navigate();
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              }
                            },
                            text: languages[choosenLanguage]['text_submit'])
                      ],
                    ),
                  ),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(
                            onTap: () {
                              setState(() {
                                internetTrue();
                              });
                            },
                          ))
                      : Container(),

                  //loader
                  (_loading == true)
                      ? const Positioned(child: Loading())
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
