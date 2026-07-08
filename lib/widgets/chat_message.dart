import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? primaryBlue : white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: white,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 15,
                          color: deepTeal,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          fontSize: 15,
                          color: deepTeal,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        tableHead: const TextStyle(
                          fontSize: 14,
                          color: deepTeal,
                          fontWeight: FontWeight.bold,
                        ),
                        tableBody: const TextStyle(
                          fontSize: 14,
                          color: deepTeal,
                        ),
                        tableBorder: TableBorder.all(color: softGray, width: 1),
                        tableCellsPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        blockquote: TextStyle(
                          fontSize: 15,
                          color: deepTeal.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        code: TextStyle(
                          fontSize: 13,
                          color: primaryBlue,
                          backgroundColor: creamBackground,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
