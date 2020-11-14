import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static final _databaseName = 'EDMT_DEV_DB.db';
  static final _databaseVersion = 1;
  static final table = 'Contact';
  static final columnEmail = 'EMAIL';
  static final columnName = 'NAME';

  //Constructor
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);

    //Check existing
    var exists = await databaseExists(path);
    if (!exists) {
      //if not exists
      print("Copy database start");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      //Copy
      ByteData data = await rootBundle.load(join("assets", _databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      //Write
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    //important
    return await openDatabase(path, version: _databaseVersion);
  }

  //CRUD
  //*************************/

  //Insert
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  //Select All
  Future<List> getAllContacts() async {
    Database db = await instance.database;
    var result = await db.query(table);
    return result.toList();
  }

  //Raw Query
  Future<int> getCount() async {
    var db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(EMAIL) FROM $table'));
  }

  //Update
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String id = row[columnEmail];
    return await db.update(table, row, where: '$columnEmail = ?', whereArgs: [id]);
  }

  //Delete
  Future<int> delete(String email) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnEmail = ?', whereArgs: [email]);
  }
}
