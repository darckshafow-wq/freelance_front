import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _getLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getColor(String value) {
    switch (value.toUpperCase()) {
      case 'OPEN':
        return Colors.green;
      case 'ACTIVE':
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'PENDING_COMPLETION':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLabel(String value) {
    switch (value.toUpperCase()) {
      case 'OPEN':
        return 'Ouverte';
      case 'ACTIVE':
      case 'IN_PROGRESS':
        return 'En cours';
      case 'PENDING_COMPLETION':
        return 'À terminer';
      case 'COMPLETED':
        return 'Terminée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return value;
    }
  }
}
