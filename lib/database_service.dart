import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quicknote/model/note_db.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'notes.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<void> deleteDatabase() async {
    const name = 'notes.db';
    final path = await getDatabasesPath();
    databaseFactory.deleteDatabase(join(path, name));
  }

  Future<Database> initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> create(Database database, int version) async =>
      await NoteDB.createTable(database);
}
