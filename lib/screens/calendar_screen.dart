import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _service = FirebaseService();

  Map<DateTime, List<OrderModel>> _buildEventMap(List<OrderModel> orders) {
    final map = <DateTime, List<OrderModel>>{};
    for (final order in orders) {
      try {
        final parts = order.deadline.split('/');
        if (parts.length != 3) continue;
        final d = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final key = DateTime(d.year, d.month, d.day);
        map.putIfAbsent(key, () => []).add(order);
      } catch (_) {}
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: StreamBuilder<List<OrderModel>>(
        stream: _service.streamAllOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          final eventMap = _buildEventMap(orders);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                  final key = DateTime(
                      selected.year, selected.month, selected.day);
                  final dayOrders = eventMap[key] ?? [];
                  if (dayOrders.isNotEmpty) {
                    _showDayOrders(context, selected, dayOrders);
                  }
                },
                onPageChanged: (day) {
                  setState(() => _focusedDay = day);
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return eventMap[key] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final orderEvents = events.cast<OrderModel>();
                    final dots = orderEvents.take(3).toList();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...dots.map((o) => Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.priorityColor(o.priority),
                              ),
                            )),
                        if (orderEvents.length > 3)
                          Text(
                            '+${orderEvents.length - 3}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSubtext,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0x336D28D9),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _selectedDay == null
                    ? const Center(
                        child: Text(
                          'Select a date to see orders',
                          style: TextStyle(color: AppColors.textSubtext),
                        ),
                      )
                    : Builder(builder: (context) {
                        final key = DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        );
                        final dayOrders = eventMap[key] ?? [];
                        if (dayOrders.isEmpty) {
                          return const Center(
                            child: Text(
                              'No orders on this date',
                              style: TextStyle(color: AppColors.textSubtext),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dayOrders.length,
                          itemBuilder: (context, index) {
                            final order = dayOrders[index];
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
                        );
                      }),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDayOrders(
      BuildContext context, DateTime day, List<OrderModel> dayOrders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      _formatDate(day),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayOrders.length} order${dayOrders.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: dayOrders.length,
                  itemBuilder: (context, index) {
                    final order = dayOrders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(
                              orderDocId: order.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime day) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[day.month - 1]} ${day.day}';
  }
}
