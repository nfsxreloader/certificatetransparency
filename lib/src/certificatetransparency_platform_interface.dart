import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'certificatetransparency_method_channel.dart';

abstract class CertificatetransparencyPlatform extends PlatformInterface {
  /// Constructs a CertificatetransparencyPlatform.
  CertificatetransparencyPlatform() : super(token: _token);

  static final Object _token = Object();

  static CertificatetransparencyPlatform _instance =
      MethodChannelCertificatetransparency();

  /// The default instance of [CertificatetransparencyPlatform] to use.
  ///
  /// Defaults to [MethodChannelCertificatetransparency].
  static CertificatetransparencyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CertificatetransparencyPlatform] when
  /// they register themselves.
  static set instance(CertificatetransparencyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// The check method method which will be called to validate [hostname] to
  /// [logListBaseUrl]'s log list. If [hostname] is in [includeHosts], certificate
  /// validation will be required, and if [hostname] is in [excludedHosts], certificate
  /// validation will be skipped.
  /// if [logListBaseUrl] is not provided, the default value will be
  /// "https://www.gstatic.com/ct/log_list/v3/"
  Future<void> check({
    required String hostname,
    List<String> includeHosts,
    List<String> excludeHosts,
    String logListBaseUrl,
  });
}
