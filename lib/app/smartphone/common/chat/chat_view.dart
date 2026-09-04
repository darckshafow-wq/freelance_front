import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freelance_front/core/controllers/common/message_controller.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageController>().fetchMessages(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MessageController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
              ? Center(child: Text(controller.errorMessage!))
              : ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return ListTile(
                      title: Text('Expéditeur: ${message.senderId}'),
                      subtitle: Text(message.content),
                    );
                  },
                ),
    );
  }
}
