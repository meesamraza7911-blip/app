# EV Application - Architecture & Design Documentation

## System Architecture

### Layer Architecture

```
┌─────────────────────────────────────────┐
│         UI Layer (Screens)              │
│  - SplashScreen                         │
│  - DashboardScreen                      │
│  - NavigationHierarchy                  │
│  - RollNumberScreen (with filtering)    │
│  - StudentManagementScreen              │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       Widget Layer (Reusable)           │
│  - BehaviorColorPicker                  │
│  - RollNumberCard                       │
│  - CustomTextField                      │
│  - StatCard                             │
│  - DialogUtil                           │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       Service Layer (Business Logic)    │
│  - DatabaseService                      │
│  - FileService                          │
│  - ExportService                        │
│  - BackupService                        │
│  - CommunicationService                 │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Data Layer (Models & Storage)      │
│  - Models (Department, Student, etc.)   │
│  - SQLite Database                      │
│  - Local File System                    │
└─────────────────────────────────────────┘
```

---

## Database Design

### Entity Relationship Diagram

```
┌──────────────┐
│ Departments  │
├──────────────┤
│ id (PK)      │
│ name         │
│ createdAt    │
└──────┬───────┘
       │ 1:N
       ↓
┌──────────────┐      ┌──────────────┐
│  Sections    │      │Academic Years│
├──────────────┤      ├──────────────┤
│ id (PK)      │      │ id (PK)      │
│ deptId (FK)  │      │ deptId (FK)  │
│ name         │      │ name         │
│ createdAt    │      │ year         │
└──────┬───────┘      └──────────────┘
       │ 1:N
       ↓
┌──────────────┐
│  Classes     │
├──────────────┤
│ id (PK)      │
│ deptId (FK)  │
│ sectionId(FK)│
│ name         │
│ createdAt    │
└──────┬───────┘
       │ 1:N
       ↓
┌─────────────────────┐
│    Students         │
├─────────────────────┤
│ id (PK)             │
│ rollNumber          │
│ classId (FK)        │
│ academicYearId (FK) │
│ studentName         │
│ fatherGuardian      │
│ studentContact      │
│ guardianContact     │
│ email               │
│ address             │
│ cnic                │
│ photoPath           │
│ behaviorColor*      │ ← INDEXED
│ createdAt           │
│ updatedAt           │
└─────────┬───────────┘
          │ 1:N
          ↓
┌──────────────────┐
│StudentDocuments  │
├──────────────────┤
│ id (PK)          │
│ studentId (FK)   │
│ filePath         │
│ fileName         │
│ fileType         │
│ uploadedAt       │
└──────────────────┘
```

### Index Strategy

```sql
-- Behavioral Color Filtering
CREATE INDEX idx_behaviorColor ON students(behaviorColor)

-- Class & Year Lookups
CREATE INDEX idx_classAcademicYear ON students(classId, academicYearId)
```

---

## Behavior Color System Architecture

### Color Model
```dart
enum BehaviorColor {
  green('Green', 0xFF4CAF50),      // Good/Excellent
  yellow('Yellow', 0xFFFFC107),    // Needs Improvement
  red('Red', 0xFFF44336),          // Weak/Attention
  blue('Blue', 0xFF2196F3);        // Special/Custom
}
```

### Color Filtering Logic

```dart
// Query students by color
Future<List<Student>> getStudentsByBehaviorColor(
  BehaviorColor color,
  String classId,
  String academicYearId
) async {
  // Uses index for O(log n) performance
  return await db.query(
    'students',
    where: 'behaviorColor = ? AND classId = ? AND academicYearId = ?',
    whereArgs: [color.name, classId, academicYearId]
  );
}
```

### Color Persistence

- Color stored in database as string: `color.name`
- Retrieved and converted to enum: `BehaviorColor.fromString(value)`
- Color updates: `student.copyWith(behaviorColor: newColor)`
- Auto-synced on card display via `BehaviorColorBadge` widget

---

## Roll Number System

### Grid Display Logic

```dart
// Configuration
const int COLUMNS = 5;
const int ROWS_PER_PAGE = 10;

// Default range
const List<int> DEFAULT_ROLL_NUMBERS = List.generate(50, (i) => i + 1);

// Max capacity
const int MAX_ROLL_NUMBERS = 200;

// Dynamic expansion
void addRollNumbers(int count) {
  // Create new student records with unassigned behavior color
  // Initial default: BehaviorColor.green
}
```

### Data Synchronization

```
Roll Number Card Display
         ↓
[Query Student by Roll]
         ↓
[Load Behavior Color]
         ↓
[Render with Color Badge]
         ↓
[Update on Tap]
         ↓
[Save to DB]
         ↓
[Auto-refresh Grid]
```

---

## Filtering Algorithm

### Behavior Color Filter

```dart
// Single-pass filter
List<Student> filteredStudents = allStudents.where(
  (student) => 
    student.behaviorColor == selectedColor &&
    student.classId == currentClassId &&
    student.academicYearId == currentYearId
).toList();
```

### Search + Filter Combined

```dart
List<Student> _filterStudents(List<Student> students) {
  if (_searchController.text.isEmpty) {
    return students; // Use pre-filtered by color
  }
  
  return students.where((student) {
    return student.rollNumber.contains(search) ||
           student.studentName.toLowerCase().contains(search.toLowerCase());
  }).toList();
}
```

### Performance Optimizations

- **Indexed Queries**: Color, class, and year are indexed
- **Lazy Loading**: Load data on demand, not all at once
- **Caching**: Recently loaded lists cached in memory
- **Pagination**: Optional for large student lists (future)

---

## Export & Sharing Architecture

### PDF Export Flow

```
Student Data
    ↓
[Create PDF Document]
    ├─→ [Load Photo Image]
    ├─→ [Format Personal Info]
    ├─→ [Format Contact Info]
    └─→ [Format Additional Info]
    ↓
[Save to Backup Directory]
    ↓
[Share via Intent]
```

### Export Service Hierarchy

```
ExportService
├── exportStudentToPDF()        → File (PDF)
├── exportStudentToExcel()      → File (XLSX)
├── exportStudentsToCSV()       → List<File> (CSV)
└── ExportFormat Enum
    ├── PDF
    ├── EXCEL
    └── BOTH
```

### Sharing Integration

```dart
// Platform channels via url_launcher
- WhatsApp: https://wa.me/{phone}?text={message}
- SMS: sms:{phone}?body={message}
- Email: mailto:{email}?subject=Student Record
- Generic: share_plus.Share.shareFiles([filePath])
```

---

## Backup & Restore Architecture

### Backup Structure

```json
{
  "version": "1.0",
  "timestamp": "2026-01-30T10:30:45.123Z",
  "data": {
    "departments": [...],
    "sections": [...],
    "classes": [...],
    "academicYears": [...],
    "students": [...],
    "documents": [...]
  }
}
```

### Backup Flow

```
[Create Backup Button]
    ↓
[Query All Tables]
    ├─→ departments
    ├─→ sections
    ├─→ classes
    ├─→ academicYears
    ├─→ students
    └─→ documents
    ↓
[Serialize to JSON]
    ↓
[Write to Device Storage]
    ↓
[Save Metadata to BackupMetadata table]
    ├─→ ID
    ├─→ Timestamp
    ├─→ File Path
    ├─→ Student Count
    └─→ App Version
    ↓
[Show Success Message]
```

### Restore Flow

```
[Select Backup File]
    ↓
[Parse JSON]
    ↓
[Validate Version]
    ↓
[Clear Existing Data]
    ↓
[Restore Each Table]
    ├─→ Departments first (foreign key)
    ├─→ Sections
    ├─→ Classes
    ├─→ Academic Years
    ├─→ Students
    └─→ Documents last
    ↓
[Verify Integrity]
    ↓
[Show Restore Complete Message]
```

### Recovery Safety

- Automatic backup before restore (optional)
- Rollback capability: Keep previous backup
- Validation: Check foreign key constraints
- Error handling: Transaction rollback on failure

---

## Communication Service Integration

### Phone Call Flow

```
[Tap Phone Number]
    ↓
[Intent: tel:{number}]
    ↓
[Native Dialer Opens]
```

### SMS/WhatsApp Flow

```
[Select Send Method]
    ├─→ SMS
    │   ↓
    │   [Generate Student Message]
    │   ↓
    │   [Intent: sms:{number}?body={message}]
    │   ↓
    │   [Native SMS App Opens]
    │
    └─→ WhatsApp
        ↓
        [Generate Guardian Message]
        ↓
        [Intent: https://wa.me/{number}?text={message}]
        ↓
        [WhatsApp Web/App Opens]
```

### Message Template

```
Auto-generated message includes:
- Student Name
- Roll Number
- Class Name
- Academic Year
- Behavior Status (color name)
- Timestamp
```

---

## File Management Architecture

### Directory Structure

```
/data/data/com.ev.studentrecords/
├── files/
│   ├── student_photos/
│   │   ├── {studentId}_{timestamp}.jpg
│   │   └── ...
│   ├── student_documents/
│   │   ├── {studentId}_{timestamp}_{filename}
│   │   └── ...
│   ├── backups/
│   │   ├── backup_{timestamp}.json
│   │   ├── {studentName}_{timestamp}.pdf
│   │   ├── {studentName}_{timestamp}.xlsx
│   │   └── ...
│   └── ev_app.db (SQLite)
```

### File Operations

```dart
FileService (Singleton)
├── getStudentPhotoDirectory()       → Path
├── getStudentDocumentsDirectory()   → Path
├── getBackupDirectory()             → Path
├── saveStudentPhoto()               → FilePath
├── saveStudentDocument()            → FilePath
├── deleteFile()                     → void
├── fileExists()                     → bool
└── clearAllFiles()                  → void
```

### Permissions Handling

```dart
// Android 10+ scoped storage
- CAMERA: Capture photos
- READ_EXTERNAL_STORAGE: Pick files
- WRITE_EXTERNAL_STORAGE: Save exports

// Request at runtime (Android 6+)
permission_handler package
└── requestPermissions()
```

---

## Performance Considerations

### Database Optimization

```
Operation              | Time Complexity | Notes
─────────────────────|─────────────────|──────────────
Get all students    | O(n)            | No index
Filter by color     | O(log n + m)    | Indexed
Filter by class+year| O(log n + m)    | Composite index
Search by name      | O(n)            | Full text search
Count students      | O(1)            | Aggregate
```

### Memory Management

```
- Student objects: ~2-3 KB each
- 1000 students: ~2-3 MB in memory
- Photos: Lazy loaded, compressed
- Documents: Referenced by path only
- Caching: LRU for frequently accessed data
```

### UI Responsiveness

```
- Async database queries: FutureBuilder
- Long operations: Show progress indicator
- Network calls: None (fully offline)
- Animations: 60 FPS target
- Grid rendering: Virtual scrolling for 200+ items
```

---

## Error Handling Strategy

### Database Errors
```dart
try {
  await _db.addStudent(student);
} catch (e) {
  if (e is DatabaseException) {
    // Handle DB-specific error
  } else {
    // Generic error
  }
  DialogUtil.showErrorDialog(context, e.toString());
}
```

### File Operations
```dart
try {
  await _fileService.saveStudentPhoto(file, studentId);
} catch (e) {
  if (!await _fileService.fileExists(photoPath)) {
    // File not found
  }
  throw Exception('Failed to save photo: $e');
}
```

### User Input Validation
```dart
// Required fields validation
if (_nameController.text.isEmpty ||
    _rollNumberController.text.isEmpty) {
  DialogUtil.showErrorDialog(context, 'Fill all required fields');
  return;
}

// Phone number validation
bool isValid = _commService.isValidPhoneNumber(phoneNumber);
```

---

## Security Architecture

### Data Security

1. **Storage**: All data on device (no cloud)
2. **Encryption**: Device-level (Android encryption optional)
3. **Access**: Single user (HOD) - no login needed
4. **Deletion**: Soft/hard delete as needed

### Permission Model

```
- Camera: Required for photo capture
- Storage: Required for documents and backups
- Phone: Required for calling/SMS/WhatsApp
- Internet: NOT REQUESTED (offline only)
```

### Data Privacy

- No telemetry
- No analytics
- No third-party integrations
- No personal data leaves device
- User has full control

---

## Scalability Roadmap

### Current: Single Department
```
Department (Electrical Engineering)
├── Sections (Morning, Evening)
├── Classes (FE-1, FE-2, ...)
├── Academic Years (1st, 2nd, 3rd, 4th)
└── Students (up to 200 per class)
```

### Future: Multi-Department
```
App
├── Department: Electrical
├── Department: Mechanical
├── Department: Civil
└── Department: Software
```

**No code restructuring required** - Database schema supports it.

---

**Last Updated**: January 2026  
**Flutter Version**: 3.0+  
**Android Target**: 10+
