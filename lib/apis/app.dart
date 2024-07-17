import 'package:xiaofanshu_flutter/model/response.dart';

import '../utils/request.dart';

class AuthApi {
  static String prefix = "/auth";

  static Future<HttpResponse> loginByPassword(String phoneNumber, String password) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/login",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "password": password},
    ));
  }

  static Future<HttpResponse> loginByCode(String phoneNumber, String code) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/loginByCode",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "smsCode": code},
    ));
  }

  static Future<HttpResponse> register(String email, String password, String code) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/register",
      method: DioMethod.post,
      data: {"email": email, "password": password, "code": code},
    ));
  }
}

class UserApi {}

class NoteApi {
  static String prefix = "/notes";

  static Future<HttpResponse> getAttentionUserNotes(int page, int size) async {
    return HttpResponse.fromJson(await Request().request(
      "$prefix/getAttentionUserNotes",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size},
    ));
  }
}
