import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:todo/helper/DatabaseHelper.dart';
import 'package:todo/model/todo.dart';

class EditTaskScreen extends StatefulWidget {
  final Todo todo;

  const EditTaskScreen({Key? key, required this.todo}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _selectedImage;
  File? _selectedVideo;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description ?? '');
    _isCompleted = widget.todo.isCompleted;
    if (widget.todo.photoPath != null) {
      _selectedImage = File(widget.todo.photoPath!);
    }
    if (widget.todo.videoPath != null) {
      _selectedVideo = File(widget.todo.videoPath!);
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final updatedTodo = Todo(
        id: widget.todo.id,
        title: _titleController.text,
        description: _descriptionController.text,
        createdDate: widget.todo.createdDate,
        editedDate: DateTime.now().toIso8601String(),
        completionDate: _isCompleted ? DateTime.now().toIso8601String() : null,
        photoPath: _selectedImage?.path,
        videoPath: _selectedVideo?.path,
        isCompleted: _isCompleted,
        color: widget.todo.color,
      );

      await DatabaseHelper.instance.update(updatedTodo.toMap());

      Navigator.pop(context, updatedTodo);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
        backgroundColor: Colors.teal, // App bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                  if (value == null || value.trim().isEmpty) {
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
                  Text(
                    'Completed:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              TextButton.icon(
                icon: Icon(Icons.image, color: Colors.blue),
                label: Text('Pick Image'),
                onPressed: _pickImage,
              ),
              if (_selectedVideo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Video Selected: ${_selectedVideo!.path.split('/').last}',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              TextButton.icon(
                icon: Icon(Icons.video_library, color: Colors.red),
                label: Text('Pick Video'),
                onPressed: _pickVideo,
              ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Update Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
