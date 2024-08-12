import 'package:xiaofanshu_flutter/model/notes.dart';
import 'package:xiaofanshu_flutter/model/recommend_tab.dart';
import 'package:xiaofanshu_flutter/model/user.dart';

class DefaultData {
  // INSERT INTO `notes_category` VALUES (2, '体育', 6, '/static/categoryIcon/sports.png');
  // INSERT INTO `notes_category` VALUES (3, '娱乐', 6, '/static/categoryIcon/recreation.png');
  // INSERT INTO `notes_category` VALUES (4, '艺术', 6, '/static/categoryIcon/art.png');
  // INSERT INTO `notes_category` VALUES (5, '财经', 6, '/static/categoryIcon/finance.png');
  // INSERT INTO `notes_category` VALUES (6, '数码', 6, '/static/categoryIcon/digitalCode.png');
  // INSERT INTO `notes_category` VALUES (7, '科技', 6, '/static/categoryIcon/popularizationScience.png');
  // INSERT INTO `notes_category` VALUES (8, '情感', 6, '/static/categoryIcon/emotion.png');
  // INSERT INTO `notes_category` VALUES (9, '汽车', 6, '/static/categoryIcon/cars.png');
  // INSERT INTO `notes_category` VALUES (10, '教育', 6, '/static/categoryIcon/education.png');
  // INSERT INTO `notes_category` VALUES (11, '时尚', 6, '/static/categoryIcon/fashion.png');
  // INSERT INTO `notes_category` VALUES (12, '游戏', 4, '/static/categoryIcon/game.png');
  // INSERT INTO `notes_category` VALUES (13, '军事', 5, '/static/categoryIcon/military.png');
  // INSERT INTO `notes_category` VALUES (14, '旅游', 5, '/static/categoryIcon/travel.png');
  // INSERT INTO `notes_category` VALUES (15, '美食', 5, '/static/categoryIcon/foods.png');
  // INSERT INTO `notes_category` VALUES (16, '文化', 5, '/static/categoryIcon/culture.png');
  // INSERT INTO `notes_category` VALUES (17, '健康养生', 5, '/static/categoryIcon/health.png');
  // INSERT INTO `notes_category` VALUES (18, '搞笑', 5, '/static/categoryIcon/funny.png');
  // INSERT INTO `notes_category` VALUES (19, '家居', 5, '/static/categoryIcon/homeAndHome.png');
  // INSERT INTO `notes_category` VALUES (20, '动漫', 1, '/static/categoryIcon/cartoon.png');
  // INSERT INTO `notes_category` VALUES (21, '宠物', 7, '/static/categoryIcon/pet.png');
  // INSERT INTO `notes_category` VALUES (22, '母婴育儿', 7, '/static/categoryIcon/parenting.png');
  // INSERT INTO `notes_category` VALUES (23, '星座运势', 7, '/static/categoryIcon/starSign.png');
  // INSERT INTO `notes_category` VALUES (24, '历史', 2, '/static/categoryIcon/history.png');
  // INSERT INTO `notes_category` VALUES (25, '音乐', 8, '/static/categoryIcon/music.png');
  // INSERT INTO `notes_category` VALUES (26, '摄影', 3, '/static/categoryIcon/shoot.png');
  // 默认推荐tab列表
  static List<RecommendTab> recommendTabList = [
    RecommendTab(id: 1, name: '推荐', sort: 0),
    RecommendTab(id: 2, name: '体育', sort: 6),
    RecommendTab(id: 3, name: '娱乐', sort: 6),
    RecommendTab(id: 4, name: '艺术', sort: 6),
    RecommendTab(id: 5, name: '财经', sort: 6),
    RecommendTab(id: 6, name: '数码', sort: 6),
    RecommendTab(id: 7, name: '科技', sort: 6),
    RecommendTab(id: 8, name: '情感', sort: 6),
    RecommendTab(id: 9, name: '汽车', sort: 6),
    RecommendTab(id: 10, name: '教育', sort: 6),
    RecommendTab(id: 11, name: '时尚', sort: 6),
    RecommendTab(id: 12, name: '游戏', sort: 4),
    RecommendTab(id: 13, name: '军事', sort: 5),
    RecommendTab(id: 14, name: '旅游', sort: 5),
    RecommendTab(id: 15, name: '美食', sort: 5),
    RecommendTab(id: 16, name: '文化', sort: 5),
    RecommendTab(id: 17, name: '健康养生', sort: 5),
    RecommendTab(id: 18, name: '搞笑', sort: 5),
    RecommendTab(id: 19, name: '家居', sort: 5),
    RecommendTab(id: 20, name: '动漫', sort: 1),
    RecommendTab(id: 21, name: '宠物', sort: 7),
    RecommendTab(id: 22, name: '母婴育儿', sort: 7),
    RecommendTab(id: 23, name: '星座运势', sort: 7),
    RecommendTab(id: 24, name: '历史', sort: 2),
    RecommendTab(id: 25, name: '音乐', sort: 8),
    RecommendTab(id: 26, name: '摄影', sort: 3),
  ];

  static User user = User(
    id: 1,
    uid: '1',
    nickname: '小番薯',
    avatarUrl: 'https://pmall-yyh.oss-cn-chengdu.aliyuncs.com/00001.jpg',
    age: 18,
    sex: 1,
    area: '中国',
    birthday: '1970-01-01',
    selfIntroduction: '这个人很懒，什么都没有留下',
    homePageBackground:
        'https://pmall-yyh.oss-cn-chengdu.aliyuncs.com/IMG_20231212_011126.jpg',
    phoneNumber: '18888888888',
    token: 'token',
    ipAddr: '北京市',
    attentionNum: 9999,
    fansNum: 9999,
  );

  static Notes notes = Notes(
      id: 1,
      title: '标题',
      content: '内容',
      coverPicture: 'https://pmall-yyh.oss-cn-chengdu.aliyuncs.com/00001.jpg',
      nickname: '小番薯',
      avatarUrl: 'https://pmall-yyh.oss-cn-chengdu.aliyuncs.com/00001.jpg',
      belongUserId: 1,
      notesLikeNum: 9999,
      notesCollectNum: 9999,
      notesViewNum: 9999,
      notesType: 1,
      isLike: true,
      isCollect: true,
      isFollow: true,
      notesResources: [
        ResourcesDTO(url: ''),
      ],
      province: '北京市',
      createTime: '2024-08-07 10:58:26',
      updateTime: '2024-08-07 10:58:26');
}
