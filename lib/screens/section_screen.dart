import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'class_screen.dart';

class SectionScreen extends StatefulWidget {
  final String departmentId;

  const SectionScreen({
    Key? key,
    required this.departmentId,
  }) : super(key: key);

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<Section>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _db.getSectionsByDepartment(widget.departmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sections),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Section>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sections = snapshot.data ?? [];

          if (sections.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.groups, color: AppColors.primaryBlue),
                  title: Text(
                    section.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassScreen(
                          departmentId: widget.departmentId,
                          sectionId: section.id,
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
