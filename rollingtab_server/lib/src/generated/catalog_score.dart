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

abstract class CatalogScore
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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

  static final t = CatalogScoreTable();

  static const db = CatalogScoreRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CatalogScore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static CatalogScoreInclude include() {
    return CatalogScoreInclude._();
  }

  static CatalogScoreIncludeList includeList({
    _is.WhereExpressionBuilder<CatalogScoreTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    CatalogScoreInclude? include,
  }) {
    return CatalogScoreIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class CatalogScoreUpdateTable extends _is.UpdateTable<CatalogScoreTable> {
  CatalogScoreUpdateTable(super.table);

  _is.ColumnValue<String, String> cid(String value) => _is.ColumnValue(
    table.cid,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> composer(String value) => _is.ColumnValue(
    table.composer,
    value,
  );

  _is.ColumnValue<String, String> artifactVersion(String value) =>
      _is.ColumnValue(
        table.artifactVersion,
        value,
      );

  _is.ColumnValue<int, int> sourceSlot(int value) => _is.ColumnValue(
    table.sourceSlot,
    value,
  );

  _is.ColumnValue<double, double> duration(double value) => _is.ColumnValue(
    table.duration,
    value,
  );

  _is.ColumnValue<String, String> license(String value) => _is.ColumnValue(
    table.license,
    value,
  );

  _is.ColumnValue<String, String> licenseUrl(String value) => _is.ColumnValue(
    table.licenseUrl,
    value,
  );

  _is.ColumnValue<String, String> compressedSha256(String value) =>
      _is.ColumnValue(
        table.compressedSha256,
        value,
      );

  _is.ColumnValue<int, int> compressedBytes(int value) => _is.ColumnValue(
    table.compressedBytes,
    value,
  );

  _is.ColumnValue<String, String> logicalSha256(String value) =>
      _is.ColumnValue(
        table.logicalSha256,
        value,
      );

  _is.ColumnValue<int, int> logicalBytes(int value) => _is.ColumnValue(
    table.logicalBytes,
    value,
  );

  _is.ColumnValue<String, String> downloadPath(String value) => _is.ColumnValue(
    table.downloadPath,
    value,
  );

  _is.ColumnValue<double, double> recommendedStart(double? value) =>
      _is.ColumnValue(
        table.recommendedStart,
        value,
      );

  _is.ColumnValue<double, double> recommendedEnd(double? value) =>
      _is.ColumnValue(
        table.recommendedEnd,
        value,
      );

  _is.ColumnValue<String, String> practiceFocus(String? value) =>
      _is.ColumnValue(
        table.practiceFocus,
        value,
      );

  _is.ColumnValue<String, String> guidanceDescription(String? value) =>
      _is.ColumnValue(
        table.guidanceDescription,
        value,
      );
}

class CatalogScoreTable extends _is.Table<int?> {
  CatalogScoreTable({super.tableRelation})
    : super(tableName: 'rollingtab_catalog') {
    updateTable = CatalogScoreUpdateTable(this);
    cid = _is.ColumnString(
      'cid',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    composer = _is.ColumnString(
      'composer',
      this,
    );
    artifactVersion = _is.ColumnString(
      'artifactVersion',
      this,
    );
    sourceSlot = _is.ColumnInt(
      'sourceSlot',
      this,
    );
    duration = _is.ColumnDouble(
      'duration',
      this,
    );
    license = _is.ColumnString(
      'license',
      this,
    );
    licenseUrl = _is.ColumnString(
      'licenseUrl',
      this,
    );
    compressedSha256 = _is.ColumnString(
      'compressedSha256',
      this,
    );
    compressedBytes = _is.ColumnInt(
      'compressedBytes',
      this,
    );
    logicalSha256 = _is.ColumnString(
      'logicalSha256',
      this,
    );
    logicalBytes = _is.ColumnInt(
      'logicalBytes',
      this,
    );
    downloadPath = _is.ColumnString(
      'downloadPath',
      this,
    );
    recommendedStart = _is.ColumnDouble(
      'recommendedStart',
      this,
    );
    recommendedEnd = _is.ColumnDouble(
      'recommendedEnd',
      this,
    );
    practiceFocus = _is.ColumnString(
      'practiceFocus',
      this,
    );
    guidanceDescription = _is.ColumnString(
      'guidanceDescription',
      this,
    );
  }

  late final CatalogScoreUpdateTable updateTable;

  late final _is.ColumnString cid;

  late final _is.ColumnString title;

  late final _is.ColumnString composer;

  late final _is.ColumnString artifactVersion;

  late final _is.ColumnInt sourceSlot;

  late final _is.ColumnDouble duration;

  late final _is.ColumnString license;

  late final _is.ColumnString licenseUrl;

  late final _is.ColumnString compressedSha256;

  late final _is.ColumnInt compressedBytes;

  late final _is.ColumnString logicalSha256;

  late final _is.ColumnInt logicalBytes;

  late final _is.ColumnString downloadPath;

  late final _is.ColumnDouble recommendedStart;

  late final _is.ColumnDouble recommendedEnd;

  late final _is.ColumnString practiceFocus;

  late final _is.ColumnString guidanceDescription;

  @override
  List<_is.Column> get columns => [
    id,
    cid,
    title,
    composer,
    artifactVersion,
    sourceSlot,
    duration,
    license,
    licenseUrl,
    compressedSha256,
    compressedBytes,
    logicalSha256,
    logicalBytes,
    downloadPath,
    recommendedStart,
    recommendedEnd,
    practiceFocus,
    guidanceDescription,
  ];
}

class CatalogScoreInclude extends _is.IncludeObject {
  CatalogScoreInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CatalogScore.t;
}

class CatalogScoreIncludeList extends _is.IncludeList {
  CatalogScoreIncludeList._({
    _is.WhereExpressionBuilder<CatalogScoreTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CatalogScore.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CatalogScore.t;
}

class CatalogScoreRepository {
  const CatalogScoreRepository._();

  /// Returns a list of [CatalogScore]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<CatalogScore>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CatalogScoreTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CatalogScore>(
      where: where?.call(CatalogScore.t),
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CatalogScore] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<CatalogScore?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CatalogScoreTable>? where,
    int? offset,
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CatalogScore>(
      where: where?.call(CatalogScore.t),
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CatalogScore] by its [id] or null if no such row exists.
  Future<CatalogScore?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CatalogScore>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CatalogScore]s in the list and returns the inserted rows.
  ///
  /// The returned [CatalogScore]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> insert(
    _is.DatabaseSession session,
    List<CatalogScore> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CatalogScore>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CatalogScore] and returns the inserted row.
  ///
  /// The returned [CatalogScore] will have its `id` field set.
  Future<CatalogScore> insertRow(
    _is.DatabaseSession session,
    CatalogScore row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CatalogScore>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CatalogScore]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [CatalogScore]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> upsert(
    _is.DatabaseSession session,
    List<CatalogScore> rows, {
    required _is.ColumnSelections<CatalogScoreTable> conflictColumns,
    _is.ColumnSelections<CatalogScoreTable>? updateColumns,
    _is.WhereExpressionBuilder<CatalogScoreTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CatalogScore>(
      rows,
      conflictColumns: conflictColumns(CatalogScore.t),
      updateColumns: updateColumns?.call(CatalogScore.t),
      updateWhere: updateWhere?.call(CatalogScore.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CatalogScore] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [CatalogScore] will have its `id` field set.
  Future<CatalogScore?> upsertRow(
    _is.DatabaseSession session,
    CatalogScore row, {
    required _is.ColumnSelections<CatalogScoreTable> conflictColumns,
    _is.ColumnSelections<CatalogScoreTable>? updateColumns,
    _is.WhereExpressionBuilder<CatalogScoreTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CatalogScore>(
      row,
      conflictColumns: conflictColumns(CatalogScore.t),
      updateColumns: updateColumns?.call(CatalogScore.t),
      updateWhere: updateWhere?.call(CatalogScore.t),
      transaction: transaction,
    );
  }

  /// Updates all [CatalogScore]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> update(
    _is.DatabaseSession session,
    List<CatalogScore> rows, {
    _is.ColumnSelections<CatalogScoreTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CatalogScore>(
      rows,
      columns: columns?.call(CatalogScore.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CatalogScore]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CatalogScore> updateRow(
    _is.DatabaseSession session,
    CatalogScore row, {
    _is.ColumnSelections<CatalogScoreTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CatalogScore>(
      row,
      columns: columns?.call(CatalogScore.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CatalogScore] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CatalogScore?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CatalogScoreUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CatalogScore>(
      id,
      columnValues: columnValues(CatalogScore.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CatalogScore]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CatalogScoreUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CatalogScoreTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CatalogScore>(
      columnValues: columnValues(CatalogScore.t.updateTable),
      where: where(CatalogScore.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CatalogScore]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> delete(
    _is.DatabaseSession session,
    List<CatalogScore> rows, {
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CatalogScore>(
      rows,
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CatalogScore].
  Future<CatalogScore> deleteRow(
    _is.DatabaseSession session,
    CatalogScore row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CatalogScore>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CatalogScore>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CatalogScoreTable> where,
    _is.OrderByBuilder<CatalogScoreTable>? orderBy,
    _is.OrderByListBuilder<CatalogScoreTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CatalogScore>(
      where: where(CatalogScore.t),
      orderBy: orderBy?.call(CatalogScore.t),
      orderByList: orderByList?.call(CatalogScore.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CatalogScoreTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CatalogScore>(
      where: where?.call(CatalogScore.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CatalogScore] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CatalogScoreTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CatalogScore>(
      where: where(CatalogScore.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
