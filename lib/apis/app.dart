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
