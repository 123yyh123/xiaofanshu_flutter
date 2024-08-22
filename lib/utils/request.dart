import 'package:dio/dio.dart';
import 'package:super_network_logger/super_network_logger.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';
import '../config/base_request.dart';
import 'loading_util.dart';
import 'package:get/get.dart' as Get;

/// 请求方法:枚举类型
enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}

// 创建请求类：封装dio
class Request {
  /// 单例模式
  static Request? _instance;

  // 工厂函数：执行初始化
  factory Request() => _instance ?? Request._internal();

  // 获取实例对象时，如果有实例对象就返回，没有就初始化
  static Request? get instance => _instance ?? Request._internal();

  /// Dio实例
  static Dio _dio = Dio();

  /// 初始化
  Request._internal() {
    // 初始化基本选项
    BaseOptions options = BaseOptions(
        baseUrl: BaseRequest.baseUrl,
        connectTimeout: BaseRequest.timeout,
        receiveTimeout: BaseRequest.receiveTimeout);
    _instance = this;
    // 初始化dio
    _dio = Dio(options);
    // 添加拦截器
    _dio.interceptors.add(
      SuperNetworkLogger(),
    );
    // 请求开始时，显示loading
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: _onRequest, onResponse: _onResponse, onError: _onError));
    LoadingUtil.hide();
  }

  /// 请求拦截器
  void _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 头部添加token
    String? token = await readData('token');
    int isFlutter = 1;
    options.headers.addAll({'token': token ?? '', 'isFlutter': isFlutter});
    // 更多业务需求
    handler.next(options);
    // super.onRequest(options, handler);
  }

  /// 相应拦截器
  void _onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // 请求成功时，关闭loading
    LoadingUtil.hide();
    // 请求成功是对数据做基本处理
    if (response.statusCode == 200) {
      // 处理成功的响应
      Get.Get.log('响应结果: $response');
    } else {
      // 处理异常结果
      Get.Get.log('响应异常: $response');
    }
    handler.next(response);
  }

  /// 错误处理: 网络错误等
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    // 请求失败时，关闭loading
    LoadingUtil.hide();
    if (error.type == DioExceptionType.connectionTimeout) {
      SnackbarUtil.show(ErrorString.connectTimeout, SnackbarUtil.error);
    } else if (error.type == DioExceptionType.sendTimeout) {
      SnackbarUtil.show(ErrorString.sendTimeout, SnackbarUtil.error);
    } else if (error.type == DioExceptionType.receiveTimeout) {
      SnackbarUtil.show(ErrorString.receiveTimeout, SnackbarUtil.error);
    } else if (error.type == DioExceptionType.badResponse) {
      SnackbarUtil.show(ErrorString.badResponse, SnackbarUtil.error);
    } else if (error.type == DioExceptionType.cancel) {
      SnackbarUtil.show(ErrorString.cancel, SnackbarUtil.error);
    } else if (error.type == DioExceptionType.connectionError) {
      SnackbarUtil.show(ErrorString.connectionError, SnackbarUtil.error);
    } else {
      SnackbarUtil.show(ErrorString.unknownError, SnackbarUtil.error);
    }
    handler.next(error);
  }

  /// 请求类：支持异步请求操作
  Future<T> request<T>(
    String path, {
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    dynamic data,
    bool? isShowLoading,
    Duration? reactiveTime,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head'
    };
    isShowLoading ??= false;
    // 特殊长接收时间
    reactiveTime ??= BaseRequest.receiveTimeout;
    // 默认配置选项
    options ??=
        Options(method: methodValues[method], receiveTimeout: reactiveTime);
    try {
      Response response;
      // 开始发送请求
      if (isShowLoading) {
        LoadingUtil.show();
      }
      response = await _dio.request(path,
          data: data,
          queryParameters: params,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['msg'] != null) {
        if (e.response?.data['code'] == StatusCode.notLogin ||
            e.response?.data['code'] == StatusCode.tokenExpired ||
            e.response?.data['code'] == StatusCode.tokenInvalid) {
          SnackbarUtil.showError(AuthErrorString.tokenExpired);
          await removeData('token');
          await removeData('userInfo');
          Get.Get.off(const LoginPage());
          Get.Get.delete<WebsocketController>(force: true);
        } else if (e.response?.data['code'] == StatusCode.accountOtherLogin) {
          SnackbarUtil.showError(AuthErrorString.loginOnOtherDevice);
          await removeData('token');
          await removeData('userInfo');
          Get.Get.delete<WebsocketController>(force: true);
          Get.Get.off(const LoginPage());
        } else {
          SnackbarUtil.showError(e.response?.data['msg']);
        }
        return e.response?.data;
      } else {
        rethrow;
      }
    }
  }

  /// 开启日志打印
  /// 需要打印日志的接口在接口请求前 Request.instance?.openLog();
  void openLog() {
    _dio.interceptors
        .add(LogInterceptor(responseHeader: false, responseBody: true));
  }
}
