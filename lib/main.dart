import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/database_service.dart';
import 'services/file_service.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final db = DatabaseService();
  await db.database;
  
  // Initialize file service
  FileService();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryBlue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: AppFontSize.title, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: AppFontSize.xxl, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: AppFontSize.lg, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: AppFontSize.md, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: AppFontSize.md),
          bodyMedium: TextStyle(fontSize: AppFontSize.md),
          bodySmall: TextStyle(fontSize: AppFontSize.sm),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
