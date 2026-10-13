import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/serverpod.dart';
import 'src/catalog.dart';
import 'src/bootstrap.dart';
import 'src/auth/auth_email.dart';
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
  SelfServiceAuth.enabled =
      Platform.environment['ROLLINGTAB_SELF_SERVICE_AUTH_ENABLED'] == 'true';
  SelfServiceAuth.pepper = pod.getPassword('emailSecretHashPepper')!;
  SelfServiceAuth.sender = null;
  if (SelfServiceAuth.enabled) {
    final key = pod.getPassword('resendApiKey');
    final from = Platform.environment['ROLLINGTAB_EMAIL_FROM'];
    if (key == null || key.isEmpty || from == null || from.isEmpty) {
      throw StateError(
        'Self-service auth requires resendApiKey and ROLLINGTAB_EMAIL_FROM.',
      );
    }
    SelfServiceAuth.sender = ResendAuthEmailSender(apiKey: key, from: from);
  }
  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      EmailIdpConfig(
        secretHashPepper: pod.getPassword('emailSecretHashPepper')!,
        sendRegistrationVerificationCode:
            (
              session, {
              required email,
              required accountRequestId,
              required verificationCode,
              required transaction,
            }) => SelfServiceAuth.deliver(
              session,
              email: email,
              requestId: accountRequestId.toString(),
              code: verificationCode,
              passwordReset: false,
            ),
        sendPasswordResetVerificationCode:
            (
              session, {
              required email,
              required passwordResetRequestId,
              required verificationCode,
              required transaction,
            }) => SelfServiceAuth.deliver(
              session,
              email: email,
              requestId: passwordResetRequestId.toString(),
              code: verificationCode,
              passwordReset: true,
            ),
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
