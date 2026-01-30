import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'ev_app.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String departmentTable = 'departments';
  static const String sectionTable = 'sections';
  static const String classTable = 'classes';
  static const String academicYearTable = 'academic_years';
  static const String studentTable = 'students';
  static const String documentTable = 'student_documents';
  static const String backupMetadataTable = 'backup_metadata';

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Department table
    await db.execute('''
      CREATE TABLE $departmentTable(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create Section table
    await db.execute('''
      CREATE TABLE $sectionTable(
        id TEXT PRIMARY KEY,
        departmentId TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(departmentId) REFERENCES $departmentTable(id)
      )
    ''');

    // Create Class table
    await db.execute('''
      CREATE TABLE $classTable(
        id TEXT PRIMARY KEY,
        departmentId TEXT NOT NULL,
        sectionId TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(departmentId) REFERENCES $departmentTable(id),
        FOREIGN KEY(sectionId) REFERENCES $sectionTable(id)
      )
    ''');

    // Create Academic Year table
    await db.execute('''
      CREATE TABLE $academicYearTable(
        id TEXT PRIMARY KEY,
        departmentId TEXT NOT NULL,
        name TEXT NOT NULL,
        year INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(departmentId) REFERENCES $departmentTable(id)
      )
    ''');

    // Create Student table with behavioral color indexing
    await db.execute('''
      CREATE TABLE $studentTable(
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
        behaviorColor TEXT NOT NULL DEFAULT 'green',
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY(classId) REFERENCES $classTable(id),
        FOREIGN KEY(academicYearId) REFERENCES $academicYearTable(id)
      )
    ''');

    // Create index for behavioral color
    await db.execute('''
      CREATE INDEX idx_behaviorColor ON $studentTable(behaviorColor)
    ''');

    // Create index for class and academic year
    await db.execute('''
      CREATE INDEX idx_classAcademicYear ON $studentTable(classId, academicYearId)
    ''');

    // Create Student Documents table
    await db.execute('''
      CREATE TABLE $documentTable(
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileName TEXT NOT NULL,
        fileType TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY(studentId) REFERENCES $studentTable(id)
      )
    ''');

    // Create Backup Metadata table
    await db.execute('''
      CREATE TABLE $backupMetadataTable(
        id TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL,
        backupPath TEXT NOT NULL,
        studentCount INTEGER NOT NULL,
        appVersion TEXT NOT NULL
      )
    ''');

    // Initialize default data
    await _initializeDefaultData(db);
  }

  Future<void> _initializeDefaultData(Database db) async {
    final depId = 'dept_electrical_001';
    final deptExists = await db.query(
      departmentTable,
      where: 'id = ?',
      whereArgs: [depId],
    );

    if (deptExists.isEmpty) {
      await db.insert(departmentTable, {
        'id': depId,
        'name': 'Electrical Engineering',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Create default sections
      final morning = 'section_morning_001';
      final evening = 'section_evening_001';

      await db.insert(sectionTable, {
        'id': morning,
        'departmentId': depId,
        'name': 'Morning',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert(sectionTable, {
        'id': evening,
        'departmentId': depId,
        'name': 'Evening',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Create default classes
      for (int i = 1; i <= 4; i++) {
        await db.insert(classTable, {
          'id': 'class_fe_${i}_001',
          'departmentId': depId,
          'sectionId': morning,
          'name': 'FE-$i',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // Create academic years
      final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
      for (int i = 0; i < years.length; i++) {
        await db.insert(academicYearTable, {
          'id': 'year_${i + 1}_001',
          'departmentId': depId,
          'name': years[i],
          'year': i + 1,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Department operations
  Future<List<Department>> getDepartments() async {
    final db = await database;
    final result = await db.query(departmentTable);
    return result.map((map) => Department.fromMap(map)).toList();
  }

  Future<Department?> getDepartment(String id) async {
    final db = await database;
    final result = await db.query(
      departmentTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Department.fromMap(result.first) : null;
  }

  Future<String> addDepartment(Department department) async {
    final db = await database;
    await db.insert(departmentTable, department.toMap());
    return department.id;
  }

  Future<int> updateDepartment(Department department) async {
    final db = await database;
    return await db.update(
      departmentTable,
      department.toMap(),
      where: 'id = ?',
      whereArgs: [department.id],
    );
  }

  // Section operations
  Future<List<Section>> getSectionsByDepartment(String departmentId) async {
    final db = await database;
    final result = await db.query(
      sectionTable,
      where: 'departmentId = ?',
      whereArgs: [departmentId],
    );
    return result.map((map) => Section.fromMap(map)).toList();
  }

  Future<String> addSection(Section section) async {
    final db = await database;
    await db.insert(sectionTable, section.toMap());
    return section.id;
  }

  Future<int> updateSection(Section section) async {
    final db = await database;
    return await db.update(
      sectionTable,
      section.toMap(),
      where: 'id = ?',
      whereArgs: [section.id],
    );
  }

  Future<int> deleteSection(String sectionId) async {
    final db = await database;
    return await db.delete(
      sectionTable,
      where: 'id = ?',
      whereArgs: [sectionId],
    );
  }

  // Class operations
  Future<List<StudentClass>> getClassesBySection(String sectionId) async {
    final db = await database;
    final result = await db.query(
      classTable,
      where: 'sectionId = ?',
      whereArgs: [sectionId],
    );
    return result.map((map) => StudentClass.fromMap(map)).toList();
  }

  Future<List<StudentClass>> getClassesByDepartment(String departmentId) async {
    final db = await database;
    final result = await db.query(
      classTable,
      where: 'departmentId = ?',
      whereArgs: [departmentId],
    );
    return result.map((map) => StudentClass.fromMap(map)).toList();
  }

  Future<StudentClass?> getClass(String classId) async {
    final db = await database;
    final result = await db.query(
      classTable,
      where: 'id = ?',
      whereArgs: [classId],
    );
    return result.isNotEmpty ? StudentClass.fromMap(result.first) : null;
  }

  Future<String> addClass(StudentClass studentClass) async {
    final db = await database;
    await db.insert(classTable, studentClass.toMap());
    return studentClass.id;
  }

  Future<int> updateClass(StudentClass studentClass) async {
    final db = await database;
    return await db.update(
      classTable,
      studentClass.toMap(),
      where: 'id = ?',
      whereArgs: [studentClass.id],
    );
  }

  Future<int> deleteClass(String classId) async {
    final db = await database;
    return await db.delete(
      classTable,
      where: 'id = ?',
      whereArgs: [classId],
    );
  }

  // Academic Year operations
  Future<List<AcademicYear>> getAcademicYearsByDepartment(String departmentId) async {
    final db = await database;
    final result = await db.query(
      academicYearTable,
      where: 'departmentId = ?',
      whereArgs: [departmentId],
    );
    return result.map((map) => AcademicYear.fromMap(map)).toList();
  }

  Future<AcademicYear?> getAcademicYear(String yearId) async {
    final db = await database;
    final result = await db.query(
      academicYearTable,
      where: 'id = ?',
      whereArgs: [yearId],
    );
    return result.isNotEmpty ? AcademicYear.fromMap(result.first) : null;
  }

  Future<String> addAcademicYear(AcademicYear year) async {
    final db = await database;
    await db.insert(academicYearTable, year.toMap());
    return year.id;
  }

  Future<int> updateAcademicYear(AcademicYear year) async {
    final db = await database;
    return await db.update(
      academicYearTable,
      year.toMap(),
      where: 'id = ?',
      whereArgs: [year.id],
    );
  }

  Future<int> deleteAcademicYear(String yearId) async {
    final db = await database;
    return await db.delete(
      academicYearTable,
      where: 'id = ?',
      whereArgs: [yearId],
    );
  }

  // Student operations
  Future<List<Student>> getStudentsByClassAndYear(
    String classId,
    String academicYearId,
  ) async {
    final db = await database;
    final result = await db.query(
      studentTable,
      where: 'classId = ? AND academicYearId = ?',
      whereArgs: [classId, academicYearId],
      orderBy: 'rollNumber ASC',
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getStudentsByBehaviorColor(
    BehaviorColor color,
    String classId,
    String academicYearId,
  ) async {
    final db = await database;
    final result = await db.query(
      studentTable,
      where: 'behaviorColor = ? AND classId = ? AND academicYearId = ?',
      whereArgs: [color.name, classId, academicYearId],
      orderBy: 'rollNumber ASC',
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final result = await db.query(studentTable, orderBy: 'createdAt DESC');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getRecentlyEdited({int limit = 5}) async {
    final db = await database;
    final result = await db.query(
      studentTable,
      orderBy: 'updatedAt DESC, createdAt DESC',
      limit: limit,
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudent(String studentId) async {
    final db = await database;
    final result = await db.query(
      studentTable,
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? Student.fromMap(result.first) : null;
  }

  Future<Student?> getStudentByRollNumber(
    String rollNumber,
    String classId,
    String academicYearId,
  ) async {
    final db = await database;
    final result = await db.query(
      studentTable,
      where: 'rollNumber = ? AND classId = ? AND academicYearId = ?',
      whereArgs: [rollNumber, classId, academicYearId],
    );
    return result.isNotEmpty ? Student.fromMap(result.first) : null;
  }

  Future<String> addStudent(Student student) async {
    final db = await database;
    await db.insert(studentTable, student.toMap());
    return student.id;
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      studentTable,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String studentId) async {
    final db = await database;
    // Delete associated documents first
    await db.delete(
      documentTable,
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    // Then delete student
    return await db.delete(
      studentTable,
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> getStudentCountByClassAndYear(String classId, String academicYearId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $studentTable WHERE classId = ? AND academicYearId = ?',
      [classId, academicYearId],
    );
    return (result.first['count'] ?? 0) as int;
  }

  Future<int> getTotalStudentCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $studentTable');
    return (result.first['count'] ?? 0) as int;
  }

  Future<Map<String, int>> getBehaviorColorStats(String classId, String academicYearId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT behaviorColor, COUNT(*) as count FROM $studentTable WHERE classId = ? AND academicYearId = ? GROUP BY behaviorColor',
      [classId, academicYearId],
    );
    final stats = <String, int>{};
    for (var row in result) {
      stats[row['behaviorColor'] as String] = (row['count'] ?? 0) as int;
    }
    return stats;
  }

  // Document operations
  Future<List<StudentDocument>> getStudentDocuments(String studentId) async {
    final db = await database;
    final result = await db.query(
      documentTable,
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return result.map((map) => StudentDocument.fromMap(map)).toList();
  }

  Future<String> addDocument(StudentDocument document) async {
    final db = await database;
    await db.insert(documentTable, document.toMap());
    return document.id;
  }

  Future<int> deleteDocument(String documentId) async {
    final db = await database;
    return await db.delete(
      documentTable,
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  // Backup operations
  Future<String> saveBackupMetadata(BackupMetadata metadata) async {
    final db = await database;
    await db.insert(backupMetadataTable, metadata.toMap());
    return metadata.id;
  }

  Future<List<BackupMetadata>> getBackupMetadata() async {
    final db = await database;
    final result = await db.query(
      backupMetadataTable,
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => BackupMetadata.fromMap(map)).toList();
  }

  // Batch export
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    return {
      'departments': await db.query(departmentTable),
      'sections': await db.query(sectionTable),
      'classes': await db.query(classTable),
      'academicYears': await db.query(academicYearTable),
      'students': await db.query(studentTable),
      'documents': await db.query(documentTable),
    };
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(documentTable);
    await db.delete(studentTable);
    await db.delete(classTable);
    await db.delete(sectionTable);
    await db.delete(academicYearTable);
    await db.delete(departmentTable);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
