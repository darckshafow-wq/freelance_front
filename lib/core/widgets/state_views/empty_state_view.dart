import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmptyStateView({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 52),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!),
            ],
          ],
        ),
      ),
    );
  }
}
