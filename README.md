# Bubu Dudu Admin Panel

A production-ready Flutter Android application for managing custom animation video orders.

## Features

- **Dashboard**: Real-time overview of active orders (Script Approved, In Progress, Preview Sent) with stats
- **Orders**: Browse all orders with search and advanced filters
- **Calendar**: Monthly calendar view with order deadlines
- **Drafts**: Manage draft orders with restore/delete actions
- **Alerts**: Notification history with read/unread states

## Tech Stack

- **Flutter** (Android only)
- **Firebase Auth** — Admin authentication
- **Cloud Firestore** — Real-time database
- **Firebase Cloud Messaging** — Push notifications
- **Firebase Storage** — File storage
- **EmailJS** — Email notifications
- **TextMeBot** — WhatsApp messaging

## Project Structure

```
lib/
  main.dart                        # App entry point, navigation
  firebase_options.dart            # Firebase configuration
  theme.dart                       # Design system (colors, fonts)
  models/
    order_model.dart               # Order data model
  services/
    firebase_service.dart          # Firestore + Auth operations
    notification_service.dart      # FCM + local notifications
    email_service.dart             # EmailJS integration
    whatsapp_service.dart          # TextMeBot integration
  screens/
    login_screen.dart
    dashboard_screen.dart
    orders_screen.dart
    order_detail_screen.dart
    calendar_screen.dart
    draft_orders_screen.dart
    alerts_screen.dart
    customer_history_screen.dart
  widgets/
    order_card.dart
    stats_widget.dart
    filter_sheet.dart
    timeline_widget.dart
    deadline_badge.dart
    priority_badge.dart
    status_badge.dart
    admin_notes_widget.dart
    contact_panel_widget.dart
functions/
  index.js                         # Firebase Cloud Functions
android/
  app/
    google-services.json           # Firebase Android config
```

## Setup

1. Install Flutter SDK
2. Run `flutter pub get`
3. Build for Android: `flutter build apk`

## Firebase Configuration

Project ID: `bubu-dudu-admin-panel`

### Firestore Collections

- `orders` — Order documents
- `admin_tokens` — FCM tokens
- `alerts` — Notification history

### Cloud Functions

- `onOrderCreated` — Sends FCM notification when new order is created
- `onDeadlineCheck` — Daily scheduled check for deadline warnings and overdue orders

## Order Statuses

- Script Review
- Script Approved
- In Progress
- Preview Sent
- Completed
- Draft