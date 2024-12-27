import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseController extends ChangeNotifier {
  final List<CourseModel> _courses = [];
  List<CourseModel> get courses => List.unmodifiable(_courses);

  void addCourse(CourseModel course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(CourseModel course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      notifyListeners();
    }
  }

  void deleteCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }
}
