import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class FileService {
  static final FileService _instance = FileService._internal();

  factory FileService() {
    return _instance;
  }

  FileService._internal();

  Future<String> getAppDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getStudentPhotoDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final photoDir = Directory('$appDir/student_photos');
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    return photoDir.path;
  }

  Future<String> getStudentDocumentsDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final docDir = Directory('$appDir/student_documents');
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    return docDir.path;
  }

  Future<String> getBackupDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final backupDir = Directory('$appDir/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String> saveStudentPhoto(File sourceFile, String studentId) async {
    final photoDir = await getStudentPhotoDirectory();
    final fileName = '${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destinationPath = '$photoDir/$fileName';
    
    try {
      await sourceFile.copy(destinationPath);
      return destinationPath;
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  Future<String> saveStudentDocument(File sourceFile, String studentId, String fileType) async {
    final docDir = await getStudentDocumentsDirectory();
    final fileName = '${studentId}_${DateTime.now().millisecondsSinceEpoch}_${sourceFile.path.split('/').last}';
    final destinationPath = '$docDir/$fileName';
    
    try {
      await sourceFile.copy(destinationPath);
      return destinationPath;
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  File getFileFromPath(String filePath) {
    return File(filePath);
  }

  String getFileNameFromPath(String filePath) {
    return filePath.split('/').last;
  }

  String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  Future<void> clearAllFiles() async {
    try {
      final photoDir = await getStudentPhotoDirectory();
      final docDir = await getStudentDocumentsDirectory();
      
      Directory(photoDir).deleteSync(recursive: true);
      Directory(docDir).deleteSync(recursive: true);
    } catch (e) {
      throw Exception('Failed to clear files: $e');
    }
  }
}
