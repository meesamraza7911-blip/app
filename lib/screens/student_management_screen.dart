import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import '../services/export_service.dart';
import '../services/communication_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class StudentManagementScreen extends StatefulWidget {
  final Student? student;
  final String? classId;
  final String? academicYearId;
  final String? className;

  const StudentManagementScreen({
    Key? key,
    this.student,
    this.classId,
    this.academicYearId,
    this.className,
  }) : super(key: key);

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  final ExportService _exportService = ExportService(DatabaseService(), FileService());
  final CommunicationService _commService = CommunicationService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _fatherGuardianController;
  late TextEditingController _rollNumberController;
  late TextEditingController _studentContactController;
  late TextEditingController _guardianContactController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cnicController;

  late BehaviorColor selectedColor;
  String? photoPath;
  List<StudentDocument> documents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.student != null) {
      _loadStudentData();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.student?.studentName ?? '');
    _fatherGuardianController = TextEditingController(text: widget.student?.fatherGuardianName ?? '');
    _rollNumberController = TextEditingController(text: widget.student?.rollNumber ?? '');
    _studentContactController = TextEditingController(text: widget.student?.studentContact ?? '');
    _guardianContactController = TextEditingController(text: widget.student?.fatherGuardianContact ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _cnicController = TextEditingController(text: widget.student?.cnic ?? '');
    selectedColor = widget.student?.behaviorColor ?? BehaviorColor.green;
    photoPath = widget.student?.photoPath;
  }

  Future<void> _loadStudentData() async {
    if (widget.student == null) return;
    try {
      final docs = await _db.getStudentDocuments(widget.student!.id);
      setState(() => documents = docs);
    } catch (e) {
      debugPrint('Error loading documents: $e');
    }
  }

  Future<void> _pickPhoto() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      try {
        final newPhotoPath = await _fileService.saveStudentPhoto(
          File(pickedFile.path),
          widget.student?.id ?? const Uuid().v4(),
        );
        setState(() => photoPath = newPhotoPath);
      } catch (e) {
        if (mounted) DialogUtil.showErrorDialog(context, 'Failed to save photo: $e');
      }
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      try {
        final studentId = widget.student?.id ?? const Uuid().v4();
        final savedPath = await _fileService.saveStudentDocument(
          File(result.files.single.path!),
          studentId,
          result.files.single.extension ?? 'pdf',
        );

        final doc = StudentDocument(
          id: const Uuid().v4(),
          studentId: studentId,
          filePath: savedPath,
          fileName: result.files.single.name,
          fileType: result.files.single.extension ?? 'pdf',
          uploadedAt: DateTime.now(),
        );

        setState(() => documents.add(doc));

        if (widget.student != null) {
          await _db.addDocument(doc);
        }
      } catch (e) {
        if (mounted) DialogUtil.showErrorDialog(context, 'Failed to save document: $e');
      }
    }
  }

  Future<void> _saveStudent() async {
    if (_nameController.text.isEmpty ||
        _rollNumberController.text.isEmpty ||
        _studentContactController.text.isEmpty ||
        _fatherGuardianController.text.isEmpty ||
        _guardianContactController.text.isEmpty) {
      DialogUtil.showErrorDialog(context, 'Please fill in all required fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final student = Student(
        id: widget.student?.id ?? const Uuid().v4(),
        rollNumber: _rollNumberController.text,
        classId: widget.student?.classId ?? widget.classId!,
        academicYearId: widget.student?.academicYearId ?? widget.academicYearId!,
        studentName: _nameController.text,
        fatherGuardianName: _fatherGuardianController.text,
        studentContact: _studentContactController.text,
        fatherGuardianContact: _guardianContactController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        cnic: _cnicController.text.isEmpty ? null : _cnicController.text,
        photoPath: photoPath,
        behaviorColor: selectedColor,
        createdAt: widget.student?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.student == null) {
        await _db.addStudent(student);
      } else {
        await _db.updateStudent(student);
      }

      // Save documents for new students
      if (widget.student == null) {
        for (var doc in documents) {
          await _db.addDocument(doc.copyWith(studentId: student.id));
        }
      }

      if (mounted) {
        DialogUtil.showSuccessDialog(context, 'Student saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) DialogUtil.showErrorDialog(context, 'Error saving student: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent() async {
    final confirmed = await DialogUtil.showConfirmDialog(
      context,
      title: 'Delete Student',
      message: 'Are you sure you want to delete this student record?',
    );

    if (confirmed != true || widget.student == null) return;

    try {
      await _db.deleteStudent(widget.student!.id);
      if (mounted) {
        DialogUtil.showSuccessDialog(context, 'Student deleted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) DialogUtil.showErrorDialog(context, 'Error deleting student: $e');
    }
  }

  Future<void> _contactVia(String type) async {
    final phoneNumber = type == 'student'
        ? _studentContactController.text
        : _guardianContactController.text;

    if (phoneNumber.isEmpty) {
      DialogUtil.showErrorDialog(context, 'Phone number not provided');
      return;
    }

    try {
      final message = type == 'student'
          ? _commService.generateStudentMessage(
              student: widget.student!,
              className: widget.className ?? 'N/A',
              academicYear: 'N/A',
            )
          : _commService.generateGuardianMessage(
              student: widget.student!,
              className: widget.className ?? 'N/A',
              academicYear: 'N/A',
            );

      if (type == 'call') {
        await _commService.makePhoneCall(phoneNumber);
      } else if (type == 'sms') {
        await _commService.sendSMS(phoneNumber, message);
      } else if (type == 'whatsapp') {
        await _commService.sendWhatsApp(phoneNumber, message);
      }
    } catch (e) {
      if (mounted) DialogUtil.showErrorDialog(context, 'Error: $e');
    }
  }

  StudentDocument copyWith({
    String? id,
    String? studentId,
    String? filePath,
    String? fileName,
    String? fileType,
    DateTime? uploadedAt,
  }) {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherGuardianController.dispose();
    _rollNumberController.dispose();
    _studentContactController.dispose();
    _guardianContactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      color: AppColors.lightGrey,
                    ),
                    child: photoPath != null && File(photoPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            child: Image.file(
                              File(photoPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person, size: 60, color: AppColors.grey),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),

            // Personal information fields
            CustomTextField(
              label: AppStrings.studentName,
              controller: _nameController,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.fatherGuardianName,
              controller: _fatherGuardianController,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.rollNumber,
              controller: _rollNumberController,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),

            // Contact Information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.studentContact,
              controller: _studentContactController,
              inputType: TextInputType.phone,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.guardianContact,
              controller: _guardianContactController,
              inputType: TextInputType.phone,
              isRequired: true,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.email,
              controller: _emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.address,
              controller: _addressController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: AppStrings.cnic,
              controller: _cnicController,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Behavior color picker
            BehaviorColorPicker(
              initialColor: selectedColor,
              onColorSelected: (color) => setState(() => selectedColor = color),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Documents section
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),

            if (documents.isNotEmpty)
              ...documents.map((doc) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(doc.fileName),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => documents.remove(doc));
                    },
                  ),
                ),
              )).toList(),

            ElevatedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Add Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            CustomButton(
              label: 'Save Student',
              onPressed: _saveStudent,
              isLoading: isLoading,
              backgroundColor: Colors.green,
            ),

            if (widget.student != null)
              Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Quick Contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ElevatedButton(
                        onPressed: () => _contactVia('call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Call'),
                      ),
                      ElevatedButton(
                        onPressed: () => _contactVia('sms'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('SMS'),
                      ),
                      ElevatedButton(
                        onPressed: () => _contactVia('whatsapp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('WhatsApp'),
                      ),
                    ],
                  ),
                ],
              ),

            if (widget.student != null)
              Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  CustomButton(
                    label: 'Delete Student',
                    onPressed: _deleteStudent,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

extension on StudentDocument {
  StudentDocument copyWith({
    String? id,
    String? studentId,
    String? filePath,
    String? fileName,
    String? fileType,
    DateTime? uploadedAt,
  }) {
    return StudentDocument(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
