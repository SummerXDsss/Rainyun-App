# Supabase 数据库配置

## 📊 数据库结构

### 1. **user_profiles** - 用户配置表
存储用户的雨云 API Key、偏好设置等信息。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| user_id | UUID | 关联 auth.users (外键) |
| rainyun_api_key | TEXT | 雨云 API Key（加密存储） |
| username | TEXT | 用户名 |
| email | TEXT | 邮箱 |
| avatar_url | TEXT | 头像 URL |
| preferences | JSONB | 用户偏好设置 JSON |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

**RLS 策略**：
- ✅ 用户只能查看、更新、插入自己的配置
- ✅ 自动更新 `updated_at` 时间戳

---

### 2. **server_cache** - 服务器缓存表
缓存用户的服务器列表，减少 API 调用。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| user_id | UUID | 关联 auth.users (外键) |
| server_id | TEXT | 服务器 ID |
| server_type | TEXT | 服务器类型 (RCS/RGS/RBM/RVH/RCA/ROS/RCDN) |
| name | TEXT | 服务器名称 |
| region | TEXT | 地区 |
| ip_address | TEXT | IP 地址 |
| status | TEXT | 状态 (运行中/已停止等) |
| specs | JSONB | 配置信息 JSON |
| expire_time | TIMESTAMPTZ | 到期时间 |
| raw_data | JSONB | 原始 API 数据 |
| last_synced_at | TIMESTAMPTZ | 最后同步时间 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

**索引**：
- user_id
- server_type
- status
- expire_time

**RLS 策略**：
- ✅ 用户只能查看、增删改自己的服务器缓存
- ✅ 自动更新 `updated_at` 时间戳
- ✅ 唯一约束：(user_id, server_id, server_type)

---

### 3. **api_logs** - API 调用日志表
记录 API 调用日志，用于调试和监控。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| user_id | UUID | 关联 auth.users (外键) |
| endpoint | TEXT | API 端点 |
| method | TEXT | HTTP 方法 |
| status_code | INTEGER | 响应状态码 |
| request_data | JSONB | 请求数据 |
| response_data | JSONB | 响应数据 |
| error_message | TEXT | 错误信息 |
| duration_ms | INTEGER | 请求耗时（毫秒） |
| created_at | TIMESTAMPTZ | 创建时间 |

**索引**：
- user_id
- endpoint
- status_code
- created_at

**RLS 策略**：
- ✅ 用户只能查看和插入自己的日志
- ✅ 自动清理 30 天前的日志

---

## 🔒 安全配置

### RLS (Row Level Security)
所有表都已启用 RLS，确保：
- ✅ 用户只能访问自己的数据
- ✅ 防止数据泄露
- ✅ 符合数据隐私要求

### 函数安全
所有数据库函数都使用 `SECURITY DEFINER` 和 `SET search_path = public`，防止 SQL 注入攻击。

---

## 🚀 项目配置

### Supabase 项目信息
- **项目 URL**: `https://rdbtrpeeijwkbzmkusiu.supabase.co`
- **Anon Key**: 已配置在 `lib/core/config/supabase_config.dart`
- **Publishable Key**: `sb_publishable_B1TPoIa_O6KEsut0Yz2h4A_O0AC78XE`

### Flutter 集成
配置文件：`lib/core/config/supabase_config.dart`

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://rdbtrpeeijwkbzmkusiu.supabase.co';
  static const String supabaseAnonKey = '...';
  static const String publishableKey = '...';
}
```

---

## 📝 使用示例

### 1. 保存用户 API Key
```dart
final supabase = Supabase.instance.client;
final userId = supabase.auth.currentUser?.id;

await supabase.from('user_profiles').upsert({
  'user_id': userId,
  'rainyun_api_key': 'your_api_key',
  'username': 'username',
  'email': 'email@example.com',
});
```

### 2. 缓存服务器列表
```dart
await supabase.from('server_cache').upsert({
  'user_id': userId,
  'server_id': 'server_123',
  'server_type': 'RCS',
  'name': 'My Server',
  'region': 'cn-hangzhou',
  'ip_address': '1.2.3.4',
  'status': 'running',
  'specs': {
    'cpu': 2,
    'memory': 4096,
    'disk': 40
  },
  'expire_time': '2026-12-31T23:59:59Z',
  'last_synced_at': DateTime.now().toIso8601String(),
});
```

### 3. 获取服务器列表
```dart
final servers = await supabase
    .from('server_cache')
    .select()
    .eq('user_id', userId)
    .order('created_at', ascending: false);
```

### 4. 记录 API 日志
```dart
await supabase.from('api_logs').insert({
  'user_id': userId,
  'endpoint': '/api/v2/rcs/list',
  'method': 'GET',
  'status_code': 200,
  'duration_ms': 156,
});
```

---

## 🔄 数据同步策略

### 推荐实现
1. **首次加载**：从 Supabase 读取缓存
2. **后台同步**：定期调用雨云 API 更新缓存
3. **实时更新**：用户操作后立即同步
4. **离线支持**：结合 Hive 本地缓存

### 缓存更新时机
- 应用启动时
- 用户手动刷新
- 缓存过期（建议 5 分钟）
- 执行操作后（如重启服务器）

---

## ⚠️ 注意事项

1. **API Key 安全**
   - ❌ 不要在客户端明文存储
   - ✅ 使用 Supabase 加密存储
   - ✅ 考虑使用 Edge Functions 代理 API 调用

2. **数据量控制**
   - 定期清理过期的服务器缓存
   - API 日志自动清理 30 天前的数据

3. **性能优化**
   - 使用索引加速查询
   - 批量插入/更新操作
   - 合理设置缓存过期时间

---

## 📚 相关文档

- [Supabase 官方文档](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [雨云 API 文档](https://s.apifox.cn/a4595cc8-44c5-4678-a2a3-eed7738dab03/llms.txt)

---

**创建时间**: 2026-01-06  
**数据库版本**: v1.0  
**安全审计**: ✅ 通过
