import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'auth_email.dart';

/// Explicit public surface; all credentials and challenges remain Serverpod-owned.
class EmailIdpEndpoint extends Endpoint {
  Future<bool> selfServiceEnabled(Session session) async =>
      SelfServiceAuth.enabled;

  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) => AuthServices.instance.emailIdp.login(
    session,
    email: email.trim().toLowerCase(),
    password: password,
  );

  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    email = email.trim().toLowerCase();
    await SelfServiceAuth.reserveEmail(session, email);
    return AuthServices.instance.emailIdp.startRegistration(
      session,
      email: email,
    );
  }

  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    SelfServiceAuth.requireEnabled();
    return AuthServices.instance.emailIdp.verifyRegistrationCode(
      session,
      accountRequestId: accountRequestId,
      verificationCode: verificationCode.trim().toLowerCase(),
    );
  }

  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String password,
  }) {
    SelfServiceAuth.requireEnabled();
    return AuthServices.instance.emailIdp.finishRegistration(
      session,
      registrationToken: registrationToken,
      password: password,
    );
  }

  Future<UuidValue> startPasswordReset(
    Session session, {
    required String email,
  }) async {
    email = email.trim().toLowerCase();
    await SelfServiceAuth.reserveEmail(session, email);
    return AuthServices.instance.emailIdp.startPasswordReset(
      session,
      email: email,
    );
  }

  Future<String> verifyPasswordResetCode(
    Session session, {
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) {
    SelfServiceAuth.requireEnabled();
    return AuthServices.instance.emailIdp.verifyPasswordResetCode(
      session,
      passwordResetRequestId: passwordResetRequestId,
      verificationCode: verificationCode.trim().toLowerCase(),
    );
  }

  Future<void> finishPasswordReset(
    Session session, {
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    SelfServiceAuth.requireEnabled();
    await AuthServices.instance.emailIdp.finishPasswordReset(
      session,
      finishPasswordResetToken: finishPasswordResetToken,
      newPassword: newPassword,
    );
  }
}
