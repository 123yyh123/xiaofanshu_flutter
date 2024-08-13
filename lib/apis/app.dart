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

  static Future<HttpResponse> register(
      String email, String password, String code) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/register",
      method: DioMethod.post,
      data: {"email": email, "password": password, "code": code},
      isShowLoading: true,
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

  static Future<HttpResponse> attentionUser(
      int userId, int targetUserId) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/relation/attention",
      method: DioMethod.post,
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
}

class NoteApi {
  static String prefix = "/notes";

  static Future<HttpResponse> getAttentionUserNotes(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getAttentionUserNotes",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size},
      isShowLoading: true,
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
}

class ThirdApi {
  static String prefix = "/third";

  static Future<HttpResponse> uploadImage(FormData data) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/uploadImg",
      method: DioMethod.post,
      data: data,
    ));
  }
}
