import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:rollingtab_server/src/auth/auth_email.dart';
import 'package:rollingtab_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

class Inbox implements AuthEmailSender {
  final codes = <String, String>{};
  bool fail = false;
  @override
  Future<void> send({
    required String email,
    required String requestId,
    required String code,
    required bool passwordReset,
  }) async {
    if (fail) throw StateError('provider failed');
    codes[requestId] = code;
  }
}

void main() {
  withServerpod('Self-service accounts', (builder, endpoints) {
    late Inbox inbox;
    setUp(() async {
      inbox = Inbox();
      SelfServiceAuth.enabled = true;
      SelfServiceAuth.sender = inbox;
      SelfServiceAuth.pepper = 'test-pepper';
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [
          EmailIdpConfig(
            secretHashPepper: 'test-pepper',
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
      await AuthEmailAttempt.db.deleteWhere(
        builder.build(),
        where: (t) => Constant.bool(true),
      );
    });
    Future<void> clearBudget() => AuthEmailAttempt.db
        .deleteWhere(builder.build(), where: (t) => Constant.bool(true))
        .then((_) {});
    Future<AuthSuccess> signup(String email) async {
      final id = await endpoints.emailIdp.startRegistration(
        builder,
        email: email,
      );
      final token = await endpoints.emailIdp.verifyRegistrationCode(
        builder,
        accountRequestId: id,
        verificationCode: inbox.codes[id.toString()]!,
      );
      return endpoints.emailIdp.finishRegistration(
        builder,
        registrationToken: token,
        password: 'test-password-123',
      );
    }

    test(
      'signup, generic duplicate, reset, old password and refresh rejection',
      () async {
        const email = 'first@example.com';
        final account = await signup(email);
        expect(account.authUserId, isNotNull);
        await clearBudget();
        final duplicate = await endpoints.emailIdp.startRegistration(
          builder,
          email: email,
        );
        expect(inbox.codes.containsKey(duplicate.toString()), false);
        await clearBudget();
        final id = await endpoints.emailIdp.startPasswordReset(
          builder,
          email: email,
        );
        final token = await endpoints.emailIdp.verifyPasswordResetCode(
          builder,
          passwordResetRequestId: id,
          verificationCode: inbox.codes[id.toString()]!,
        );
        await endpoints.emailIdp.finishPasswordReset(
          builder,
          finishPasswordResetToken: token,
          newPassword: 'new-password-456',
        );
        await expectLater(
          endpoints.emailIdp.login(
            builder,
            email: email,
            password: 'test-password-123',
          ),
          throwsA(isA<EmailAccountLoginException>()),
        );
        final restored = await endpoints.emailIdp.login(
          builder,
          email: email,
          password: 'new-password-456',
        );
        expect(restored.authUserId, account.authUserId);
        await expectLater(
          endpoints.jwtRefresh.refreshAccessToken(
            builder,
            refreshToken: account.refreshToken,
          ),
          throwsA(anything),
        );
        await expectLater(
          endpoints.emailIdp.finishPasswordReset(
            builder,
            finishPasswordResetToken: token,
            newPassword: 'another-password',
          ),
          throwsA(anything),
        );
      },
    );
    test(
      'unverified, exhausted and superseded challenges cannot create accounts',
      () async {
        const email = 'challenge@example.com';
        final id = await endpoints.emailIdp.startRegistration(
          builder,
          email: email,
        );
        for (var i = 0; i < 3; i++) {
          await expectLater(
            endpoints.emailIdp.verifyRegistrationCode(
              builder,
              accountRequestId: id,
              verificationCode: 'wrong',
            ),
            throwsA(anything),
          );
        }
        await expectLater(
          endpoints.emailIdp.verifyRegistrationCode(
            builder,
            accountRequestId: id,
            verificationCode: inbox.codes[id.toString()]!,
          ),
          throwsA(anything),
        );
        await clearBudget();
        final next = await endpoints.emailIdp.startRegistration(
          builder,
          email: email,
        );
        await expectLater(
          endpoints.emailIdp.verifyRegistrationCode(
            builder,
            accountRequestId: id,
            verificationCode: inbox.codes[id.toString()]!,
          ),
          throwsA(anything),
        );
        final token = await endpoints.emailIdp.verifyRegistrationCode(
          builder,
          accountRequestId: next,
          verificationCode: inbox.codes[next.toString()]!,
        );
        await expectLater(
          endpoints.emailIdp.finishRegistration(
            builder,
            registrationToken: token,
            password: 'short',
          ),
          throwsA(anything),
        );
        await endpoints.emailIdp.finishRegistration(
          builder,
          registrationToken: token,
          password: 'valid-password',
        );
        await expectLater(
          endpoints.emailIdp.finishRegistration(
            builder,
            registrationToken: token,
            password: 'valid-password',
          ),
          throwsA(anything),
        );
      },
    );
    test(
      'missing account reset sends nothing; disabled feature fails closed',
      () async {
        await endpoints.emailIdp.startPasswordReset(
          builder,
          email: 'missing@example.com',
        );
        expect(inbox.codes, isEmpty);
        SelfServiceAuth.enabled = false;
        expect(await endpoints.emailIdp.selfServiceEnabled(builder), false);
        await expectLater(
          endpoints.emailIdp.startRegistration(
            builder,
            email: 'disabled@example.com',
          ),
          throwsA(isA<BackendError>()),
        );
        await expectLater(
          endpoints.emailIdp.finishRegistration(
            builder,
            registrationToken: 'bad',
            password: 'valid-password',
          ),
          throwsA(isA<BackendError>()),
        );
      },
    );
    test(
      'failed delivery consumes budget; independent address works',
      () async {
        inbox.fail = true;
        await expectLater(
          endpoints.emailIdp.startRegistration(
            builder,
            email: 'failure@example.com',
          ),
          throwsA(isA<BackendError>()),
        );
        inbox.fail = false;
        await expectLater(
          endpoints.emailIdp.startRegistration(
            builder,
            email: 'failure@example.com',
          ),
          throwsA(
            isA<BackendError>().having(
              (e) => e.code,
              'code',
              'email_rate_limited',
            ),
          ),
        );
        await signup('independent@example.com');
      },
    );
    test('expired codes cannot complete registration', () async {
      final id = await endpoints.emailIdp.startRegistration(
        builder,
        email: 'expired@example.com',
      );
      final session = builder.build();
      final request = (await EmailAccountRequest.db.findById(session, id))!;
      request.createdAt = DateTime.now().toUtc().subtract(
        const Duration(minutes: 16),
      );
      await EmailAccountRequest.db.updateRow(session, request);
      await expectLater(
        endpoints.emailIdp.verifyRegistrationCode(
          builder,
          accountRequestId: id,
          verificationCode: inbox.codes[id.toString()]!,
        ),
        throwsA(anything),
      );
    });
    test('hourly and global limits survive cooldown and do not send', () async {
      final session = builder.build();
      for (var i = 0; i < 3; i++) {
        await SelfServiceAuth.reserveEmail(session, 'budget@example.com');
        final rows = await AuthEmailAttempt.db.find(session);
        for (final row in rows) {
          row.createdAt = DateTime.now().toUtc().subtract(
            Duration(minutes: 2 + i),
          );
          await AuthEmailAttempt.db.updateRow(session, row);
        }
      }
      await expectLater(
        SelfServiceAuth.reserveEmail(session, 'budget@example.com'),
        throwsA(isA<BackendError>()),
      );
      await clearBudget();
      for (var i = 0; i < 100; i++) {
        await AuthEmailAttempt.db.insertRow(
          session,
          AuthEmailAttempt(
            emailHash: 'hash-$i',
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
      await expectLater(
        SelfServiceAuth.reserveEmail(session, 'global@example.com'),
        throwsA(isA<BackendError>()),
      );
      expect(inbox.codes, isEmpty);
    });
    test('parallel sends share atomic cooldown', () async {
      final results = await Future.wait(
        List.generate(4, (_) async {
          try {
            await endpoints.emailIdp.startRegistration(
              builder,
              email: 'race@example.com',
            );
            return true;
          } on BackendError {
            return false;
          }
        }),
      );
      expect(results.where((r) => r).length, 1);
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
