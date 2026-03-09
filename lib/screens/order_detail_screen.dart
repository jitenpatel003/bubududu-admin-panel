import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../services/email_service.dart';
import '../theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/deadline_badge.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/admin_notes_widget.dart';
import '../widgets/contact_panel_widget.dart';
import 'customer_history_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderDocId;

  const OrderDetailScreen({super.key, required this.orderDocId});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder<OrderModel?>(
      stream: _streamOrderByDocId(service, orderDocId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final order = snapshot.data;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Detail')),
            body: const Center(child: Text('Order not found')),
          );
        }
        return _OrderDetailBody(order: order, service: service);
      },
    );
  }

  Stream<OrderModel?> _streamOrderByDocId(
      FirebaseService service, String docId) {
    return service
        .streamAllOrders()
        .map((orders) => orders.where((o) => o.id == docId).firstOrNull);
  }
}

class _OrderDetailBody extends StatefulWidget {
  final OrderModel order;
  final FirebaseService service;

  const _OrderDetailBody({required this.order, required this.service});

  @override
  State<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<_OrderDetailBody> {
  final _emailService = EmailService();
  bool _approving = false;
  bool _updatingStatus = false;
  String? _selectedStatus;

  final List<String> _statuses = [
    'Script Review',
    'Script Approved',
    'In Progress',
    'Preview Sent',
    'Completed',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  void didUpdateWidget(_OrderDetailBody old) {
    super.didUpdateWidget(old);
    if (old.order.status != widget.order.status) {
      _selectedStatus = widget.order.status;
    }
  }

  Future<void> _approveScript() async {
    setState(() => _approving = true);
    try {
      await widget.service.approveScript(widget.order.id);
      await _emailService.sendScriptApprovedEmail(
        toEmail: widget.order.email,
        customerName: widget.order.customerName,
        orderId: widget.order.orderId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Script approved and email sent'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  Future<void> _requestChanges() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Script Changes'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the required changes...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Request Changes'),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await widget.service.requestScriptChanges(
        widget.order.id,
        controller.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change request added'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
    controller.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == widget.order.status) return;
    setState(() {
      _updatingStatus = true;
      _selectedStatus = newStatus;
    });
    try {
      await widget.service.updateOrderStatus(widget.order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _selectedStatus = widget.order.status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderId),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(status: order.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Customer Details
            _sectionCard(
              title: 'Customer Details',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _infoRow(Icons.person, 'Name', order.customerName),
                  _infoRow(Icons.email_outlined, 'Email', order.email),
                  if (order.whatsapp.isNotEmpty)
                    _infoRow(Icons.phone_outlined, 'WhatsApp', order.whatsapp),
                  if (order.instagram.isNotEmpty)
                    _infoRow(
                        Icons.camera_alt_outlined, 'Instagram', order.instagram),
                  _infoRow(Icons.location_on_outlined, 'Country', order.country),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section 2: Video Details
            _sectionCard(
              title: 'Video Details',
              icon: Icons.videocam_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.tag, 'Order ID', order.orderId),
                  _infoRow(Icons.calendar_today, 'Order Date', order.orderDate),
                  _infoRow(
                      Icons.video_library_outlined, 'Length', order.videoLength),
                  _infoRow(
                      Icons.local_shipping_outlined, 'Delivery', order.deliverySpeed),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.textSubtext),
                      const SizedBox(width: 8),
                      const Text(
                        'Deadline',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSubtext,
                        ),
                      ),
                      const Spacer(),
                      DeadlineBadge(order: order),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_outline, size: 16, color: AppColors.textSubtext),
                      const SizedBox(width: 8),
                      const Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSubtext,
                        ),
                      ),
                      const Spacer(),
                      PriorityBadge(priority: order.priority),
                    ],
                  ),
                  if (order.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: order.tags
                          .map((t) => Chip(
                                label: Text(t,
                                    style: const TextStyle(fontSize: 12)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section 3: Script
            _sectionCard(
              title: 'Script',
              icon: Icons.description_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (order.script.isEmpty)
                    const Text(
                      'No script provided.',
                      style: TextStyle(
                          color: AppColors.textSubtext, fontSize: 13),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        order.script,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _approving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline,
                                  size: 18),
                          label: const Text('Approve Script'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          onPressed:
                              _approving || order.status == 'Script Approved'
                                  ? null
                                  : _approveScript,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Request Changes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
                          ),
                          onPressed: _requestChanges,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section 4: Status Update
            _sectionCard(
              title: 'Update Status',
              icon: Icons.update,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: _statuses
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: _updatingStatus
                        ? null
                        : (v) {
                            if (v != null) _updateStatus(v);
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section 5: Admin Notes
            _sectionCard(
              title: 'Admin Notes',
              icon: Icons.note_outlined,
              child: AdminNotesWidget(
                docId: order.id,
                notes: order.notes,
              ),
            ),
            const SizedBox(height: 12),

            // Section 6: Timeline
            _sectionCard(
              title: 'Timeline',
              icon: Icons.timeline,
              child: TimelineWidget(timeline: order.timeline),
            ),
            const SizedBox(height: 12),

            // Section 7: Quick Contact
            _sectionCard(
              title: 'Quick Contact',
              icon: Icons.contact_phone_outlined,
              child: ContactPanelWidget(order: order),
            ),
            const SizedBox(height: 12),

            // Section 8: Customer History
            _sectionCard(
              title: 'Customer History',
              icon: Icons.history,
              child: _CustomerHistoryInline(order: order),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSubtext),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSubtext,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerHistoryInline extends StatelessWidget {
  final OrderModel order;
  const _CustomerHistoryInline({required this.order});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return FutureBuilder<List<OrderModel>>(
      future: service.getOrdersByEmail(order.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data ?? [];
        final others = orders.where((o) => o.id != order.id).toList();

        if (others.isEmpty) {
          return const Row(
            children: [
              Icon(Icons.star_outline, size: 16, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'First order from this customer',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${others.length} previous order${others.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSubtext,
              ),
            ),
            const SizedBox(height: 8),
            ...others.take(5).map((o) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderDocId: o.id),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          o.orderId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          o.status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSubtext,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textSubtext,
                        ),
                      ],
                    ),
                  ),
                )),
            if (others.length > 5)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerHistoryScreen(email: order.email),
                  ),
                ),
                child: Text('View all ${others.length} orders'),
              ),
          ],
        );
      },
    );
  }
}
