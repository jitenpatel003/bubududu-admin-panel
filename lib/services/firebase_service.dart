import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Auth ────────────────────────────────────────────────────────────────

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Streams ─────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> streamActiveOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: [
          'Script Approved',
          'In Progress',
          'Preview Sent',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Stream<List<OrderModel>> streamAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Stream<List<OrderModel>> streamDraftOrders() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'Draft')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Stream<OrderModel?> streamOrder(String orderId) {
    return _firestore
        .collection('orders')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return OrderModel.fromFirestore(snap.docs.first);
    });
  }

  Stream<List<OrderModel>> streamOrdersByEmail(String email) {
    return _firestore
        .collection('orders')
        .where('email', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  // ─── Fetch ───────────────────────────────────────────────────────────────

  Future<OrderModel?> getOrderByDocId(String docId) async {
    final doc = await _firestore.collection('orders').doc(docId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<List<OrderModel>> getOrdersByEmail(String email) async {
    final snap = await _firestore
        .collection('orders')
        .where('email', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(OrderModel.fromFirestore).toList();
  }

  // ─── Updates ─────────────────────────────────────────────────────────────

  Future<void> updateOrderStatus(String docId, String newStatus) async {
    await _firestore.collection('orders').doc(docId).update({
      'status': newStatus,
      'timeline': FieldValue.arrayUnion([
        {
          'event': 'Status changed to $newStatus',
          'timestamp': Timestamp.now(),
        }
      ]),
    });
  }

  Future<void> updateOrderPriority(String docId, String priority) async {
    await _firestore.collection('orders').doc(docId).update({
      'priority': priority,
    });
  }

  Future<void> approveScript(String docId) async {
    await _firestore.collection('orders').doc(docId).update({
      'status': 'Script Approved',
      'timeline': FieldValue.arrayUnion([
        {
          'event': 'Script Approved',
          'timestamp': Timestamp.now(),
        }
      ]),
    });
  }

  Future<void> requestScriptChanges(String docId, String changeNote) async {
    final now = Timestamp.now();
    await _firestore.collection('orders').doc(docId).update({
      'timeline': FieldValue.arrayUnion([
        {
          'event': 'Script Change Requested',
          'timestamp': now,
        }
      ]),
      'notes': FieldValue.arrayUnion([
        {
          'text': changeNote,
          'timestamp': now,
        }
      ]),
    });
  }

  Future<void> addNote(String docId, String note) async {
    await _firestore.collection('orders').doc(docId).update({
      'notes': FieldValue.arrayUnion([
        {
          'text': note,
          'timestamp': Timestamp.now(),
        }
      ]),
    });
  }

  Future<void> restoreOrder(String docId) async {
    await _firestore.collection('orders').doc(docId).update({
      'status': 'Script Review',
      'timeline': FieldValue.arrayUnion([
        {
          'event': 'Order restored from Draft',
          'timestamp': Timestamp.now(),
        }
      ]),
    });
  }

  Future<void> deleteOrder(String docId) async {
    await _firestore.collection('orders').doc(docId).delete();
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<Map<String, int>> getDashboardStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activeSnap = await _firestore
        .collection('orders')
        .where('status', whereIn: [
          'Script Approved',
          'In Progress',
          'Preview Sent',
        ])
        .get();

    final allActiveSnap = await _firestore
        .collection('orders')
        .where('status', isNotEqualTo: 'Completed')
        .get();

    int urgent = 0;
    int dueToday = 0;
    int overdue = 0;

    for (final doc in allActiveSnap.docs) {
      final order = OrderModel.fromFirestore(doc);
      if (order.status == 'Draft') continue;
      if (order.isUrgent && !order.isDueToday) urgent++;
      if (order.isDueToday) dueToday++;
      if (order.isOverdue) overdue++;
    }

    return {
      'active': activeSnap.docs.length,
      'urgent': urgent,
      'dueToday': dueToday,
      'overdue': overdue,
    };
  }

  // ─── FCM Token ───────────────────────────────────────────────────────────

  Future<void> saveFcmToken(String token) async {
    await _firestore.collection('admin_tokens').doc('main').set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── Alerts ──────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  Future<void> markAllAlertsRead() async {
    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('alerts')
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
