import 'package:certificatetransparency/src/certificatetransparency_method_channel.dart';
import 'package:dio/dio.dart';

/// Certificate Transparency Interceptor for [Dio](https://pub.dev/packages/dio).
/// Accepts [includeHosts], [excludeHosts] and [logListBaseUrl].
/// [includeHosts] indicates the included hosts to be validated
/// [excludeHosts] indicates the excluded hosts to be validated
/// [logListBaseUrl] value will override the default CT log list base url.
class CertificateTransparencyInterceptor extends Interceptor {
  final List<String> includeHosts;
  final List<String> excludeHosts;
  final String logListBaseUrl;

  CertificateTransparencyInterceptor({
    this.includeHosts = const [],
    this.excludeHosts = const [],
    this.logListBaseUrl = 'https://www.gstatic.com/ct/log_list/v3/',
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await MethodChannelCertificatetransparency().check(
        hostname: options.baseUrl,
        includeHosts: includeHosts,
        excludeHosts: excludeHosts,
        logListBaseUrl: logListBaseUrl,
      );
      super.onRequest(options, handler);
    } on Exception catch (e) {
      handler.reject(DioError(
        requestOptions: options,
        error: e,
        type: DioErrorType.badCertificate,
      ));
    }
  }
}
