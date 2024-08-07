import 'dart:convert';

class User {
  static String tableName = 'user';
  int id;
  String uid;
  String nickname;
  String avatarUrl;
  int age;
  int sex;
  String area;
  String birthday;
  String selfIntroduction;
  String homePageBackground;
  String phoneNumber;
  String token;
  String ipAddr;
  int attentionNum;
  int fansNum;

  User({
    id,
    required this.uid,
    required this.nickname,
    required this.avatarUrl,
    required this.age,
    required this.sex,
    required this.area,
    required this.birthday,
    required this.selfIntroduction,
    required this.homePageBackground,
    required this.phoneNumber,
    required this.token,
    required this.ipAddr,
    required this.attentionNum,
    required this.fansNum,
  }) : id = int.parse(id.toString());

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uid: json['uid'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      age: json['age'],
      sex: json['sex'],
      area: json['area'],
      birthday: json['birthday'],
      selfIntroduction: json['selfIntroduction'],
      homePageBackground: json['homePageBackground'],
      phoneNumber: json['phoneNumber'],
      token: json['token'],
      ipAddr: json['ipAddr'],
      attentionNum: json['attentionNum'],
      fansNum: json['fansNum'],
    );
  }

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'age': age,
      'sex': sex,
      'area': area,
      'birthday': birthday,
      'selfIntroduction': selfIntroduction,
      'homePageBackground': homePageBackground,
      'phoneNumber': phoneNumber,
      'token': token,
      'ipAddr': ipAddr,
      'attentionNum': attentionNum,
      'fansNum': fansNum,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
