# Rainyun App - 构建说明

## 项目信息
- **应用名称**: Rainyun 3rd
- **包名**: com.summer.rainyun3rd
- **版本**: v0.0.1+1

## Java 版本要求

当前系统检测到 Java 24，但 Gradle 8.7 最高支持 Java 23。需要安装并使用 Java 17 或 Java 21。

### 解决方案 1：安装 Java 17（推荐）

```bash
# macOS 使用 Homebrew
brew install openjdk@17

# 设置环境变量
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### 解决方案 2：配置 Gradle 使用特定 Java 版本

在 `~/.gradle/gradle.properties` 中添加：

```properties
org.gradle.java.home=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
```

## 构建步骤

### 1. 确认 Java 版本
```bash
java -version
# 应显示 Java 17 或 Java 21
```

### 2. 获取依赖
```bash
flutter pub get
```

### 3. 生成代码
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. 分析代码
```bash
flutter analyze
```

### 5. 打包 APK
```bash
flutter build apk --release
```

APK 输出路径: `build/app/outputs/flutter-apk/app-release.apk`

## 项目结构

```
lib/
├── core/
│   ├── constants/       # API 常量和应用配置
│   ├── network/         # Dio 客户端配置
│   ├── theme/           # Material 3 主题
│   └── utils/           # 工具函数
├── data/
│   ├── models/          # Freezed 数据模型
│   ├── services/        # API 服务层
│   └── repositories/    # 数据仓库
├── presentation/
│   ├── screens/         # 应用页面
│   │   ├── servers/     # 服务器列表页
│   │   ├── products/    # 产品中心页
│   │   └── profile/     # 我的页面
│   ├── widgets/         # 可复用组件
│   └── providers/       # Riverpod 状态管理
└── main.dart            # 应用入口

```

## 功能特性

### 已实现
- ✅ Material 3 设计
- ✅ 底部导航栏（服务器、查看产品、我的）
- ✅ 去除水波特效和触底特效
- ✅ 无 AppBar 设计
- ✅ 自定义刷新按钮
- ✅ 服务器卡片展示
- ✅ 产品分类和一键下单
- ✅ 用户信息管理
- ✅ Hive 本地缓存
- ✅ Riverpod 状态管理

### 待集成
- ⏳ Supabase 认证（需要配置 Supabase 项目）
- ⏳ 雨云 API 真实数据对接
- ⏳ 服务器监控图表（fl_chart）
- ⏳ 服务器操作（开机/关机/重启/续期）

## 注意事项

1. **API Key 安全**: API Key 应存储在 Supabase，不要硬编码
2. **缓存策略**: 使用 Hive 缓存服务器列表，减少 API 调用
3. **错误处理**: 需要添加网络错误和 API 错误处理
4. **日志记录**: 已集成 Logger，可用于调试

## 下一步开发

1. 配置 Supabase 项目并更新连接信息
2. 实现真实的雨云 API 调用
3. 添加服务器详情页面
4. 实现监控数据可视化
5. 添加服务器操作功能
6. 完善错误处理和用户提示
7. 添加加载状态和骨架屏
8. 实现下拉刷新和上拉加载

## 常见问题

### Gradle 构建失败
- 检查 Java 版本是否为 17 或 21
- 清理 Gradle 缓存: `rm -rf ~/.gradle/caches/`
- 更新 Gradle 版本（已配置为 8.7）

### 依赖冲突
- 运行 `flutter pub get`
- 运行 `flutter clean`
- 重新构建项目

### 代码生成问题
- 确保 freezed 和 json_serializable 版本兼容
- 运行 `dart run build_runner clean`
- 重新运行 `dart run build_runner build --delete-conflicting-outputs`
