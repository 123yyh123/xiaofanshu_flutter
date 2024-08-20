import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';

class DBManager {
  static DBManager? _instance;
  static Database? _database;

  static DBManager get instance => _instance ??= DBManager();

  Future<Database> get database async => _database ??= await init();

  final String _dbName = 'xiaofanshu.db';
  final int _dbVersion = 1;

  Future<Database> init() async {
    // 初始化数据库
    Get.log('初始化数据库');
    var path = await getDatabasesPath() + _dbName;
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        // 创建表，RecommendTab表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recommend_tab (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            sort INTEGER DEFAULT 0,
            status INTEGER DEFAULT 1,
            createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),
            updateTime TIMESTAMP DEFAULT (datetime('now', 'localtime'))
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS draft_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT DEFAULT NULL,
            content TEXT DEFAULT NULL,
            type INTEGER DEFAULT 0,
            filesPath TEXT NOT NULL,
            coverPath TEXT DEFAULT NULL,
            authority INTEGER DEFAULT 0,
            address TEXT DEFAULT NULL,
            createTime TIMESTAMP DEFAULT (datetime('now', 'localtime'))
          );
        ''');
        Get.log('数据库初始化完成');
      },
    );
  }
}
