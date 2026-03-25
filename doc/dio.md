# Using Certificate Transparency with Dio

The library allows you to create an interceptor for use where by default certificate transparency check runs on all domains.

```dart
final client = Dio(BaseOptions(baseUrl: baseUrl));

client.interceptors.add(CertificateTransparencyInterceptor());
```

You can specify which hosts to disable certificate transparency checks on through exclusions.

```dart
final interceptor = CertificateTransparencyInterceptor(
    includeHosts: [],
    excludeHosts: [
        '*.example.com'
    ],
);
```
