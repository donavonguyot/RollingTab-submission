import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rollingtab/backend/connection.dart';
import 'package:rollingtab/widgets/auth_dialog.dart';

import 'backend_test.dart' show auth;

void main() {
  test('client handles scalar challenges and safe auth errors', () async {
    final b = BackendConnection(
      client: MockClient((r) async {
        if (r.url.path.endsWith('selfServiceEnabled')) {
          return http.Response('true', 200);
        }
        if (r.url.path.endsWith('startRegistration')) {
          expect(jsonDecode(r.body)['email'], 'user@example.com');
          return http.Response('"request-id"', 200);
        }
        return http.Response(
          '{"className":"BackendError","data":{"__className__":"BackendError","message":"Please wait","code":"email_rate_limited"}}',
          400,
        );
      }),
    );
    addTearDown(b.dispose);
    expect(await b.selfServiceEnabled(), true);
    expect(
      await b.startEmailFlow(' USER@example.com ', reset: false),
      'request-id',
    );
    await expectLater(
      b.verifyEmailCode('request-id', 'bad', reset: false),
      throwsA(
        isA<BackendFailure>().having(
          (e) => e.message,
          'message',
          'Please wait',
        ),
      ),
    );
  });
  testWidgets(
    'signup verifies code, validates passwords and establishes session',
    (tester) async {
      final calls = <String>[];
      final b = BackendConnection(
        client: MockClient((r) async {
          calls.add(r.url.path);
          final result = switch (r.url.path.split('/').last) {
            'selfServiceEnabled' => true,
            'startRegistration' => 'request-id',
            'verifyRegistrationCode' => 'completion-token',
            'finishRegistration' => auth(),
            _ => null,
          };
          return http.Response(jsonEncode(result), 200);
        }),
      );
      addTearDown(b.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AuthDialog(backend: b),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Resend code in'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'abc12345');
      await tester.tap(find.text('Verify code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'valid-password');
      await tester.enterText(find.byType(TextField).at(1), 'mismatch');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(calls.any((p) => p.endsWith('finishRegistration')), false);
      await tester.enterText(find.byType(TextField).at(1), 'valid-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(b.signedIn, true);
      expect(find.byType(AuthDialog), findsNothing);
    },
  );
  testWidgets('reset returns to sign-in with email preserved', (tester) async {
    final b = BackendConnection(
      client: MockClient((r) async {
        return http.Response(
          jsonEncode(switch (r.url.path.split('/').last) {
            'selfServiceEnabled' => true,
            'startPasswordReset' => 'reset-request',
            'verifyPasswordResetCode' => 'reset-token',
            _ => null,
          }),
          200,
        );
      }),
    );
    addTearDown(b.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AuthDialog(backend: b)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'abc12345');
    await tester.tap(find.text('Verify code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'new-password');
    await tester.enterText(find.byType(TextField).at(1), 'new-password');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();
    expect(
      find.text('Password updated. Sign in with your new password.'),
      findsOneWidget,
    );
    expect(find.text('user@example.com'), findsOneWidget);
    expect(b.signedIn, false);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('disabled self service preserves existing sign-in', (
    tester,
  ) async {
    final b = BackendConnection(
      client: MockClient((_) async => http.Response('false', 200)),
    );
    addTearDown(b.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AuthDialog(backend: b)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsNothing);
    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
