import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'student_management_screen.dart';

class RollNumberScreen extends StatefulWidget {
  final String classId;
  final String academicYearId;
  final String className;
  final String yearName;

  const RollNumberScreen({
    Key? key,
    required this.classId,
    required this.academicYearId,
    required this.className,
    required this.yearName,
  }) : super(key: key);

  @override
  State<RollNumberScreen> createState() => _RollNumberScreenState();
}

class _RollNumberScreenState extends State<RollNumberScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<Student>> _studentsFuture;
  
  BehaviorColor? selectedFilterColor;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(() => setState(() {}));
  }

  void _loadStudents() {
    _studentsFuture = selectedFilterColor == null
        ? _db.getStudentsByClassAndYear(widget.classId, widget.academicYearId)
        : _db.getStudentsByBehaviorColor(selectedFilterColor!, widget.classId, widget.academicYearId);
  }

  void _onFilterColorSelected(BehaviorColor color) {
    setState(() {
      selectedFilterColor = selectedFilterColor == color ? null : color;
      _loadStudents();
    });
  }

  List<Student> _filterStudents(List<Student> students) {
    if (_searchController.text.isEmpty) {
      return students;
    }
    return students.where((student) {
      return student.rollNumber.contains(_searchController.text) ||
          student.studentName.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - ${widget.yearName}'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allStudents = snapshot.data ?? [];
          final filteredStudents = _filterStudents(allStudents);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by roll number or name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                ),
              ),

              // Behavior color filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Filter: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ...BehaviorColor.values.map((color) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: BehaviorFilterButton(
                            color: color,
                            isSelected: selectedFilterColor == color,
                            onTap: () => _onFilterColorSelected(color),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${filteredStudents.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    if (selectedFilterColor != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          selectedFilterColor = null;
                          _loadStudents();
                        }),
                        child: Text(
                          'Clear Filter',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Roll number grid
              Expanded(
                child: filteredStudents.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noData,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return RollNumberCard(
                            rollNumber: student.rollNumber,
                            behaviorColor: student.behaviorColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentManagementScreen(
                                    student: student,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentManagementScreen(
                classId: widget.classId,
                academicYearId: widget.academicYearId,
                className: widget.className,
              ),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
