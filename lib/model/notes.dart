import 'dart:convert';

class Notes {
  static String tableName = 'notes';
  int id;
  String title;
  String content;
  String coverPicture;
  String nickname;
  String avatarUrl;
  int belongUserId;
  int notesLikeNum;
  int notesCollectNum;
  int notesViewNum;
  int notesType;
  bool isLike;
  bool isCollect;
  bool isFollow;
  List<ResourcesDTO> notesResources;
  String address;
  String province;
  String createTime;
  String updateTime;

  Notes({
    required id,
    required this.title,
    required this.content,
    required this.coverPicture,
    required this.nickname,
    required this.avatarUrl,
    required belongUserId,
    required this.notesLikeNum,
    required this.notesCollectNum,
    required this.notesViewNum,
    required this.notesType,
    required this.isLike,
    required this.isCollect,
    required this.isFollow,
    required this.notesResources,
    required this.province,
    address,
    required this.createTime,
    required this.updateTime,
  })  : id = int.parse(id.toString()),
        belongUserId = int.parse(belongUserId.toString()),
        address = address ?? '';

  factory Notes.fromJson(Map<String, dynamic> json) {
    json['notesResources'] = json['notesResources']
        .map<ResourcesDTO>((e) => ResourcesDTO.fromJson(e))
        .toList();
    return Notes(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      coverPicture: json['coverPicture'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      belongUserId: json['belongUserId'],
      notesLikeNum: json['notesLikeNum'],
      notesCollectNum: json['notesCollectNum'],
      notesViewNum: json['notesViewNum'],
      notesType: json['notesType'],
      isLike: json['isLike'],
      isCollect: json['isCollect'],
      isFollow: json['isFollow'],
      notesResources: json['notesResources'],
      province: json['province'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      address: json['address'],
    );
  }

  factory Notes.fromJsonString(String jsonString) {
    return Notes.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'coverPicture': coverPicture,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'belongUserId': belongUserId,
      'notesLikeNum': notesLikeNum,
      'notesCollectNum': notesCollectNum,
      'notesViewNum': notesViewNum,
      'notesType': notesType,
      'isLike': isLike,
      'isCollect': isCollect,
      'isFollow': isFollow,
      'notesResources': notesResources.map((e) => e.toJson()).toList(),
      'address': address,
      'province': province,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class ResourcesDTO {
  String url;

  ResourcesDTO({
    required this.url,
  });

  factory ResourcesDTO.fromJson(Map<String, dynamic> json) {
    return ResourcesDTO(
      url: json['url'],
    );
  }

  factory ResourcesDTO.fromJsonString(String jsonString) {
    return ResourcesDTO.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
