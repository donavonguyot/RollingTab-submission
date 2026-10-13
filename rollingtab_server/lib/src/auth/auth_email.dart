import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Injectable delivery boundary. Production never writes codes to disk or logs.
abstract interface class AuthEmailSender {
  Future<void> send({
    required String email,
    required String requestId,
    required String code,
    required bool passwordReset,
  });
}

class ResendAuthEmailSender implements AuthEmailSender {
  final String apiKey, from;
  final http.Client client;
  final Duration timeout;
  ResendAuthEmailSender({
    required this.apiKey,
    required this.from,
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  }) : client = client ?? http.Client();

  @override
  Future<void> send({
    required String email,
    required String requestId,
    required String code,
    required bool passwordReset,
  }) async {
    final purpose = passwordReset
        ? 'Reset your RollingTAB password'
        : 'Verify your RollingTAB email';
    final text =
        '$purpose\n\nYour verification code is: $code\n\n'
        'Return to RollingTAB and enter this code within 15 minutes. '
        'If you did not request this email, you can ignore it.\n';
    final body = jsonEncode({
      'from': from,
      'to': [email],
      'subject': purpose,
      'text': text,
      'html':
          '<h1>$purpose</h1><p>Your verification code:</p>'
          '<p style="font-size:28px;letter-spacing:4px"><strong>${const HtmlEscape().convert(code)}</strong></p>'
          '<p>Return to RollingTAB and enter this code within 15 minutes.</p>'
          '<p>If you did not request this email, you can ignore it.</p>',
    });
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await client
            .post(
              Uri.parse('https://api.resend.com/emails'),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
                'Idempotency-Key':
                    'rollingtab/${passwordReset ? 'reset' : 'signup'}/$requestId',
              },
              body: body,
            )
            .timeout(timeout);
        if (response.statusCode >= 200 && response.statusCode < 300) return;
        if (response.statusCode >= 500 && attempt == 0) continue;
        break;
      } on Exception {
        if (attempt == 0) continue;
      }
    }
    throw BackendError(
      code: 'email_unavailable',
      message: 'We could not send the email. Please try again in a minute.',
    );
  }
}

/// Set once at startup; disabled by default. Tests may inject an in-memory sender.
class SelfServiceAuth {
  static bool enabled = false;
  static AuthEmailSender? sender;
  static String pepper = '';

  static void requireEnabled() {
    if (!enabled || sender == null) {
      throw BackendError(
        code: 'auth_disabled',
        message: 'Account creation and password recovery are temporarily unavailable.',
      );
    }
  }

  static Future<void> reserveEmail(Session session, String email) async {
    requireEnabled();
    if (email.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      throw BackendError(
        code: 'invalid_email',
        message: 'Enter a valid email address.',
      );
    }
    // Commit the reservation before sending. Failed deliveries also consume a slot.
    // One transaction lock makes both per-address and global budgets atomic.
    await session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        "SELECT pg_advisory_xact_lock(hashtextextended('rollingtab-auth-email', 0))",
        transaction: tx,
      );
      final now = DateTime.now().toUtc();
      final cutoff = now.subtract(const Duration(hours: 1));
      await AuthEmailAttempt.db.deleteWhere(
        session,
        where: (t) => t.createdAt < cutoff,
        transaction: tx,
      );
      final recent = await AuthEmailAttempt.db.find(session, transaction: tx);
      final hash = Hmac(
        sha256,
        utf8.encode(pepper),
      ).convert(utf8.encode(email)).toString();
      final mine = recent.where((a) => a.emailHash == hash).toList();
      if (recent.length >= 100 ||
          mine.length >= 3 ||
          mine.any(
            (a) =>
                a.createdAt.isAfter(now.subtract(const Duration(minutes: 1))),
          )) {
        throw BackendError(
          code: 'email_rate_limited',
          message: 'Too many email requests. Wait a minute before retrying; at most three are allowed per hour.',
        );
      }
      await AuthEmailAttempt.db.insertRow(
        session,
        AuthEmailAttempt(emailHash: hash, createdAt: now),
        transaction: tx,
      );
    });
  }

  static Future<void> deliver(
    Session session, {
    required String email,
    required String requestId,
    required String code,
    required bool passwordReset,
  }) async {
    requireEnabled();
    try {
      await sender!.send(
        email: email,
        requestId: requestId,
        code: code,
        passwordReset: passwordReset,
      );
      session.log('Authentication email accepted by provider.');
    } catch (_) {
      session.log(
        'Authentication email delivery failed.',
        level: LogLevel.warning,
      );
      throw BackendError(
        code: 'email_unavailable',
        message: 'We could not send the email. Please try again in a minute.',
      );
    }
  }
}
