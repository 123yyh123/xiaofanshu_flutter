import 'package:sqflite/sqflite.dart';

import '../utils/db_util.dart';

class PraiseAndCollectionMapper {
  static Future<int> insert(Map<String, dynamic> data) async {
    Database database = await DBManager.instance.database;
    return await database.insert('praise_and_collection', data);
  }

  static Future<List<Map<String, dynamic>>> queryAll() async {
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result =
        await database.query('praise_and_collection', orderBy: 'time desc');
    return result;
  }

  static Future<List<Map<String, dynamic>>> queryPage(
      int page, int pageSize) async {
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database.query(
        'praise_and_collection',
        limit: pageSize,
        offset: (page - 1) * pageSize,
        orderBy: 'time desc');
    return result;
  }

  static Future<int> delete(int id) async {
    Database database = await DBManager.instance.database;
    return await database
        .delete('praise_and_collection', where: 'id = ?', whereArgs: [id]);
  }
}
