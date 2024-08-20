import 'package:sqflite/sqflite.dart';
import 'package:xiaofanshu_flutter/model/draft_notes.dart';

import '../utils/db_util.dart';

class DraftNotesMapper {
  static Future<int> insert(DraftNotes draft) async {
    // 插入数据
    Database database = await DBManager.instance.database;
    return await database.insert(DraftNotes.tableName, draft.toMap());
  }

  static Future<List<DraftNotes>> queryAll() async {
    // 查询所有数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result =
        await database.query(DraftNotes.tableName, orderBy: 'createTime DESC');
    return result.map((e) => DraftNotes.fromMap(e)).toList();
  }

  static Future<DraftNotes?> queryById(int id) async {
    // 根据id查询数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(DraftNotes.tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return DraftNotes.fromMap(result.first);
    } else {
      return null;
    }
  }

  static Future<int> delete(int id) async {
    // 删除数据
    Database database = await DBManager.instance.database;
    return await database
        .delete(DraftNotes.tableName, where: 'id = ?', whereArgs: [id]);
  }
}
