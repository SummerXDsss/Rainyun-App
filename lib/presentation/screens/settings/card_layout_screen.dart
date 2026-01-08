import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'dart:convert';

// 卡片元素定义
class CardElement {
  final String id;
  final String name;
  final String description;
  bool enabled;
  
  CardElement({
    required this.id,
    required this.name,
    required this.description,
    this.enabled = true,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'enabled': enabled,
  };
  
  factory CardElement.fromJson(Map<String, dynamic> json) => CardElement(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    enabled: json['enabled'] ?? true,
  );
}

// 默认卡片元素列表
List<CardElement> getDefaultCardElements() => [
  CardElement(id: 'type_tag', name: '类型标签', description: '显示云服务器/游戏云等类型', enabled: true),
  CardElement(id: 'server_name', name: '服务器名称', description: '显示服务器名称或别名', enabled: true),
  CardElement(id: 'status', name: '运行状态', description: '显示运行中/已停止状态', enabled: true),
  CardElement(id: 'region', name: '地区信息', description: '显示服务器所在地区', enabled: true),
  CardElement(id: 'ip_address', name: 'IP地址', description: '显示服务器IP地址', enabled: true),
  CardElement(id: 'specs', name: '配置信息', description: '显示CPU/内存/带宽配置', enabled: true),
  CardElement(id: 'expire_date', name: '到期时间', description: '显示服务到期日期', enabled: true),
  CardElement(id: 'cpu_usage', name: 'CPU使用率', description: '显示CPU占用百分比', enabled: true),
  CardElement(id: 'mem_usage', name: '内存使用率', description: '显示内存占用百分比', enabled: true),
];

// 卡片布局配置Provider
final cardLayoutProvider = StateNotifierProvider<CardLayoutNotifier, List<CardElement>>((ref) {
  return CardLayoutNotifier();
});

class CardLayoutNotifier extends StateNotifier<List<CardElement>> {
  CardLayoutNotifier() : super(getDefaultCardElements()) {
    _loadFromPrefs();
  }
  
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('card_layout');
    if (jsonStr != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonStr);
        state = jsonList.map((e) => CardElement.fromJson(e)).toList();
      } catch (e) {
        state = getDefaultCardElements();
      }
    }
  }
  
  Future<void> saveLayout(List<CardElement> elements) async {
    state = elements;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(elements.map((e) => e.toJson()).toList());
    await prefs.setString('card_layout', jsonStr);
  }
  
  Future<void> resetToDefault() async {
    state = getDefaultCardElements();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('card_layout');
  }
  
  bool isElementEnabled(String id) {
    return state.firstWhere((e) => e.id == id, orElse: () => CardElement(id: '', name: '', description: '', enabled: true)).enabled;
  }
  
  int getElementIndex(String id) {
    return state.indexWhere((e) => e.id == id);
  }
}

class CardLayoutScreen extends ConsumerStatefulWidget {
  const CardLayoutScreen({super.key});

  @override
  ConsumerState<CardLayoutScreen> createState() => _CardLayoutScreenState();
}

class _CardLayoutScreenState extends ConsumerState<CardLayoutScreen> {
  late List<CardElement> _elements;
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _elements = List.from(ref.read(cardLayoutProvider).map((e) => CardElement(
      id: e.id,
      name: e.name,
      description: e.description,
      enabled: e.enabled,
    )));
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _elements.removeAt(oldIndex);
      _elements.insert(newIndex, item);
      _hasChanges = true;
    });
  }
  
  void _toggleElement(int index) {
    setState(() {
      _elements[index].enabled = !_elements[index].enabled;
      _hasChanges = true;
    });
  }
  
  Future<void> _saveAndApply() async {
    await ref.read(cardLayoutProvider.notifier).saveLayout(_elements);
    if (mounted) {
      TDToast.showSuccess('保存成功，即将重载', context: context);
      // 延迟后重载应用
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
  
  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复默认'),
        content: const Text('确定要恢复默认布局设置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await ref.read(cardLayoutProvider.notifier).resetToDefault();
      setState(() {
        _elements = List.from(ref.read(cardLayoutProvider).map((e) => CardElement(
          id: e.id,
          name: e.name,
          description: e.description,
          enabled: e.enabled,
        )));
        _hasChanges = false;
      });
      if (mounted) {
        TDToast.showSuccess('已恢复默认', context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片布局设置'),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: const Text('恢复默认'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 提示信息
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '拖拽调整显示顺序，点击开关控制是否显示',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          
          // 元素列表
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _elements.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final element = _elements[index];
                return Container(
                  key: ValueKey(element.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: element.enabled 
                          ? theme.primaryColor.withOpacity(0.3)
                          : theme.hintColor.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.hintColor,
                      ),
                    ),
                    title: Text(
                      element.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: element.enabled ? null : theme.hintColor,
                      ),
                    ),
                    subtitle: Text(
                      element.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                    trailing: Switch(
                      value: element.enabled,
                      onChanged: (_) => _toggleElement(index),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 保存按钮
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveAndApply : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('保存并应用', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
