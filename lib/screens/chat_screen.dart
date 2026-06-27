import 'package:flutter/material.dart';
import '../themes/palette.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,

      body: const Center(
        child: Text('Chat', style: TextStyle(fontSize: 24, color: deepTeal)),
      ),
    );
  }
}
