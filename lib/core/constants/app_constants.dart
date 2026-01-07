class AppConstants {
  static const String appName = 'RainyunApp';
  static const String appVersion = '0.0.1';
  
  static const String hiveBoxName = 'rainyun_cache';
  static const String apiKeyBox = 'api_key_box';
  static const String userDataBox = 'user_data_box';
  static const String serverCacheBox = 'server_cache_box';
  
  static const String keyApiKey = 'rainyun_api_key';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  
  static const int cacheExpireDuration = 300;
  static const int monitorRefreshInterval = 30;
  
  static const List<String> serverTypes = [
    'RCS',
    'RGS', 
    'RBM',
    'RVH',
    'RCA',
    'ROS',
    'RCDN',
  ];
  
  static const Map<String, String> serverTypeNames = {
    'RCS': '云服务器',
    'RGS': '游戏云',
    'RBM': '裸金属',
    'RVH': '虚拟主机',
    'RCA': '云应用',
    'ROS': '对象存储',
    'RCDN': 'CDN加速',
  };
  
  static const Map<String, String> categoryNames = {
    'servers': '我的服务器',
    'products': '产品中心',
    'domains': '域名管理',
    'ssl': 'SSL证书',
    'workorder': '工单管理',
    'expense': '费用管理',
    'profile': '我的',
  };
  
  static const List<String> productCategories = [
    '云服务器',
    '游戏云',
    '裸金属',
    '虚拟主机',
    '云应用',
    '对象存储',
    'CDN加速',
    '域名注册',
    'SSL证书',
  ];
}
