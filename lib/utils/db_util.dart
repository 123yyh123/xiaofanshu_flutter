import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/recommend_tab.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';

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
      },
    );
  }
}
