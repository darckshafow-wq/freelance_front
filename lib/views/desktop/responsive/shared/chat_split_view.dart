import 'package:flutter/material.dart';

class ChatSplitView extends StatefulWidget {
  final Widget listWidget;
  final Widget detailPlaceholder;
  final Widget activeChatWidget;
  final bool isContactSelected;

  const ChatSplitView({
    super.key,
    required this.listWidget,
    required this.detailPlaceholder,
    required this.activeChatWidget,
    required this.isContactSelected,
  });

  @override
  State<ChatSplitView> createState() => _ChatSplitViewState();
}

class _ChatSplitViewState extends State<ChatSplitView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Column: List of conversations
        Container(
          width: 350,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          ),
          child: widget.listWidget,
        ),
        // Right Column: Active chat or placeholder
        Expanded(
          child: widget.isContactSelected 
            ? widget.activeChatWidget 
            : widget.detailPlaceholder,
        ),
      ],
    );
  }
}
