import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'generated/protocol.dart';

/// Operator-only secret. Never exposed as an endpoint or written to logs.
Future<void> provisionAccounts(Session session, String? secret) async {
  if (secret == null || secret.isEmpty) return;
  final entries = (jsonDecode(secret) as List).cast<Map<String, dynamic>>();
  await session.db.transaction((tx) async {
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(9893002)',
      transaction: tx,
    );
    for (final entry in entries) {
      final email = (entry['email'] as String).trim().toLowerCase();
      final password = entry['password'] as String;
      if (!email.contains('@') || password.length < 16) {
        throw StateError('Invalid bootstrap account');
      }
      final old = await ProvisionedAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(email),
        transaction: tx,
      );
      if (old != null) continue;
      final user = await AuthServices.instance.authUsers.create(
        session,
        transaction: tx,
      );
      await AuthServices.instance.emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: user.id,
        email: email,
        password: password,
        transaction: tx,
      );
      await ProvisionedAccount.db.insertRow(
        session,
        ProvisionedAccount(email: email, authUserId: user.id),
        transaction: tx,
      );
    }
  });
}
