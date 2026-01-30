# EV - Student Record Management Application

A production-grade, 100% offline Android application built with Flutter and Dart for managing departmental student records. Designed specifically for a Head of Department (HOD) to manage student data without any internet connection or cloud services.

## Features

### Core Functionality
- ✅ **Fully Offline**: No internet, APIs, Firebase, or cloud services
- ✅ **SQLite Database**: Local persistent data storage
- ✅ **Department Management**: Organize students by departments
- ✅ **Multi-level Navigation**: Department → Section → Class → Academic Year → Roll Numbers
- ✅ **Student Profiles**: Comprehensive student information management

### Student Management
- Add, edit, delete student records
- Student photo capture (camera)
- Document upload and management
- Contact information (phone, email, address)
- CNIC/B-Form tracking
- Behavior/Status color coding system

### Advanced Features
- **Behavior Color System**: 
  - Green: Good/Excellent
  - Yellow: Needs Improvement
  - Red: Weak/Attention Required
  - Blue: Special/Custom
  
- **Intelligent Filtering**: Filter students by behavior color, class, and academic year
- **Roll Number Grid**: Visual grid display with color indicators
- **Communication Integration**:
  - Make phone calls
  - Send SMS with auto-generated messages
  - Send WhatsApp messages with student details
  
- **Export Functionality**:
  - Export individual student records to PDF or Excel
  - Export student lists to CSV
  - Share exports via WhatsApp, SMS, or any installed app
  
- **Backup & Restore**:
  - One-tap complete data backup
  - Restore from local backup files
  - Backup history tracking

### Dashboard
- Total student count
- Behavior status statistics
- Recently edited students
- Quick action buttons
- One-tap backup functionality

## Project Structure

```
ev/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── models.dart              # All data models
│   ├── screens/
│   │   ├── splash_screen.dart       # Splash/loading screen
│   │   ├── dashboard_screen.dart    # Main dashboard
│   │   ├── department_screen.dart   # Department selection
│   │   ├── section_screen.dart      # Section selection
│   │   ├── class_screen.dart        # Class selection
│   │   ├── academic_year_screen.dart # Academic year selection
│   │   ├── roll_number_screen.dart  # Roll numbers with filtering
│   │   └── student_management_screen.dart # Student profile & editing
│   ├── services/
│   │   ├── database_service.dart    # SQLite database operations
│   │   ├── file_service.dart        # File & media handling
│   │   ├── export_service.dart      # Export & backup services
│   │   └── communication_service.dart # Call, SMS, WhatsApp
│   ├── widgets/
│   │   └── common_widgets.dart      # Reusable UI components
│   └── utils/
│       └── constants.dart           # App constants & theme
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Code analysis rules
```

## Database Schema

### Tables
- **departments**: Department information
- **sections**: Sections within departments (Morning/Evening)
- **classes**: Classes within sections (FE-1, FE-2, etc.)
- **academic_years**: Year levels (1st Year, 2nd Year, etc.)
- **students**: Student records with behavior color indexing
- **student_documents**: Associated documents and media
- **backup_metadata**: Backup history and metadata

### Key Indexes
- `idx_behaviorColor`: For efficient behavior color filtering
- `idx_classAcademicYear`: For quick student lookups

## Installation & Setup

### Prerequisites
- Flutter SDK 3.0+
- Android SDK (API 30+)
- Dart 3.0+

### Build Steps

1. **Clone the project**:
   ```bash
   git clone <repository-url>
   cd ev
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build APK**:
   ```bash
   # Debug APK
   flutter build apk --debug
   
   # Release APK (recommended for production)
   flutter build apk --release
   ```

4. **Build AAB (for Play Store)**:
   ```bash
   flutter build appbundle --release
   ```

### Signing Release APK

**Generate keystore** (one-time):
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

**Create signing configuration** (`android/key.properties`):
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=key
storeFile=../key.jks
```

**Build signed APK**:
```bash
flutter build apk --release
```

## Usage Guide

### First Launch
1. App initializes with default Electrical Engineering Department
2. Default sections created: Morning, Evening
3. Default academic years created: 1st Year through 4th Year
4. Database is ready for student data entry

### Adding a Student
1. Navigate to Dashboard → Manage Students
2. Select Department → Section → Class → Academic Year
3. Click "Add Student" or tap "+" on roll numbers page
4. Fill in all required information
5. Select behavior status color
6. Add photo (optional) and documents
7. Save student record

### Filtering Students
1. Go to Roll Numbers page for any class/year
2. Use color filter buttons to filter by behavior status
3. Use search bar to find by roll number or name
4. Filters work instantly and offline

### Exporting Student Data
1. Open student profile
2. Click "Export" button
3. Select format: PDF, Excel, or Both
4. Choose sharing method: WhatsApp, SMS, or any app

### Backup & Restore
1. **Create Backup**: Dashboard → Backup button or Quick Actions
2. **View Backups**: Settings (if implemented)
3. **Restore**: Select backup file from local storage

## Technology Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite (sqflite 2.3.3)
- **Storage**: path_provider, file_picker, image_picker
- **Export**: pdf, excel, share_plus
- **Communication**: url_launcher
- **UI**: Material 3 design system
- **Utilities**: uuid, intl

## Permissions (Android 10+)

**Required Permissions**:
- CAMERA: Take student photos
- READ_EXTERNAL_STORAGE: Pick images and documents
- WRITE_EXTERNAL_STORAGE: Save files locally
- CALL_PHONE: Make phone calls
- ACCESS_FINE_LOCATION: Not required (disabled)
- INTERNET: Not required (offline only)

## Performance Specifications

- **APK Size**: ~50-60 MB (minimal)
- **Database Size**: Grows with student records (~1KB per record)
- **Memory Usage**: Optimized for low-end devices (2GB+ RAM)
- **Target Android**: 10+ (API 29+)
- **Minimum Android**: 10

## Security Considerations

- ✅ All data stored locally on device
- ✅ No external API calls
- ✅ No cloud synchronization
- ✅ Device-level encryption possible (via Android settings)
- ✅ Single user (HOD) - no authentication needed
- ⚠️ App backup depends on device security settings

## Future Enhancements

- Multi-department support with switching
- Attendance tracking
- Grade/marks management
- Fee tracking and receipts
- Complaint and feedback system
- Biometric unlock option
- Dark theme support
- Multi-language support (if needed)
- Export schedule automation

## Troubleshooting

### App won't start
- Clear app cache: Settings → Apps → EV → Storage → Clear Cache
- Uninstall and reinstall
- Check logcat: `flutter logs`

### Database errors
- App automatically initializes on first run
- Delete app data to reset: Settings → Apps → EV → Storage → Clear All Data

### Export not working
- Ensure documents folder has write permissions
- Check available storage space
- For PDF: Ensure file path is valid

### Camera/Gallery not working
- Grant permissions in Settings → Apps → Permissions
- For Android 10+: Grant access to "All files" or specific folders

## Support & Maintenance

This is a production-grade application designed for long-term use by departmental HODs. Regular maintenance includes:
- Periodic backups (recommend weekly)
- Database optimization (if student count exceeds 10,000)
- APK updates for new features

## License

Proprietary - For departmental use only.

## Contact & Support

For issues, feature requests, or improvements, contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Compatibility**: Android 10+, Flutter 3.0+
