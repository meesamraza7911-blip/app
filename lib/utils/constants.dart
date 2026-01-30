import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryDarkBlue = Color(0xFF1976D2);
  static const Color primaryLightBlue = Color(0xFFBBDEFB);

  // Behavior colors
  static const Color behaviorGreen = Color(0xFF4CAF50);
  static const Color behaviorYellow = Color(0xFFFFC107);
  static const Color behaviorRed = Color(0xFFF44336);
  static const Color behaviorBlue = Color(0xFF2196F3);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static Color getBehaviorColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return behaviorGreen;
      case 'yellow':
        return behaviorYellow;
      case 'red':
        return behaviorRed;
      case 'blue':
        return behaviorBlue;
      default:
        return behaviorGreen;
    }
  }
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppBorderRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppFontSize {
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 24;
  static const double title = 32;
}

class AppStrings {
  // General
  static const String appName = 'EV';
  static const String appSubtitle = 'Student Record Management';
  static const String department = 'Electrical Engineering Department';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String departments = 'Departments';
  static const String sections = 'Sections';
  static const String classes = 'Classes';
  static const String academicYears = 'Academic Years';
  static const String students = 'Students';
  static const String rollNumbers = 'Roll Numbers';
  static const String studentProfile = 'Student Profile';

  // Actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String backup = 'Backup';
  static const String restore = 'Restore';
  static const String export = 'Export';
  static const String share = 'Share';
  static const String upload = 'Upload';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clear = 'Clear';

  // Student fields
  static const String studentName = 'Student Name';
  static const String fatherGuardianName = 'Father / Guardian Name';
  static const String rollNumber = 'Roll Number';
  static const String studentContact = 'Student Contact';
  static const String guardianContact = 'Guardian Contact';
  static const String email = 'Email';
  static const String address = 'Address';
  static const String cnic = 'CNIC / B-Form';
  static const String className = 'Class';
  static const String academicYear = 'Academic Year';
  static const String behaviorStatus = 'Behavior Status';

  // Behavior colors
  static const String behaviorGood = 'Good';
  static const String behaviorNeedsImprovement = 'Needs Improvement';
  static const String behaviorWeak = 'Weak';
  static const String behaviorSpecial = 'Special';

  // Messages
  static const String confirmDelete = 'Are you sure you want to delete?';
  static const String confirmClear = 'This will clear all data. Are you sure?';
  static const String successMessage = 'Operation successful';
  static const String errorMessage = 'An error occurred';
  static const String noData = 'No data available';
  static const String loadingMessage = 'Loading...';

  // Export
  static const String exportOptions = 'Select Export Format';
  static const String exportPDF = 'PDF';
  static const String exportExcel = 'Excel';
  static const String exportBoth = 'Both';
}

class AppConstants {
  static const int defaultRollNumberCount = 50;
  static const int maxRollNumbers = 200;
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}

// Roll number ranges for quick initialization
final List<int> defaultRollNumbers = List<int>.generate(
  AppConstants.defaultRollNumberCount,
  (i) => i + 1,
);
