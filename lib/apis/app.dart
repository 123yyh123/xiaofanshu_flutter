import '../utils/request.dart';

class AuthApi {
  static String prefix = "/auth";

  static Future loginByPassword(String phoneNumber, String password) async {
    return await Request().request(
      "$prefix/login",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "password": password},
    );
  }

  static Future loginByCode(String phoneNumber, String code) async {
    return await Request().request(
      "$prefix/loginByCode",
      method: DioMethod.post,
      params: {"phoneNumber": phoneNumber, "smsCode": code},
    );
  }

  static Future register(String email, String password, String code) async {
    return await Request().request(
      "$prefix/register",
      method: DioMethod.post,
      data: {"email": email, "password": password, "code": code},
    );
  }
}

class UserApi {}

class NoteApi {
  static String prefix = "/notes";

  static Future getAttentionUserNotes(int page, int size) async {
    return await Request().request(
      "$prefix/getAttentionUserNotes",
      method: DioMethod.get,
      params: {"page": page, "pageSize": size},
    );
  }
}
