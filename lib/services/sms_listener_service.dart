import 'dart:io';
import 'package:sms_advanced/sms_advanced.dart';
import 'bank_sms_parser.dart';
import 'sms_confirmation_service.dart';

class SmsListenerService {
  static final SmsListenerService _instance = SmsListenerService._internal();
  factory SmsListenerService() => _instance;
  SmsListenerService._internal();

  final SmsReceiver _smsReceiver = SmsReceiver();
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
    _smsReceiver.onSmsReceived!.listen((SmsMessage message) {
      _onSmsReceived(message);
    });

    _isListening = true;
    print('SMS Listener initialized successfully');
    return true;
  }

  /// Request SMS permissions
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      // sms_advanced handles permissions internally
      return true;
    } catch (e) {
      print('Error requesting SMS permissions: $e');
      return false;
    }
  }

  /// Handle incoming SMS
  void _onSmsReceived(SmsMessage message) {
    _processSms(message.sender ?? 'Unknown', message.body ?? '');
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
    if (!Platform.isAndroid) {
      return false;
    }
    
    // Telephony package doesn't have a direct permission check
    // We'll assume permissions are granted if listener is active
    return _isListening;
  }

  /// Get current listening status
  bool get isListening => _isListening;
}
