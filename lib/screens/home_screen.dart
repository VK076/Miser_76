import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'income_screen.dart';
import 'insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Currency selectedCurrency = CurrencyManager.inr; // Global currency state

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      DashboardScreen(
        selectedCurrency: selectedCurrency,
        onCurrencyChanged: (currency) => setState(() => selectedCurrency = currency),
      ),
      BudgetScreen(selectedCurrency: selectedCurrency),
      IncomeScreen(selectedCurrency: selectedCurrency),
      InsightsScreen(selectedCurrency: selectedCurrency),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
