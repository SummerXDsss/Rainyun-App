import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class RainyunApiService {
  final DioClient _dioClient;

  RainyunApiService(this._dioClient);

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dioClient.get(ApiConstants.userInfo);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getServerList() async {
    try {
      final response = await _dioClient.get(ApiConstants.productList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRcsList() async {
    try {
      final response = await _dioClient.get(ApiConstants.rcsList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRgsList() async {
    try {
      final response = await _dioClient.get(ApiConstants.rgsList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRbmList() async {
    try {
      final response = await _dioClient.get(ApiConstants.rbmList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRvhList() async {
    try {
      final response = await _dioClient.get(ApiConstants.rvhList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRosList() async {
    try {
      final response = await _dioClient.get(ApiConstants.rosList);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getServerDetail(String id, String type) async {
    try {
      String endpoint;
      switch (type.toUpperCase()) {
        case 'RCS':
          endpoint = '${ApiConstants.rcsDetail}/$id';
          break;
        case 'RGS':
          endpoint = '${ApiConstants.rgsDetail}/$id';
          break;
        default:
          throw Exception('Unsupported server type: $type');
      }
      final response = await _dioClient.get(endpoint);
      return response.data['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMonitorData(String id, String type) async {
    try {
      final endpoint = ApiConstants.rcsMonitor.replaceAll('{id}', id);
      final response = await _dioClient.get(endpoint);
      return response.data['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> startServer(String id, String type) async {
    try {
      final endpoint = ApiConstants.rcsStart.replaceAll('{id}', id);
      final response = await _dioClient.post(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> stopServer(String id, String type) async {
    try {
      final endpoint = ApiConstants.rcsStop.replaceAll('{id}', id);
      final response = await _dioClient.post(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> restartServer(String id, String type) async {
    try {
      final endpoint = ApiConstants.rcsRestart.replaceAll('{id}', id);
      final response = await _dioClient.post(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> renewServer(String id, String type, int months) async {
    try {
      final endpoint = ApiConstants.rcsRenew.replaceAll('{id}', id);
      final response = await _dioClient.post(
        endpoint,
        data: {'months': months},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getProductPackages(String type) async {
    try {
      String endpoint;
      switch (type.toUpperCase()) {
        case 'RCS':
          endpoint = ApiConstants.rcsPackages;
          break;
        case 'RGS':
          endpoint = ApiConstants.rgsPackages;
          break;
        case 'RVH':
          endpoint = ApiConstants.rvhPackages;
          break;
        case 'ROS':
          endpoint = ApiConstants.rosPackages;
          break;
        default:
          endpoint = ApiConstants.productList;
      }
      final response = await _dioClient.get(endpoint);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dioClient.post(
        '/api/v2/order/create',
        data: orderData,
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateUserName(String name) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.userInfo,
        data: {'name': name},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
