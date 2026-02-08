import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'bank_sms_parser.dart';
import 'expense_database.dart';

class SmsConfirmationService {
  static final SmsConfirmationService _instance = SmsConfirmationService._internal();
  factory SmsConfirmationService() => _instance;
  SmsConfirmationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ExpenseDatabase _db = ExpenseDatabase();
  
  // Store pending transactions for later retrieval
  final Map<int, ParsedTransaction> _pendingTransactions = {};
  int _notificationIdCounter = 1000; // Start from 1000 to avoid conflicts

  /// Initialize notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Show confirmation notification for parsed transaction
  Future<void> showConfirmationNotification(ParsedTransaction transaction) async {
    final notificationId = _notificationIdCounter++;
    _pendingTransactions[notificationId] = transaction;

    // Format notification content
    final title = '🏦 Transaction Detected (${transaction.confidence}% confident)';
    final body = '₹${transaction.amount?.toStringAsFixed(2)} - ${transaction.category}\n'
        '"${transaction.description}"';

    // Android notification with action buttons
    final androidDetails = AndroidNotificationDetails(
      'sms_transactions',
      'SMS Transactions',
      channelDescription: 'Notifications for detected bank transactions',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        const AndroidNotificationAction(
          'confirm',
          '✓ Add Expense',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'ignore',
          '✗ Ignore',
          cancelNotification: true,
        ),
      ],
    );

    // iOS notification
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationId,
      title,
      body,
      details,
      payload: notificationId.toString(),
    );

    // Auto-dismiss after 24 hours
    Future.delayed(const Duration(hours: 24), () {
      _pendingTransactions.remove(notificationId);
    });
  }

  /// Handle notification tap/action
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final notificationId = int.tryParse(response.payload ?? '');
    if (notificationId == null) return;

    final transaction = _pendingTransactions[notificationId];
    if (transaction == null) return;

    // Handle action
    if (response.actionId == 'confirm') {
      // Add expense to database
      await _confirmTransaction(transaction);
      _pendingTransactions.remove(notificationId);
    } else if (response.actionId == 'ignore') {
      // Just remove from pending
      _pendingTransactions.remove(notificationId);
    } else {
      // Notification body tapped - could open app to review screen
      // For now, just confirm
      await _confirmTransaction(transaction);
      _pendingTransactions.remove(notificationId);
    }
  }

  /// Confirm and add transaction to database
  Future<void> _confirmTransaction(ParsedTransaction transaction) async {
    final expense = transaction.toExpense();
    await _db.addExpense(expense);
    
    // Show success notification
    await _showSuccessNotification(transaction);
  }

  /// Show success notification after adding expense
  Future<void> _showSuccessNotification(ParsedTransaction transaction) async {
    const androidDetails = AndroidNotificationDetails(
      'sms_success',
      'Transaction Added',
      channelDescription: 'Confirmation when transaction is added',
      importance: Importance.low,
      priority: Priority.low,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationIdCounter++,
      '✓ Expense Added',
      '₹${transaction.amount?.toStringAsFixed(2)} added to ${transaction.category}',
      details,
    );
  }

  /// Get all pending transactions
  List<ParsedTransaction> getPendingTransactions() {
    return _pendingTransactions.values.toList();
  }

  /// Clear all pending transactions
  void clearPending() {
    _pendingTransactions.clear();
  }
}
