import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  final _supabase = Supabase.instance.client;
  final _apiService = RainyunApiService();
  List<Map<String, dynamic>> _apiKeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase
          .from('api_keys')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _apiKeys = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('加载API Keys失败: $e');
    }
  }

  Future<void> _addApiKey() async {
    final nameController = TextEditingController();
    final keyController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加 API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：主账号、测试账号',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: '从雨云控制台获取',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text.trim().isEmpty ? '未命名' : nameController.text.trim(),
                  'key': keyController.text.trim(),
                });
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result != null) {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        TDToast.showFail('请先登录', context: context);
        return;
      }

      try {
        // 如果是第一个Key，自动设为激活
        final isFirst = _apiKeys.isEmpty;
        
        await _supabase.from('api_keys').insert({
          'user_id': user.id,
          'name': result['name'],
          'api_key': result['key'],
          'is_active': isFirst,
        });

        if (isFirst) {
          await _apiService.setApiKey(result['key']!);
        }

        TDToast.showSuccess('添加成功', context: context);
        _loadApiKeys();
      } catch (e) {
        TDToast.showFail('添加失败', context: context);
      }
    }
  }

  Future<void> _switchApiKey(Map<String, dynamic> apiKey) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 先将所有Key设为非激活
      await _supabase
          .from('api_keys')
          .update({'is_active': false})
          .eq('user_id', user.id);

      // 激活选中的Key
      await _supabase
          .from('api_keys')
          .update({'is_active': true})
          .eq('id', apiKey['id']);

      // 更新本地API Key
      await _apiService.setApiKey(apiKey['api_key']);

      TDToast.showSuccess('已切换到 ${apiKey['name']}', context: context);
      _loadApiKeys();
    } catch (e) {
      TDToast.showFail('切换失败', context: context);
    }
  }

  Future<void> _editApiKey(Map<String, dynamic> apiKey) async {
    final nameController = TextEditingController(text: apiKey['name']);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑名称'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: '名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _supabase
            .from('api_keys')
            .update({'name': result, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', apiKey['id']);

        TDToast.showSuccess('已更新', context: context);
        _loadApiKeys();
      } catch (e) {
        TDToast.showFail('更新失败', context: context);
      }
    }
  }

  Future<void> _deleteApiKey(Map<String, dynamic> apiKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除 "${apiKey['name']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('api_keys').delete().eq('id', apiKey['id']);

        // 如果删除的是激活的Key，清除本地Key
        if (apiKey['is_active'] == true) {
          await _apiService.setApiKey('');
        }

        TDToast.showSuccess('已删除', context: context);
        _loadApiKeys();
      } catch (e) {
        TDToast.showFail('删除失败', context: context);
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
        title: const Text('API Key 管理'),
        actions: [
          IconButton(
            onPressed: _addApiKey,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _apiKeys.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _apiKeys.length,
                  itemBuilder: (context, index) {
                    final apiKey = _apiKeys[index];
                    return _buildApiKeyCard(apiKey, theme, cardColor);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('暂无 API Key', style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 8),
          Text('点击右上角添加', style: TextStyle(color: theme.hintColor, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addApiKey,
            icon: const Icon(Icons.add),
            label: const Text('添加 API Key'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyCard(Map<String, dynamic> apiKey, ThemeData theme, Color cardColor) {
    final isActive = apiKey['is_active'] == true;
    final key = apiKey['api_key'] as String? ?? '';
    final maskedKey = key.length > 12 ? '${key.substring(0, 8)}****${key.substring(key.length - 4)}' : '****';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: theme.primaryColor, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isActive ? theme.primaryColor : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.vpn_key,
            color: isActive ? theme.primaryColor : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Text(apiKey['name'] ?? '未命名', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('当前', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ],
        ),
        subtitle: Text(maskedKey, style: TextStyle(color: theme.hintColor, fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'switch':
                _switchApiKey(apiKey);
                break;
              case 'edit':
                _editApiKey(apiKey);
                break;
              case 'delete':
                _deleteApiKey(apiKey);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isActive)
              const PopupMenuItem(value: 'switch', child: Text('切换使用')),
            const PopupMenuItem(value: 'edit', child: Text('编辑名称')),
            const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
          ],
        ),
        onTap: isActive ? null : () => _switchApiKey(apiKey),
      ),
    );
  }
}
