import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'constants/app_constants.dart';
import 'models/expense.dart';
import 'models/expense_adapter.dart';
import 'models/budget.dart';
import 'models/budget_adapter.dart';
import 'models/income.dart';
import 'models/income_adapter.dart';
import 'models/recurring_expense_adapter.dart';
import 'models/recurring_income_adapter.dart';
import 'models/wallet_adapter.dart';
import 'models/goal_adapter.dart';
import 'services/expense_database.dart';
import 'services/budget_database.dart';
import 'services/income_database.dart';
import 'services/recurring_expense_database.dart';
import 'services/recurring_income_database.dart';
import 'services/wallet_database.dart';
import 'services/goal_database.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/deep_link_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(RecurringExpenseAdapter());
  Hive.registerAdapter(RecurringIncomeAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(GoalAdapter());
  
  // Initialize databases with safe recovery
  await _safeInit('expenses', () => ExpenseDatabase.initialize());
  await _safeInit('budgets', () => BudgetDatabase.initialize());
  await _safeInit('income', () => IncomeDatabase.initialize());
  await _safeInit('wallets', () => WalletDatabase.initialize());
  await _safeInit('goals', () => GoalDatabase.initialize());
  
  // Initialize recurring transaction databases
  final recurringExpenseDb = RecurringExpenseDatabase();
  await _safeInit('recurring_expenses', () => recurringExpenseDb.init());
  
  final recurringIncomeDb = RecurringIncomeDatabase();
  await _safeInit('recurring_income', () => recurringIncomeDb.init());
  
  // Initialize notification service (may fail on simulator)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
  } catch (e) {
    print('Notification service initialization failed (expected on simulator): $e');
  }

  // Initialize Cloud Sync & Deep Links (Safe Init)
  try {
    // 1. Initialize Deep Links (Shortcuts)
    final deepLinkService = DeepLinkService();
    deepLinkService.initUniLinks();
    
    // 2. Initialize Firebase (Sync)
    // This might fail if GoogleService-Info.plist is missing
    await SyncService().initialize();
  } catch (e) {
    print('Cloud services initialization failed: $e');
  }
  
  runApp(const MyApp());
}

/// Helper to safely initialize Hive boxes.
/// If initialization fails (e.g. schema mismatch), it clears the box and retries.
Future<void> _safeInit(String boxName, Future<void> Function() initFunc) async {
  try {
    await initFunc();
  } catch (e) {
    print('Error initializing $boxName: $e. Clearing corrupted data...');
    try {
      await Hive.deleteBoxFromDisk(boxName);
      print('Box $boxName deleted. Retrying...');
      await initFunc();
    } catch (e2) {
      print('CRITICAL: Failed to recover $boxName: $e2');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  /// Static method to change theme from anywhere in the app
  static void setTheme(BuildContext context, bool isDarkMode) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setTheme(isDarkMode);
  }

  /// Get current theme mode
  static bool isDarkMode(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state?.isDarkMode ?? false;
  }
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void setTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  /// Light theme configuration
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.success,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        color: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevationMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark theme configuration
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.success,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        color: AppColors.darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBackground,
        elevation: AppDimensions.elevationMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}