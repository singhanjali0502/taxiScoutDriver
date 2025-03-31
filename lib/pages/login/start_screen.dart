import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../functions/functions.dart';
import '../../translation/translation.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(media.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                languages[choosenLanguage]['text_start'] ?? "",
                style: TextStyle(
                  fontSize: media.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: media.height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _launchURL('https://www.taxiscout24.com/signup');
                    },
                    child: Text(
                      languages[choosenLanguage]['text_yes'] ?? "",
                      style: TextStyle(
                        fontSize: media.width * 0.05,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Login()
                      ));
                    },
                    child: Text(
                      languages[choosenLanguage]['text_no'] ?? "",
                      style: TextStyle(
                        fontSize: media.width * 0.05,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
