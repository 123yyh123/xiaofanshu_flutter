/// 错误提示
class ErrorString {
  static const String networkError = '网络错误';
  static const String serverError = '服务器错误';
  static const String unknownError = '未知错误';
  static const String connectTimeout = '连接超时';
  static const String sendTimeout = '发送超时';
  static const String receiveTimeout = '接收超时';
  static const String badCertificate = '证书错误';
  static const String badResponse = '响应错误';
  static const String cancel = '请求取消';
  static const String connectionError = '连接错误';
}

/// 授权错误提示
class AuthErrorString {
  static const String tokenExpired = '用户未认证或登录过期,请重新登录';
  static const String loginOnOtherDevice = '用户已在其他地方登录,请重新登录';
}

/// 登录提示
class LoginString {
  static const String login = '登录';
  static const String register = '注册';
  static const String help = '帮助';
  static const String forgetPassword = '忘记密码';
  static const String loginByPhone = '手机号登录';
  static const String loginByPassword = '密码登录';
  static const String loginByCode = '验证码登录';
  static const String inputPhone = '请输入手机号';
  static const String inputPassword = '请输入密码';
  static const String inputCode = '请输入验证码';
  static const String phoneUnableLogin = '手机号无法登录';
  static const String getCode = '发送验证码';
  static const String beforeResend = 's后重新发送';
  static const String loginSuccess = '登录成功';
  static const String registerSuccess = '注册成功';
  static const String forgetPasswordSuccess = '修改密码成功';
  static const String loginTip = '未注册的手机号验证后自动创建小番薯账号';
}

/// 登录错误提示
class LoginErrorString {
  static const String phoneAndPasswordEmpty = '请填写手机号和验证码';
  static const String phoneAndCodeEmpty = '请填写手机号和密码';
  static const String phoneEmpty = '请输入手机号';
  static const String passwordEmpty = '请输入密码';
  static const String codeEmpty = '请输入验证码';
  static const String phoneError = '请输入正确的手机号';
}

/// 主页
class HomeTabName {
  static const String index = '首页';
  static const String shopping = '购物';
  static const String release = '发布';
  static const String message = '消息';
  static const String mine = '我的';
}

/// 首页
class IndexTabName {
  static const String attention = '关注';
  static const String recommend = '推荐';
  static const String nearBy = '附近';
}

/// 我的
class MineString {
  static const String attention = '关注';
  static const String fans = '粉丝';
  static const String getPraiseAndCollect = '获赞与收藏';
  static const String editInfo = '编辑资料';
}
