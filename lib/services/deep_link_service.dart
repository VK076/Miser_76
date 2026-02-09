import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'smart_parser_service.dart';
import '../models/expense.dart';
import '../services/expense_database.dart';
import '../constants/currency.dart';

class DeepLinkService {
  StreamSubscription? _sub;
  final AppLinks _appLinks = AppLinks();
  final SmartParserService _parser = SmartParserService();
  final ExpenseDatabase _db = ExpenseDatabase();
  
  // Callback to show dialog in UI
  Function(Expense)? onExpenseParsed;

  /// Initialize deep link listener
  void initUniLinks() async {
    // 1. Handle link when app is in background/foreground (Stream)
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _processUri(uri);
    }, onError: (err) {
      print("Deep Link Error: $err");
    });

    // 2. Handle link when app is closed (Initial Link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _processUri(initialUri);
      }
    } catch (e) {
      print("Failed to get initial link: $e");
    }
  }

  void _processUri(Uri uri) {
    if (uri.scheme == 'financeapp' && uri.host == 'add') {
      final text = uri.queryParameters['text'];
      if (text != null && text.isNotEmpty) {
        try {
          final expense = _parser.parse(text);
          if (onExpenseParsed != null) {
            onExpenseParsed!(expense);
          }
        } catch (e) {
          print("Error parsing deep link text: $e");
        }
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
