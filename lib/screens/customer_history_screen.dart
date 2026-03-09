import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class CustomerHistoryScreen extends StatelessWidget {
  final String email;

  const CustomerHistoryScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Customer History')),
      body: StreamBuilder<List<OrderModel>>(
        stream: service.streamOrdersByEmail(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${orders.length} order${orders.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(color: AppColors.textSubtext),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
