import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../functions/functions.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatText = TextEditingController();
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;
  Timer? _timer;

  // ValueNotifier to dynamically update messages
  ValueNotifier<List<dynamic>> valueNotifierHome = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    getCurrentMessages(); // Initial fetch
    _startAutoRefresh(); // Start auto-refresh
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  // Function to fetch messages and update ValueNotifier
  void getCurrentMessages() async {
    List<dynamic> messages = await getCurrentMessagesCompany();
    valueNotifierHome.value = messages;

    // Scroll to the bottom when new messages arrive
    Future.delayed(Duration(milliseconds: 300), () {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
  }

  // Auto-refresh messages every 5 seconds
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // Chat header
                Container(
                  padding: EdgeInsets.fromLTRB(
                    media.width * 0.05,
                    MediaQuery.of(context).padding.top + media.width * 0.05,
                    media.width * 0.05,
                    media.width * 0.05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: Icon(Icons.arrow_back, size: 28),
                      ),
                      Text(
                        'Chat With Company',
                        style: GoogleFonts.roboto(
                          fontSize: media.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 28), // Placeholder for balance layout
                    ],
                  ),
                ),

                // Chat messages list
                Expanded(
                  child: ValueListenableBuilder<List<dynamic>>(
                    valueListenable: valueNotifierHome,
                    builder: (context, chatList, child) {
                      if (chatList.isEmpty) {
                        return Center(
                          child: Text(
                            "No messages yet",
                            style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          // ✅ Ensure index is within valid range
                          if (index < 0 || index >= chatList.length) {
                            return SizedBox(); // Return empty widget if index is invalid
                          }

                          final chatItem = chatList[index];
                          bool isSentByUser = chatItem["from_type"] == "is_driver";
                          String timestamp = chatItem["created_at"];
                          DateTime dateTime = DateTime.parse(timestamp);
                          String formattedTime = DateFormat('HH:mm').format(dateTime);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: media.width * 0.015,
                              horizontal: media.width * 0.05,
                            ),
                            child: Align(
                              alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment:
                                isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.04),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSentByUser ? Colors.blue : Colors.grey[800],
                                    ),
                                    child: Text(
                                      chatItem['message'] ?? "",
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(fontSize: media.width * 0.03, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),


                // Chat input field
                Container(
                  margin: EdgeInsets.only(top: media.width * 0.025, bottom: media.width * 0.05),
                  padding: EdgeInsets.symmetric(
                    horizontal: media.width * 0.025,
                    vertical: media.width * 0.01,
                  ),
                  width: media.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chatText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message...",
                            hintStyle: GoogleFonts.roboto(fontSize: media.width * 0.035, color: Colors.grey),
                          ),
                          minLines: 1,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _sendingMessage = true;
                          });

                          await sendMessageCompany(chatText.text); // Function to send message
                          chatText.clear();
                          getCurrentMessages(); // ✅ Auto-update messages after sending

                          setState(() {
                            _sendingMessage = false;
                          });
                        },
                        child: Icon(Icons.send, color: Colors.blue, size: 28),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loader overlay when sending a message
            if (_sendingMessage)
              Container(
                color: Colors.black.withOpacity(0.3), // Semi-transparent background
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
