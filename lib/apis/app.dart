import 'package:dio/dio.dart';
import 'package:xiaofanshu_flutter/model/response.dart';

import '../utils/request.dart';

class AuthApi {
  static String prefix = "/auth";

  /// 登录
  static Future<HttpResponse> loginByPassword(
      String phoneNumber, String password) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/login",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "password": password},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> loginByCode(
      String phoneNumber, String code) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/loginByCode",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "smsCode": code},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> logout(int userId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/logout",
      method: DioMethod.post,
      isShowLoading: true,
      params: {'userId': userId},
    ));
  }

  static Future<HttpResponse> register(
      String email, String password, String code) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/register",
      method: DioMethod.post,
      data: {"email": email, "password": password, "code": code},
      isShowLoading: true,
    ));
  }

  // 获取TRTC的userSig
  static Future<HttpResponse> getTrtcUserSig(String userId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getTrtcUserSig",
      method: DioMethod.post,
      params: {"userId": userId},
    ));
  }
}

class UserApi {
  static String prefix = "/user";

  static Future<HttpResponse> getUserInfo(int userId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getUserInfo",
      method: DioMethod.get,
      params: {"userId": userId},
    ));
  }

  static Future<HttpResponse> updateUserAvatar(String avatar, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateAvatarUrl",
      method: DioMethod.post,
      data: {"id": id, "avatarUrl": avatar},
    ));
  }

  static Future<HttpResponse> updateUserBackground(
      String background, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateBackgroundImage",
      method: DioMethod.post,
      data: {"id": id, "homePageBackground": background},
    ));
  }

  static Future<HttpResponse> updateUserNickname(
      String nickname, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateNickname",
      method: DioMethod.post,
      data: {"id": id, "nickname": nickname},
    ));
  }

  static Future<HttpResponse> updateUserIntroduction(
      String introduction, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateIntroduction",
      method: DioMethod.post,
      data: {"id": id, "selfIntroduction": introduction},
    ));
  }

  static Future<HttpResponse> updateUserSex(int sex, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateSex",
      method: DioMethod.post,
      data: {"id": id, "sex": sex},
    ));
  }

  static Future<HttpResponse> updateUserBirthday(
      String birthday, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateBirthday",
      method: DioMethod.post,
      data: {"id": id, "birthday": birthday},
    ));
  }

  static Future<HttpResponse> updateUserArea(String area, int id) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/updateArea",
      method: DioMethod.post,
      data: {"id": id, "area": area},
    ));
  }

  static Future<HttpResponse> attentionUser(
      int userId, int targetUserId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/relation/attention",
      method: DioMethod.post,
      isShowLoading: true,
      params: {"userId": userId, "targetUserId": targetUserId},
    ));
  }

  static Future<HttpResponse> viewUserInfo(int userId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/viewUserInfo",
      method: DioMethod.get,
      params: {"userId": userId},
    ));
  }

  static Future<HttpResponse> getAttentionList(
      int userId, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/relation/attentionList",
      method: DioMethod.get,
      params: {"userId": userId, "pageNum": page, "pageSize": size},
    ));
  }

  static Future<HttpResponse> getFansList(
      int userId, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/relation/fansList",
      method: DioMethod.get,
      params: {"userId": userId, "pageNum": page, "pageSize": size},
    ));
  }
}

class NoteApi {
  static String prefix = "/notes";

  static Future<HttpResponse> publishNotes(Map<String, dynamic> data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/publish",
      method: DioMethod.post,
      data: data,
    ));
  }

  static Future<HttpResponse> getAttentionUserNotes(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getAttentionUserNotes",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size},
      // isShowLoading: true,
    ));
  }

  static Future<HttpResponse> getNoteCategory() async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/category/getNotesCategoryList",
      method: DioMethod.get,
    ));
  }

  static Future<HttpResponse> getRecommendNotesList(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getLastNotesByPage",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> getRecommendNotesListByCategory(
      int page, int size, int categoryId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByCategoryId",
      method: DioMethod.get,
      params: {
        "page": page,
        "pageSize": size,
        "categoryId": categoryId,
        "type": 0,
        "notesType": 2
      },
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> praiseNotes(
      int notesId, int userId, int targetUserId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/praiseNotes",
      method: DioMethod.post,
      params: {
        "notesId": notesId,
        "userId": userId,
        "targetUserId": targetUserId
      },
    ));
  }

  static Future<HttpResponse> getMyNotes(
      int publishType, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByUserId",
      method: DioMethod.get,
      params: {
        "page": page,
        "pageSize": size,
        "authority": publishType,
        "type": 0
      },
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> getNotesByView(
      int page, int size, int type, int userId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByView",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size, "type": type, "userId": userId},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> getMyCollects(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByUserId",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size, "type": 1, "authority": 0},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse> getMyLikes(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByUserId",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size, "type": 2, "authority": 0},
      isShowLoading: true,
    ));
  }

  static Future<HttpResponse>
      getAllNotesCountAndPraiseCountAndCollectCount() async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getAllNotesCountAndPraiseCountAndCollectCount",
      method: DioMethod.get,
    ));
  }

  static Future<HttpResponse> getNotesDetail(int notesId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getNotesByNotesId",
      method: DioMethod.get,
      params: {"notesId": notesId},
    ));
  }

  static Future<HttpResponse> collectNotes(
      int notesId, int userId, int targetUserId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/collectNotes",
      method: DioMethod.post,
      params: {
        "notesId": notesId,
        "userId": userId,
        "targetUserId": targetUserId
      },
    ));
  }
}

class SearchApi {
  static String prefix = "/search";

  static Future<HttpResponse> searchUser(
      String keyword, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/user/getUser",
      method: DioMethod.get,
      params: {"keyword": keyword, "page": page, "pageSize": size},
    ));
  }

  static Future<HttpResponse> searchNotes(
      String keyword, int page, int size, int notesType, int hot) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/notes/getNotesByKeyword",
      method: DioMethod.get,
      params: {
        "keyword": keyword,
        "page": page,
        "pageSize": size,
        "notesType": notesType,
        "hot": hot
      },
    ));
  }

  static Future<HttpResponse> getNotesNearBy(
      double latitude, double longitude, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/notes/getNotesNearBy",
      method: DioMethod.post,
      data: {
        "longitude": longitude,
        "latitude": latitude,
        "page": page,
        "pageSize": size
      },
    ));
  }
}

class CommentApi {
  static String prefix = "/comment";

  static Future<HttpResponse> getCommentCountByNotesId(int notesId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getCommentCount",
      method: DioMethod.get,
      params: {"notesId": notesId},
    ));
  }

  static Future<HttpResponse> getCommentFirstListByNotesId(
      int notesId, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getCommentFirstList",
      method: DioMethod.get,
      params: {"notesId": notesId, "page": page, "pageSize": size},
    ));
  }

  static Future<HttpResponse> getCommentSecondListByNotesId(
      int notesId, String parentId, int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getCommentSecondList",
      method: DioMethod.get,
      params: {
        "notesId": notesId,
        "parentId": parentId,
        "page": page,
        "pageSize": size
      },
    ));
  }

  static Future<HttpResponse> praiseComment(
      String commentId, int userId, int targetUserId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/praiseComment",
      method: DioMethod.post,
      params: {
        "commentId": commentId,
        "userId": userId,
        "targetUserId": targetUserId
      },
    ));
  }

  static Future<HttpResponse> addComment(Map<String, dynamic> data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/addComment",
      method: DioMethod.post,
      data: data,
    ));
  }

  static Future<HttpResponse> setTopComment(String commentId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/setTopComment",
      method: DioMethod.post,
      isShowLoading: true,
      params: {"commentId": commentId},
    ));
  }

  static Future<HttpResponse> deleteComment(String commentId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/deleteComment",
      method: DioMethod.delete,
      isShowLoading: true,
      params: {"commentId": commentId},
    ));
  }
}

class ThirdApi {
  static String prefix = "/third";

  static Future<HttpResponse> uploadImage(FormData data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/uploadImg",
      method: DioMethod.post,
      data: data,
      reactiveTime: const Duration(seconds: 20),
    ));
  }

  static Future<HttpResponse> uploadVideo(FormData data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/uploadVideo",
      method: DioMethod.post,
      data: data,
      reactiveTime: const Duration(seconds: 100),
    ));
  }

  static Future<HttpResponse> uploadAudio(FormData data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/uploadAudio",
      method: DioMethod.post,
      data: data,
      reactiveTime: const Duration(seconds: 20),
    ));
  }

  // 获取周边信息，location 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
  static Future<Map<String, dynamic>> getPeripheralInformation(
      String location, int page,
      {String keywords = ''}) async {
    Dio dio = Dio();
    Response response = await dio.get(
      "https://restapi.amap.com/v3/place/around",
      queryParameters: {
        "key": "3b68169ed0fc463234db5491ab18c95e",
        "location": location,
        "keywords": keywords,
        "radius": 10000,
        "page": page,
      },
    );
    return response.data;
  }
}
