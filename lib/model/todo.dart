class Todo {
  final int? id;
  final String title;
  final String? description;
  final String createdDate;
  final String? editedDate;
  final String? completionDate;
  final String? photoPath;
  final String? videoPath;
  final String? color;
  final bool isCompleted;
  final bool isHidden;

  Todo({
    this.id,
    required this.title,
    this.description,
    required this.createdDate,
    this.editedDate,
    this.completionDate,
    this.photoPath,
    this.videoPath,
    this.color,
    this.isCompleted = false,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'createdDate': createdDate,
      'editedDate': editedDate,
      'completionDate': completionDate,
      'photoPath': photoPath,
      'videoPath': videoPath,
      'color': color,
      'isCompleted': isCompleted ? 1 : 0,
      'isHidden': isHidden ? 1 : 0,
    };
  }
}
