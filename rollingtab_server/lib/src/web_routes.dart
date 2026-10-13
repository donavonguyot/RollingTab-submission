import 'dart:io' as io;
import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

const bridgeMethods = {
  'catalog/list',
  'catalog/getArtifact',
  'passages/list',
  'passages/save',
  'passages/delete',
  'emailIdp/login',
  'jwtRefresh/refreshAccessToken',
  'serverpod_auth_core.status/signOutDevice',
};

/// Same-origin transport to this process's API only; never accepts an upstream URL.
class ApiBridge extends Route {
  final int apiPort;
  final Set<String> origins;
  final io.HttpClient _client = io.HttpClient()..autoUncompress = false;
  ApiBridge(this.apiPort, this.origins)
    : super(methods: Method.values.toSet(), path: '/api/**');
  @override
  Future<Response> handleCall(Session session, Request request) async {
    if (request.method != Method.post) return Response(405, body: Body.empty());
    final path = request.url.path.replaceFirst(RegExp(r'^/api/'), '');
    final origin = request.headers['origin']?.singleOrNull;
    if (!bridgeMethods.contains(path) || request.url.hasQuery) {
      return Response.forbidden();
    }
    if (origin != null && !origins.contains(origin)) {
      return Response.forbidden();
    }
    final data = BytesBuilder();
    await for (final chunk in request.body.read()) {
      data.add(chunk);
      if (data.length > 65536) return Response(413, body: Body.empty());
    }
    final upstream = await _client.postUrl(
      Uri.parse('http://127.0.0.1:$apiPort/$path'),
    );
    upstream.followRedirects = false;
    for (final header in [
      'content-type',
      'authorization',
      'cookie',
      'origin',
      'x-serverpod-auth-mode',
    ]) {
      final values = request.headers[header];
      if (values != null) upstream.headers.set(header, values.toList());
    }
    upstream.add(data.takeBytes());
    final result = await upstream.close().timeout(const Duration(seconds: 30));
    final bytes = BytesBuilder();
    await for (final chunk in result) {
      bytes.add(chunk);
    }
    final headers = <String, List<String>>{
      'cache-control': ['no-store'],
    };
    for (final name in ['content-type', 'set-cookie', 'www-authenticate']) {
      final value = result.headers[name];
      if (value != null) headers[name] = value;
    }
    return Response(
      result.statusCode,
      body: Body.fromData(
        bytes.takeBytes(),
        mimeType: MimeType.parse(
          result.headers.contentType?.mimeType ?? 'application/json',
        ),
        encoding: Encoding.getByName(
          result.headers.contentType?.charset ?? 'utf-8',
        ),
      ),
      headers: Headers.fromMap(headers),
    );
  }
}

/// Explicit local review exports only; never registered in production.
class ReviewExportRoute extends Route {
  final io.Directory directory;
  ReviewExportRoute(this.directory)
    : super(methods: {Method.post}, path: '/__review/**');
  @override
  Future<Response> handleCall(Session session, Request request) async {
    final name = request.url.path.split('/').last;
    if (request.headers['origin']?.singleOrNull != 'http://localhost:9895' ||
        !{
          'rollingtab-measurement.json',
          'rollingtab-still.png',
        }.contains(name)) {
      return Response.forbidden();
    }
    final bytes = BytesBuilder();
    await for (final chunk in request.body.read()) {
      bytes.add(chunk);
      if (bytes.length > 8 * 1024 * 1024) {
        return Response(413, body: Body.empty());
      }
    }
    await directory.create(recursive: true);
    await io.File('${directory.path}/$name').writeAsBytes(bytes.takeBytes());
    return Response(201, body: Body.empty());
  }
}

class ScoreBytesRoute extends Route {
  final List<int> bytes;
  ScoreBytesRoute(this.bytes) : super(path: '/');
  @override
  Future<Response> handleCall(Session session, Request request) async {
    if (request.url.hasQuery) return Response.notFound();
    return Response.ok(
      body: Body.fromData(
        Uint8List.fromList(bytes),
        mimeType: MimeType('application', 'gzip'),
      ),
      headers: Headers.fromMap({
        'cache-control': ['public, max-age=31536000, immutable'],
        'x-content-type-options': ['nosniff'],
      }),
    );
  }
}

/// Keep document-relative audio and Flutter assets beneath the app prefix.
Handler playSlashRedirect(Handler next) => (request) {
  // Relic normalizes route matching, so an exact Route also matches /play/.
  // Check the original URL in middleware to avoid redirecting it to itself.
  if (request.url.path == '/play') {
    return Response.movedPermanently(request.url.replace(path: '/play/'));
  }
  return next(request);
};
