import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class RainyunApiService {
  late final Dio _dio;
  String? _apiKey;

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
        if (_apiKey != null) {
          options.headers['x-api-key'] = _apiKey;
        }
        debugPrint('🌐 API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ API Error: ${error.message}');
        return handler.next(error);
      },
    ));

    _loadApiKey();
  }

  void _loadApiKey() {
    try {
      final box = Hive.box(AppConstants.apiKeyBox);
      _apiKey = box.get('rainyun_api_key');
      debugPrint('🔑 API Key loaded: ${_apiKey != null ? "Yes" : "No"}');
    } catch (e) {
      debugPrint('❌ Failed to load API Key: $e');
    }
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final box = Hive.box(AppConstants.apiKeyBox);
    await box.put('rainyun_api_key', apiKey);
    debugPrint('🔑 API Key saved');
  }

  String? getApiKey() => _apiKey;

  bool hasApiKey() => _apiKey != null && _apiKey!.isNotEmpty;

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

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get(ApiConstants.userInfo);
      return response.data;
    } catch (e) {
      debugPrint('❌ getUserInfo error: $e');
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

}
