import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bank_sms_parser.dart';
import 'sms_confirmation_service.dart';

class SmsListenerService {
  static final SmsListenerService _instance = SmsListenerService._internal();
  factory SmsListenerService() => _instance;
  SmsListenerService._internal();

  final Telephony telephony = Telephony.instance;
  final BankSmsParser _parser = BankSmsParser();
  final SmsConfirmationService _confirmationService = SmsConfirmationService();
  
  bool _isListening = false;
  int _confidenceThreshold = 60; // Default: only show notifications for 60%+ confidence

  /// Initialize SMS listener (Android only)
  Future<bool> initialize({int confidenceThreshold = 60}) async {
    if (!Platform.isAndroid) {
      print('SMS listening is only supported on Android');
      return false;
    }

    _confidenceThreshold = confidenceThreshold;

    // Check if already listening
    if (_isListening) {
      return true;
    }

    // Request SMS permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('SMS permissions not granted');
      return false;
    }

    // Start listening to incoming SMS
    telephony.listenIncomingSms(
      onNewMessage: _onSmsReceived,
      onBackgroundMessage: _onBackgroundSmsReceived,
    );

    _isListening = true;
    print('SMS Listener initialized successfully');
    return true;
  }

  /// Request SMS permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.sms.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }

    return false;
  }

  /// Handle incoming SMS (foreground)
  void _onSmsReceived(SmsMessage message) {
    _processSms(message.address ?? 'Unknown', message.body ?? '');
  }

  /// Handle incoming SMS (background) - static method required by telephony package
  static void _onBackgroundSmsReceived(SmsMessage message) {
    // Background handler - limited functionality
    // We'll process in foreground for now
    print('Background SMS received from: ${message.address}');
  }

  /// Process SMS message
  void _processSms(String sender, String body) {
    print('SMS received from: $sender');

    // Check if sender is a bank
    if (!BankSmsParser.isBankSender(sender)) {
      print('Not a bank SMS, ignoring');
      return;
    }

    print('Bank SMS detected, parsing...');

    // Parse the SMS
    final parsed = _parser.parse(body, sender);

    print('Parsed result: $parsed');

    // Check confidence threshold
    if (parsed.confidence < _confidenceThreshold) {
      print('Confidence too low (${parsed.confidence}%), ignoring');
      return;
    }

    // Show confirmation notification
    _confirmationService.showConfirmationNotification(parsed);
  }

  /// Stop listening to SMS
  void dispose() {
    _isListening = false;
    print('SMS Listener stopped');
  }

  /// Update confidence threshold
  void setConfidenceThreshold(int threshold) {
    _confidenceThreshold = threshold.clamp(0, 100);
  }

  /// Check if SMS permissions are granted
  Future<bool> hasPermissions() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Get current listening status
  bool get isListening => _isListening;
}
