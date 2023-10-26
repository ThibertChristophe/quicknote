import 'package:quicknote/model/note.dart';
import 'package:quicknote/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:core';

class NoteDB {
  static const tableName = 'notes';

  static Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
"id" INTEGER NOT NULL,
"content" TEXT NOT NULL,
PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  // static Future<void> deleteDatabase() async {
  //   final database = await DatabaseService().deleteDatabase();
  // }

  static Future<int> create(
      {String title = "", required String content}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (content) VALUES (?)''',
      [content],
    );
  }

  static Future<List<Note>> fetchAll() async {
    final database = await DatabaseService().database;
    final notes = await database.rawQuery('''SELECT * FROM $tableName''');
    return notes.map((note) => Note.fromSqfliteDatabase(note)).toList();
  }

  static Future<Note> fetchById(int id) async {
    final database = await DatabaseService().database;
    final notes = await database
        .rawQuery('''SELECT * FROM $tableName WHERE id = ?''', [id]);
    return Note.fromSqfliteDatabase(notes.first);
  }

  static Future<int> update({required int id, String? content}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  static Future<int> delete({required int id}) async {
    final database = await DatabaseService().database;
    return await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteAll() async {
    final database = await DatabaseService().database;
    return await database.rawDelete("DELETE FROM $tableName");
  }

  static Future<int> count() async {
    final database = await DatabaseService().database;
    final notes =
        await database.rawQuery('''SELECT count(*) FROM $tableName ''');
    return notes.length;
  }
}
