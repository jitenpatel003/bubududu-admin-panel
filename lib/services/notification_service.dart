import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handled by the system; deep link on tap is handled in main
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for navigating to order detail
  Function(String orderId)? onOrderNotificationTapped;

  static const AndroidNotificationChannel _newOrdersChannel =
      AndroidNotificationChannel(
    'new_orders',
    'New Orders',
    description: 'Notifications for new orders',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _deadlineChannel =
      AndroidNotificationChannel(
    'deadline_alerts',
    'Deadline Alerts',
    description: 'Notifications for deadline warnings',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'general',
    'General',
    description: 'General notifications',
    importance: Importance.defaultImportance,
  );

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create notification channels on Android
    if (Platform.isAndroid) {
      final plugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(_newOrdersChannel);
      await plugin?.createNotificationChannel(_deadlineChannel);
      await plugin?.createNotificationChannel(_generalChannel);
    }

    // Initialize local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null && payload.isNotEmpty) {
          onOrderNotificationTapped?.call(payload);
        }
      },
    );

    // Subscribe to topic
    await _messaging.subscribeToTopic('admin_alerts');

    // Save FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseService().saveFcmToken(token);
    }

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      FirebaseService().saveFcmToken(newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> handleInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleMessageOpenedApp(initial);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification == null) return;

    final channel = _channelForType(message.data['type'] ?? '');

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['orderId'],
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final orderId = message.data['orderId'];
    if (orderId != null && orderId.isNotEmpty) {
      onOrderNotificationTapped?.call(orderId);
    }
  }

  AndroidNotificationChannel _channelForType(String type) {
    switch (type) {
      case 'new_order':
        return _newOrdersChannel;
      case 'deadline_warning':
      case 'overdue':
        return _deadlineChannel;
      default:
        return _generalChannel;
    }
  }
}
