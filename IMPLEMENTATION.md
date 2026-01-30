# EV Application - Implementation Guide

## Quick Start (15 minutes)

### Prerequisites
- Flutter 3.0+ installed
- Android SDK API 30+
- Device/emulator running Android 10+

### Installation Steps

**1. Clone the project**
```bash
cd /path/to/ev
```

**2. Get dependencies**
```bash
flutter pub get
```

**3. Connect device**
```bash
# USB Debugging enabled
adb devices  # Should show your device
```

**4. Run the app**
```bash
flutter run
```

**5. Build APK**
```bash
flutter build apk --release
```

---

## Project Walkthrough

### Directory Structure Explained

```
ev/
├── lib/
│   ├── main.dart
│   │   └── Entry point, theme setup, app initialization
│   │
│   ├── models/
│   │   └── models.dart (5 models)
│   │       ├── Department: Organization unit
│   │       ├── Section: Morning/Evening/Custom
│   │       ├── StudentClass: FE-1, FE-2, etc.
│   │       ├── AcademicYear: 1st, 2nd, 3rd year
│   │       ├── Student: Main student record
│   │       ├── StudentDocument: Files/media
│   │       ├── BehaviorColor: Enum with colors
│   │       └── BackupMetadata: Backup info
│   │
│   ├── services/
│   │   ├── database_service.dart (600+ lines)
│   │   │   └── All SQLite operations
│   │   ├── file_service.dart (100+ lines)
│   │   │   └── File & media management
│   │   ├── export_service.dart (300+ lines)
│   │   │   ├── ExportService: PDF/Excel/CSV
│   │   │   └── BackupService: Backup/Restore
│   │   └── communication_service.dart (100+ lines)
│   │       └── Phone, SMS, WhatsApp
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   │   └── 3-second animated splash
│   │   ├── dashboard_screen.dart
│   │   │   └── Main menu, stats, recent students
│   │   ├── department_screen.dart
│   │   │   └── List departments
│   │   ├── section_screen.dart
│   │   │   └── List sections (Morning/Evening)
│   │   ├── class_screen.dart
│   │   │   └── List classes (FE-1, FE-2, etc.)
│   │   ├── academic_year_screen.dart
│   │   │   └── List academic years
│   │   ├── roll_number_screen.dart (⭐ KEY FILE)
│   │   │   ├── 5x10 grid of roll numbers
│   │   │   ├── Color-coded cards
│   │   │   ├── Behavior color filtering
│   │   │   ├── Search functionality
│   │   │   └── Add new students
│   │   └── student_management_screen.dart (⭐ KEY FILE)
│   │       ├── Student profile editor
│   │       ├── Photo capture
│   │       ├── Document upload
│   │       ├── Behavior color picker
│   │       ├── Contact integration
│   │       └── Export options
│   │
│   ├── widgets/
│   │   └── common_widgets.dart (500+ lines)
│   │       ├── BehaviorColorPicker: Color selector
│   │       ├── BehaviorColorBadge: Color display
│   │       ├── BehaviorFilterButton: Filter buttons
│   │       ├── RollNumberCard: Grid item
│   │       ├── CustomTextField: Input field
│   │       ├── CustomButton: Styled button
│   │       ├── StatCard: Dashboard stat
│   │       └── DialogUtil: Dialogs
│   │
│   └── utils/
│       └── constants.dart
│           ├── AppColors: Color palette
│           ├── AppSpacing: Margins/padding
│           ├── AppBorderRadius: Border radius
│           ├── AppFontSize: Font sizes
│           ├── AppStrings: UI strings
│           └── AppConstants: Config values
│
├── android/
│   ├── app/
│   │   ├── build.gradle (Gradle config)
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle (Root Gradle)
│   └── local.properties
│
├── pubspec.yaml (Dependencies)
├── analysis_options.yaml (Code analysis)
├── README.md (Overview)
├── ARCHITECTURE.md (Design docs)
├── BUILD_AND_DEPLOYMENT.md (Build guide)
└── IMPLEMENTATION.md (This file)
```

---

## Step-by-Step Implementation Flow

### 1. App Initialization

**File**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final db = DatabaseService();
  await db.database;  // Creates tables if needed
  
  // Initialize file service
  FileService();
  
  runApp(const MyApp());
}
```

**What happens**:
- Initializes Flutter binding
- Creates/opens SQLite database
- Creates default tables
- Inserts default data (Department, Sections, Classes, Years)
- Starts app

### 2. Splash Screen (3 seconds)

**File**: `lib/screens/splash_screen.dart`

```dart
// Shows EV logo with animation
// Loads database in background
// Auto-navigates to Dashboard
```

### 3. Dashboard Screen

**File**: `lib/screens/dashboard_screen.dart`

**Key Features**:
- Displays total student count
- Shows statistics grid
- Lists recently edited students
- Quick action buttons
- Backup functionality

**Database queries**:
```dart
totalStudents = await _db.getTotalStudentCount();
recentStudents = await _db.getRecentlyEdited(limit: 5);
```

### 4. Navigation Hierarchy

**Flow**:
```
Dashboard
   ↓ (Tap "Manage Students")
Department Screen → Electrical Engineering
   ↓ (Select Department)
Section Screen → Morning / Evening
   ↓ (Select Section)
Class Screen → FE-1, FE-2, FE-3, FE-4
   ↓ (Select Class)
Academic Year Screen → 1st, 2nd, 3rd, 4th Year
   ↓ (Select Year)
Roll Number Screen → Grid of 1-50 (expandable to 200)
```

**Files**:
- `department_screen.dart`
- `section_screen.dart`
- `class_screen.dart`
- `academic_year_screen.dart`

### 5. Roll Number Screen (⭐ CRITICAL)

**File**: `lib/screens/roll_number_screen.dart`

**Key Functionality**:

**a) Display Grid**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,  // 5 columns = 10 per row
  ),
  itemCount: filteredStudents.length,
  itemBuilder: (context, index) {
    return RollNumberCard(
      rollNumber: student.rollNumber,
      behaviorColor: student.behaviorColor,  // ← Color display
      onTap: () => openStudentProfile(student),
    );
  },
)
```

**b) Color Filtering**
```dart
// Behavior filter buttons
Wrap(
  children: BehaviorColor.values.map((color) {
    return BehaviorFilterButton(
      color: color,
      isSelected: selectedFilterColor == color,
      onTap: () {
        setState(() {
          selectedFilterColor = selectedFilterColor == color ? null : color;
          _loadStudents();  // Re-query with filter
        });
      },
    );
  }).toList(),
)

// Database query
Future<List<Student>> getStudentsByBehaviorColor(
  BehaviorColor color,
  String classId,
  String academicYearId,
) async {
  return await db.query(
    'students',
    where: 'behaviorColor = ? AND classId = ? AND academicYearId = ?',
    whereArgs: [color.name, classId, academicYearId],
  );
}
```

**c) Search**
```dart
TextField(
  controller: _searchController,
  onChanged: (_) => setState(() {}),  // Re-filter on change
)

// Filter logic
List<Student> _filterStudents(List<Student> students) {
  if (_searchController.text.isEmpty) return students;
  
  return students.where((student) {
    final query = _searchController.text.toLowerCase();
    return student.rollNumber.contains(query) ||
           student.studentName.toLowerCase().contains(query);
  }).toList();
}
```

### 6. Student Management Screen (⭐ CRITICAL)

**File**: `lib/screens/student_management_screen.dart`

**Modes**:
- **Add Mode**: No student parameter passed
- **Edit Mode**: Student parameter passed

**Key Operations**:

**a) Photo Capture**
```dart
// Pick from camera
Future<void> _pickPhoto() async {
  final XFile? pickedFile = await _imagePicker.pickImage(
    source: ImageSource.camera,
  );
  
  if (pickedFile != null) {
    photoPath = await _fileService.saveStudentPhoto(
      File(pickedFile.path),
      studentId,
    );
    setState(() {});
  }
}
```

**b) Behavior Color Selection**
```dart
BehaviorColorPicker(
  initialColor: selectedColor,
  onColorSelected: (color) {
    setState(() => selectedColor = color);
  },
)
```

**c) Save Student**
```dart
Future<void> _saveStudent() async {
  // Validate
  if (_nameController.text.isEmpty) {
    showError('Name required');
    return;
  }
  
  // Create/Update Student
  final student = Student(
    id: widget.student?.id ?? Uuid().v4(),
    rollNumber: _rollNumberController.text,
    studentName: _nameController.text,
    // ... other fields
    behaviorColor: selectedColor,  // ← Save color
    createdAt: widget.student?.createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  // Save to database
  if (widget.student == null) {
    await _db.addStudent(student);
  } else {
    await _db.updateStudent(student);
  }
  
  // Navigate back
  Navigator.pop(context);
}
```

**d) Contact Integration**
```dart
// Call student
Future<void> _contactVia(String type) async {
  final phoneNumber = _studentContactController.text;
  
  if (type == 'call') {
    await _commService.makePhoneCall(phoneNumber);
  } else if (type == 'sms') {
    final message = _commService.generateStudentMessage(
      student: currentStudent,
      className: widget.className,
      academicYear: 'N/A',
    );
    await _commService.sendSMS(phoneNumber, message);
  } else if (type == 'whatsapp') {
    final message = _commService.generateGuardianMessage(...);
    await _commService.sendWhatsApp(phoneNumber, message);
  }
}
```

---

## Database Schema Deep Dive

### Students Table

```sql
CREATE TABLE students(
  id TEXT PRIMARY KEY,
  rollNumber TEXT NOT NULL,
  classId TEXT NOT NULL,
  academicYearId TEXT NOT NULL,
  studentName TEXT NOT NULL,
  fatherGuardianName TEXT NOT NULL,
  studentContact TEXT NOT NULL,
  fatherGuardianContact TEXT NOT NULL,
  email TEXT,
  address TEXT,
  cnic TEXT,
  photoPath TEXT,
  behaviorColor TEXT NOT NULL DEFAULT 'green',  -- ⭐ KEY FIELD
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  FOREIGN KEY(classId) REFERENCES classes(id),
  FOREIGN KEY(academicYearId) REFERENCES academic_years(id)
)

-- Index for efficient filtering
CREATE INDEX idx_behaviorColor ON students(behaviorColor)
CREATE INDEX idx_classAcademicYear ON students(classId, academicYearId)
```

### Why This Design?

1. **Behavior Color as String**: Stored as `'green'`, `'yellow'`, `'red'`, `'blue'`
   - Reason: Enum values convert to string via `.name`
   - Indexed for O(log n) filtering

2. **Composite Index on classId + academicYearId**:
   - Most queries filter by both together
   - Single index faster than separate

3. **Photo Path as String**:
   - Stores full device path
   - File content not stored in DB (too large)
   - Lazy load on demand

4. **Documents in Separate Table**:
   - 1 student : N documents
   - Flexible for multiple files per student

---

## Behavior Color System Implementation

### Color Persistence Flow

```
┌─────────────────────┐
│  Behavior Color     │
│  Selection in UI    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│  BehaviorColorPicker│
│  onColorSelected()  │
└──────────┬──────────┘
           ↓ selectedColor = newColor
┌─────────────────────┐
│  Student Object     │
│  behaviorColor: enum│
└──────────┬──────────┘
           ↓ toMap()
┌─────────────────────┐
│  'behaviorColor':   │
│  'green'/'yellow'.. │
└──────────┬──────────┘
           ↓ await _db.addStudent()
┌─────────────────────┐
│  INSERT INTO        │
│  students           │
│  (behaviorColor...) │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│  SQLite Stored      │
│  behaviorColor: 'green'
└──────────┬──────────┘
           ↓ (next app launch)
┌─────────────────────┐
│  SELECT * WHERE     │
│  behaviorColor=...  │
└──────────┬──────────┘
           ↓ fromMap()
┌─────────────────────┐
│  BehaviorColor enum │
│  AUTO-CONVERTED     │
└──────────┬──────────┘
           ↓ RollNumberCard
┌─────────────────────┐
│  Color Badge        │
│  Displays on Grid   │
└─────────────────────┘
```

### Code Example

```dart
// 1. Model - Conversion
class Student {
  final BehaviorColor behaviorColor;
  
  // To Database
  Map<String, dynamic> toMap() {
    return {
      'behaviorColor': behaviorColor.name,  // 'green'
    };
  }
  
  // From Database
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      behaviorColor: BehaviorColor.fromString(
        map['behaviorColor'] as String? ?? 'green'
      ),
    );
  }
}

// 2. Enum - Parse
enum BehaviorColor {
  green(...),
  yellow(...),
  red(...),
  blue(...);
  
  static BehaviorColor fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => BehaviorColor.green,
    );
  }
}

// 3. Widget - Display
class RollNumberCard extends StatelessWidget {
  final BehaviorColor? behaviorColor;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Card background...
        Positioned(
          top: 4,
          right: 4,
          child: BehaviorColorBadge(
            color: behaviorColor!,
            size: 16,
          ),
        ),
      ],
    );
  }
}

class BehaviorColorBadge extends StatelessWidget {
  final BehaviorColor color;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(color.colorValue),  // 0xFF4CAF50 for green
        shape: BoxShape.circle,
      ),
    );
  }
}
```

---

## Export & Backup Implementation

### PDF Export Example

```dart
Future<File> exportStudentToPDF(Student student) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // Title
        pw.Text('Student Record'),
        
        // Photo
        if (student.photoPath != null)
          pw.Image(pw.MemoryImage(
            File(student.photoPath!).readAsBytesSync()
          )),
        
        // Fields
        _buildPDFField('Name', student.studentName),
        _buildPDFField('Status', student.behaviorColor.label),
        // ... more fields
      ],
    ),
  );
  
  final file = File('$backupDir/student_${DateTime.now().timestamp}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}
```

### Backup Flow

```dart
Future<File> createBackup() async {
  // 1. Export all data
  final backupData = await _db.exportAllData();
  
  // 2. Create JSON
  final backupJson = {
    'version': '1.0',
    'timestamp': DateTime.now().toIso8601String(),
    'data': backupData,
  };
  
  // 3. Save to file
  final file = File('$backupDir/backup_${timestamp}.json');
  await file.writeAsString(jsonEncode(backupJson));
  
  // 4. Save metadata
  await _db.saveBackupMetadata(BackupMetadata(
    id: Uuid().v4(),
    createdAt: DateTime.now(),
    backupPath: file.path,
    studentCount: await _db.getTotalStudentCount(),
    appVersion: '1.0.0',
  ));
  
  return file;
}
```

---

## Common Tasks

### Task 1: Add a New Student

```dart
// Navigate to StudentManagementScreen with context
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => StudentManagementScreen(
      classId: 'class_fe_1_001',
      academicYearId: 'year_1_001',
      className: 'FE-1',
    ),
  ),
);
```

### Task 2: Filter Students by Color

```dart
// In RollNumberScreen
setState(() {
  selectedFilterColor = BehaviorColor.red;
  _studentsFuture = _db.getStudentsByBehaviorColor(
    BehaviorColor.red,
    widget.classId,
    widget.academicYearId,
  );
});
```

### Task 3: Export Student Record

```dart
// In StudentManagementScreen
Future<void> _exportStudent() async {
  final pdfFile = await _exportService.exportStudentToPDF(
    student,
    studentClass,
    academicYear,
  );
  
  // Share
  await Share.shareFiles([pdfFile.path]);
}
```

### Task 4: Create Backup

```dart
Future<void> _createBackup() async {
  try {
    final backupFile = await _backupService.createBackup();
    showSuccessDialog('Backup saved to ${backupFile.path}');
  } catch (e) {
    showErrorDialog('Backup failed: $e');
  }
}
```

---

## Debugging Tips

### View Database (Android)

```bash
# Connect device
adb devices

# Access app files
adb shell

# Navigate to app directory
cd /data/data/com.ev.studentrecords/files

# View database
sqlite3 ev_app.db

# Useful queries
sqlite> .tables
sqlite> SELECT COUNT(*) FROM students;
sqlite> SELECT * FROM students WHERE rollNumber = '5';
sqlite> SELECT DISTINCT behaviorColor FROM students;
```

### Check Logs

```bash
# Flutter logs
flutter logs

# Android specific
adb logcat | grep flutter

# Filter by app
adb logcat | grep com.ev.studentrecords
```

### Common Crashes

1. **"Database locked"**
   - Close previous instance
   - Restart emulator

2. **"Permission denied" (storage)**
   - Grant permissions in device settings
   - Test on Android 11+ device

3. **"NPE on null photoPath"**
   - Check: `if (photoPath != null && File(photoPath!).existsSync())`

---

## Performance Optimization

### For 1000+ Students

1. **Pagination**:
   ```dart
   Future<List<Student>> getStudentsPaginated(int page, int pageSize) {
     offset = page * pageSize;
     return db.query(studentTable, offset: offset, limit: pageSize);
   }
   ```

2. **Lazy Loading**:
   ```dart
   class RollNumberScreen extends StatefulWidget {
     // Only load students when screen opens
     @override
     void initState() {
       _loadStudents();  // Don't load in Dashboard
     }
   }
   ```

3. **Caching**:
   ```dart
   Map<String, List<Student>> _cache = {};
   
   Future<List<Student>> getStudentsCached(String key) {
     if (_cache.containsKey(key)) return Future.value(_cache[key]);
     return _loadAndCache(key);
   }
   ```

---

## Testing Checklist

- [ ] App starts without crash
- [ ] Database initializes with default data
- [ ] Can navigate through hierarchy
- [ ] Roll numbers display correctly
- [ ] Can add new student
- [ ] Behavior color saves and displays
- [ ] Color filtering works
- [ ] Photo capture works
- [ ] Can send SMS/WhatsApp
- [ ] PDF export works
- [ ] Backup creates file
- [ ] Restore from backup works
- [ ] No crashes in logcat
- [ ] App size acceptable
- [ ] Runs on Android 10-14

---

**Last Updated**: January 2026  
**Flutter Version**: 3.0+
