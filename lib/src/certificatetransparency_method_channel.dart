import 'dart:io';

import 'package:certificatetransparency/src/exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'certificatetransparency_platform_interface.dart';

/// An implementation of [CertificatetransparencyPlatform] that uses method channels.
class MethodChannelCertificatetransparency
    extends CertificatetransparencyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('certificatetransparency');

  /// Currently only support Android platform which will throw [CertificateTransparencyException]
  /// if the certificate is not valid. Other than Android platform will cause [UnimplementedError].
  @override
  Future<void> check({
    required String hostname,
    List<String> includeHosts = const [],
    List<String> excludeHosts = const [],
    String logListBaseUrl = 'https://www.gstatic.com/ct/log_list/v3/',
  }) async {
    Map<String, dynamic> params = <String, dynamic>{
      "hostname": hostname,
      "includeHosts": includeHosts,
      "excludeHosts": excludeHosts,
      "logListBaseUrl": logListBaseUrl,
    };
    if (Platform.isAndroid) {
      var result = await methodChannel.invokeMethod('check', params);
      if (!result['success']) {
        throw const CertificateTransparencyException();
      }
    }
  }
}
