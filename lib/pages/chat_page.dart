import 'package:chat_app/widgets/chat_messages_widget.dart';
import 'package:chat_app/widgets/new_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat page'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessagesWidget(),
          ),
          NewMessageWidget(),
        ],
      ),
    );
  }
}
