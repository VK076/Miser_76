import 'package:flutter/material.dart';
import '../services/smart_parser_service.dart';
import '../models/expense.dart';
import '../services/expense_database.dart';
import '../constants/app_constants.dart';

class WhatsappSimulationScreen extends StatefulWidget {
  const WhatsappSimulationScreen({Key? key}) : super(key: key);

  @override
  State<WhatsappSimulationScreen> createState() => _WhatsappSimulationScreenState();
}

class _WhatsappSimulationScreenState extends State<WhatsappSimulationScreen> {
  final TextEditingController _controller = TextEditingController();
  final SmartParserService _parser = SmartParserService();
  final ExpenseDatabase _db = ExpenseDatabase();
  
  List<String> logs = [];

  void _addLog(String log) {
    setState(() {
      logs.insert(0, "[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] $log");
    });
  }

  void _simulateIncomingMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    _addLog("📩 Incoming Webhook: '$text'");
    
    try {
      _addLog("🧠 Parser: Analyzing...");
      final expense = _parser.parse(text);
      _addLog("✅ Parsed: ${expense.amount} for ${expense.category}");
      
      _addLog("💾 Database: Saving...");
      await _db.addExpense(expense);
      _addLog("✨ Success! Saved to Hive.");
      
      _controller.clear();
    } catch (e) {
      _addLog("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Buddy Simulator"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Simulate Incoming Message",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "e.g., 250 taxi to airport",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _simulateIncomingMessage,
                  icon: const Icon(Icons.send),
                  label: const Text("Simulate Webhook / Shortcut"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Logs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isError = log.contains("❌");
                final isSuccess = log.contains("✅") || log.contains("✨");
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isError ? Colors.red.shade50 : (isSuccess ? Colors.green.shade50 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isError ? Colors.red.shade200 : (isSuccess ? Colors.green.shade200 : Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    log,
                    style: TextStyle(
                      color: isError ? Colors.red.shade900 : (isSuccess ? Colors.green.shade900 : Colors.black87),
                      fontFamily: 'Courier',
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
