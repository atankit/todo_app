import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo/helper/DatabaseHelper.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/screen/add_screen.dart';
import 'package:todo/screen/edit_screen.dart';
import 'package:todo/screen/video_player_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Todo> _tasks = [];
  List<Todo> _filteredTasks = [];
  List<int> _selectedTaskIds = [];
  String _searchQuery = '';
  bool _isMultiSelectEnabled = false;
  String _sortBy = 'createdDate';
  bool _showHiddenTasks = false;
  bool _isAscending = true; // Controls the sort direction


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ~~~~~~~~~~~~~~~ Load tasks from the database ~~~~~~~~~~~~~~~
  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.queryAll();
    setState(() {
      _tasks = tasks
          .map((e) => Todo(
                id: e[DatabaseHelper.columnId],
                title: e[DatabaseHelper.columnTitle],
                description: e[DatabaseHelper.columnDescription],
                createdDate: e[DatabaseHelper.columnCreatedDate],
                editedDate: e[DatabaseHelper.columnEditedDate],
                completionDate: e[DatabaseHelper.columnCompletionDate],
                photoPath: e[DatabaseHelper.columnPhotoPath],
                videoPath: e[DatabaseHelper.columnVideoPath],
                color: e[DatabaseHelper.columnColor],
                isCompleted: e[DatabaseHelper.columnIsCompleted] == 1,
                isHidden: e[DatabaseHelper.columnIsHidden] == 1,
              ))
          .toList();
      _filterTasks();
    });
  }
//     ~~~~~~~~~~~~~~~hidden to-do and searching to-do working~~~~~~~~~~~~~~~~~
  void _filterTasks() {
    setState(() {
      _filteredTasks = _tasks
          .where((task) =>
              (!_showHiddenTasks && !task.isHidden) ||
              (_showHiddenTasks && task.isHidden))
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (task.description != null &&
                  task.description!
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())))
          .toList();
      _sortTasks();
    });
  }
  //     ~~~~~~~~~~~~~~~Sort by title & time working~~~~~~~~~~~~~~~~~
  void _sortTasks() {
    _filteredTasks.sort((a, b) {
      if (_sortBy == 'createdDate') {
        // Sort by created date
        return _isAscending
            ? a.createdDate.compareTo(b.createdDate) // Oldest first
            : b.createdDate.compareTo(a.createdDate); // Latest first
      } else if (_sortBy == 'title') {
        // Sort by title (A-Z)
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      } else if (_sortBy == 'completionDate') {
        // Sort by completion date if available
        return _isAscending
            ? (a.completionDate ?? '').compareTo(b.completionDate ?? '')
            : (b.completionDate ?? '').compareTo(a.completionDate ?? '');
      }
      return 0; // Default case (no sorting)
    });
  }

//  ~~~~~~~~~~~~~~~Multi Selection  working~~~~~~~~~~~~~~~~~
  void _toggleMultiSelect(bool isEnabled) {
    setState(() {
      _isMultiSelectEnabled = isEnabled;
      if (!isEnabled) {
        _selectedTaskIds.clear();
      }
    });
  }
//     ~~~~~~~~~~~~~~~ Updation working~~~~~~~~~~~~~~~~~
  void _updateMultiSelectState() {
    setState(() {
      if (_selectedTaskIds.isEmpty) {
        _toggleMultiSelect(false);
      }
    });
  }

  //     ~~~~~~~~~~~~~~~Deletion working~~~~~~~~~~~~~~~~~
  Future<void> _deleteSelectedTasks() async {
    for (int id in _selectedTaskIds) {
      await _dbHelper.delete(id);
    }
    _toggleMultiSelect(false);
    _loadTasks();
  }

  //      ~~~~~~~~~~~~Share icon working~~~~~~~~~~~~~~~
  void _shareTaskWithFile(Todo task) {
    if (task.photoPath != null) {
      Share.shareXFiles([XFile(task.photoPath!)],
          text:
              'Task: ${task.title}\nDescription: ${task.description ?? "No Description"}');
    } else {
      Share.share(
          'Task: ${task.title}\nDescription: ${task.description ?? "No Description"}');
    }
  }

//        ~~~~~~~~~~DATE TIME FORMAT~~~~~~~~~~~~~
  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return "Invalid Date";
    }
  }

  // ~~~~~~~~~~~~~~~~  List view - title, subtitle, leading, trailing Working ~~~~~~~~~~~~~~
  Widget _buildTaskItem(Todo task) {
    bool isSelected = _selectedTaskIds.contains(task.id);

    //  -------------------- multi selection calling ---------------------
    return GestureDetector(
      onLongPress: () {
        if (!_isMultiSelectEnabled) {
          _toggleMultiSelect(true);
          setState(() {
            _selectedTaskIds.add(task.id!);
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        elevation: 6,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
          // __________  title / title ________________________
                      title: RichText(
                        text: TextSpan(
                          text: task.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),

                 // ----------------- highlighting only the search matches.-----------------------------
                          children: _searchQuery.isNotEmpty
                              ? _highlightSearchText(task.title, _searchQuery)
                              : [],
                        ),
                      ),
            // ________________Subtitle/ Description ________________________
                      subtitle: SelectableText(
                        task.description ?? "No description provided",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
            // _________________ Trailing / Created/Updated/Completion  date
                      trailing: Text(
                        task.isCompleted && task.completionDate != null
                            ? 'Completed: ${_formatDateTime(task.completionDate!)}'
                            : (task.editedDate != null && task.editedDate!.isNotEmpty)
                            ? 'Updated: ${_formatDateTime(task.editedDate!)}'
                            : 'Created: ${_formatDateTime(task.createdDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isCompleted ? Colors.green : Colors.black,
                        ),
                      ),
                    ),

           // __________ image / video / If no photo or video, display a default placeholder img-----------
                    SizedBox(height: 10),
           //  ------------------  Calling VideoPlayerWidget class --------------------
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: task.videoPath != null
                          ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayerWidget(videoPath: task.videoPath!),
                      )
                          : task.photoPath != null
                          ? Image.file(
                        File(task.photoPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/images/default_image.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
              // _______________ Edit icon -----------------------
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.pencil, color: Colors.blueAccent),
                              tooltip: "Edit Task",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(todo: task),
                                  ),
                                ).then((_) => _loadTasks());
                              },
                            ),
              //  _____________________Delete icon______________________________________
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.trashCan, color: Colors.redAccent),
                              tooltip: "Delete Task",
                              onPressed: () async {
                                await _dbHelper.delete(task.id!);
                                _loadTasks();
                              },
                            ),
              //  _____________________Share icon_____________________________________-
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.shareFromSquare, color: Colors.purple),
                              tooltip: "Share Task",
                              onPressed: () {
                                _shareTaskWithFile(task);
                              },
                            ),
              //   _____________________Hide icon____________________________________
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.eyeSlash, color: Colors.grey),
                              tooltip: "Hide Task",
                              onPressed: () async {
                                await _dbHelper.toggleTaskVisibility(task.id!, true);
                                _loadTasks();
                              },
                            ),
                          ],
                        ),
            //  _______________________ Check Icons appear after long-press.___________________________________________
                        if (_isMultiSelectEnabled)
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedTaskIds.add(task.id!);
                                } else {
                                  _selectedTaskIds.remove(task.id!);
                                }
                                _updateMultiSelectState();
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

       // ___________________ if task completed indigate Green check icon ___________________________________
            if (task.isCompleted)
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Icon(Icons.check_circle, color: Colors.green, size: 24),
              ),
          ],
        ),
      ),
    );
  }

//      ------------------------Searching method -------------------------------------

  List<TextSpan> _highlightSearchText(String text, String query) {
    if (query.isEmpty) {
      // If no query, return the whole text as is.
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ];
    }

    final spans = <TextSpan>[];
    final regex = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = regex.allMatches(text);

    int lastMatchEnd = 0;

    for (var match in matches) {
      // Add non-matching text before the match.
      if (lastMatchEnd != match.start) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            color: Colors.grey.shade800,
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      // Add matching text.
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellow.shade200,
        ),
      ));
      lastMatchEnd = match.end;
    }

    // Add remaining non-matching text.
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          color: Colors.grey.shade800,
          fontStyle: FontStyle.italic,
        ),
      ));
    }

    return spans;
  }

// --------------- app bar --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isMultiSelectEnabled
            ? Text(
                '${_selectedTaskIds.length} Selected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : Text(
                'To-Do App',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

 // ---------------Delete and cross icons appear in AppBar when we used to multi seletion-------------------------
        actions: _isMultiSelectEnabled
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed:
                      _selectedTaskIds.isNotEmpty ? _deleteSelectedTasks : null,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => _toggleMultiSelect(false),
                ),
              ]
            : [
     // ---------------------Unhide to-do icon----------------------------
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            tooltip: 'Unhide All Tasks',
            onPressed: () async {
              await _dbHelper.toggleAllTasksVisibility(false);
              _loadTasks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

       // ___________________Search Bar___________________________________
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none, // Removes the default border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterTasks();
                        });
                      },
                    ),
                  ),
                ),

          // ________________________Sort pop up menu_______________________________________
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      if (value == 'Sort By Title') {
                        _sortBy = 'title';
                        _isAscending = true; // Always A-Z for title
                      } else if (value == 'Sort By Created Date Asc') {
                        _sortBy = 'createdDate';
                        _isAscending = true; // Oldest first
                      } else if (value == 'Sort By Created Date Desc') {
                        _sortBy = 'createdDate';
                        _isAscending = false; // Latest first
                      } else if (value == 'Sort By Completion Date Asc') {
                        _sortBy = 'completionDate';
                        _isAscending = true; // Earliest completion first
                      } else if (value == 'Sort By Completion Date Desc') {
                        _sortBy = 'completionDate';
                        _isAscending = false; // Latest completion first
                      }
                      _sortTasks();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Sort By Title',
                      child: ListTile(
                        leading: Icon(Icons.sort_by_alpha, color: Colors.blueAccent),
                        title: Text('Sort by Title (A-Z)'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Sort By Created Date Asc',
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.green),
                        title: Text('Sort by Date (Oldest First)'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Sort By Created Date Desc',
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.red),
                        title: Text('Sort by Date (Latest First)'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Sort By Completion Date Asc',
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.orange),
                        title: Text('Sort by Completion (Earliest First)'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Sort By Completion Date Desc',
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.purple),
                        title: Text('Sort by Completion (Latest First)'),
                      ),
                    ),
                  ],
                  icon: Icon(Icons.sort, color: Colors.blueAccent),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  tooltip: 'Sort Tasks',
                )

              ],
            ),
          ),
     //  ------------------------ Calling listview------------------------------
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(_filteredTasks[index]);
              },
            ),
          ),
        ],
      ),
   // --------------------------Add button---------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          ).then((_) => _loadTasks());
        },
        child: FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}
