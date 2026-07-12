import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_type.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/data/student_repository.dart';
import '../../student_context/models/student_summary.dart';
import '../../student_context/presentation/widgets/student_context_header.dart';
import '../../student_context/presentation/widgets/student_picker.dart';
import '../../student_context/providers/student_context_provider.dart';
import '../data/gallery_repository.dart';
import 'widgets/gallery_grid.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Student'), Tab(text: 'Shared')],
          ),
        ),
        body: TabBarView(
          children: [
            _StudentGalleryTab(),
            _SharedGalleryTab(),
          ],
        ),
      ),
    );
  }
}

/// Parents see their current student's gallery directly. Staff pick a
/// student first (there's no "current student" for staff), then see the
/// same grid.
class _StudentGalleryTab extends StatefulWidget {
  @override
  State<_StudentGalleryTab> createState() => _StudentGalleryTabState();
}

class _StudentGalleryTabState extends State<_StudentGalleryTab> {
  StudentSummary? _staffSelectedStudent;

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<SessionProvider>().currentUser?.userType;
    final galleryRepository = context.read<GalleryRepository>();

    if (userType == UserType.parent) {
      final activeStudent = context.watch<StudentContextProvider>().activeStudent;
      if (activeStudent == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return GalleryGrid(
        key: ValueKey('student-${activeStudent.id}'),
        emptyMessage: "No photos or videos of ${activeStudent.name} yet",
        fetchPage: (skip, take) => galleryRepository.fetchStudentGallery(
          studentId: activeStudent.id,
          skip: skip,
          take: take,
        ),
      );
    }

    if (_staffSelectedStudent == null) {
      return StudentPicker(
        repository: context.read<StudentRepository>(),
        onSelected: (student) => setState(() => _staffSelectedStudent = student),
      );
    }

    final student = _staffSelectedStudent!;
    return Column(
      children: [
        StudentContextHeader(
          name: student.name,
          onChange: () => setState(() => _staffSelectedStudent = null),
        ),
        Expanded(
          child: GalleryGrid(
            key: ValueKey('student-${student.id}'),
            emptyMessage: "No photos or videos of ${student.name} yet",
            fetchPage: (skip, take) => galleryRepository.fetchStudentGallery(
              studentId: student.id,
              skip: skip,
              take: take,
            ),
          ),
        ),
      ],
    );
  }
}

class _SharedGalleryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final galleryRepository = context.read<GalleryRepository>();
    return GalleryGrid(
      emptyMessage: 'No shared photos or videos yet',
      fetchPage: (skip, take) => galleryRepository.fetchSharedGallery(skip: skip, take: take),
    );
  }
}
