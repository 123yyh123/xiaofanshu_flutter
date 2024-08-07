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
}
