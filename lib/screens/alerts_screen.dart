import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../services/firebase_service.dart';
import 'order_detail_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all read'),
            onPressed: () => service.markAllAlertsRead(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.streamAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textSubtext.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSubtext,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(alert: alert);
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final type = alert['type'] ?? 'general';
    final isRead = alert['read'] == true;
    final title = alert['title'] ?? '';
    final message = alert['message'] ?? '';
    final ts = (alert['createdAt'] as Timestamp?)?.toDate();
    final orderId = alert['orderId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead ? AppColors.card : const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: orderId != null
            ? () {
                // Navigate to order detail by orderId field (not doc id)
                // We use a helper approach
                _navigateToOrder(context, orderId as String);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _iconColor(type).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _alertIcon(type),
                  size: 18,
                  color: _iconColor(type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSubtext,
                          ),
                        ),
                      ),
                    if (ts != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _timeAgo(ts),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSubtext,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _alertIcon(String type) {
    switch (type) {
      case 'new_order':
        return Icons.add_circle;
      case 'script_review':
        return Icons.rate_review;
      case 'deadline_warning':
        return Icons.warning;
      case 'overdue':
        return Icons.error;
      case 'preview_sent':
        return Icons.send;
      default:
        return Icons.notifications;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'new_order':
        return AppColors.success;
      case 'script_review':
        return AppColors.statusScriptReview;
      case 'deadline_warning':
        return AppColors.warning;
      case 'overdue':
        return AppColors.danger;
      case 'preview_sent':
        return AppColors.statusPreviewSent;
      default:
        return AppColors.textSubtext;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _navigateToOrder(BuildContext context, String orderId) async {
    final service = FirebaseService();
    final orders = await service.streamAllOrders().first;
    final order = orders.where((o) => o.orderId == orderId).firstOrNull;
    if (order != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderDocId: order.id),
        ),
      );
    }
  }
}
