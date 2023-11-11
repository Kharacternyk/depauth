//
//  Generated code. Do not modify.
//  source: protos/storage.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Storage extends $pb.GeneratedMessage {
  factory Storage({
    $core.int? identity,
    $core.int? version,
    $core.Map<$core.int, Entity>? entities,
    $core.Iterable<Factor>? factors,
  }) {
    final $result = create();
    if (identity != null) {
      $result.identity = identity;
    }
    if (version != null) {
      $result.version = version;
    }
    if (entities != null) {
      $result.entities.addAll(entities);
    }
    if (factors != null) {
      $result.factors.addAll(factors);
    }
    return $result;
  }
  Storage._() : super();
  factory Storage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Storage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Storage', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..m<$core.int, Entity>(3, _omitFieldNames ? '' : 'entities', entryClassName: 'Storage.EntitiesEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Entity.create, valueDefaultOrMaker: Entity.getDefault, packageName: const $pb.PackageName('depauth'))
    ..pc<Factor>(4, _omitFieldNames ? '' : 'factors', $pb.PbFieldType.PM, subBuilder: Factor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Storage clone() => Storage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Storage copyWith(void Function(Storage) updates) => super.copyWith((message) => updates(message as Storage)) as Storage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Storage create() => Storage._();
  Storage createEmptyInstance() => create();
  static $pb.PbList<Storage> createRepeated() => $pb.PbList<Storage>();
  @$core.pragma('dart2js:noInline')
  static Storage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Storage>(create);
  static Storage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get identity => $_getIZ(0);
  @$pb.TagNumber(1)
  set identity($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.Map<$core.int, Entity> get entities => $_getMap(2);

  @$pb.TagNumber(4)
  $core.List<Factor> get factors => $_getList(3);
}

class Entity extends $pb.GeneratedMessage {
  factory Entity({
    $core.String? name,
    $core.int? type,
    $core.int? lost,
    $core.int? compromised,
    $core.int? importance,
    Note? note,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (type != null) {
      $result.type = type;
    }
    if (lost != null) {
      $result.lost = lost;
    }
    if (compromised != null) {
      $result.compromised = compromised;
    }
    if (importance != null) {
      $result.importance = importance;
    }
    if (note != null) {
      $result.note = note;
    }
    return $result;
  }
  Entity._() : super();
  factory Entity.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Entity.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Entity', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'lost', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'compromised', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'importance', $pb.PbFieldType.OU3)
    ..aOM<Note>(6, _omitFieldNames ? '' : 'note', subBuilder: Note.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Entity clone() => Entity()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Entity copyWith(void Function(Entity) updates) => super.copyWith((message) => updates(message as Entity)) as Entity;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Entity create() => Entity._();
  Entity createEmptyInstance() => create();
  static $pb.PbList<Entity> createRepeated() => $pb.PbList<Entity>();
  @$core.pragma('dart2js:noInline')
  static Entity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Entity>(create);
  static Entity? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get type => $_getIZ(1);
  @$pb.TagNumber(2)
  set type($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get lost => $_getIZ(2);
  @$pb.TagNumber(3)
  set lost($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLost() => $_has(2);
  @$pb.TagNumber(3)
  void clearLost() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get compromised => $_getIZ(3);
  @$pb.TagNumber(4)
  set compromised($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCompromised() => $_has(3);
  @$pb.TagNumber(4)
  void clearCompromised() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get importance => $_getIZ(4);
  @$pb.TagNumber(5)
  set importance($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasImportance() => $_has(4);
  @$pb.TagNumber(5)
  void clearImportance() => clearField(5);

  @$pb.TagNumber(6)
  Note get note => $_getN(5);
  @$pb.TagNumber(6)
  set note(Note v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => clearField(6);
  @$pb.TagNumber(6)
  Note ensureNote() => $_ensure(5);
}

class Factor extends $pb.GeneratedMessage {
  factory Factor({
    $core.int? entity,
    $core.int? threshold,
    $core.Map<$core.int, Dependency>? dependencies,
  }) {
    final $result = create();
    if (entity != null) {
      $result.entity = entity;
    }
    if (threshold != null) {
      $result.threshold = threshold;
    }
    if (dependencies != null) {
      $result.dependencies.addAll(dependencies);
    }
    return $result;
  }
  Factor._() : super();
  factory Factor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Factor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Factor', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'entity', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'threshold', $pb.PbFieldType.OU3)
    ..m<$core.int, Dependency>(3, _omitFieldNames ? '' : 'dependencies', entryClassName: 'Factor.DependenciesEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Dependency.create, valueDefaultOrMaker: Dependency.getDefault, packageName: const $pb.PackageName('depauth'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Factor clone() => Factor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Factor copyWith(void Function(Factor) updates) => super.copyWith((message) => updates(message as Factor)) as Factor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Factor create() => Factor._();
  Factor createEmptyInstance() => create();
  static $pb.PbList<Factor> createRepeated() => $pb.PbList<Factor>();
  @$core.pragma('dart2js:noInline')
  static Factor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Factor>(create);
  static Factor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entity => $_getIZ(0);
  @$pb.TagNumber(1)
  set entity($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get threshold => $_getIZ(1);
  @$pb.TagNumber(2)
  set threshold($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasThreshold() => $_has(1);
  @$pb.TagNumber(2)
  void clearThreshold() => clearField(2);

  @$pb.TagNumber(3)
  $core.Map<$core.int, Dependency> get dependencies => $_getMap(2);
}

class Note extends $pb.GeneratedMessage {
  factory Note({
    $core.String? text,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  Note._() : super();
  factory Note.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Note.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Note', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Note clone() => Note()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Note copyWith(void Function(Note) updates) => super.copyWith((message) => updates(message as Note)) as Note;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Note create() => Note._();
  Note createEmptyInstance() => create();
  static $pb.PbList<Note> createRepeated() => $pb.PbList<Note>();
  @$core.pragma('dart2js:noInline')
  static Note getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Note>(create);
  static Note? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);
}

class Dependency extends $pb.GeneratedMessage {
  factory Dependency() => create();
  Dependency._() : super();
  factory Dependency.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Dependency.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Dependency', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Dependency clone() => Dependency()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Dependency copyWith(void Function(Dependency) updates) => super.copyWith((message) => updates(message as Dependency)) as Dependency;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Dependency create() => Dependency._();
  Dependency createEmptyInstance() => create();
  static $pb.PbList<Dependency> createRepeated() => $pb.PbList<Dependency>();
  @$core.pragma('dart2js:noInline')
  static Dependency getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Dependency>(create);
  static Dependency? _defaultInstance;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
