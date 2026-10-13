import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/connection.dart';

enum _Flow { signIn, signup, reset }

enum _Step { email, code, password }

class AuthDialog extends StatefulWidget {
  final BackendConnection backend;
  const AuthDialog({super.key, required this.backend});
  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final email = TextEditingController(),
      password = TextEditingController(),
      code = TextEditingController(),
      confirm = TextEditingController();
  _Flow flow = _Flow.signIn;
  _Step step = _Step.email;
  bool busy = false, enabled = false;
  String? error, notice, requestId, token;
  DateTime? resendAt;
  Timer? timer;
  bool get reset => flow == _Flow.reset;
  int get remaining => resendAt == null
      ? 0
      : resendAt!.difference(DateTime.now()).inSeconds.clamp(0, 60);

  @override
  void initState() {
    super.initState();
    widget.backend.selfServiceEnabled().then((value) {
      if (mounted) setState(() => enabled = value);
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && resendAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in [email, password, code, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void switchFlow(_Flow value) => setState(() {
    flow = value;
    step = _Step.email;
    error = null;
    notice = null;
    requestId = null;
    token = null;
    password.clear();
    confirm.clear();
    code.clear();
  });

  Future<void> sendCode() async {
    if (remaining > 0) {
      throw const BackendFailure(
        'Wait a minute before requesting another email.',
      );
    }
    requestId = await widget.backend.startEmailFlow(email.text, reset: reset);
    token = null;
    code.clear();
    resendAt = DateTime.now().add(const Duration(seconds: 61));
    step = _Step.code;
    notice = reset
        ? 'If an account exists for this email, we sent a code. Check your inbox and spam folder.'
        : 'Check your inbox and spam folder for a code. If you already have an account, sign in or reset your password.';
  }

  Future<void> work(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        error = e is BackendFailure
            ? e.message
            : 'Something went wrong. Please try again.';
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() => work(() async {
    if (flow == _Flow.signIn) {
      await widget.backend.login(email.text, password.text);
      if (mounted) Navigator.pop(context);
    } else if (step == _Step.email) {
      await sendCode();
    } else if (step == _Step.code) {
      token = await widget.backend.verifyEmailCode(
        requestId!,
        code.text,
        reset: reset,
      );
      step = _Step.password;
      notice = null;
    } else {
      if (password.text.length < 8 || password.text.trim() != password.text) {
        throw const BackendFailure(
          'Use at least 8 characters with no spaces at the beginning or end.',
        );
      }
      if (password.text != confirm.text) {
        throw const BackendFailure('Passwords do not match.');
      }
      await widget.backend.finishEmailFlow(token!, password.text, reset: reset);
      if (!mounted) return;
      if (reset) {
        switchFlow(_Flow.signIn);
        notice = 'Password updated. Sign in with your new password.';
      } else {
        Navigator.pop(context);
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    final title = flow == _Flow.signIn
        ? 'Sign in to RollingTAB'
        : reset
        ? 'Reset password'
        : 'Create account';
    final label = flow == _Flow.signIn
        ? 'Sign in'
        : step == _Step.email
        ? 'Send code'
        : step == _Step.code
        ? 'Verify code'
        : reset
        ? 'Update password'
        : 'Create account';
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Playing does not require an account. Sign in to save your passages.',
                ),
                const SizedBox(height: 16),
                if (flow == _Flow.signIn || step == _Step.email)
                  TextField(
                    controller: email,
                    enabled: !busy,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                  )
                else
                  Text(email.text.trim()),
                if (flow == _Flow.signIn || step == _Step.password) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    enabled: !busy,
                    obscureText: true,
                    autofillHints: [
                      flow == _Flow.signIn
                          ? AutofillHints.password
                          : AutofillHints.newPassword,
                    ],
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSubmitted: (_) {
                      if (!busy) submit();
                    },
                  ),
                  if (flow != _Flow.signIn) ...[
                    const Text(
                      'At least 8 characters; no leading or trailing spaces.',
                    ),
                    TextField(
                      controller: confirm,
                      enabled: !busy,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                    ),
                  ],
                ],
                if (step == _Step.code) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: code,
                    enabled: !busy,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                    ),
                    onSubmitted: (_) {
                      if (!busy) submit();
                    },
                  ),
                  const Text(
                    'Codes expire after 15 minutes. Three attempts are allowed.',
                  ),
                ],
                if (flow != _Flow.signIn && step != _Step.email) ...[
                  TextButton(
                    onPressed: busy || remaining > 0
                        ? null
                        : () => work(sendCode),
                    child: Text(
                      remaining > 0
                          ? 'Resend code in ${remaining}s'
                          : 'Resend code',
                    ),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => switchFlow(flow),
                    child: const Text('Change email'),
                  ),
                ],
                if (notice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(notice!),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (busy)
                  const LinearProgressIndicator(semanticsLabel: 'Connecting'),
                if (flow == _Flow.signIn && enabled) ...[
                  TextButton(
                    onPressed: busy ? null : () => switchFlow(_Flow.signup),
                    child: const Text('Create account'),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => switchFlow(_Flow.reset),
                    child: const Text('Forgot password?'),
                  ),
                ],
                if (flow != _Flow.signIn)
                  TextButton(
                    onPressed: busy ? null : () => switchFlow(_Flow.signIn),
                    child: const Text('Back to sign in'),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: busy ? null : submit, child: Text(label)),
        ],
      ),
    );
  }
}
