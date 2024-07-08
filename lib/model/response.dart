class HttpResponse {
  int code;
  String message;
  dynamic data;

  HttpResponse({required this.code, required this.message, this.data});

  factory HttpResponse.fromJson(Map<String, dynamic> json) {
    return HttpResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }
}
