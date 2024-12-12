# To-Do List Application

## Overview-
The To-Do List Application is a feature-rich Flutter app that helps users manage their tasks efficiently. It provides intuitive UI and robust functionality, allowing users to create, edit, delete, and organize tasks with ease. The app uses SQLite for persistent storage and includes advanced features such as search, multi-select, sharing, and multimedia support.

### Features-
  + Add, Edit, and Delete Tasks: Users can create tasks, modify their details, and remove them as needed.
  + Persistent Storage: Tasks are stored in a SQLite database for reliable and consistent access.
  + ListView Display: Tasks are shown in a ListView with essential details such as:
     - Title
     - Description
     - Created Date
     - Edited Date
     - Completion Date 

### Advanced Features-
  + Multi-Select and Delete: Users can select multiple tasks at once for deletion.
    -  <img src="https://github.com/user-attachments/assets/b855aba8-9e92-4f0b-8977-b7a7f0c68994" width="200" />
     
  + Mark as Done: Tasks can be marked as completed, with visual indicators to distinguish completed tasks.
     -  <img src="https://github.com/user-attachments/assets/94a592f2-9c46-4c41-bea2-88a1e5be34e9" width="200" />
  + Search and Highlight:
     - Search for tasks by title and description.
     - Highlight matching words in search results.
     -   <img src="https://github.com/user-attachments/assets/64673d88-26c0-4a05-ae0c-3b365f83d1e2" width="200" />
  + Add Photos and Videos: Attach images and videos to tasks for richer context.
  + Share Tasks: Share task details with other applications.
  + Text Selection and Editing: Enable text selection, copying, and cutting in task descriptions.
    
### Sorting Options-
  + Sort Tasks:
     - By title (alphabetical order).
     - Sort by completion (latest/earliest first).

### Customization-

  + Background Images: Add images to the task details background, with graceful handling if an image is missing.
  + Color Selection: Choose task colors, supported in the database upgrade.

### Technical Details-
  + Platform: Flutter (Dart).
  + Multimedia Handling: Supports photo and video attachments.
  + Error Handling: Graceful handling of missing images and database issues.

### Screenshot-
