import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class TimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timeline;

  const TimelineWidget({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No timeline events yet.',
          style: TextStyle(color: AppColors.textSubtext, fontSize: 13),
        ),
      );
    }

    final sorted = List<Map<String, dynamic>>.from(timeline)
      ..sort((a, b) {
        final ta = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final tb = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return tb.compareTo(ta);
      });

    return Column(
      children: sorted.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == sorted.length - 1;
        final ts = (item['timestamp'] as Timestamp?)?.toDate();
        final event = item['event'] ?? '';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: index == 0 ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == 0
                          ? AppColors.primary
                          : AppColors.textSubtext,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (ts != null)
                      Text(
                        DateFormat('MMM d, yyyy · hh:mm a').format(ts),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtext,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
