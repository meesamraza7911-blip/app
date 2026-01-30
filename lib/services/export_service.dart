import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel_pkg;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';

class ExportService {
  final DatabaseService _db;
  final FileService _fileService;

  ExportService(this._db, this._fileService);

  Future<File> exportStudentToPDF(Student student, StudentClass? studentClass, AcademicYear? academicYear) async {
    final pdf = pw.Document();

    final profilePhoto = student.photoPath != null && await _fileService.fileExists(student.photoPath!)
        ? pw.MemoryImage(File(student.photoPath!).readAsBytesSync())
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Student Record', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Electrical Engineering Department', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                if (profilePhoto != null)
                  pw.Image(profilePhoto, width: 80, height: 100),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text('Personal Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildPDFField('Full Name', student.studentName),
          _buildPDFField('Father/Guardian Name', student.fatherGuardianName),
          _buildPDFField('Roll Number', student.rollNumber),
          _buildPDFField('Class', studentClass?.name ?? 'N/A'),
          _buildPDFField('Academic Year', academicYear?.name ?? 'N/A'),
          pw.SizedBox(height: 15),
          pw.Text('Contact Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildPDFField('Student Contact', student.studentContact),
          _buildPDFField('Guardian Contact', student.fatherGuardianContact),
          if (student.email != null) _buildPDFField('Email', student.email!),
          pw.SizedBox(height: 15),
          pw.Text('Additional Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          if (student.address != null) _buildPDFField('Address', student.address!),
          if (student.cnic != null) _buildPDFField('CNIC/B-Form', student.cnic!),
          _buildPDFField('Status', student.behaviorColor.label),
          pw.SizedBox(height: 10),
          pw.Text('Date: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );

    final backupDir = await _fileService.getBackupDirectory();
    final fileName = '${student.studentName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('$backupDir/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildPDFField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  Future<File> exportStudentToExcel(
    Student student,
    StudentClass? studentClass,
    AcademicYear? academicYear,
  ) async {
    final excelSheet = excel_pkg.Excel.createExcel();
    final sheet = excelSheet['Sheet1'];

    // Title
    sheet.appendRow(['Student Record - Electrical Engineering Department']);
    sheet.appendRow([]);

    // Personal Information
    sheet.appendRow(['Personal Information']);
    sheet.appendRow(['Full Name', student.studentName]);
    sheet.appendRow(['Father/Guardian Name', student.fatherGuardianName]);
    sheet.appendRow(['Roll Number', student.rollNumber]);
    sheet.appendRow(['Class', studentClass?.name ?? 'N/A']);
    sheet.appendRow(['Academic Year', academicYear?.name ?? 'N/A']);
    sheet.appendRow([]);

    // Contact Information
    sheet.appendRow(['Contact Information']);
    sheet.appendRow(['Student Contact', student.studentContact]);
    sheet.appendRow(['Guardian Contact', student.fatherGuardianContact]);
    if (student.email != null) {
      sheet.appendRow(['Email', student.email!]);
    }
    sheet.appendRow([]);

    // Additional Information
    sheet.appendRow(['Additional Information']);
    if (student.address != null) {
      sheet.appendRow(['Address', student.address!]);
    }
    if (student.cnic != null) {
      sheet.appendRow(['CNIC/B-Form', student.cnic!]);
    }
    sheet.appendRow(['Behavior Status', student.behaviorColor.label]);
    sheet.appendRow([]);

    // Metadata
    sheet.appendRow(['Generated', DateTime.now().toString().split('.')[0]]);

    final backupDir = await _fileService.getBackupDirectory();
    final fileName = '${student.studentName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('$backupDir/$fileName');
    await file.writeAsBytes(excelSheet.encode()!);
    return file;
  }

  Future<List<File>> exportStudentsToCSV(List<Student> students, List<StudentClass> classes, List<AcademicYear> years) async {
    final files = <File>[];
    final backupDir = await _fileService.getBackupDirectory();

    // Create main CSV
    final buffer = StringBuffer();
    buffer.writeln('Roll Number,Student Name,Father/Guardian,Class,Academic Year,Contact,Guardian Contact,Behavior Status');

    for (var student in students) {
      final studentClass = classes.firstWhere(
        (c) => c.id == student.classId,
        orElse: () => StudentClass(
          id: '',
          departmentId: '',
          sectionId: '',
          name: 'N/A',
          createdAt: DateTime.now(),
        ),
      );
      final year = years.firstWhere(
        (y) => y.id == student.academicYearId,
        orElse: () => AcademicYear(
          id: '',
          departmentId: '',
          name: 'N/A',
          year: 0,
          createdAt: DateTime.now(),
        ),
      );

      buffer.writeln(
        '${student.rollNumber},${student.studentName},${student.fatherGuardianName},${studentClass.name},${year.name},${student.studentContact},${student.fatherGuardianContact},${student.behaviorColor.label}',
      );
    }

    final csvFile = File('$backupDir/students_${DateTime.now().millisecondsSinceEpoch}.csv');
    await csvFile.writeAsString(buffer.toString());
    files.add(csvFile);

    return files;
  }
}

class BackupService {
  final DatabaseService _db;
  final FileService _fileService;

  BackupService(this._db, this._fileService);

  Future<File> createBackup() async {
    final backupData = await _db.exportAllData();
    final backupDir = await _fileService.getBackupDirectory();
    
    final backupJson = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': backupData,
    };

    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('$backupDir/$fileName');
    await file.writeAsString(jsonEncode(backupJson));

    // Save metadata
    final studentCount = await _db.getTotalStudentCount();
    final metadata = BackupMetadata(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      backupPath: file.path,
      studentCount: studentCount,
      appVersion: '1.0.0',
    );
    await _db.saveBackupMetadata(metadata);

    return file;
  }

  Future<void> restoreBackup(File backupFile) async {
    try {
      final jsonContent = await backupFile.readAsString();
      final backupData = jsonDecode(jsonContent);
      
      if (backupData['version'] != '1.0') {
        throw Exception('Unsupported backup version');
      }

      final data = backupData['data'] as Map<String, dynamic>;
      
      // Clear existing data
      await _db.deleteAllData();

      // Restore departments
      if (data.containsKey('departments')) {
        for (var dept in data['departments']) {
          final department = Department.fromMap(Map<String, dynamic>.from(dept));
          await _db.addDepartment(department);
        }
      }

      // Restore sections
      if (data.containsKey('sections')) {
        for (var section in data['sections']) {
          final sec = Section.fromMap(Map<String, dynamic>.from(section));
          await _db.addSection(sec);
        }
      }

      // Restore classes
      if (data.containsKey('classes')) {
        for (var cls in data['classes']) {
          final studentClass = StudentClass.fromMap(Map<String, dynamic>.from(cls));
          await _db.addClass(studentClass);
        }
      }

      // Restore academic years
      if (data.containsKey('academicYears')) {
        for (var year in data['academicYears']) {
          final academicYear = AcademicYear.fromMap(Map<String, dynamic>.from(year));
          await _db.addAcademicYear(academicYear);
        }
      }

      // Restore students
      if (data.containsKey('students')) {
        for (var student in data['students']) {
          final std = Student.fromMap(Map<String, dynamic>.from(student));
          await _db.addStudent(std);
        }
      }

      // Restore documents
      if (data.containsKey('documents')) {
        for (var doc in data['documents']) {
          final document = StudentDocument.fromMap(Map<String, dynamic>.from(doc));
          await _db.addDocument(document);
        }
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  Future<List<BackupMetadata>> getBackupHistory() async {
    return await _db.getBackupMetadata();
  }

  Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
}
