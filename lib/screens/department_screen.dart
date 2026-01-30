import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'section_screen.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<Department>> _departmentsFuture;

  @override
  void initState() {
    super.initState();
    _departmentsFuture = _db.getDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.departments),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Department>>(
        future: _departmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.apartment, color: AppColors.primaryBlue),
                  title: Text(
                    dept.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(dept.id),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SectionScreen(departmentId: dept.id),
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
