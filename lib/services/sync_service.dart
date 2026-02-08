import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/expense.dart';
import '../services/expense_database.dart';
import '../services/smart_parser_service.dart';

class SyncService {
  final ExpenseDatabase _localDb = ExpenseDatabase();
  final SmartParserService _parser = SmartParserService();
  
  // Singleton
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isInitialized = true;
      print("Firebase Initialized Successfully");
      
      // SignIn anonymously to get a UID
      await _signIn();
      
      // Start listening to the cloud
      _startListening();
      
    } catch (e) {
      print("Firebase Initialization Failed: $e");
      // App should continue working offline
    }
  }

  Future<void> _signIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
        print("Signed in as anonymous user: ${FirebaseAuth.instance.currentUser?.uid}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
  }

  void _startListening() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Listen to 'incoming' collection for new messages/expenses
    // In a real app, this might be a webhook pushing to this collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('incoming_expenses')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _processIncomingDocument(change.doc);
        }
      }
    }, onError: (e) => print("Sync Error: $e"));
  }

  Future<void> _processIncomingDocument(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final text = data['text'] as String?;
      
      if (text != null && text.isNotEmpty) {
        print("Received Cloud Expense: $text");
        
        // Parse and Add to Local DB
        try {
          final expense = _parser.parse(text);
          // Auto-confirm logic or add to a "Review Queue"
          // For now, we add it directly
          await _localDb.addExpense(expense);
          
          // Delete from cloud queue after processing
          await doc.reference.delete();
          
          print("Cloud expense synced and saved locally.");
        } catch (e) {
          print("Error parsing cloud expense: $e");
        }
      }
    } catch (e) {
      print("Error processing doc: $e");
    }
  }
}
