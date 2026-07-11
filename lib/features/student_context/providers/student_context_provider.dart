import 'package:flutter/foundation.dart';

import '../models/student.dart';

/// Holds the parent's linked students and which one is currently active.
/// Every parent-scoped repository call should read [activeStudent] from
/// here rather than each screen tracking its own student id.
///
/// Today a parent is hardcoded to a single student (id '1') since the
/// backend has no real parent-student linkage yet - see
/// `SessionProvider.dummyParentStudentId`. [switchStudent] and the
/// multi-student list are already in place so wiring up the real API
/// later (fetching a parent's actual children) is a data change, not a
/// UI/state-shape change.
class StudentContextProvider extends ChangeNotifier {
  List<Student> _students = const [];
  Student? _activeStudent;

  List<Student> get students => List.unmodifiable(_students);
  Student? get activeStudent => _activeStudent;
  bool get hasMultipleStudents => _students.length > 1;

  void setStudents(List<Student> students) {
    _students = students;
    _activeStudent = students.isNotEmpty ? students.first : null;
    notifyListeners();
  }

  void switchStudent(String studentId) {
    for (final student in _students) {
      if (student.id == studentId) {
        _activeStudent = student;
        notifyListeners();
        return;
      }
    }
  }

  void clear() {
    _students = const [];
    _activeStudent = null;
    notifyListeners();
  }
}
