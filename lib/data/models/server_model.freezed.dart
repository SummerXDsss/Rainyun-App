// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServerModel _$ServerModelFromJson(Map<String, dynamic> json) {
  return _ServerModel.fromJson(json);
}

/// @nodoc
mixin _$ServerModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get internalIp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get specs => throw _privateConstructorUsedError;
  DateTime? get expireDate => throw _privateConstructorUsedError;
  DateTime? get createDate => throw _privateConstructorUsedError;
  bool get autoRenew => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerModelCopyWith<ServerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerModelCopyWith<$Res> {
  factory $ServerModelCopyWith(
          ServerModel value, $Res Function(ServerModel) then) =
      _$ServerModelCopyWithImpl<$Res, ServerModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      String? region,
      String? ipAddress,
      String? internalIp,
      Map<String, dynamic>? specs,
      DateTime? expireDate,
      DateTime? createDate,
      bool autoRenew});
}

/// @nodoc
class _$ServerModelCopyWithImpl<$Res, $Val extends ServerModel>
    implements $ServerModelCopyWith<$Res> {
  _$ServerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? region = freezed,
    Object? ipAddress = freezed,
    Object? internalIp = freezed,
    Object? specs = freezed,
    Object? expireDate = freezed,
    Object? createDate = freezed,
    Object? autoRenew = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      internalIp: freezed == internalIp
          ? _value.internalIp
          : internalIp // ignore: cast_nullable_to_non_nullable
              as String?,
      specs: freezed == specs
          ? _value.specs
          : specs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expireDate: freezed == expireDate
          ? _value.expireDate
          : expireDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createDate: freezed == createDate
          ? _value.createDate
          : createDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerModelImplCopyWith<$Res>
    implements $ServerModelCopyWith<$Res> {
  factory _$$ServerModelImplCopyWith(
          _$ServerModelImpl value, $Res Function(_$ServerModelImpl) then) =
      __$$ServerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      String? region,
      String? ipAddress,
      String? internalIp,
      Map<String, dynamic>? specs,
      DateTime? expireDate,
      DateTime? createDate,
      bool autoRenew});
}

/// @nodoc
class __$$ServerModelImplCopyWithImpl<$Res>
    extends _$ServerModelCopyWithImpl<$Res, _$ServerModelImpl>
    implements _$$ServerModelImplCopyWith<$Res> {
  __$$ServerModelImplCopyWithImpl(
      _$ServerModelImpl _value, $Res Function(_$ServerModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? region = freezed,
    Object? ipAddress = freezed,
    Object? internalIp = freezed,
    Object? specs = freezed,
    Object? expireDate = freezed,
    Object? createDate = freezed,
    Object? autoRenew = null,
  }) {
    return _then(_$ServerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      internalIp: freezed == internalIp
          ? _value.internalIp
          : internalIp // ignore: cast_nullable_to_non_nullable
              as String?,
      specs: freezed == specs
          ? _value._specs
          : specs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expireDate: freezed == expireDate
          ? _value.expireDate
          : expireDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createDate: freezed == createDate
          ? _value.createDate
          : createDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerModelImpl implements _ServerModel {
  const _$ServerModelImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      this.region,
      this.ipAddress,
      this.internalIp,
      final Map<String, dynamic>? specs,
      this.expireDate,
      this.createDate,
      this.autoRenew = false})
      : _specs = specs;

  factory _$ServerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String status;
  @override
  final String? region;
  @override
  final String? ipAddress;
  @override
  final String? internalIp;
  final Map<String, dynamic>? _specs;
  @override
  Map<String, dynamic>? get specs {
    final value = _specs;
    if (value == null) return null;
    if (_specs is EqualUnmodifiableMapView) return _specs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? expireDate;
  @override
  final DateTime? createDate;
  @override
  @JsonKey()
  final bool autoRenew;

  @override
  String toString() {
    return 'ServerModel(id: $id, name: $name, type: $type, status: $status, region: $region, ipAddress: $ipAddress, internalIp: $internalIp, specs: $specs, expireDate: $expireDate, createDate: $createDate, autoRenew: $autoRenew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.internalIp, internalIp) ||
                other.internalIp == internalIp) &&
            const DeepCollectionEquality().equals(other._specs, _specs) &&
            (identical(other.expireDate, expireDate) ||
                other.expireDate == expireDate) &&
            (identical(other.createDate, createDate) ||
                other.createDate == createDate) &&
            (identical(other.autoRenew, autoRenew) ||
                other.autoRenew == autoRenew));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      status,
      region,
      ipAddress,
      internalIp,
      const DeepCollectionEquality().hash(_specs),
      expireDate,
      createDate,
      autoRenew);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerModelImplCopyWith<_$ServerModelImpl> get copyWith =>
      __$$ServerModelImplCopyWithImpl<_$ServerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerModelImplToJson(
      this,
    );
  }
}

abstract class _ServerModel implements ServerModel {
  const factory _ServerModel(
      {required final String id,
      required final String name,
      required final String type,
      required final String status,
      final String? region,
      final String? ipAddress,
      final String? internalIp,
      final Map<String, dynamic>? specs,
      final DateTime? expireDate,
      final DateTime? createDate,
      final bool autoRenew}) = _$ServerModelImpl;

  factory _ServerModel.fromJson(Map<String, dynamic> json) =
      _$ServerModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get status;
  @override
  String? get region;
  @override
  String? get ipAddress;
  @override
  String? get internalIp;
  @override
  Map<String, dynamic>? get specs;
  @override
  DateTime? get expireDate;
  @override
  DateTime? get createDate;
  @override
  bool get autoRenew;
  @override
  @JsonKey(ignore: true)
  _$$ServerModelImplCopyWith<_$ServerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonitorData _$MonitorDataFromJson(Map<String, dynamic> json) {
  return _MonitorData.fromJson(json);
}

/// @nodoc
mixin _$MonitorData {
  String get serverId => throw _privateConstructorUsedError;
  double get cpuUsage => throw _privateConstructorUsedError;
  double get memoryUsage => throw _privateConstructorUsedError;
  double get diskUsage => throw _privateConstructorUsedError;
  double get networkIn => throw _privateConstructorUsedError;
  double get networkOut => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonitorDataCopyWith<MonitorData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonitorDataCopyWith<$Res> {
  factory $MonitorDataCopyWith(
          MonitorData value, $Res Function(MonitorData) then) =
      _$MonitorDataCopyWithImpl<$Res, MonitorData>;
  @useResult
  $Res call(
      {String serverId,
      double cpuUsage,
      double memoryUsage,
      double diskUsage,
      double networkIn,
      double networkOut,
      DateTime? timestamp});
}

/// @nodoc
class _$MonitorDataCopyWithImpl<$Res, $Val extends MonitorData>
    implements $MonitorDataCopyWith<$Res> {
  _$MonitorDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverId = null,
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? networkIn = null,
    Object? networkOut = null,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      cpuUsage: null == cpuUsage
          ? _value.cpuUsage
          : cpuUsage // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as double,
      networkIn: null == networkIn
          ? _value.networkIn
          : networkIn // ignore: cast_nullable_to_non_nullable
              as double,
      networkOut: null == networkOut
          ? _value.networkOut
          : networkOut // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonitorDataImplCopyWith<$Res>
    implements $MonitorDataCopyWith<$Res> {
  factory _$$MonitorDataImplCopyWith(
          _$MonitorDataImpl value, $Res Function(_$MonitorDataImpl) then) =
      __$$MonitorDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverId,
      double cpuUsage,
      double memoryUsage,
      double diskUsage,
      double networkIn,
      double networkOut,
      DateTime? timestamp});
}

/// @nodoc
class __$$MonitorDataImplCopyWithImpl<$Res>
    extends _$MonitorDataCopyWithImpl<$Res, _$MonitorDataImpl>
    implements _$$MonitorDataImplCopyWith<$Res> {
  __$$MonitorDataImplCopyWithImpl(
      _$MonitorDataImpl _value, $Res Function(_$MonitorDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverId = null,
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? networkIn = null,
    Object? networkOut = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$MonitorDataImpl(
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      cpuUsage: null == cpuUsage
          ? _value.cpuUsage
          : cpuUsage // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as double,
      networkIn: null == networkIn
          ? _value.networkIn
          : networkIn // ignore: cast_nullable_to_non_nullable
              as double,
      networkOut: null == networkOut
          ? _value.networkOut
          : networkOut // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonitorDataImpl implements _MonitorData {
  const _$MonitorDataImpl(
      {required this.serverId,
      this.cpuUsage = 0.0,
      this.memoryUsage = 0.0,
      this.diskUsage = 0.0,
      this.networkIn = 0.0,
      this.networkOut = 0.0,
      this.timestamp});

  factory _$MonitorDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonitorDataImplFromJson(json);

  @override
  final String serverId;
  @override
  @JsonKey()
  final double cpuUsage;
  @override
  @JsonKey()
  final double memoryUsage;
  @override
  @JsonKey()
  final double diskUsage;
  @override
  @JsonKey()
  final double networkIn;
  @override
  @JsonKey()
  final double networkOut;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'MonitorData(serverId: $serverId, cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, diskUsage: $diskUsage, networkIn: $networkIn, networkOut: $networkOut, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonitorDataImpl &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.diskUsage, diskUsage) ||
                other.diskUsage == diskUsage) &&
            (identical(other.networkIn, networkIn) ||
                other.networkIn == networkIn) &&
            (identical(other.networkOut, networkOut) ||
                other.networkOut == networkOut) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, serverId, cpuUsage, memoryUsage,
      diskUsage, networkIn, networkOut, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonitorDataImplCopyWith<_$MonitorDataImpl> get copyWith =>
      __$$MonitorDataImplCopyWithImpl<_$MonitorDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonitorDataImplToJson(
      this,
    );
  }
}

abstract class _MonitorData implements MonitorData {
  const factory _MonitorData(
      {required final String serverId,
      final double cpuUsage,
      final double memoryUsage,
      final double diskUsage,
      final double networkIn,
      final double networkOut,
      final DateTime? timestamp}) = _$MonitorDataImpl;

  factory _MonitorData.fromJson(Map<String, dynamic> json) =
      _$MonitorDataImpl.fromJson;

  @override
  String get serverId;
  @override
  double get cpuUsage;
  @override
  double get memoryUsage;
  @override
  double get diskUsage;
  @override
  double get networkIn;
  @override
  double get networkOut;
  @override
  DateTime? get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$MonitorDataImplCopyWith<_$MonitorDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
