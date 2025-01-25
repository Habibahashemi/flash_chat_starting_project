import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_starting_project/constants.dart';
import 'package:flash_chat_starting_project/services/authService.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  TextEditingController _messageTextControllar = TextEditingController();
  // void getMessages() async {
  //   var messages = await _fireStore.collection('messages').get();
  //   for (var messages in messages.docs) {
  //     print(messages.data());
  //   }
  // }
  void messagesStreem() {
    //streem
    _fireStore.collection('messages').snapshots().listen((event) {
      for (var messages in event.docs) {
        print(messages.data());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        automaticallyImplyLeading: false,
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Implement logout functionality
                Navigator.pop(context);
                AuthService().signOut();
                // getMessages();
                // messagesStreem();
              }),
        ],
        title: const Text('⚡ ️Chat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlue,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    var messages = snapshot.data!.docs;
                    List<Text> messagesWidgets = [];
                    for (var message in messages) {
                      var messageText = message.get('text');
                      var sender = message.get('sender');
                      Text messageWidget = Text('$messageText,from $sender');
                      messagesWidgets.add(messageWidget);
                    }
                    return Column(
                      children: messagesWidgets,
                    );
                  } else {
                    return Center(child: Text('Snapshot has no data'));
                  }
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageTextControllar,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality
                      _fireStore.collection('messages').add({
                        'date': DateTime.now().microsecondsSinceEpoch,
                        'text': _messageTextControllar,
                        'sender': AuthService().getCurrentUser!.email
                      });
                    },
                    child: const Icon(Icons.send,
                        size: 30, color: kSendButtonColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
