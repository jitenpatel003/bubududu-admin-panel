import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../widgets/order_card.dart';
import '../widgets/filter_sheet.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _applyFilters(List<OrderModel> orders) {
    List<OrderModel> result = orders;

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((o) {
        return o.orderId.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.country.toLowerCase().contains(q) ||
            o.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // Status filter
    final statuses = _filters['statuses'] as List<String>? ?? [];
    if (statuses.isNotEmpty) {
      result = result.where((o) => statuses.contains(o.status)).toList();
    }

    // Priority filter
    final priorities = _filters['priorities'] as List<String>? ?? [];
    if (priorities.isNotEmpty) {
      result = result.where((o) => priorities.contains(o.priority)).toList();
    }

    // Country filter
    final country = _filters['country'] as String? ?? '';
    if (country.isNotEmpty) {
      result = result
          .where((o) =>
              o.country.toLowerCase().contains(country.toLowerCase()))
          .toList();
    }

    // Delivery speed filter
    final speed = _filters['deliverySpeed'] as String? ?? '';
    if (speed.isNotEmpty) {
      result = result.where((o) => o.deliverySpeed == speed).toList();
    }

    // Tags filter
    final tags = _filters['tags'] as List<String>? ?? [];
    if (tags.isNotEmpty) {
      result = result
          .where((o) => tags.any((t) => o.tags.contains(t)))
          .toList();
    }

    // Deadline range
    final from = _filters['deadlineFrom'] as DateTime?;
    final to = _filters['deadlineTo'] as DateTime?;
    if (from != null || to != null) {
      result = result.where((o) {
        try {
          final parts = o.deadline.split('/');
          if (parts.length != 3) return true;
          final d = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          if (from != null && d.isBefore(from)) return false;
          if (to != null && d.isAfter(to)) return false;
          return true;
        } catch (_) {
          return true;
        }
      }).toList();
    }

    return result;
  }

  bool get _hasActiveFilters {
    final statuses = _filters['statuses'] as List<String>? ?? [];
    final priorities = _filters['priorities'] as List<String>? ?? [];
    final tags = _filters['tags'] as List<String>? ?? [];
    final country = _filters['country'] as String? ?? '';
    final speed = _filters['deliverySpeed'] as String? ?? '';
    return statuses.isNotEmpty ||
        priorities.isNotEmpty ||
        tags.isNotEmpty ||
        country.isNotEmpty ||
        speed.isNotEmpty ||
        _filters['deadlineFrom'] != null ||
        _filters['deadlineTo'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
      ),
      body: Column(
        children: [
          // Search + Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by ID, name, country, tag...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: _hasActiveFilters,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: _hasActiveFilters
                          ? AppColors.primary.withOpacity(0.1)
                          : null,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FilterSheet(
                          initialFilters: _filters,
                          onApply: (f) => setState(() => _filters = f),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firebaseService.streamAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data ?? [];
                final filtered = _applyFilters(allOrders);

                return Column(
                  children: [
                    // Count header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} Order${filtered.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtext,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: AppColors.textSubtext,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No orders found',
                                    style: TextStyle(
                                      color: AppColors.textSubtext,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {},
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 16),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final order = filtered[index];
                                  return OrderCard(
                                    order: order,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(
                                          orderDocId: order.id,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
