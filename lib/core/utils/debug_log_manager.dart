import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 调试日志类型
enum DebugLogType {
  info,
  request,
  response,
  error,
  warning,
}

/// 调试日志条目
class DebugLogEntry {
  final DateTime timestamp;
  final DebugLogType type;
  final String title;
  final String content;
  final String? extra;
  bool isExpanded;

  DebugLogEntry({
    required this.timestamp,
    required this.type,
    required this.title,
    required this.content,
    this.extra,
    this.isExpanded = false,
  });

  String get typeIcon {
    switch (type) {
      case DebugLogType.info:
        return 'ℹ️';
      case DebugLogType.request:
        return '🌐';
      case DebugLogType.response:
        return '📦';
      case DebugLogType.error:
        return '❌';
      case DebugLogType.warning:
        return '⚠️';
    }
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String get fullLog {
    final buffer = StringBuffer();
    buffer.writeln('[$formattedTime] $typeIcon $title');
    buffer.writeln(content);
    if (extra != null && extra!.isNotEmpty) {
      buffer.writeln('---');
      buffer.writeln(extra);
    }
    return buffer.toString();
  }
}

/// 调试日志管理器（单例）
class DebugLogManager extends ChangeNotifier {
  static final DebugLogManager _instance = DebugLogManager._internal();
  factory DebugLogManager() => _instance;
  DebugLogManager._internal();

  // 调试模式状态
  bool _isDebugMode = false;
  bool get isDebugMode => _isDebugMode;

  // 调试面板显示状态
  bool _isPanelVisible = false;
  bool get isPanelVisible => _isPanelVisible;

  // 日志列表（最多保存500条）
  final Queue<DebugLogEntry> _logs = Queue<DebugLogEntry>();
  static const int _maxLogs = 500;

  List<DebugLogEntry> get logs => _logs.toList();

  /// 验证密码并开启调试模式
  bool enableDebugMode(String password) {
    if (password == 'rainyun2026') {
      _isDebugMode = true;
      _isPanelVisible = true;
      addLog(
        type: DebugLogType.info,
        title: '调试模式已开启',
        content: '欢迎使用调试模式，所有API请求和响应将在此显示。',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 关闭调试模式
  void disableDebugMode() {
    _isDebugMode = false;
    _isPanelVisible = false;
    notifyListeners();
  }

  /// 显示/隐藏调试面板
  void togglePanel() {
    if (_isDebugMode) {
      _isPanelVisible = !_isPanelVisible;
      notifyListeners();
    }
  }

  void showPanel() {
    if (_isDebugMode) {
      _isPanelVisible = true;
      notifyListeners();
    }
  }

  void hidePanel() {
    _isPanelVisible = false;
    notifyListeners();
  }

  /// 添加日志
  void addLog({
    required DebugLogType type,
    required String title,
    required String content,
    String? extra,
  }) {
    final entry = DebugLogEntry(
      timestamp: DateTime.now(),
      type: type,
      title: title,
      content: content,
      extra: extra,
    );

    _logs.addFirst(entry);

    // 限制日志数量
    while (_logs.length > _maxLogs) {
      _logs.removeLast();
    }

    // 同时输出到控制台
    debugPrint('[DEBUG] ${entry.typeIcon} $title');
    
    notifyListeners();
  }

  /// 记录API请求
  void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!_isDebugMode) return;

    final content = StringBuffer();
    content.writeln('$method $url');
    
    if (headers != null && headers.isNotEmpty) {
      content.writeln('\nHeaders:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'x-api-key' && value != null) {
          final keyStr = value.toString();
          content.writeln('  $key: ${keyStr.length > 8 ? '${keyStr.substring(0, 8)}...' : keyStr}');
        } else {
          content.writeln('  $key: $value');
        }
      });
    }

    String? extra;
    if (body != null) {
      extra = 'Body:\n${_formatJson(body)}';
    }

    addLog(
      type: DebugLogType.request,
      title: '$method ${_shortenUrl(url)}',
      content: content.toString(),
      extra: extra,
    );
  }

  /// 记录API响应
  void logResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic data,
    int? durationMs,
  }) {
    if (!_isDebugMode) return;

    final content = StringBuffer();
    content.writeln('Status: $statusCode');
    if (durationMs != null) {
      content.writeln('Duration: ${durationMs}ms');
    }

    String? extra;
    if (data != null) {
      extra = 'Response:\n${_formatJson(data)}';
    }

    addLog(
      type: statusCode >= 200 && statusCode < 300 ? DebugLogType.response : DebugLogType.error,
      title: '[$statusCode] ${_shortenUrl(url)}',
      content: content.toString(),
      extra: extra,
    );
  }

  /// 记录错误
  void logError({
    required String title,
    required String error,
    String? stackTrace,
  }) {
    if (!_isDebugMode) return;

    addLog(
      type: DebugLogType.error,
      title: title,
      content: error,
      extra: stackTrace,
    );
  }

  /// 清空日志
  void clearLogs() {
    _logs.clear();
    addLog(
      type: DebugLogType.info,
      title: '日志已清空',
      content: '所有调试日志已清空。',
    );
  }

  /// 导出所有日志
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== 雨云调试日志 ===');
    buffer.writeln('导出时间: ${DateTime.now()}');
    buffer.writeln('日志条数: ${_logs.length}');
    buffer.writeln('');
    
    for (final log in _logs.toList().reversed) {
      buffer.writeln(log.fullLog);
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  String _shortenUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      return uri.path;
    }
    if (url.length > 40) {
      return '${url.substring(0, 40)}...';
    }
    return url;
  }

  String _formatJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        // 简单格式化，避免太长
        final str = data.toString();
        if (str.length > 2000) {
          return '${str.substring(0, 2000)}...\n[数据过长，已截断]';
        }
        return str;
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
}
