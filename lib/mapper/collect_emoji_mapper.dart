import 'package:sqflite/sqflite.dart';
import 'package:xiaofanshu_flutter/model/collect_emoji.dart';

import '../utils/db_util.dart';

class CollectEmojiMapper {
  static Future<int> insert(Map<String, dynamic> data) async {
    // 插入数据
    Database database = await DBManager.instance.database;
    return await database.insert(CollectEmoji.table, data);
  }

  static Future<List<CollectEmoji>> queryAll() async {
    // 查询所有数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result =
        await database.query(CollectEmoji.table, orderBy: 'time desc');
    return result.map((e) => CollectEmoji.fromJson(e)).toList();
  }

  static Future<void> delete(int id) async {
    // 删除数据
    Database database = await DBManager.instance.database;
    await database.delete(CollectEmoji.table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAll() async {
    // 删除所有数据
    Database database = await DBManager.instance.database;
    await database.delete(CollectEmoji.table);
  }

  // 更改表情的位置，仅仅支持排在最前面，将time设置为当前时间
  static Future<void> updatePosition(int id) async {
    Database database = await DBManager.instance.database;
    await database.update(
        CollectEmoji.table, {'time': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [id]);
  }

  // 更改表情的本地路径
  static Future<void> updatePath(int id, String path) async {
    Database database = await DBManager.instance.database;
    await database.update(CollectEmoji.table, {'fileUrl': path},
        where: 'id = ?', whereArgs: [id]);
  }
}
