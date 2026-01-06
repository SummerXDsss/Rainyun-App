import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class ServerModel with _$ServerModel {
  const factory ServerModel({
    required String id,
    required String name,
    required String type,
    required String status,
    String? region,
    String? ipAddress,
    String? internalIp,
    Map<String, dynamic>? specs,
    DateTime? expireDate,
    DateTime? createDate,
    @Default(false) bool autoRenew,
  }) = _ServerModel;

  factory ServerModel.fromJson(Map<String, dynamic> json) =>
      _$ServerModelFromJson(json);
}

@freezed
class MonitorData with _$MonitorData {
  const factory MonitorData({
    required String serverId,
    @Default(0.0) double cpuUsage,
    @Default(0.0) double memoryUsage,
    @Default(0.0) double diskUsage,
    @Default(0.0) double networkIn,
    @Default(0.0) double networkOut,
    DateTime? timestamp,
  }) = _MonitorData;

  factory MonitorData.fromJson(Map<String, dynamic> json) =>
      _$MonitorDataFromJson(json);
}
