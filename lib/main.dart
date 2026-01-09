import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'core/services/widget_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/widgets/debug_panel.dart';
import 'presentation/screens/settings/personalization_screen.dart';
import 'presentation/screens/settings/api_keys_screen.dart';
import 'presentation/screens/settings/widget_settings_screen.dart';

/// 全局导航Key，用于从任何地方进行导航
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// MethodChannel用于接收小组件点击事件
const _widgetChannel = MethodChannel('com.rainyun.widget/navigation');

/// 后台任务回调
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 初始化必要的服务
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      await Hive.openBox(AppConstants.apiKeyBox);
      
      // 更新小组件
      final widgetService = WidgetService();
      await widgetService.updateWidget();
      return true;
    } catch (e) {
      debugPrint('后台任务执行失败: $e');
      return false;
    }
  });
}

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Supabase initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    try {
      await Hive.initFlutter();
      await Hive.openBox(AppConstants.hiveBoxName);
      await Hive.openBox(AppConstants.apiKeyBox);
      await Hive.openBox(AppConstants.userDataBox);
      await Hive.openBox(AppConstants.serverCacheBox);
      debugPrint('✅ Hive initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Hive initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    // 初始化WorkManager用于后台更新小组件
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      // 注册定期任务，每15分钟更新一次小组件
      await Workmanager().registerPeriodicTask(
        'widget_update_task',
        'widgetBackgroundUpdate',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      debugPrint('✅ WorkManager initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ WorkManager initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(
      const ProviderScope(
        child: RainyunApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class RainyunApp extends ConsumerStatefulWidget {
  const RainyunApp({super.key});

  @override
  ConsumerState<RainyunApp> createState() => _RainyunAppState();
}

class _RainyunAppState extends ConsumerState<RainyunApp> {
  @override
  void initState() {
    super.initState();
    _setupWidgetChannel();
  }
  
  /// 设置小组件导航通道
  void _setupWidgetChannel() {
    _widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'navigateToWidgetSettings') {
        final args = call.arguments as Map?;
        final widgetId = args?['widgetId'] as int?;
        
        // 延迟导航，确保应用已完全启动
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => WidgetSettingsScreen(widgetId: widgetId),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        // 用DebugPanel包装整个应用，使调试面板可以显示在任何页面之上
        return DebugPanel(child: child ?? const SizedBox.shrink());
      },
      routes: {
        '/personalization': (context) => const PersonalizationScreen(),
        '/api_keys': (context) => const ApiKeysScreen(),
        '/widget_settings': (context) => const WidgetSettingsScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
