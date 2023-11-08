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
    $core.Map<$core.int, Factor>? factors,
    $core.Map<$core.int, Dependency>? dependencies,
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
    if (dependencies != null) {
      $result.dependencies.addAll(dependencies);
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
    ..m<$core.int, Factor>(4, _omitFieldNames ? '' : 'factors', entryClassName: 'Storage.FactorsEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Factor.create, valueDefaultOrMaker: Factor.getDefault, packageName: const $pb.PackageName('depauth'))
    ..m<$core.int, Dependency>(5, _omitFieldNames ? '' : 'dependencies', entryClassName: 'Storage.DependenciesEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Dependency.create, valueDefaultOrMaker: Dependency.getDefault, packageName: const $pb.PackageName('depauth'))
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
  $core.Map<$core.int, Factor> get factors => $_getMap(3);

  @$pb.TagNumber(5)
  $core.Map<$core.int, Dependency> get dependencies => $_getMap(4);
}

class Entity extends $pb.GeneratedMessage {
  factory Entity({
    $core.String? name,
    $core.int? type,
    $core.int? x,
    $core.int? y,
    $core.int? lost,
    $core.int? compromised,
    $core.int? importance,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (type != null) {
      $result.type = type;
    }
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
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
    return $result;
  }
  Entity._() : super();
  factory Entity.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Entity.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Entity', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'lost', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'compromised', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'importance', $pb.PbFieldType.OU3)
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
  $core.int get x => $_getIZ(2);
  @$pb.TagNumber(3)
  set x($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasX() => $_has(2);
  @$pb.TagNumber(3)
  void clearX() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get y => $_getIZ(3);
  @$pb.TagNumber(4)
  set y($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasY() => $_has(3);
  @$pb.TagNumber(4)
  void clearY() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get lost => $_getIZ(4);
  @$pb.TagNumber(5)
  set lost($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLost() => $_has(4);
  @$pb.TagNumber(5)
  void clearLost() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get compromised => $_getIZ(5);
  @$pb.TagNumber(6)
  set compromised($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCompromised() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompromised() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get importance => $_getIZ(6);
  @$pb.TagNumber(7)
  set importance($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasImportance() => $_has(6);
  @$pb.TagNumber(7)
  void clearImportance() => clearField(7);
}

class Factor extends $pb.GeneratedMessage {
  factory Factor({
    $core.int? entity,
  }) {
    final $result = create();
    if (entity != null) {
      $result.entity = entity;
    }
    return $result;
  }
  Factor._() : super();
  factory Factor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Factor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Factor', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'entity', $pb.PbFieldType.OU3)
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
}

class Dependency extends $pb.GeneratedMessage {
  factory Dependency({
    $core.int? factor,
    $core.int? entity,
  }) {
    final $result = create();
    if (factor != null) {
      $result.factor = factor;
    }
    if (entity != null) {
      $result.entity = entity;
    }
    return $result;
  }
  Dependency._() : super();
  factory Dependency.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Dependency.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Dependency', package: const $pb.PackageName(_omitMessageNames ? '' : 'depauth'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'factor', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'entity', $pb.PbFieldType.OU3)
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

  @$pb.TagNumber(1)
  $core.int get factor => $_getIZ(0);
  @$pb.TagNumber(1)
  set factor($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFactor() => $_has(0);
  @$pb.TagNumber(1)
  void clearFactor() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get entity => $_getIZ(1);
  @$pb.TagNumber(2)
  set entity($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntity() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntity() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
