/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class PassageInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PassageInput._({
    required this.passageId,
    required this.cid,
    required this.artifactVersion,
    required this.sourceSlot,
    required this.name,
    required this.start,
    required this.end,
    required this.tempo,
    required this.loop,
    required this.expectedRevision,
    required this.requestId,
  });

  factory PassageInput({
    required String passageId,
    required String cid,
    required String artifactVersion,
    required int sourceSlot,
    required String name,
    required double start,
    required double end,
    required double tempo,
    required bool loop,
    required int expectedRevision,
    required String requestId,
  }) = _PassageInputImpl;

  factory PassageInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return PassageInput(
      passageId: jsonSerialization['passageId'] as String,
      cid: jsonSerialization['cid'] as String,
      artifactVersion: jsonSerialization['artifactVersion'] as String,
      sourceSlot: jsonSerialization['sourceSlot'] as int,
      name: jsonSerialization['name'] as String,
      start: (jsonSerialization['start'] as num).toDouble(),
      end: (jsonSerialization['end'] as num).toDouble(),
      tempo: (jsonSerialization['tempo'] as num).toDouble(),
      loop: _is.BoolJsonExtension.fromJson(jsonSerialization['loop']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      requestId: jsonSerialization['requestId'] as String,
    );
  }

  String passageId;

  String cid;

  String artifactVersion;

  int sourceSlot;

  String name;

  double start;

  double end;

  double tempo;

  bool loop;

  int expectedRevision;

  String requestId;

  /// Returns a shallow copy of this [PassageInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PassageInput copyWith({
    String? passageId,
    String? cid,
    String? artifactVersion,
    int? sourceSlot,
    String? name,
    double? start,
    double? end,
    double? tempo,
    bool? loop,
    int? expectedRevision,
    String? requestId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PassageInput',
      'passageId': passageId,
      'cid': cid,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'name': name,
      'start': start,
      'end': end,
      'tempo': tempo,
      'loop': loop,
      'expectedRevision': expectedRevision,
      'requestId': requestId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PassageInput',
      'passageId': passageId,
      'cid': cid,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'name': name,
      'start': start,
      'end': end,
      'tempo': tempo,
      'loop': loop,
      'expectedRevision': expectedRevision,
      'requestId': requestId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PassageInputImpl extends PassageInput {
  _PassageInputImpl({
    required String passageId,
    required String cid,
    required String artifactVersion,
    required int sourceSlot,
    required String name,
    required double start,
    required double end,
    required double tempo,
    required bool loop,
    required int expectedRevision,
    required String requestId,
  }) : super._(
         passageId: passageId,
         cid: cid,
         artifactVersion: artifactVersion,
         sourceSlot: sourceSlot,
         name: name,
         start: start,
         end: end,
         tempo: tempo,
         loop: loop,
         expectedRevision: expectedRevision,
         requestId: requestId,
       );

  /// Returns a shallow copy of this [PassageInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PassageInput copyWith({
    String? passageId,
    String? cid,
    String? artifactVersion,
    int? sourceSlot,
    String? name,
    double? start,
    double? end,
    double? tempo,
    bool? loop,
    int? expectedRevision,
    String? requestId,
  }) {
    return PassageInput(
      passageId: passageId ?? this.passageId,
      cid: cid ?? this.cid,
      artifactVersion: artifactVersion ?? this.artifactVersion,
      sourceSlot: sourceSlot ?? this.sourceSlot,
      name: name ?? this.name,
      start: start ?? this.start,
      end: end ?? this.end,
      tempo: tempo ?? this.tempo,
      loop: loop ?? this.loop,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      requestId: requestId ?? this.requestId,
    );
  }
}
