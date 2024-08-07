class RecommendTab {
  static String tableName = 'recommend_tab';

  int? id;
  String name;
  int sort;
  int? status;
  int? createTime;
  int? updateTime;

  RecommendTab({
    this.id,
    required this.name,
    required this.sort,
    this.status,
    this.createTime,
    this.updateTime,
  });

  factory RecommendTab.fromJson(Map<String, dynamic> json) {
    return RecommendTab(
      id: json['id'],
      name: json['name'],
      sort: json['sort'],
      status: json['status'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sort': sort,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }
}
