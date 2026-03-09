const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ─── Trigger 1: onOrderCreated ────────────────────────────────────────────
exports.onOrderCreated = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const customerName = data.customerName || "Unknown";
    const country = data.country || "";
    const orderId = data.orderId || snap.id;

    const message = {
      notification: {
        title: "New Order Received",
        body: `${customerName} from ${country}`,
      },
      data: {
        orderId: orderId,
        type: "new_order",
      },
      topic: "admin_alerts",
    };

    try {
      await messaging.send(message);

      // Store alert in Firestore
      await db.collection("alerts").add({
        type: "new_order",
        title: "New Order Received",
        message: `${customerName} from ${country}`,
        orderId: orderId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error("Error sending new order notification:", error);
    }
  });

// ─── Trigger 2: onDeadlineCheck ──────────────────────────────────────────
exports.onDeadlineCheck = functions.pubsub
  .schedule("every day 09:00")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const activeStatuses = [
      "Script Review",
      "Script Approved",
      "In Progress",
      "Preview Sent",
    ];

    const snap = await db
      .collection("orders")
      .where("status", "in", activeStatuses)
      .get();

    const batch = [];

    for (const doc of snap.docs) {
      const data = doc.data();
      const deadlineStr = data.deadline; // format: dd/MM/yyyy
      const orderId = data.orderId || doc.id;
      const customerName = data.customerName || "Unknown";

      if (!deadlineStr) continue;

      const parts = deadlineStr.split("/");
      if (parts.length !== 3) continue;

      const deadlineDate = new Date(
        parseInt(parts[2]),
        parseInt(parts[1]) - 1,
        parseInt(parts[0])
      );

      const isTomorrow =
        deadlineDate.getFullYear() === tomorrow.getFullYear() &&
        deadlineDate.getMonth() === tomorrow.getMonth() &&
        deadlineDate.getDate() === tomorrow.getDate();

      const isOverdue = deadlineDate < today;

      if (isTomorrow) {
        batch.push({
          notification: {
            title: "Deadline Tomorrow",
            body: `${orderId} - ${customerName} due tomorrow`,
          },
          data: {
            orderId: orderId,
            type: "deadline_warning",
          },
          alertTitle: "Deadline Tomorrow",
          alertMessage: `${orderId} - ${customerName} due tomorrow`,
          alertType: "deadline_warning",
        });
      } else if (isOverdue) {
        batch.push({
          notification: {
            title: "Order Overdue",
            body: `${orderId} - ${customerName} is overdue`,
          },
          data: {
            orderId: orderId,
            type: "overdue",
          },
          alertTitle: "Order Overdue",
          alertMessage: `${orderId} - ${customerName} is overdue`,
          alertType: "overdue",
        });
      }
    }

    for (const item of batch) {
      try {
        await messaging.send({
          notification: item.notification,
          data: item.data,
          topic: "admin_alerts",
        });

        await db.collection("alerts").add({
          type: item.alertType,
          title: item.alertTitle,
          message: item.alertMessage,
          orderId: item.data.orderId,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (error) {
        console.error("Error sending deadline notification:", error);
      }
    }

    console.log(`Processed ${batch.length} deadline notifications`);
    return null;
  });
