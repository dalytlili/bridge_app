import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../controllers/course_controller.dart';
import '../../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/custom_text_field.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null && mounted) {
        final File imageFile = File(pickedImage.path);

        if (await imageFile.exists()) {
          setState(() {
            _selectedImage = imageFile;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showCourseDialog({CourseModel? course}) {
    final titleController = TextEditingController(text: course?.title ?? '');
    final priceController = TextEditingController(text: course?.price ?? '');
    File? tempImage = _selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  course == null ? 'Add New Course' : 'Edit Course',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: titleController,
                  labelText: 'Course Title',
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: priceController,
                  labelText: 'Price',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                    if (mounted) {
                      setState(() {
                        tempImage = _selectedImage;
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: tempImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              tempImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Add Course Image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_validateInputs(titleController, priceController)) {
                      final newCourse = CourseModel(
                        id: course?.id ?? DateTime.now().toString(),
                        title: titleController.text.trim(),
                        price: priceController.text.trim(),
                        imageUrl: tempImage?.path ?? course?.imageUrl ?? '',
                      );

                      if (course == null) {
                        context.read<CourseController>().addCourse(newCourse);
                      } else {
                        context
                            .read<CourseController>()
                            .updateCourse(newCourse);
                      }

                      _selectedImage = null;
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFFB4004E),
                  ),
                  child: Text(
                    course == null ? 'Add Course' : 'Update Course',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs(TextEditingController titleController,
      TextEditingController priceController) {
    if (titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a course title');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a price');
      return false;
    }
    return true;
  }

  void _confirmDeleteCourse(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CourseController>().deleteCourse(course.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Bridge Management'),
        backgroundColor: const Color(0xFFB4004E),
        elevation: 0,
      ),
      body: Consumer<CourseController>(
        builder: (context, courseController, child) {
          final courses = courseController.courses;

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_books,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCourseDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4004E),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Stack(
                children: [
                  CourseCard(course: course),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCourseDialog(course: course),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDeleteCourse(context, course),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseDialog(),
        backgroundColor: const Color(0xFFB4004E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Course',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
