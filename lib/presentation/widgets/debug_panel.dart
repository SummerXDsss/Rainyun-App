import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/debug_log_manager.dart';

/// 可拖动的调试面板
class DebugPanel extends StatefulWidget {
  final Widget child;

  const DebugPanel({super.key, required this.child});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  final DebugLogManager _debugManager = DebugLogManager();
  
  // 面板位置
  double _panelX = 20;
  double _panelY = 100;
  
  // 面板大小状态
  bool _isMinimized = false;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugStateChanged);
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugStateChanged);
    super.dispose();
  }

  void _onDebugStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_debugManager.isDebugMode && _debugManager.isPanelVisible)
          Positioned(
            left: _panelX,
            top: _panelY,
            child: _buildPanel(context),
          ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final panelWidth = _isExpanded ? screenSize.width - 40 : 320.0;
    final panelHeight = _isMinimized ? 48.0 : (_isExpanded ? screenSize.height - 200 : 400.0);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _panelX = (_panelX + details.delta.dx).clamp(0, screenSize.width - panelWidth);
          _panelY = (_panelY + details.delta.dy).clamp(0, screenSize.height - panelHeight);
        });
      },
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
          ),
          child: Column(
            children: [
              _buildHeader(),
              if (!_isMinimized) Expanded(child: _buildLogList()),
              if (!_isMinimized) _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          const Text(
            '调试面板',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          // 最小化按钮
          IconButton(
            icon: Icon(
              _isMinimized ? Icons.expand_less : Icons.expand_more,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () => setState(() => _isMinimized = !_isMinimized),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // 展开/收缩按钮
          if (!_isMinimized)
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          // 隐藏按钮
          IconButton(
            icon: const Icon(Icons.visibility_off, color: Colors.white70, size: 20),
            onPressed: () => _debugManager.hidePanel(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // 关闭调试模式
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => _debugManager.disableDebugMode(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    final logs = _debugManager.logs;
    
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          '暂无日志',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(DebugLogEntry log) {
    final typeColor = _getTypeColor(log.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          InkWell(
            onTap: () {
              setState(() {
                log.isExpanded = !log.isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(log.typeIcon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    log.formattedTime,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.title,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 复制按钮
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14),
                    color: Colors.white54,
                    onPressed: () => _copyToClipboard(log.fullLog),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  Icon(
                    log.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          // 展开内容
          if (log.isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  SelectableText(
                    log.content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (log.extra != null && log.extra!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        log.extra!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text(
            '${_debugManager.logs.length} 条日志',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _copyToClipboard(_debugManager.exportLogs()),
            icon: const Icon(Icons.download, size: 14),
            label: const Text('导出', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          TextButton.icon(
            onPressed: () => _debugManager.clearLogs(),
            icon: const Icon(Icons.delete_outline, size: 14),
            label: const Text('清空', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(DebugLogType type) {
    switch (type) {
      case DebugLogType.info:
        return Colors.blue;
      case DebugLogType.request:
        return Colors.cyan;
      case DebugLogType.response:
        return Colors.green;
      case DebugLogType.error:
        return Colors.red;
      case DebugLogType.warning:
        return Colors.orange;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// 调试模式浮动按钮（用于重新显示面板）
class DebugFloatingButton extends StatelessWidget {
  const DebugFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final debugManager = DebugLogManager();
    
    return ListenableBuilder(
      listenable: debugManager,
      builder: (context, child) {
        if (!debugManager.isDebugMode || debugManager.isPanelVisible) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton.small(
            onPressed: () => debugManager.showPanel(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.bug_report, size: 20),
          ),
        );
      },
    );
  }
}
