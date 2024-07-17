class StatusCode {
  static const int getSuccess = 20010;
  static const int getError = 20011;

  static const int postSuccess = 20020;
  static const int postError = 20021;

  static const int putSuccess = 20030;
  static const int putError = 20031;

  static const int deleteSuccess = 20040;
  static const int deleteError = 20041;

  //未登录
  static const int notLogin = 40310;

  //token过期
  static const int tokenExpired = 40320;

  //token无效
  static const int tokenInvalid = 40330;

  //密码错误
  static const int passwordError = 40340;

  //手机号已存在
  static const int phoneNumberExist = 10010;

  //手机号未注册
  static const int phoneNumberNotRegister = 10011;

  //短信验证码错误
  static const int smsCodeError = 10020;

  //登录类型错误
  static const int loginTypeError = 10030;

  //第三方账号openId为空
  static const int openIdNull = 10040;

  //短信发送频繁
  static const int smsCodeSendFrequently = 10050;

  //账号异常
  static const int accountException = 10060;

  //账号在其他设备登录
  static const int accountOtherLogin = 10061;

  //账号操作异常
  static const int accountOperationError = 10062;

  //文件过大
  static const int fileSizeTooLarge = 10070;

  //ElasticSearch已初始化
  static const int elasticsearchInitAlready = 10080;

  // ElasticSearch初始化异常
  static const int elasticsearchInitError = 10081;

  //获取地理信息失败
  static const int getGeographicInformationError = 10090;

  //无权限
  static const int noPermission = 10100;

  //操作太过频繁
  static const int repeatOperation = 10110;

  //参数错误
  static const int parameterError = 40010;

  //服务器异常
  static const int serverError = 50000;

  //数据库操作异常
  static const int dbError = 50010;

  //aliyun短信服务初始化异常
  static const int aliyunSmsInitError = 50020;

  //aliyun短信服务异常
  static const int aliyunSmsSendError = 50021;

  //aliyun oss服务异常
  static const int aliyunOssInitError = 50030;
  static const int redisError = 50040;

  //文件不能为空
  static const int fileNotNull = 50050;
}
