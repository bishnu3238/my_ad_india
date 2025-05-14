import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onTyping;

  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTyping,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: InputBorder.none,
            ),
            minLines: 1,
            maxLines: 4,
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: onSend,
        ),
      ],
    );
  }
}
