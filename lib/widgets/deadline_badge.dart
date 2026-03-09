import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/order_model.dart';

class DeadlineBadge extends StatelessWidget {
  final OrderModel order;

  const DeadlineBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final days = order.daysUntilDeadline;
    final color = AppColors.deadlineColor(days);

    String label;
    if (days < 0) {
      label = 'Overdue by ${days.abs()} day${days.abs() == 1 ? '' : 's'}';
    } else if (days == 0) {
      label = 'Due today';
    } else if (days == 1) {
      label = '1 day left';
    } else {
      label = '$days days left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            days < 0 ? Icons.warning_amber_rounded : Icons.schedule,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
