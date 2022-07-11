
import 'package:path/path.dart';
import 'package:my_todo_app/model/task_model.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider{
  DBProvider();
  static final DBProvider dataBase = DBProvider();
  static late Database _database;

  Future<Database> get database async{
    _database = await initDatabase();
    return _database;
  }

  // database initializer
  initDatabase() async{
    return await openDatabase(
      join(await getDatabasesPath(), "todo_app.db"),
      onCreate: (db, version) async {
        // SQL create table request
        await db.execute('''
        CREATE TABLE tasks (task TEXT, createDate Text)
        ''');
      },
      version: 1
    );
  }

  // insert new task to table
  addNewTask(Task newTask) async {
    final db = await database;
    db.insert(
      "tasks", 
      newTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
  
  Future<dynamic> getTasks() async{
    final db = await database;
    var res = await db.query("tasks");
    if (res.isEmpty){
      return Null;
    } else {
      var resultMap = res.toList();
      return resultMap.isNotEmpty ? resultMap : Null;
    }
  }

  Future<void> removeAllTask() async{
    final db = await database;
    db.execute("delete from tasks");
  }

  Future<void> deleteTask(String task, String createDate) async{
    final db = await database;
    db.execute("delete from tasks where task = \"$task\" and createDate = \"$createDate\"");
  }
}