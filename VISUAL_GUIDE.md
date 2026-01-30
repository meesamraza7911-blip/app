# EV Application - Visual Flow & Component Guide

## 🎬 App Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        APP START                                 │
│                          │                                       │
│                 main.dart - Initialization                       │
│                 • WidgetsFlutterBinding.ensureInitialized()      │
│                 • DatabaseService initialize                    │
│                 • FileService initialize                        │
│                          │                                       │
└──────────────────────────┼──────────────────────────────────────┘
                           │
                    ▼ (Runapp)
┌──────────────────────────────────────────────────────────────────┐
│              MaterialApp - Theme Setup                            │
│              • Color scheme: Blue primary                         │
│              • Material 3 design                                  │
│              • Home: SplashScreen                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    ▼ (Shows)
┌──────────────────────────────────────────────────────────────────┐
│          SplashScreen (3 seconds)                                 │
│          ┌─────────────────────────────┐                         │
│          │        EV Logo              │                         │
│          │   Animated Circle + Text    │                         │
│          │  Student Record Management  │                         │
│          │  Progress Indicator         │                         │
│          └─────────────────────────────┘                         │
│          • AnimationController (2s)                              │
│          • FadeTransition                                        │
│          • SlideTransition                                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
              3 seconds elapsed
                           │
                    ▼ (Auto-navigate)
┌──────────────────────────────────────────────────────────────────┐
│              DashboardScreen                                      │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ AppBar                                                     │  │
│  │ • Title: "Dashboard"                                       │  │
│  │ • Backup button (icon)                                     │  │
│  │ • Info button (icon)                                       │  │
│  └────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Overview Section (4 StatCards in 2x2 grid)                │  │
│  │ ┌──────────────┐ ┌──────────────┐                         │  │
│  │ │Total Students│ │Good (Green)  │                         │  │
│  │ │      X       │ │      Y       │                         │  │
│  │ └──────────────┘ └──────────────┘                         │  │
│  │ ┌──────────────┐ ┌──────────────┐                         │  │
│  │ │Needs Improve │ │Weak (Red)    │                         │  │
│  │ │      Z       │ │      W       │                         │  │
│  │ └──────────────┘ └──────────────┘                         │  │
│  └────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Quick Actions                                              │  │
│  │ [Add Student] [View All] [Backup Data]                    │  │
│  └────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Recently Edited Students (List)                           │  │
│  │ ┌──────────────────────────────────────────┐              │  │
│  │ │ 🟢 Student Name  | Roll: 5              │ → Details    │  │
│  │ ├──────────────────────────────────────────┤              │  │
│  │ │ 🟡 Student Name  | Roll: 12             │ → Details    │  │
│  │ ├──────────────────────────────────────────┤              │  │
│  │ │ 🔴 Student Name  | Roll: 23             │ → Details    │  │
│  │ └──────────────────────────────────────────┘              │  │
│  └────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ FloatingActionButton (Bottom Right)                        │  │
│  │ [Manage Students] (with arrow icon)                        │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
```

---

## 🗂️ Navigation Hierarchy

```
DASHBOARD (Home)
    │
    ├─→ [Manage Students FAB]
    │       │
    │       ▼
    │   DEPARTMENT SCREEN
    │   ┌─────────────────────────┐
    │   │ Electrical Engineering  │
    │   │ (Single Item, tap)      │
    │   └──────┬──────────────────┘
    │          │
    │          ▼
    │   SECTION SCREEN
    │   ┌─────────────────────────┐
    │   │ Morning                 │
    │   │ Evening                 │
    │   └──────┬──────────────────┘
    │          │
    │          ▼
    │   CLASS SCREEN
    │   ┌─────────────────────────┐
    │   │ FE-1                    │
    │   │ FE-2                    │
    │   │ FE-3                    │
    │   │ FE-4                    │
    │   └──────┬──────────────────┘
    │          │
    │          ▼
    │   ACADEMIC YEAR SCREEN
    │   ┌─────────────────────────┐
    │   │ 1st Year                │
    │   │ 2nd Year                │
    │   │ 3rd Year                │
    │   │ 4th Year                │
    │   └──────┬──────────────────┘
    │          │
    │          ▼
    │   ROLL NUMBER SCREEN ⭐
    │   ┌─────────────────────────┐
    │   │ Filter Buttons:         │
    │   │ [🟢] [🟡] [🔴] [🔵]   │
    │   │ Search: [_________]     │
    │   │                         │
    │   │ Roll Numbers (Grid):    │
    │   │ ┌─┬─┬─┬─┬─┐            │
    │   │ │1│2│3│4│5│            │
    │   │ ├─┼─┼─┼─┼─┤            │
    │   │ │6│7│8│9│10│           │
    │   │ └─┴─┴─┴─┴─┘            │
    │   │ (Color badges on cards)│
    │   │ + Add button (FAB)     │
    │   │ (Tap any card)         │
    │   └──────┬──────────────────┘
    │          │
    │          ▼
    │   STUDENT PROFILE SCREEN ⭐
    │   ┌─────────────────────────┐
    │   │ Photo:                  │
    │   │ [______________]        │
    │   │ [Take Photo] button     │
    │   │                         │
    │   │ Personal Info:          │
    │   │ [Name: _______]         │
    │   │ [Father: _____]         │
    │   │ [Roll: ___]             │
    │   │                         │
    │   │ Contact Info:           │
    │   │ [Student: ___]          │
    │   │ [Guardian: ___]         │
    │   │ [Email: ___] (opt)      │
    │   │ [Address: ___](opt)     │
    │   │ [CNIC: ___] (opt)       │
    │   │                         │
    │   │ Color Picker:           │
    │   │ ○🟢 ○🟡 ○🔴 ○🔵      │
    │   │                         │
    │   │ Documents:              │
    │   │ [Upload Doc] button     │
    │   │                         │
    │   │ Quick Contact:          │
    │   │ [Call] [SMS] [WhatsApp] │
    │   │                         │
    │   │ [Save Student]          │
    │   │ [Delete Student]        │
    │   └─────────────────────────┘
    │
    ├─→ [Add Student FAB] (from dashboard)
    │       │
    │       ▼ (skips navigation to STUDENT PROFILE)
    │   STUDENT PROFILE (Add mode)
    │
    └─→ [Backup Button]
            │
            ▼
        CREATE BACKUP
        • Exports all data to JSON
        • Saves to /backups/
        • Shows success message
```

---

## 🎨 UI Component Hierarchy

```
MATERIAL DESIGN STRUCTURE
│
├─ AppBar (Elevated, Blue background)
│  ├─ Back button (auto)
│  ├─ Title (centered)
│  └─ Action icons (backup, info)
│
├─ FloatingActionButton
│  ├─ Add student
│  ├─ Backup
│  └─ Custom colors
│
├─ Cards
│  ├─ StatCard (dashboard stats)
│  ├─ ListTile (student lists)
│  └─ RollNumberCard (grid items)
│
├─ TextFields
│  ├─ CustomTextField (bordered, focused)
│  ├─ Search field (with clear button)
│  └─ Form validators
│
├─ Buttons
│  ├─ ElevatedButton (primary actions)
│  ├─ TextButton (secondary)
│  ├─ IconButton (quick actions)
│  └─ BehaviorFilterButton (custom)
│
├─ Dialog
│  ├─ Confirmation dialogs
│  ├─ Error dialogs
│  └─ Success dialogs
│
├─ Grid/List Views
│  ├─ GridView (roll numbers 5 columns)
│  ├─ ListView (departments, sections, etc.)
│  └─ GridView.builder (dynamic)
│
└─ Custom Widgets
   ├─ BehaviorColorPicker (4 circles)
   ├─ BehaviorColorBadge (small circle)
   ├─ BehaviorFilterButton (pill button)
   └─ RollNumberCard (grid item with badge)
```

---

## 🌈 Color Scheme

```
PRIMARY COLORS:
┌─────────────────────────────────────────┐
│ 🟦 Primary Blue:    #2196F3             │
│ 🟦 Dark Blue:       #1976D2             │
│ 🟦 Light Blue:      #BBDEFB             │
│ ⚪ White:           #FFFFFF             │
│ ⚫ Black:           #000000             │
│ ⚪ Grey:            #757575             │
└─────────────────────────────────────────┘

BEHAVIOR COLORS:
┌─────────────────────────────────────────┐
│ 🟢 Green:           #4CAF50             │
│ 🟡 Yellow:          #FFC107             │
│ 🔴 Red:             #F44336             │
│ 🔵 Blue:            #2196F3             │
└─────────────────────────────────────────┘

STATUS COLORS:
┌─────────────────────────────────────────┐
│ ✅ Success Green:   #4CAF50             │
│ ⚠️ Warning Orange:  #FF9800             │
│ ❌ Error Red:       #F44336             │
│ ℹ️ Info Blue:       #2196F3             │
└─────────────────────────────────────────┘
```

---

## 📱 Screen Layout Examples

### Dashboard Screen Layout
```
┌──────────────────────────────────────────┐
│ █ Dashboard    [🔐] [ℹ️]                │ ← AppBar
├──────────────────────────────────────────┤
│ Overview                          Refresh │
├──────────────────────────────────────────┤
│ ┌──────────────┐  ┌──────────────┐      │
│ │ Total        │  │ Good         │      │
│ │ Students     │  │ (Green)      │      │
│ │     100      │  │     45       │      │
│ │ 👥           │  │ ✓            │      │
│ └──────────────┘  └──────────────┘      │
│ ┌──────────────┐  ┌──────────────┐      │
│ │ Needs Improv │  │ Weak         │      │
│ │ (Yellow)     │  │ (Red)        │      │
│ │     30       │  │     25       │      │
│ │ ⚠️            │  │ ❌           │      │
│ └──────────────┘  └──────────────┘      │
├──────────────────────────────────────────┤
│ Quick Actions                            │
│ [➕ Add Student] [👁️ View All]          │
│ [💾 Backup Data]                        │
├──────────────────────────────────────────┤
│ Recently Edited                          │
│                                          │
│ 🟢 Ahmed Khan       | Roll: 05          │
│ 🟡 Fatima Ali       | Roll: 12          │
│ 🔴 Hassan Malik     | Roll: 23          │
│ 🟢 Zainab Ahmed     | Roll: 34          │
│ 🔵 Usman Khan       | Roll: 45          │
│                                          │
├──────────────────────────────────────────┤
│                    [Manage Students ➜] ↗️ │ ← FAB
└──────────────────────────────────────────┘
```

### Roll Number Screen Layout
```
┌──────────────────────────────────────────┐
│ █ FE-1 - 1st Year  [⬅️]                 │ ← AppBar
├──────────────────────────────────────────┤
│ [🔍 Search by roll or name    ✕]        │ ← Search
├──────────────────────────────────────────┤
│ Filter: [🟢] [🟡] [🔴] [🔵] | Clear    │ ← Filters
├──────────────────────────────────────────┤
│ Total: 47 students                       │
│                                          │
│ ┌──┬──┬──┬──┬──┐                        │
│ │1🟢│2 │3 │4🟡│5 │ ← Color badges      │
│ ├──┼──┼──┼──┼──┤                        │
│ │6🔴│7 │8 │9 │10│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │11│12│13│14│15│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │16│17│18│19│20│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │21│22│23│24│25│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │26│27│28│29│30│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │31│32│33│34│35│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │36│37│38│39│40│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │41│42│43│44│45│                      │
│ ├──┼──┼──┼──┼──┤                        │
│ │46│47│  │  │  │                      │
│ └──┴──┴──┴──┴──┘                        │
│                                          │
├──────────────────────────────────────────┤
│                     [➕ Add Student] ↗️  │ ← FAB
└──────────────────────────────────────────┘
```

### Student Profile Screen Layout
```
┌──────────────────────────────────────────┐
│ █ Edit Student    [⬅️]                  │ ← AppBar
├──────────────────────────────────────────┤
│              ┌─────────────┐             │
│              │             │             │
│              │  [ Photo ]  │             │
│              │             │             │
│              └─────────────┘             │
│         [📷 Take Photo] button           │
├──────────────────────────────────────────┤
│ Personal Information                     │
├──────────────────────────────────────────┤
│ Student Name *              [_________]  │
│ Father/Guardian Name *      [_________]  │
│ Roll Number *               [___]        │
├──────────────────────────────────────────┤
│ Contact Information                      │
├──────────────────────────────────────────┤
│ Student Contact *           [___-_____]  │
│ Guardian Contact *          [___-_____]  │
│ Email                       [__@__]      │
│ Address                     [_________]  │
│ CNIC / B-Form              [___-_____]  │
├──────────────────────────────────────────┤
│ Behavior Status                          │
├──────────────────────────────────────────┤
│ ⭕🟢  ⭕🟡  ⭕🔴  ⭕🔵                 │
│  Green Yellow Red   Blue                 │
├──────────────────────────────────────────┤
│ Documents                                │
├──────────────────────────────────────────┤
│ 📄 Document_1.pdf     [✕]               │
│ 📄 Document_2.jpg     [✕]               │
│ [📤 Add Document]                       │
├──────────────────────────────────────────┤
│ Quick Contact                            │
│ [☎️ Call] [💬 SMS] [💚 WhatsApp]       │
├──────────────────────────────────────────┤
│ [💾 Save Student]                       │
│ [🗑️ Delete Student]                     │
└──────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

```
USER ACTION
    │
    ├─→ Tap on Roll Number Card
    │       │
    │       ▼
    │   Load Student from DB
    │   (DatabaseService.getStudent)
    │       │
    │       ▼
    │   Build StudentManagementScreen
    │   (Edit mode)
    │       │
    │       ▼
    │   Display Student Data
    │   • Populate text fields
    │   • Load photo if exists
    │   • Load documents
    │   • Show behavior color
    │       │
    │       ▼
    │   User Makes Changes
    │       │
    │       ├─→ Text field changes → setState()
    │       ├─→ Color picker changes → setState()
    │       ├─→ Add photo → saveStudentPhoto()
    │       └─→ Add document → saveStudentDocument()
    │       │
    │       ▼
    │   User Taps Save
    │       │
    │       ▼
    │   Validate All Fields
    │       │
    │       ├─→ If invalid → Show Error Dialog
    │       │
    │       └─→ If valid
    │           │
    │           ▼
    │       Create Student Object
    │       • Copy all field values
    │       • Include behavior color
    │       │
    │       ▼
    │   Save to Database
    │   (DatabaseService.updateStudent)
    │       │
    │       ▼
    │   Save Documents
    │   (DatabaseService.addDocument)
    │       │
    │       ▼
    │   Show Success Dialog
    │       │
    │       ▼
    │   Pop Navigation
    │   (Return to Roll Number Screen)
    │       │
    │       ▼
    │   Roll Number Screen Re-queries
    │   (FutureBuilder rebuilds)
    │       │
    │       ▼
    │   Grid Updates
    │   • New student in grid
    │   • Color badge visible
    │   • Filtering still works
    │
    └─→ Tap Filter Button
            │
            ▼
        Select Color
        (BehaviorFilterButton)
            │
            ▼
        Query Students by Color
        (DatabaseService.getStudentsByBehaviorColor)
            │
            ├─→ Use index: idx_behaviorColor
            │
            ▼
        Return Filtered Results
        (O(log n) with index)
            │
            ▼
        setState()
            │
            ▼
        Grid Rebuilds
        (Shows only selected color)
```

---

## 🗄️ Database Schema Visualization

```
DEPARTMENTS
┌────────────────────────────┐
│ id (PK): "dept_001"        │
│ name: "Electrical"         │
│ createdAt: ISO datetime    │
└─────────┬──────────────────┘
          │ 1:N
          │
          ├─────────────────────┐
          │                     │
          ▼                     ▼
      SECTIONS            ACADEMIC_YEARS
      ┌─────────┐         ┌─────────┐
      │ Morning │         │ 1st Yr  │
      │ Evening │         │ 2nd Yr  │
      │ Custom  │         │ 3rd Yr  │
      └────┬────┘         │ 4th Yr  │
           │              └────┬────┘
           ▼ 1:N               │
      CLASSES                  │
      ┌──────────────────┐     │
      │ FE-1             │     │
      │ FE-2             │     │
      │ FE-3             │     │
      │ FE-4             │     │
      └─────┬────────────┘     │
            │                  │
            └────────┬─────────┘
                     │ Many-to-Many (via)
                     ▼
            STUDENTS (Main Table)
            ┌──────────────────────────────┐
            │ id (PK)                      │
            │ rollNumber                   │
            │ classId (FK)                 │
            │ academicYearId (FK)          │
            │ studentName                  │
            │ fatherGuardianName           │
            │ studentContact               │
            │ fatherGuardianContact        │
            │ email                        │
            │ address                      │
            │ cnic                         │
            │ photoPath                    │
            │ behaviorColor (⭐ INDEXED)  │
            │ createdAt                    │
            │ updatedAt                    │
            └─────┬────────────────────────┘
                  │ 1:N
                  ▼
          STUDENT_DOCUMENTS
          ┌──────────────────┐
          │ id (PK)          │
          │ studentId (FK)   │
          │ filePath         │
          │ fileName         │
          │ fileType         │
          │ uploadedAt       │
          └──────────────────┘

INDEXES:
└─ idx_behaviorColor ON students(behaviorColor)
└─ idx_classAcademicYear ON students(classId, academicYearId)
```

---

## 📲 State Management Flow

```
STATELESS WIDGETS:
• BehaviorColorBadge - No state needed
• RollNumberCard - No state needed
• CustomTextField - No state needed
• CustomButton - No state needed
• StatCard - No state needed
• BehaviorColorPicker (parent passes callback)

STATEFUL WIDGETS:
• SplashScreen
  - animationController: AnimationController
  - _fadeAnimation: Animation<double>
  - _slideAnimation: Animation<Offset>

• DashboardScreen
  - totalStudents: int
  - recentStudents: List<Student>
  - isLoading: bool

• RollNumberScreen
  - selectedFilterColor: BehaviorColor?
  - _searchController: TextEditingController
  - _studentsFuture: Future<List<Student>>

• StudentManagementScreen
  - _nameController: TextEditingController
  - _rollNumberController: TextEditingController
  - ... (multiple text controllers)
  - selectedColor: BehaviorColor
  - photoPath: String?
  - documents: List<StudentDocument>
  - isLoading: bool

ASYNC PATTERNS:
• FutureBuilder for one-time DB queries
• setState for UI updates
• Callbacks for filter/search
• No ChangeNotifier (not needed for this size app)
```

---

**This visual guide helps understand the complete architecture and flow of the EV application at a glance.**

