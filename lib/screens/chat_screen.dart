import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_starting_project/components/messageBubble.dart';
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
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // Implement logout functionality

                AuthService().signOut();
              }),
        ],
        title: const Text('⚡️ ️Chat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(fireStore: _fireStore),
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
                      // Implement send functionality
                      _fireStore.collection('messages').add({
                        'date': DateTime.now().microsecondsSinceEpoch,
                        'text': _messageTextControllar.text, //*************
                        'sender': AuthService().getCurrentUser!.email,
                      });
                      _messageTextControllar.clear();
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

class MessageStream extends StatelessWidget {
  const MessageStream({
    super.key,
    required FirebaseFirestore fireStore,
  }) : _fireStore = fireStore;

  final FirebaseFirestore _fireStore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('messages')
            .orderBy('date', descending: true)
            .snapshots(),
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
            List<Widget> messagesBubbles = [];
            for (var message in messages) {
              var messageText = message.get('text');
              var sender = message.get('sender');
              Widget messageBubble = MessageBubble(
                  message: messageText,
                  sender: sender,
                  isMe: AuthService().getCurrentUser!.email == sender);
              messagesBubbles.add(messageBubble);
            }
            return Expanded(
              child: ListView(
                reverse: true,
                children: messagesBubbles,
              ),
            );
          } else {
            return Center(child: Text('Snapshot has no data'));
          }
        });
  }
}
