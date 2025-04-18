import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  var _choosenLanguage = choosenLanguage;
  bool _isLoading = false;

  //navigate pop
  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                height: media.height * 1,
                width: media.width * 1,
                padding: EdgeInsets.fromLTRB(media.width * 0.05,
                    media.width * 0.05, media.width * 0.05, media.width * 0.05),
                color: page,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: media.width * 0.05),
                          width: media.width * 1,
                          alignment: Alignment.center,
                          child: Text(
                            languages[choosenLanguage]['text_change_language'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twenty,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ),
                        Positioned(
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Icon(Icons.arrow_back)))
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    SizedBox(
                      width: media.width * 0.9,
                      height: media.height * 0.16,
                      child: Image.asset(
                        'assets/images/chooselang.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Expanded(
                      // ignore: avoid_unnecessary_containers
                      child: Container(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: languages
                                .map((i, value) {
                                  return MapEntry(
                                      i,
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _choosenLanguage = i;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.025),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                languagesCode
                                                    .firstWhere((e) =>
                                                        e['code'] == i)['name']
                                                    .toString(),
                                                style: GoogleFonts.roboto(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: textColor),
                                              ),
                                              Container(
                                                height: media.width * 0.05,
                                                width: media.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xff222222),
                                                        width: 1.2)),
                                                alignment: Alignment.center,
                                                child: (_choosenLanguage == i)
                                                    ? Container(
                                                        height:
                                                            media.width * 0.03,
                                                        width:
                                                            media.width * 0.03,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(
                                                                    0xff222222)),
                                                      )
                                                    : Container(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ));
                                })
                                .values
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    Button(
                        onTap: () async {
                          choosenLanguage = _choosenLanguage;
                          if (choosenLanguage == 'ar' ||
                              choosenLanguage == 'ur' ||
                              choosenLanguage == 'iw') {
                            languageDirection = 'rtl';
                          } else {
                            languageDirection = 'ltr';
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          await getlangid();
                          pref.setString(
                              'languageDirection', languageDirection);
                          pref.setString('choosenLanguage', _choosenLanguage);
                          valueNotifierHome.incrementNotifier();
                          setState(() {
                            _isLoading = false;
                          });
                          pop();
                        },
                        text: languages[choosenLanguage]['text_confirm'])
                  ],
                ),
              ),

              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
