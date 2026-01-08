import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/rainyun_api_service.dart';
import 'card_layout_screen.dart';

// 主题模式Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadFromPrefs();
  }
  
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString('theme_mode') ?? 'system';
    state = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString('theme_mode', themeModeStr);
  }
}

// 卡片样式Provider
final cardStyleProvider = StateNotifierProvider<CardStyleNotifier, String>((ref) {
  return CardStyleNotifier();
});

class CardStyleNotifier extends StateNotifier<String> {
  CardStyleNotifier() : super('list') {
    _loadFromPrefs();
  }
  
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('card_style') ?? 'list';
  }
  
  Future<void> setCardStyle(String style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_style', style);
  }
}

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final _supabase = Supabase.instance.client;
  final _apiService = RainyunApiService();
  bool _isLoading = false;
  String _currentApiKey = '';
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _currentApiKey = _apiService.getApiKey() ?? '';
  }
  
  Future<void> _loadPreferences() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('preferences, rainyun_api_key')
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response != null) {
        final prefs = response['preferences'] as Map<String, dynamic>? ?? {};
        
        // 从云端加载主题模式（会自动保存到本地）
        final themeModeStr = prefs['theme_mode'] as String? ?? 'system';
        final themeMode = switch (themeModeStr) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
        await ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
        
        // 从云端加载卡片样式（会自动保存到本地）
        final cardStyle = prefs['card_style'] as String? ?? 'list';
        await ref.read(cardStyleProvider.notifier).setCardStyle(cardStyle);
        
        // 如果本地没有API Key但云端有，则同步到本地
        final cloudApiKey = response['rainyun_api_key'] as String?;
        if (cloudApiKey != null && cloudApiKey.isNotEmpty && _currentApiKey.isEmpty) {
          await _apiService.setApiKey(cloudApiKey);
          setState(() => _currentApiKey = cloudApiKey);
        }
      }
    } catch (e) {
      debugPrint('加载偏好设置失败: $e');
    }
  }
  
  Future<void> _savePreferencesToCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final themeMode = ref.read(themeModeProvider);
    final cardStyle = ref.read(cardStyleProvider);
    
    final themeModeStr = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    
    try {
      await _supabase.from('user_profiles').upsert({
        'user_id': user.id,
        'preferences': {
          'theme_mode': themeModeStr,
          'card_style': cardStyle,
        },
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('保存偏好设置到云端失败: $e');
    }
  }
  
  Future<void> _syncApiKeyToCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      TDToast.showFail('请先登录', context: context);
      return;
    }
    
    if (_currentApiKey.isEmpty) {
      TDToast.showFail('请先绑定API Key', context: context);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _supabase.from('user_profiles').upsert({
        'user_id': user.id,
        'rainyun_api_key': _currentApiKey,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
      
      TDToast.showSuccess('API Key已同步到云端', context: context);
    } catch (e) {
      TDToast.showFail('同步失败', context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _syncApiKeyFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      TDToast.showFail('请先登录', context: context);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('rainyun_api_key')
          .eq('user_id', user.id)
          .maybeSingle();
      
      final cloudApiKey = response?['rainyun_api_key'] as String?;
      if (cloudApiKey != null && cloudApiKey.isNotEmpty) {
        await _apiService.setApiKey(cloudApiKey);
        setState(() => _currentApiKey = cloudApiKey);
        TDToast.showSuccess('API Key已从云端同步', context: context);
      } else {
        TDToast.showText('云端没有保存的API Key', context: context);
      }
    } catch (e) {
      TDToast.showFail('同步失败', context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    final themeMode = ref.watch(themeModeProvider);
    final cardStyle = ref.watch(cardStyleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个性化设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题设置
          _buildSectionTitle('主题设置'),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  '跟随系统',
                  Icons.brightness_auto,
                  ThemeMode.system,
                  themeMode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  '浅色模式',
                  Icons.light_mode,
                  ThemeMode.light,
                  themeMode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  '深色模式',
                  Icons.dark_mode,
                  ThemeMode.dark,
                  themeMode,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 卡片样式
          _buildSectionTitle('服务器卡片样式'),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStyleOption(
                  '列表样式',
                  '经典条状卡片展示',
                  Icons.view_list,
                  'list',
                  cardStyle,
                ),
                const Divider(height: 1),
                _buildStyleOption(
                  '仪表盘样式',
                  '网格化信息展示',
                  Icons.dashboard,
                  'dashboard',
                  cardStyle,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 卡片内容配置
          _buildSectionTitle('卡片内容配置'),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.tune, color: theme.primaryColor),
              title: const Text('自定义卡片布局'),
              subtitle: Text(
                '调整卡片显示内容和排列顺序',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CardLayoutScreen()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // API Key 云端同步
          _buildSectionTitle('API Key 云端同步'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.vpn_key, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentApiKey.isNotEmpty 
                            ? '${_currentApiKey.substring(0, 8)}****'
                            : '未绑定API Key',
                        style: TextStyle(
                          color: _currentApiKey.isNotEmpty ? null : theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '将API Key同步到云端，方便在其他设备登录时自动获取',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _syncApiKeyToCloud,
                        icon: const Icon(Icons.cloud_upload, size: 18),
                        label: const Text('上传到云端'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _syncApiKeyFromCloud,
                        icon: const Icon(Icons.cloud_download, size: 18),
                        label: const Text('从云端同步'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 提示信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '长按服务器卡片可自定义服务器名称',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
  
  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode, ThemeMode current) {
    final isSelected = mode == current;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(title),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () async {
        await ref.read(themeModeProvider.notifier).setThemeMode(mode);
        _savePreferencesToCloud();
      },
    );
  }
  
  Widget _buildStyleOption(String title, String subtitle, IconData icon, String style, String current) {
    final isSelected = style == current;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () async {
        await ref.read(cardStyleProvider.notifier).setCardStyle(style);
        _savePreferencesToCloud();
      },
    );
  }
}
