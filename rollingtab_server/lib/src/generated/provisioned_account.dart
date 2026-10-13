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

abstract class ProvisionedAccount
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProvisionedAccount._({
    this.id,
    required this.email,
    required this.authUserId,
  });

  factory ProvisionedAccount({
    int? id,
    required String email,
    required _is.UuidValue authUserId,
  }) = _ProvisionedAccountImpl;

  factory ProvisionedAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProvisionedAccount(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  static final t = ProvisionedAccountTable();

  static const db = ProvisionedAccountRepository._();

  @override
  int? id;

  String email;

  _is.UuidValue authUserId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProvisionedAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProvisionedAccount copyWith({
    int? id,
    String? email,
    _is.UuidValue? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProvisionedAccount',
      if (id != null) 'id': id,
      'email': email,
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ProvisionedAccountInclude include() {
    return ProvisionedAccountInclude._();
  }

  static ProvisionedAccountIncludeList includeList({
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    ProvisionedAccountInclude? include,
  }) {
    return ProvisionedAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProvisionedAccountImpl extends ProvisionedAccount {
  _ProvisionedAccountImpl({
    int? id,
    required String email,
    required _is.UuidValue authUserId,
  }) : super._(
         id: id,
         email: email,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [ProvisionedAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProvisionedAccount copyWith({
    Object? id = _Undefined,
    String? email,
    _is.UuidValue? authUserId,
  }) {
    return ProvisionedAccount(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      authUserId: authUserId ?? this.authUserId,
    );
  }
}

class ProvisionedAccountUpdateTable
    extends _is.UpdateTable<ProvisionedAccountTable> {
  ProvisionedAccountUpdateTable(super.table);

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );
}

class ProvisionedAccountTable extends _is.Table<int?> {
  ProvisionedAccountTable({super.tableRelation})
    : super(tableName: 'rollingtab_provisioned_account') {
    updateTable = ProvisionedAccountUpdateTable(this);
    email = _is.ColumnString(
      'email',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
  }

  late final ProvisionedAccountUpdateTable updateTable;

  late final _is.ColumnString email;

  late final _is.ColumnUuid authUserId;

  @override
  List<_is.Column> get columns => [
    id,
    email,
    authUserId,
  ];
}

class ProvisionedAccountInclude extends _is.IncludeObject {
  ProvisionedAccountInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ProvisionedAccount.t;
}

class ProvisionedAccountIncludeList extends _is.IncludeList {
  ProvisionedAccountIncludeList._({
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProvisionedAccount.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProvisionedAccount.t;
}

class ProvisionedAccountRepository {
  const ProvisionedAccountRepository._();

  /// Returns a list of [ProvisionedAccount]s matching the given query parameters.
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
  Future<List<ProvisionedAccount>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProvisionedAccount>(
      where: where?.call(ProvisionedAccount.t),
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProvisionedAccount] matching the given query parameters.
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
  Future<ProvisionedAccount?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? where,
    int? offset,
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProvisionedAccount>(
      where: where?.call(ProvisionedAccount.t),
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProvisionedAccount] by its [id] or null if no such row exists.
  Future<ProvisionedAccount?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProvisionedAccount>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProvisionedAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [ProvisionedAccount]s will have their `id` fields set.
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
  Future<List<ProvisionedAccount>> insert(
    _is.DatabaseSession session,
    List<ProvisionedAccount> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProvisionedAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProvisionedAccount] and returns the inserted row.
  ///
  /// The returned [ProvisionedAccount] will have its `id` field set.
  Future<ProvisionedAccount> insertRow(
    _is.DatabaseSession session,
    ProvisionedAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProvisionedAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProvisionedAccount]s in the list and returns the resulting rows.
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
  /// The returned [ProvisionedAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProvisionedAccount>> upsert(
    _is.DatabaseSession session,
    List<ProvisionedAccount> rows, {
    required _is.ColumnSelections<ProvisionedAccountTable> conflictColumns,
    _is.ColumnSelections<ProvisionedAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProvisionedAccount>(
      rows,
      conflictColumns: conflictColumns(ProvisionedAccount.t),
      updateColumns: updateColumns?.call(ProvisionedAccount.t),
      updateWhere: updateWhere?.call(ProvisionedAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProvisionedAccount] and returns the resulting row.
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
  /// The returned [ProvisionedAccount] will have its `id` field set.
  Future<ProvisionedAccount?> upsertRow(
    _is.DatabaseSession session,
    ProvisionedAccount row, {
    required _is.ColumnSelections<ProvisionedAccountTable> conflictColumns,
    _is.ColumnSelections<ProvisionedAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProvisionedAccount>(
      row,
      conflictColumns: conflictColumns(ProvisionedAccount.t),
      updateColumns: updateColumns?.call(ProvisionedAccount.t),
      updateWhere: updateWhere?.call(ProvisionedAccount.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProvisionedAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProvisionedAccount>> update(
    _is.DatabaseSession session,
    List<ProvisionedAccount> rows, {
    _is.ColumnSelections<ProvisionedAccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProvisionedAccount>(
      rows,
      columns: columns?.call(ProvisionedAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProvisionedAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProvisionedAccount> updateRow(
    _is.DatabaseSession session,
    ProvisionedAccount row, {
    _is.ColumnSelections<ProvisionedAccountTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProvisionedAccount>(
      row,
      columns: columns?.call(ProvisionedAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProvisionedAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProvisionedAccount?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProvisionedAccountUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProvisionedAccount>(
      id,
      columnValues: columnValues(ProvisionedAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProvisionedAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProvisionedAccount>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProvisionedAccountUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ProvisionedAccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProvisionedAccount>(
      columnValues: columnValues(ProvisionedAccount.t.updateTable),
      where: where(ProvisionedAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProvisionedAccount]s in the list and returns the deleted rows.
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
  Future<List<ProvisionedAccount>> delete(
    _is.DatabaseSession session,
    List<ProvisionedAccount> rows, {
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProvisionedAccount>(
      rows,
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProvisionedAccount].
  Future<ProvisionedAccount> deleteRow(
    _is.DatabaseSession session,
    ProvisionedAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProvisionedAccount>(
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
  Future<List<ProvisionedAccount>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProvisionedAccountTable> where,
    _is.OrderByBuilder<ProvisionedAccountTable>? orderBy,
    _is.OrderByListBuilder<ProvisionedAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProvisionedAccount>(
      where: where(ProvisionedAccount.t),
      orderBy: orderBy?.call(ProvisionedAccount.t),
      orderByList: orderByList?.call(ProvisionedAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProvisionedAccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProvisionedAccount>(
      where: where?.call(ProvisionedAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProvisionedAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProvisionedAccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProvisionedAccount>(
      where: where(ProvisionedAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
