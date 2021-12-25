import 'package:todolatest/models/todo_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

const String tableTodo = 'todo';
const String columnId = 'id';
const String columnTitle = 'title';
const String columndateTime = 'dateTime';

class TodoHelper{

  static Database? _database;
  static TodoHelper? _todoHelper;

  TodoHelper._createInstance();

  TodoHelper() {
    _todoHelper ??= TodoHelper._createInstance();
  }
  //call initializeDatabase method if no db found
  Future<Database?> get database async {
    if (_database != null)return _database;
    _database = await initializeDatabase();
    return _database;

  }
  //initializing the database
  Future<Database> initializeDatabase() async {
    //create path and the db name
    var dir = await getDatabasesPath();
    var path = dir + "myDatabase.db";
    var exists = await databaseExists(path);
    //table create sql query
    var tableCreate = "create table todo ( $columnId integer primary key autoincrement,$columnTitle text not null,$columndateTime text not null)";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(tableCreate);
      },
    );

    return database;
  }

  //insert new record to the database
  void insertTodo(TodoInfo todoInfo) async {
    var db = await this.database;
    var result = await db!.insert(tableTodo, todoInfo.toMap());

  }
  //return all the existing records in the database
  Future<List<TodoInfo>> getTodos() async {
    List<TodoInfo> _todos = [];

    var db = await this.database;
    var result = await db!.query(tableTodo);
    for (var element in result) {

      var todoInfo = TodoInfo.fromMap(element);
      _todos.add(todoInfo);
    }

    return _todos;
  }
  //Delete record from the table,  required record primary key
  Future<int> delete(id) async {
    var db = await database;
    return await db!.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }
  //Update selected record,  required record primary key, title and updated date and time
  Future<int> update(TodoInfo todo) async {
    var db = await database;

    return await db!.update(tableTodo, todo.toMap(), where: '$columnId = ?', whereArgs: [todo.id]);
  }

  //return record search by title
  Future<List<TodoInfo>> getTodo(String title) async {
    List<TodoInfo> _todos = [];
    var db = await database;

    var maps = await db!.query(tableTodo,
        columns: [columnId, columnTitle, columndateTime],
        where: '$columnTitle LIKE ?',
        whereArgs: ['%$title%']);

    for (var element in maps) {

      var todoInfo = TodoInfo.fromMap(element);
      _todos.add(todoInfo);
    }

    return _todos;

  }

}