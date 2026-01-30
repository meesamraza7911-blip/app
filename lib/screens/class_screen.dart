import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'academic_year_screen.dart';

class ClassScreen extends StatefulWidget {
  final String departmentId;
  final String sectionId;

  const ClassScreen({
    Key? key,
    required this.departmentId,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<StudentClass>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = _db.getClassesBySection(widget.sectionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.classes),
        centerTitle: true,
      ),
      body: FutureBuilder<List<StudentClass>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data ?? [];

          if (classes.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final studentClass = classes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.school, color: AppColors.primaryBlue),
                  title: Text(
                    studentClass.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AcademicYearScreen(
                          departmentId: widget.departmentId,
                          classId: studentClass.id,
                          className: studentClass.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
