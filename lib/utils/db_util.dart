import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

import '../static/default_data.dart';

class DBManager {
  static DBManager? _instance;
  static Database? _database;

  static DBManager get instance => _instance ??= DBManager();

  Future<Database> get database async => _database ??= await init();

  // 销毁
  static void dispose() {
    _database?.close();
    _database = null;
    _instance = null;
  }

  final String _dbName = 'xiaofanshu';
  final int _dbVersion = 1;

  Future<Database> init() async {
    // 初始化数据库
    Get.log('初始化数据库');
    int userId = int.parse(jsonDecode(
            await readData('userInfo') ?? jsonEncode(DefaultData.user))['id']
        .toString());
    var path = '${await getDatabasesPath()}${_dbName}_$userId.db';
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
        // 创建表，DraftNotes表
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
        // 创建表，MessageList表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS message_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT UNIQUE,
            avatar_url TEXT,
            user_name TEXT,
            last_message TEXT,
            last_time INTEGER,
            unread_num INTEGER,
            stranger BOOLEAN
          );
        ''');
        Get.log('数据库初始化完成');
      },
    );
  }

  // 创建表
  Future<void> createTable(String sql) async {
    Database db = await database;
    await db.execute(sql);
  }

  // 创建recommend_tab表
  Future<void> createRecommendTabTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS recommend_tab (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        sort INTEGER DEFAULT 0,
        status INTEGER DEFAULT 1,
        createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),
        updateTime TIMESTAMP DEFAULT (datetime('now', 'localtime'))
      );
    ''');
  }

  // 创建draft_notes表
  Future<void> createDraftNotesTable() async {
    await createTable('''
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
  }

  // 创建message_list表
  Future<void> createMessageListTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS message_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE,
        avatar_url TEXT,
        user_name TEXT,
        last_message TEXT,
        last_time INTEGER,
        unread_num INTEGER,
        stranger BOOLEAN
      );
    ''');
  }

  // 创建聊天记录表
  Future<void> createChatRecordTable(String userId) async {
    await createTable('''
      	create table if not exists chat_$userId (
				id integer primary key autoincrement,
				from_id text,
				to_id text,
				content text,
				time integer,
				chat_type integer,
				is_read integer,
				is_send integer,
				audio_time integer);
    ''');
  }
}
