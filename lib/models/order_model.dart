import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String customerName;
  final String email;
  final String whatsapp;
  final String instagram;
  final String country;
  final String countryCode;
  final String orderDate;
  final String videoLength;
  final String deliverySpeed;
  final String deadline;
  final String status;
  final String priority;
  final List<String> tags;
  final String script;
  final String videoUrl;
  final Timestamp? createdAt;
  final List<Map<String, dynamic>> notes;
  final List<Map<String, dynamic>> timeline;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.email,
    required this.whatsapp,
    required this.instagram,
    required this.country,
    required this.countryCode,
    required this.orderDate,
    required this.videoLength,
    required this.deliverySpeed,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.tags,
    required this.script,
    required this.videoUrl,
    this.createdAt,
    required this.notes,
    required this.timeline,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      customerName: data['customerName'] ?? '',
      email: data['email'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      instagram: data['instagram'] ?? '',
      country: data['country'] ?? '',
      countryCode: data['countryCode'] ?? '',
      orderDate: data['orderDate'] ?? '',
      videoLength: data['videoLength'] ?? 'Short',
      deliverySpeed: data['deliverySpeed'] ?? 'Standard',
      deadline: data['deadline'] ?? '',
      status: data['status'] ?? 'Script Review',
      priority: data['priority'] ?? 'Normal',
      tags: List<String>.from(data['tags'] ?? []),
      script: data['script'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      notes: List<Map<String, dynamic>>.from(data['notes'] ?? []),
      timeline: List<Map<String, dynamic>>.from(data['timeline'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'email': email,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'country': country,
      'countryCode': countryCode,
      'orderDate': orderDate,
      'videoLength': videoLength,
      'deliverySpeed': deliverySpeed,
      'deadline': deadline,
      'status': status,
      'priority': priority,
      'tags': tags,
      'script': script,
      'videoUrl': videoUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'notes': notes,
      'timeline': timeline,
    };
  }

  int get daysUntilDeadline {
    try {
      final parts = deadline.split('/');
      if (parts.length != 3) return 999;
      final deadlineDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return deadlineDate.difference(today).inDays;
    } catch (_) {
      return 999;
    }
  }

  bool get isOverdue => daysUntilDeadline < 0 && status != 'Completed';
  bool get isDueToday => daysUntilDeadline == 0 && status != 'Completed';
  bool get isUrgent => daysUntilDeadline <= 1 && status != 'Completed';

  OrderModel copyWith({
    String? status,
    String? priority,
    List<Map<String, dynamic>>? notes,
    List<Map<String, dynamic>>? timeline,
    String? videoUrl,
    String? script,
  }) {
    return OrderModel(
      id: id,
      orderId: orderId,
      customerName: customerName,
      email: email,
      whatsapp: whatsapp,
      instagram: instagram,
      country: country,
      countryCode: countryCode,
      orderDate: orderDate,
      videoLength: videoLength,
      deliverySpeed: deliverySpeed,
      deadline: deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags,
      script: script ?? this.script,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt,
      notes: notes ?? this.notes,
      timeline: timeline ?? this.timeline,
    );
  }
}
