import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/serverpod.dart';
import 'src/catalog.dart';
import 'src/bootstrap.dart';
import 'src/web_routes.dart';

Serverpod createServer(List<String> args) {
  final pod = Serverpod(args);
  if (pod.runMode == 'production') {
    final cookie = pod.config.authCookie;
    final host = pod.config.webServer?.publicHost;
    final origins = pod.config.allowedOrigins ?? [];
    if (cookie == null ||
        !cookie.secure ||
        cookie.name != 'rollingtab_auth' ||
        cookie.refreshName != 'rollingtab_refresh' ||
        cookie.path != '/api/' ||
        cookie.domain != null ||
        origins.length != 1 ||
        origins.single != 'https://$host') {
      throw StateError(
        'Configure RollingTAB secure cookies and the exact web origin before starting production.',
      );
    }
  }
  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      EmailIdpConfig(
        secretHashPepper: pod.getPassword('emailSecretHashPepper')!,
        sendRegistrationVerificationCode: (
          session, {
          required email,
          required accountRequestId,
          required verificationCode,
          required transaction,
        }) async => throw UnsupportedError('Invited accounts only'),
        sendPasswordResetVerificationCode: (
          session, {
          required email,
          required passwordResetRequestId,
          required verificationCode,
          required transaction,
        }) async => throw UnsupportedError('Operator-managed accounts'),
      ),
    ],
  );
  pod.webServer.addRoute(
    ApiBridge(
      pod.config.apiServer.port,
      (pod.config.allowedOrigins ?? []).toSet(),
    ),
  );
  readCatalogAssets();
  for (final entry in catalogBytes.entries) {
    pod.webServer.addRoute(
      ScoreBytesRoute(entry.value),
      '/score-bytes/${entry.key}.json.gz',
    );
  }
  final reviewOutput = Platform.environment['ROLLINGTAB_REVIEW_OUTPUT'];
  if (pod.runMode == 'development' && reviewOutput != null) {
    pod.webServer.addRoute(ReviewExportRoute(Directory(reviewOutput)));
  }
  if (File('web/site/index.html').existsSync()) {
    pod.webServer.addRoute(
      StaticRoute.file(
        File('web/site/index.html'),
        cacheControlFactory: StaticRoute.privateNoCache(),
      ),
    );
    pod.webServer.addRoute(
      StaticRoute.directory(Directory('web/site/site-assets')),
      '/site-assets',
    );
  }
  pod.webServer.addMiddleware(playSlashRedirect, '/play');
  if (Directory('web/app').existsSync()) {
    pod.webServer.addRoute(
      FlutterRoute(Directory('web/app'), enableWasmHeaders: true),
      '/play',
    );
  }
  return pod;
}

Future<void> run(List<String> args) async {
  final pod = createServer(args);
  await pod.start();
  final session = await pod.createSession(enableLogging: false);
  try {
    await importCatalog(session);
    await provisionAccounts(session, pod.getPassword('bootstrapAccounts'));
  } finally {
    await session.close();
  }
}
