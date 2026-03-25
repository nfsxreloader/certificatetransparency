import 'package:certificatetransparency/certificatetransparency.dart';
import 'package:certificatetransparency_example/pages/test_webview.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:system_proxy/system_proxy.dart';

class TestPage extends StatefulWidget {
  final String title;

  const TestPage({required this.title, Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late TextEditingController _baseUrlController;
  late TextEditingController _hostnameController;

  late Set<String> _includeHosts;
  late Set<String> _excludeHosts;

  @override
  void initState() {
    _baseUrlController = TextEditingController();
    _hostnameController = TextEditingController();
    _includeHosts = <String>{};
    _excludeHosts = <String>{};
    super.initState();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _hostnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  label: Text('Base URL'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Included Hosts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              ..._includeHosts.map((host) => Text('+ $host')).toList(),
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
                onPressed: () async {
                  _hostnameController.clear();
                  var result = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Include Host'),
                      content: TextField(
                        controller: _hostnameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Hostname'),
                          hintText: 'subdomain.example.com',
                          helperText:
                              'e.g. *.*, example.com, *.example.com, subdomain.example.com',
                          helperMaxLines: 2,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(_hostnameController.text);
                          },
                          child: const Text('Include'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _includeHosts.add(result);
                    });
                  }
                },
                child: const Text('Include Host'),
              ),
              const SizedBox(height: 16),
              Text(
                'Excluded Hosts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              ..._excludeHosts.map((host) => Text('- $host')).toList(),
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
                onPressed: () async {
                  _hostnameController.clear();
                  var result = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Exclude Host'),
                      content: TextField(
                        controller: _hostnameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Hostname'),
                          hintText: 'subdomain.example.com',
                          helperText:
                              'e.g. *.*, example.com, *.example.com, subdomain.example.com',
                          helperMaxLines: 2,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(_hostnameController.text);
                          },
                          child: const Text('Exclude'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _excludeHosts.add(result);
                    });
                  }
                },
                child: const Text('Exclude Host'),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
                onPressed: () async {
                  final client = Dio(
                    BaseOptions(
                      baseUrl: _baseUrlController.text,
                    ),
                  );
                  Map<String, String>? proxy =
                      await SystemProxy.getProxySettings();
                  var host = proxy?['host'];
                  var port = proxy?['port'];
                  client.httpClientAdapter = IOHttpClientAdapter()
                    ..onHttpClientCreate = (client) {
                      String? proxy;
                      if (host != null) {
                        proxy = host;
                        if (port != null) {
                          proxy += ':$port';
                        }
                      }
                      client.findProxy =
                          (uri) => proxy == null ? 'DIRECT' : 'PROXY $proxy';
                      return client;
                    };
                  client.interceptors.add(
                    CertificateTransparencyInterceptor(
                      includeHosts: _includeHosts.toList(),
                      excludeHosts: _excludeHosts.toList(),
                      logListBaseUrl: 'https://www.gstatic.com/ct/log_list/v1/',
                    ),
                  );
                  try {
                    await client.get('');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Valid certificate',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.greenAccent,
                        ),
                      );
                    }
                  } on DioError catch (e) {
                    if (e.type == DioErrorType.badCertificate) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invalid certificate',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text(
                  'Test Certificate Transparency',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TestWebviewPage(),
                    ),
                  );
                },
                child: const Text(
                  'Test on Webview',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
