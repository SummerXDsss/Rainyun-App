// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServerModelImpl _$$ServerModelImplFromJson(Map<String, dynamic> json) =>
    _$ServerModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      region: json['region'] as String?,
      ipAddress: json['ipAddress'] as String?,
      internalIp: json['internalIp'] as String?,
      specs: json['specs'] as Map<String, dynamic>?,
      expireDate: json['expireDate'] == null
          ? null
          : DateTime.parse(json['expireDate'] as String),
      createDate: json['createDate'] == null
          ? null
          : DateTime.parse(json['createDate'] as String),
      autoRenew: json['autoRenew'] as bool? ?? false,
    );

Map<String, dynamic> _$$ServerModelImplToJson(_$ServerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'region': instance.region,
      'ipAddress': instance.ipAddress,
      'internalIp': instance.internalIp,
      'specs': instance.specs,
      'expireDate': instance.expireDate?.toIso8601String(),
      'createDate': instance.createDate?.toIso8601String(),
      'autoRenew': instance.autoRenew,
    };

_$MonitorDataImpl _$$MonitorDataImplFromJson(Map<String, dynamic> json) =>
    _$MonitorDataImpl(
      serverId: json['serverId'] as String,
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      memoryUsage: (json['memoryUsage'] as num?)?.toDouble() ?? 0.0,
      diskUsage: (json['diskUsage'] as num?)?.toDouble() ?? 0.0,
      networkIn: (json['networkIn'] as num?)?.toDouble() ?? 0.0,
      networkOut: (json['networkOut'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$MonitorDataImplToJson(_$MonitorDataImpl instance) =>
    <String, dynamic>{
      'serverId': instance.serverId,
      'cpuUsage': instance.cpuUsage,
      'memoryUsage': instance.memoryUsage,
      'diskUsage': instance.diskUsage,
      'networkIn': instance.networkIn,
      'networkOut': instance.networkOut,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
