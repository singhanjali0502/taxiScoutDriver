import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../functions/functions.dart'; // Firebase Realtime Database

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

  @override
  void initState() {
    super.initState();
    getCurrentMessagesCompany();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    controller.dispose();
    chatText.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ✅ Auto-refresh messages every 5 seconds
  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      getCurrentMessages();
    });
  }

  // ✅ Scroll to bottom smoothly when messages update
  void _scrollToBottom() {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ✅ Scroll only if user is near bottom
  void _scrollToBottomIfNeeded() {
    if (controller.hasClients) {
      double maxScroll = controller.position.maxScrollExtent;
      double currentScroll = controller.position.pixels;
      double threshold = 50.0; // If user is within 50px of the bottom

      if ((maxScroll - currentScroll) <= threshold) {
        _scrollToBottom();
      }
    }
  }

  // ✅ Fetch messages & auto-scroll when new ones arrive
  Future<void> getCurrentMessages() async {
    await getCurrentMessagesCompany(); // Your function to get messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(); // Always scroll to the latest message when opening
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
                // ✅ Chat header
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
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                      Text(
                        'Chat With Company',
                        style: GoogleFonts.roboto(
                          fontSize: media.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28), // Placeholder
                    ],
                  ),
                ),

                // ✅ Chat messages list
                Expanded(
                  child: ValueListenableBuilder<List<dynamic>>(
                    valueListenable: valueNotifierHomes,
                    builder: (context, chatList, child) {
                      if (chatList.isEmpty) {
                        return Center(
                          child: Text(
                            "No messages yet",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          final chatItem = chatList[index];
                          bool isSentByUser = chatItem["from_type"] == "is_driver";

                          dynamic timestamp = chatItem["created_at"];
                          DateTime dateTime;

                          if (timestamp is int) {
                            dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                          } else if (timestamp is String) {
                            dateTime = DateTime.tryParse(timestamp) ?? DateTime(1970);
                          } else {
                            dateTime = DateTime(1970);
                          }

                          String formattedTime =
                          DateFormat('HH:mm').format(dateTime);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: media.width * 0.015,
                              horizontal: media.width * 0.05,
                            ),
                            child: Align(
                              alignment: isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSentByUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.04),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSentByUser
                                          ? Colors.blue
                                          : Colors.grey[800],
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
                                    style: TextStyle(
                                      fontSize: media.width * 0.03,
                                      color: Colors.grey,
                                    ),
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

                // ✅ Chat input field
                Container(
                  margin: EdgeInsets.only(
                    top: media.width * 0.025,
                    bottom: media.width * 0.05,
                  ),
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
                            hintStyle: GoogleFonts.roboto(
                              fontSize: media.width * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                          minLines: 1,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          if (chatText.text.trim().isEmpty) return;

                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _sendingMessage = true;
                          });

                          await sendMessageCompany(chatText.text);
                          chatText.clear();

                          setState(() {
                            _sendingMessage = false;
                          });

                          // ✅ Scroll only if user is at bottom
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _scrollToBottomIfNeeded();
                          });
                        },
                        child: const Icon(Icons.send,
                            color: Colors.blue, size: 28),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ Loader overlay when sending a message
            if (_sendingMessage)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
