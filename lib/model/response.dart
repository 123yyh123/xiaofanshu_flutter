class HttpResponse {
  int code;
  String msg;
  dynamic data;

  HttpResponse({required this.code, required this.msg, this.data});

  factory HttpResponse.fromJson(Map<String, dynamic> json) {
    return HttpResponse(
      code: json['code'],
      msg: json['msg'],
      data: json['data'],
    );
  }
  factory HttpResponse.defaultResponse() {
    return HttpResponse(
      code: 0,
      msg: '',
      data: null,
    );
  }
}
