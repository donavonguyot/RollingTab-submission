import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:rollingtab_server/src/auth/auth_email.dart';
import 'package:rollingtab_server/src/generated/protocol.dart';

void main() {
  test(
    'Resend includes both bodies, scoped sender and stable retry key',
    () async {
      final requests = <http.Request>[];
      final sender = ResendAuthEmailSender(
        apiKey: 'test-key',
        from: 'RollingTAB <noreply@mail.rollingtab.com>',
        client: MockClient((r) async {
          requests.add(r);
          return http.Response('{}', requests.length == 1 ? 503 : 200);
        }),
      );
      await sender.send(
        email: 'test@example.com',
        requestId: 'request-1',
        code: 'abc12345',
        passwordReset: false,
      );
      expect(requests.length, 2);
      expect(requests.first.body, requests.last.body);
      expect(
        requests.first.headers['Idempotency-Key'],
        requests.last.headers['Idempotency-Key'],
      );
      final data = jsonDecode(requests.first.body);
      expect(data['text'], contains('abc12345'));
      expect(data['html'], contains('abc12345'));
      expect(data['subject'], 'Verify your RollingTAB email');
    },
  );
  test('Provider rejection is sanitized and not retried', () async {
    var count = 0;
    final sender = ResendAuthEmailSender(
      apiKey: 'test',
      from: 'sender',
      client: MockClient((_) async {
        count++;
        return http.Response('secret provider details', 403);
      }),
    );
    await expectLater(
      sender.send(
        email: 'test@example.com',
        requestId: 'r',
        code: 'secret',
        passwordReset: true,
      ),
      throwsA(
        isA<BackendError>().having(
          (e) => e.message,
          'message',
          isNot(contains('secret')),
        ),
      ),
    );
    expect(count, 1);
  });
  test('Timeout retries are bounded', () async {
    var count = 0;
    final sender = ResendAuthEmailSender(
      apiKey: 'test',
      from: 'sender',
      timeout: const Duration(milliseconds: 1),
      client: MockClient((_) async {
        count++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return http.Response('{}', 200);
      }),
    );
    await expectLater(
      sender.send(
        email: 'test@example.com',
        requestId: 'r',
        code: 'secret',
        passwordReset: true,
      ),
      throwsA(isA<BackendError>()),
    );
    expect(count, 2);
  });
}
