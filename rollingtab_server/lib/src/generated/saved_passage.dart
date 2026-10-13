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

abstract class SavedPassage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    required _is.UuidValue owner,
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
      owner: _is.UuidValueJsonExtension.fromJson(jsonSerialization['owner']),
      cid: jsonSerialization['cid'] as String,
      artifactVersion: jsonSerialization['artifactVersion'] as String,
      sourceSlot: jsonSerialization['sourceSlot'] as int,
      name: jsonSerialization['name'] as String,
      start: (jsonSerialization['start'] as num).toDouble(),
      end: (jsonSerialization['end'] as num).toDouble(),
      tempo: (jsonSerialization['tempo'] as num).toDouble(),
      loop: _is.BoolJsonExtension.fromJson(jsonSerialization['loop']),
      revision: jsonSerialization['revision'] as int,
      requestId: jsonSerialization['requestId'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = SavedPassageTable();

  static const db = SavedPassageRepository._();

  @override
  int? id;

  String passageId;

  _is.UuidValue owner;

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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SavedPassage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SavedPassage copyWith({
    int? id,
    String? passageId,
    _is.UuidValue? owner,
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

  static SavedPassageInclude include() {
    return SavedPassageInclude._();
  }

  static SavedPassageIncludeList includeList({
    _is.WhereExpressionBuilder<SavedPassageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    SavedPassageInclude? include,
  }) {
    return SavedPassageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SavedPassageImpl extends SavedPassage {
  _SavedPassageImpl({
    int? id,
    required String passageId,
    required _is.UuidValue owner,
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
  @_is.useResult
  @override
  SavedPassage copyWith({
    Object? id = _Undefined,
    String? passageId,
    _is.UuidValue? owner,
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

class SavedPassageUpdateTable extends _is.UpdateTable<SavedPassageTable> {
  SavedPassageUpdateTable(super.table);

  _is.ColumnValue<String, String> passageId(String value) => _is.ColumnValue(
    table.passageId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> owner(_is.UuidValue value) =>
      _is.ColumnValue(
        table.owner,
        value,
      );

  _is.ColumnValue<String, String> cid(String value) => _is.ColumnValue(
    table.cid,
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

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<double, double> start(double value) => _is.ColumnValue(
    table.start,
    value,
  );

  _is.ColumnValue<double, double> end(double value) => _is.ColumnValue(
    table.end,
    value,
  );

  _is.ColumnValue<double, double> tempo(double value) => _is.ColumnValue(
    table.tempo,
    value,
  );

  _is.ColumnValue<bool, bool> loop(bool value) => _is.ColumnValue(
    table.loop,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> requestId(String value) => _is.ColumnValue(
    table.requestId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class SavedPassageTable extends _is.Table<int?> {
  SavedPassageTable({super.tableRelation})
    : super(tableName: 'rollingtab_passage') {
    updateTable = SavedPassageUpdateTable(this);
    passageId = _is.ColumnString(
      'passageId',
      this,
    );
    owner = _is.ColumnUuid(
      'owner',
      this,
    );
    cid = _is.ColumnString(
      'cid',
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
    name = _is.ColumnString(
      'name',
      this,
    );
    start = _is.ColumnDouble(
      'start',
      this,
    );
    end = _is.ColumnDouble(
      'end',
      this,
    );
    tempo = _is.ColumnDouble(
      'tempo',
      this,
    );
    loop = _is.ColumnBool(
      'loop',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    requestId = _is.ColumnString(
      'requestId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final SavedPassageUpdateTable updateTable;

  late final _is.ColumnString passageId;

  late final _is.ColumnUuid owner;

  late final _is.ColumnString cid;

  late final _is.ColumnString artifactVersion;

  late final _is.ColumnInt sourceSlot;

  late final _is.ColumnString name;

  late final _is.ColumnDouble start;

  late final _is.ColumnDouble end;

  late final _is.ColumnDouble tempo;

  late final _is.ColumnBool loop;

  late final _is.ColumnInt revision;

  late final _is.ColumnString requestId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    passageId,
    owner,
    cid,
    artifactVersion,
    sourceSlot,
    name,
    start,
    end,
    tempo,
    loop,
    revision,
    requestId,
    createdAt,
    updatedAt,
  ];
}

class SavedPassageInclude extends _is.IncludeObject {
  SavedPassageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SavedPassage.t;
}

class SavedPassageIncludeList extends _is.IncludeList {
  SavedPassageIncludeList._({
    _is.WhereExpressionBuilder<SavedPassageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SavedPassage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SavedPassage.t;
}

class SavedPassageRepository {
  const SavedPassageRepository._();

  /// Returns a list of [SavedPassage]s matching the given query parameters.
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
  Future<List<SavedPassage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SavedPassageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SavedPassage>(
      where: where?.call(SavedPassage.t),
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SavedPassage] matching the given query parameters.
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
  Future<SavedPassage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SavedPassageTable>? where,
    int? offset,
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SavedPassage>(
      where: where?.call(SavedPassage.t),
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SavedPassage] by its [id] or null if no such row exists.
  Future<SavedPassage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SavedPassage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SavedPassage]s in the list and returns the inserted rows.
  ///
  /// The returned [SavedPassage]s will have their `id` fields set.
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
  Future<List<SavedPassage>> insert(
    _is.DatabaseSession session,
    List<SavedPassage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SavedPassage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SavedPassage] and returns the inserted row.
  ///
  /// The returned [SavedPassage] will have its `id` field set.
  Future<SavedPassage> insertRow(
    _is.DatabaseSession session,
    SavedPassage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SavedPassage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SavedPassage]s in the list and returns the resulting rows.
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
  /// The returned [SavedPassage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SavedPassage>> upsert(
    _is.DatabaseSession session,
    List<SavedPassage> rows, {
    required _is.ColumnSelections<SavedPassageTable> conflictColumns,
    _is.ColumnSelections<SavedPassageTable>? updateColumns,
    _is.WhereExpressionBuilder<SavedPassageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SavedPassage>(
      rows,
      conflictColumns: conflictColumns(SavedPassage.t),
      updateColumns: updateColumns?.call(SavedPassage.t),
      updateWhere: updateWhere?.call(SavedPassage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SavedPassage] and returns the resulting row.
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
  /// The returned [SavedPassage] will have its `id` field set.
  Future<SavedPassage?> upsertRow(
    _is.DatabaseSession session,
    SavedPassage row, {
    required _is.ColumnSelections<SavedPassageTable> conflictColumns,
    _is.ColumnSelections<SavedPassageTable>? updateColumns,
    _is.WhereExpressionBuilder<SavedPassageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SavedPassage>(
      row,
      conflictColumns: conflictColumns(SavedPassage.t),
      updateColumns: updateColumns?.call(SavedPassage.t),
      updateWhere: updateWhere?.call(SavedPassage.t),
      transaction: transaction,
    );
  }

  /// Updates all [SavedPassage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SavedPassage>> update(
    _is.DatabaseSession session,
    List<SavedPassage> rows, {
    _is.ColumnSelections<SavedPassageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SavedPassage>(
      rows,
      columns: columns?.call(SavedPassage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SavedPassage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SavedPassage> updateRow(
    _is.DatabaseSession session,
    SavedPassage row, {
    _is.ColumnSelections<SavedPassageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SavedPassage>(
      row,
      columns: columns?.call(SavedPassage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SavedPassage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SavedPassage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SavedPassageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SavedPassage>(
      id,
      columnValues: columnValues(SavedPassage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SavedPassage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SavedPassage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SavedPassageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SavedPassageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SavedPassage>(
      columnValues: columnValues(SavedPassage.t.updateTable),
      where: where(SavedPassage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SavedPassage]s in the list and returns the deleted rows.
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
  Future<List<SavedPassage>> delete(
    _is.DatabaseSession session,
    List<SavedPassage> rows, {
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SavedPassage>(
      rows,
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SavedPassage].
  Future<SavedPassage> deleteRow(
    _is.DatabaseSession session,
    SavedPassage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SavedPassage>(
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
  Future<List<SavedPassage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SavedPassageTable> where,
    _is.OrderByBuilder<SavedPassageTable>? orderBy,
    _is.OrderByListBuilder<SavedPassageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SavedPassage>(
      where: where(SavedPassage.t),
      orderBy: orderBy?.call(SavedPassage.t),
      orderByList: orderByList?.call(SavedPassage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SavedPassageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SavedPassage>(
      where: where?.call(SavedPassage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SavedPassage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SavedPassageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SavedPassage>(
      where: where(SavedPassage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
