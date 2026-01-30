import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../services/file_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'department_screen.dart';
import 'student_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  late BackupService _backupService;

  int totalStudents = 0;
  List<Student> recentStudents = [];
  Map<String, int> behaviorStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _backupService = BackupService(_db, _fileService);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);
    try {
      final total = await _db.getTotalStudentCount();
      final recent = await _db.getRecentlyEdited(limit: 5);
      
      setState(() {
        totalStudents = total;
        recentStudents = recent;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        DialogUtil.showErrorDialog(context, 'Failed to load dashboard data: $e');
      }
    }
  }

  Future<void> _createBackup() async {
    try {
      await _backupService.createBackup();
      if (mounted) {
        DialogUtil.showSuccessDialog(context, 'Backup created successfully');
        _loadDashboardData();
      }
    } catch (e) {
      if (mounted) {
        DialogUtil.showErrorDialog(context, 'Backup failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.dashboard),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.backup),
              onPressed: _createBackup,
              tooltip: 'Create Backup',
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showAboutDialog(context),
              tooltip: 'About',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSummary(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildQuickActions(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRecentStudents(),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DepartmentScreen()),
            );
          },
          icon: const Icon(Icons.navigate_next),
          label: const Text('Manage Students'),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            StatCard(
              label: 'Total Students',
              value: totalStudents.toString(),
              icon: Icons.people,
              backgroundColor: AppColors.primaryLightBlue,
            ),
            StatCard(
              label: 'Good Status',
              value: _getColorCount(BehaviorColor.green).toString(),
              icon: Icons.check_circle,
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
            StatCard(
              label: 'Needs Improvement',
              value: _getColorCount(BehaviorColor.yellow).toString(),
              icon: Icons.warning,
              backgroundColor: Colors.yellow.withOpacity(0.1),
            ),
            StatCard(
              label: 'Weak / Attention',
              value: _getColorCount(BehaviorColor.red).toString(),
              icon: Icons.error,
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildActionButton(
              label: 'Add Student',
              icon: Icons.person_add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentManagementScreen()),
                );
              },
            ),
            _buildActionButton(
              label: 'View All',
              icon: Icons.list,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DepartmentScreen()),
                );
              },
            ),
            _buildActionButton(
              label: 'Backup Data',
              icon: Icons.save_alt,
              onPressed: _createBackup,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  Widget _buildRecentStudents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Edited',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        if (recentStudents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                AppStrings.noData,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentStudents.length,
            itemBuilder: (context, index) {
              final student = recentStudents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  leading: BehaviorColorBadge(
                    color: student.behaviorColor,
                    size: 24,
                  ),
                  title: Text(student.studentName),
                  subtitle: Text('Roll: ${student.rollNumber}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentManagementScreen(student: student),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  int _getColorCount(BehaviorColor color) {
    // This would need to fetch stats from database
    // Simplified for now
    return 0;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About EV'),
        content: const Text(
          'EV - Student Record Management\n\n'
          'A production-grade offline application for managing student records.\n\n'
          'Version: 1.0.0\n'
          'Electrical Engineering Department',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
