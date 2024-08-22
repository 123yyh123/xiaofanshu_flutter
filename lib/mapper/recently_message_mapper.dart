import 'package:sqflite/sqflite.dart';

import '../model/recently_message.dart';
import '../utils/db_util.dart';

class RecentlyMessageMapper {
  static Future<int> insert(RecentlyMessage recentlyMessage) async {
    // 插入数据
    Database database = await DBManager.instance.database;
    return await database.insert(
        RecentlyMessage.tableName, recentlyMessage.toJson());
  }

  static Future<List<RecentlyMessage>> queryAll() async {
    // 查询所有数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(RecentlyMessage.tableName, orderBy: 'last_time DESC');
    return result.map((e) => RecentlyMessage.fromJson(e)).toList();
  }

  static Future<RecentlyMessage?> queryById(int id) async {
    // 根据id查询数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(RecentlyMessage.tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return RecentlyMessage.fromJson(result.first);
    } else {
      return null;
    }
  }

  static Future<RecentlyMessage?> queryByUserId(String userId) async {
    // 根据userId查询数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database.query(
        RecentlyMessage.tableName,
        where: 'user_id = ?',
        whereArgs: [userId]);
    if (result.isNotEmpty) {
      return RecentlyMessage.fromJson(result.first);
    } else {
      return null;
    }
  }

  static Future<int> update(RecentlyMessage recentlyMessage) async {
    // 采用删除后插入的方式更新数据
    Database database = await DBManager.instance.database;
    database.transaction((txn) async {
      await txn.delete(RecentlyMessage.tableName,
          where: 'user_id = ?', whereArgs: [recentlyMessage.userId]);
      await txn.insert(RecentlyMessage.tableName, recentlyMessage.toJson());
    });
    return 1;
  }

  static Future<int> updateRead(int id) async {
    // 更新已读状态
    Database database = await DBManager.instance.database;
    return await database.update(RecentlyMessage.tableName, {'unread_num': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    // 删除数据
    Database database = await DBManager.instance.database;
    return await database
        .delete(RecentlyMessage.tableName, where: 'id = ?', whereArgs: [id]);
  }
}
