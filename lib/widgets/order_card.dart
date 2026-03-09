import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme.dart';
import 'status_badge.dart';
import 'priority_badge.dart';
import 'deadline_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Order ID + Priority badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  PriorityBadge(priority: order.priority),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Customer Name
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Row 3: Country
              if (order.country.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSubtext,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.country,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSubtext,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),

              // Row 4: Video length + Delivery speed
              Row(
                children: [
                  const Icon(
                    Icons.videocam_outlined,
                    size: 14,
                    color: AppColors.textSubtext,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.videoLength} · ${order.deliverySpeed}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSubtext,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 5 & 6: Deadline + Status
              Row(
                children: [
                  DeadlineBadge(order: order),
                  const SizedBox(width: 8),
                  StatusBadge(status: order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
