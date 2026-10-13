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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class SavedPassage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SavedPassage._({
    this.id,
    required this.passageId,
    required this.owner,
    required this.cid,
    required this.artifactVersion,
    required this.sourceSlot,
    required this.name,
    required this.start,
    required this.end,
    required this.tempo,
    required this.loop,
    required this.revision,
    required this.requestId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedPassage({
    int? id,
    required String passageId,
    required _isc.UuidValue owner,
    required String cid,
    required String artifactVersion,
    required int sourceSlot,
    required String name,
    required double start,
    required double end,
    required double tempo,
    required bool loop,
    required int revision,
    required String requestId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavedPassageImpl;

  factory SavedPassage.fromJson(Map<String, dynamic> jsonSerialization) {
    return SavedPassage(
      id: jsonSerialization['id'] as int?,
      passageId: jsonSerialization['passageId'] as String,
      owner: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['owner']),
      cid: jsonSerialization['cid'] as String,
      artifactVersion: jsonSerialization['artifactVersion'] as String,
      sourceSlot: jsonSerialization['sourceSlot'] as int,
      name: jsonSerialization['name'] as String,
      start: (jsonSerialization['start'] as num).toDouble(),
      end: (jsonSerialization['end'] as num).toDouble(),
      tempo: (jsonSerialization['tempo'] as num).toDouble(),
      loop: _isc.BoolJsonExtension.fromJson(jsonSerialization['loop']),
      revision: jsonSerialization['revision'] as int,
      requestId: jsonSerialization['requestId'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String passageId;

  _isc.UuidValue owner;

  String cid;

  String artifactVersion;

  int sourceSlot;

  String name;

  double start;

  double end;

  double tempo;

  bool loop;

  int revision;

  String requestId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SavedPassage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SavedPassage copyWith({
    int? id,
    String? passageId,
    _isc.UuidValue? owner,
    String? cid,
    String? artifactVersion,
    int? sourceSlot,
    String? name,
    double? start,
    double? end,
    double? tempo,
    bool? loop,
    int? revision,
    String? requestId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SavedPassage',
      if (id != null) 'id': id,
      'passageId': passageId,
      'owner': owner.toJson(),
      'cid': cid,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'name': name,
      'start': start,
      'end': end,
      'tempo': tempo,
      'loop': loop,
      'revision': revision,
      'requestId': requestId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SavedPassage',
      if (id != null) 'id': id,
      'passageId': passageId,
      'owner': owner.toJson(),
      'cid': cid,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'name': name,
      'start': start,
      'end': end,
      'tempo': tempo,
      'loop': loop,
      'revision': revision,
      'requestId': requestId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SavedPassageImpl extends SavedPassage {
  _SavedPassageImpl({
    int? id,
    required String passageId,
    required _isc.UuidValue owner,
    required String cid,
    required String artifactVersion,
    required int sourceSlot,
    required String name,
    required double start,
    required double end,
    required double tempo,
    required bool loop,
    required int revision,
    required String requestId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         passageId: passageId,
         owner: owner,
         cid: cid,
         artifactVersion: artifactVersion,
         sourceSlot: sourceSlot,
         name: name,
         start: start,
         end: end,
         tempo: tempo,
         loop: loop,
         revision: revision,
         requestId: requestId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SavedPassage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SavedPassage copyWith({
    Object? id = _Undefined,
    String? passageId,
    _isc.UuidValue? owner,
    String? cid,
    String? artifactVersion,
    int? sourceSlot,
    String? name,
    double? start,
    double? end,
    double? tempo,
    bool? loop,
    int? revision,
    String? requestId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedPassage(
      id: id is int? ? id : this.id,
      passageId: passageId ?? this.passageId,
      owner: owner ?? this.owner,
      cid: cid ?? this.cid,
      artifactVersion: artifactVersion ?? this.artifactVersion,
      sourceSlot: sourceSlot ?? this.sourceSlot,
      name: name ?? this.name,
      start: start ?? this.start,
      end: end ?? this.end,
      tempo: tempo ?? this.tempo,
      loop: loop ?? this.loop,
      revision: revision ?? this.revision,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
