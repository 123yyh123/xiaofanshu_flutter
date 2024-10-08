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
    try {
      _database?.close();
    } catch (e) {
      Get.log('数据库关闭');
    }
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
        await db.execute('''
          create table if not exists collect_emoji (
            id integer primary key autoincrement,
            time integer,
            fileUrl text,
            networkUrl text);
        ''');
        // 系统消息的表，主要为了显示未读数，1为赞和收藏，2为新增关注，3为评论和@，unread_num为未读数
        await db.execute('''
          CREATE TABLE IF NOT EXISTS system_message (
            id INTEGER PRIMARY KEY,
            type INTEGER,
            unread_num INTEGER
          );
        ''');
        await db.execute('''
          INSERT OR IGNORE INTO system_message (id, type, unread_num) VALUES
          (1, 1, 0),
          (2, 2, 0),
          (3, 3, 0);
        ''');
        // 创建关注消息表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS attention_message (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            avatar_url TEXT,
            user_name TEXT,
            content TEXT
          );
        ''');
        // 创建点赞和收藏消息表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS praise_and_collection (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            avatar_url TEXT,
            user_name TEXT,
            content TEXT,
            notes_id TEXT,
            notes_type TEXT,
            notes_cover_picture TEXT,
            time INTEGER
          );
        ''');
        // 初始化搜索记录表
        await db.execute('''
        CREATE TABLE IF NOT EXISTS search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT UNIQUE,
          updateTime INTEGER
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

  // 创建收藏表情表
  Future<void> createCollectEmojiTable() async {
    await createTable('''
      create table if not exists collect_emoji (
        id integer primary key autoincrement,
        time integer,
        fileUrl text,
        networkUrl text);
    ''');
  }

  // 创建系统消息表
  Future<void> createSystemMessageTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS system_message (
        id INTEGER PRIMARY KEY,
        type INTEGER,
        unread_num INTEGER
      );
    ''');
    await createTable('''
      INSERT OR IGNORE INTO system_message (id, type, unread_num) VALUES
      (1, 1, 0),
      (2, 2, 0),
      (3, 3, 0);
    ''');
  }

  // 创建关注消息表
  Future<void> createAttentionMessageTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS attention_message (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        avatar_url TEXT,
        user_name TEXT,
        content TEXT
      );
    ''');
  }

  // 创建点赞和收藏消息表
  Future<void> createPraiseAndCollectionTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS praise_and_collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        avatar_url TEXT,
        user_name TEXT,
        content TEXT,
        notes_id TEXT,
        notes_type TEXT,
        notes_cover_picture TEXT,
        time INTEGER
      );
    ''');
  }

  // 创建搜索记录表
  Future<void> createSearchHistoryTable() async {
    await createTable('''
      CREATE TABLE IF NOT EXISTS search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT UNIQUE,
        updateTime INTEGER
      );
    ''');
  }
}
