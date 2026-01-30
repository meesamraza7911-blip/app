// Models for EV Application

class Department {
  final String id;
  final String name;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class Section {
  final String id;
  final String departmentId;
  final String name;
  final DateTime createdAt;

  Section({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departmentId': departmentId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] as String,
      departmentId: map['departmentId'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class StudentClass {
  final String id;
  final String departmentId;
  final String sectionId;
  final String name;
  final DateTime createdAt;

  StudentClass({
    required this.id,
    required this.departmentId,
    required this.sectionId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departmentId': departmentId,
      'sectionId': sectionId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudentClass.fromMap(Map<String, dynamic> map) {
    return StudentClass(
      id: map['id'] as String,
      departmentId: map['departmentId'] as String,
      sectionId: map['sectionId'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class AcademicYear {
  final String id;
  final String departmentId;
  final String name;
  final int year;
  final DateTime createdAt;

  AcademicYear({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.year,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departmentId': departmentId,
      'name': name,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AcademicYear.fromMap(Map<String, dynamic> map) {
    return AcademicYear(
      id: map['id'] as String,
      departmentId: map['departmentId'] as String,
      name: map['name'] as String,
      year: map['year'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

enum BehaviorColor {
  green('Green', 0xFF4CAF50),
  yellow('Yellow', 0xFFFFC107),
  red('Red', 0xFFF44336),
  blue('Blue', 0xFF2196F3);

  final String label;
  final int colorValue;

  const BehaviorColor(this.label, this.colorValue);

  static BehaviorColor fromString(String value) {
    return BehaviorColor.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BehaviorColor.green,
    );
  }
}

class Student {
  final String id;
  final String rollNumber;
  final String classId;
  final String academicYearId;
  final String studentName;
  final String fatherGuardianName;
  final String studentContact;
  final String fatherGuardianContact;
  final String? email;
  final String? address;
  final String? cnic;
  final String? photoPath;
  final BehaviorColor behaviorColor;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.rollNumber,
    required this.classId,
    required this.academicYearId,
    required this.studentName,
    required this.fatherGuardianName,
    required this.studentContact,
    required this.fatherGuardianContact,
    this.email,
    this.address,
    this.cnic,
    this.photoPath,
    this.behaviorColor = BehaviorColor.green,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rollNumber': rollNumber,
      'classId': classId,
      'academicYearId': academicYearId,
      'studentName': studentName,
      'fatherGuardianName': fatherGuardianName,
      'studentContact': studentContact,
      'fatherGuardianContact': fatherGuardianContact,
      'email': email,
      'address': address,
      'cnic': cnic,
      'photoPath': photoPath,
      'behaviorColor': behaviorColor.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      rollNumber: map['rollNumber'] as String,
      classId: map['classId'] as String,
      academicYearId: map['academicYearId'] as String,
      studentName: map['studentName'] as String,
      fatherGuardianName: map['fatherGuardianName'] as String,
      studentContact: map['studentContact'] as String,
      fatherGuardianContact: map['fatherGuardianContact'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      cnic: map['cnic'] as String?,
      photoPath: map['photoPath'] as String?,
      behaviorColor: BehaviorColor.fromString(map['behaviorColor'] as String? ?? 'green'),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  Student copyWith({
    String? id,
    String? rollNumber,
    String? classId,
    String? academicYearId,
    String? studentName,
    String? fatherGuardianName,
    String? studentContact,
    String? fatherGuardianContact,
    String? email,
    String? address,
    String? cnic,
    String? photoPath,
    BehaviorColor? behaviorColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      classId: classId ?? this.classId,
      academicYearId: academicYearId ?? this.academicYearId,
      studentName: studentName ?? this.studentName,
      fatherGuardianName: fatherGuardianName ?? this.fatherGuardianName,
      studentContact: studentContact ?? this.studentContact,
      fatherGuardianContact: fatherGuardianContact ?? this.fatherGuardianContact,
      email: email ?? this.email,
      address: address ?? this.address,
      cnic: cnic ?? this.cnic,
      photoPath: photoPath ?? this.photoPath,
      behaviorColor: behaviorColor ?? this.behaviorColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StudentDocument {
  final String id;
  final String studentId;
  final String filePath;
  final String fileName;
  final String fileType;
  final DateTime uploadedAt;

  StudentDocument({
    required this.id,
    required this.studentId,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'filePath': filePath,
      'fileName': fileName,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory StudentDocument.fromMap(Map<String, dynamic> map) {
    return StudentDocument(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      filePath: map['filePath'] as String,
      fileName: map['fileName'] as String,
      fileType: map['fileType'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    );
  }
}

class BackupMetadata {
  final String id;
  final DateTime createdAt;
  final String backupPath;
  final int studentCount;
  final String appVersion;

  BackupMetadata({
    required this.id,
    required this.createdAt,
    required this.backupPath,
    required this.studentCount,
    required this.appVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'backupPath': backupPath,
      'studentCount': studentCount,
      'appVersion': appVersion,
    };
  }

  factory BackupMetadata.fromMap(Map<String, dynamic> map) {
    return BackupMetadata(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      backupPath: map['backupPath'] as String,
      studentCount: map['studentCount'] as int,
      appVersion: map['appVersion'] as String,
    );
  }
}
