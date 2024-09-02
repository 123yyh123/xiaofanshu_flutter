import 'package:sqflite/sqflite.dart';

import '../utils/db_util.dart';

class SystemMessageMapper {
  static Future<int> insert(Map<String, dynamic> data) async {
    Database database = await DBManager.instance.database;
    return await database.insert('system_message', data);
  }

  // 获取系统消息列表
  static Future<List<Map<String, dynamic>>> getAll() async {
    Database database = await DBManager.instance.database;
    return await database.query('system_message', orderBy: 'type');
  }

  // 获取记录里面所有的未读消息的总和
  // select sum(unread_num) from system_message;
  static Future<int> getUnreadCount() async {
    Database database = await DBManager.instance.database;
    // 执行查询获取未读消息总和
    final List<Map<String, dynamic>> result = await database
        .rawQuery('SELECT SUM(unread_num) as total FROM system_message');
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    } else {
      return 0;
    }
  }

  // 更新系统消息，某个消息类型的未读消息数量加1
  static Future<int> updateUnreadCount(int type) async {
    Database database = await DBManager.instance.database;
    return await database.rawUpdate(
        'UPDATE system_message SET unread_num = unread_num + 1 WHERE type = ?',
        [type]);
  }

  // 更新系统消息，某个消息类型的未读消息数量清空
  static Future<int> clearUnreadCount(int type) async {
    Database database = await DBManager.instance.database;
    return await database.rawUpdate(
        'UPDATE system_message SET unread_num = 0 WHERE type = ?', [type]);
  }
}
