import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:pands_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:pands_app/screens/login_page.dart';

import '../customSnackBar.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool emojiShowing = false;
  late String messageText;
  FocusNode focusNode = FocusNode();

  void dispose() {
    messageTextController.dispose();
    super.dispose();
  }

  _onBackspacePressed() {
    messageTextController
      ..text = messageTextController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageTextController.text.length));
  }

  void onEmojiSelected(Emoji emoji) {
    messageTextController.text = messageTextController.text + emoji.emoji;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void setupFirebaseMessaging() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "Received message: ${message.notification?.title} - ${message.notification?.body}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          "User tapped on notification: ${message.notification?.title} - ${message.notification?.body}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality

                MySnackbar.showAwesomeSnackbar(
                  context,
                  title: 'Logout',
                  message: 'Logout successful.',
                  contentType: ContentType.warning,
                );
                _auth.signOut();
                Navigator.pushNamed(context, LoginPage.id);
              }),
        ],
        title: Center(child: Text('PandsApp')),
        backgroundColor: Color(0xff000000),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/moon.jpg'),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                margin: EdgeInsets.only(bottom: 3, left: 5, right: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            setState(() {
                              emojiShowing = !emojiShowing;
                            });
                            if (emojiShowing) {
                              focusNode.unfocus();
                            } else {
                              focusNode.requestFocus();
                            }
                          },
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        onTap: () {
                          if (emojiShowing == true) {
                            setState(() {
                              emojiShowing = !emojiShowing;
                            });
                          }
                        },
                        focusNode: focusNode,
                        controller: messageTextController,
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //Implement send functionality.
                        messageTextController.clear();
                        _firestore.collection("messages").add({
                          "text": messageText,
                          "sender": loggedInUser?.email,
                          'timestamp':
                              DateTime.now().toUtc().millisecondsSinceEpoch,
                        });
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.green,
                        size: 30,
                      ), /*Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),*/
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent),
          );
        }
        final messages = snapshot.data?.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages!) {
          var data = message.data() as Map;
          final messageText = data["text"];
          final messageSender = data["sender"];
          final currentUser = loggedInUser?.email;

          final messageBubble = MessageBubble(
            messageText: messageText,
            messageSender: messageSender,
            isMe: currentUser == messageSender,
          );

          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.messageText,
      required this.messageSender,
      required this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 2, 10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            messageSender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Container(
            child: BubbleSpecialThree(
              text: messageText,
              color: isMe ? Color(0xFF1B97F3) : Color(0xFFE8E8EE),
              delivered: true,
              tail: true,
              isSender: isMe ? true : false,
              textStyle: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
