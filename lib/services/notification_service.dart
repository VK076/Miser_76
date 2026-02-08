import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true; // Android doesn't need runtime permission for notifications
  }

  // Show budget alert notification
  Future<void> showBudgetAlert({
    required String category,
    required double percentage,
    required String currencySymbol,
    required double spent,
    required double budget,
  }) async {
    String title;
    String body;

    if (percentage >= 100) {
      title = '🚨 Budget Exceeded!';
      body = 'You\'ve spent $currencySymbol${spent.toStringAsFixed(0)} of $currencySymbol${budget.toStringAsFixed(0)} in $category';
    } else if (percentage >= 90) {
      title = '⚠️ Budget Alert';
      body = 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $category budget';
    } else {
      title = '💡 Budget Notice';
      body = 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $category budget';
    }

    await _showNotification(
      id: category.hashCode,
      title: title,
      body: body,
      payload: 'budget:$category',
    );
  }

  // Show recurring transaction reminder
  Future<void> showRecurringTransactionReminder({
    required String type, // 'expense' or 'income'
    required String description,
    required String currencySymbol,
    required double amount,
  }) async {
    final emoji = type == 'expense' ? '💸' : '💰';
    final title = '$emoji Recurring ${type == 'expense' ? 'Expense' : 'Income'} Due';
    final body = '$description - $currencySymbol${amount.toStringAsFixed(0)}';

    await _showNotification(
      id: description.hashCode,
      title: title,
      body: body,
      payload: 'recurring:$type:$description',
    );
  }

  // Show monthly summary notification
  Future<void> showMonthlySummary({
    required String currencySymbol,
    required double totalIncome,
    required double totalExpenses,
    required double netBalance,
  }) async {
    final title = '📊 Monthly Summary';
    final body = 'Income: $currencySymbol${totalIncome.toStringAsFixed(0)} | '
        'Expenses: $currencySymbol${totalExpenses.toStringAsFixed(0)} | '
        'Balance: $currencySymbol${netBalance.toStringAsFixed(0)}';

    await _showNotification(
      id: 999,
      title: title,
      body: body,
      payload: 'summary:monthly',
    );
  }

  // Show savings milestone notification
  Future<void> showSavingsMilestone({
    required String currencySymbol,
    required double savedAmount,
    required double savingsRate,
  }) async {
    final title = '🎉 Savings Milestone!';
    final body = 'You\'ve saved $currencySymbol${savedAmount.toStringAsFixed(0)} this month (${savingsRate.toStringAsFixed(0)}% savings rate)';

    await _showNotification(
      id: 998,
      title: title,
      body: body,
      payload: 'milestone:savings',
    );
  }

  // Generic notification method
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finance_app_channel',
      'Finance App Notifications',
      channelDescription: 'Notifications for budget alerts and reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
