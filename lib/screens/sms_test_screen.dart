import 'package:flutter/material.dart';
import '../services/bank_sms_parser.dart';
import '../services/sms_confirmation_service.dart';
import '../constants/app_constants.dart';

class SmsTestScreen extends StatefulWidget {
  const SmsTestScreen({Key? key}) : super(key: key);

  @override
  State<SmsTestScreen> createState() => _SmsTestScreenState();
}

class _SmsTestScreenState extends State<SmsTestScreen> {
  final _parser = BankSmsParser();
  final _confirmationService = SmsConfirmationService();
  final _senderController = TextEditingController(text: 'HDFC');
  final _messageController = TextEditingController();
  
  final List<String> _sampleMessages = [
    'Rs.500 debited from A/c XX1234 on 01-Feb-24 at Amazon',
    'INR 1,200.00 spent on ICICI Bank Card XX5678 at Swiggy',
    'Dear Customer, Rs 300 debited from your A/c XX9012 for UPI/Zomato',
    'Rs.150 debited from Paytm Wallet for Coffee Shop',
    'Your A/c XX4567 is debited with Rs.2500 for Rent Payment',
    'Rs 89.50 spent at Uber on 08-Feb-24 using Card XX8901',
  ];

  ParsedTransaction? _lastParsed;

  @override
  void initState() {
    super.initState();
    _confirmationService.initialize();
  }

  void _testParse() {
    final sender = _senderController.text.trim();
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    final parsed = _parser.parse(message, sender);
    setState(() => _lastParsed = parsed);

    // Show notification if confidence is high enough
    if (parsed.confidence >= 60) {
      _confirmationService.showConfirmationNotification(parsed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent! Check your notification tray'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('SMS Parser Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sender input
          TextField(
            controller: _senderController,
            decoration: const InputDecoration(
              labelText: 'Sender (e.g., HDFC, ICICI)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Message input
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'SMS Message',
              hintText: 'Paste or type a bank SMS here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Test button
          ElevatedButton.icon(
            onPressed: _testParse,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Parse & Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Sample messages
          Text(
            'Sample Messages (Tap to use)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          ..._sampleMessages.map((msg) => Card(
                child: ListTile(
                  dense: true,
                  title: Text(
                    msg,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () {
                    _messageController.text = msg;
                  },
                ),
              )),

          const SizedBox(height: 24),

          // Parse result
          if (_lastParsed != null) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Parse Result',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildResultCard(
              'Confidence',
              '${_lastParsed!.confidence}%',
              _getConfidenceColor(_lastParsed!.confidence),
            ),
            _buildResultCard('Amount', '₹${_lastParsed!.amount?.toStringAsFixed(2) ?? 'N/A'}', Colors.green),
            _buildResultCard('Category', _lastParsed!.category, Colors.blue),
            _buildResultCard('Merchant', _lastParsed!.merchant, Colors.orange),
            _buildResultCard('Description', _lastParsed!.description, Colors.purple),
            if (_lastParsed!.accountLast4 != null)
              _buildResultCard('Account', 'XX${_lastParsed!.accountLast4}', Colors.teal),
            if (_lastParsed!.error != null)
              _buildResultCard('Error', _lastParsed!.error!, Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.check, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _senderController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
