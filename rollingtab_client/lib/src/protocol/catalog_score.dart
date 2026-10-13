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

abstract class CatalogScore
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CatalogScore._({
    this.id,
    required this.cid,
    required this.title,
    required this.composer,
    required this.artifactVersion,
    required this.sourceSlot,
    required this.duration,
    required this.license,
    required this.licenseUrl,
    required this.compressedSha256,
    required this.compressedBytes,
    required this.logicalSha256,
    required this.logicalBytes,
    required this.downloadPath,
    this.recommendedStart,
    this.recommendedEnd,
    this.practiceFocus,
    this.guidanceDescription,
  });

  factory CatalogScore({
    int? id,
    required String cid,
    required String title,
    required String composer,
    required String artifactVersion,
    required int sourceSlot,
    required double duration,
    required String license,
    required String licenseUrl,
    required String compressedSha256,
    required int compressedBytes,
    required String logicalSha256,
    required int logicalBytes,
    required String downloadPath,
    double? recommendedStart,
    double? recommendedEnd,
    String? practiceFocus,
    String? guidanceDescription,
  }) = _CatalogScoreImpl;

  factory CatalogScore.fromJson(Map<String, dynamic> jsonSerialization) {
    return CatalogScore(
      id: jsonSerialization['id'] as int?,
      cid: jsonSerialization['cid'] as String,
      title: jsonSerialization['title'] as String,
      composer: jsonSerialization['composer'] as String,
      artifactVersion: jsonSerialization['artifactVersion'] as String,
      sourceSlot: jsonSerialization['sourceSlot'] as int,
      duration: (jsonSerialization['duration'] as num).toDouble(),
      license: jsonSerialization['license'] as String,
      licenseUrl: jsonSerialization['licenseUrl'] as String,
      compressedSha256: jsonSerialization['compressedSha256'] as String,
      compressedBytes: jsonSerialization['compressedBytes'] as int,
      logicalSha256: jsonSerialization['logicalSha256'] as String,
      logicalBytes: jsonSerialization['logicalBytes'] as int,
      downloadPath: jsonSerialization['downloadPath'] as String,
      recommendedStart: (jsonSerialization['recommendedStart'] as num?)
          ?.toDouble(),
      recommendedEnd: (jsonSerialization['recommendedEnd'] as num?)?.toDouble(),
      practiceFocus: jsonSerialization['practiceFocus'] as String?,
      guidanceDescription: jsonSerialization['guidanceDescription'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cid;

  String title;

  String composer;

  String artifactVersion;

  int sourceSlot;

  double duration;

  String license;

  String licenseUrl;

  String compressedSha256;

  int compressedBytes;

  String logicalSha256;

  int logicalBytes;

  String downloadPath;

  double? recommendedStart;

  double? recommendedEnd;

  String? practiceFocus;

  String? guidanceDescription;

  /// Returns a shallow copy of this [CatalogScore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CatalogScore copyWith({
    int? id,
    String? cid,
    String? title,
    String? composer,
    String? artifactVersion,
    int? sourceSlot,
    double? duration,
    String? license,
    String? licenseUrl,
    String? compressedSha256,
    int? compressedBytes,
    String? logicalSha256,
    int? logicalBytes,
    String? downloadPath,
    double? recommendedStart,
    double? recommendedEnd,
    String? practiceFocus,
    String? guidanceDescription,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CatalogScore',
      if (id != null) 'id': id,
      'cid': cid,
      'title': title,
      'composer': composer,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'duration': duration,
      'license': license,
      'licenseUrl': licenseUrl,
      'compressedSha256': compressedSha256,
      'compressedBytes': compressedBytes,
      'logicalSha256': logicalSha256,
      'logicalBytes': logicalBytes,
      'downloadPath': downloadPath,
      if (recommendedStart != null) 'recommendedStart': recommendedStart,
      if (recommendedEnd != null) 'recommendedEnd': recommendedEnd,
      if (practiceFocus != null) 'practiceFocus': practiceFocus,
      if (guidanceDescription != null)
        'guidanceDescription': guidanceDescription,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CatalogScore',
      if (id != null) 'id': id,
      'cid': cid,
      'title': title,
      'composer': composer,
      'artifactVersion': artifactVersion,
      'sourceSlot': sourceSlot,
      'duration': duration,
      'license': license,
      'licenseUrl': licenseUrl,
      'compressedSha256': compressedSha256,
      'compressedBytes': compressedBytes,
      'logicalSha256': logicalSha256,
      'logicalBytes': logicalBytes,
      'downloadPath': downloadPath,
      if (recommendedStart != null) 'recommendedStart': recommendedStart,
      if (recommendedEnd != null) 'recommendedEnd': recommendedEnd,
      if (practiceFocus != null) 'practiceFocus': practiceFocus,
      if (guidanceDescription != null)
        'guidanceDescription': guidanceDescription,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CatalogScoreImpl extends CatalogScore {
  _CatalogScoreImpl({
    int? id,
    required String cid,
    required String title,
    required String composer,
    required String artifactVersion,
    required int sourceSlot,
    required double duration,
    required String license,
    required String licenseUrl,
    required String compressedSha256,
    required int compressedBytes,
    required String logicalSha256,
    required int logicalBytes,
    required String downloadPath,
    double? recommendedStart,
    double? recommendedEnd,
    String? practiceFocus,
    String? guidanceDescription,
  }) : super._(
         id: id,
         cid: cid,
         title: title,
         composer: composer,
         artifactVersion: artifactVersion,
         sourceSlot: sourceSlot,
         duration: duration,
         license: license,
         licenseUrl: licenseUrl,
         compressedSha256: compressedSha256,
         compressedBytes: compressedBytes,
         logicalSha256: logicalSha256,
         logicalBytes: logicalBytes,
         downloadPath: downloadPath,
         recommendedStart: recommendedStart,
         recommendedEnd: recommendedEnd,
         practiceFocus: practiceFocus,
         guidanceDescription: guidanceDescription,
       );

  /// Returns a shallow copy of this [CatalogScore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CatalogScore copyWith({
    Object? id = _Undefined,
    String? cid,
    String? title,
    String? composer,
    String? artifactVersion,
    int? sourceSlot,
    double? duration,
    String? license,
    String? licenseUrl,
    String? compressedSha256,
    int? compressedBytes,
    String? logicalSha256,
    int? logicalBytes,
    String? downloadPath,
    Object? recommendedStart = _Undefined,
    Object? recommendedEnd = _Undefined,
    Object? practiceFocus = _Undefined,
    Object? guidanceDescription = _Undefined,
  }) {
    return CatalogScore(
      id: id is int? ? id : this.id,
      cid: cid ?? this.cid,
      title: title ?? this.title,
      composer: composer ?? this.composer,
      artifactVersion: artifactVersion ?? this.artifactVersion,
      sourceSlot: sourceSlot ?? this.sourceSlot,
      duration: duration ?? this.duration,
      license: license ?? this.license,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      compressedSha256: compressedSha256 ?? this.compressedSha256,
      compressedBytes: compressedBytes ?? this.compressedBytes,
      logicalSha256: logicalSha256 ?? this.logicalSha256,
      logicalBytes: logicalBytes ?? this.logicalBytes,
      downloadPath: downloadPath ?? this.downloadPath,
      recommendedStart: recommendedStart is double?
          ? recommendedStart
          : this.recommendedStart,
      recommendedEnd: recommendedEnd is double?
          ? recommendedEnd
          : this.recommendedEnd,
      practiceFocus: practiceFocus is String?
          ? practiceFocus
          : this.practiceFocus,
      guidanceDescription: guidanceDescription is String?
          ? guidanceDescription
          : this.guidanceDescription,
    );
  }
}
