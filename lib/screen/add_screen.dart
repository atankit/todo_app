import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:todo/helper/DatabaseHelper.dart';
import 'package:todo/model/todo.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _pickMedia(ImageSource source, bool isImage) async {
    final picker = ImagePicker();
    final pickedFile = isImage
        ? await picker.pickImage(source: source)
        : await picker.pickVideo(source: source); // Use pickVideo for videos

    if (pickedFile != null) {
      setState(() {
        if (isImage) {
          _selectedImage = File(pickedFile.path);
        } else {
          _selectedVideo = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Todo(
        title: _titleController.text,
        description: _descriptionController.text,
        createdDate: DateTime.now().toString(),
        photoPath: _selectedImage?.path,
        videoPath: _selectedVideo?.path,
      );

      await _dbHelper.insert(task.toMap());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
        backgroundColor: Colors.teal, // App bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Add Photo'),
                        IconButton(
                          icon: Icon(Icons.photo, color: Colors.blue),
                          onPressed: () => _pickMedia(ImageSource.gallery, true),
                        ),
                        if (_selectedImage != null)
                          Text(
                            'Selected',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Add Video'),
                        IconButton(
                          icon: Icon(Icons.videocam, color: Colors.red),
                          onPressed: () => _pickMedia(ImageSource.gallery, false),
                        ),
                        if (_selectedVideo != null)
                          Text(
                            'Selected',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Save ToDo',),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
