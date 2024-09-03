import 'package:sqflite/sqflite.dart';
import '../utils/db_util.dart';

class SearchHistoryMapper {
  static Future<int> insert(String keyword) async {
    Database db = await DBManager.instance.database;
    return await db.rawInsert('''
      INSERT INTO search_history (content, updateTime) VALUES (?, ?)
    ''', [keyword, DateTime.now().millisecondsSinceEpoch]);
  }

  static Future<int> updateIfExist(String keyword) async {
    Database db = await DBManager.instance.database;
    // 如果存在则更新时间，不存在则插入
    return await db.rawInsert('''
    INSERT INTO search_history (content, updateTime) 
    VALUES (?, ?) 
    ON CONFLICT(content) DO UPDATE SET updateTime = ?
  ''', [
      keyword,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch
    ]);
  }

  static Future<int> delete(String keyword) async {
    Database db = await DBManager.instance.database;
    return await db.rawDelete('''
      DELETE FROM search_history WHERE content = ?
    ''', [keyword]);
  }

  static Future<int> deleteAll() async {
    Database db = await DBManager.instance.database;
    return await db.rawDelete('''
      DELETE FROM search_history
    ''');
  }

  static Future<List<String>> queryAll() async {
    Database db = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM search_history ORDER BY updateTime DESC
    ''');
    return result.map((e) => e['content'] as String).toList();
  }
}
