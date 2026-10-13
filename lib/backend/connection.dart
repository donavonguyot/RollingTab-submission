import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:rollingtab_client/rollingtab_client.dart' as api;

import '../model/music.dart';
import '../model/projection.dart';
import '../vendor/pdmx_document.dart';
import 'http_client.dart';

export 'package:rollingtab_client/rollingtab_client.dart'
    show CatalogScore, SavedPassage, PassageInput;

class BackendConfig {
  final String apiBase, webBase, cid, corpus;
  final int slot;
  const BackendConfig({
    this.apiBase = const String.fromEnvironment(
      'ROLLINGTAB_API_BASE',
      defaultValue: 'http://localhost:9893/',
    ),
    this.webBase = const String.fromEnvironment(
      'ROLLINGTAB_WEB_BASE',
      defaultValue: 'http://localhost:9895/',
    ),
    this.cid = const String.fromEnvironment(
      'ROLLINGTAB_SCORE_CID',
      defaultValue: 'QmcmrMSehjpEW3yzzstiCECCTxLNBapeRrnQKc7rrWCB26',
    ),
    this.corpus = '',
    this.slot = 1,
  });
  String get endpoint =>
      kIsWeb ? Uri.base.resolve('/api/').toString() : apiBase;
  Uri auth(String operation) => Uri.parse(endpoint).resolve(operation);
}

class BackendFailure implements Exception {
  final String message;
  final int? status;
  const BackendFailure(this.message, [this.status]);
  @override
  String toString() => message;
}

class _MemoryKey implements ClientAuthKeyProvider {
  final String? Function() token;
  _MemoryKey(this.token);
  @override
  Future<String?> get authHeaderValue async =>
      token() == null ? null : 'Bearer ${token()}';
}

class BackendConnection extends ChangeNotifier {
  final BackendConfig config;
  final http.Client client, bytesClient;
  late final api.Client apiClient;
  AuthSuccess? _session;
  Future<void>? _refreshing;
  int _epoch = 0;
  int _scoreEpoch = 0;
  Map<String, dynamic>? receipt;
  api.CatalogScore? artifact;
  BackendConnection({
    this.config = const BackendConfig(),
    http.Client? client,
    http.Client? bytesClient,
  }) : client = client ?? sessionClient(),
       bytesClient = bytesClient ?? http.Client() {
    apiClient = api.Client(config.endpoint, httpClientOverride: this.client);
    apiClient.cookieAuth = kIsWeb;
    apiClient.authKeyProvider = _MemoryKey(() => _session?.token);
  }
  bool get signedIn => _session != null;
  int get accountEpoch => _epoch;
  Future<dynamic> _auth(
    String operation,
    Map<String, dynamic> payload, {
    bool authorize = false,
  }) async {
    final http.Response response;
    try {
      response = await client
          .post(
            config.auth(operation),
            headers: {
              'content-type': 'application/json',
              if (kIsWeb) 'x-serverpod-auth-mode': 'cookie',
              if (authorize && _session != null)
                'authorization': 'Bearer ${_session!.token}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const BackendFailure(
        'Cannot reach RollingTAB. Check your connection and try again.',
      );
    }
    if (response.statusCode != 200) {
      Map<String, dynamic> error = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final detail = decoded['data'];
          error = Map<String, dynamic>.from(detail is Map ? detail : decoded);
        }
      } catch (_) {}
      final reason = error['reason'];
      final message = switch (reason) {
        'invalidCredentials' => 'Email or password is incorrect.',
        'tooManyAttempts' =>
          'Too many attempts. Wait before trying again, or request a new code.',
        'expired' => 'This code has expired. Request a new code.',
        'policyViolation' =>
          'Use at least 8 characters with no spaces at the beginning or end.',
        'invalid' => 'This code or request is invalid. Check the code or request a new one.',
        _ =>
          error['__className__'] == 'BackendError' && error['message'] is String
              ? error['message'] as String
              : response.statusCode == 401
              ? 'Sign in again to save passages.'
              : 'Authentication could not be completed. Please try again.',
      };
      throw BackendFailure(message, response.statusCode);
    }
    if (response.body.isEmpty || response.body == 'null') return {};
    final value = jsonDecode(response.body);
    return value;
  }

  Future<void> login(String email, String password) async {
    if (signedIn) await signOut();
    final epoch = ++_epoch;
    final data = await _auth('emailIdp/login', {
      'email': email.trim(),
      'password': password,
    });
    if (epoch != _epoch) return;
    _session = AuthSuccess.fromJson(data);
    notifyListeners();
  }

  Future<bool> selfServiceEnabled() async {
    try {
      return await _auth('emailIdp/selfServiceEnabled', {}) == true;
    } catch (_) {
      return false;
    }
  }

  Future<String> startEmailFlow(String email, {required bool reset}) async =>
      await _auth(
        'emailIdp/${reset ? 'startPasswordReset' : 'startRegistration'}',
        {'email': email.trim().toLowerCase()},
      ) as String;

  Future<String> verifyEmailCode(
    String requestId,
    String code, {
    required bool reset,
  }) async => await _auth(
    'emailIdp/${reset ? 'verifyPasswordResetCode' : 'verifyRegistrationCode'}',
    {
      reset ? 'passwordResetRequestId' : 'accountRequestId': requestId,
      'verificationCode': code.trim().toLowerCase(),
    },
  ) as String;

  Future<void> finishEmailFlow(
    String token,
    String password, {
    required bool reset,
  }) async {
    if (reset) {
      await _auth('emailIdp/finishPasswordReset', {
        'finishPasswordResetToken': token,
        'newPassword': password,
      });
      _epoch++;
      _session = null;
      notifyListeners();
    } else {
      final epoch = ++_epoch;
      final data = await _auth('emailIdp/finishRegistration', {
        'registrationToken': token,
        'password': password,
      });
      if (epoch != _epoch) return;
      _session = AuthSuccess.fromJson(Map<String, dynamic>.from(data as Map));
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (!kIsWeb) return;
    try {
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  Future<void> _doRefresh() async {
    final epoch = _epoch;
    try {
      if (!kIsWeb && _session == null) {
        throw const BackendFailure('Sign in first.');
      }
      final data = await _auth('jwtRefresh/refreshAccessToken', {
        'refreshToken': kIsWeb ? null : _session?.refreshToken,
      });
      if (epoch != _epoch) throw const BackendFailure('Account changed.');
      _session = AuthSuccess.fromJson(data);
      notifyListeners();
    } catch (e) {
      if (epoch == _epoch) {
        _session = null;
        _epoch++;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_session != null) {
      await _auth(
        'serverpod_auth_core.status/signOutDevice',
        {},
        authorize: true,
      );
    }
    _epoch++;
    _session = null;
    notifyListeners();
  }

  Future<T> _private<T>(Future<T> Function() call) async {
    if (!signedIn) throw const BackendFailure('Sign in to save passages.');
    if (_session!.tokenExpiresAt?.isBefore(
          DateTime.now().add(const Duration(seconds: 45)),
        ) ??
        false) {
      await refresh();
    }
    final epoch = _epoch;
    try {
      final result = await call();
      if (epoch != _epoch) {
        throw const BackendFailure('Account changed during the request.');
      }
      return result;
    } on api.BackendError catch (e) {
      throw BackendFailure(e.message);
    } on ServerpodClientUnauthorized {
      if (epoch == _epoch) {
        _session = null;
        _epoch++;
        notifyListeners();
      }
      throw const BackendFailure('Session expired. Sign in again.', 401);
    }
  }

  Future<List<api.SavedPassage>> passages() =>
      _private(() => apiClient.passages.list());
  Future<api.SavedPassage> save(api.PassageInput input) =>
      _private(() => apiClient.passages.save(input));
  Future<void> delete(api.SavedPassage p) =>
      _private(() => apiClient.passages.delete(p.passageId, p.revision));

  Future<List<api.CatalogScore>> catalog() => apiClient.catalog.list();
  void cancelScoreLoad() {
    _scoreEpoch++;
  }

  Future<TabScore> loadScore({String? cid}) async {
    final epoch = ++_scoreEpoch;
    receipt = null;
    final api.CatalogScore descriptor;
    try {
      descriptor = await apiClient.catalog.getArtifact(cid ?? config.cid);
    } on api.BackendError catch (e) {
      throw BackendFailure(e.message);
    } on ServerpodClientException catch (e) {
      throw BackendFailure('Score metadata unavailable: $e');
    }
    final web = kIsWeb ? Uri.base : Uri.parse(config.webBase);
    if (descriptor.cid != (cid ?? config.cid) ||
        descriptor.sourceSlot < 0 ||
        descriptor.downloadPath !=
            '/score-bytes/${descriptor.compressedSha256}.json.gz') {
      throw const BackendFailure('Invalid score identity.');
    }
    final metadata = <String, dynamic>{
      'contract_version': 'rolling-note-pdmx-artifact-v1',
      'logical_document': {
        'relpath': 'scores/${descriptor.cid}.json',
        'byte_size': descriptor.logicalBytes,
        'sha256': descriptor.logicalSha256,
      },
      'artifact': {
        'relpath': descriptor.downloadPath,
        'compression': 'gzip',
        'byte_size': descriptor.compressedBytes,
        'sha256': descriptor.compressedSha256,
        'url': web.resolve(descriptor.downloadPath).toString(),
      },
      'cache': {
        'key': descriptor.downloadPath,
        'byte_unit': 'compressed_bytes',
      },
    };
    validateDescriptor(metadata, descriptor.cid, descriptor.artifactVersion);
    final response = await bytesClient
        .get(web.resolve(descriptor.downloadPath))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw BackendFailure(
        'Score bytes unavailable (${response.statusCode}).',
        response.statusCode,
      );
    }
    final score = decodeArtifact(
      metadata,
      response.bodyBytes,
      cid: descriptor.cid,
      slot: descriptor.sourceSlot,
      corpus: descriptor.artifactVersion,
    );
    if (epoch != _scoreEpoch) {
      throw const BackendFailure('Score changed during loading.');
    }
    artifact = descriptor;
    receipt = {
      'source': 'RollingTAB Serverpod metadata + downloaded gzip',
      'cid': descriptor.cid,
      'artifactVersion': descriptor.artifactVersion,
      'compressedSha256': sha256.convert(response.bodyBytes).toString(),
      'compressedBytes': response.bodyBytes.length,
      'sourceSlot': descriptor.sourceSlot,
      'fetchedAt': DateTime.now().toUtc().toIso8601String(),
    };
    return score;
  }

  @override
  void dispose() {
    apiClient.close();
    bytesClient.close();
    super.dispose();
  }
}

void validateDescriptor(
  Map<String, dynamic> metadata,
  String cid,
  String corpus,
) {
  final a = metadata['artifact'],
      logical = metadata['logical_document'],
      cache = metadata['cache'];
  if (metadata['contract_version'] != 'rolling-note-pdmx-artifact-v1' ||
      a is! Map ||
      logical is! Map ||
      cache is! Map ||
      !(logical['relpath'] is String &&
          (logical['relpath'] as String).split('/').last == '$cid.json') ||
      a['compression'] != 'gzip' ||
      a['byte_size'] is! int ||
      a['byte_size'] <= 0 ||
      a['byte_size'] > 32 * 1024 * 1024 ||
      a['sha256'] is! String ||
      !RegExp(r'^[a-f0-9]{64}$').hasMatch(a['sha256']) ||
      a['url'] is! String ||
      cache['key'] != a['relpath'] ||
      cache['byte_unit'] != 'compressed_bytes' ||
      logical['byte_size'] is! int ||
      logical['byte_size'] > 64 * 1024 * 1024) {
    throw const BackendFailure('Invalid score artifact identity or metadata.');
  }
}

TabScore decodeArtifact(
  Map<String, dynamic> metadata,
  Uint8List bytes, {
  required String cid,
  required int slot,
  String corpus = '',
}) {
  validateDescriptor(metadata, cid, corpus);
  final a = metadata['artifact'] as Map;
  if (bytes.length != a['byte_size'] ||
      sha256.convert(bytes).toString() != a['sha256']) {
    throw const BackendFailure('Score checksum or byte size does not match.');
  }
  try {
    final decoded = GZipDecoder().decodeBytes(bytes);
    final logical = metadata['logical_document'] as Map?;
    if (logical != null &&
        (decoded.length != logical['byte_size'] ||
            sha256.convert(decoded).toString() != logical['sha256'])) {
      throw const BackendFailure('Decoded score checksum does not match.');
    }
    final document = PdmxDocument.fromJson(
      jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>,
    );
    return scoreFromDocument(
      document,
      cid: cid,
      slot: slot,
      provenance: {
        'cid': cid,
        'corpusVersion': corpus.isEmpty ? 'latest requested' : corpus,
        'compressedSha256': a['sha256'],
      },
    );
  } on BackendFailure {
    rethrow;
  } catch (e) {
    throw BackendFailure('Cannot decode guitar score: $e');
  }
}
