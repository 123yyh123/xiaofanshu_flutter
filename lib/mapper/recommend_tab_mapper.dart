import 'package:sqflite/sqflite.dart';
import 'package:xiaofanshu_flutter/model/recommend_tab.dart';
import 'package:xiaofanshu_flutter/utils/db_util.dart';
import 'package:get/get.dart';

class RecommendTabMapper {
  static Future<int> insert(RecommendTab recommendTab) async {
    // 插入数据
    Database database = await DBManager.instance.database;
    return await database.insert(RecommendTab.tableName, recommendTab.toJson());
  }

  static Future<int> insertList(List<RecommendTab> recommendTabList) async {
    // 批量插入数据
    Get.log('批量插入数据');
    Database database = await DBManager.instance.database;
    Batch batch = database.batch();
    for (var recommendTab in recommendTabList) {
      batch.insert(RecommendTab.tableName, recommendTab.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return (await batch.commit()).length;
  }

  static Future<RecommendTab?> queryById(int id) async {
    // 根据id查询数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result = await database
        .query(RecommendTab.tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return RecommendTab.fromJson(result.first);
    } else {
      return null;
    }
  }

  static Future<List<RecommendTab>> queryAll() async {
    // 查询所有数据
    Database database = await DBManager.instance.database;
    List<Map<String, dynamic>> result =
        await database.query(RecommendTab.tableName, orderBy: 'sort ASC');
    return result.map((e) => RecommendTab.fromJson(e)).toList();
  }

  static Future<int> updateSort(int swapId, int targetId) async {
    // 更新排序
    Database database = await DBManager.instance.database;
    RecommendTab? recommendTabSwap = await queryById(swapId);
    RecommendTab? recommendTabTarget = await queryById(targetId);
    recommendTabSwap?.sort = recommendTabTarget!.sort;
    recommendTabTarget?.sort = recommendTabSwap!.sort;
    if (recommendTabSwap != null && recommendTabTarget != null) {
      // 开启事务，将swapId和targetId的sort互换
      await database.transaction((txn) async {
        await txn.update(RecommendTab.tableName, recommendTabSwap.toJson(),
            where: 'id = ?', whereArgs: [swapId]);
        await txn.update(RecommendTab.tableName, recommendTabTarget.toJson(),
            where: 'id = ?', whereArgs: [targetId]);
      });
      return 2;
    } else {
      return 0;
    }
  }
}
