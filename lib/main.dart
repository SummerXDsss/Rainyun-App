import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/widgets/debug_panel.dart';
import 'presentation/screens/settings/personalization_screen.dart';
import 'presentation/screens/settings/api_keys_screen.dart';

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

class RainyunApp extends ConsumerWidget {
  const RainyunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
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
      },
      home: const SplashScreen(),
    );
  }
}
