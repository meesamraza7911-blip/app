import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'roll_number_screen.dart';

class AcademicYearScreen extends StatefulWidget {
  final String departmentId;
  final String classId;
  final String className;

  const AcademicYearScreen({
    Key? key,
    required this.departmentId,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<AcademicYearScreen> createState() => _AcademicYearScreenState();
}

class _AcademicYearScreenState extends State<AcademicYearScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<AcademicYear>> _yearsFuture;

  @override
  void initState() {
    super.initState();
    _yearsFuture = _db.getAcademicYearsByDepartment(widget.departmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.academicYears),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AcademicYear>>(
        future: _yearsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final years = snapshot.data ?? [];

          if (years.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                  title: Text(
                    year.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RollNumberScreen(
                          classId: widget.classId,
                          academicYearId: year.id,
                          className: widget.className,
                          yearName: year.name,
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
