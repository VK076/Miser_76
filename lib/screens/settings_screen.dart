import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../services/notification_service.dart';
import '../services/backup_service.dart';
import 'manage_wallets_screen.dart';
import 'goals_screen.dart';
import 'whatsapp_simulation_screen.dart';
import '../main.dart';
import '../services/sms_listener_service.dart';
import 'dart:io';
import 'sms_test_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Currency selectedCurrency;
  final Function(Currency) onCurrencyChanged;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService();
  final _smsListener = SmsListenerService();
  bool _budgetAlertsEnabled = true;
  bool _dailyRemindersEnabled = true;
  bool _recurringRemindersEnabled = true;
  bool _smsAutoCaptureEnabled = false;
  int _smsConfidenceThreshold = 60;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    // In a real app, these would be saved in SharedPreferences
    // For now, we'll keep them in memory or default to true
    setState(() {
      _budgetAlertsEnabled = true;
      _dailyRemindersEnabled = true;
      _recurringRemindersEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance', textColor),
          _buildThemeOption(isDark),
          const Divider(),
          _buildSectionHeader('Preferences', textColor),
          _buildCurrencyOption(isDark),
           ListTile(
            leading: Icon(Icons.account_balance_wallet, color: isDark ? Colors.white70 : Colors.black54),
            title: const Text('Manage Wallets'),
            subtitle: const Text('Add or edit your accounts'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const ManageWalletsScreen())
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.flag, color: isDark ? Colors.white70 : Colors.black54),
            title: const Text('Savings Goals'),
            subtitle: const Text('Track your financial targets'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalsScreen())
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Notifications', textColor),
          _buildNotificationOption(
            title: 'Budget Alerts',
            subtitle: 'Get notified when you approach budget limits',
            value: _budgetAlertsEnabled,
            onChanged: (val) {
              setState(() => _budgetAlertsEnabled = val);
              // Save preference
            },
          ),
          _buildNotificationOption(
            title: 'Daily Reminders',
            subtitle: 'Remind me to log expenses daily',
            value: _dailyRemindersEnabled,
            onChanged: (val) {
              setState(() => _dailyRemindersEnabled = val);
              if (val) {
                // Schedule daily reminder
              } else {
                _notificationService.cancelAllNotifications(); // This might be too aggressive, ideally cancel specific ID
              }
            },
          ),
          _buildNotificationOption(
            title: 'Recurring Transactions',
            subtitle: 'Reminders for upcoming recurring payments',
            value: _recurringRemindersEnabled,
            onChanged: (val) {
              setState(() => _recurringRemindersEnabled = val);
              // Save preference
            },
          ),
          const Divider(),
          _buildSectionHeader('Data Management', textColor),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export or import your data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showBackupDialog(context),
          ),
          const Divider(),
          if (Platform.isAndroid) ..._buildSmsSettings(isDark),
          if (Platform.isAndroid) const Divider(),
          _buildSectionHeader('Developer Options', textColor),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.teal),
            title: const Text('Finance Buddy Simulator'),
            subtitle: const Text('Test WhatsApp/Deep Link parsing'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const WhatsappSimulationScreen())
              );
            },
          ),
          if (Platform.isAndroid)
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.teal),
              title: const Text('SMS Parser Test'),
              subtitle: const Text('Test bank SMS parsing'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SmsTestScreen())
                );
              },
            ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildThemeOption(bool isDark) {
    return SwitchListTile(
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.white70 : Colors.black54),
      title: const Text('Dark Mode'),
      value: isDark,
      onChanged: (val) => widget.onThemeChanged(val),
      activeColor: AppColors.primary,
    );
  }

  Widget _buildCurrencyOption(bool isDark) {
    return ListTile(
      leading: Icon(Icons.currency_exchange, color: isDark ? Colors.white70 : Colors.black54),
      title: const Text('Currency'),
      subtitle: Text('${widget.selectedCurrency.name} (${widget.selectedCurrency.symbol})'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select Currency',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: CurrencyManager.allCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = CurrencyManager.allCurrencies[index];
                      final isSelected = currency.code == widget.selectedCurrency.code;
                      
                      return ListTile(
                        leading: Text(
                          currency.symbol,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        title: Text('${currency.code} - ${currency.name}'),
                        trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                        onTap: () {
                          widget.onCurrencyChanged(currency);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    final backupService = BackupService();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload, color: AppColors.primary),
              title: const Text('Export Data'),
              subtitle: const Text('Save a backup of all your data'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await backupService.createBackup();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup created successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.orange),
              title: const Text('Import Data'),
              subtitle: const Text('Restore from a backup file (Overwrites current data)'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('⚠️ Warning'),
                    content: const Text('This will overwite your current data with the backup. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Restore', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await backupService.restoreBackup();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data restored successfully! Please restart app if data doesn\'t appear.')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore failed: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  List<Widget> _buildSmsSettings(bool isDark) {
    return [
      _buildSectionHeader('Smart SMS Capture (Android)', isDark ? Colors.white : Colors.black87),
      SwitchListTile(
        secondary: const Icon(Icons.sms, color: Colors.teal),
        title: const Text('Auto-Capture Bank SMS'),
        subtitle: const Text('Automatically detect and parse bank transaction messages'),
        value: _smsAutoCaptureEnabled,
        onChanged: (val) async {
          if (val) {
            // Request permissions and enable
            final success = await _smsListener.initialize(
              confidenceThreshold: _smsConfidenceThreshold,
            );
            setState(() => _smsAutoCaptureEnabled = success);
            
            if (!success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SMS permissions required')),
                );
              }
            }
          } else {
            // Disable
            _smsListener.dispose();
            setState(() => _smsAutoCaptureEnabled = false);
          }
        },
        activeColor: AppColors.primary,
      ),
      if (_smsAutoCaptureEnabled) ...[
        ListTile(
          leading: const Icon(Icons.tune, color: Colors.grey),
          title: const Text('Confidence Threshold'),
          subtitle: Text('Only notify for ${_smsConfidenceThreshold}%+ confidence'),
        ),
        Slider(
          value: _smsConfidenceThreshold.toDouble(),
          min: 30,
          max: 100,
          divisions: 7,
          label: '${_smsConfidenceThreshold}%',
          onChanged: (val) {
            setState(() => _smsConfidenceThreshold = val.toInt());
            _smsListener.setConfidenceThreshold(_smsConfidenceThreshold);
          },
          activeColor: AppColors.primary,
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.grey),
          title: const Text('How it works'),
          subtitle: const Text(
            'When a bank SMS is received, the app will parse it and show a notification. '
            'Tap "Confirm" to add the expense, or "Ignore" to dismiss.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    ];
  }
}
