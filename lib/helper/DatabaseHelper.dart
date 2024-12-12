// Database Helper
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = "todo_database.db";
  static final _dbVersion = 2;
  static final _tableName = "todo";

  static final columnId = "_id";
  static final columnTitle = "title";
  static final columnDescription = "description";
  static final columnCreatedDate = "createdDate";
  static final columnEditedDate = "editedDate";
  static final columnCompletionDate = "completionDate";
  static final columnPhotoPath = "photoPath";
  static final columnVideoPath = "videoPath";
  static final columnColor = "color";
  static final columnIsHidden = "isHidden";
  static final columnIsCompleted = "isCompleted";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCreatedDate TEXT NOT NULL,
        $columnEditedDate TEXT,
        $columnCompletionDate TEXT,
        $columnPhotoPath TEXT,
        $columnVideoPath TEXT,
        $columnColor TEXT,
        $columnIsHidden INTEGER DEFAULT 0,
        $columnIsCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN $columnColor TEXT');
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_tableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(
      _tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      _tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  // ~~~~~~~~~~~~~~~~~~~~~ Hide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<int> toggleTaskVisibility(int id, bool isHidden) async {
    final db = await database;
    return await db.update(
      _tableName,
      {columnIsHidden: isHidden ? 1 : 0},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

 // ~~~~~~~~~~~~~~~~~~~~~~~~~ Unhide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> toggleAllTasksVisibility(bool isHidden) async {
    final db = await database;
    await db.update(
      _tableName,
      {columnIsHidden: isHidden ? 1 : 0},
      where: '$columnIsHidden = ?',
      whereArgs: [1],
    );
  }

}
