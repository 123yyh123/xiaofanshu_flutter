import 'package:sqflite/sqflite.dart';
import '../utils/db_util.dart';

class ChatMessageMapper {
  static const String tableName = 'chat_';

  static Future<int> insert(Map<String, dynamic> data, String toId) async {
    // 插入数据
    Database database = await DBManager.instance.database;
    return await database.insert(tableName + toId, data);
  }

  static Future<List<Map<String, dynamic>>> queryAll(int toId) async {
    // 查询所有数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result =
        await database.query(tableName + toId.toString(), orderBy: 'time asc');
    return result;
  }

  static Future<Map<String, dynamic>> queryById(int id, int toId) async {
    // 根据id查询数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(tableName + toId.toString(), where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  static Future<int> delete(int id, int toId) async {
    // 删除数据
    Database database = await DBManager.instance.database;
    return await database
        .delete(tableName + toId.toString(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteAll(int toId) async {
    // 删除所有数据
    Database database = await DBManager.instance.database;
    return await database.delete(tableName + toId.toString());
  }

  // 更新消息状态
  static Future<int> updateMessageStatus(int id, int toId, int status) async {
    Database database = await DBManager.instance.database;
    return await database.update(
        tableName + toId.toString(), {'is_send': status},
        where: 'id = ?', whereArgs: [id]);
  }

  // 取10条消息，分页查询
  // SELECT *
  // FROM tableName
  // WHERE time < (
  //     SELECT time
  //     FROM tableName
  //     WHERE id = lastMessageId
  // )
  // ORDER BY time DESC
  // LIMIT 10;
  static Future<List<Map<String, dynamic>>> queryRecentMessage(
      int toId, int lastMessageId) async {
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result;
    if (lastMessageId == -1) {
      result = await database.query(tableName + toId.toString(),
          orderBy: 'time desc', limit: 15);
    } else {
      result = await database.rawQuery(
          'SELECT * FROM $tableName$toId WHERE time < (SELECT time FROM $tableName$toId WHERE id = ?) ORDER BY time DESC LIMIT 15;',
          [lastMessageId]);
    }
    return result;
  }

  // 取最新的一条消息
  static Future<Map<String, dynamic>> queryLatestMessage(int toId) async {
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(tableName + toId.toString(), orderBy: 'time desc', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  // 获取最新的聊天消息，从给定的消息id开始，时间大于给定消息id的消息
  static Future<List<Map<String, dynamic>>> queryNewMessage(
      int toId, int lastMessageId) async {
    Database database = await DBManager.instance.database;
    if (lastMessageId == -1) {
      // 取出所有消息，时间升序
      return await database.query(tableName + toId.toString(),
          orderBy: 'time asc');
    } else {
      return await database.rawQuery(
          'SELECT * FROM $tableName$toId WHERE time > (SELECT time FROM $tableName$toId WHERE id = ?) ORDER BY time ASC;',
          [lastMessageId]);
    }
  }
}
