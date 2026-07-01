// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProjectStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ProjectStatus.planning.name),
      ).withConverter<ProjectStatus>($ProjectsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<Priority, String> priority =
      GeneratedColumn<String>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Priority.medium.name),
      ).withConverter<Priority>($ProjectsTable.$converterpriority);
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProjectsTable.$convertertags);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    description,
    status,
    priority,
    startDate,
    targetDate,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
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
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: $ProjectsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: $ProjectsTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      tags: $ProjectsTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProjectStatus, String, String> $converterstatus =
      const EnumNameConverter<ProjectStatus>(ProjectStatus.values);
  static JsonTypeConverter2<Priority, String, String> $converterpriority =
      const EnumNameConverter<Priority>(Priority.values);
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String title;
  final String description;
  final ProjectStatus status;
  final Priority priority;
  final DateTime? startDate;
  final DateTime? targetDate;
  final List<String> tags;
  const Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.startDate,
    this.targetDate,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['priority'] = Variable<String>(
        $ProjectsTable.$converterpriority.toSql(priority),
      );
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    {
      map['tags'] = Variable<String>($ProjectsTable.$convertertags.toSql(tags));
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      title: Value(title),
      description: Value(description),
      status: Value(status),
      priority: Value(priority),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      tags: Value(tags),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      status: $ProjectsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      priority: $ProjectsTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      tags: serializer.fromJson<List<String>>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(
        $ProjectsTable.$converterstatus.toJson(status),
      ),
      'priority': serializer.toJson<String>(
        $ProjectsTable.$converterpriority.toJson(priority),
      ),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'tags': serializer.toJson<List<String>>(tags),
    };
  }

  Project copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? title,
    String? description,
    ProjectStatus? status,
    Priority? priority,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    List<String>? tags,
  }) => Project(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    startDate: startDate.present ? startDate.value : this.startDate,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    tags: tags ?? this.tags,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    description,
    status,
    priority,
    startDate,
    targetDate,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.tags == this.tags);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> title;
  final Value<String> description;
  final Value<ProjectStatus> status;
  final Value<Priority> priority;
  final Value<DateTime?> startDate;
  final Value<DateTime?> targetDate;
  final Value<List<String>> tags;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? title,
    Value<String>? description,
    Value<ProjectStatus>? status,
    Value<Priority>? priority,
    Value<DateTime?>? startDate,
    Value<DateTime?>? targetDate,
    Value<List<String>>? tags,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $ProjectsTable.$converterpriority.toSql(priority.value),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $ProjectsTable.$convertertags.toSql(tags.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentsTable extends Experiments
    with TableInfo<$ExperimentsTable, Experiment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _hypothesisMeta = const VerificationMeta(
    'hypothesis',
  );
  @override
  late final GeneratedColumn<String> hypothesis = GeneratedColumn<String>(
    'hypothesis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExperimentStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ExperimentStatus.planned.name),
      ).withConverter<ExperimentStatus>($ExperimentsTable.$converterstatus);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> strainIds =
      GeneratedColumn<String>(
        'strain_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ExperimentsTable.$converterstrainIds);
  static const VerificationMeta _protocolRefMeta = const VerificationMeta(
    'protocolRef',
  );
  @override
  late final GeneratedColumn<String> protocolRef = GeneratedColumn<String>(
    'protocol_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  methodologySteps = GeneratedColumn<String>(
    'methodology_steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ExperimentsTable.$convertermethodologySteps);
  static const VerificationMeta _resultsNotesMeta = const VerificationMeta(
    'resultsNotes',
  );
  @override
  late final GeneratedColumn<String> resultsNotes = GeneratedColumn<String>(
    'results_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _conclusionMeta = const VerificationMeta(
    'conclusion',
  );
  @override
  late final GeneratedColumn<String> conclusion = GeneratedColumn<String>(
    'conclusion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _furtherPlanMeta = const VerificationMeta(
    'furtherPlan',
  );
  @override
  late final GeneratedColumn<String> furtherPlan = GeneratedColumn<String>(
    'further_plan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> dataLinks =
      GeneratedColumn<String>(
        'data_links',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ExperimentsTable.$converterdataLinks);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    title,
    hypothesis,
    status,
    date,
    strainIds,
    protocolRef,
    methodologySteps,
    resultsNotes,
    conclusion,
    furtherPlan,
    dataLinks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Experiment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('hypothesis')) {
      context.handle(
        _hypothesisMeta,
        hypothesis.isAcceptableOrUnknown(data['hypothesis']!, _hypothesisMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('protocol_ref')) {
      context.handle(
        _protocolRefMeta,
        protocolRef.isAcceptableOrUnknown(
          data['protocol_ref']!,
          _protocolRefMeta,
        ),
      );
    }
    if (data.containsKey('results_notes')) {
      context.handle(
        _resultsNotesMeta,
        resultsNotes.isAcceptableOrUnknown(
          data['results_notes']!,
          _resultsNotesMeta,
        ),
      );
    }
    if (data.containsKey('conclusion')) {
      context.handle(
        _conclusionMeta,
        conclusion.isAcceptableOrUnknown(data['conclusion']!, _conclusionMeta),
      );
    }
    if (data.containsKey('further_plan')) {
      context.handle(
        _furtherPlanMeta,
        furtherPlan.isAcceptableOrUnknown(
          data['further_plan']!,
          _furtherPlanMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Experiment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Experiment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      hypothesis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hypothesis'],
      )!,
      status: $ExperimentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      strainIds: $ExperimentsTable.$converterstrainIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}strain_ids'],
        )!,
      ),
      protocolRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol_ref'],
      )!,
      methodologySteps: $ExperimentsTable.$convertermethodologySteps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}methodology_steps'],
        )!,
      ),
      resultsNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}results_notes'],
      )!,
      conclusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conclusion'],
      )!,
      furtherPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}further_plan'],
      )!,
      dataLinks: $ExperimentsTable.$converterdataLinks.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}data_links'],
        )!,
      ),
    );
  }

  @override
  $ExperimentsTable createAlias(String alias) {
    return $ExperimentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExperimentStatus, String, String> $converterstatus =
      const EnumNameConverter<ExperimentStatus>(ExperimentStatus.values);
  static TypeConverter<List<String>, String> $converterstrainIds =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertermethodologySteps =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterdataLinks =
      const StringListConverter();
}

class Experiment extends DataClass implements Insertable<Experiment> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String projectId;
  final String title;
  final String hypothesis;
  final ExperimentStatus status;
  final DateTime? date;

  /// Logical foreign keys to `strains.id` (which strains a run used). Stored as
  /// a JSON array per SPEC.md (the array is enough for v1, no join table); these
  /// are resolved to Strain rows in the app layer, so missing IDs degrade
  /// gracefully rather than failing a DB constraint.
  final List<String> strainIds;
  final String protocolRef;

  /// The methodology written out as ordered steps (JSON array of strings).
  final List<String> methodologySteps;
  final String resultsNotes;

  /// What the run concluded, and what to do next.
  final String conclusion;
  final String furtherPlan;
  final List<String> dataLinks;
  const Experiment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.projectId,
    required this.title,
    required this.hypothesis,
    required this.status,
    this.date,
    required this.strainIds,
    required this.protocolRef,
    required this.methodologySteps,
    required this.resultsNotes,
    required this.conclusion,
    required this.furtherPlan,
    required this.dataLinks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['hypothesis'] = Variable<String>(hypothesis);
    {
      map['status'] = Variable<String>(
        $ExperimentsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    {
      map['strain_ids'] = Variable<String>(
        $ExperimentsTable.$converterstrainIds.toSql(strainIds),
      );
    }
    map['protocol_ref'] = Variable<String>(protocolRef);
    {
      map['methodology_steps'] = Variable<String>(
        $ExperimentsTable.$convertermethodologySteps.toSql(methodologySteps),
      );
    }
    map['results_notes'] = Variable<String>(resultsNotes);
    map['conclusion'] = Variable<String>(conclusion);
    map['further_plan'] = Variable<String>(furtherPlan);
    {
      map['data_links'] = Variable<String>(
        $ExperimentsTable.$converterdataLinks.toSql(dataLinks),
      );
    }
    return map;
  }

  ExperimentsCompanion toCompanion(bool nullToAbsent) {
    return ExperimentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      projectId: Value(projectId),
      title: Value(title),
      hypothesis: Value(hypothesis),
      status: Value(status),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      strainIds: Value(strainIds),
      protocolRef: Value(protocolRef),
      methodologySteps: Value(methodologySteps),
      resultsNotes: Value(resultsNotes),
      conclusion: Value(conclusion),
      furtherPlan: Value(furtherPlan),
      dataLinks: Value(dataLinks),
    );
  }

  factory Experiment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Experiment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      hypothesis: serializer.fromJson<String>(json['hypothesis']),
      status: $ExperimentsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      date: serializer.fromJson<DateTime?>(json['date']),
      strainIds: serializer.fromJson<List<String>>(json['strainIds']),
      protocolRef: serializer.fromJson<String>(json['protocolRef']),
      methodologySteps: serializer.fromJson<List<String>>(
        json['methodologySteps'],
      ),
      resultsNotes: serializer.fromJson<String>(json['resultsNotes']),
      conclusion: serializer.fromJson<String>(json['conclusion']),
      furtherPlan: serializer.fromJson<String>(json['furtherPlan']),
      dataLinks: serializer.fromJson<List<String>>(json['dataLinks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'hypothesis': serializer.toJson<String>(hypothesis),
      'status': serializer.toJson<String>(
        $ExperimentsTable.$converterstatus.toJson(status),
      ),
      'date': serializer.toJson<DateTime?>(date),
      'strainIds': serializer.toJson<List<String>>(strainIds),
      'protocolRef': serializer.toJson<String>(protocolRef),
      'methodologySteps': serializer.toJson<List<String>>(methodologySteps),
      'resultsNotes': serializer.toJson<String>(resultsNotes),
      'conclusion': serializer.toJson<String>(conclusion),
      'furtherPlan': serializer.toJson<String>(furtherPlan),
      'dataLinks': serializer.toJson<List<String>>(dataLinks),
    };
  }

  Experiment copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? projectId,
    String? title,
    String? hypothesis,
    ExperimentStatus? status,
    Value<DateTime?> date = const Value.absent(),
    List<String>? strainIds,
    String? protocolRef,
    List<String>? methodologySteps,
    String? resultsNotes,
    String? conclusion,
    String? furtherPlan,
    List<String>? dataLinks,
  }) => Experiment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    hypothesis: hypothesis ?? this.hypothesis,
    status: status ?? this.status,
    date: date.present ? date.value : this.date,
    strainIds: strainIds ?? this.strainIds,
    protocolRef: protocolRef ?? this.protocolRef,
    methodologySteps: methodologySteps ?? this.methodologySteps,
    resultsNotes: resultsNotes ?? this.resultsNotes,
    conclusion: conclusion ?? this.conclusion,
    furtherPlan: furtherPlan ?? this.furtherPlan,
    dataLinks: dataLinks ?? this.dataLinks,
  );
  Experiment copyWithCompanion(ExperimentsCompanion data) {
    return Experiment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      hypothesis: data.hypothesis.present
          ? data.hypothesis.value
          : this.hypothesis,
      status: data.status.present ? data.status.value : this.status,
      date: data.date.present ? data.date.value : this.date,
      strainIds: data.strainIds.present ? data.strainIds.value : this.strainIds,
      protocolRef: data.protocolRef.present
          ? data.protocolRef.value
          : this.protocolRef,
      methodologySteps: data.methodologySteps.present
          ? data.methodologySteps.value
          : this.methodologySteps,
      resultsNotes: data.resultsNotes.present
          ? data.resultsNotes.value
          : this.resultsNotes,
      conclusion: data.conclusion.present
          ? data.conclusion.value
          : this.conclusion,
      furtherPlan: data.furtherPlan.present
          ? data.furtherPlan.value
          : this.furtherPlan,
      dataLinks: data.dataLinks.present ? data.dataLinks.value : this.dataLinks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Experiment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('hypothesis: $hypothesis, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('strainIds: $strainIds, ')
          ..write('protocolRef: $protocolRef, ')
          ..write('methodologySteps: $methodologySteps, ')
          ..write('resultsNotes: $resultsNotes, ')
          ..write('conclusion: $conclusion, ')
          ..write('furtherPlan: $furtherPlan, ')
          ..write('dataLinks: $dataLinks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    title,
    hypothesis,
    status,
    date,
    strainIds,
    protocolRef,
    methodologySteps,
    resultsNotes,
    conclusion,
    furtherPlan,
    dataLinks,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Experiment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.hypothesis == this.hypothesis &&
          other.status == this.status &&
          other.date == this.date &&
          other.strainIds == this.strainIds &&
          other.protocolRef == this.protocolRef &&
          other.methodologySteps == this.methodologySteps &&
          other.resultsNotes == this.resultsNotes &&
          other.conclusion == this.conclusion &&
          other.furtherPlan == this.furtherPlan &&
          other.dataLinks == this.dataLinks);
}

class ExperimentsCompanion extends UpdateCompanion<Experiment> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> projectId;
  final Value<String> title;
  final Value<String> hypothesis;
  final Value<ExperimentStatus> status;
  final Value<DateTime?> date;
  final Value<List<String>> strainIds;
  final Value<String> protocolRef;
  final Value<List<String>> methodologySteps;
  final Value<String> resultsNotes;
  final Value<String> conclusion;
  final Value<String> furtherPlan;
  final Value<List<String>> dataLinks;
  final Value<int> rowid;
  const ExperimentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.hypothesis = const Value.absent(),
    this.status = const Value.absent(),
    this.date = const Value.absent(),
    this.strainIds = const Value.absent(),
    this.protocolRef = const Value.absent(),
    this.methodologySteps = const Value.absent(),
    this.resultsNotes = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.furtherPlan = const Value.absent(),
    this.dataLinks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String projectId,
    required String title,
    this.hypothesis = const Value.absent(),
    this.status = const Value.absent(),
    this.date = const Value.absent(),
    this.strainIds = const Value.absent(),
    this.protocolRef = const Value.absent(),
    this.methodologySteps = const Value.absent(),
    this.resultsNotes = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.furtherPlan = const Value.absent(),
    this.dataLinks = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       title = Value(title);
  static Insertable<Experiment> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? hypothesis,
    Expression<String>? status,
    Expression<DateTime>? date,
    Expression<String>? strainIds,
    Expression<String>? protocolRef,
    Expression<String>? methodologySteps,
    Expression<String>? resultsNotes,
    Expression<String>? conclusion,
    Expression<String>? furtherPlan,
    Expression<String>? dataLinks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (hypothesis != null) 'hypothesis': hypothesis,
      if (status != null) 'status': status,
      if (date != null) 'date': date,
      if (strainIds != null) 'strain_ids': strainIds,
      if (protocolRef != null) 'protocol_ref': protocolRef,
      if (methodologySteps != null) 'methodology_steps': methodologySteps,
      if (resultsNotes != null) 'results_notes': resultsNotes,
      if (conclusion != null) 'conclusion': conclusion,
      if (furtherPlan != null) 'further_plan': furtherPlan,
      if (dataLinks != null) 'data_links': dataLinks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? projectId,
    Value<String>? title,
    Value<String>? hypothesis,
    Value<ExperimentStatus>? status,
    Value<DateTime?>? date,
    Value<List<String>>? strainIds,
    Value<String>? protocolRef,
    Value<List<String>>? methodologySteps,
    Value<String>? resultsNotes,
    Value<String>? conclusion,
    Value<String>? furtherPlan,
    Value<List<String>>? dataLinks,
    Value<int>? rowid,
  }) {
    return ExperimentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      hypothesis: hypothesis ?? this.hypothesis,
      status: status ?? this.status,
      date: date ?? this.date,
      strainIds: strainIds ?? this.strainIds,
      protocolRef: protocolRef ?? this.protocolRef,
      methodologySteps: methodologySteps ?? this.methodologySteps,
      resultsNotes: resultsNotes ?? this.resultsNotes,
      conclusion: conclusion ?? this.conclusion,
      furtherPlan: furtherPlan ?? this.furtherPlan,
      dataLinks: dataLinks ?? this.dataLinks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (hypothesis.present) {
      map['hypothesis'] = Variable<String>(hypothesis.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ExperimentsTable.$converterstatus.toSql(status.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (strainIds.present) {
      map['strain_ids'] = Variable<String>(
        $ExperimentsTable.$converterstrainIds.toSql(strainIds.value),
      );
    }
    if (protocolRef.present) {
      map['protocol_ref'] = Variable<String>(protocolRef.value);
    }
    if (methodologySteps.present) {
      map['methodology_steps'] = Variable<String>(
        $ExperimentsTable.$convertermethodologySteps.toSql(
          methodologySteps.value,
        ),
      );
    }
    if (resultsNotes.present) {
      map['results_notes'] = Variable<String>(resultsNotes.value);
    }
    if (conclusion.present) {
      map['conclusion'] = Variable<String>(conclusion.value);
    }
    if (furtherPlan.present) {
      map['further_plan'] = Variable<String>(furtherPlan.value);
    }
    if (dataLinks.present) {
      map['data_links'] = Variable<String>(
        $ExperimentsTable.$converterdataLinks.toSql(dataLinks.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('hypothesis: $hypothesis, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('strainIds: $strainIds, ')
          ..write('protocolRef: $protocolRef, ')
          ..write('methodologySteps: $methodologySteps, ')
          ..write('resultsNotes: $resultsNotes, ')
          ..write('conclusion: $conclusion, ')
          ..write('furtherPlan: $furtherPlan, ')
          ..write('dataLinks: $dataLinks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _experimentIdMeta = const VerificationMeta(
    'experimentId',
  );
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
    'experiment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES experiments (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TaskStatus.todo.name),
      ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<Priority, String> priority =
      GeneratedColumn<String>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Priority.medium.name),
      ).withConverter<Priority>($TasksTable.$converterpriority);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    experimentId,
    title,
    description,
    dueDate,
    status,
    priority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('experiment_id')) {
      context.handle(
        _experimentIdMeta,
        experimentId.isAcceptableOrUnknown(
          data['experiment_id']!,
          _experimentIdMeta,
        ),
      );
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
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      experimentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experiment_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: $TasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<Priority, String, String> $converterpriority =
      const EnumNameConverter<Priority>(Priority.values);
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String? projectId;
  final String? experimentId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final Priority priority;
  const Task({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    this.projectId,
    this.experimentId,
    required this.title,
    required this.description,
    this.dueDate,
    required this.status,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || experimentId != null) {
      map['experiment_id'] = Variable<String>(experimentId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status),
      );
    }
    {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority),
      );
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      experimentId: experimentId == null && nullToAbsent
          ? const Value.absent()
          : Value(experimentId),
      title: Value(title),
      description: Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      priority: Value(priority),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      experimentId: serializer.fromJson<String?>(json['experimentId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: $TasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      priority: $TasksTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String?>(projectId),
      'experimentId': serializer.toJson<String?>(experimentId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(
        $TasksTable.$converterstatus.toJson(status),
      ),
      'priority': serializer.toJson<String>(
        $TasksTable.$converterpriority.toJson(priority),
      ),
    };
  }

  Task copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    Value<String?> projectId = const Value.absent(),
    Value<String?> experimentId = const Value.absent(),
    String? title,
    String? description,
    Value<DateTime?> dueDate = const Value.absent(),
    TaskStatus? status,
    Priority? priority,
  }) => Task(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId.present ? projectId.value : this.projectId,
    experimentId: experimentId.present ? experimentId.value : this.experimentId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    status: status ?? this.status,
    priority: priority ?? this.priority,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('experimentId: $experimentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    experimentId,
    title,
    description,
    dueDate,
    status,
    priority,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.experimentId == this.experimentId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.priority == this.priority);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String?> projectId;
  final Value<String?> experimentId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime?> dueDate;
  final Value<TaskStatus> status;
  final Value<Priority> priority;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.experimentId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? experimentId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (experimentId != null) 'experiment_id': experimentId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String?>? projectId,
    Value<String?>? experimentId,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime?>? dueDate,
    Value<TaskStatus>? status,
    Value<Priority>? priority,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      experimentId: experimentId ?? this.experimentId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('experimentId: $experimentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrainsTable extends Strains with TableInfo<$StrainsTable, Strain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrainsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hostOrganismMeta = const VerificationMeta(
    'hostOrganism',
  );
  @override
  late final GeneratedColumn<String> hostOrganism = GeneratedColumn<String>(
    'host_organism',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _genotypeMeta = const VerificationMeta(
    'genotype',
  );
  @override
  late final GeneratedColumn<String> genotype = GeneratedColumn<String>(
    'genotype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _plasmidMeta = const VerificationMeta(
    'plasmid',
  );
  @override
  late final GeneratedColumn<String> plasmid = GeneratedColumn<String>(
    'plasmid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _constructNotesMeta = const VerificationMeta(
    'constructNotes',
  );
  @override
  late final GeneratedColumn<String> constructNotes = GeneratedColumn<String>(
    'construct_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  selectionMarkers = GeneratedColumn<String>(
    'selection_markers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($StrainsTable.$converterselectionMarkers);
  static const VerificationMeta _freezerLocationMeta = const VerificationMeta(
    'freezerLocation',
  );
  @override
  late final GeneratedColumn<String> freezerLocation = GeneratedColumn<String>(
    'freezer_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    serialNumber,
    hostOrganism,
    genotype,
    plasmid,
    constructNotes,
    selectionMarkers,
    freezerLocation,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strains';
  @override
  VerificationContext validateIntegrity(
    Insertable<Strain> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('host_organism')) {
      context.handle(
        _hostOrganismMeta,
        hostOrganism.isAcceptableOrUnknown(
          data['host_organism']!,
          _hostOrganismMeta,
        ),
      );
    }
    if (data.containsKey('genotype')) {
      context.handle(
        _genotypeMeta,
        genotype.isAcceptableOrUnknown(data['genotype']!, _genotypeMeta),
      );
    }
    if (data.containsKey('plasmid')) {
      context.handle(
        _plasmidMeta,
        plasmid.isAcceptableOrUnknown(data['plasmid']!, _plasmidMeta),
      );
    }
    if (data.containsKey('construct_notes')) {
      context.handle(
        _constructNotesMeta,
        constructNotes.isAcceptableOrUnknown(
          data['construct_notes']!,
          _constructNotesMeta,
        ),
      );
    }
    if (data.containsKey('freezer_location')) {
      context.handle(
        _freezerLocationMeta,
        freezerLocation.isAcceptableOrUnknown(
          data['freezer_location']!,
          _freezerLocationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Strain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Strain(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      )!,
      hostOrganism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_organism'],
      )!,
      genotype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genotype'],
      )!,
      plasmid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plasmid'],
      )!,
      constructNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}construct_notes'],
      )!,
      selectionMarkers: $StrainsTable.$converterselectionMarkers.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selection_markers'],
        )!,
      ),
      freezerLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freezer_location'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $StrainsTable createAlias(String alias) {
    return $StrainsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterselectionMarkers =
      const StringListConverter();
}

class Strain extends DataClass implements Insertable<Strain> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;

  /// User-assigned lab serial / catalog number (editable).
  final String serialNumber;
  final String hostOrganism;
  final String genotype;
  final String plasmid;
  final String constructNotes;

  /// Selection markers carried by the strain (antibiotic resistances /
  /// auxotrophies, e.g. ['Kanamycin','Ampicillin']) — what to select on. JSON.
  final List<String> selectionMarkers;
  final String freezerLocation;
  final String notes;
  const Strain({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    required this.serialNumber,
    required this.hostOrganism,
    required this.genotype,
    required this.plasmid,
    required this.constructNotes,
    required this.selectionMarkers,
    required this.freezerLocation,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['serial_number'] = Variable<String>(serialNumber);
    map['host_organism'] = Variable<String>(hostOrganism);
    map['genotype'] = Variable<String>(genotype);
    map['plasmid'] = Variable<String>(plasmid);
    map['construct_notes'] = Variable<String>(constructNotes);
    {
      map['selection_markers'] = Variable<String>(
        $StrainsTable.$converterselectionMarkers.toSql(selectionMarkers),
      );
    }
    map['freezer_location'] = Variable<String>(freezerLocation);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  StrainsCompanion toCompanion(bool nullToAbsent) {
    return StrainsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      serialNumber: Value(serialNumber),
      hostOrganism: Value(hostOrganism),
      genotype: Value(genotype),
      plasmid: Value(plasmid),
      constructNotes: Value(constructNotes),
      selectionMarkers: Value(selectionMarkers),
      freezerLocation: Value(freezerLocation),
      notes: Value(notes),
    );
  }

  factory Strain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Strain(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      serialNumber: serializer.fromJson<String>(json['serialNumber']),
      hostOrganism: serializer.fromJson<String>(json['hostOrganism']),
      genotype: serializer.fromJson<String>(json['genotype']),
      plasmid: serializer.fromJson<String>(json['plasmid']),
      constructNotes: serializer.fromJson<String>(json['constructNotes']),
      selectionMarkers: serializer.fromJson<List<String>>(
        json['selectionMarkers'],
      ),
      freezerLocation: serializer.fromJson<String>(json['freezerLocation']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'serialNumber': serializer.toJson<String>(serialNumber),
      'hostOrganism': serializer.toJson<String>(hostOrganism),
      'genotype': serializer.toJson<String>(genotype),
      'plasmid': serializer.toJson<String>(plasmid),
      'constructNotes': serializer.toJson<String>(constructNotes),
      'selectionMarkers': serializer.toJson<List<String>>(selectionMarkers),
      'freezerLocation': serializer.toJson<String>(freezerLocation),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Strain copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    String? serialNumber,
    String? hostOrganism,
    String? genotype,
    String? plasmid,
    String? constructNotes,
    List<String>? selectionMarkers,
    String? freezerLocation,
    String? notes,
  }) => Strain(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    serialNumber: serialNumber ?? this.serialNumber,
    hostOrganism: hostOrganism ?? this.hostOrganism,
    genotype: genotype ?? this.genotype,
    plasmid: plasmid ?? this.plasmid,
    constructNotes: constructNotes ?? this.constructNotes,
    selectionMarkers: selectionMarkers ?? this.selectionMarkers,
    freezerLocation: freezerLocation ?? this.freezerLocation,
    notes: notes ?? this.notes,
  );
  Strain copyWithCompanion(StrainsCompanion data) {
    return Strain(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      hostOrganism: data.hostOrganism.present
          ? data.hostOrganism.value
          : this.hostOrganism,
      genotype: data.genotype.present ? data.genotype.value : this.genotype,
      plasmid: data.plasmid.present ? data.plasmid.value : this.plasmid,
      constructNotes: data.constructNotes.present
          ? data.constructNotes.value
          : this.constructNotes,
      selectionMarkers: data.selectionMarkers.present
          ? data.selectionMarkers.value
          : this.selectionMarkers,
      freezerLocation: data.freezerLocation.present
          ? data.freezerLocation.value
          : this.freezerLocation,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Strain(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('hostOrganism: $hostOrganism, ')
          ..write('genotype: $genotype, ')
          ..write('plasmid: $plasmid, ')
          ..write('constructNotes: $constructNotes, ')
          ..write('selectionMarkers: $selectionMarkers, ')
          ..write('freezerLocation: $freezerLocation, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    serialNumber,
    hostOrganism,
    genotype,
    plasmid,
    constructNotes,
    selectionMarkers,
    freezerLocation,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Strain &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.serialNumber == this.serialNumber &&
          other.hostOrganism == this.hostOrganism &&
          other.genotype == this.genotype &&
          other.plasmid == this.plasmid &&
          other.constructNotes == this.constructNotes &&
          other.selectionMarkers == this.selectionMarkers &&
          other.freezerLocation == this.freezerLocation &&
          other.notes == this.notes);
}

class StrainsCompanion extends UpdateCompanion<Strain> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> serialNumber;
  final Value<String> hostOrganism;
  final Value<String> genotype;
  final Value<String> plasmid;
  final Value<String> constructNotes;
  final Value<List<String>> selectionMarkers;
  final Value<String> freezerLocation;
  final Value<String> notes;
  final Value<int> rowid;
  const StrainsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.hostOrganism = const Value.absent(),
    this.genotype = const Value.absent(),
    this.plasmid = const Value.absent(),
    this.constructNotes = const Value.absent(),
    this.selectionMarkers = const Value.absent(),
    this.freezerLocation = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrainsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String name,
    this.serialNumber = const Value.absent(),
    this.hostOrganism = const Value.absent(),
    this.genotype = const Value.absent(),
    this.plasmid = const Value.absent(),
    this.constructNotes = const Value.absent(),
    this.selectionMarkers = const Value.absent(),
    this.freezerLocation = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Strain> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? serialNumber,
    Expression<String>? hostOrganism,
    Expression<String>? genotype,
    Expression<String>? plasmid,
    Expression<String>? constructNotes,
    Expression<String>? selectionMarkers,
    Expression<String>? freezerLocation,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (hostOrganism != null) 'host_organism': hostOrganism,
      if (genotype != null) 'genotype': genotype,
      if (plasmid != null) 'plasmid': plasmid,
      if (constructNotes != null) 'construct_notes': constructNotes,
      if (selectionMarkers != null) 'selection_markers': selectionMarkers,
      if (freezerLocation != null) 'freezer_location': freezerLocation,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrainsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? serialNumber,
    Value<String>? hostOrganism,
    Value<String>? genotype,
    Value<String>? plasmid,
    Value<String>? constructNotes,
    Value<List<String>>? selectionMarkers,
    Value<String>? freezerLocation,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return StrainsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      hostOrganism: hostOrganism ?? this.hostOrganism,
      genotype: genotype ?? this.genotype,
      plasmid: plasmid ?? this.plasmid,
      constructNotes: constructNotes ?? this.constructNotes,
      selectionMarkers: selectionMarkers ?? this.selectionMarkers,
      freezerLocation: freezerLocation ?? this.freezerLocation,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (hostOrganism.present) {
      map['host_organism'] = Variable<String>(hostOrganism.value);
    }
    if (genotype.present) {
      map['genotype'] = Variable<String>(genotype.value);
    }
    if (plasmid.present) {
      map['plasmid'] = Variable<String>(plasmid.value);
    }
    if (constructNotes.present) {
      map['construct_notes'] = Variable<String>(constructNotes.value);
    }
    if (selectionMarkers.present) {
      map['selection_markers'] = Variable<String>(
        $StrainsTable.$converterselectionMarkers.toSql(selectionMarkers.value),
      );
    }
    if (freezerLocation.present) {
      map['freezer_location'] = Variable<String>(freezerLocation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrainsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('hostOrganism: $hostOrganism, ')
          ..write('genotype: $genotype, ')
          ..write('plasmid: $plasmid, ')
          ..write('constructNotes: $constructNotes, ')
          ..write('selectionMarkers: $selectionMarkers, ')
          ..write('freezerLocation: $freezerLocation, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReagentsTable extends Reagents with TableInfo<$ReagentsTable, Reagent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReagentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reagent'),
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _catalogNoMeta = const VerificationMeta(
    'catalogNo',
  );
  @override
  late final GeneratedColumn<String> catalogNo = GeneratedColumn<String>(
    'catalog_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lotMeta = const VerificationMeta('lot');
  @override
  late final GeneratedColumn<String> lot = GeneratedColumn<String>(
    'lot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recipeMeta = const VerificationMeta('recipe');
  @override
  late final GeneratedColumn<String> recipe = GeneratedColumn<String>(
    'recipe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    kind,
    supplier,
    catalogNo,
    lot,
    location,
    expiryDate,
    quantity,
    recipe,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reagents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reagent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('catalog_no')) {
      context.handle(
        _catalogNoMeta,
        catalogNo.isAcceptableOrUnknown(data['catalog_no']!, _catalogNoMeta),
      );
    }
    if (data.containsKey('lot')) {
      context.handle(
        _lotMeta,
        lot.isAcceptableOrUnknown(data['lot']!, _lotMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('recipe')) {
      context.handle(
        _recipeMeta,
        recipe.isAcceptableOrUnknown(data['recipe']!, _recipeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reagent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reagent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      )!,
      catalogNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_no'],
      )!,
      lot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      recipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ReagentsTable createAlias(String alias) {
    return $ReagentsTable(attachedDatabase, alias);
  }
}

class Reagent extends DataClass implements Insertable<Reagent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;

  /// 'reagent' (default) or 'buffer'.
  final String kind;
  final String supplier;
  final String catalogNo;
  final String lot;
  final String location;
  final DateTime? expiryDate;
  final String quantity;

  /// Preparation / composition recipe — used mainly for buffers.
  final String recipe;
  final String notes;
  const Reagent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    required this.kind,
    required this.supplier,
    required this.catalogNo,
    required this.lot,
    required this.location,
    this.expiryDate,
    required this.quantity,
    required this.recipe,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['supplier'] = Variable<String>(supplier);
    map['catalog_no'] = Variable<String>(catalogNo);
    map['lot'] = Variable<String>(lot);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['quantity'] = Variable<String>(quantity);
    map['recipe'] = Variable<String>(recipe);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ReagentsCompanion toCompanion(bool nullToAbsent) {
    return ReagentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      kind: Value(kind),
      supplier: Value(supplier),
      catalogNo: Value(catalogNo),
      lot: Value(lot),
      location: Value(location),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      quantity: Value(quantity),
      recipe: Value(recipe),
      notes: Value(notes),
    );
  }

  factory Reagent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reagent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      supplier: serializer.fromJson<String>(json['supplier']),
      catalogNo: serializer.fromJson<String>(json['catalogNo']),
      lot: serializer.fromJson<String>(json['lot']),
      location: serializer.fromJson<String>(json['location']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      quantity: serializer.fromJson<String>(json['quantity']),
      recipe: serializer.fromJson<String>(json['recipe']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'supplier': serializer.toJson<String>(supplier),
      'catalogNo': serializer.toJson<String>(catalogNo),
      'lot': serializer.toJson<String>(lot),
      'location': serializer.toJson<String>(location),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'quantity': serializer.toJson<String>(quantity),
      'recipe': serializer.toJson<String>(recipe),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Reagent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    String? kind,
    String? supplier,
    String? catalogNo,
    String? lot,
    String? location,
    Value<DateTime?> expiryDate = const Value.absent(),
    String? quantity,
    String? recipe,
    String? notes,
  }) => Reagent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    supplier: supplier ?? this.supplier,
    catalogNo: catalogNo ?? this.catalogNo,
    lot: lot ?? this.lot,
    location: location ?? this.location,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    quantity: quantity ?? this.quantity,
    recipe: recipe ?? this.recipe,
    notes: notes ?? this.notes,
  );
  Reagent copyWithCompanion(ReagentsCompanion data) {
    return Reagent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      catalogNo: data.catalogNo.present ? data.catalogNo.value : this.catalogNo,
      lot: data.lot.present ? data.lot.value : this.lot,
      location: data.location.present ? data.location.value : this.location,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      recipe: data.recipe.present ? data.recipe.value : this.recipe,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reagent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('supplier: $supplier, ')
          ..write('catalogNo: $catalogNo, ')
          ..write('lot: $lot, ')
          ..write('location: $location, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('quantity: $quantity, ')
          ..write('recipe: $recipe, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    kind,
    supplier,
    catalogNo,
    lot,
    location,
    expiryDate,
    quantity,
    recipe,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reagent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.supplier == this.supplier &&
          other.catalogNo == this.catalogNo &&
          other.lot == this.lot &&
          other.location == this.location &&
          other.expiryDate == this.expiryDate &&
          other.quantity == this.quantity &&
          other.recipe == this.recipe &&
          other.notes == this.notes);
}

class ReagentsCompanion extends UpdateCompanion<Reagent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> supplier;
  final Value<String> catalogNo;
  final Value<String> lot;
  final Value<String> location;
  final Value<DateTime?> expiryDate;
  final Value<String> quantity;
  final Value<String> recipe;
  final Value<String> notes;
  final Value<int> rowid;
  const ReagentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.supplier = const Value.absent(),
    this.catalogNo = const Value.absent(),
    this.lot = const Value.absent(),
    this.location = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.recipe = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReagentsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String name,
    this.kind = const Value.absent(),
    this.supplier = const Value.absent(),
    this.catalogNo = const Value.absent(),
    this.lot = const Value.absent(),
    this.location = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.recipe = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Reagent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? supplier,
    Expression<String>? catalogNo,
    Expression<String>? lot,
    Expression<String>? location,
    Expression<DateTime>? expiryDate,
    Expression<String>? quantity,
    Expression<String>? recipe,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (supplier != null) 'supplier': supplier,
      if (catalogNo != null) 'catalog_no': catalogNo,
      if (lot != null) 'lot': lot,
      if (location != null) 'location': location,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (quantity != null) 'quantity': quantity,
      if (recipe != null) 'recipe': recipe,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReagentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? supplier,
    Value<String>? catalogNo,
    Value<String>? lot,
    Value<String>? location,
    Value<DateTime?>? expiryDate,
    Value<String>? quantity,
    Value<String>? recipe,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ReagentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      supplier: supplier ?? this.supplier,
      catalogNo: catalogNo ?? this.catalogNo,
      lot: lot ?? this.lot,
      location: location ?? this.location,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      recipe: recipe ?? this.recipe,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (catalogNo.present) {
      map['catalog_no'] = Variable<String>(catalogNo.value);
    }
    if (lot.present) {
      map['lot'] = Variable<String>(lot.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (recipe.present) {
      map['recipe'] = Variable<String>(recipe.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReagentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('supplier: $supplier, ')
          ..write('catalogNo: $catalogNo, ')
          ..write('lot: $lot, ')
          ..write('location: $location, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('quantity: $quantity, ')
          ..write('recipe: $recipe, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManuscriptsTable extends Manuscripts
    with TableInfo<$ManuscriptsTable, Manuscript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManuscriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _targetJournalMeta = const VerificationMeta(
    'targetJournal',
  );
  @override
  late final GeneratedColumn<String> targetJournal = GeneratedColumn<String>(
    'target_journal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ManuscriptStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ManuscriptStatus.drafting.name),
      ).withConverter<ManuscriptStatus>($ManuscriptsTable.$converterstatus);
  static const VerificationMeta _submissionIdMeta = const VerificationMeta(
    'submissionId',
  );
  @override
  late final GeneratedColumn<String> submissionId = GeneratedColumn<String>(
    'submission_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _submittedDateMeta = const VerificationMeta(
    'submittedDate',
  );
  @override
  late final GeneratedColumn<DateTime> submittedDate =
      GeneratedColumn<DateTime>(
        'submitted_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    title,
    targetJournal,
    status,
    submissionId,
    submittedDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manuscripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Manuscript> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_journal')) {
      context.handle(
        _targetJournalMeta,
        targetJournal.isAcceptableOrUnknown(
          data['target_journal']!,
          _targetJournalMeta,
        ),
      );
    }
    if (data.containsKey('submission_id')) {
      context.handle(
        _submissionIdMeta,
        submissionId.isAcceptableOrUnknown(
          data['submission_id']!,
          _submissionIdMeta,
        ),
      );
    }
    if (data.containsKey('submitted_date')) {
      context.handle(
        _submittedDateMeta,
        submittedDate.isAcceptableOrUnknown(
          data['submitted_date']!,
          _submittedDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manuscript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manuscript(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      targetJournal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_journal'],
      )!,
      status: $ManuscriptsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      submissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submission_id'],
      )!,
      submittedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ManuscriptsTable createAlias(String alias) {
    return $ManuscriptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ManuscriptStatus, String, String> $converterstatus =
      const EnumNameConverter<ManuscriptStatus>(ManuscriptStatus.values);
}

class Manuscript extends DataClass implements Insertable<Manuscript> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String projectId;
  final String title;
  final String targetJournal;
  final ManuscriptStatus status;
  final String submissionId;
  final DateTime? submittedDate;
  final String notes;
  const Manuscript({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.projectId,
    required this.title,
    required this.targetJournal,
    required this.status,
    required this.submissionId,
    this.submittedDate,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['target_journal'] = Variable<String>(targetJournal);
    {
      map['status'] = Variable<String>(
        $ManuscriptsTable.$converterstatus.toSql(status),
      );
    }
    map['submission_id'] = Variable<String>(submissionId);
    if (!nullToAbsent || submittedDate != null) {
      map['submitted_date'] = Variable<DateTime>(submittedDate);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ManuscriptsCompanion toCompanion(bool nullToAbsent) {
    return ManuscriptsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      projectId: Value(projectId),
      title: Value(title),
      targetJournal: Value(targetJournal),
      status: Value(status),
      submissionId: Value(submissionId),
      submittedDate: submittedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedDate),
      notes: Value(notes),
    );
  }

  factory Manuscript.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manuscript(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      targetJournal: serializer.fromJson<String>(json['targetJournal']),
      status: $ManuscriptsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      submissionId: serializer.fromJson<String>(json['submissionId']),
      submittedDate: serializer.fromJson<DateTime?>(json['submittedDate']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'targetJournal': serializer.toJson<String>(targetJournal),
      'status': serializer.toJson<String>(
        $ManuscriptsTable.$converterstatus.toJson(status),
      ),
      'submissionId': serializer.toJson<String>(submissionId),
      'submittedDate': serializer.toJson<DateTime?>(submittedDate),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Manuscript copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? projectId,
    String? title,
    String? targetJournal,
    ManuscriptStatus? status,
    String? submissionId,
    Value<DateTime?> submittedDate = const Value.absent(),
    String? notes,
  }) => Manuscript(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    targetJournal: targetJournal ?? this.targetJournal,
    status: status ?? this.status,
    submissionId: submissionId ?? this.submissionId,
    submittedDate: submittedDate.present
        ? submittedDate.value
        : this.submittedDate,
    notes: notes ?? this.notes,
  );
  Manuscript copyWithCompanion(ManuscriptsCompanion data) {
    return Manuscript(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      targetJournal: data.targetJournal.present
          ? data.targetJournal.value
          : this.targetJournal,
      status: data.status.present ? data.status.value : this.status,
      submissionId: data.submissionId.present
          ? data.submissionId.value
          : this.submissionId,
      submittedDate: data.submittedDate.present
          ? data.submittedDate.value
          : this.submittedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manuscript(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('targetJournal: $targetJournal, ')
          ..write('status: $status, ')
          ..write('submissionId: $submissionId, ')
          ..write('submittedDate: $submittedDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    projectId,
    title,
    targetJournal,
    status,
    submissionId,
    submittedDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manuscript &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.targetJournal == this.targetJournal &&
          other.status == this.status &&
          other.submissionId == this.submissionId &&
          other.submittedDate == this.submittedDate &&
          other.notes == this.notes);
}

class ManuscriptsCompanion extends UpdateCompanion<Manuscript> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> projectId;
  final Value<String> title;
  final Value<String> targetJournal;
  final Value<ManuscriptStatus> status;
  final Value<String> submissionId;
  final Value<DateTime?> submittedDate;
  final Value<String> notes;
  final Value<int> rowid;
  const ManuscriptsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.targetJournal = const Value.absent(),
    this.status = const Value.absent(),
    this.submissionId = const Value.absent(),
    this.submittedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManuscriptsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String projectId,
    required String title,
    this.targetJournal = const Value.absent(),
    this.status = const Value.absent(),
    this.submissionId = const Value.absent(),
    this.submittedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       title = Value(title);
  static Insertable<Manuscript> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? targetJournal,
    Expression<String>? status,
    Expression<String>? submissionId,
    Expression<DateTime>? submittedDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (targetJournal != null) 'target_journal': targetJournal,
      if (status != null) 'status': status,
      if (submissionId != null) 'submission_id': submissionId,
      if (submittedDate != null) 'submitted_date': submittedDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManuscriptsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? projectId,
    Value<String>? title,
    Value<String>? targetJournal,
    Value<ManuscriptStatus>? status,
    Value<String>? submissionId,
    Value<DateTime?>? submittedDate,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ManuscriptsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      targetJournal: targetJournal ?? this.targetJournal,
      status: status ?? this.status,
      submissionId: submissionId ?? this.submissionId,
      submittedDate: submittedDate ?? this.submittedDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetJournal.present) {
      map['target_journal'] = Variable<String>(targetJournal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ManuscriptsTable.$converterstatus.toSql(status.value),
      );
    }
    if (submissionId.present) {
      map['submission_id'] = Variable<String>(submissionId.value);
    }
    if (submittedDate.present) {
      map['submitted_date'] = Variable<DateTime>(submittedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManuscriptsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('targetJournal: $targetJournal, ')
          ..write('status: $status, ')
          ..write('submissionId: $submissionId, ')
          ..write('submittedDate: $submittedDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TombstonesTable extends Tombstones
    with TableInfo<$TombstonesTable, Tombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [id, entityTable, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['table_name']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tombstone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $TombstonesTable createAlias(String alias) {
    return $TombstonesTable(attachedDatabase, alias);
  }
}

class Tombstone extends DataClass implements Insertable<Tombstone> {
  final String id;
  final String entityTable;
  final DateTime deletedAt;
  const Tombstone({
    required this.id,
    required this.entityTable,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(entityTable);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  TombstonesCompanion toCompanion(bool nullToAbsent) {
    return TombstonesCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      deletedAt: Value(deletedAt),
    );
  }

  factory Tombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tombstone(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  Tombstone copyWith({String? id, String? entityTable, DateTime? deletedAt}) =>
      Tombstone(
        id: id ?? this.id,
        entityTable: entityTable ?? this.entityTable,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  Tombstone copyWithCompanion(TombstonesCompanion data) {
    return Tombstone(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tombstone(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityTable, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tombstone &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.deletedAt == this.deletedAt);
}

class TombstonesCompanion extends UpdateCompanion<Tombstone> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const TombstonesCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TombstonesCompanion.insert({
    required String id,
    required String entityTable,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityTable = Value(entityTable);
  static Insertable<Tombstone> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'table_name': entityTable,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TombstonesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityTable,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return TombstonesCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['table_name'] = Variable<String>(entityTable.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TombstonesCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final String key;
  final String value;
  const SyncMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetaRow copyWith({String? key, String? value}) =>
      SyncMetaRow(key: key ?? this.key, value: value ?? this.value);
  SyncMetaRow copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<int> accentColor = GeneratedColumn<int>(
    'accent_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF009688),
  );
  static const VerificationMeta _densityMeta = const VerificationMeta(
    'density',
  );
  @override
  late final GeneratedColumn<String> density = GeneratedColumn<String>(
    'density',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('comfortable'),
  );
  static const VerificationMeta _bgModeMeta = const VerificationMeta('bgMode');
  @override
  late final GeneratedColumn<String> bgMode = GeneratedColumn<String>(
    'bg_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _bgColorAMeta = const VerificationMeta(
    'bgColorA',
  );
  @override
  late final GeneratedColumn<int> bgColorA = GeneratedColumn<int>(
    'bg_color_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF0F2027),
  );
  static const VerificationMeta _bgColorBMeta = const VerificationMeta(
    'bgColorB',
  );
  @override
  late final GeneratedColumn<int> bgColorB = GeneratedColumn<int>(
    'bg_color_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF2C5364),
  );
  static const VerificationMeta _bgImageMeta = const VerificationMeta(
    'bgImage',
  );
  @override
  late final GeneratedColumn<String> bgImage = GeneratedColumn<String>(
    'bg_image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bgDimMeta = const VerificationMeta('bgDim');
  @override
  late final GeneratedColumn<double> bgDim = GeneratedColumn<double>(
    'bg_dim',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.35),
  );
  static const VerificationMeta _surfaceOpacityMeta = const VerificationMeta(
    'surfaceOpacity',
  );
  @override
  late final GeneratedColumn<double> surfaceOpacity = GeneratedColumn<double>(
    'surface_opacity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.78),
  );
  static const VerificationMeta _surfaceBlurMeta = const VerificationMeta(
    'surfaceBlur',
  );
  @override
  late final GeneratedColumn<double> surfaceBlur = GeneratedColumn<double>(
    'surface_blur',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(18.0),
  );
  static const VerificationMeta _notifyFrequencyMeta = const VerificationMeta(
    'notifyFrequency',
  );
  @override
  late final GeneratedColumn<String> notifyFrequency = GeneratedColumn<String>(
    'notify_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _holidayRegionMeta = const VerificationMeta(
    'holidayRegion',
  );
  @override
  late final GeneratedColumn<String> holidayRegion = GeneratedColumn<String>(
    'holiday_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _scheduleNotifyMeta = const VerificationMeta(
    'scheduleNotify',
  );
  @override
  late final GeneratedColumn<bool> scheduleNotify = GeneratedColumn<bool>(
    'schedule_notify',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("schedule_notify" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _allowMultipleInstancesMeta =
      const VerificationMeta('allowMultipleInstances');
  @override
  late final GeneratedColumn<bool> allowMultipleInstances =
      GeneratedColumn<bool>(
        'allow_multiple_instances',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_multiple_instances" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    accentColor,
    density,
    bgMode,
    bgColorA,
    bgColorB,
    bgImage,
    bgDim,
    surfaceOpacity,
    surfaceBlur,
    notifyFrequency,
    holidayRegion,
    scheduleNotify,
    allowMultipleInstances,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    }
    if (data.containsKey('density')) {
      context.handle(
        _densityMeta,
        density.isAcceptableOrUnknown(data['density']!, _densityMeta),
      );
    }
    if (data.containsKey('bg_mode')) {
      context.handle(
        _bgModeMeta,
        bgMode.isAcceptableOrUnknown(data['bg_mode']!, _bgModeMeta),
      );
    }
    if (data.containsKey('bg_color_a')) {
      context.handle(
        _bgColorAMeta,
        bgColorA.isAcceptableOrUnknown(data['bg_color_a']!, _bgColorAMeta),
      );
    }
    if (data.containsKey('bg_color_b')) {
      context.handle(
        _bgColorBMeta,
        bgColorB.isAcceptableOrUnknown(data['bg_color_b']!, _bgColorBMeta),
      );
    }
    if (data.containsKey('bg_image')) {
      context.handle(
        _bgImageMeta,
        bgImage.isAcceptableOrUnknown(data['bg_image']!, _bgImageMeta),
      );
    }
    if (data.containsKey('bg_dim')) {
      context.handle(
        _bgDimMeta,
        bgDim.isAcceptableOrUnknown(data['bg_dim']!, _bgDimMeta),
      );
    }
    if (data.containsKey('surface_opacity')) {
      context.handle(
        _surfaceOpacityMeta,
        surfaceOpacity.isAcceptableOrUnknown(
          data['surface_opacity']!,
          _surfaceOpacityMeta,
        ),
      );
    }
    if (data.containsKey('surface_blur')) {
      context.handle(
        _surfaceBlurMeta,
        surfaceBlur.isAcceptableOrUnknown(
          data['surface_blur']!,
          _surfaceBlurMeta,
        ),
      );
    }
    if (data.containsKey('notify_frequency')) {
      context.handle(
        _notifyFrequencyMeta,
        notifyFrequency.isAcceptableOrUnknown(
          data['notify_frequency']!,
          _notifyFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('holiday_region')) {
      context.handle(
        _holidayRegionMeta,
        holidayRegion.isAcceptableOrUnknown(
          data['holiday_region']!,
          _holidayRegionMeta,
        ),
      );
    }
    if (data.containsKey('schedule_notify')) {
      context.handle(
        _scheduleNotifyMeta,
        scheduleNotify.isAcceptableOrUnknown(
          data['schedule_notify']!,
          _scheduleNotifyMeta,
        ),
      );
    }
    if (data.containsKey('allow_multiple_instances')) {
      context.handle(
        _allowMultipleInstancesMeta,
        allowMultipleInstances.isAcceptableOrUnknown(
          data['allow_multiple_instances']!,
          _allowMultipleInstancesMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color'],
      )!,
      density: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}density'],
      )!,
      bgMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bg_mode'],
      )!,
      bgColorA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bg_color_a'],
      )!,
      bgColorB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bg_color_b'],
      )!,
      bgImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bg_image'],
      )!,
      bgDim: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bg_dim'],
      )!,
      surfaceOpacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}surface_opacity'],
      )!,
      surfaceBlur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}surface_blur'],
      )!,
      notifyFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notify_frequency'],
      )!,
      holidayRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holiday_region'],
      )!,
      scheduleNotify: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}schedule_notify'],
      )!,
      allowMultipleInstances: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_multiple_instances'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String themeMode;
  final int accentColor;
  final String density;
  final String bgMode;
  final int bgColorA;
  final int bgColorB;
  final String bgImage;
  final double bgDim;
  final double surfaceOpacity;
  final double surfaceBlur;
  final String notifyFrequency;
  final String holidayRegion;
  final bool scheduleNotify;
  final bool allowMultipleInstances;
  final DateTime updatedAt;
  const AppSetting({
    required this.id,
    required this.themeMode,
    required this.accentColor,
    required this.density,
    required this.bgMode,
    required this.bgColorA,
    required this.bgColorB,
    required this.bgImage,
    required this.bgDim,
    required this.surfaceOpacity,
    required this.surfaceBlur,
    required this.notifyFrequency,
    required this.holidayRegion,
    required this.scheduleNotify,
    required this.allowMultipleInstances,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['accent_color'] = Variable<int>(accentColor);
    map['density'] = Variable<String>(density);
    map['bg_mode'] = Variable<String>(bgMode);
    map['bg_color_a'] = Variable<int>(bgColorA);
    map['bg_color_b'] = Variable<int>(bgColorB);
    map['bg_image'] = Variable<String>(bgImage);
    map['bg_dim'] = Variable<double>(bgDim);
    map['surface_opacity'] = Variable<double>(surfaceOpacity);
    map['surface_blur'] = Variable<double>(surfaceBlur);
    map['notify_frequency'] = Variable<String>(notifyFrequency);
    map['holiday_region'] = Variable<String>(holidayRegion);
    map['schedule_notify'] = Variable<bool>(scheduleNotify);
    map['allow_multiple_instances'] = Variable<bool>(allowMultipleInstances);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      accentColor: Value(accentColor),
      density: Value(density),
      bgMode: Value(bgMode),
      bgColorA: Value(bgColorA),
      bgColorB: Value(bgColorB),
      bgImage: Value(bgImage),
      bgDim: Value(bgDim),
      surfaceOpacity: Value(surfaceOpacity),
      surfaceBlur: Value(surfaceBlur),
      notifyFrequency: Value(notifyFrequency),
      holidayRegion: Value(holidayRegion),
      scheduleNotify: Value(scheduleNotify),
      allowMultipleInstances: Value(allowMultipleInstances),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      accentColor: serializer.fromJson<int>(json['accentColor']),
      density: serializer.fromJson<String>(json['density']),
      bgMode: serializer.fromJson<String>(json['bgMode']),
      bgColorA: serializer.fromJson<int>(json['bgColorA']),
      bgColorB: serializer.fromJson<int>(json['bgColorB']),
      bgImage: serializer.fromJson<String>(json['bgImage']),
      bgDim: serializer.fromJson<double>(json['bgDim']),
      surfaceOpacity: serializer.fromJson<double>(json['surfaceOpacity']),
      surfaceBlur: serializer.fromJson<double>(json['surfaceBlur']),
      notifyFrequency: serializer.fromJson<String>(json['notifyFrequency']),
      holidayRegion: serializer.fromJson<String>(json['holidayRegion']),
      scheduleNotify: serializer.fromJson<bool>(json['scheduleNotify']),
      allowMultipleInstances: serializer.fromJson<bool>(
        json['allowMultipleInstances'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'accentColor': serializer.toJson<int>(accentColor),
      'density': serializer.toJson<String>(density),
      'bgMode': serializer.toJson<String>(bgMode),
      'bgColorA': serializer.toJson<int>(bgColorA),
      'bgColorB': serializer.toJson<int>(bgColorB),
      'bgImage': serializer.toJson<String>(bgImage),
      'bgDim': serializer.toJson<double>(bgDim),
      'surfaceOpacity': serializer.toJson<double>(surfaceOpacity),
      'surfaceBlur': serializer.toJson<double>(surfaceBlur),
      'notifyFrequency': serializer.toJson<String>(notifyFrequency),
      'holidayRegion': serializer.toJson<String>(holidayRegion),
      'scheduleNotify': serializer.toJson<bool>(scheduleNotify),
      'allowMultipleInstances': serializer.toJson<bool>(allowMultipleInstances),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    int? id,
    String? themeMode,
    int? accentColor,
    String? density,
    String? bgMode,
    int? bgColorA,
    int? bgColorB,
    String? bgImage,
    double? bgDim,
    double? surfaceOpacity,
    double? surfaceBlur,
    String? notifyFrequency,
    String? holidayRegion,
    bool? scheduleNotify,
    bool? allowMultipleInstances,
    DateTime? updatedAt,
  }) => AppSetting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    accentColor: accentColor ?? this.accentColor,
    density: density ?? this.density,
    bgMode: bgMode ?? this.bgMode,
    bgColorA: bgColorA ?? this.bgColorA,
    bgColorB: bgColorB ?? this.bgColorB,
    bgImage: bgImage ?? this.bgImage,
    bgDim: bgDim ?? this.bgDim,
    surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
    surfaceBlur: surfaceBlur ?? this.surfaceBlur,
    notifyFrequency: notifyFrequency ?? this.notifyFrequency,
    holidayRegion: holidayRegion ?? this.holidayRegion,
    scheduleNotify: scheduleNotify ?? this.scheduleNotify,
    allowMultipleInstances:
        allowMultipleInstances ?? this.allowMultipleInstances,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      density: data.density.present ? data.density.value : this.density,
      bgMode: data.bgMode.present ? data.bgMode.value : this.bgMode,
      bgColorA: data.bgColorA.present ? data.bgColorA.value : this.bgColorA,
      bgColorB: data.bgColorB.present ? data.bgColorB.value : this.bgColorB,
      bgImage: data.bgImage.present ? data.bgImage.value : this.bgImage,
      bgDim: data.bgDim.present ? data.bgDim.value : this.bgDim,
      surfaceOpacity: data.surfaceOpacity.present
          ? data.surfaceOpacity.value
          : this.surfaceOpacity,
      surfaceBlur: data.surfaceBlur.present
          ? data.surfaceBlur.value
          : this.surfaceBlur,
      notifyFrequency: data.notifyFrequency.present
          ? data.notifyFrequency.value
          : this.notifyFrequency,
      holidayRegion: data.holidayRegion.present
          ? data.holidayRegion.value
          : this.holidayRegion,
      scheduleNotify: data.scheduleNotify.present
          ? data.scheduleNotify.value
          : this.scheduleNotify,
      allowMultipleInstances: data.allowMultipleInstances.present
          ? data.allowMultipleInstances.value
          : this.allowMultipleInstances,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('accentColor: $accentColor, ')
          ..write('density: $density, ')
          ..write('bgMode: $bgMode, ')
          ..write('bgColorA: $bgColorA, ')
          ..write('bgColorB: $bgColorB, ')
          ..write('bgImage: $bgImage, ')
          ..write('bgDim: $bgDim, ')
          ..write('surfaceOpacity: $surfaceOpacity, ')
          ..write('surfaceBlur: $surfaceBlur, ')
          ..write('notifyFrequency: $notifyFrequency, ')
          ..write('holidayRegion: $holidayRegion, ')
          ..write('scheduleNotify: $scheduleNotify, ')
          ..write('allowMultipleInstances: $allowMultipleInstances, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    accentColor,
    density,
    bgMode,
    bgColorA,
    bgColorB,
    bgImage,
    bgDim,
    surfaceOpacity,
    surfaceBlur,
    notifyFrequency,
    holidayRegion,
    scheduleNotify,
    allowMultipleInstances,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.accentColor == this.accentColor &&
          other.density == this.density &&
          other.bgMode == this.bgMode &&
          other.bgColorA == this.bgColorA &&
          other.bgColorB == this.bgColorB &&
          other.bgImage == this.bgImage &&
          other.bgDim == this.bgDim &&
          other.surfaceOpacity == this.surfaceOpacity &&
          other.surfaceBlur == this.surfaceBlur &&
          other.notifyFrequency == this.notifyFrequency &&
          other.holidayRegion == this.holidayRegion &&
          other.scheduleNotify == this.scheduleNotify &&
          other.allowMultipleInstances == this.allowMultipleInstances &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<int> accentColor;
  final Value<String> density;
  final Value<String> bgMode;
  final Value<int> bgColorA;
  final Value<int> bgColorB;
  final Value<String> bgImage;
  final Value<double> bgDim;
  final Value<double> surfaceOpacity;
  final Value<double> surfaceBlur;
  final Value<String> notifyFrequency;
  final Value<String> holidayRegion;
  final Value<bool> scheduleNotify;
  final Value<bool> allowMultipleInstances;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.density = const Value.absent(),
    this.bgMode = const Value.absent(),
    this.bgColorA = const Value.absent(),
    this.bgColorB = const Value.absent(),
    this.bgImage = const Value.absent(),
    this.bgDim = const Value.absent(),
    this.surfaceOpacity = const Value.absent(),
    this.surfaceBlur = const Value.absent(),
    this.notifyFrequency = const Value.absent(),
    this.holidayRegion = const Value.absent(),
    this.scheduleNotify = const Value.absent(),
    this.allowMultipleInstances = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.density = const Value.absent(),
    this.bgMode = const Value.absent(),
    this.bgColorA = const Value.absent(),
    this.bgColorB = const Value.absent(),
    this.bgImage = const Value.absent(),
    this.bgDim = const Value.absent(),
    this.surfaceOpacity = const Value.absent(),
    this.surfaceBlur = const Value.absent(),
    this.notifyFrequency = const Value.absent(),
    this.holidayRegion = const Value.absent(),
    this.scheduleNotify = const Value.absent(),
    this.allowMultipleInstances = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<int>? accentColor,
    Expression<String>? density,
    Expression<String>? bgMode,
    Expression<int>? bgColorA,
    Expression<int>? bgColorB,
    Expression<String>? bgImage,
    Expression<double>? bgDim,
    Expression<double>? surfaceOpacity,
    Expression<double>? surfaceBlur,
    Expression<String>? notifyFrequency,
    Expression<String>? holidayRegion,
    Expression<bool>? scheduleNotify,
    Expression<bool>? allowMultipleInstances,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (accentColor != null) 'accent_color': accentColor,
      if (density != null) 'density': density,
      if (bgMode != null) 'bg_mode': bgMode,
      if (bgColorA != null) 'bg_color_a': bgColorA,
      if (bgColorB != null) 'bg_color_b': bgColorB,
      if (bgImage != null) 'bg_image': bgImage,
      if (bgDim != null) 'bg_dim': bgDim,
      if (surfaceOpacity != null) 'surface_opacity': surfaceOpacity,
      if (surfaceBlur != null) 'surface_blur': surfaceBlur,
      if (notifyFrequency != null) 'notify_frequency': notifyFrequency,
      if (holidayRegion != null) 'holiday_region': holidayRegion,
      if (scheduleNotify != null) 'schedule_notify': scheduleNotify,
      if (allowMultipleInstances != null)
        'allow_multiple_instances': allowMultipleInstances,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<int>? accentColor,
    Value<String>? density,
    Value<String>? bgMode,
    Value<int>? bgColorA,
    Value<int>? bgColorB,
    Value<String>? bgImage,
    Value<double>? bgDim,
    Value<double>? surfaceOpacity,
    Value<double>? surfaceBlur,
    Value<String>? notifyFrequency,
    Value<String>? holidayRegion,
    Value<bool>? scheduleNotify,
    Value<bool>? allowMultipleInstances,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      density: density ?? this.density,
      bgMode: bgMode ?? this.bgMode,
      bgColorA: bgColorA ?? this.bgColorA,
      bgColorB: bgColorB ?? this.bgColorB,
      bgImage: bgImage ?? this.bgImage,
      bgDim: bgDim ?? this.bgDim,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
      notifyFrequency: notifyFrequency ?? this.notifyFrequency,
      holidayRegion: holidayRegion ?? this.holidayRegion,
      scheduleNotify: scheduleNotify ?? this.scheduleNotify,
      allowMultipleInstances:
          allowMultipleInstances ?? this.allowMultipleInstances,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<int>(accentColor.value);
    }
    if (density.present) {
      map['density'] = Variable<String>(density.value);
    }
    if (bgMode.present) {
      map['bg_mode'] = Variable<String>(bgMode.value);
    }
    if (bgColorA.present) {
      map['bg_color_a'] = Variable<int>(bgColorA.value);
    }
    if (bgColorB.present) {
      map['bg_color_b'] = Variable<int>(bgColorB.value);
    }
    if (bgImage.present) {
      map['bg_image'] = Variable<String>(bgImage.value);
    }
    if (bgDim.present) {
      map['bg_dim'] = Variable<double>(bgDim.value);
    }
    if (surfaceOpacity.present) {
      map['surface_opacity'] = Variable<double>(surfaceOpacity.value);
    }
    if (surfaceBlur.present) {
      map['surface_blur'] = Variable<double>(surfaceBlur.value);
    }
    if (notifyFrequency.present) {
      map['notify_frequency'] = Variable<String>(notifyFrequency.value);
    }
    if (holidayRegion.present) {
      map['holiday_region'] = Variable<String>(holidayRegion.value);
    }
    if (scheduleNotify.present) {
      map['schedule_notify'] = Variable<bool>(scheduleNotify.value);
    }
    if (allowMultipleInstances.present) {
      map['allow_multiple_instances'] = Variable<bool>(
        allowMultipleInstances.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('accentColor: $accentColor, ')
          ..write('density: $density, ')
          ..write('bgMode: $bgMode, ')
          ..write('bgColorA: $bgColorA, ')
          ..write('bgColorB: $bgColorB, ')
          ..write('bgImage: $bgImage, ')
          ..write('bgDim: $bgDim, ')
          ..write('surfaceOpacity: $surfaceOpacity, ')
          ..write('surfaceBlur: $surfaceBlur, ')
          ..write('notifyFrequency: $notifyFrequency, ')
          ..write('holidayRegion: $holidayRegion, ')
          ..write('scheduleNotify: $scheduleNotify, ')
          ..write('allowMultipleInstances: $allowMultipleInstances, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CulturesTable extends Cultures with TableInfo<$CulturesTable, Culture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CulturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _strainIdMeta = const VerificationMeta(
    'strainId',
  );
  @override
  late final GeneratedColumn<String> strainId = GeneratedColumn<String>(
    'strain_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strains (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _mediumMeta = const VerificationMeta('medium');
  @override
  late final GeneratedColumn<String> medium = GeneratedColumn<String>(
    'medium',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vesselMeta = const VerificationMeta('vessel');
  @override
  late final GeneratedColumn<String> vessel = GeneratedColumn<String>(
    'vessel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startedDateMeta = const VerificationMeta(
    'startedDate',
  );
  @override
  late final GeneratedColumn<DateTime> startedDate = GeneratedColumn<DateTime>(
    'started_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _endedDateMeta = const VerificationMeta(
    'endedDate',
  );
  @override
  late final GeneratedColumn<DateTime> endedDate = GeneratedColumn<DateTime>(
    'ended_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _inoculumAmountMeta = const VerificationMeta(
    'inoculumAmount',
  );
  @override
  late final GeneratedColumn<String> inoculumAmount = GeneratedColumn<String>(
    'inoculum_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  selectionMarkers = GeneratedColumn<String>(
    'selection_markers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CulturesTable.$converterselectionMarkers);
  static const VerificationMeta _parentCultureIdMeta = const VerificationMeta(
    'parentCultureId',
  );
  @override
  late final GeneratedColumn<String> parentCultureId = GeneratedColumn<String>(
    'parent_culture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentInoculatedAtMeta =
      const VerificationMeta('parentInoculatedAt');
  @override
  late final GeneratedColumn<DateTime> parentInoculatedAt =
      GeneratedColumn<DateTime>(
        'parent_inoculated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    strainId,
    status,
    medium,
    vessel,
    startedDate,
    endedDate,
    notes,
    purpose,
    inoculumAmount,
    selectionMarkers,
    parentCultureId,
    parentInoculatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cultures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Culture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('strain_id')) {
      context.handle(
        _strainIdMeta,
        strainId.isAcceptableOrUnknown(data['strain_id']!, _strainIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('medium')) {
      context.handle(
        _mediumMeta,
        medium.isAcceptableOrUnknown(data['medium']!, _mediumMeta),
      );
    }
    if (data.containsKey('vessel')) {
      context.handle(
        _vesselMeta,
        vessel.isAcceptableOrUnknown(data['vessel']!, _vesselMeta),
      );
    }
    if (data.containsKey('started_date')) {
      context.handle(
        _startedDateMeta,
        startedDate.isAcceptableOrUnknown(
          data['started_date']!,
          _startedDateMeta,
        ),
      );
    }
    if (data.containsKey('ended_date')) {
      context.handle(
        _endedDateMeta,
        endedDate.isAcceptableOrUnknown(data['ended_date']!, _endedDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('inoculum_amount')) {
      context.handle(
        _inoculumAmountMeta,
        inoculumAmount.isAcceptableOrUnknown(
          data['inoculum_amount']!,
          _inoculumAmountMeta,
        ),
      );
    }
    if (data.containsKey('parent_culture_id')) {
      context.handle(
        _parentCultureIdMeta,
        parentCultureId.isAcceptableOrUnknown(
          data['parent_culture_id']!,
          _parentCultureIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_inoculated_at')) {
      context.handle(
        _parentInoculatedAtMeta,
        parentInoculatedAt.isAcceptableOrUnknown(
          data['parent_inoculated_at']!,
          _parentInoculatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Culture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Culture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      strainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strain_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      medium: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medium'],
      )!,
      vessel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel'],
      )!,
      startedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_date'],
      )!,
      endedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      inoculumAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inoculum_amount'],
      )!,
      selectionMarkers: $CulturesTable.$converterselectionMarkers.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selection_markers'],
        )!,
      ),
      parentCultureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_culture_id'],
      ),
      parentInoculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}parent_inoculated_at'],
      ),
    );
  }

  @override
  $CulturesTable createAlias(String alias) {
    return $CulturesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterselectionMarkers =
      const StringListConverter();
}

class Culture extends DataClass implements Insertable<Culture> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;
  final String? strainId;
  final String status;
  final String medium;
  final String vessel;
  final DateTime startedDate;
  final DateTime? endedDate;
  final String notes;

  /// Why this culture was started (free text) — shown on the printable culture
  /// label.
  final String purpose;
  final String inoculumAmount;

  /// Selection markers this culture is grown under (defaults from the strain but
  /// editable per culture). JSON array.
  final List<String> selectionMarkers;
  final String? parentCultureId;
  final DateTime? parentInoculatedAt;
  const Culture({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    this.strainId,
    required this.status,
    required this.medium,
    required this.vessel,
    required this.startedDate,
    this.endedDate,
    required this.notes,
    required this.purpose,
    required this.inoculumAmount,
    required this.selectionMarkers,
    this.parentCultureId,
    this.parentInoculatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || strainId != null) {
      map['strain_id'] = Variable<String>(strainId);
    }
    map['status'] = Variable<String>(status);
    map['medium'] = Variable<String>(medium);
    map['vessel'] = Variable<String>(vessel);
    map['started_date'] = Variable<DateTime>(startedDate);
    if (!nullToAbsent || endedDate != null) {
      map['ended_date'] = Variable<DateTime>(endedDate);
    }
    map['notes'] = Variable<String>(notes);
    map['purpose'] = Variable<String>(purpose);
    map['inoculum_amount'] = Variable<String>(inoculumAmount);
    {
      map['selection_markers'] = Variable<String>(
        $CulturesTable.$converterselectionMarkers.toSql(selectionMarkers),
      );
    }
    if (!nullToAbsent || parentCultureId != null) {
      map['parent_culture_id'] = Variable<String>(parentCultureId);
    }
    if (!nullToAbsent || parentInoculatedAt != null) {
      map['parent_inoculated_at'] = Variable<DateTime>(parentInoculatedAt);
    }
    return map;
  }

  CulturesCompanion toCompanion(bool nullToAbsent) {
    return CulturesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      strainId: strainId == null && nullToAbsent
          ? const Value.absent()
          : Value(strainId),
      status: Value(status),
      medium: Value(medium),
      vessel: Value(vessel),
      startedDate: Value(startedDate),
      endedDate: endedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endedDate),
      notes: Value(notes),
      purpose: Value(purpose),
      inoculumAmount: Value(inoculumAmount),
      selectionMarkers: Value(selectionMarkers),
      parentCultureId: parentCultureId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCultureId),
      parentInoculatedAt: parentInoculatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(parentInoculatedAt),
    );
  }

  factory Culture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Culture(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      strainId: serializer.fromJson<String?>(json['strainId']),
      status: serializer.fromJson<String>(json['status']),
      medium: serializer.fromJson<String>(json['medium']),
      vessel: serializer.fromJson<String>(json['vessel']),
      startedDate: serializer.fromJson<DateTime>(json['startedDate']),
      endedDate: serializer.fromJson<DateTime?>(json['endedDate']),
      notes: serializer.fromJson<String>(json['notes']),
      purpose: serializer.fromJson<String>(json['purpose']),
      inoculumAmount: serializer.fromJson<String>(json['inoculumAmount']),
      selectionMarkers: serializer.fromJson<List<String>>(
        json['selectionMarkers'],
      ),
      parentCultureId: serializer.fromJson<String?>(json['parentCultureId']),
      parentInoculatedAt: serializer.fromJson<DateTime?>(
        json['parentInoculatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'strainId': serializer.toJson<String?>(strainId),
      'status': serializer.toJson<String>(status),
      'medium': serializer.toJson<String>(medium),
      'vessel': serializer.toJson<String>(vessel),
      'startedDate': serializer.toJson<DateTime>(startedDate),
      'endedDate': serializer.toJson<DateTime?>(endedDate),
      'notes': serializer.toJson<String>(notes),
      'purpose': serializer.toJson<String>(purpose),
      'inoculumAmount': serializer.toJson<String>(inoculumAmount),
      'selectionMarkers': serializer.toJson<List<String>>(selectionMarkers),
      'parentCultureId': serializer.toJson<String?>(parentCultureId),
      'parentInoculatedAt': serializer.toJson<DateTime?>(parentInoculatedAt),
    };
  }

  Culture copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    Value<String?> strainId = const Value.absent(),
    String? status,
    String? medium,
    String? vessel,
    DateTime? startedDate,
    Value<DateTime?> endedDate = const Value.absent(),
    String? notes,
    String? purpose,
    String? inoculumAmount,
    List<String>? selectionMarkers,
    Value<String?> parentCultureId = const Value.absent(),
    Value<DateTime?> parentInoculatedAt = const Value.absent(),
  }) => Culture(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    strainId: strainId.present ? strainId.value : this.strainId,
    status: status ?? this.status,
    medium: medium ?? this.medium,
    vessel: vessel ?? this.vessel,
    startedDate: startedDate ?? this.startedDate,
    endedDate: endedDate.present ? endedDate.value : this.endedDate,
    notes: notes ?? this.notes,
    purpose: purpose ?? this.purpose,
    inoculumAmount: inoculumAmount ?? this.inoculumAmount,
    selectionMarkers: selectionMarkers ?? this.selectionMarkers,
    parentCultureId: parentCultureId.present
        ? parentCultureId.value
        : this.parentCultureId,
    parentInoculatedAt: parentInoculatedAt.present
        ? parentInoculatedAt.value
        : this.parentInoculatedAt,
  );
  Culture copyWithCompanion(CulturesCompanion data) {
    return Culture(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      strainId: data.strainId.present ? data.strainId.value : this.strainId,
      status: data.status.present ? data.status.value : this.status,
      medium: data.medium.present ? data.medium.value : this.medium,
      vessel: data.vessel.present ? data.vessel.value : this.vessel,
      startedDate: data.startedDate.present
          ? data.startedDate.value
          : this.startedDate,
      endedDate: data.endedDate.present ? data.endedDate.value : this.endedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      inoculumAmount: data.inoculumAmount.present
          ? data.inoculumAmount.value
          : this.inoculumAmount,
      selectionMarkers: data.selectionMarkers.present
          ? data.selectionMarkers.value
          : this.selectionMarkers,
      parentCultureId: data.parentCultureId.present
          ? data.parentCultureId.value
          : this.parentCultureId,
      parentInoculatedAt: data.parentInoculatedAt.present
          ? data.parentInoculatedAt.value
          : this.parentInoculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Culture(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('strainId: $strainId, ')
          ..write('status: $status, ')
          ..write('medium: $medium, ')
          ..write('vessel: $vessel, ')
          ..write('startedDate: $startedDate, ')
          ..write('endedDate: $endedDate, ')
          ..write('notes: $notes, ')
          ..write('purpose: $purpose, ')
          ..write('inoculumAmount: $inoculumAmount, ')
          ..write('selectionMarkers: $selectionMarkers, ')
          ..write('parentCultureId: $parentCultureId, ')
          ..write('parentInoculatedAt: $parentInoculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    strainId,
    status,
    medium,
    vessel,
    startedDate,
    endedDate,
    notes,
    purpose,
    inoculumAmount,
    selectionMarkers,
    parentCultureId,
    parentInoculatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Culture &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.strainId == this.strainId &&
          other.status == this.status &&
          other.medium == this.medium &&
          other.vessel == this.vessel &&
          other.startedDate == this.startedDate &&
          other.endedDate == this.endedDate &&
          other.notes == this.notes &&
          other.purpose == this.purpose &&
          other.inoculumAmount == this.inoculumAmount &&
          other.selectionMarkers == this.selectionMarkers &&
          other.parentCultureId == this.parentCultureId &&
          other.parentInoculatedAt == this.parentInoculatedAt);
}

class CulturesCompanion extends UpdateCompanion<Culture> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String?> strainId;
  final Value<String> status;
  final Value<String> medium;
  final Value<String> vessel;
  final Value<DateTime> startedDate;
  final Value<DateTime?> endedDate;
  final Value<String> notes;
  final Value<String> purpose;
  final Value<String> inoculumAmount;
  final Value<List<String>> selectionMarkers;
  final Value<String?> parentCultureId;
  final Value<DateTime?> parentInoculatedAt;
  final Value<int> rowid;
  const CulturesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.strainId = const Value.absent(),
    this.status = const Value.absent(),
    this.medium = const Value.absent(),
    this.vessel = const Value.absent(),
    this.startedDate = const Value.absent(),
    this.endedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.purpose = const Value.absent(),
    this.inoculumAmount = const Value.absent(),
    this.selectionMarkers = const Value.absent(),
    this.parentCultureId = const Value.absent(),
    this.parentInoculatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CulturesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.strainId = const Value.absent(),
    this.status = const Value.absent(),
    this.medium = const Value.absent(),
    this.vessel = const Value.absent(),
    this.startedDate = const Value.absent(),
    this.endedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.purpose = const Value.absent(),
    this.inoculumAmount = const Value.absent(),
    this.selectionMarkers = const Value.absent(),
    this.parentCultureId = const Value.absent(),
    this.parentInoculatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Culture> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? strainId,
    Expression<String>? status,
    Expression<String>? medium,
    Expression<String>? vessel,
    Expression<DateTime>? startedDate,
    Expression<DateTime>? endedDate,
    Expression<String>? notes,
    Expression<String>? purpose,
    Expression<String>? inoculumAmount,
    Expression<String>? selectionMarkers,
    Expression<String>? parentCultureId,
    Expression<DateTime>? parentInoculatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (strainId != null) 'strain_id': strainId,
      if (status != null) 'status': status,
      if (medium != null) 'medium': medium,
      if (vessel != null) 'vessel': vessel,
      if (startedDate != null) 'started_date': startedDate,
      if (endedDate != null) 'ended_date': endedDate,
      if (notes != null) 'notes': notes,
      if (purpose != null) 'purpose': purpose,
      if (inoculumAmount != null) 'inoculum_amount': inoculumAmount,
      if (selectionMarkers != null) 'selection_markers': selectionMarkers,
      if (parentCultureId != null) 'parent_culture_id': parentCultureId,
      if (parentInoculatedAt != null)
        'parent_inoculated_at': parentInoculatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CulturesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String?>? strainId,
    Value<String>? status,
    Value<String>? medium,
    Value<String>? vessel,
    Value<DateTime>? startedDate,
    Value<DateTime?>? endedDate,
    Value<String>? notes,
    Value<String>? purpose,
    Value<String>? inoculumAmount,
    Value<List<String>>? selectionMarkers,
    Value<String?>? parentCultureId,
    Value<DateTime?>? parentInoculatedAt,
    Value<int>? rowid,
  }) {
    return CulturesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      strainId: strainId ?? this.strainId,
      status: status ?? this.status,
      medium: medium ?? this.medium,
      vessel: vessel ?? this.vessel,
      startedDate: startedDate ?? this.startedDate,
      endedDate: endedDate ?? this.endedDate,
      notes: notes ?? this.notes,
      purpose: purpose ?? this.purpose,
      inoculumAmount: inoculumAmount ?? this.inoculumAmount,
      selectionMarkers: selectionMarkers ?? this.selectionMarkers,
      parentCultureId: parentCultureId ?? this.parentCultureId,
      parentInoculatedAt: parentInoculatedAt ?? this.parentInoculatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (strainId.present) {
      map['strain_id'] = Variable<String>(strainId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (medium.present) {
      map['medium'] = Variable<String>(medium.value);
    }
    if (vessel.present) {
      map['vessel'] = Variable<String>(vessel.value);
    }
    if (startedDate.present) {
      map['started_date'] = Variable<DateTime>(startedDate.value);
    }
    if (endedDate.present) {
      map['ended_date'] = Variable<DateTime>(endedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (inoculumAmount.present) {
      map['inoculum_amount'] = Variable<String>(inoculumAmount.value);
    }
    if (selectionMarkers.present) {
      map['selection_markers'] = Variable<String>(
        $CulturesTable.$converterselectionMarkers.toSql(selectionMarkers.value),
      );
    }
    if (parentCultureId.present) {
      map['parent_culture_id'] = Variable<String>(parentCultureId.value);
    }
    if (parentInoculatedAt.present) {
      map['parent_inoculated_at'] = Variable<DateTime>(
        parentInoculatedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CulturesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('strainId: $strainId, ')
          ..write('status: $status, ')
          ..write('medium: $medium, ')
          ..write('vessel: $vessel, ')
          ..write('startedDate: $startedDate, ')
          ..write('endedDate: $endedDate, ')
          ..write('notes: $notes, ')
          ..write('purpose: $purpose, ')
          ..write('inoculumAmount: $inoculumAmount, ')
          ..write('selectionMarkers: $selectionMarkers, ')
          ..write('parentCultureId: $parentCultureId, ')
          ..write('parentInoculatedAt: $parentInoculatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentUpdatesTable extends ExperimentUpdates
    with TableInfo<$ExperimentUpdatesTable, ExperimentUpdate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentUpdatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _experimentIdMeta = const VerificationMeta(
    'experimentId',
  );
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
    'experiment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES experiments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _happenedAtMeta = const VerificationMeta(
    'happenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> happenedAt = GeneratedColumn<DateTime>(
    'happened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    experimentId,
    happenedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiment_updates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExperimentUpdate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('experiment_id')) {
      context.handle(
        _experimentIdMeta,
        experimentId.isAcceptableOrUnknown(
          data['experiment_id']!,
          _experimentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_experimentIdMeta);
    }
    if (data.containsKey('happened_at')) {
      context.handle(
        _happenedAtMeta,
        happenedAt.isAcceptableOrUnknown(data['happened_at']!, _happenedAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExperimentUpdate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentUpdate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      experimentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experiment_id'],
      )!,
      happenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $ExperimentUpdatesTable createAlias(String alias) {
    return $ExperimentUpdatesTable(attachedDatabase, alias);
  }
}

class ExperimentUpdate extends DataClass
    implements Insertable<ExperimentUpdate> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String experimentId;
  final DateTime happenedAt;
  final String note;
  const ExperimentUpdate({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.experimentId,
    required this.happenedAt,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['experiment_id'] = Variable<String>(experimentId);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    map['note'] = Variable<String>(note);
    return map;
  }

  ExperimentUpdatesCompanion toCompanion(bool nullToAbsent) {
    return ExperimentUpdatesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      experimentId: Value(experimentId),
      happenedAt: Value(happenedAt),
      note: Value(note),
    );
  }

  factory ExperimentUpdate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentUpdate(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      experimentId: serializer.fromJson<String>(json['experimentId']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'experimentId': serializer.toJson<String>(experimentId),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
      'note': serializer.toJson<String>(note),
    };
  }

  ExperimentUpdate copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? experimentId,
    DateTime? happenedAt,
    String? note,
  }) => ExperimentUpdate(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    experimentId: experimentId ?? this.experimentId,
    happenedAt: happenedAt ?? this.happenedAt,
    note: note ?? this.note,
  );
  ExperimentUpdate copyWithCompanion(ExperimentUpdatesCompanion data) {
    return ExperimentUpdate(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
      happenedAt: data.happenedAt.present
          ? data.happenedAt.value
          : this.happenedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentUpdate(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('experimentId: $experimentId, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    experimentId,
    happenedAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentUpdate &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.experimentId == this.experimentId &&
          other.happenedAt == this.happenedAt &&
          other.note == this.note);
}

class ExperimentUpdatesCompanion extends UpdateCompanion<ExperimentUpdate> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> experimentId;
  final Value<DateTime> happenedAt;
  final Value<String> note;
  final Value<int> rowid;
  const ExperimentUpdatesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentUpdatesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String experimentId,
    this.happenedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : experimentId = Value(experimentId);
  static Insertable<ExperimentUpdate> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? experimentId,
    Expression<DateTime>? happenedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (experimentId != null) 'experiment_id': experimentId,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentUpdatesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? experimentId,
    Value<DateTime>? happenedAt,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return ExperimentUpdatesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      experimentId: experimentId ?? this.experimentId,
      happenedAt: happenedAt ?? this.happenedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<DateTime>(happenedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentUpdatesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('experimentId: $experimentId, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Progress report'),
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> projectIds =
      GeneratedColumn<String>(
        'project_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ReportsTable.$converterprojectIds);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  experimentIds = GeneratedColumn<String>(
    'experiment_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ReportsTable.$converterexperimentIds);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    recipient,
    author,
    periodStart,
    periodEnd,
    summary,
    projectIds,
    experimentIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      ),
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      projectIds: $ReportsTable.$converterprojectIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}project_ids'],
        )!,
      ),
      experimentIds: $ReportsTable.$converterexperimentIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}experiment_ids'],
        )!,
      ),
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterprojectIds =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterexperimentIds =
      const StringListConverter();
}

class Report extends DataClass implements Insertable<Report> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String title;
  final String recipient;
  final String author;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String summary;
  final List<String> projectIds;
  final List<String> experimentIds;
  const Report({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.title,
    required this.recipient,
    required this.author,
    this.periodStart,
    this.periodEnd,
    required this.summary,
    required this.projectIds,
    required this.experimentIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['title'] = Variable<String>(title);
    map['recipient'] = Variable<String>(recipient);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || periodStart != null) {
      map['period_start'] = Variable<DateTime>(periodStart);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    map['summary'] = Variable<String>(summary);
    {
      map['project_ids'] = Variable<String>(
        $ReportsTable.$converterprojectIds.toSql(projectIds),
      );
    }
    {
      map['experiment_ids'] = Variable<String>(
        $ReportsTable.$converterexperimentIds.toSql(experimentIds),
      );
    }
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      title: Value(title),
      recipient: Value(recipient),
      author: Value(author),
      periodStart: periodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(periodStart),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      summary: Value(summary),
      projectIds: Value(projectIds),
      experimentIds: Value(experimentIds),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      recipient: serializer.fromJson<String>(json['recipient']),
      author: serializer.fromJson<String>(json['author']),
      periodStart: serializer.fromJson<DateTime?>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      summary: serializer.fromJson<String>(json['summary']),
      projectIds: serializer.fromJson<List<String>>(json['projectIds']),
      experimentIds: serializer.fromJson<List<String>>(json['experimentIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'title': serializer.toJson<String>(title),
      'recipient': serializer.toJson<String>(recipient),
      'author': serializer.toJson<String>(author),
      'periodStart': serializer.toJson<DateTime?>(periodStart),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'summary': serializer.toJson<String>(summary),
      'projectIds': serializer.toJson<List<String>>(projectIds),
      'experimentIds': serializer.toJson<List<String>>(experimentIds),
    };
  }

  Report copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? title,
    String? recipient,
    String? author,
    Value<DateTime?> periodStart = const Value.absent(),
    Value<DateTime?> periodEnd = const Value.absent(),
    String? summary,
    List<String>? projectIds,
    List<String>? experimentIds,
  }) => Report(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    recipient: recipient ?? this.recipient,
    author: author ?? this.author,
    periodStart: periodStart.present ? periodStart.value : this.periodStart,
    periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
    summary: summary ?? this.summary,
    projectIds: projectIds ?? this.projectIds,
    experimentIds: experimentIds ?? this.experimentIds,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      author: data.author.present ? data.author.value : this.author,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      summary: data.summary.present ? data.summary.value : this.summary,
      projectIds: data.projectIds.present
          ? data.projectIds.value
          : this.projectIds,
      experimentIds: data.experimentIds.present
          ? data.experimentIds.value
          : this.experimentIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('recipient: $recipient, ')
          ..write('author: $author, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('summary: $summary, ')
          ..write('projectIds: $projectIds, ')
          ..write('experimentIds: $experimentIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    recipient,
    author,
    periodStart,
    periodEnd,
    summary,
    projectIds,
    experimentIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.recipient == this.recipient &&
          other.author == this.author &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.summary == this.summary &&
          other.projectIds == this.projectIds &&
          other.experimentIds == this.experimentIds);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> title;
  final Value<String> recipient;
  final Value<String> author;
  final Value<DateTime?> periodStart;
  final Value<DateTime?> periodEnd;
  final Value<String> summary;
  final Value<List<String>> projectIds;
  final Value<List<String>> experimentIds;
  final Value<int> rowid;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.recipient = const Value.absent(),
    this.author = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.summary = const Value.absent(),
    this.projectIds = const Value.absent(),
    this.experimentIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.recipient = const Value.absent(),
    this.author = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.summary = const Value.absent(),
    this.projectIds = const Value.absent(),
    this.experimentIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Report> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? title,
    Expression<String>? recipient,
    Expression<String>? author,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<String>? summary,
    Expression<String>? projectIds,
    Expression<String>? experimentIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (recipient != null) 'recipient': recipient,
      if (author != null) 'author': author,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (summary != null) 'summary': summary,
      if (projectIds != null) 'project_ids': projectIds,
      if (experimentIds != null) 'experiment_ids': experimentIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? title,
    Value<String>? recipient,
    Value<String>? author,
    Value<DateTime?>? periodStart,
    Value<DateTime?>? periodEnd,
    Value<String>? summary,
    Value<List<String>>? projectIds,
    Value<List<String>>? experimentIds,
    Value<int>? rowid,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      author: author ?? this.author,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      summary: summary ?? this.summary,
      projectIds: projectIds ?? this.projectIds,
      experimentIds: experimentIds ?? this.experimentIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (projectIds.present) {
      map['project_ids'] = Variable<String>(
        $ReportsTable.$converterprojectIds.toSql(projectIds.value),
      );
    }
    if (experimentIds.present) {
      map['experiment_ids'] = Variable<String>(
        $ReportsTable.$converterexperimentIds.toSql(experimentIds.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('recipient: $recipient, ')
          ..write('author: $author, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('summary: $summary, ')
          ..write('projectIds: $projectIds, ')
          ..write('experimentIds: $experimentIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProtocolsTable extends Protocols
    with TableInfo<$ProtocolsTable, Protocol> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProtocolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> steps =
      GeneratedColumn<String>(
        'steps',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProtocolsTable.$convertersteps);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> stepIds =
      GeneratedColumn<String>(
        'step_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProtocolsTable.$converterstepIds);
  static const VerificationMeta _materialsMeta = const VerificationMeta(
    'materials',
  );
  @override
  late final GeneratedColumn<String> materials = GeneratedColumn<String>(
    'materials',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    category,
    summary,
    steps,
    stepIds,
    materials,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'protocols';
  @override
  VerificationContext validateIntegrity(
    Insertable<Protocol> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('materials')) {
      context.handle(
        _materialsMeta,
        materials.isAcceptableOrUnknown(data['materials']!, _materialsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Protocol map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Protocol(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      steps: $ProtocolsTable.$convertersteps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}steps'],
        )!,
      ),
      stepIds: $ProtocolsTable.$converterstepIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}step_ids'],
        )!,
      ),
      materials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materials'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ProtocolsTable createAlias(String alias) {
    return $ProtocolsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersteps =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterstepIds =
      const StringListConverter();
}

class Protocol extends DataClass implements Insertable<Protocol> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;
  final String category;
  final String summary;

  /// The procedure written as ordered steps (JSON array of strings).
  final List<String> steps;

  /// Stable per-step ids, parallel to [steps], so attached images can reference a
  /// step even when steps are reordered. Empty for protocols created before this
  /// was added — the editor backfills ids on first edit.
  final List<String> stepIds;
  final String materials;
  final String notes;
  const Protocol({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    required this.category,
    required this.summary,
    required this.steps,
    required this.stepIds,
    required this.materials,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['summary'] = Variable<String>(summary);
    {
      map['steps'] = Variable<String>(
        $ProtocolsTable.$convertersteps.toSql(steps),
      );
    }
    {
      map['step_ids'] = Variable<String>(
        $ProtocolsTable.$converterstepIds.toSql(stepIds),
      );
    }
    map['materials'] = Variable<String>(materials);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ProtocolsCompanion toCompanion(bool nullToAbsent) {
    return ProtocolsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      category: Value(category),
      summary: Value(summary),
      steps: Value(steps),
      stepIds: Value(stepIds),
      materials: Value(materials),
      notes: Value(notes),
    );
  }

  factory Protocol.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Protocol(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      summary: serializer.fromJson<String>(json['summary']),
      steps: serializer.fromJson<List<String>>(json['steps']),
      stepIds: serializer.fromJson<List<String>>(json['stepIds']),
      materials: serializer.fromJson<String>(json['materials']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'summary': serializer.toJson<String>(summary),
      'steps': serializer.toJson<List<String>>(steps),
      'stepIds': serializer.toJson<List<String>>(stepIds),
      'materials': serializer.toJson<String>(materials),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Protocol copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    String? category,
    String? summary,
    List<String>? steps,
    List<String>? stepIds,
    String? materials,
    String? notes,
  }) => Protocol(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    category: category ?? this.category,
    summary: summary ?? this.summary,
    steps: steps ?? this.steps,
    stepIds: stepIds ?? this.stepIds,
    materials: materials ?? this.materials,
    notes: notes ?? this.notes,
  );
  Protocol copyWithCompanion(ProtocolsCompanion data) {
    return Protocol(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      summary: data.summary.present ? data.summary.value : this.summary,
      steps: data.steps.present ? data.steps.value : this.steps,
      stepIds: data.stepIds.present ? data.stepIds.value : this.stepIds,
      materials: data.materials.present ? data.materials.value : this.materials,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Protocol(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('steps: $steps, ')
          ..write('stepIds: $stepIds, ')
          ..write('materials: $materials, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    category,
    summary,
    steps,
    stepIds,
    materials,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Protocol &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.category == this.category &&
          other.summary == this.summary &&
          other.steps == this.steps &&
          other.stepIds == this.stepIds &&
          other.materials == this.materials &&
          other.notes == this.notes);
}

class ProtocolsCompanion extends UpdateCompanion<Protocol> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> summary;
  final Value<List<String>> steps;
  final Value<List<String>> stepIds;
  final Value<String> materials;
  final Value<String> notes;
  final Value<int> rowid;
  const ProtocolsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.summary = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepIds = const Value.absent(),
    this.materials = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProtocolsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.summary = const Value.absent(),
    this.steps = const Value.absent(),
    this.stepIds = const Value.absent(),
    this.materials = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Protocol> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? summary,
    Expression<String>? steps,
    Expression<String>? stepIds,
    Expression<String>? materials,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (summary != null) 'summary': summary,
      if (steps != null) 'steps': steps,
      if (stepIds != null) 'step_ids': stepIds,
      if (materials != null) 'materials': materials,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProtocolsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? category,
    Value<String>? summary,
    Value<List<String>>? steps,
    Value<List<String>>? stepIds,
    Value<String>? materials,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ProtocolsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      steps: steps ?? this.steps,
      stepIds: stepIds ?? this.stepIds,
      materials: materials ?? this.materials,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(
        $ProtocolsTable.$convertersteps.toSql(steps.value),
      );
    }
    if (stepIds.present) {
      map['step_ids'] = Variable<String>(
        $ProtocolsTable.$converterstepIds.toSql(stepIds.value),
      );
    }
    if (materials.present) {
      map['materials'] = Variable<String>(materials.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProtocolsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('steps: $steps, ')
          ..write('stepIds: $stepIds, ')
          ..write('materials: $materials, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImagesTable extends Images with TableInfo<$ImagesTable, AttachedImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _experimentIdMeta = const VerificationMeta(
    'experimentId',
  );
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
    'experiment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES experiments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _strainIdMeta = const VerificationMeta(
    'strainId',
  );
  @override
  late final GeneratedColumn<String> strainId = GeneratedColumn<String>(
    'strain_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strains (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cultureIdMeta = const VerificationMeta(
    'cultureId',
  );
  @override
  late final GeneratedColumn<String> cultureId = GeneratedColumn<String>(
    'culture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cultures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _updateIdMeta = const VerificationMeta(
    'updateId',
  );
  @override
  late final GeneratedColumn<String> updateId = GeneratedColumn<String>(
    'update_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES experiment_updates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<String> reportId = GeneratedColumn<String>(
    'report_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reports (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _protocolIdMeta = const VerificationMeta(
    'protocolId',
  );
  @override
  late final GeneratedColumn<String> protocolId = GeneratedColumn<String>(
    'protocol_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES protocols (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<String> stepId = GeneratedColumn<String>(
    'step_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ImageAnnotation>, String>
  annotations = GeneratedColumn<String>(
    'annotations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<ImageAnnotation>>($ImagesTable.$converterannotations);
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('image/jpeg'),
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    experimentId,
    strainId,
    cultureId,
    updateId,
    reportId,
    protocolId,
    stepId,
    caption,
    notes,
    annotations,
    contentType,
    storagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachedImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('experiment_id')) {
      context.handle(
        _experimentIdMeta,
        experimentId.isAcceptableOrUnknown(
          data['experiment_id']!,
          _experimentIdMeta,
        ),
      );
    }
    if (data.containsKey('strain_id')) {
      context.handle(
        _strainIdMeta,
        strainId.isAcceptableOrUnknown(data['strain_id']!, _strainIdMeta),
      );
    }
    if (data.containsKey('culture_id')) {
      context.handle(
        _cultureIdMeta,
        cultureId.isAcceptableOrUnknown(data['culture_id']!, _cultureIdMeta),
      );
    }
    if (data.containsKey('update_id')) {
      context.handle(
        _updateIdMeta,
        updateId.isAcceptableOrUnknown(data['update_id']!, _updateIdMeta),
      );
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    }
    if (data.containsKey('protocol_id')) {
      context.handle(
        _protocolIdMeta,
        protocolId.isAcceptableOrUnknown(data['protocol_id']!, _protocolIdMeta),
      );
    }
    if (data.containsKey('step_id')) {
      context.handle(
        _stepIdMeta,
        stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachedImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachedImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      experimentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experiment_id'],
      ),
      strainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strain_id'],
      ),
      cultureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}culture_id'],
      ),
      updateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}update_id'],
      ),
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_id'],
      ),
      protocolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol_id'],
      ),
      stepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_id'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      annotations: $ImagesTable.$converterannotations.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}annotations'],
        )!,
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<ImageAnnotation>, String> $converterannotations =
      const ImageAnnotationListConverter();
}

class AttachedImage extends DataClass implements Insertable<AttachedImage> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String? experimentId;
  final String? strainId;
  final String? cultureId;
  final String? updateId;
  final String? reportId;
  final String? protocolId;
  final String? stepId;
  final String caption;
  final String notes;
  final List<ImageAnnotation> annotations;
  final String contentType;
  final String storagePath;
  const AttachedImage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    this.experimentId,
    this.strainId,
    this.cultureId,
    this.updateId,
    this.reportId,
    this.protocolId,
    this.stepId,
    required this.caption,
    required this.notes,
    required this.annotations,
    required this.contentType,
    required this.storagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || experimentId != null) {
      map['experiment_id'] = Variable<String>(experimentId);
    }
    if (!nullToAbsent || strainId != null) {
      map['strain_id'] = Variable<String>(strainId);
    }
    if (!nullToAbsent || cultureId != null) {
      map['culture_id'] = Variable<String>(cultureId);
    }
    if (!nullToAbsent || updateId != null) {
      map['update_id'] = Variable<String>(updateId);
    }
    if (!nullToAbsent || reportId != null) {
      map['report_id'] = Variable<String>(reportId);
    }
    if (!nullToAbsent || protocolId != null) {
      map['protocol_id'] = Variable<String>(protocolId);
    }
    if (!nullToAbsent || stepId != null) {
      map['step_id'] = Variable<String>(stepId);
    }
    map['caption'] = Variable<String>(caption);
    map['notes'] = Variable<String>(notes);
    {
      map['annotations'] = Variable<String>(
        $ImagesTable.$converterannotations.toSql(annotations),
      );
    }
    map['content_type'] = Variable<String>(contentType);
    map['storage_path'] = Variable<String>(storagePath);
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      experimentId: experimentId == null && nullToAbsent
          ? const Value.absent()
          : Value(experimentId),
      strainId: strainId == null && nullToAbsent
          ? const Value.absent()
          : Value(strainId),
      cultureId: cultureId == null && nullToAbsent
          ? const Value.absent()
          : Value(cultureId),
      updateId: updateId == null && nullToAbsent
          ? const Value.absent()
          : Value(updateId),
      reportId: reportId == null && nullToAbsent
          ? const Value.absent()
          : Value(reportId),
      protocolId: protocolId == null && nullToAbsent
          ? const Value.absent()
          : Value(protocolId),
      stepId: stepId == null && nullToAbsent
          ? const Value.absent()
          : Value(stepId),
      caption: Value(caption),
      notes: Value(notes),
      annotations: Value(annotations),
      contentType: Value(contentType),
      storagePath: Value(storagePath),
    );
  }

  factory AttachedImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachedImage(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      experimentId: serializer.fromJson<String?>(json['experimentId']),
      strainId: serializer.fromJson<String?>(json['strainId']),
      cultureId: serializer.fromJson<String?>(json['cultureId']),
      updateId: serializer.fromJson<String?>(json['updateId']),
      reportId: serializer.fromJson<String?>(json['reportId']),
      protocolId: serializer.fromJson<String?>(json['protocolId']),
      stepId: serializer.fromJson<String?>(json['stepId']),
      caption: serializer.fromJson<String>(json['caption']),
      notes: serializer.fromJson<String>(json['notes']),
      annotations: serializer.fromJson<List<ImageAnnotation>>(
        json['annotations'],
      ),
      contentType: serializer.fromJson<String>(json['contentType']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'experimentId': serializer.toJson<String?>(experimentId),
      'strainId': serializer.toJson<String?>(strainId),
      'cultureId': serializer.toJson<String?>(cultureId),
      'updateId': serializer.toJson<String?>(updateId),
      'reportId': serializer.toJson<String?>(reportId),
      'protocolId': serializer.toJson<String?>(protocolId),
      'stepId': serializer.toJson<String?>(stepId),
      'caption': serializer.toJson<String>(caption),
      'notes': serializer.toJson<String>(notes),
      'annotations': serializer.toJson<List<ImageAnnotation>>(annotations),
      'contentType': serializer.toJson<String>(contentType),
      'storagePath': serializer.toJson<String>(storagePath),
    };
  }

  AttachedImage copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    Value<String?> experimentId = const Value.absent(),
    Value<String?> strainId = const Value.absent(),
    Value<String?> cultureId = const Value.absent(),
    Value<String?> updateId = const Value.absent(),
    Value<String?> reportId = const Value.absent(),
    Value<String?> protocolId = const Value.absent(),
    Value<String?> stepId = const Value.absent(),
    String? caption,
    String? notes,
    List<ImageAnnotation>? annotations,
    String? contentType,
    String? storagePath,
  }) => AttachedImage(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    experimentId: experimentId.present ? experimentId.value : this.experimentId,
    strainId: strainId.present ? strainId.value : this.strainId,
    cultureId: cultureId.present ? cultureId.value : this.cultureId,
    updateId: updateId.present ? updateId.value : this.updateId,
    reportId: reportId.present ? reportId.value : this.reportId,
    protocolId: protocolId.present ? protocolId.value : this.protocolId,
    stepId: stepId.present ? stepId.value : this.stepId,
    caption: caption ?? this.caption,
    notes: notes ?? this.notes,
    annotations: annotations ?? this.annotations,
    contentType: contentType ?? this.contentType,
    storagePath: storagePath ?? this.storagePath,
  );
  AttachedImage copyWithCompanion(ImagesCompanion data) {
    return AttachedImage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
      strainId: data.strainId.present ? data.strainId.value : this.strainId,
      cultureId: data.cultureId.present ? data.cultureId.value : this.cultureId,
      updateId: data.updateId.present ? data.updateId.value : this.updateId,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      protocolId: data.protocolId.present
          ? data.protocolId.value
          : this.protocolId,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      caption: data.caption.present ? data.caption.value : this.caption,
      notes: data.notes.present ? data.notes.value : this.notes,
      annotations: data.annotations.present
          ? data.annotations.value
          : this.annotations,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachedImage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('experimentId: $experimentId, ')
          ..write('strainId: $strainId, ')
          ..write('cultureId: $cultureId, ')
          ..write('updateId: $updateId, ')
          ..write('reportId: $reportId, ')
          ..write('protocolId: $protocolId, ')
          ..write('stepId: $stepId, ')
          ..write('caption: $caption, ')
          ..write('notes: $notes, ')
          ..write('annotations: $annotations, ')
          ..write('contentType: $contentType, ')
          ..write('storagePath: $storagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    experimentId,
    strainId,
    cultureId,
    updateId,
    reportId,
    protocolId,
    stepId,
    caption,
    notes,
    annotations,
    contentType,
    storagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachedImage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.experimentId == this.experimentId &&
          other.strainId == this.strainId &&
          other.cultureId == this.cultureId &&
          other.updateId == this.updateId &&
          other.reportId == this.reportId &&
          other.protocolId == this.protocolId &&
          other.stepId == this.stepId &&
          other.caption == this.caption &&
          other.notes == this.notes &&
          other.annotations == this.annotations &&
          other.contentType == this.contentType &&
          other.storagePath == this.storagePath);
}

class ImagesCompanion extends UpdateCompanion<AttachedImage> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String?> experimentId;
  final Value<String?> strainId;
  final Value<String?> cultureId;
  final Value<String?> updateId;
  final Value<String?> reportId;
  final Value<String?> protocolId;
  final Value<String?> stepId;
  final Value<String> caption;
  final Value<String> notes;
  final Value<List<ImageAnnotation>> annotations;
  final Value<String> contentType;
  final Value<String> storagePath;
  final Value<int> rowid;
  const ImagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.strainId = const Value.absent(),
    this.cultureId = const Value.absent(),
    this.updateId = const Value.absent(),
    this.reportId = const Value.absent(),
    this.protocolId = const Value.absent(),
    this.stepId = const Value.absent(),
    this.caption = const Value.absent(),
    this.notes = const Value.absent(),
    this.annotations = const Value.absent(),
    this.contentType = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.experimentId = const Value.absent(),
    this.strainId = const Value.absent(),
    this.cultureId = const Value.absent(),
    this.updateId = const Value.absent(),
    this.reportId = const Value.absent(),
    this.protocolId = const Value.absent(),
    this.stepId = const Value.absent(),
    this.caption = const Value.absent(),
    this.notes = const Value.absent(),
    this.annotations = const Value.absent(),
    this.contentType = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AttachedImage> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? experimentId,
    Expression<String>? strainId,
    Expression<String>? cultureId,
    Expression<String>? updateId,
    Expression<String>? reportId,
    Expression<String>? protocolId,
    Expression<String>? stepId,
    Expression<String>? caption,
    Expression<String>? notes,
    Expression<String>? annotations,
    Expression<String>? contentType,
    Expression<String>? storagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (experimentId != null) 'experiment_id': experimentId,
      if (strainId != null) 'strain_id': strainId,
      if (cultureId != null) 'culture_id': cultureId,
      if (updateId != null) 'update_id': updateId,
      if (reportId != null) 'report_id': reportId,
      if (protocolId != null) 'protocol_id': protocolId,
      if (stepId != null) 'step_id': stepId,
      if (caption != null) 'caption': caption,
      if (notes != null) 'notes': notes,
      if (annotations != null) 'annotations': annotations,
      if (contentType != null) 'content_type': contentType,
      if (storagePath != null) 'storage_path': storagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String?>? experimentId,
    Value<String?>? strainId,
    Value<String?>? cultureId,
    Value<String?>? updateId,
    Value<String?>? reportId,
    Value<String?>? protocolId,
    Value<String?>? stepId,
    Value<String>? caption,
    Value<String>? notes,
    Value<List<ImageAnnotation>>? annotations,
    Value<String>? contentType,
    Value<String>? storagePath,
    Value<int>? rowid,
  }) {
    return ImagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      experimentId: experimentId ?? this.experimentId,
      strainId: strainId ?? this.strainId,
      cultureId: cultureId ?? this.cultureId,
      updateId: updateId ?? this.updateId,
      reportId: reportId ?? this.reportId,
      protocolId: protocolId ?? this.protocolId,
      stepId: stepId ?? this.stepId,
      caption: caption ?? this.caption,
      notes: notes ?? this.notes,
      annotations: annotations ?? this.annotations,
      contentType: contentType ?? this.contentType,
      storagePath: storagePath ?? this.storagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (strainId.present) {
      map['strain_id'] = Variable<String>(strainId.value);
    }
    if (cultureId.present) {
      map['culture_id'] = Variable<String>(cultureId.value);
    }
    if (updateId.present) {
      map['update_id'] = Variable<String>(updateId.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<String>(reportId.value);
    }
    if (protocolId.present) {
      map['protocol_id'] = Variable<String>(protocolId.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<String>(stepId.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (annotations.present) {
      map['annotations'] = Variable<String>(
        $ImagesTable.$converterannotations.toSql(annotations.value),
      );
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('experimentId: $experimentId, ')
          ..write('strainId: $strainId, ')
          ..write('cultureId: $cultureId, ')
          ..write('updateId: $updateId, ')
          ..write('reportId: $reportId, ')
          ..write('protocolId: $protocolId, ')
          ..write('stepId: $stepId, ')
          ..write('caption: $caption, ')
          ..write('notes: $notes, ')
          ..write('annotations: $annotations, ')
          ..write('contentType: $contentType, ')
          ..write('storagePath: $storagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageBlobsTable extends ImageBlobs
    with TableInfo<$ImageBlobsTable, ImageBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES images (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageBlob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
    );
  }

  @override
  $ImageBlobsTable createAlias(String alias) {
    return $ImageBlobsTable(attachedDatabase, alias);
  }
}

class ImageBlob extends DataClass implements Insertable<ImageBlob> {
  final String id;
  final Uint8List bytes;
  const ImageBlob({required this.id, required this.bytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bytes'] = Variable<Uint8List>(bytes);
    return map;
  }

  ImageBlobsCompanion toCompanion(bool nullToAbsent) {
    return ImageBlobsCompanion(id: Value(id), bytes: Value(bytes));
  }

  factory ImageBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageBlob(
      id: serializer.fromJson<String>(json['id']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bytes': serializer.toJson<Uint8List>(bytes),
    };
  }

  ImageBlob copyWith({String? id, Uint8List? bytes}) =>
      ImageBlob(id: id ?? this.id, bytes: bytes ?? this.bytes);
  ImageBlob copyWithCompanion(ImageBlobsCompanion data) {
    return ImageBlob(
      id: data.id.present ? data.id.value : this.id,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageBlob(')
          ..write('id: $id, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(bytes));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageBlob &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.bytes, this.bytes));
}

class ImageBlobsCompanion extends UpdateCompanion<ImageBlob> {
  final Value<String> id;
  final Value<Uint8List> bytes;
  final Value<int> rowid;
  const ImageBlobsCompanion({
    this.id = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageBlobsCompanion.insert({
    required String id,
    required Uint8List bytes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bytes = Value(bytes);
  static Insertable<ImageBlob> custom({
    Expression<String>? id,
    Expression<Uint8List>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageBlobsCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? bytes,
    Value<int>? rowid,
  }) {
    return ImageBlobsCompanion(
      id: id ?? this.id,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageBlobsCompanion(')
          ..write('id: $id, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('My Lab'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  const Workspace({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
    };
  }

  Workspace copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
  }) => Workspace(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipsTable extends Memberships
    with TableInfo<$MembershipsTable, Membership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('viewer'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    userId,
    email,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<Membership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Membership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Membership(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $MembershipsTable createAlias(String alias) {
    return $MembershipsTable(attachedDatabase, alias);
  }
}

class Membership extends DataClass implements Insertable<Membership> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String userId;
  final String email;
  final String role;
  const Membership({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.userId,
    required this.email,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['user_id'] = Variable<String>(userId);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    return map;
  }

  MembershipsCompanion toCompanion(bool nullToAbsent) {
    return MembershipsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      userId: Value(userId),
      email: Value(email),
      role: Value(role),
    );
  }

  factory Membership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Membership(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
    };
  }

  Membership copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? userId,
    String? email,
    String? role,
  }) => Membership(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    userId: userId ?? this.userId,
    email: email ?? this.email,
    role: role ?? this.role,
  );
  Membership copyWithCompanion(MembershipsCompanion data) {
    return Membership(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Membership(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, workspaceId, userId, email, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Membership &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.role == this.role);
}

class MembershipsCompanion extends UpdateCompanion<Membership> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> userId;
  final Value<String> email;
  final Value<String> role;
  final Value<int> rowid;
  const MembershipsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String workspaceId,
    required String userId,
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       userId = Value(userId);
  static Insertable<Membership> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? userId,
    Value<String>? email,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return MembershipsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceInvitesTable extends WorkspaceInvites
    with TableInfo<$WorkspaceInvitesTable, WorkspaceInvite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceInvitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('editor'),
  );
  static const VerificationMeta _invitedByMeta = const VerificationMeta(
    'invitedBy',
  );
  @override
  late final GeneratedColumn<String> invitedBy = GeneratedColumn<String>(
    'invited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    email,
    role,
    invitedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace_invites';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceInvite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('invited_by')) {
      context.handle(
        _invitedByMeta,
        invitedBy.isAcceptableOrUnknown(data['invited_by']!, _invitedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceInvite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceInvite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      invitedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invited_by'],
      )!,
    );
  }

  @override
  $WorkspaceInvitesTable createAlias(String alias) {
    return $WorkspaceInvitesTable(attachedDatabase, alias);
  }
}

class WorkspaceInvite extends DataClass implements Insertable<WorkspaceInvite> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String email;
  final String role;
  final String invitedBy;
  const WorkspaceInvite({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.email,
    required this.role,
    required this.invitedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['invited_by'] = Variable<String>(invitedBy);
    return map;
  }

  WorkspaceInvitesCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceInvitesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      email: Value(email),
      role: Value(role),
      invitedBy: Value(invitedBy),
    );
  }

  factory WorkspaceInvite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceInvite(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      invitedBy: serializer.fromJson<String>(json['invitedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'invitedBy': serializer.toJson<String>(invitedBy),
    };
  }

  WorkspaceInvite copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? email,
    String? role,
    String? invitedBy,
  }) => WorkspaceInvite(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    email: email ?? this.email,
    role: role ?? this.role,
    invitedBy: invitedBy ?? this.invitedBy,
  );
  WorkspaceInvite copyWithCompanion(WorkspaceInvitesCompanion data) {
    return WorkspaceInvite(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      invitedBy: data.invitedBy.present ? data.invitedBy.value : this.invitedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceInvite(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('invitedBy: $invitedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    email,
    role,
    invitedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceInvite &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.email == this.email &&
          other.role == this.role &&
          other.invitedBy == this.invitedBy);
}

class WorkspaceInvitesCompanion extends UpdateCompanion<WorkspaceInvite> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> email;
  final Value<String> role;
  final Value<String> invitedBy;
  final Value<int> rowid;
  const WorkspaceInvitesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.invitedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceInvitesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String workspaceId,
    required String email,
    this.role = const Value.absent(),
    this.invitedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       email = Value(email);
  static Insertable<WorkspaceInvite> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? invitedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (invitedBy != null) 'invited_by': invitedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceInvitesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? email,
    Value<String>? role,
    Value<String>? invitedBy,
    Value<int>? rowid,
  }) {
    return WorkspaceInvitesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      email: email ?? this.email,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (invitedBy.present) {
      map['invited_by'] = Variable<String>(invitedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceInvitesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('invitedBy: $invitedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrimersTable extends Primers with TableInfo<$PrimersTable, Primer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<String> sequence = GeneratedColumn<String>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetGeneMeta = const VerificationMeta(
    'targetGene',
  );
  @override
  late final GeneratedColumn<String> targetGene = GeneratedColumn<String>(
    'target_gene',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tmMeta = const VerificationMeta('tm');
  @override
  late final GeneratedColumn<String> tm = GeneratedColumn<String>(
    'tm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    serialNumber,
    sequence,
    targetGene,
    direction,
    tm,
    supplier,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'primers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Primer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('target_gene')) {
      context.handle(
        _targetGeneMeta,
        targetGene.isAcceptableOrUnknown(data['target_gene']!, _targetGeneMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('tm')) {
      context.handle(_tmMeta, tm.isAcceptableOrUnknown(data['tm']!, _tmMeta));
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Primer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Primer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sequence'],
      )!,
      targetGene: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_gene'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      tm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tm'],
      )!,
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $PrimersTable createAlias(String alias) {
    return $PrimersTable(attachedDatabase, alias);
  }
}

class Primer extends DataClass implements Insertable<Primer> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;

  /// User-assigned lab serial / catalog number (editable).
  final String serialNumber;
  final String sequence;
  final String targetGene;
  final String direction;
  final String tm;
  final String supplier;
  final String notes;
  const Primer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    required this.serialNumber,
    required this.sequence,
    required this.targetGene,
    required this.direction,
    required this.tm,
    required this.supplier,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['serial_number'] = Variable<String>(serialNumber);
    map['sequence'] = Variable<String>(sequence);
    map['target_gene'] = Variable<String>(targetGene);
    map['direction'] = Variable<String>(direction);
    map['tm'] = Variable<String>(tm);
    map['supplier'] = Variable<String>(supplier);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  PrimersCompanion toCompanion(bool nullToAbsent) {
    return PrimersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      serialNumber: Value(serialNumber),
      sequence: Value(sequence),
      targetGene: Value(targetGene),
      direction: Value(direction),
      tm: Value(tm),
      supplier: Value(supplier),
      notes: Value(notes),
    );
  }

  factory Primer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Primer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      serialNumber: serializer.fromJson<String>(json['serialNumber']),
      sequence: serializer.fromJson<String>(json['sequence']),
      targetGene: serializer.fromJson<String>(json['targetGene']),
      direction: serializer.fromJson<String>(json['direction']),
      tm: serializer.fromJson<String>(json['tm']),
      supplier: serializer.fromJson<String>(json['supplier']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'serialNumber': serializer.toJson<String>(serialNumber),
      'sequence': serializer.toJson<String>(sequence),
      'targetGene': serializer.toJson<String>(targetGene),
      'direction': serializer.toJson<String>(direction),
      'tm': serializer.toJson<String>(tm),
      'supplier': serializer.toJson<String>(supplier),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Primer copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    String? serialNumber,
    String? sequence,
    String? targetGene,
    String? direction,
    String? tm,
    String? supplier,
    String? notes,
  }) => Primer(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    serialNumber: serialNumber ?? this.serialNumber,
    sequence: sequence ?? this.sequence,
    targetGene: targetGene ?? this.targetGene,
    direction: direction ?? this.direction,
    tm: tm ?? this.tm,
    supplier: supplier ?? this.supplier,
    notes: notes ?? this.notes,
  );
  Primer copyWithCompanion(PrimersCompanion data) {
    return Primer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      targetGene: data.targetGene.present
          ? data.targetGene.value
          : this.targetGene,
      direction: data.direction.present ? data.direction.value : this.direction,
      tm: data.tm.present ? data.tm.value : this.tm,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Primer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('sequence: $sequence, ')
          ..write('targetGene: $targetGene, ')
          ..write('direction: $direction, ')
          ..write('tm: $tm, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    serialNumber,
    sequence,
    targetGene,
    direction,
    tm,
    supplier,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Primer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.serialNumber == this.serialNumber &&
          other.sequence == this.sequence &&
          other.targetGene == this.targetGene &&
          other.direction == this.direction &&
          other.tm == this.tm &&
          other.supplier == this.supplier &&
          other.notes == this.notes);
}

class PrimersCompanion extends UpdateCompanion<Primer> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> serialNumber;
  final Value<String> sequence;
  final Value<String> targetGene;
  final Value<String> direction;
  final Value<String> tm;
  final Value<String> supplier;
  final Value<String> notes;
  final Value<int> rowid;
  const PrimersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.sequence = const Value.absent(),
    this.targetGene = const Value.absent(),
    this.direction = const Value.absent(),
    this.tm = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrimersCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String name,
    this.serialNumber = const Value.absent(),
    this.sequence = const Value.absent(),
    this.targetGene = const Value.absent(),
    this.direction = const Value.absent(),
    this.tm = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Primer> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? serialNumber,
    Expression<String>? sequence,
    Expression<String>? targetGene,
    Expression<String>? direction,
    Expression<String>? tm,
    Expression<String>? supplier,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (sequence != null) 'sequence': sequence,
      if (targetGene != null) 'target_gene': targetGene,
      if (direction != null) 'direction': direction,
      if (tm != null) 'tm': tm,
      if (supplier != null) 'supplier': supplier,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrimersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? serialNumber,
    Value<String>? sequence,
    Value<String>? targetGene,
    Value<String>? direction,
    Value<String>? tm,
    Value<String>? supplier,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return PrimersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      sequence: sequence ?? this.sequence,
      targetGene: targetGene ?? this.targetGene,
      direction: direction ?? this.direction,
      tm: tm ?? this.tm,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<String>(sequence.value);
    }
    if (targetGene.present) {
      map['target_gene'] = Variable<String>(targetGene.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (tm.present) {
      map['tm'] = Variable<String>(tm.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrimersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('sequence: $sequence, ')
          ..write('targetGene: $targetGene, ')
          ..write('direction: $direction, ')
          ..write('tm: $tm, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CloneConstructionsTable extends CloneConstructions
    with TableInfo<$CloneConstructionsTable, CloneConstruction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CloneConstructionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _backboneNameMeta = const VerificationMeta(
    'backboneName',
  );
  @override
  late final GeneratedColumn<String> backboneName = GeneratedColumn<String>(
    'backbone_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _backboneStrainIdMeta = const VerificationMeta(
    'backboneStrainId',
  );
  @override
  late final GeneratedColumn<String> backboneStrainId = GeneratedColumn<String>(
    'backbone_strain_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _enzymesMeta = const VerificationMeta(
    'enzymes',
  );
  @override
  late final GeneratedColumn<String> enzymes = GeneratedColumn<String>(
    'enzymes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<CloneFragment>, String>
  fragments =
      GeneratedColumn<String>(
        'fragments',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<CloneFragment>>(
        $CloneConstructionsTable.$converterfragments,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    notes,
    backboneName,
    backboneStrainId,
    enzymes,
    fragments,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clone_constructions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CloneConstruction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('backbone_name')) {
      context.handle(
        _backboneNameMeta,
        backboneName.isAcceptableOrUnknown(
          data['backbone_name']!,
          _backboneNameMeta,
        ),
      );
    }
    if (data.containsKey('backbone_strain_id')) {
      context.handle(
        _backboneStrainIdMeta,
        backboneStrainId.isAcceptableOrUnknown(
          data['backbone_strain_id']!,
          _backboneStrainIdMeta,
        ),
      );
    }
    if (data.containsKey('enzymes')) {
      context.handle(
        _enzymesMeta,
        enzymes.isAcceptableOrUnknown(data['enzymes']!, _enzymesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CloneConstruction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CloneConstruction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      backboneName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backbone_name'],
      )!,
      backboneStrainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backbone_strain_id'],
      )!,
      enzymes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enzymes'],
      )!,
      fragments: $CloneConstructionsTable.$converterfragments.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fragments'],
        )!,
      ),
    );
  }

  @override
  $CloneConstructionsTable createAlias(String alias) {
    return $CloneConstructionsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<CloneFragment>, String> $converterfragments =
      const CloneFragmentListConverter();
}

class CloneConstruction extends DataClass
    implements Insertable<CloneConstruction> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String name;
  final String notes;
  final String backboneName;
  final String backboneStrainId;
  final String enzymes;
  final List<CloneFragment> fragments;
  const CloneConstruction({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.name,
    required this.notes,
    required this.backboneName,
    required this.backboneStrainId,
    required this.enzymes,
    required this.fragments,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['backbone_name'] = Variable<String>(backboneName);
    map['backbone_strain_id'] = Variable<String>(backboneStrainId);
    map['enzymes'] = Variable<String>(enzymes);
    {
      map['fragments'] = Variable<String>(
        $CloneConstructionsTable.$converterfragments.toSql(fragments),
      );
    }
    return map;
  }

  CloneConstructionsCompanion toCompanion(bool nullToAbsent) {
    return CloneConstructionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      name: Value(name),
      notes: Value(notes),
      backboneName: Value(backboneName),
      backboneStrainId: Value(backboneStrainId),
      enzymes: Value(enzymes),
      fragments: Value(fragments),
    );
  }

  factory CloneConstruction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CloneConstruction(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      backboneName: serializer.fromJson<String>(json['backboneName']),
      backboneStrainId: serializer.fromJson<String>(json['backboneStrainId']),
      enzymes: serializer.fromJson<String>(json['enzymes']),
      fragments: serializer.fromJson<List<CloneFragment>>(json['fragments']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'backboneName': serializer.toJson<String>(backboneName),
      'backboneStrainId': serializer.toJson<String>(backboneStrainId),
      'enzymes': serializer.toJson<String>(enzymes),
      'fragments': serializer.toJson<List<CloneFragment>>(fragments),
    };
  }

  CloneConstruction copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? name,
    String? notes,
    String? backboneName,
    String? backboneStrainId,
    String? enzymes,
    List<CloneFragment>? fragments,
  }) => CloneConstruction(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    backboneName: backboneName ?? this.backboneName,
    backboneStrainId: backboneStrainId ?? this.backboneStrainId,
    enzymes: enzymes ?? this.enzymes,
    fragments: fragments ?? this.fragments,
  );
  CloneConstruction copyWithCompanion(CloneConstructionsCompanion data) {
    return CloneConstruction(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      backboneName: data.backboneName.present
          ? data.backboneName.value
          : this.backboneName,
      backboneStrainId: data.backboneStrainId.present
          ? data.backboneStrainId.value
          : this.backboneStrainId,
      enzymes: data.enzymes.present ? data.enzymes.value : this.enzymes,
      fragments: data.fragments.present ? data.fragments.value : this.fragments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CloneConstruction(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('backboneName: $backboneName, ')
          ..write('backboneStrainId: $backboneStrainId, ')
          ..write('enzymes: $enzymes, ')
          ..write('fragments: $fragments')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    name,
    notes,
    backboneName,
    backboneStrainId,
    enzymes,
    fragments,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CloneConstruction &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.backboneName == this.backboneName &&
          other.backboneStrainId == this.backboneStrainId &&
          other.enzymes == this.enzymes &&
          other.fragments == this.fragments);
}

class CloneConstructionsCompanion extends UpdateCompanion<CloneConstruction> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<String> notes;
  final Value<String> backboneName;
  final Value<String> backboneStrainId;
  final Value<String> enzymes;
  final Value<List<CloneFragment>> fragments;
  final Value<int> rowid;
  const CloneConstructionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.backboneName = const Value.absent(),
    this.backboneStrainId = const Value.absent(),
    this.enzymes = const Value.absent(),
    this.fragments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CloneConstructionsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.backboneName = const Value.absent(),
    this.backboneStrainId = const Value.absent(),
    this.enzymes = const Value.absent(),
    this.fragments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<CloneConstruction> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? backboneName,
    Expression<String>? backboneStrainId,
    Expression<String>? enzymes,
    Expression<String>? fragments,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (backboneName != null) 'backbone_name': backboneName,
      if (backboneStrainId != null) 'backbone_strain_id': backboneStrainId,
      if (enzymes != null) 'enzymes': enzymes,
      if (fragments != null) 'fragments': fragments,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CloneConstructionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? name,
    Value<String>? notes,
    Value<String>? backboneName,
    Value<String>? backboneStrainId,
    Value<String>? enzymes,
    Value<List<CloneFragment>>? fragments,
    Value<int>? rowid,
  }) {
    return CloneConstructionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      backboneName: backboneName ?? this.backboneName,
      backboneStrainId: backboneStrainId ?? this.backboneStrainId,
      enzymes: enzymes ?? this.enzymes,
      fragments: fragments ?? this.fragments,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (backboneName.present) {
      map['backbone_name'] = Variable<String>(backboneName.value);
    }
    if (backboneStrainId.present) {
      map['backbone_strain_id'] = Variable<String>(backboneStrainId.value);
    }
    if (enzymes.present) {
      map['enzymes'] = Variable<String>(enzymes.value);
    }
    if (fragments.present) {
      map['fragments'] = Variable<String>(
        $CloneConstructionsTable.$converterfragments.toSql(fragments.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CloneConstructionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('backboneName: $backboneName, ')
          ..write('backboneStrainId: $backboneStrainId, ')
          ..write('enzymes: $enzymes, ')
          ..write('fragments: $fragments, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrashEntriesTable extends TrashEntries
    with TableInfo<$TrashEntriesTable, TrashEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrashEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    entityTable,
    entityId,
    kind,
    label,
    deletedAt,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trash_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrashEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrashEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrashEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $TrashEntriesTable createAlias(String alias) {
    return $TrashEntriesTable(attachedDatabase, alias);
  }
}

class TrashEntry extends DataClass implements Insertable<TrashEntry> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String entityTable;
  final String entityId;
  final String kind;
  final String label;
  final DateTime deletedAt;
  final String payload;
  const TrashEntry({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.entityTable,
    required this.entityId,
    required this.kind,
    required this.label,
    required this.deletedAt,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  TrashEntriesCompanion toCompanion(bool nullToAbsent) {
    return TrashEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      kind: Value(kind),
      label: Value(label),
      deletedAt: Value(deletedAt),
      payload: Value(payload),
    );
  }

  factory TrashEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrashEntry(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
      'payload': serializer.toJson<String>(payload),
    };
  }

  TrashEntry copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? entityTable,
    String? entityId,
    String? kind,
    String? label,
    DateTime? deletedAt,
    String? payload,
  }) => TrashEntry(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    deletedAt: deletedAt ?? this.deletedAt,
    payload: payload ?? this.payload,
  );
  TrashEntry copyWithCompanion(TrashEntriesCompanion data) {
    return TrashEntry(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrashEntry(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    entityTable,
    entityId,
    kind,
    label,
    deletedAt,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrashEntry &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.deletedAt == this.deletedAt &&
          other.payload == this.payload);
}

class TrashEntriesCompanion extends UpdateCompanion<TrashEntry> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> kind;
  final Value<String> label;
  final Value<DateTime> deletedAt;
  final Value<String> payload;
  final Value<int> rowid;
  const TrashEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrashEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String entityTable,
    required String entityId,
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String payload,
    this.rowid = const Value.absent(),
  }) : entityTable = Value(entityTable),
       entityId = Value(entityId),
       payload = Value(payload);
  static Insertable<TrashEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<DateTime>? deletedAt,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrashEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? kind,
    Value<String>? label,
    Value<DateTime>? deletedAt,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return TrashEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      deletedAt: deletedAt ?? this.deletedAt,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrashEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomEventsTable extends CustomEvents
    with TableInfo<$CustomEventsTable, CustomEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personal'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _repeatAnnuallyMeta = const VerificationMeta(
    'repeatAnnually',
  );
  @override
  late final GeneratedColumn<bool> repeatAnnually = GeneratedColumn<bool>(
    'repeat_annually',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeat_annually" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    date,
    category,
    note,
    repeatAnnually,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('repeat_annually')) {
      context.handle(
        _repeatAnnuallyMeta,
        repeatAnnually.isAcceptableOrUnknown(
          data['repeat_annually']!,
          _repeatAnnuallyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      repeatAnnually: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeat_annually'],
      )!,
    );
  }

  @override
  $CustomEventsTable createAlias(String alias) {
    return $CustomEventsTable(attachedDatabase, alias);
  }
}

class CustomEvent extends DataClass implements Insertable<CustomEvent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String title;
  final DateTime date;
  final String category;
  final String note;
  final bool repeatAnnually;
  const CustomEvent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.title,
    required this.date,
    required this.category,
    required this.note,
    required this.repeatAnnually,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['note'] = Variable<String>(note);
    map['repeat_annually'] = Variable<bool>(repeatAnnually);
    return map;
  }

  CustomEventsCompanion toCompanion(bool nullToAbsent) {
    return CustomEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      title: Value(title),
      date: Value(date),
      category: Value(category),
      note: Value(note),
      repeatAnnually: Value(repeatAnnually),
    );
  }

  factory CustomEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomEvent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String>(json['note']),
      repeatAnnually: serializer.fromJson<bool>(json['repeatAnnually']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String>(note),
      'repeatAnnually': serializer.toJson<bool>(repeatAnnually),
    };
  }

  CustomEvent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? title,
    DateTime? date,
    String? category,
    String? note,
    bool? repeatAnnually,
  }) => CustomEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    title: title ?? this.title,
    date: date ?? this.date,
    category: category ?? this.category,
    note: note ?? this.note,
    repeatAnnually: repeatAnnually ?? this.repeatAnnually,
  );
  CustomEvent copyWithCompanion(CustomEventsCompanion data) {
    return CustomEvent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      repeatAnnually: data.repeatAnnually.present
          ? data.repeatAnnually.value
          : this.repeatAnnually,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomEvent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('repeatAnnually: $repeatAnnually')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    title,
    date,
    category,
    note,
    repeatAnnually,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomEvent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.title == this.title &&
          other.date == this.date &&
          other.category == this.category &&
          other.note == this.note &&
          other.repeatAnnually == this.repeatAnnually);
}

class CustomEventsCompanion extends UpdateCompanion<CustomEvent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<String> note;
  final Value<bool> repeatAnnually;
  final Value<int> rowid;
  const CustomEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.repeatAnnually = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomEventsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String title,
    required DateTime date,
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.repeatAnnually = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       date = Value(date);
  static Insertable<CustomEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? note,
    Expression<bool>? repeatAnnually,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (repeatAnnually != null) 'repeat_annually': repeatAnnually,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? title,
    Value<DateTime>? date,
    Value<String>? category,
    Value<String>? note,
    Value<bool>? repeatAnnually,
    Value<int>? rowid,
  }) {
    return CustomEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      repeatAnnually: repeatAnnually ?? this.repeatAnnually,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (repeatAnnually.present) {
      map['repeat_annually'] = Variable<bool>(repeatAnnually.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('repeatAnnually: $repeatAnnually, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CultureEventsTable extends CultureEvents
    with TableInfo<$CultureEventsTable, CultureEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CultureEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cultureIdMeta = const VerificationMeta(
    'cultureId',
  );
  @override
  late final GeneratedColumn<String> cultureId = GeneratedColumn<String>(
    'culture_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cultures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _happenedAtMeta = const VerificationMeta(
    'happenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> happenedAt = GeneratedColumn<DateTime>(
    'happened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('note'),
  );
  static const VerificationMeta _agentMeta = const VerificationMeta('agent');
  @override
  late final GeneratedColumn<String> agent = GeneratedColumn<String>(
    'agent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    workspaceId,
    cultureId,
    happenedAt,
    type,
    agent,
    amount,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'culture_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CultureEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('culture_id')) {
      context.handle(
        _cultureIdMeta,
        cultureId.isAcceptableOrUnknown(data['culture_id']!, _cultureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cultureIdMeta);
    }
    if (data.containsKey('happened_at')) {
      context.handle(
        _happenedAtMeta,
        happenedAt.isAcceptableOrUnknown(data['happened_at']!, _happenedAtMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('agent')) {
      context.handle(
        _agentMeta,
        agent.isAcceptableOrUnknown(data['agent']!, _agentMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CultureEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CultureEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      cultureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}culture_id'],
      )!,
      happenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      agent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $CultureEventsTable createAlias(String alias) {
    return $CultureEventsTable(attachedDatabase, alias);
  }
}

class CultureEvent extends DataClass implements Insertable<CultureEvent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final String cultureId;
  final DateTime happenedAt;
  final String type;
  final String agent;
  final String amount;
  final String note;
  const CultureEvent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    required this.cultureId,
    required this.happenedAt,
    required this.type,
    required this.agent,
    required this.amount,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['culture_id'] = Variable<String>(cultureId);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    map['type'] = Variable<String>(type);
    map['agent'] = Variable<String>(agent);
    map['amount'] = Variable<String>(amount);
    map['note'] = Variable<String>(note);
    return map;
  }

  CultureEventsCompanion toCompanion(bool nullToAbsent) {
    return CultureEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      workspaceId: Value(workspaceId),
      cultureId: Value(cultureId),
      happenedAt: Value(happenedAt),
      type: Value(type),
      agent: Value(agent),
      amount: Value(amount),
      note: Value(note),
    );
  }

  factory CultureEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CultureEvent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      cultureId: serializer.fromJson<String>(json['cultureId']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
      type: serializer.fromJson<String>(json['type']),
      agent: serializer.fromJson<String>(json['agent']),
      amount: serializer.fromJson<String>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'cultureId': serializer.toJson<String>(cultureId),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
      'type': serializer.toJson<String>(type),
      'agent': serializer.toJson<String>(agent),
      'amount': serializer.toJson<String>(amount),
      'note': serializer.toJson<String>(note),
    };
  }

  CultureEvent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    String? cultureId,
    DateTime? happenedAt,
    String? type,
    String? agent,
    String? amount,
    String? note,
  }) => CultureEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
    cultureId: cultureId ?? this.cultureId,
    happenedAt: happenedAt ?? this.happenedAt,
    type: type ?? this.type,
    agent: agent ?? this.agent,
    amount: amount ?? this.amount,
    note: note ?? this.note,
  );
  CultureEvent copyWithCompanion(CultureEventsCompanion data) {
    return CultureEvent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      cultureId: data.cultureId.present ? data.cultureId.value : this.cultureId,
      happenedAt: data.happenedAt.present
          ? data.happenedAt.value
          : this.happenedAt,
      type: data.type.present ? data.type.value : this.type,
      agent: data.agent.present ? data.agent.value : this.agent,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CultureEvent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('cultureId: $cultureId, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('type: $type, ')
          ..write('agent: $agent, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    workspaceId,
    cultureId,
    happenedAt,
    type,
    agent,
    amount,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CultureEvent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.workspaceId == this.workspaceId &&
          other.cultureId == this.cultureId &&
          other.happenedAt == this.happenedAt &&
          other.type == this.type &&
          other.agent == this.agent &&
          other.amount == this.amount &&
          other.note == this.note);
}

class CultureEventsCompanion extends UpdateCompanion<CultureEvent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> workspaceId;
  final Value<String> cultureId;
  final Value<DateTime> happenedAt;
  final Value<String> type;
  final Value<String> agent;
  final Value<String> amount;
  final Value<String> note;
  final Value<int> rowid;
  const CultureEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.cultureId = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.agent = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CultureEventsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workspaceId = const Value.absent(),
    required String cultureId,
    this.happenedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.agent = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cultureId = Value(cultureId);
  static Insertable<CultureEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? workspaceId,
    Expression<String>? cultureId,
    Expression<DateTime>? happenedAt,
    Expression<String>? type,
    Expression<String>? agent,
    Expression<String>? amount,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (cultureId != null) 'culture_id': cultureId,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (type != null) 'type': type,
      if (agent != null) 'agent': agent,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CultureEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? workspaceId,
    Value<String>? cultureId,
    Value<DateTime>? happenedAt,
    Value<String>? type,
    Value<String>? agent,
    Value<String>? amount,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return CultureEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
      cultureId: cultureId ?? this.cultureId,
      happenedAt: happenedAt ?? this.happenedAt,
      type: type ?? this.type,
      agent: agent ?? this.agent,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (cultureId.present) {
      map['culture_id'] = Variable<String>(cultureId.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<DateTime>(happenedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (agent.present) {
      map['agent'] = Variable<String>(agent.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CultureEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('cultureId: $cultureId, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('type: $type, ')
          ..write('agent: $agent, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ExperimentsTable experiments = $ExperimentsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $StrainsTable strains = $StrainsTable(this);
  late final $ReagentsTable reagents = $ReagentsTable(this);
  late final $ManuscriptsTable manuscripts = $ManuscriptsTable(this);
  late final $TombstonesTable tombstones = $TombstonesTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CulturesTable cultures = $CulturesTable(this);
  late final $ExperimentUpdatesTable experimentUpdates =
      $ExperimentUpdatesTable(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $ProtocolsTable protocols = $ProtocolsTable(this);
  late final $ImagesTable images = $ImagesTable(this);
  late final $ImageBlobsTable imageBlobs = $ImageBlobsTable(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $MembershipsTable memberships = $MembershipsTable(this);
  late final $WorkspaceInvitesTable workspaceInvites = $WorkspaceInvitesTable(
    this,
  );
  late final $PrimersTable primers = $PrimersTable(this);
  late final $CloneConstructionsTable cloneConstructions =
      $CloneConstructionsTable(this);
  late final $TrashEntriesTable trashEntries = $TrashEntriesTable(this);
  late final $CustomEventsTable customEvents = $CustomEventsTable(this);
  late final $CultureEventsTable cultureEvents = $CultureEventsTable(this);
  late final Index idxExperimentsProject = Index(
    'idx_experiments_project',
    'CREATE INDEX idx_experiments_project ON experiments (project_id)',
  );
  late final Index idxTasksProject = Index(
    'idx_tasks_project',
    'CREATE INDEX idx_tasks_project ON tasks (project_id)',
  );
  late final Index idxTasksExperiment = Index(
    'idx_tasks_experiment',
    'CREATE INDEX idx_tasks_experiment ON tasks (experiment_id)',
  );
  late final Index idxManuscriptsProject = Index(
    'idx_manuscripts_project',
    'CREATE INDEX idx_manuscripts_project ON manuscripts (project_id)',
  );
  late final Index idxImagesExperiment = Index(
    'idx_images_experiment',
    'CREATE INDEX idx_images_experiment ON images (experiment_id)',
  );
  late final Index idxImagesStrain = Index(
    'idx_images_strain',
    'CREATE INDEX idx_images_strain ON images (strain_id)',
  );
  late final Index idxImagesProtocol = Index(
    'idx_images_protocol',
    'CREATE INDEX idx_images_protocol ON images (protocol_id)',
  );
  late final Index idxMembershipsWorkspace = Index(
    'idx_memberships_workspace',
    'CREATE INDEX idx_memberships_workspace ON memberships (workspace_id)',
  );
  late final Index idxMembershipsUser = Index(
    'idx_memberships_user',
    'CREATE INDEX idx_memberships_user ON memberships (user_id)',
  );
  late final Index idxInvitesWorkspace = Index(
    'idx_invites_workspace',
    'CREATE INDEX idx_invites_workspace ON workspace_invites (workspace_id)',
  );
  late final Index idxCulturesStrain = Index(
    'idx_cultures_strain',
    'CREATE INDEX idx_cultures_strain ON cultures (strain_id)',
  );
  late final Index idxCulturesStatus = Index(
    'idx_cultures_status',
    'CREATE INDEX idx_cultures_status ON cultures (status)',
  );
  late final Index idxUpdatesExperiment = Index(
    'idx_updates_experiment',
    'CREATE INDEX idx_updates_experiment ON experiment_updates (experiment_id)',
  );
  late final Index idxCustomEventsDate = Index(
    'idx_custom_events_date',
    'CREATE INDEX idx_custom_events_date ON custom_events (date)',
  );
  late final Index idxCultureEventsCulture = Index(
    'idx_culture_events_culture',
    'CREATE INDEX idx_culture_events_culture ON culture_events (culture_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    experiments,
    tasks,
    strains,
    reagents,
    manuscripts,
    tombstones,
    syncMeta,
    appSettings,
    cultures,
    experimentUpdates,
    reports,
    protocols,
    images,
    imageBlobs,
    workspaces,
    memberships,
    workspaceInvites,
    primers,
    cloneConstructions,
    trashEntries,
    customEvents,
    cultureEvents,
    idxExperimentsProject,
    idxTasksProject,
    idxTasksExperiment,
    idxManuscriptsProject,
    idxImagesExperiment,
    idxImagesStrain,
    idxImagesProtocol,
    idxMembershipsWorkspace,
    idxMembershipsUser,
    idxInvitesWorkspace,
    idxCulturesStrain,
    idxCulturesStatus,
    idxUpdatesExperiment,
    idxCustomEventsDate,
    idxCultureEventsCulture,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('experiments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'experiments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('manuscripts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strains',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cultures', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'experiments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('experiment_updates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'experiments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strains',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cultures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'experiment_updates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reports',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'protocols',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'images',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('image_blobs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cultures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('culture_events', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String title,
      Value<String> description,
      Value<ProjectStatus> status,
      Value<Priority> priority,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<List<String>> tags,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> title,
      Value<String> description,
      Value<ProjectStatus> status,
      Value<Priority> priority,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<List<String>> tags,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExperimentsTable, List<Experiment>>
  _experimentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.experiments,
    aliasName: 'projects__id__experiments__project_id',
  );

  $$ExperimentsTableProcessedTableManager get experimentsRefs {
    final manager = $$ExperimentsTableTableManager(
      $_db,
      $_db.experiments,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_experimentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'projects__id__tasks__project_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ManuscriptsTable, List<Manuscript>>
  _manuscriptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.manuscripts,
    aliasName: 'projects__id__manuscripts__project_id',
  );

  $$ManuscriptsTableProcessedTableManager get manuscriptsRefs {
    final manager = $$ManuscriptsTableTableManager(
      $_db,
      $_db.manuscripts,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_manuscriptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
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

  ColumnWithTypeConverterFilters<ProjectStatus, ProjectStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Priority, Priority, String> get priority =>
      $composableBuilder(
        column: $table.priority,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> experimentsRefs(
    Expression<bool> Function($$ExperimentsTableFilterComposer f) f,
  ) {
    final $$ExperimentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableFilterComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> manuscriptsRefs(
    Expression<bool> Function($$ManuscriptsTableFilterComposer f) f,
  ) {
    final $$ManuscriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manuscripts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManuscriptsTableFilterComposer(
            $db: $db,
            $table: $db.manuscripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProjectStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Priority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> experimentsRefs<T extends Object>(
    Expression<T> Function($$ExperimentsTableAnnotationComposer a) f,
  ) {
    final $$ExperimentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableAnnotationComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> manuscriptsRefs<T extends Object>(
    Expression<T> Function($$ManuscriptsTableAnnotationComposer a) f,
  ) {
    final $$ManuscriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manuscripts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManuscriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.manuscripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool experimentsRefs,
            bool tasksRefs,
            bool manuscriptsRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                description: description,
                status: status,
                priority: priority,
                startDate: startDate,
                targetDate: targetDate,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                description: description,
                status: status,
                priority: priority,
                startDate: startDate,
                targetDate: targetDate,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                experimentsRefs = false,
                tasksRefs = false,
                manuscriptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (experimentsRefs) db.experiments,
                    if (tasksRefs) db.tasks,
                    if (manuscriptsRefs) db.manuscripts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (experimentsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Experiment
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._experimentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).experimentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Task
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (manuscriptsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Manuscript
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._manuscriptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).manuscriptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool experimentsRefs,
        bool tasksRefs,
        bool manuscriptsRefs,
      })
    >;
typedef $$ExperimentsTableCreateCompanionBuilder =
    ExperimentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String projectId,
      required String title,
      Value<String> hypothesis,
      Value<ExperimentStatus> status,
      Value<DateTime?> date,
      Value<List<String>> strainIds,
      Value<String> protocolRef,
      Value<List<String>> methodologySteps,
      Value<String> resultsNotes,
      Value<String> conclusion,
      Value<String> furtherPlan,
      Value<List<String>> dataLinks,
      Value<int> rowid,
    });
typedef $$ExperimentsTableUpdateCompanionBuilder =
    ExperimentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> projectId,
      Value<String> title,
      Value<String> hypothesis,
      Value<ExperimentStatus> status,
      Value<DateTime?> date,
      Value<List<String>> strainIds,
      Value<String> protocolRef,
      Value<List<String>> methodologySteps,
      Value<String> resultsNotes,
      Value<String> conclusion,
      Value<String> furtherPlan,
      Value<List<String>> dataLinks,
      Value<int> rowid,
    });

final class $$ExperimentsTableReferences
    extends BaseReferences<_$AppDatabase, $ExperimentsTable, Experiment> {
  $$ExperimentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('experiments__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'experiments__id__tasks__experiment_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.experimentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExperimentUpdatesTable, List<ExperimentUpdate>>
  _experimentUpdatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.experimentUpdates,
        aliasName: 'experiments__id__experiment_updates__experiment_id',
      );

  $$ExperimentUpdatesTableProcessedTableManager get experimentUpdatesRefs {
    final manager = $$ExperimentUpdatesTableTableManager(
      $_db,
      $_db.experimentUpdates,
    ).filter((f) => f.experimentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _experimentUpdatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'experiments__id__images__experiment_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.experimentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExperimentsTableFilterComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hypothesis => $composableBuilder(
    column: $table.hypothesis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExperimentStatus, ExperimentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get strainIds => $composableBuilder(
    column: $table.strainIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get protocolRef => $composableBuilder(
    column: $table.protocolRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get methodologySteps => $composableBuilder(
    column: $table.methodologySteps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get resultsNotes => $composableBuilder(
    column: $table.resultsNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get furtherPlan => $composableBuilder(
    column: $table.furtherPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get dataLinks => $composableBuilder(
    column: $table.dataLinks,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.experimentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> experimentUpdatesRefs(
    Expression<bool> Function($$ExperimentUpdatesTableFilterComposer f) f,
  ) {
    final $$ExperimentUpdatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.experimentUpdates,
      getReferencedColumn: (t) => t.experimentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentUpdatesTableFilterComposer(
            $db: $db,
            $table: $db.experimentUpdates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.experimentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExperimentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hypothesis => $composableBuilder(
    column: $table.hypothesis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strainIds => $composableBuilder(
    column: $table.strainIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocolRef => $composableBuilder(
    column: $table.protocolRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodologySteps => $composableBuilder(
    column: $table.methodologySteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultsNotes => $composableBuilder(
    column: $table.resultsNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get furtherPlan => $composableBuilder(
    column: $table.furtherPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataLinks => $composableBuilder(
    column: $table.dataLinks,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExperimentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperimentsTable> {
  $$ExperimentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get hypothesis => $composableBuilder(
    column: $table.hypothesis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ExperimentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get strainIds =>
      $composableBuilder(column: $table.strainIds, builder: (column) => column);

  GeneratedColumn<String> get protocolRef => $composableBuilder(
    column: $table.protocolRef,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get methodologySteps =>
      $composableBuilder(
        column: $table.methodologySteps,
        builder: (column) => column,
      );

  GeneratedColumn<String> get resultsNotes => $composableBuilder(
    column: $table.resultsNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get furtherPlan => $composableBuilder(
    column: $table.furtherPlan,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get dataLinks =>
      $composableBuilder(column: $table.dataLinks, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.experimentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> experimentUpdatesRefs<T extends Object>(
    Expression<T> Function($$ExperimentUpdatesTableAnnotationComposer a) f,
  ) {
    final $$ExperimentUpdatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.experimentUpdates,
          getReferencedColumn: (t) => t.experimentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExperimentUpdatesTableAnnotationComposer(
                $db: $db,
                $table: $db.experimentUpdates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.experimentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExperimentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExperimentsTable,
          Experiment,
          $$ExperimentsTableFilterComposer,
          $$ExperimentsTableOrderingComposer,
          $$ExperimentsTableAnnotationComposer,
          $$ExperimentsTableCreateCompanionBuilder,
          $$ExperimentsTableUpdateCompanionBuilder,
          (Experiment, $$ExperimentsTableReferences),
          Experiment,
          PrefetchHooks Function({
            bool projectId,
            bool tasksRefs,
            bool experimentUpdatesRefs,
            bool imagesRefs,
          })
        > {
  $$ExperimentsTableTableManager(_$AppDatabase db, $ExperimentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> hypothesis = const Value.absent(),
                Value<ExperimentStatus> status = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<List<String>> strainIds = const Value.absent(),
                Value<String> protocolRef = const Value.absent(),
                Value<List<String>> methodologySteps = const Value.absent(),
                Value<String> resultsNotes = const Value.absent(),
                Value<String> conclusion = const Value.absent(),
                Value<String> furtherPlan = const Value.absent(),
                Value<List<String>> dataLinks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                hypothesis: hypothesis,
                status: status,
                date: date,
                strainIds: strainIds,
                protocolRef: protocolRef,
                methodologySteps: methodologySteps,
                resultsNotes: resultsNotes,
                conclusion: conclusion,
                furtherPlan: furtherPlan,
                dataLinks: dataLinks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String projectId,
                required String title,
                Value<String> hypothesis = const Value.absent(),
                Value<ExperimentStatus> status = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<List<String>> strainIds = const Value.absent(),
                Value<String> protocolRef = const Value.absent(),
                Value<List<String>> methodologySteps = const Value.absent(),
                Value<String> resultsNotes = const Value.absent(),
                Value<String> conclusion = const Value.absent(),
                Value<String> furtherPlan = const Value.absent(),
                Value<List<String>> dataLinks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                hypothesis: hypothesis,
                status: status,
                date: date,
                strainIds: strainIds,
                protocolRef: protocolRef,
                methodologySteps: methodologySteps,
                resultsNotes: resultsNotes,
                conclusion: conclusion,
                furtherPlan: furtherPlan,
                dataLinks: dataLinks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExperimentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                tasksRefs = false,
                experimentUpdatesRefs = false,
                imagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tasksRefs) db.tasks,
                    if (experimentUpdatesRefs) db.experimentUpdates,
                    if (imagesRefs) db.images,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$ExperimentsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$ExperimentsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          Experiment,
                          $ExperimentsTable,
                          Task
                        >(
                          currentTable: table,
                          referencedTable: $$ExperimentsTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExperimentsTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.experimentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (experimentUpdatesRefs)
                        await $_getPrefetchedData<
                          Experiment,
                          $ExperimentsTable,
                          ExperimentUpdate
                        >(
                          currentTable: table,
                          referencedTable: $$ExperimentsTableReferences
                              ._experimentUpdatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExperimentsTableReferences(
                                db,
                                table,
                                p0,
                              ).experimentUpdatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.experimentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imagesRefs)
                        await $_getPrefetchedData<
                          Experiment,
                          $ExperimentsTable,
                          AttachedImage
                        >(
                          currentTable: table,
                          referencedTable: $$ExperimentsTableReferences
                              ._imagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExperimentsTableReferences(
                                db,
                                table,
                                p0,
                              ).imagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.experimentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExperimentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExperimentsTable,
      Experiment,
      $$ExperimentsTableFilterComposer,
      $$ExperimentsTableOrderingComposer,
      $$ExperimentsTableAnnotationComposer,
      $$ExperimentsTableCreateCompanionBuilder,
      $$ExperimentsTableUpdateCompanionBuilder,
      (Experiment, $$ExperimentsTableReferences),
      Experiment,
      PrefetchHooks Function({
        bool projectId,
        bool tasksRefs,
        bool experimentUpdatesRefs,
        bool imagesRefs,
      })
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String?> experimentId,
      required String title,
      Value<String> description,
      Value<DateTime?> dueDate,
      Value<TaskStatus> status,
      Value<Priority> priority,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String?> projectId,
      Value<String?> experimentId,
      Value<String> title,
      Value<String> description,
      Value<DateTime?> dueDate,
      Value<TaskStatus> status,
      Value<Priority> priority,
      Value<int> rowid,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('tasks__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExperimentsTable _experimentIdTable(_$AppDatabase db) =>
      db.experiments.createAlias('tasks__experiment_id__experiments__id');

  $$ExperimentsTableProcessedTableManager? get experimentId {
    final $_column = $_itemColumn<String>('experiment_id');
    if ($_column == null) return null;
    final manager = $$ExperimentsTableTableManager(
      $_db,
      $_db.experiments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_experimentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
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

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Priority, Priority, String> get priority =>
      $composableBuilder(
        column: $table.priority,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentsTableFilterComposer get experimentId {
    final $$ExperimentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableFilterComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
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

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentsTableOrderingComposer get experimentId {
    final $$ExperimentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableOrderingComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Priority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentsTableAnnotationComposer get experimentId {
    final $$ExperimentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableAnnotationComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool projectId, bool experimentId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> experimentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                experimentId: experimentId,
                title: title,
                description: description,
                dueDate: dueDate,
                status: status,
                priority: priority,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> experimentId = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                experimentId: experimentId,
                title: title,
                description: description,
                dueDate: dueDate,
                status: status,
                priority: priority,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, experimentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$TasksTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (experimentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.experimentId,
                                referencedTable: $$TasksTableReferences
                                    ._experimentIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._experimentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool projectId, bool experimentId})
    >;
typedef $$StrainsTableCreateCompanionBuilder =
    StrainsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String name,
      Value<String> serialNumber,
      Value<String> hostOrganism,
      Value<String> genotype,
      Value<String> plasmid,
      Value<String> constructNotes,
      Value<List<String>> selectionMarkers,
      Value<String> freezerLocation,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$StrainsTableUpdateCompanionBuilder =
    StrainsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> serialNumber,
      Value<String> hostOrganism,
      Value<String> genotype,
      Value<String> plasmid,
      Value<String> constructNotes,
      Value<List<String>> selectionMarkers,
      Value<String> freezerLocation,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$StrainsTableReferences
    extends BaseReferences<_$AppDatabase, $StrainsTable, Strain> {
  $$StrainsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CulturesTable, List<Culture>> _culturesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cultures,
    aliasName: 'strains__id__cultures__strain_id',
  );

  $$CulturesTableProcessedTableManager get culturesRefs {
    final manager = $$CulturesTableTableManager(
      $_db,
      $_db.cultures,
    ).filter((f) => f.strainId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_culturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'strains__id__images__strain_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.strainId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrainsTableFilterComposer
    extends Composer<_$AppDatabase, $StrainsTable> {
  $$StrainsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostOrganism => $composableBuilder(
    column: $table.hostOrganism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genotype => $composableBuilder(
    column: $table.genotype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plasmid => $composableBuilder(
    column: $table.plasmid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get constructNotes => $composableBuilder(
    column: $table.constructNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get selectionMarkers => $composableBuilder(
    column: $table.selectionMarkers,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get freezerLocation => $composableBuilder(
    column: $table.freezerLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> culturesRefs(
    Expression<bool> Function($$CulturesTableFilterComposer f) f,
  ) {
    final $$CulturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.strainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableFilterComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.strainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrainsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrainsTable> {
  $$StrainsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostOrganism => $composableBuilder(
    column: $table.hostOrganism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genotype => $composableBuilder(
    column: $table.genotype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plasmid => $composableBuilder(
    column: $table.plasmid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get constructNotes => $composableBuilder(
    column: $table.constructNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectionMarkers => $composableBuilder(
    column: $table.selectionMarkers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freezerLocation => $composableBuilder(
    column: $table.freezerLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrainsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrainsTable> {
  $$StrainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hostOrganism => $composableBuilder(
    column: $table.hostOrganism,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genotype =>
      $composableBuilder(column: $table.genotype, builder: (column) => column);

  GeneratedColumn<String> get plasmid =>
      $composableBuilder(column: $table.plasmid, builder: (column) => column);

  GeneratedColumn<String> get constructNotes => $composableBuilder(
    column: $table.constructNotes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get selectionMarkers =>
      $composableBuilder(
        column: $table.selectionMarkers,
        builder: (column) => column,
      );

  GeneratedColumn<String> get freezerLocation => $composableBuilder(
    column: $table.freezerLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> culturesRefs<T extends Object>(
    Expression<T> Function($$CulturesTableAnnotationComposer a) f,
  ) {
    final $$CulturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.strainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableAnnotationComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.strainId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrainsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrainsTable,
          Strain,
          $$StrainsTableFilterComposer,
          $$StrainsTableOrderingComposer,
          $$StrainsTableAnnotationComposer,
          $$StrainsTableCreateCompanionBuilder,
          $$StrainsTableUpdateCompanionBuilder,
          (Strain, $$StrainsTableReferences),
          Strain,
          PrefetchHooks Function({bool culturesRefs, bool imagesRefs})
        > {
  $$StrainsTableTableManager(_$AppDatabase db, $StrainsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> serialNumber = const Value.absent(),
                Value<String> hostOrganism = const Value.absent(),
                Value<String> genotype = const Value.absent(),
                Value<String> plasmid = const Value.absent(),
                Value<String> constructNotes = const Value.absent(),
                Value<List<String>> selectionMarkers = const Value.absent(),
                Value<String> freezerLocation = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrainsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                serialNumber: serialNumber,
                hostOrganism: hostOrganism,
                genotype: genotype,
                plasmid: plasmid,
                constructNotes: constructNotes,
                selectionMarkers: selectionMarkers,
                freezerLocation: freezerLocation,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String name,
                Value<String> serialNumber = const Value.absent(),
                Value<String> hostOrganism = const Value.absent(),
                Value<String> genotype = const Value.absent(),
                Value<String> plasmid = const Value.absent(),
                Value<String> constructNotes = const Value.absent(),
                Value<List<String>> selectionMarkers = const Value.absent(),
                Value<String> freezerLocation = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrainsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                serialNumber: serialNumber,
                hostOrganism: hostOrganism,
                genotype: genotype,
                plasmid: plasmid,
                constructNotes: constructNotes,
                selectionMarkers: selectionMarkers,
                freezerLocation: freezerLocation,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrainsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({culturesRefs = false, imagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (culturesRefs) db.cultures,
                if (imagesRefs) db.images,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (culturesRefs)
                    await $_getPrefetchedData<Strain, $StrainsTable, Culture>(
                      currentTable: table,
                      referencedTable: $$StrainsTableReferences
                          ._culturesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StrainsTableReferences(db, table, p0).culturesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.strainId == item.id),
                      typedResults: items,
                    ),
                  if (imagesRefs)
                    await $_getPrefetchedData<
                      Strain,
                      $StrainsTable,
                      AttachedImage
                    >(
                      currentTable: table,
                      referencedTable: $$StrainsTableReferences
                          ._imagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StrainsTableReferences(db, table, p0).imagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.strainId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StrainsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrainsTable,
      Strain,
      $$StrainsTableFilterComposer,
      $$StrainsTableOrderingComposer,
      $$StrainsTableAnnotationComposer,
      $$StrainsTableCreateCompanionBuilder,
      $$StrainsTableUpdateCompanionBuilder,
      (Strain, $$StrainsTableReferences),
      Strain,
      PrefetchHooks Function({bool culturesRefs, bool imagesRefs})
    >;
typedef $$ReagentsTableCreateCompanionBuilder =
    ReagentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String name,
      Value<String> kind,
      Value<String> supplier,
      Value<String> catalogNo,
      Value<String> lot,
      Value<String> location,
      Value<DateTime?> expiryDate,
      Value<String> quantity,
      Value<String> recipe,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$ReagentsTableUpdateCompanionBuilder =
    ReagentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> kind,
      Value<String> supplier,
      Value<String> catalogNo,
      Value<String> lot,
      Value<String> location,
      Value<DateTime?> expiryDate,
      Value<String> quantity,
      Value<String> recipe,
      Value<String> notes,
      Value<int> rowid,
    });

class $$ReagentsTableFilterComposer
    extends Composer<_$AppDatabase, $ReagentsTable> {
  $$ReagentsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogNo => $composableBuilder(
    column: $table.catalogNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lot => $composableBuilder(
    column: $table.lot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipe => $composableBuilder(
    column: $table.recipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReagentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReagentsTable> {
  $$ReagentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogNo => $composableBuilder(
    column: $table.catalogNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lot => $composableBuilder(
    column: $table.lot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipe => $composableBuilder(
    column: $table.recipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReagentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReagentsTable> {
  $$ReagentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get catalogNo =>
      $composableBuilder(column: $table.catalogNo, builder: (column) => column);

  GeneratedColumn<String> get lot =>
      $composableBuilder(column: $table.lot, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get recipe =>
      $composableBuilder(column: $table.recipe, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ReagentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReagentsTable,
          Reagent,
          $$ReagentsTableFilterComposer,
          $$ReagentsTableOrderingComposer,
          $$ReagentsTableAnnotationComposer,
          $$ReagentsTableCreateCompanionBuilder,
          $$ReagentsTableUpdateCompanionBuilder,
          (Reagent, BaseReferences<_$AppDatabase, $ReagentsTable, Reagent>),
          Reagent,
          PrefetchHooks Function()
        > {
  $$ReagentsTableTableManager(_$AppDatabase db, $ReagentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReagentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReagentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReagentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> supplier = const Value.absent(),
                Value<String> catalogNo = const Value.absent(),
                Value<String> lot = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> recipe = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReagentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                kind: kind,
                supplier: supplier,
                catalogNo: catalogNo,
                lot: lot,
                location: location,
                expiryDate: expiryDate,
                quantity: quantity,
                recipe: recipe,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String> supplier = const Value.absent(),
                Value<String> catalogNo = const Value.absent(),
                Value<String> lot = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> recipe = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReagentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                kind: kind,
                supplier: supplier,
                catalogNo: catalogNo,
                lot: lot,
                location: location,
                expiryDate: expiryDate,
                quantity: quantity,
                recipe: recipe,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReagentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReagentsTable,
      Reagent,
      $$ReagentsTableFilterComposer,
      $$ReagentsTableOrderingComposer,
      $$ReagentsTableAnnotationComposer,
      $$ReagentsTableCreateCompanionBuilder,
      $$ReagentsTableUpdateCompanionBuilder,
      (Reagent, BaseReferences<_$AppDatabase, $ReagentsTable, Reagent>),
      Reagent,
      PrefetchHooks Function()
    >;
typedef $$ManuscriptsTableCreateCompanionBuilder =
    ManuscriptsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String projectId,
      required String title,
      Value<String> targetJournal,
      Value<ManuscriptStatus> status,
      Value<String> submissionId,
      Value<DateTime?> submittedDate,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$ManuscriptsTableUpdateCompanionBuilder =
    ManuscriptsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> projectId,
      Value<String> title,
      Value<String> targetJournal,
      Value<ManuscriptStatus> status,
      Value<String> submissionId,
      Value<DateTime?> submittedDate,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$ManuscriptsTableReferences
    extends BaseReferences<_$AppDatabase, $ManuscriptsTable, Manuscript> {
  $$ManuscriptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('manuscripts__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ManuscriptsTableFilterComposer
    extends Composer<_$AppDatabase, $ManuscriptsTable> {
  $$ManuscriptsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetJournal => $composableBuilder(
    column: $table.targetJournal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ManuscriptStatus, ManuscriptStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedDate => $composableBuilder(
    column: $table.submittedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManuscriptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ManuscriptsTable> {
  $$ManuscriptsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetJournal => $composableBuilder(
    column: $table.targetJournal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedDate => $composableBuilder(
    column: $table.submittedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManuscriptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManuscriptsTable> {
  $$ManuscriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get targetJournal => $composableBuilder(
    column: $table.targetJournal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ManuscriptStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get submittedDate => $composableBuilder(
    column: $table.submittedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManuscriptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManuscriptsTable,
          Manuscript,
          $$ManuscriptsTableFilterComposer,
          $$ManuscriptsTableOrderingComposer,
          $$ManuscriptsTableAnnotationComposer,
          $$ManuscriptsTableCreateCompanionBuilder,
          $$ManuscriptsTableUpdateCompanionBuilder,
          (Manuscript, $$ManuscriptsTableReferences),
          Manuscript,
          PrefetchHooks Function({bool projectId})
        > {
  $$ManuscriptsTableTableManager(_$AppDatabase db, $ManuscriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManuscriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManuscriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManuscriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> targetJournal = const Value.absent(),
                Value<ManuscriptStatus> status = const Value.absent(),
                Value<String> submissionId = const Value.absent(),
                Value<DateTime?> submittedDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManuscriptsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                targetJournal: targetJournal,
                status: status,
                submissionId: submissionId,
                submittedDate: submittedDate,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String projectId,
                required String title,
                Value<String> targetJournal = const Value.absent(),
                Value<ManuscriptStatus> status = const Value.absent(),
                Value<String> submissionId = const Value.absent(),
                Value<DateTime?> submittedDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManuscriptsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                projectId: projectId,
                title: title,
                targetJournal: targetJournal,
                status: status,
                submissionId: submissionId,
                submittedDate: submittedDate,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManuscriptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$ManuscriptsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$ManuscriptsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ManuscriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManuscriptsTable,
      Manuscript,
      $$ManuscriptsTableFilterComposer,
      $$ManuscriptsTableOrderingComposer,
      $$ManuscriptsTableAnnotationComposer,
      $$ManuscriptsTableCreateCompanionBuilder,
      $$ManuscriptsTableUpdateCompanionBuilder,
      (Manuscript, $$ManuscriptsTableReferences),
      Manuscript,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$TombstonesTableCreateCompanionBuilder =
    TombstonesCompanion Function({
      required String id,
      required String entityTable,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });
typedef $$TombstonesTableUpdateCompanionBuilder =
    TombstonesCompanion Function({
      Value<String> id,
      Value<String> entityTable,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$TombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableFilterComposer({
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

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableOrderingComposer({
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

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TombstonesTable,
          Tombstone,
          $$TombstonesTableFilterComposer,
          $$TombstonesTableOrderingComposer,
          $$TombstonesTableAnnotationComposer,
          $$TombstonesTableCreateCompanionBuilder,
          $$TombstonesTableUpdateCompanionBuilder,
          (
            Tombstone,
            BaseReferences<_$AppDatabase, $TombstonesTable, Tombstone>,
          ),
          Tombstone,
          PrefetchHooks Function()
        > {
  $$TombstonesTableTableManager(_$AppDatabase db, $TombstonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TombstonesCompanion(
                id: id,
                entityTable: entityTable,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityTable,
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TombstonesCompanion.insert(
                id: id,
                entityTable: entityTable,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TombstonesTable,
      Tombstone,
      $$TombstonesTableFilterComposer,
      $$TombstonesTableOrderingComposer,
      $$TombstonesTableAnnotationComposer,
      $$TombstonesTableCreateCompanionBuilder,
      $$TombstonesTableUpdateCompanionBuilder,
      (Tombstone, BaseReferences<_$AppDatabase, $TombstonesTable, Tombstone>),
      Tombstone,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaRow,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaRow,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (SyncMetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<int> accentColor,
      Value<String> density,
      Value<String> bgMode,
      Value<int> bgColorA,
      Value<int> bgColorB,
      Value<String> bgImage,
      Value<double> bgDim,
      Value<double> surfaceOpacity,
      Value<double> surfaceBlur,
      Value<String> notifyFrequency,
      Value<String> holidayRegion,
      Value<bool> scheduleNotify,
      Value<bool> allowMultipleInstances,
      Value<DateTime> updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<int> accentColor,
      Value<String> density,
      Value<String> bgMode,
      Value<int> bgColorA,
      Value<int> bgColorB,
      Value<String> bgImage,
      Value<double> bgDim,
      Value<double> surfaceOpacity,
      Value<double> surfaceBlur,
      Value<String> notifyFrequency,
      Value<String> holidayRegion,
      Value<bool> scheduleNotify,
      Value<bool> allowMultipleInstances,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bgMode => $composableBuilder(
    column: $table.bgMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bgColorA => $composableBuilder(
    column: $table.bgColorA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bgColorB => $composableBuilder(
    column: $table.bgColorB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bgImage => $composableBuilder(
    column: $table.bgImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bgDim => $composableBuilder(
    column: $table.bgDim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get surfaceOpacity => $composableBuilder(
    column: $table.surfaceOpacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get surfaceBlur => $composableBuilder(
    column: $table.surfaceBlur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notifyFrequency => $composableBuilder(
    column: $table.notifyFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holidayRegion => $composableBuilder(
    column: $table.holidayRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scheduleNotify => $composableBuilder(
    column: $table.scheduleNotify,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowMultipleInstances => $composableBuilder(
    column: $table.allowMultipleInstances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bgMode => $composableBuilder(
    column: $table.bgMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bgColorA => $composableBuilder(
    column: $table.bgColorA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bgColorB => $composableBuilder(
    column: $table.bgColorB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bgImage => $composableBuilder(
    column: $table.bgImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bgDim => $composableBuilder(
    column: $table.bgDim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get surfaceOpacity => $composableBuilder(
    column: $table.surfaceOpacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get surfaceBlur => $composableBuilder(
    column: $table.surfaceBlur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notifyFrequency => $composableBuilder(
    column: $table.notifyFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holidayRegion => $composableBuilder(
    column: $table.holidayRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scheduleNotify => $composableBuilder(
    column: $table.scheduleNotify,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowMultipleInstances => $composableBuilder(
    column: $table.allowMultipleInstances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get density =>
      $composableBuilder(column: $table.density, builder: (column) => column);

  GeneratedColumn<String> get bgMode =>
      $composableBuilder(column: $table.bgMode, builder: (column) => column);

  GeneratedColumn<int> get bgColorA =>
      $composableBuilder(column: $table.bgColorA, builder: (column) => column);

  GeneratedColumn<int> get bgColorB =>
      $composableBuilder(column: $table.bgColorB, builder: (column) => column);

  GeneratedColumn<String> get bgImage =>
      $composableBuilder(column: $table.bgImage, builder: (column) => column);

  GeneratedColumn<double> get bgDim =>
      $composableBuilder(column: $table.bgDim, builder: (column) => column);

  GeneratedColumn<double> get surfaceOpacity => $composableBuilder(
    column: $table.surfaceOpacity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get surfaceBlur => $composableBuilder(
    column: $table.surfaceBlur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notifyFrequency => $composableBuilder(
    column: $table.notifyFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get holidayRegion => $composableBuilder(
    column: $table.holidayRegion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get scheduleNotify => $composableBuilder(
    column: $table.scheduleNotify,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowMultipleInstances => $composableBuilder(
    column: $table.allowMultipleInstances,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int> accentColor = const Value.absent(),
                Value<String> density = const Value.absent(),
                Value<String> bgMode = const Value.absent(),
                Value<int> bgColorA = const Value.absent(),
                Value<int> bgColorB = const Value.absent(),
                Value<String> bgImage = const Value.absent(),
                Value<double> bgDim = const Value.absent(),
                Value<double> surfaceOpacity = const Value.absent(),
                Value<double> surfaceBlur = const Value.absent(),
                Value<String> notifyFrequency = const Value.absent(),
                Value<String> holidayRegion = const Value.absent(),
                Value<bool> scheduleNotify = const Value.absent(),
                Value<bool> allowMultipleInstances = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                accentColor: accentColor,
                density: density,
                bgMode: bgMode,
                bgColorA: bgColorA,
                bgColorB: bgColorB,
                bgImage: bgImage,
                bgDim: bgDim,
                surfaceOpacity: surfaceOpacity,
                surfaceBlur: surfaceBlur,
                notifyFrequency: notifyFrequency,
                holidayRegion: holidayRegion,
                scheduleNotify: scheduleNotify,
                allowMultipleInstances: allowMultipleInstances,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int> accentColor = const Value.absent(),
                Value<String> density = const Value.absent(),
                Value<String> bgMode = const Value.absent(),
                Value<int> bgColorA = const Value.absent(),
                Value<int> bgColorB = const Value.absent(),
                Value<String> bgImage = const Value.absent(),
                Value<double> bgDim = const Value.absent(),
                Value<double> surfaceOpacity = const Value.absent(),
                Value<double> surfaceBlur = const Value.absent(),
                Value<String> notifyFrequency = const Value.absent(),
                Value<String> holidayRegion = const Value.absent(),
                Value<bool> scheduleNotify = const Value.absent(),
                Value<bool> allowMultipleInstances = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                accentColor: accentColor,
                density: density,
                bgMode: bgMode,
                bgColorA: bgColorA,
                bgColorB: bgColorB,
                bgImage: bgImage,
                bgDim: bgDim,
                surfaceOpacity: surfaceOpacity,
                surfaceBlur: surfaceBlur,
                notifyFrequency: notifyFrequency,
                holidayRegion: holidayRegion,
                scheduleNotify: scheduleNotify,
                allowMultipleInstances: allowMultipleInstances,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CulturesTableCreateCompanionBuilder =
    CulturesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String?> strainId,
      Value<String> status,
      Value<String> medium,
      Value<String> vessel,
      Value<DateTime> startedDate,
      Value<DateTime?> endedDate,
      Value<String> notes,
      Value<String> purpose,
      Value<String> inoculumAmount,
      Value<List<String>> selectionMarkers,
      Value<String?> parentCultureId,
      Value<DateTime?> parentInoculatedAt,
      Value<int> rowid,
    });
typedef $$CulturesTableUpdateCompanionBuilder =
    CulturesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String?> strainId,
      Value<String> status,
      Value<String> medium,
      Value<String> vessel,
      Value<DateTime> startedDate,
      Value<DateTime?> endedDate,
      Value<String> notes,
      Value<String> purpose,
      Value<String> inoculumAmount,
      Value<List<String>> selectionMarkers,
      Value<String?> parentCultureId,
      Value<DateTime?> parentInoculatedAt,
      Value<int> rowid,
    });

final class $$CulturesTableReferences
    extends BaseReferences<_$AppDatabase, $CulturesTable, Culture> {
  $$CulturesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StrainsTable _strainIdTable(_$AppDatabase db) =>
      db.strains.createAlias('cultures__strain_id__strains__id');

  $$StrainsTableProcessedTableManager? get strainId {
    final $_column = $_itemColumn<String>('strain_id');
    if ($_column == null) return null;
    final manager = $$StrainsTableTableManager(
      $_db,
      $_db.strains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'cultures__id__images__culture_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.cultureId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CultureEventsTable, List<CultureEvent>>
  _cultureEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cultureEvents,
    aliasName: 'cultures__id__culture_events__culture_id',
  );

  $$CultureEventsTableProcessedTableManager get cultureEventsRefs {
    final manager = $$CultureEventsTableTableManager(
      $_db,
      $_db.cultureEvents,
    ).filter((f) => f.cultureId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cultureEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CulturesTableFilterComposer
    extends Composer<_$AppDatabase, $CulturesTable> {
  $$CulturesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vessel => $composableBuilder(
    column: $table.vessel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedDate => $composableBuilder(
    column: $table.startedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedDate => $composableBuilder(
    column: $table.endedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inoculumAmount => $composableBuilder(
    column: $table.inoculumAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get selectionMarkers => $composableBuilder(
    column: $table.selectionMarkers,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get parentCultureId => $composableBuilder(
    column: $table.parentCultureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get parentInoculatedAt => $composableBuilder(
    column: $table.parentInoculatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StrainsTableFilterComposer get strainId {
    final $$StrainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableFilterComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.cultureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cultureEventsRefs(
    Expression<bool> Function($$CultureEventsTableFilterComposer f) f,
  ) {
    final $$CultureEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cultureEvents,
      getReferencedColumn: (t) => t.cultureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CultureEventsTableFilterComposer(
            $db: $db,
            $table: $db.cultureEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CulturesTableOrderingComposer
    extends Composer<_$AppDatabase, $CulturesTable> {
  $$CulturesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vessel => $composableBuilder(
    column: $table.vessel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedDate => $composableBuilder(
    column: $table.startedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedDate => $composableBuilder(
    column: $table.endedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inoculumAmount => $composableBuilder(
    column: $table.inoculumAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectionMarkers => $composableBuilder(
    column: $table.selectionMarkers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCultureId => $composableBuilder(
    column: $table.parentCultureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get parentInoculatedAt => $composableBuilder(
    column: $table.parentInoculatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrainsTableOrderingComposer get strainId {
    final $$StrainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableOrderingComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CulturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CulturesTable> {
  $$CulturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get medium =>
      $composableBuilder(column: $table.medium, builder: (column) => column);

  GeneratedColumn<String> get vessel =>
      $composableBuilder(column: $table.vessel, builder: (column) => column);

  GeneratedColumn<DateTime> get startedDate => $composableBuilder(
    column: $table.startedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedDate =>
      $composableBuilder(column: $table.endedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get inoculumAmount => $composableBuilder(
    column: $table.inoculumAmount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get selectionMarkers =>
      $composableBuilder(
        column: $table.selectionMarkers,
        builder: (column) => column,
      );

  GeneratedColumn<String> get parentCultureId => $composableBuilder(
    column: $table.parentCultureId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get parentInoculatedAt => $composableBuilder(
    column: $table.parentInoculatedAt,
    builder: (column) => column,
  );

  $$StrainsTableAnnotationComposer get strainId {
    final $$StrainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableAnnotationComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.cultureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cultureEventsRefs<T extends Object>(
    Expression<T> Function($$CultureEventsTableAnnotationComposer a) f,
  ) {
    final $$CultureEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cultureEvents,
      getReferencedColumn: (t) => t.cultureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CultureEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.cultureEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CulturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CulturesTable,
          Culture,
          $$CulturesTableFilterComposer,
          $$CulturesTableOrderingComposer,
          $$CulturesTableAnnotationComposer,
          $$CulturesTableCreateCompanionBuilder,
          $$CulturesTableUpdateCompanionBuilder,
          (Culture, $$CulturesTableReferences),
          Culture,
          PrefetchHooks Function({
            bool strainId,
            bool imagesRefs,
            bool cultureEventsRefs,
          })
        > {
  $$CulturesTableTableManager(_$AppDatabase db, $CulturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CulturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CulturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CulturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> strainId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> medium = const Value.absent(),
                Value<String> vessel = const Value.absent(),
                Value<DateTime> startedDate = const Value.absent(),
                Value<DateTime?> endedDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> inoculumAmount = const Value.absent(),
                Value<List<String>> selectionMarkers = const Value.absent(),
                Value<String?> parentCultureId = const Value.absent(),
                Value<DateTime?> parentInoculatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CulturesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                strainId: strainId,
                status: status,
                medium: medium,
                vessel: vessel,
                startedDate: startedDate,
                endedDate: endedDate,
                notes: notes,
                purpose: purpose,
                inoculumAmount: inoculumAmount,
                selectionMarkers: selectionMarkers,
                parentCultureId: parentCultureId,
                parentInoculatedAt: parentInoculatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> strainId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> medium = const Value.absent(),
                Value<String> vessel = const Value.absent(),
                Value<DateTime> startedDate = const Value.absent(),
                Value<DateTime?> endedDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> inoculumAmount = const Value.absent(),
                Value<List<String>> selectionMarkers = const Value.absent(),
                Value<String?> parentCultureId = const Value.absent(),
                Value<DateTime?> parentInoculatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CulturesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                strainId: strainId,
                status: status,
                medium: medium,
                vessel: vessel,
                startedDate: startedDate,
                endedDate: endedDate,
                notes: notes,
                purpose: purpose,
                inoculumAmount: inoculumAmount,
                selectionMarkers: selectionMarkers,
                parentCultureId: parentCultureId,
                parentInoculatedAt: parentInoculatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CulturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strainId = false,
                imagesRefs = false,
                cultureEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (imagesRefs) db.images,
                    if (cultureEventsRefs) db.cultureEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strainId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strainId,
                                    referencedTable: $$CulturesTableReferences
                                        ._strainIdTable(db),
                                    referencedColumn: $$CulturesTableReferences
                                        ._strainIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (imagesRefs)
                        await $_getPrefetchedData<
                          Culture,
                          $CulturesTable,
                          AttachedImage
                        >(
                          currentTable: table,
                          referencedTable: $$CulturesTableReferences
                              ._imagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CulturesTableReferences(
                                db,
                                table,
                                p0,
                              ).imagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cultureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cultureEventsRefs)
                        await $_getPrefetchedData<
                          Culture,
                          $CulturesTable,
                          CultureEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CulturesTableReferences
                              ._cultureEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CulturesTableReferences(
                                db,
                                table,
                                p0,
                              ).cultureEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cultureId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CulturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CulturesTable,
      Culture,
      $$CulturesTableFilterComposer,
      $$CulturesTableOrderingComposer,
      $$CulturesTableAnnotationComposer,
      $$CulturesTableCreateCompanionBuilder,
      $$CulturesTableUpdateCompanionBuilder,
      (Culture, $$CulturesTableReferences),
      Culture,
      PrefetchHooks Function({
        bool strainId,
        bool imagesRefs,
        bool cultureEventsRefs,
      })
    >;
typedef $$ExperimentUpdatesTableCreateCompanionBuilder =
    ExperimentUpdatesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String experimentId,
      Value<DateTime> happenedAt,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$ExperimentUpdatesTableUpdateCompanionBuilder =
    ExperimentUpdatesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> experimentId,
      Value<DateTime> happenedAt,
      Value<String> note,
      Value<int> rowid,
    });

final class $$ExperimentUpdatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExperimentUpdatesTable,
          ExperimentUpdate
        > {
  $$ExperimentUpdatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExperimentsTable _experimentIdTable(_$AppDatabase db) => db
      .experiments
      .createAlias('experiment_updates__experiment_id__experiments__id');

  $$ExperimentsTableProcessedTableManager get experimentId {
    final $_column = $_itemColumn<String>('experiment_id')!;

    final manager = $$ExperimentsTableTableManager(
      $_db,
      $_db.experiments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_experimentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'experiment_updates__id__images__update_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.updateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExperimentUpdatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExperimentUpdatesTable> {
  $$ExperimentUpdatesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ExperimentsTableFilterComposer get experimentId {
    final $$ExperimentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableFilterComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.updateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExperimentUpdatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperimentUpdatesTable> {
  $$ExperimentUpdatesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExperimentsTableOrderingComposer get experimentId {
    final $$ExperimentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableOrderingComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExperimentUpdatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperimentUpdatesTable> {
  $$ExperimentUpdatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ExperimentsTableAnnotationComposer get experimentId {
    final $$ExperimentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableAnnotationComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.updateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExperimentUpdatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExperimentUpdatesTable,
          ExperimentUpdate,
          $$ExperimentUpdatesTableFilterComposer,
          $$ExperimentUpdatesTableOrderingComposer,
          $$ExperimentUpdatesTableAnnotationComposer,
          $$ExperimentUpdatesTableCreateCompanionBuilder,
          $$ExperimentUpdatesTableUpdateCompanionBuilder,
          (ExperimentUpdate, $$ExperimentUpdatesTableReferences),
          ExperimentUpdate,
          PrefetchHooks Function({bool experimentId, bool imagesRefs})
        > {
  $$ExperimentUpdatesTableTableManager(
    _$AppDatabase db,
    $ExperimentUpdatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentUpdatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentUpdatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentUpdatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> experimentId = const Value.absent(),
                Value<DateTime> happenedAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentUpdatesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                experimentId: experimentId,
                happenedAt: happenedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String experimentId,
                Value<DateTime> happenedAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentUpdatesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                experimentId: experimentId,
                happenedAt: happenedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExperimentUpdatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({experimentId = false, imagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (imagesRefs) db.images],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (experimentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.experimentId,
                                referencedTable:
                                    $$ExperimentUpdatesTableReferences
                                        ._experimentIdTable(db),
                                referencedColumn:
                                    $$ExperimentUpdatesTableReferences
                                        ._experimentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (imagesRefs)
                    await $_getPrefetchedData<
                      ExperimentUpdate,
                      $ExperimentUpdatesTable,
                      AttachedImage
                    >(
                      currentTable: table,
                      referencedTable: $$ExperimentUpdatesTableReferences
                          ._imagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExperimentUpdatesTableReferences(
                            db,
                            table,
                            p0,
                          ).imagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.updateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExperimentUpdatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExperimentUpdatesTable,
      ExperimentUpdate,
      $$ExperimentUpdatesTableFilterComposer,
      $$ExperimentUpdatesTableOrderingComposer,
      $$ExperimentUpdatesTableAnnotationComposer,
      $$ExperimentUpdatesTableCreateCompanionBuilder,
      $$ExperimentUpdatesTableUpdateCompanionBuilder,
      (ExperimentUpdate, $$ExperimentUpdatesTableReferences),
      ExperimentUpdate,
      PrefetchHooks Function({bool experimentId, bool imagesRefs})
    >;
typedef $$ReportsTableCreateCompanionBuilder =
    ReportsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> title,
      Value<String> recipient,
      Value<String> author,
      Value<DateTime?> periodStart,
      Value<DateTime?> periodEnd,
      Value<String> summary,
      Value<List<String>> projectIds,
      Value<List<String>> experimentIds,
      Value<int> rowid,
    });
typedef $$ReportsTableUpdateCompanionBuilder =
    ReportsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> title,
      Value<String> recipient,
      Value<String> author,
      Value<DateTime?> periodStart,
      Value<DateTime?> periodEnd,
      Value<String> summary,
      Value<List<String>> projectIds,
      Value<List<String>> experimentIds,
      Value<int> rowid,
    });

final class $$ReportsTableReferences
    extends BaseReferences<_$AppDatabase, $ReportsTable, Report> {
  $$ReportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'reports__id__images__report_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.reportId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get projectIds => $composableBuilder(
    column: $table.projectIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get experimentIds => $composableBuilder(
    column: $table.experimentIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.reportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectIds => $composableBuilder(
    column: $table.projectIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get experimentIds => $composableBuilder(
    column: $table.experimentIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get projectIds =>
      $composableBuilder(
        column: $table.projectIds,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get experimentIds =>
      $composableBuilder(
        column: $table.experimentIds,
        builder: (column) => column,
      );

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.reportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, $$ReportsTableReferences),
          Report,
          PrefetchHooks Function({bool imagesRefs})
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> recipient = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<DateTime?> periodStart = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<List<String>> projectIds = const Value.absent(),
                Value<List<String>> experimentIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                recipient: recipient,
                author: author,
                periodStart: periodStart,
                periodEnd: periodEnd,
                summary: summary,
                projectIds: projectIds,
                experimentIds: experimentIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> recipient = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<DateTime?> periodStart = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<List<String>> projectIds = const Value.absent(),
                Value<List<String>> experimentIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                recipient: recipient,
                author: author,
                periodStart: periodStart,
                periodEnd: periodEnd,
                summary: summary,
                projectIds: projectIds,
                experimentIds: experimentIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({imagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (imagesRefs) db.images],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (imagesRefs)
                    await $_getPrefetchedData<
                      Report,
                      $ReportsTable,
                      AttachedImage
                    >(
                      currentTable: table,
                      referencedTable: $$ReportsTableReferences
                          ._imagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReportsTableReferences(db, table, p0).imagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.reportId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, $$ReportsTableReferences),
      Report,
      PrefetchHooks Function({bool imagesRefs})
    >;
typedef $$ProtocolsTableCreateCompanionBuilder =
    ProtocolsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String name,
      Value<String> category,
      Value<String> summary,
      Value<List<String>> steps,
      Value<List<String>> stepIds,
      Value<String> materials,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$ProtocolsTableUpdateCompanionBuilder =
    ProtocolsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> category,
      Value<String> summary,
      Value<List<String>> steps,
      Value<List<String>> stepIds,
      Value<String> materials,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$ProtocolsTableReferences
    extends BaseReferences<_$AppDatabase, $ProtocolsTable, Protocol> {
  $$ProtocolsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ImagesTable, List<AttachedImage>>
  _imagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'protocols__id__images__protocol_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.protocolId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProtocolsTableFilterComposer
    extends Composer<_$AppDatabase, $ProtocolsTable> {
  $$ProtocolsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get stepIds => $composableBuilder(
    column: $table.stepIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get materials => $composableBuilder(
    column: $table.materials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.protocolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProtocolsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProtocolsTable> {
  $$ProtocolsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepIds => $composableBuilder(
    column: $table.stepIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materials => $composableBuilder(
    column: $table.materials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProtocolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProtocolsTable> {
  $$ProtocolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get stepIds =>
      $composableBuilder(column: $table.stepIds, builder: (column) => column);

  GeneratedColumn<String> get materials =>
      $composableBuilder(column: $table.materials, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.protocolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProtocolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProtocolsTable,
          Protocol,
          $$ProtocolsTableFilterComposer,
          $$ProtocolsTableOrderingComposer,
          $$ProtocolsTableAnnotationComposer,
          $$ProtocolsTableCreateCompanionBuilder,
          $$ProtocolsTableUpdateCompanionBuilder,
          (Protocol, $$ProtocolsTableReferences),
          Protocol,
          PrefetchHooks Function({bool imagesRefs})
        > {
  $$ProtocolsTableTableManager(_$AppDatabase db, $ProtocolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProtocolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProtocolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProtocolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<List<String>> steps = const Value.absent(),
                Value<List<String>> stepIds = const Value.absent(),
                Value<String> materials = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProtocolsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                category: category,
                summary: summary,
                steps: steps,
                stepIds: stepIds,
                materials: materials,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String name,
                Value<String> category = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<List<String>> steps = const Value.absent(),
                Value<List<String>> stepIds = const Value.absent(),
                Value<String> materials = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProtocolsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                category: category,
                summary: summary,
                steps: steps,
                stepIds: stepIds,
                materials: materials,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProtocolsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({imagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (imagesRefs) db.images],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (imagesRefs)
                    await $_getPrefetchedData<
                      Protocol,
                      $ProtocolsTable,
                      AttachedImage
                    >(
                      currentTable: table,
                      referencedTable: $$ProtocolsTableReferences
                          ._imagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProtocolsTableReferences(db, table, p0).imagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.protocolId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProtocolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProtocolsTable,
      Protocol,
      $$ProtocolsTableFilterComposer,
      $$ProtocolsTableOrderingComposer,
      $$ProtocolsTableAnnotationComposer,
      $$ProtocolsTableCreateCompanionBuilder,
      $$ProtocolsTableUpdateCompanionBuilder,
      (Protocol, $$ProtocolsTableReferences),
      Protocol,
      PrefetchHooks Function({bool imagesRefs})
    >;
typedef $$ImagesTableCreateCompanionBuilder =
    ImagesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String?> experimentId,
      Value<String?> strainId,
      Value<String?> cultureId,
      Value<String?> updateId,
      Value<String?> reportId,
      Value<String?> protocolId,
      Value<String?> stepId,
      Value<String> caption,
      Value<String> notes,
      Value<List<ImageAnnotation>> annotations,
      Value<String> contentType,
      Value<String> storagePath,
      Value<int> rowid,
    });
typedef $$ImagesTableUpdateCompanionBuilder =
    ImagesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String?> experimentId,
      Value<String?> strainId,
      Value<String?> cultureId,
      Value<String?> updateId,
      Value<String?> reportId,
      Value<String?> protocolId,
      Value<String?> stepId,
      Value<String> caption,
      Value<String> notes,
      Value<List<ImageAnnotation>> annotations,
      Value<String> contentType,
      Value<String> storagePath,
      Value<int> rowid,
    });

final class $$ImagesTableReferences
    extends BaseReferences<_$AppDatabase, $ImagesTable, AttachedImage> {
  $$ImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExperimentsTable _experimentIdTable(_$AppDatabase db) =>
      db.experiments.createAlias('images__experiment_id__experiments__id');

  $$ExperimentsTableProcessedTableManager? get experimentId {
    final $_column = $_itemColumn<String>('experiment_id');
    if ($_column == null) return null;
    final manager = $$ExperimentsTableTableManager(
      $_db,
      $_db.experiments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_experimentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StrainsTable _strainIdTable(_$AppDatabase db) =>
      db.strains.createAlias('images__strain_id__strains__id');

  $$StrainsTableProcessedTableManager? get strainId {
    final $_column = $_itemColumn<String>('strain_id');
    if ($_column == null) return null;
    final manager = $$StrainsTableTableManager(
      $_db,
      $_db.strains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CulturesTable _cultureIdTable(_$AppDatabase db) =>
      db.cultures.createAlias('images__culture_id__cultures__id');

  $$CulturesTableProcessedTableManager? get cultureId {
    final $_column = $_itemColumn<String>('culture_id');
    if ($_column == null) return null;
    final manager = $$CulturesTableTableManager(
      $_db,
      $_db.cultures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cultureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExperimentUpdatesTable _updateIdTable(_$AppDatabase db) => db
      .experimentUpdates
      .createAlias('images__update_id__experiment_updates__id');

  $$ExperimentUpdatesTableProcessedTableManager? get updateId {
    final $_column = $_itemColumn<String>('update_id');
    if ($_column == null) return null;
    final manager = $$ExperimentUpdatesTableTableManager(
      $_db,
      $_db.experimentUpdates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_updateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReportsTable _reportIdTable(_$AppDatabase db) =>
      db.reports.createAlias('images__report_id__reports__id');

  $$ReportsTableProcessedTableManager? get reportId {
    final $_column = $_itemColumn<String>('report_id');
    if ($_column == null) return null;
    final manager = $$ReportsTableTableManager(
      $_db,
      $_db.reports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProtocolsTable _protocolIdTable(_$AppDatabase db) =>
      db.protocols.createAlias('images__protocol_id__protocols__id');

  $$ProtocolsTableProcessedTableManager? get protocolId {
    final $_column = $_itemColumn<String>('protocol_id');
    if ($_column == null) return null;
    final manager = $$ProtocolsTableTableManager(
      $_db,
      $_db.protocols,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_protocolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ImageBlobsTable, List<ImageBlob>>
  _imageBlobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imageBlobs,
    aliasName: 'images__id__image_blobs__id',
  );

  $$ImageBlobsTableProcessedTableManager get imageBlobsRefs {
    final manager = $$ImageBlobsTableTableManager(
      $_db,
      $_db.imageBlobs,
    ).filter((f) => f.id.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageBlobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepId => $composableBuilder(
    column: $table.stepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<ImageAnnotation>,
    List<ImageAnnotation>,
    String
  >
  get annotations => $composableBuilder(
    column: $table.annotations,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  $$ExperimentsTableFilterComposer get experimentId {
    final $$ExperimentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableFilterComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrainsTableFilterComposer get strainId {
    final $$StrainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableFilterComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CulturesTableFilterComposer get cultureId {
    final $$CulturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableFilterComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentUpdatesTableFilterComposer get updateId {
    final $$ExperimentUpdatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.updateId,
      referencedTable: $db.experimentUpdates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentUpdatesTableFilterComposer(
            $db: $db,
            $table: $db.experimentUpdates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReportsTableFilterComposer get reportId {
    final $$ReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportsTableFilterComposer(
            $db: $db,
            $table: $db.reports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProtocolsTableFilterComposer get protocolId {
    final $$ProtocolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.protocolId,
      referencedTable: $db.protocols,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProtocolsTableFilterComposer(
            $db: $db,
            $table: $db.protocols,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> imageBlobsRefs(
    Expression<bool> Function($$ImageBlobsTableFilterComposer f) f,
  ) {
    final $$ImageBlobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageBlobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageBlobsTableFilterComposer(
            $db: $db,
            $table: $db.imageBlobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepId => $composableBuilder(
    column: $table.stepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get annotations => $composableBuilder(
    column: $table.annotations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExperimentsTableOrderingComposer get experimentId {
    final $$ExperimentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableOrderingComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrainsTableOrderingComposer get strainId {
    final $$StrainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableOrderingComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CulturesTableOrderingComposer get cultureId {
    final $$CulturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableOrderingComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentUpdatesTableOrderingComposer get updateId {
    final $$ExperimentUpdatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.updateId,
      referencedTable: $db.experimentUpdates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentUpdatesTableOrderingComposer(
            $db: $db,
            $table: $db.experimentUpdates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReportsTableOrderingComposer get reportId {
    final $$ReportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportsTableOrderingComposer(
            $db: $db,
            $table: $db.reports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProtocolsTableOrderingComposer get protocolId {
    final $$ProtocolsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.protocolId,
      referencedTable: $db.protocols,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProtocolsTableOrderingComposer(
            $db: $db,
            $table: $db.protocols,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stepId =>
      $composableBuilder(column: $table.stepId, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ImageAnnotation>, String>
  get annotations => $composableBuilder(
    column: $table.annotations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  $$ExperimentsTableAnnotationComposer get experimentId {
    final $$ExperimentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.experimentId,
      referencedTable: $db.experiments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExperimentsTableAnnotationComposer(
            $db: $db,
            $table: $db.experiments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrainsTableAnnotationComposer get strainId {
    final $$StrainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strainId,
      referencedTable: $db.strains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrainsTableAnnotationComposer(
            $db: $db,
            $table: $db.strains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CulturesTableAnnotationComposer get cultureId {
    final $$CulturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableAnnotationComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExperimentUpdatesTableAnnotationComposer get updateId {
    final $$ExperimentUpdatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.updateId,
          referencedTable: $db.experimentUpdates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExperimentUpdatesTableAnnotationComposer(
                $db: $db,
                $table: $db.experimentUpdates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ReportsTableAnnotationComposer get reportId {
    final $$ReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.reports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProtocolsTableAnnotationComposer get protocolId {
    final $$ProtocolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.protocolId,
      referencedTable: $db.protocols,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProtocolsTableAnnotationComposer(
            $db: $db,
            $table: $db.protocols,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> imageBlobsRefs<T extends Object>(
    Expression<T> Function($$ImageBlobsTableAnnotationComposer a) f,
  ) {
    final $$ImageBlobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageBlobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageBlobsTableAnnotationComposer(
            $db: $db,
            $table: $db.imageBlobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagesTable,
          AttachedImage,
          $$ImagesTableFilterComposer,
          $$ImagesTableOrderingComposer,
          $$ImagesTableAnnotationComposer,
          $$ImagesTableCreateCompanionBuilder,
          $$ImagesTableUpdateCompanionBuilder,
          (AttachedImage, $$ImagesTableReferences),
          AttachedImage,
          PrefetchHooks Function({
            bool experimentId,
            bool strainId,
            bool cultureId,
            bool updateId,
            bool reportId,
            bool protocolId,
            bool imageBlobsRefs,
          })
        > {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> experimentId = const Value.absent(),
                Value<String?> strainId = const Value.absent(),
                Value<String?> cultureId = const Value.absent(),
                Value<String?> updateId = const Value.absent(),
                Value<String?> reportId = const Value.absent(),
                Value<String?> protocolId = const Value.absent(),
                Value<String?> stepId = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<List<ImageAnnotation>> annotations = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                experimentId: experimentId,
                strainId: strainId,
                cultureId: cultureId,
                updateId: updateId,
                reportId: reportId,
                protocolId: protocolId,
                stepId: stepId,
                caption: caption,
                notes: notes,
                annotations: annotations,
                contentType: contentType,
                storagePath: storagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> experimentId = const Value.absent(),
                Value<String?> strainId = const Value.absent(),
                Value<String?> cultureId = const Value.absent(),
                Value<String?> updateId = const Value.absent(),
                Value<String?> reportId = const Value.absent(),
                Value<String?> protocolId = const Value.absent(),
                Value<String?> stepId = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<List<ImageAnnotation>> annotations = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                experimentId: experimentId,
                strainId: strainId,
                cultureId: cultureId,
                updateId: updateId,
                reportId: reportId,
                protocolId: protocolId,
                stepId: stepId,
                caption: caption,
                notes: notes,
                annotations: annotations,
                contentType: contentType,
                storagePath: storagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ImagesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                experimentId = false,
                strainId = false,
                cultureId = false,
                updateId = false,
                reportId = false,
                protocolId = false,
                imageBlobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (imageBlobsRefs) db.imageBlobs],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (experimentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.experimentId,
                                    referencedTable: $$ImagesTableReferences
                                        ._experimentIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._experimentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (strainId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strainId,
                                    referencedTable: $$ImagesTableReferences
                                        ._strainIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._strainIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (cultureId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cultureId,
                                    referencedTable: $$ImagesTableReferences
                                        ._cultureIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._cultureIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (updateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.updateId,
                                    referencedTable: $$ImagesTableReferences
                                        ._updateIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._updateIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (reportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reportId,
                                    referencedTable: $$ImagesTableReferences
                                        ._reportIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._reportIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (protocolId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.protocolId,
                                    referencedTable: $$ImagesTableReferences
                                        ._protocolIdTable(db),
                                    referencedColumn: $$ImagesTableReferences
                                        ._protocolIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (imageBlobsRefs)
                        await $_getPrefetchedData<
                          AttachedImage,
                          $ImagesTable,
                          ImageBlob
                        >(
                          currentTable: table,
                          referencedTable: $$ImagesTableReferences
                              ._imageBlobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImagesTableReferences(
                                db,
                                table,
                                p0,
                              ).imageBlobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) =>
                                  referencedItems.where((e) => e.id == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagesTable,
      AttachedImage,
      $$ImagesTableFilterComposer,
      $$ImagesTableOrderingComposer,
      $$ImagesTableAnnotationComposer,
      $$ImagesTableCreateCompanionBuilder,
      $$ImagesTableUpdateCompanionBuilder,
      (AttachedImage, $$ImagesTableReferences),
      AttachedImage,
      PrefetchHooks Function({
        bool experimentId,
        bool strainId,
        bool cultureId,
        bool updateId,
        bool reportId,
        bool protocolId,
        bool imageBlobsRefs,
      })
    >;
typedef $$ImageBlobsTableCreateCompanionBuilder =
    ImageBlobsCompanion Function({
      required String id,
      required Uint8List bytes,
      Value<int> rowid,
    });
typedef $$ImageBlobsTableUpdateCompanionBuilder =
    ImageBlobsCompanion Function({
      Value<String> id,
      Value<Uint8List> bytes,
      Value<int> rowid,
    });

final class $$ImageBlobsTableReferences
    extends BaseReferences<_$AppDatabase, $ImageBlobsTable, ImageBlob> {
  $$ImageBlobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImagesTable _idTable(_$AppDatabase db) =>
      db.images.createAlias('image_blobs__id__images__id');

  $$ImagesTableProcessedTableManager get id {
    final $_column = $_itemColumn<String>('id')!;

    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImageBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  $$ImagesTableFilterComposer get id {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImagesTableOrderingComposer get id {
    final $$ImagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableOrderingComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  $$ImagesTableAnnotationComposer get id {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageBlobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageBlobsTable,
          ImageBlob,
          $$ImageBlobsTableFilterComposer,
          $$ImageBlobsTableOrderingComposer,
          $$ImageBlobsTableAnnotationComposer,
          $$ImageBlobsTableCreateCompanionBuilder,
          $$ImageBlobsTableUpdateCompanionBuilder,
          (ImageBlob, $$ImageBlobsTableReferences),
          ImageBlob,
          PrefetchHooks Function({bool id})
        > {
  $$ImageBlobsTableTableManager(_$AppDatabase db, $ImageBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageBlobsCompanion(id: id, bytes: bytes, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List bytes,
                Value<int> rowid = const Value.absent(),
              }) => ImageBlobsCompanion.insert(
                id: id,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImageBlobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.id,
                                referencedTable: $$ImageBlobsTableReferences
                                    ._idTable(db),
                                referencedColumn: $$ImageBlobsTableReferences
                                    ._idTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImageBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageBlobsTable,
      ImageBlob,
      $$ImageBlobsTableFilterComposer,
      $$ImageBlobsTableOrderingComposer,
      $$ImageBlobsTableAnnotationComposer,
      $$ImageBlobsTableCreateCompanionBuilder,
      $$ImageBlobsTableUpdateCompanionBuilder,
      (ImageBlob, $$ImageBlobsTableReferences),
      ImageBlob,
      PrefetchHooks Function({bool id})
    >;
typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<int> rowid,
    });

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            Workspace,
            BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>,
          ),
          Workspace,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (Workspace, BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>),
      Workspace,
      PrefetchHooks Function()
    >;
typedef $$MembershipsTableCreateCompanionBuilder =
    MembershipsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String workspaceId,
      required String userId,
      Value<String> email,
      Value<String> role,
      Value<int> rowid,
    });
typedef $$MembershipsTableUpdateCompanionBuilder =
    MembershipsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> userId,
      Value<String> email,
      Value<String> role,
      Value<int> rowid,
    });

class $$MembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$MembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembershipsTable,
          Membership,
          $$MembershipsTableFilterComposer,
          $$MembershipsTableOrderingComposer,
          $$MembershipsTableAnnotationComposer,
          $$MembershipsTableCreateCompanionBuilder,
          $$MembershipsTableUpdateCompanionBuilder,
          (
            Membership,
            BaseReferences<_$AppDatabase, $MembershipsTable, Membership>,
          ),
          Membership,
          PrefetchHooks Function()
        > {
  $$MembershipsTableTableManager(_$AppDatabase db, $MembershipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembershipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembershipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                userId: userId,
                email: email,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String workspaceId,
                required String userId,
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                userId: userId,
                email: email,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembershipsTable,
      Membership,
      $$MembershipsTableFilterComposer,
      $$MembershipsTableOrderingComposer,
      $$MembershipsTableAnnotationComposer,
      $$MembershipsTableCreateCompanionBuilder,
      $$MembershipsTableUpdateCompanionBuilder,
      (
        Membership,
        BaseReferences<_$AppDatabase, $MembershipsTable, Membership>,
      ),
      Membership,
      PrefetchHooks Function()
    >;
typedef $$WorkspaceInvitesTableCreateCompanionBuilder =
    WorkspaceInvitesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String workspaceId,
      required String email,
      Value<String> role,
      Value<String> invitedBy,
      Value<int> rowid,
    });
typedef $$WorkspaceInvitesTableUpdateCompanionBuilder =
    WorkspaceInvitesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> email,
      Value<String> role,
      Value<String> invitedBy,
      Value<int> rowid,
    });

class $$WorkspaceInvitesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceInvitesTable> {
  $$WorkspaceInvitesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invitedBy => $composableBuilder(
    column: $table.invitedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspaceInvitesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceInvitesTable> {
  $$WorkspaceInvitesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invitedBy => $composableBuilder(
    column: $table.invitedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspaceInvitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceInvitesTable> {
  $$WorkspaceInvitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get invitedBy =>
      $composableBuilder(column: $table.invitedBy, builder: (column) => column);
}

class $$WorkspaceInvitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceInvitesTable,
          WorkspaceInvite,
          $$WorkspaceInvitesTableFilterComposer,
          $$WorkspaceInvitesTableOrderingComposer,
          $$WorkspaceInvitesTableAnnotationComposer,
          $$WorkspaceInvitesTableCreateCompanionBuilder,
          $$WorkspaceInvitesTableUpdateCompanionBuilder,
          (
            WorkspaceInvite,
            BaseReferences<
              _$AppDatabase,
              $WorkspaceInvitesTable,
              WorkspaceInvite
            >,
          ),
          WorkspaceInvite,
          PrefetchHooks Function()
        > {
  $$WorkspaceInvitesTableTableManager(
    _$AppDatabase db,
    $WorkspaceInvitesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceInvitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceInvitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceInvitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> invitedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceInvitesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                email: email,
                role: role,
                invitedBy: invitedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String workspaceId,
                required String email,
                Value<String> role = const Value.absent(),
                Value<String> invitedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceInvitesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                email: email,
                role: role,
                invitedBy: invitedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspaceInvitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceInvitesTable,
      WorkspaceInvite,
      $$WorkspaceInvitesTableFilterComposer,
      $$WorkspaceInvitesTableOrderingComposer,
      $$WorkspaceInvitesTableAnnotationComposer,
      $$WorkspaceInvitesTableCreateCompanionBuilder,
      $$WorkspaceInvitesTableUpdateCompanionBuilder,
      (
        WorkspaceInvite,
        BaseReferences<_$AppDatabase, $WorkspaceInvitesTable, WorkspaceInvite>,
      ),
      WorkspaceInvite,
      PrefetchHooks Function()
    >;
typedef $$PrimersTableCreateCompanionBuilder =
    PrimersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String name,
      Value<String> serialNumber,
      Value<String> sequence,
      Value<String> targetGene,
      Value<String> direction,
      Value<String> tm,
      Value<String> supplier,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$PrimersTableUpdateCompanionBuilder =
    PrimersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> serialNumber,
      Value<String> sequence,
      Value<String> targetGene,
      Value<String> direction,
      Value<String> tm,
      Value<String> supplier,
      Value<String> notes,
      Value<int> rowid,
    });

class $$PrimersTableFilterComposer
    extends Composer<_$AppDatabase, $PrimersTable> {
  $$PrimersTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetGene => $composableBuilder(
    column: $table.targetGene,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tm => $composableBuilder(
    column: $table.tm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrimersTableOrderingComposer
    extends Composer<_$AppDatabase, $PrimersTable> {
  $$PrimersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetGene => $composableBuilder(
    column: $table.targetGene,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tm => $composableBuilder(
    column: $table.tm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrimersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrimersTable> {
  $$PrimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get targetGene => $composableBuilder(
    column: $table.targetGene,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get tm =>
      $composableBuilder(column: $table.tm, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PrimersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrimersTable,
          Primer,
          $$PrimersTableFilterComposer,
          $$PrimersTableOrderingComposer,
          $$PrimersTableAnnotationComposer,
          $$PrimersTableCreateCompanionBuilder,
          $$PrimersTableUpdateCompanionBuilder,
          (Primer, BaseReferences<_$AppDatabase, $PrimersTable, Primer>),
          Primer,
          PrefetchHooks Function()
        > {
  $$PrimersTableTableManager(_$AppDatabase db, $PrimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> serialNumber = const Value.absent(),
                Value<String> sequence = const Value.absent(),
                Value<String> targetGene = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> tm = const Value.absent(),
                Value<String> supplier = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrimersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                serialNumber: serialNumber,
                sequence: sequence,
                targetGene: targetGene,
                direction: direction,
                tm: tm,
                supplier: supplier,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String name,
                Value<String> serialNumber = const Value.absent(),
                Value<String> sequence = const Value.absent(),
                Value<String> targetGene = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> tm = const Value.absent(),
                Value<String> supplier = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrimersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                serialNumber: serialNumber,
                sequence: sequence,
                targetGene: targetGene,
                direction: direction,
                tm: tm,
                supplier: supplier,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrimersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrimersTable,
      Primer,
      $$PrimersTableFilterComposer,
      $$PrimersTableOrderingComposer,
      $$PrimersTableAnnotationComposer,
      $$PrimersTableCreateCompanionBuilder,
      $$PrimersTableUpdateCompanionBuilder,
      (Primer, BaseReferences<_$AppDatabase, $PrimersTable, Primer>),
      Primer,
      PrefetchHooks Function()
    >;
typedef $$CloneConstructionsTableCreateCompanionBuilder =
    CloneConstructionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> notes,
      Value<String> backboneName,
      Value<String> backboneStrainId,
      Value<String> enzymes,
      Value<List<CloneFragment>> fragments,
      Value<int> rowid,
    });
typedef $$CloneConstructionsTableUpdateCompanionBuilder =
    CloneConstructionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> name,
      Value<String> notes,
      Value<String> backboneName,
      Value<String> backboneStrainId,
      Value<String> enzymes,
      Value<List<CloneFragment>> fragments,
      Value<int> rowid,
    });

class $$CloneConstructionsTableFilterComposer
    extends Composer<_$AppDatabase, $CloneConstructionsTable> {
  $$CloneConstructionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backboneName => $composableBuilder(
    column: $table.backboneName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backboneStrainId => $composableBuilder(
    column: $table.backboneStrainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enzymes => $composableBuilder(
    column: $table.enzymes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<CloneFragment>,
    List<CloneFragment>,
    String
  >
  get fragments => $composableBuilder(
    column: $table.fragments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$CloneConstructionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CloneConstructionsTable> {
  $$CloneConstructionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backboneName => $composableBuilder(
    column: $table.backboneName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backboneStrainId => $composableBuilder(
    column: $table.backboneStrainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enzymes => $composableBuilder(
    column: $table.enzymes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fragments => $composableBuilder(
    column: $table.fragments,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CloneConstructionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CloneConstructionsTable> {
  $$CloneConstructionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get backboneName => $composableBuilder(
    column: $table.backboneName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backboneStrainId => $composableBuilder(
    column: $table.backboneStrainId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enzymes =>
      $composableBuilder(column: $table.enzymes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<CloneFragment>, String> get fragments =>
      $composableBuilder(column: $table.fragments, builder: (column) => column);
}

class $$CloneConstructionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CloneConstructionsTable,
          CloneConstruction,
          $$CloneConstructionsTableFilterComposer,
          $$CloneConstructionsTableOrderingComposer,
          $$CloneConstructionsTableAnnotationComposer,
          $$CloneConstructionsTableCreateCompanionBuilder,
          $$CloneConstructionsTableUpdateCompanionBuilder,
          (
            CloneConstruction,
            BaseReferences<
              _$AppDatabase,
              $CloneConstructionsTable,
              CloneConstruction
            >,
          ),
          CloneConstruction,
          PrefetchHooks Function()
        > {
  $$CloneConstructionsTableTableManager(
    _$AppDatabase db,
    $CloneConstructionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CloneConstructionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CloneConstructionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CloneConstructionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> backboneName = const Value.absent(),
                Value<String> backboneStrainId = const Value.absent(),
                Value<String> enzymes = const Value.absent(),
                Value<List<CloneFragment>> fragments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloneConstructionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                notes: notes,
                backboneName: backboneName,
                backboneStrainId: backboneStrainId,
                enzymes: enzymes,
                fragments: fragments,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> backboneName = const Value.absent(),
                Value<String> backboneStrainId = const Value.absent(),
                Value<String> enzymes = const Value.absent(),
                Value<List<CloneFragment>> fragments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloneConstructionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                name: name,
                notes: notes,
                backboneName: backboneName,
                backboneStrainId: backboneStrainId,
                enzymes: enzymes,
                fragments: fragments,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CloneConstructionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CloneConstructionsTable,
      CloneConstruction,
      $$CloneConstructionsTableFilterComposer,
      $$CloneConstructionsTableOrderingComposer,
      $$CloneConstructionsTableAnnotationComposer,
      $$CloneConstructionsTableCreateCompanionBuilder,
      $$CloneConstructionsTableUpdateCompanionBuilder,
      (
        CloneConstruction,
        BaseReferences<
          _$AppDatabase,
          $CloneConstructionsTable,
          CloneConstruction
        >,
      ),
      CloneConstruction,
      PrefetchHooks Function()
    >;
typedef $$TrashEntriesTableCreateCompanionBuilder =
    TrashEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String entityTable,
      required String entityId,
      Value<String> kind,
      Value<String> label,
      Value<DateTime> deletedAt,
      required String payload,
      Value<int> rowid,
    });
typedef $$TrashEntriesTableUpdateCompanionBuilder =
    TrashEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> kind,
      Value<String> label,
      Value<DateTime> deletedAt,
      Value<String> payload,
      Value<int> rowid,
    });

class $$TrashEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrashEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrashEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrashEntriesTable> {
  $$TrashEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$TrashEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrashEntriesTable,
          TrashEntry,
          $$TrashEntriesTableFilterComposer,
          $$TrashEntriesTableOrderingComposer,
          $$TrashEntriesTableAnnotationComposer,
          $$TrashEntriesTableCreateCompanionBuilder,
          $$TrashEntriesTableUpdateCompanionBuilder,
          (
            TrashEntry,
            BaseReferences<_$AppDatabase, $TrashEntriesTable, TrashEntry>,
          ),
          TrashEntry,
          PrefetchHooks Function()
        > {
  $$TrashEntriesTableTableManager(_$AppDatabase db, $TrashEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrashEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrashEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrashEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrashEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                entityTable: entityTable,
                entityId: entityId,
                kind: kind,
                label: label,
                deletedAt: deletedAt,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String entityTable,
                required String entityId,
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => TrashEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                entityTable: entityTable,
                entityId: entityId,
                kind: kind,
                label: label,
                deletedAt: deletedAt,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrashEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrashEntriesTable,
      TrashEntry,
      $$TrashEntriesTableFilterComposer,
      $$TrashEntriesTableOrderingComposer,
      $$TrashEntriesTableAnnotationComposer,
      $$TrashEntriesTableCreateCompanionBuilder,
      $$TrashEntriesTableUpdateCompanionBuilder,
      (
        TrashEntry,
        BaseReferences<_$AppDatabase, $TrashEntriesTable, TrashEntry>,
      ),
      TrashEntry,
      PrefetchHooks Function()
    >;
typedef $$CustomEventsTableCreateCompanionBuilder =
    CustomEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String title,
      required DateTime date,
      Value<String> category,
      Value<String> note,
      Value<bool> repeatAnnually,
      Value<int> rowid,
    });
typedef $$CustomEventsTableUpdateCompanionBuilder =
    CustomEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> title,
      Value<DateTime> date,
      Value<String> category,
      Value<String> note,
      Value<bool> repeatAnnually,
      Value<int> rowid,
    });

class $$CustomEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomEventsTable> {
  $$CustomEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatAnnually => $composableBuilder(
    column: $table.repeatAnnually,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomEventsTable> {
  $$CustomEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatAnnually => $composableBuilder(
    column: $table.repeatAnnually,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomEventsTable> {
  $$CustomEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get repeatAnnually => $composableBuilder(
    column: $table.repeatAnnually,
    builder: (column) => column,
  );
}

class $$CustomEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomEventsTable,
          CustomEvent,
          $$CustomEventsTableFilterComposer,
          $$CustomEventsTableOrderingComposer,
          $$CustomEventsTableAnnotationComposer,
          $$CustomEventsTableCreateCompanionBuilder,
          $$CustomEventsTableUpdateCompanionBuilder,
          (
            CustomEvent,
            BaseReferences<_$AppDatabase, $CustomEventsTable, CustomEvent>,
          ),
          CustomEvent,
          PrefetchHooks Function()
        > {
  $$CustomEventsTableTableManager(_$AppDatabase db, $CustomEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> repeatAnnually = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomEventsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                date: date,
                category: category,
                note: note,
                repeatAnnually: repeatAnnually,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String title,
                required DateTime date,
                Value<String> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> repeatAnnually = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                title: title,
                date: date,
                category: category,
                note: note,
                repeatAnnually: repeatAnnually,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomEventsTable,
      CustomEvent,
      $$CustomEventsTableFilterComposer,
      $$CustomEventsTableOrderingComposer,
      $$CustomEventsTableAnnotationComposer,
      $$CustomEventsTableCreateCompanionBuilder,
      $$CustomEventsTableUpdateCompanionBuilder,
      (
        CustomEvent,
        BaseReferences<_$AppDatabase, $CustomEventsTable, CustomEvent>,
      ),
      CustomEvent,
      PrefetchHooks Function()
    >;
typedef $$CultureEventsTableCreateCompanionBuilder =
    CultureEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      required String cultureId,
      Value<DateTime> happenedAt,
      Value<String> type,
      Value<String> agent,
      Value<String> amount,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$CultureEventsTableUpdateCompanionBuilder =
    CultureEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> workspaceId,
      Value<String> cultureId,
      Value<DateTime> happenedAt,
      Value<String> type,
      Value<String> agent,
      Value<String> amount,
      Value<String> note,
      Value<int> rowid,
    });

final class $$CultureEventsTableReferences
    extends BaseReferences<_$AppDatabase, $CultureEventsTable, CultureEvent> {
  $$CultureEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CulturesTable _cultureIdTable(_$AppDatabase db) =>
      db.cultures.createAlias('culture_events__culture_id__cultures__id');

  $$CulturesTableProcessedTableManager get cultureId {
    final $_column = $_itemColumn<String>('culture_id')!;

    final manager = $$CulturesTableTableManager(
      $_db,
      $_db.cultures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cultureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CultureEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CultureEventsTable> {
  $$CultureEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agent => $composableBuilder(
    column: $table.agent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$CulturesTableFilterComposer get cultureId {
    final $$CulturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableFilterComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CultureEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CultureEventsTable> {
  $$CultureEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agent => $composableBuilder(
    column: $table.agent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$CulturesTableOrderingComposer get cultureId {
    final $$CulturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableOrderingComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CultureEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CultureEventsTable> {
  $$CultureEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get agent =>
      $composableBuilder(column: $table.agent, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$CulturesTableAnnotationComposer get cultureId {
    final $$CulturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cultureId,
      referencedTable: $db.cultures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CulturesTableAnnotationComposer(
            $db: $db,
            $table: $db.cultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CultureEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CultureEventsTable,
          CultureEvent,
          $$CultureEventsTableFilterComposer,
          $$CultureEventsTableOrderingComposer,
          $$CultureEventsTableAnnotationComposer,
          $$CultureEventsTableCreateCompanionBuilder,
          $$CultureEventsTableUpdateCompanionBuilder,
          (CultureEvent, $$CultureEventsTableReferences),
          CultureEvent,
          PrefetchHooks Function({bool cultureId})
        > {
  $$CultureEventsTableTableManager(_$AppDatabase db, $CultureEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CultureEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CultureEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CultureEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> cultureId = const Value.absent(),
                Value<DateTime> happenedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> agent = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CultureEventsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                cultureId: cultureId,
                happenedAt: happenedAt,
                type: type,
                agent: agent,
                amount: amount,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                required String cultureId,
                Value<DateTime> happenedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> agent = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CultureEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                workspaceId: workspaceId,
                cultureId: cultureId,
                happenedAt: happenedAt,
                type: type,
                agent: agent,
                amount: amount,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CultureEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cultureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cultureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cultureId,
                                referencedTable: $$CultureEventsTableReferences
                                    ._cultureIdTable(db),
                                referencedColumn: $$CultureEventsTableReferences
                                    ._cultureIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CultureEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CultureEventsTable,
      CultureEvent,
      $$CultureEventsTableFilterComposer,
      $$CultureEventsTableOrderingComposer,
      $$CultureEventsTableAnnotationComposer,
      $$CultureEventsTableCreateCompanionBuilder,
      $$CultureEventsTableUpdateCompanionBuilder,
      (CultureEvent, $$CultureEventsTableReferences),
      CultureEvent,
      PrefetchHooks Function({bool cultureId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ExperimentsTableTableManager get experiments =>
      $$ExperimentsTableTableManager(_db, _db.experiments);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$StrainsTableTableManager get strains =>
      $$StrainsTableTableManager(_db, _db.strains);
  $$ReagentsTableTableManager get reagents =>
      $$ReagentsTableTableManager(_db, _db.reagents);
  $$ManuscriptsTableTableManager get manuscripts =>
      $$ManuscriptsTableTableManager(_db, _db.manuscripts);
  $$TombstonesTableTableManager get tombstones =>
      $$TombstonesTableTableManager(_db, _db.tombstones);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CulturesTableTableManager get cultures =>
      $$CulturesTableTableManager(_db, _db.cultures);
  $$ExperimentUpdatesTableTableManager get experimentUpdates =>
      $$ExperimentUpdatesTableTableManager(_db, _db.experimentUpdates);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$ProtocolsTableTableManager get protocols =>
      $$ProtocolsTableTableManager(_db, _db.protocols);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
  $$ImageBlobsTableTableManager get imageBlobs =>
      $$ImageBlobsTableTableManager(_db, _db.imageBlobs);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$MembershipsTableTableManager get memberships =>
      $$MembershipsTableTableManager(_db, _db.memberships);
  $$WorkspaceInvitesTableTableManager get workspaceInvites =>
      $$WorkspaceInvitesTableTableManager(_db, _db.workspaceInvites);
  $$PrimersTableTableManager get primers =>
      $$PrimersTableTableManager(_db, _db.primers);
  $$CloneConstructionsTableTableManager get cloneConstructions =>
      $$CloneConstructionsTableTableManager(_db, _db.cloneConstructions);
  $$TrashEntriesTableTableManager get trashEntries =>
      $$TrashEntriesTableTableManager(_db, _db.trashEntries);
  $$CustomEventsTableTableManager get customEvents =>
      $$CustomEventsTableTableManager(_db, _db.customEvents);
  $$CultureEventsTableTableManager get cultureEvents =>
      $$CultureEventsTableTableManager(_db, _db.cultureEvents);
}
