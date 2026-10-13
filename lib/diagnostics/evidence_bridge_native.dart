import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

String get audioBackend => 'flutter_pcm_sound / Core Audio';
Future<void> registerEvidence(
  Map<String, dynamic> Function() snapshot,
  Future<void> Function(Map<String, dynamic>) command,
  Future<Uint8List> Function() capture,
) async {
  const port = int.fromEnvironment('ROLLINGTAB_CONTROL_PORT');
  if (port == 0) return;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  server.listen((request) async {
    try {
      if (request.headers.value('origin') != null ||
          !{
            'localhost:$port',
            '127.0.0.1:$port',
          }.contains(request.headers.value('host'))) {
        request.response.statusCode = 403;
        return;
      }
      if (request.uri.path == '/capture') {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(await capture());
      } else if (request.method == 'POST' && request.uri.path == '/command') {
        await command(jsonDecode(await utf8.decoder.bind(request).join()));
        request.response.write(jsonEncode(snapshot()));
      } else {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(snapshot()));
      }
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write(e.toString());
    } finally {
      await request.response.close();
    }
  });
}
