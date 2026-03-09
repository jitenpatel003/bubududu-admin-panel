import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../widgets/order_card.dart';
import '../widgets/stats_widget.dart';
import 'order_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _todayFormatted(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSubtext,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: service.streamActiveOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];

          // Calculate stats from orders
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          int urgent = 0;
          int dueToday = 0;
          int overdue = 0;

          for (final o in orders) {
            if (o.isOverdue) overdue++;
            if (o.isDueToday) dueToday++;
            if (o.isUrgent && !o.isDueToday && !o.isOverdue) urgent++;
          }

          return RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              slivers: [
                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.0,
                          children: [
                            StatsWidget(
                              label: 'Active Orders',
                              count: orders.length,
                              icon: Icons.pending_actions,
                              color: AppColors.primary,
                            ),
                            StatsWidget(
                              label: 'Urgent Orders',
                              count: urgent,
                              icon: Icons.priority_high,
                              color: AppColors.warning,
                            ),
                            StatsWidget(
                              label: 'Due Today',
                              count: dueToday,
                              icon: Icons.today,
                              color: AppColors.danger,
                            ),
                            StatsWidget(
                              label: 'Overdue',
                              count: overdue,
                              icon: Icons.alarm_off,
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Orders section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Active Production',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${orders.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (orders.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: AppColors.success,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No active orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = orders[index];
                          return OrderCard(
                            order: order,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(orderDocId: order.id),
                              ),
                            ),
                          );
                        },
                        childCount: orders.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _todayFormatted() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
