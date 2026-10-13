import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Invited accounts only. Registration and reset methods are not exposed.
class EmailIdpEndpoint extends Endpoint {
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) => AuthServices.instance.emailIdp.login(
    session,
    email: email,
    password: password,
  );
}
