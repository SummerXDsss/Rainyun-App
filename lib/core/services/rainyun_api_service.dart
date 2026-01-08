import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/debug_log_manager.dart';
import 'auth_service.dart';

class RainyunApiService {
  late final Dio _dio;
  String? _apiKey;
  final AuthService _authService = AuthService();
  final DebugLogManager _debugLog = DebugLogManager();

  RainyunApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final startTime = DateTime.now().millisecondsSinceEpoch;
        options.extra['startTime'] = startTime;
        
        if (_apiKey != null) {
          options.headers['x-api-key'] = _apiKey;
          developer.log('🔑 已添加 API Key 到请求头', name: 'RainyunAPI');
        } else {
          developer.log('⚠️ 警告：API Key 为空！', name: 'RainyunAPI');
        }
        developer.log('🌐 API Request: ${options.method} ${options.uri}', name: 'RainyunAPI');
        
        // 记录到调试面板
        _debugLog.logRequest(
          method: options.method,
          url: options.uri.toString(),
          headers: Map<String, dynamic>.from(options.headers),
          body: options.data,
        );
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['startTime'] as int?;
        final duration = startTime != null 
            ? DateTime.now().millisecondsSinceEpoch - startTime 
            : null;
        
        developer.log('✅ API Response: ${response.statusCode}', name: 'RainyunAPI');
        
        // 记录到调试面板
        _debugLog.logResponse(
          method: response.requestOptions.method,
          url: response.requestOptions.uri.toString(),
          statusCode: response.statusCode ?? 0,
          data: response.data,
          durationMs: duration,
        );
        
        return handler.next(response);
      },
      onError: (error, handler) {
        developer.log('❌ API Error: ${error.message}', name: 'RainyunAPI');
        
        // 记录错误到调试面板
        _debugLog.logError(
          title: 'API请求失败: ${error.requestOptions.uri.path}',
          error: error.message ?? '未知错误',
          stackTrace: error.response?.data?.toString(),
        );
        
        return handler.next(error);
      },
    ));

    _loadApiKey();
  }

  void _loadApiKey() {
    try {
      final box = Hive.box(AppConstants.apiKeyBox);
      _apiKey = box.get('rainyun_api_key') as String?;
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        debugPrint('🔑 API Key loaded: ${_apiKey!.substring(0, 8)}...');
      } else {
        debugPrint('⚠️ No API Key found');
      }
    } catch (e) {
      debugPrint('❌ Failed to load API Key: $e');
    }
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final box = Hive.box(AppConstants.apiKeyBox);
    await box.put('rainyun_api_key', apiKey);
    debugPrint('🔑 API Key saved to Hive');
    
    if (_authService.isLoggedIn) {
      try {
        await _authService.updateUserProfile(rainyunApiKey: apiKey);
        debugPrint('🔑 API Key synced to Supabase');
      } catch (e) {
        debugPrint('⚠️ Failed to sync API Key to Supabase: $e');
      }
    }
  }

  String? getApiKey() => _apiKey;

  bool hasApiKey() => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> syncApiKeyFromSupabase() async {
    if (!_authService.isLoggedIn) return;
    try {
      final profile = await _authService.getUserProfile();
      if (profile?.rainyunApiKey != null && profile!.rainyunApiKey!.isNotEmpty) {
        final box = Hive.box(AppConstants.apiKeyBox);
        await box.put('rainyun_api_key', profile.rainyunApiKey);
        _apiKey = profile.rainyunApiKey;
        debugPrint('🔄 API Key synced from Supabase');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to sync API Key from Supabase: $e');
    }
  }

  // ========== Product API ==========
  
  /// 获取产品列表（所有服务器）
  Future<Map<String, dynamic>> getProductList() async {
    try {
      final response = await _dio.get(ApiConstants.productSummary);
      return response.data;
    } catch (e) {
      debugPrint('❌ getProductList error: $e');
      rethrow;
    }
  }

  /// 获取产品ID列表
  Future<Map<String, dynamic>> getProductIds() async {
    try {
      final response = await _dio.get(ApiConstants.productIds);
      return response.data;
    } catch (e) {
      debugPrint('❌ getProductIds error: $e');
      rethrow;
    }
  }

  /// 获取可用区域列表
  Future<Map<String, dynamic>> getProductZones() async {
    try {
      final response = await _dio.get(ApiConstants.productZones);
      return response.data;
    } catch (e) {
      debugPrint('❌ getProductZones error: $e');
      rethrow;
    }
  }

  // ========== RCS (Cloud Server) API ==========

  /// 获取RCS服务器列表
  Future<Map<String, dynamic>> getRcsList() async {
    try {
      final response = await _dio.get(ApiConstants.rcsList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsList error: $e');
      rethrow;
    }
  }

  /// 获取RCS服务器详情
  Future<Map<String, dynamic>> getRcsDetail(String productId) async {
    try {
      final response = await _dio.get(
        ApiConstants.rcsDetail,
        queryParameters: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsDetail error: $e');
      rethrow;
    }
  }

  /// RCS开机
  Future<Map<String, dynamic>> rcsStart(String productId) async {
    try {
      final response = await _dio.post(
        ApiConstants.rcsStart,
        data: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rcsStart error: $e');
      rethrow;
    }
  }

  /// RCS关机
  Future<Map<String, dynamic>> rcsStop(String productId) async {
    try {
      final response = await _dio.post(
        ApiConstants.rcsStop,
        data: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rcsStop error: $e');
      rethrow;
    }
  }

  /// RCS重启
  Future<Map<String, dynamic>> rcsRestart(String productId) async {
    try {
      final response = await _dio.post(
        ApiConstants.rcsRestart,
        data: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rcsRestart error: $e');
      rethrow;
    }
  }

  // ========== RGS (Game Server) API ==========

  /// 获取RGS游戏云列表
  Future<Map<String, dynamic>> getRgsList() async {
    try {
      final response = await _dio.get(ApiConstants.rgsList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsList error: $e');
      rethrow;
    }
  }

  /// 获取RGS详情
  Future<Map<String, dynamic>> getRgsDetail(String productId) async {
    try {
      final response = await _dio.get(
        ApiConstants.rgsDetail,
        queryParameters: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsDetail error: $e');
      rethrow;
    }
  }

  // ========== Domain API ==========

  /// 获取域名列表
  Future<Map<String, dynamic>> getDomainList() async {
    try {
      final response = await _dio.get(ApiConstants.domainList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getDomainList error: $e');
      rethrow;
    }
  }

  /// 获取域名详情
  Future<Map<String, dynamic>> getDomainDetail(String productId) async {
    try {
      final response = await _dio.get(
        ApiConstants.domainDetail,
        queryParameters: {'product_id': productId},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getDomainDetail error: $e');
      rethrow;
    }
  }

  // ========== User API ==========

  /// 获取雨云用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      debugPrint('🌐 正在请求用户信息: ${ApiConstants.baseUrl}${ApiConstants.userInfo}');
      debugPrint('🔑 API Key: ${_apiKey != null ? '已设置' : '未设置'}');
      
      final response = await _dio.get(ApiConstants.userInfo);
      
      debugPrint('✅ 用户信息API响应成功: ${response.statusCode}');
      return response.data;
    } catch (e) {
      debugPrint('❌ getUserInfo error: $e');
      if (e.toString().contains('401') || e.toString().contains('403')) {
        debugPrint('⚠️ 认证失败，可能是API Key无效');
      }
      rethrow;
    }
  }

  /// 获取用户消息
  Future<Map<String, dynamic>> getUserMessages() async {
    try {
      final response = await _dio.get(ApiConstants.userMessages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getUserMessages error: $e');
      rethrow;
    }
  }

  // ========== Product Packages API ==========

  /// 获取RCS套餐列表
  Future<Map<String, dynamic>> getRcsPackages() async {
    try {
      final response = await _dio.get(ApiConstants.rcsPackages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsPackages error: $e');
      rethrow;
    }
  }

  /// 获取RCS价格
  Future<Map<String, dynamic>> getRcsPrice({
    required String packageId,
    int? months,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.rcsPrice,
        queryParameters: {
          'package_id': packageId,
          if (months != null) 'months': months,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsPrice error: $e');
      rethrow;
    }
  }

  /// 获取RGS套餐列表
  Future<Map<String, dynamic>> getRgsPackages() async {
    try {
      final response = await _dio.get(ApiConstants.rgsPackages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsPackages error: $e');
      rethrow;
    }
  }

  /// 获取RGS价格
  Future<Map<String, dynamic>> getRgsPrice({
    required String packageId,
    int? months,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.rgsPrice,
        queryParameters: {
          'package_id': packageId,
          if (months != null) 'months': months,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsPrice error: $e');
      rethrow;
    }
  }

  /// 获取RVH套餐列表
  Future<Map<String, dynamic>> getRvhPackages() async {
    try {
      final response = await _dio.get(ApiConstants.rvhPackages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRvhPackages error: $e');
      rethrow;
    }
  }

  /// 获取ROS套餐列表
  Future<Map<String, dynamic>> getRosPackages() async {
    try {
      final response = await _dio.get(ApiConstants.rosPackages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRosPackages error: $e');
      rethrow;
    }
  }

  /// 获取RCDN套餐列表
  Future<Map<String, dynamic>> getRcdnPackages() async {
    try {
      final response = await _dio.get(ApiConstants.rcdnPackages);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcdnPackages error: $e');
      rethrow;
    }
  }

  // ========== RVH (Virtual Host) API ==========

  /// 获取RVH虚拟主机列表
  Future<Map<String, dynamic>> getRvhList() async {
    try {
      final response = await _dio.get(ApiConstants.rvhList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRvhList error: $e');
      rethrow;
    }
  }

  /// 获取RVH详情
  Future<Map<String, dynamic>> getRvhDetail(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rvhList}$productId/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRvhDetail error: $e');
      rethrow;
    }
  }

  // ========== ROS (Object Storage) API ==========

  /// 获取ROS对象存储列表
  Future<Map<String, dynamic>> getRosList() async {
    try {
      final response = await _dio.get(ApiConstants.rosList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRosList error: $e');
      rethrow;
    }
  }

  /// 获取ROS详情
  Future<Map<String, dynamic>> getRosDetail(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rosList}$productId/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRosDetail error: $e');
      rethrow;
    }
  }

  // ========== RCDN (CDN) API ==========

  /// 获取RCDN列表
  Future<Map<String, dynamic>> getRcdnList() async {
    try {
      final response = await _dio.get(ApiConstants.rcdnList);
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcdnList error: $e');
      rethrow;
    }
  }

  /// 获取RCDN详情
  Future<Map<String, dynamic>> getRcdnDetail(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcdnList}$productId/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcdnDetail error: $e');
      rethrow;
    }
  }

  // ========== RGS Power Control ==========

  /// RGS开机
  Future<Map<String, dynamic>> rgsStart(String productId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rgsList}$productId/power',
        data: {'action': 'start'},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rgsStart error: $e');
      rethrow;
    }
  }

  /// RGS关机
  Future<Map<String, dynamic>> rgsStop(String productId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rgsList}$productId/power',
        data: {'action': 'stop'},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rgsStop error: $e');
      rethrow;
    }
  }

  /// RGS重启
  Future<Map<String, dynamic>> rgsRestart(String productId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rgsList}$productId/power',
        data: {'action': 'restart'},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rgsRestart error: $e');
      rethrow;
    }
  }

  // ========== Workorder API ==========

  /// 获取工单列表
  Future<Map<String, dynamic>> getWorkorderList({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        '/workorder/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getWorkorderList error: $e');
      rethrow;
    }
  }

  /// 获取工单详情
  Future<Map<String, dynamic>> getWorkorderDetail(String id) async {
    try {
      final response = await _dio.get('/workorder/$id');
      return response.data;
    } catch (e) {
      debugPrint('❌ getWorkorderDetail error: $e');
      rethrow;
    }
  }

  /// 创建工单
  Future<Map<String, dynamic>> createWorkorder({
    required String title,
    required String content,
    String? productId,
    String? productType,
  }) async {
    try {
      final response = await _dio.post(
        '/workorder/',
        data: {
          'title': title,
          'content': content,
          if (productId != null) 'product_id': productId,
          if (productType != null) 'product_type': productType,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ createWorkorder error: $e');
      rethrow;
    }
  }

  /// 回复工单
  Future<Map<String, dynamic>> replyWorkorder({
    required String id,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/workorder/$id/reply_order',
        data: {'content': content},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ replyWorkorder error: $e');
      rethrow;
    }
  }

  // ========== User Coupons API ==========

  /// 获取优惠券列表
  Future<Map<String, dynamic>> getCouponList() async {
    try {
      final response = await _dio.get('/user/coupons/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getCouponList error: $e');
      rethrow;
    }
  }

  /// 激活优惠券
  Future<Map<String, dynamic>> activateCoupon(String code) async {
    try {
      final response = await _dio.post(
        '/user/coupons/active',
        data: {'code': code},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ activateCoupon error: $e');
      rethrow;
    }
  }

  // ========== User Reward API ==========

  /// 获取积分任务列表
  Future<Map<String, dynamic>> getRewardTasks() async {
    try {
      final response = await _dio.get('/user/reward/tasks');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRewardTasks error: $e');
      rethrow;
    }
  }

  /// 获取可兑换产品列表
  Future<Map<String, dynamic>> getRewardProducts() async {
    try {
      final response = await _dio.get('/user/reward/products');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRewardProducts error: $e');
      rethrow;
    }
  }

  // ========== SSL Certificate API ==========

  /// 获取SSL证书列表
  Future<Map<String, dynamic>> getSslList() async {
    try {
      final response = await _dio.get('/product/sslcenter/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getSslList error: $e');
      rethrow;
    }
  }

  // ========== Monitor API ==========

  /// 获取RCS监控数据
  Future<Map<String, dynamic>> getRcsMonitor(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcsList}$productId/monitor');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsMonitor error: $e');
      rethrow;
    }
  }

  /// 获取RGS监控数据
  Future<Map<String, dynamic>> getRgsMonitor(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rgsList}$productId/monitor');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsMonitor error: $e');
      rethrow;
    }
  }

  // ========== VNC API ==========

  /// 获取RCS VNC连接
  Future<Map<String, dynamic>> getRcsVnc(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcsList}$productId/vnc');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsVnc error: $e');
      rethrow;
    }
  }

  /// 获取RGS VNC连接
  Future<Map<String, dynamic>> getRgsVnc(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rgsList}$productId/vnc');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRgsVnc error: $e');
      rethrow;
    }
  }

  // ========== Reinstall API ==========

  /// 获取RCS系统列表
  Future<Map<String, dynamic>> getRcsOsList(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcsList}$productId/os');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsOsList error: $e');
      rethrow;
    }
  }

  /// RCS重装系统
  Future<Map<String, dynamic>> rcsReinstall({
    required String productId,
    required String osId,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rcsList}$productId/reinstall',
        data: {
          'os_id': osId,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ rcsReinstall error: $e');
      rethrow;
    }
  }

  // ========== Backup API ==========

  /// 获取RCS备份列表
  Future<Map<String, dynamic>> getRcsBackups(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcsList}$productId/backup/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsBackups error: $e');
      rethrow;
    }
  }

  /// 创建RCS备份
  Future<Map<String, dynamic>> createRcsBackup(String productId, {String? name}) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rcsList}$productId/backup/',
        data: {if (name != null) 'name': name},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ createRcsBackup error: $e');
      rethrow;
    }
  }

  // ========== Firewall API ==========

  /// 获取RCS防火墙规则
  Future<Map<String, dynamic>> getRcsFirewall(String productId) async {
    try {
      final response = await _dio.get('${ApiConstants.rcsList}$productId/firewall/');
      return response.data;
    } catch (e) {
      debugPrint('❌ getRcsFirewall error: $e');
      rethrow;
    }
  }

  /// 设置RCS防火墙规则
  Future<Map<String, dynamic>> setRcsFirewallRule({
    required String productId,
    required String action,
    required String protocol,
    required String port,
    String? sourceIp,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rcsList}$productId/firewall/rule',
        data: {
          'action': action,
          'protocol': protocol,
          'port': port,
          if (sourceIp != null) 'source_ip': sourceIp,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ setRcsFirewallRule error: $e');
      rethrow;
    }
  }

  // ========== Renew API ==========

  /// 获取续费价格
  Future<Map<String, dynamic>> getRenewPrice({
    required String productId,
    required String productType,
    int months = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/product/$productType/$productId/renew/',
        queryParameters: {'months': months},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getRenewPrice error: $e');
      rethrow;
    }
  }

  /// 续费产品
  Future<Map<String, dynamic>> renewProduct({
    required String productId,
    required String productType,
    required int months,
  }) async {
    try {
      final response = await _dio.post(
        '/product/$productType/$productId/renew/',
        data: {'months': months},
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ renewProduct error: $e');
      rethrow;
    }
  }

  // ========== Task Log API ==========

  /// 获取任务日志
  Future<Map<String, dynamic>> getTaskLog({
    String? productId,
    String? productType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/product/task_log',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (productId != null) 'product_id': productId,
          if (productType != null) 'product_type': productType,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ getTaskLog error: $e');
      rethrow;
    }
  }

  // ========== Generic API Helper ==========

  /// 通用GET请求
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      debugPrint('❌ GET $path error: $e');
      rethrow;
    }
  }

  /// 通用POST请求
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      debugPrint('❌ POST $path error: $e');
      rethrow;
    }
  }

  /// 通用PATCH请求
  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } catch (e) {
      debugPrint('❌ PATCH $path error: $e');
      rethrow;
    }
  }

  /// 通用DELETE请求
  Future<Map<String, dynamic>> delete(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } catch (e) {
      debugPrint('❌ DELETE $path error: $e');
      rethrow;
    }
  }

  /// 通用PUT请求
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } catch (e) {
      debugPrint('❌ PUT $path error: $e');
      rethrow;
    }
  }
}
