// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IdeasTable extends Ideas with TableInfo<$IdeasTable, IdeaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timePeriodMeta = const VerificationMeta(
    'timePeriod',
  );
  @override
  late final GeneratedColumn<String> timePeriod = GeneratedColumn<String>(
    'time_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonForStoppingMeta = const VerificationMeta(
    'reasonForStopping',
  );
  @override
  late final GeneratedColumn<String> reasonForStopping =
      GeneratedColumn<String>(
        'reason_for_stopping',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _emotionalNoteMeta = const VerificationMeta(
    'emotionalNote',
  );
  @override
  late final GeneratedColumn<String> emotionalNote = GeneratedColumn<String>(
    'emotional_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notYetAnalysed'),
  );
  static const VerificationMeta _aiOptInMeta = const VerificationMeta(
    'aiOptIn',
  );
  @override
  late final GeneratedColumn<bool> aiOptIn = GeneratedColumn<bool>(
    'ai_opt_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ai_opt_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    createdAt,
    timePeriod,
    reasonForStopping,
    emotionalNote,
    verdict,
    aiOptIn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ideas';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdeaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('time_period')) {
      context.handle(
        _timePeriodMeta,
        timePeriod.isAcceptableOrUnknown(data['time_period']!, _timePeriodMeta),
      );
    }
    if (data.containsKey('reason_for_stopping')) {
      context.handle(
        _reasonForStoppingMeta,
        reasonForStopping.isAcceptableOrUnknown(
          data['reason_for_stopping']!,
          _reasonForStoppingMeta,
        ),
      );
    }
    if (data.containsKey('emotional_note')) {
      context.handle(
        _emotionalNoteMeta,
        emotionalNote.isAcceptableOrUnknown(
          data['emotional_note']!,
          _emotionalNoteMeta,
        ),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    }
    if (data.containsKey('ai_opt_in')) {
      context.handle(
        _aiOptInMeta,
        aiOptIn.isAcceptableOrUnknown(data['ai_opt_in']!, _aiOptInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdeaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdeaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      timePeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_period'],
      ),
      reasonForStopping: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_for_stopping'],
      ),
      emotionalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotional_note'],
      ),
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      aiOptIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ai_opt_in'],
      )!,
    );
  }

  @override
  $IdeasTable createAlias(String alias) {
    return $IdeasTable(attachedDatabase, alias);
  }
}

class IdeaData extends DataClass implements Insertable<IdeaData> {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? timePeriod;
  final String? reasonForStopping;
  final String? emotionalNote;
  final String verdict;
  final bool aiOptIn;
  const IdeaData({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.timePeriod,
    this.reasonForStopping,
    this.emotionalNote,
    required this.verdict,
    required this.aiOptIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || timePeriod != null) {
      map['time_period'] = Variable<String>(timePeriod);
    }
    if (!nullToAbsent || reasonForStopping != null) {
      map['reason_for_stopping'] = Variable<String>(reasonForStopping);
    }
    if (!nullToAbsent || emotionalNote != null) {
      map['emotional_note'] = Variable<String>(emotionalNote);
    }
    map['verdict'] = Variable<String>(verdict);
    map['ai_opt_in'] = Variable<bool>(aiOptIn);
    return map;
  }

  IdeasCompanion toCompanion(bool nullToAbsent) {
    return IdeasCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      timePeriod: timePeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(timePeriod),
      reasonForStopping: reasonForStopping == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonForStopping),
      emotionalNote: emotionalNote == null && nullToAbsent
          ? const Value.absent()
          : Value(emotionalNote),
      verdict: Value(verdict),
      aiOptIn: Value(aiOptIn),
    );
  }

  factory IdeaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdeaData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      timePeriod: serializer.fromJson<String?>(json['timePeriod']),
      reasonForStopping: serializer.fromJson<String?>(
        json['reasonForStopping'],
      ),
      emotionalNote: serializer.fromJson<String?>(json['emotionalNote']),
      verdict: serializer.fromJson<String>(json['verdict']),
      aiOptIn: serializer.fromJson<bool>(json['aiOptIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'timePeriod': serializer.toJson<String?>(timePeriod),
      'reasonForStopping': serializer.toJson<String?>(reasonForStopping),
      'emotionalNote': serializer.toJson<String?>(emotionalNote),
      'verdict': serializer.toJson<String>(verdict),
      'aiOptIn': serializer.toJson<bool>(aiOptIn),
    };
  }

  IdeaData copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    Value<String?> timePeriod = const Value.absent(),
    Value<String?> reasonForStopping = const Value.absent(),
    Value<String?> emotionalNote = const Value.absent(),
    String? verdict,
    bool? aiOptIn,
  }) => IdeaData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    timePeriod: timePeriod.present ? timePeriod.value : this.timePeriod,
    reasonForStopping: reasonForStopping.present
        ? reasonForStopping.value
        : this.reasonForStopping,
    emotionalNote: emotionalNote.present
        ? emotionalNote.value
        : this.emotionalNote,
    verdict: verdict ?? this.verdict,
    aiOptIn: aiOptIn ?? this.aiOptIn,
  );
  IdeaData copyWithCompanion(IdeasCompanion data) {
    return IdeaData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      timePeriod: data.timePeriod.present
          ? data.timePeriod.value
          : this.timePeriod,
      reasonForStopping: data.reasonForStopping.present
          ? data.reasonForStopping.value
          : this.reasonForStopping,
      emotionalNote: data.emotionalNote.present
          ? data.emotionalNote.value
          : this.emotionalNote,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      aiOptIn: data.aiOptIn.present ? data.aiOptIn.value : this.aiOptIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdeaData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('timePeriod: $timePeriod, ')
          ..write('reasonForStopping: $reasonForStopping, ')
          ..write('emotionalNote: $emotionalNote, ')
          ..write('verdict: $verdict, ')
          ..write('aiOptIn: $aiOptIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    createdAt,
    timePeriod,
    reasonForStopping,
    emotionalNote,
    verdict,
    aiOptIn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdeaData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.timePeriod == this.timePeriod &&
          other.reasonForStopping == this.reasonForStopping &&
          other.emotionalNote == this.emotionalNote &&
          other.verdict == this.verdict &&
          other.aiOptIn == this.aiOptIn);
}

class IdeasCompanion extends UpdateCompanion<IdeaData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<String?> timePeriod;
  final Value<String?> reasonForStopping;
  final Value<String?> emotionalNote;
  final Value<String> verdict;
  final Value<bool> aiOptIn;
  final Value<int> rowid;
  const IdeasCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.timePeriod = const Value.absent(),
    this.reasonForStopping = const Value.absent(),
    this.emotionalNote = const Value.absent(),
    this.verdict = const Value.absent(),
    this.aiOptIn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdeasCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime createdAt,
    this.timePeriod = const Value.absent(),
    this.reasonForStopping = const Value.absent(),
    this.emotionalNote = const Value.absent(),
    this.verdict = const Value.absent(),
    this.aiOptIn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<IdeaData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<String>? timePeriod,
    Expression<String>? reasonForStopping,
    Expression<String>? emotionalNote,
    Expression<String>? verdict,
    Expression<bool>? aiOptIn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (timePeriod != null) 'time_period': timePeriod,
      if (reasonForStopping != null) 'reason_for_stopping': reasonForStopping,
      if (emotionalNote != null) 'emotional_note': emotionalNote,
      if (verdict != null) 'verdict': verdict,
      if (aiOptIn != null) 'ai_opt_in': aiOptIn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdeasCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<String?>? timePeriod,
    Value<String?>? reasonForStopping,
    Value<String?>? emotionalNote,
    Value<String>? verdict,
    Value<bool>? aiOptIn,
    Value<int>? rowid,
  }) {
    return IdeasCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      timePeriod: timePeriod ?? this.timePeriod,
      reasonForStopping: reasonForStopping ?? this.reasonForStopping,
      emotionalNote: emotionalNote ?? this.emotionalNote,
      verdict: verdict ?? this.verdict,
      aiOptIn: aiOptIn ?? this.aiOptIn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (timePeriod.present) {
      map['time_period'] = Variable<String>(timePeriod.value);
    }
    if (reasonForStopping.present) {
      map['reason_for_stopping'] = Variable<String>(reasonForStopping.value);
    }
    if (emotionalNote.present) {
      map['emotional_note'] = Variable<String>(emotionalNote.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (aiOptIn.present) {
      map['ai_opt_in'] = Variable<bool>(aiOptIn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdeasCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('timePeriod: $timePeriod, ')
          ..write('reasonForStopping: $reasonForStopping, ')
          ..write('emotionalNote: $emotionalNote, ')
          ..write('verdict: $verdict, ')
          ..write('aiOptIn: $aiOptIn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IdeasTable ideas = $IdeasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [ideas];
}

typedef $$IdeasTableCreateCompanionBuilder =
    IdeasCompanion Function({
      required String id,
      required String title,
      required String description,
      required DateTime createdAt,
      Value<String?> timePeriod,
      Value<String?> reasonForStopping,
      Value<String?> emotionalNote,
      Value<String> verdict,
      Value<bool> aiOptIn,
      Value<int> rowid,
    });
typedef $$IdeasTableUpdateCompanionBuilder =
    IdeasCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<String?> timePeriod,
      Value<String?> reasonForStopping,
      Value<String?> emotionalNote,
      Value<String> verdict,
      Value<bool> aiOptIn,
      Value<int> rowid,
    });

class $$IdeasTableFilterComposer extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timePeriod => $composableBuilder(
    column: $table.timePeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonForStopping => $composableBuilder(
    column: $table.reasonForStopping,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotionalNote => $composableBuilder(
    column: $table.emotionalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aiOptIn => $composableBuilder(
    column: $table.aiOptIn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdeasTableOrderingComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timePeriod => $composableBuilder(
    column: $table.timePeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonForStopping => $composableBuilder(
    column: $table.reasonForStopping,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotionalNote => $composableBuilder(
    column: $table.emotionalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aiOptIn => $composableBuilder(
    column: $table.aiOptIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdeasTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get timePeriod => $composableBuilder(
    column: $table.timePeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonForStopping => $composableBuilder(
    column: $table.reasonForStopping,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emotionalNote => $composableBuilder(
    column: $table.emotionalNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<bool> get aiOptIn =>
      $composableBuilder(column: $table.aiOptIn, builder: (column) => column);
}

class $$IdeasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdeasTable,
          IdeaData,
          $$IdeasTableFilterComposer,
          $$IdeasTableOrderingComposer,
          $$IdeasTableAnnotationComposer,
          $$IdeasTableCreateCompanionBuilder,
          $$IdeasTableUpdateCompanionBuilder,
          (IdeaData, BaseReferences<_$AppDatabase, $IdeasTable, IdeaData>),
          IdeaData,
          PrefetchHooks Function()
        > {
  $$IdeasTableTableManager(_$AppDatabase db, $IdeasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> timePeriod = const Value.absent(),
                Value<String?> reasonForStopping = const Value.absent(),
                Value<String?> emotionalNote = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<bool> aiOptIn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdeasCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                timePeriod: timePeriod,
                reasonForStopping: reasonForStopping,
                emotionalNote: emotionalNote,
                verdict: verdict,
                aiOptIn: aiOptIn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required DateTime createdAt,
                Value<String?> timePeriod = const Value.absent(),
                Value<String?> reasonForStopping = const Value.absent(),
                Value<String?> emotionalNote = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<bool> aiOptIn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdeasCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
                timePeriod: timePeriod,
                reasonForStopping: reasonForStopping,
                emotionalNote: emotionalNote,
                verdict: verdict,
                aiOptIn: aiOptIn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdeasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdeasTable,
      IdeaData,
      $$IdeasTableFilterComposer,
      $$IdeasTableOrderingComposer,
      $$IdeasTableAnnotationComposer,
      $$IdeasTableCreateCompanionBuilder,
      $$IdeasTableUpdateCompanionBuilder,
      (IdeaData, BaseReferences<_$AppDatabase, $IdeasTable, IdeaData>),
      IdeaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IdeasTableTableManager get ideas =>
      $$IdeasTableTableManager(_db, _db.ideas);
}
