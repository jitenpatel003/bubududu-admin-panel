import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart'
    show NotificationService, firebaseMessagingBackgroundHandler;
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/draft_orders_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/order_detail_screen.dart';

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Set navigation callback for notification taps
  notificationService.onOrderNotificationTapped = (orderId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => _OrderDeepLinkScreen(orderId: orderId),
      ),
    );
  };

  // Handle cold start notification
  await notificationService.handleInitialMessage();

  runApp(const BubuDuduAdminApp());
}

class BubuDuduAdminApp extends StatelessWidget {
  const BubuDuduAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubu Dudu Admin Panel',
      theme: AppTheme.theme,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data != null) {
            return const MainNavigationScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrdersScreen(),
    const CalendarScreen(),
    const DraftOrdersScreen(),
    const AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drafts),
            label: 'Drafts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}

/// Helper screen for deep link navigation by orderId field
class _OrderDeepLinkScreen extends StatelessWidget {
  final String orderId;
  const _OrderDeepLinkScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseService().streamAllOrders().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final orders = snapshot.data!;
        final order = orders.where((o) => o.orderId == orderId).firstOrNull;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: Text(orderId)),
            body: const Center(child: Text('Order not found')),
          );
        }
        return OrderDetailScreen(orderDocId: order.id);
      },
    );
  }
}
