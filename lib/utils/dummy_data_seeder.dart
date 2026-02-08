import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/income.dart';
import '../services/expense_database.dart';
import '../services/budget_database.dart';
import '../services/income_database.dart';
import 'package:uuid/uuid.dart';

class DummyDataSeeder {
  static Future<void> seedData(BuildContext context) async {
    final expenseDb = ExpenseDatabase();
    final budgetDb = BudgetDatabase();
    final incomeDb = IncomeDatabase();
    final uuid = const Uuid();

    // Clear existing data
    await expenseDb.deleteAllExpenses();
    await budgetDb.deleteAllBudgets();
    await incomeDb.deleteAllIncome();

    final now = DateTime.now();

    // Add Income Data
    final incomeEntries = [
      Income(
        id: uuid.v4(),
        amount: 5000,
        source: 'Salary',
        description: 'Monthly Salary - January',
        date: DateTime(now.year, now.month - 1, 1),
        isRecurring: true,
      ),
      Income(
        id: uuid.v4(),
        amount: 5000,
        source: 'Salary',
        description: 'Monthly Salary - February',
        date: DateTime(now.year, now.month, 1),
        isRecurring: true,
      ),
      Income(
        id: uuid.v4(),
        amount: 1200,
        source: 'Freelance',
        description: 'Web Development Project',
        date: DateTime(now.year, now.month, 15),
        isRecurring: false,
      ),
      Income(
        id: uuid.v4(),
        amount: 800,
        source: 'Investment',
        description: 'Stock Dividends',
        date: DateTime(now.year, now.month, 10),
        isRecurring: false,
      ),
      Income(
        id: uuid.v4(),
        amount: 500,
        source: 'Business',
        description: 'Side Business Revenue',
        date: DateTime(now.year, now.month, 20),
        isRecurring: false,
      ),
    ];

    for (var income in incomeEntries) {
      await incomeDb.addIncome(income);
    }

    // Add Budget Data
    final budgets = [
      Budget(
        id: uuid.v4(),
        category: 'Food & Dining',
        amount: 500,
        period: 'month',
        createdDate: DateTime(now.year, now.month, 1),
      ),
      Budget(
        id: uuid.v4(),
        category: 'Transport',
        amount: 300,
        period: 'month',
        createdDate: DateTime(now.year, now.month, 1),
      ),
      Budget(
        id: uuid.v4(),
        category: 'Entertainment',
        amount: 200,
        period: 'month',
        createdDate: DateTime(now.year, now.month, 1),
      ),
      Budget(
        id: uuid.v4(),
        category: 'Shopping',
        amount: 400,
        period: 'month',
        createdDate: DateTime(now.year, now.month, 1),
      ),
      Budget(
        id: uuid.v4(),
        category: 'Health',
        amount: 150,
        period: 'month',
        createdDate: DateTime(now.year, now.month, 1),
      ),
      Budget(
        id: uuid.v4(),
        category: 'Travel',
        amount: 3000,
        period: 'year',
        createdDate: DateTime(now.year, 1, 1),
      ),
    ];

    for (var budget in budgets) {
      await budgetDb.addBudget(budget);
    }

    // Add Expense Data - Current Month
    final currentMonthExpenses = [
      // Food & Dining - Over budget
      Expense(
        id: uuid.v4(),
        amount: 45.50,
        category: 'Food & Dining',
        description: 'Dinner at Italian Restaurant',
        date: DateTime(now.year, now.month, 2),
      ),
      Expense(
        id: uuid.v4(),
        amount: 85.00,
        category: 'Food & Dining',
        description: 'Weekly Groceries',
        date: DateTime(now.year, now.month, 5),
      ),
      Expense(
        id: uuid.v4(),
        amount: 32.75,
        category: 'Food & Dining',
        description: 'Lunch with colleagues',
        date: DateTime(now.year, now.month, 8),
      ),
      Expense(
        id: uuid.v4(),
        amount: 120.00,
        category: 'Food & Dining',
        description: 'Family dinner celebration',
        date: DateTime(now.year, now.month, 12),
      ),
      Expense(
        id: uuid.v4(),
        amount: 95.00,
        category: 'Food & Dining',
        description: 'Weekly Groceries',
        date: DateTime(now.year, now.month, 15),
      ),
      Expense(
        id: uuid.v4(),
        amount: 28.50,
        category: 'Food & Dining',
        description: 'Coffee and breakfast',
        date: DateTime(now.year, now.month, 18),
      ),
      Expense(
        id: uuid.v4(),
        amount: 150.00,
        category: 'Food & Dining',
        description: 'Sushi restaurant',
        date: DateTime(now.year, now.month, 22),
      ),

      // Transport
      Expense(
        id: uuid.v4(),
        amount: 60.00,
        category: 'Fuel',
        description: 'Gas station fill-up',
        date: DateTime(now.year, now.month, 3),
      ),
      Expense(
        id: uuid.v4(),
        amount: 25.00,
        category: 'Transport',
        description: 'Uber rides',
        date: DateTime(now.year, now.month, 7),
      ),
      Expense(
        id: uuid.v4(),
        amount: 65.00,
        category: 'Fuel',
        description: 'Gas station fill-up',
        date: DateTime(now.year, now.month, 16),
      ),
      Expense(
        id: uuid.v4(),
        amount: 15.00,
        category: 'Parking',
        description: 'Downtown parking',
        date: DateTime(now.year, now.month, 20),
      ),

      // Entertainment
      Expense(
        id: uuid.v4(),
        amount: 45.00,
        category: 'Entertainment',
        description: 'Movie tickets',
        date: DateTime(now.year, now.month, 4),
      ),
      Expense(
        id: uuid.v4(),
        amount: 15.99,
        category: 'Streaming',
        description: 'Netflix subscription',
        date: DateTime(now.year, now.month, 1),
      ),
      Expense(
        id: uuid.v4(),
        amount: 59.99,
        category: 'Gaming',
        description: 'New video game',
        date: DateTime(now.year, now.month, 14),
      ),

      // Shopping
      Expense(
        id: uuid.v4(),
        amount: 89.99,
        category: 'Clothing',
        description: 'New jeans and shirt',
        date: DateTime(now.year, now.month, 6),
      ),
      Expense(
        id: uuid.v4(),
        amount: 299.00,
        category: 'Electronics',
        description: 'Wireless headphones',
        date: DateTime(now.year, now.month, 11),
      ),
      Expense(
        id: uuid.v4(),
        amount: 45.00,
        category: 'Shopping',
        description: 'Home decor items',
        date: DateTime(now.year, now.month, 19),
      ),

      // Health
      Expense(
        id: uuid.v4(),
        amount: 50.00,
        category: 'Fitness',
        description: 'Gym membership',
        date: DateTime(now.year, now.month, 1),
      ),
      Expense(
        id: uuid.v4(),
        amount: 35.00,
        category: 'Medicine',
        description: 'Pharmacy - vitamins',
        date: DateTime(now.year, now.month, 9),
      ),

      // Utilities
      Expense(
        id: uuid.v4(),
        amount: 120.00,
        category: 'Electricity',
        description: 'Monthly electricity bill',
        date: DateTime(now.year, now.month, 5),
      ),
      Expense(
        id: uuid.v4(),
        amount: 60.00,
        category: 'Internet',
        description: 'Internet bill',
        date: DateTime(now.year, now.month, 1),
      ),

      // Work
      Expense(
        id: uuid.v4(),
        amount: 75.00,
        category: 'Work',
        description: 'Office supplies',
        date: DateTime(now.year, now.month, 10),
      ),
    ];

    // Add Previous Month Expenses
    final previousMonthExpenses = [
      Expense(
        id: uuid.v4(),
        amount: 320.00,
        category: 'Food & Dining',
        description: 'Monthly groceries',
        date: DateTime(now.year, now.month - 1, 15),
      ),
      Expense(
        id: uuid.v4(),
        amount: 180.00,
        category: 'Transport',
        description: 'Gas and parking',
        date: DateTime(now.year, now.month - 1, 10),
      ),
      Expense(
        id: uuid.v4(),
        amount: 95.00,
        category: 'Entertainment',
        description: 'Concert tickets',
        date: DateTime(now.year, now.month - 1, 20),
      ),
    ];

    for (var expense in [...currentMonthExpenses, ...previousMonthExpenses]) {
      await expenseDb.addExpense(expense);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Dummy data loaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
