# DKDApp 数据同步策略

## 一、数据架构概述

### 1.1 数据分层

本应用采用**双层数据存储架构**，结合服务端云数据库和客户端本地数据库：

| 层级 | 存储位置 | 技术方案 | 数据特点 |
|------|----------|----------|----------|
| **服务端** | MongoDB | NestJS + Mongoose | 权威数据源，支持复杂查询 |
| **客户端** | SQLite | sqflite | 离线缓存，快速访问 |
| **Web端** | Memory | In-Memory Map | 临时缓存，会话级 |

### 1.2 数据流向

```
服务端API ──→ 客户端API层 ──→ 本地数据库缓存
     ↑                              │
     └──────── 数据同步 ←───────────┘
```

---

## 二、同步策略

### 2.1 核心原则

1. **优先使用API数据**：有网络时优先从服务端获取最新数据
2. **本地缓存降级**：网络不可用时使用本地缓存数据
3. **增量更新**：仅同步变更数据，减少流量消耗
4. **数据一致性**：保证本地数据与服务端最终一致

### 2.2 同步时机

| 场景 | 同步策略 | 触发条件 |
|------|----------|----------|
| **应用启动** | 全量同步 | 每次冷启动 |
| **页面访问** | 增量同步 | 进入人物/派系页面 |
| **后台定时** | 增量同步 | 每30分钟 |
| **手动刷新** | 强制同步 | 用户下拉刷新 |

### 2.3 同步流程

```
┌─────────────────────────────────────────────────────────────┐
│                    数据同步流程                              │
├─────────────────────────────────────────────────────────────┤
│  1. 检查网络连接                                             │
│       │                                                     │
│       ├── 有网络 ──→ 调用API获取数据                         │
│       │       │                                             │
│       │       ├── 成功 ──→ 更新UI + 同步到本地数据库          │
│       │       │                                             │
│       │       └── 失败 ──→ 使用本地缓存数据                   │
│       │                                                     │
│       └── 无网络 ──→ 直接使用本地缓存数据                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 三、服务端接口设计

### 3.1 人物接口 (Figure)

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 列表 | GET | `/figures` | 支持关键词搜索 |
| 详情 | GET | `/figures/:id` | 按ID查询 |
| 详情 | GET | `/figures/name/:name` | 按名称查询 |
| 创建 | POST | `/figures` | 新增人物 |
| 更新 | PATCH | `/figures/:id` | 更新人物 |
| 删除 | DELETE | `/figures/:id` | 软删除人物 |

### 3.2 派系接口 (Sect)

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 列表 | GET | `/sects` | 支持关键词/朝代筛选 |
| 详情 | GET | `/sects/:id` | 按ID查询 |
| 详情 | GET | `/sects/name/:name` | 按名称查询 |
| 创建 | POST | `/sects` | 新增派系 |
| 更新 | PATCH | `/sects/:id` | 更新派系 |
| 删除 | DELETE | `/sects/:id` | 软删除派系 |

### 3.3 响应格式

```json
{
  "success": true,
  "data": [],
  "message": "操作成功"
}
```

---

## 四、客户端数据管理

### 4.1 API服务层

创建统一的 `ApiService` 类，封装所有HTTP请求：

- **配置管理**：统一管理基础URL和请求头
- **错误处理**：统一的异常捕获和重试机制
- **数据转换**：统一的响应格式解析

### 4.2 数据库服务层

`DatabaseService` 提供本地数据持久化：

- **表结构**：figures、figure_thoughts、figure_works、sects、sect_info、sect_representatives
- **操作方法**：增删改查 + 批量操作
- **Web兼容**：内存存储模拟实现

### 4.3 数据同步逻辑

#### 4.3.1 人物数据同步

```dart
Future<void> _syncToLocal(List<Map<String, dynamic>> apiFigures) async {
  for (var figure in apiFigures) {
    await DatabaseService().saveFigureWithDetails(
      figure['name'],
      figure['bio'] ?? '',
      List<String>.from(figure['coreThoughts'] ?? []),
      List<String>.from(figure['works'] ?? []),
    );
  }
}
```

#### 4.3.2 派系数据同步

```dart
Future<void> _syncToLocal(List<Map<String, dynamic>> apiSects) async {
  for (var sect in apiSects) {
    await DatabaseService().saveSect(
      sect['name'],
      sect['dynasty'] ?? '',
      sect['practice'] ?? '',
      sect['description'] ?? '',
      List<Map<String, String>>.from(sect['info'] ?? []),
      List<String>.from(sect['representatives'] ?? []),
    );
  }
}
```

---

## 五、缓存策略

### 5.1 缓存类型

| 缓存层 | 存储位置 | 有效期 | 用途 |
|--------|----------|--------|------|
| **内存缓存** | RAM | 会话级 | 当前页面数据 |
| **本地数据库** | SQLite | 持久化 | 离线数据 |
| **HTTP缓存** | 客户端 | 5分钟 | API响应缓存 |

### 5.2 缓存失效策略

1. **时间失效**：超过30分钟强制刷新
2. **版本比对**：通过ETag或版本号判断更新
3. **事件驱动**：服务端推送更新通知（后续扩展）

---

## 六、错误处理与降级

### 6.1 网络异常处理

```dart
try {
  // 尝试从API获取数据
  List<Map<String, dynamic>>? apiFigures = await ApiService.fetchFigures();
  
  if (apiFigures != null && apiFigures.isNotEmpty) {
    figures = apiFigures;
    await _syncToLocal(apiFigures);
  } else {
    throw Exception('API返回数据为空');
  }
} catch (e) {
  // 降级到本地数据
  print('从API加载失败，使用本地数据: $e');
  figures = await DatabaseService().getAllFigures();
}
```

### 6.2 数据完整性检查

- **必填字段校验**：name、description、bio等核心字段
- **数据格式校验**：列表类型、日期格式等
- **默认值填充**：缺失字段使用合理默认值

---

## 七、性能优化

### 7.1 请求优化

- **批量请求**：合并多个API请求
- **分页加载**：支持分页参数，避免一次性加载大量数据
- **请求缓存**：相同请求短时间内返回缓存结果

### 7.2 数据压缩

- **JSON压缩**：服务端启用Gzip压缩
- **字段筛选**：按需请求字段，减少数据传输量

### 7.3 异步处理

- **后台同步**：数据同步放在后台线程执行
- **懒加载**：仅加载当前视图需要的数据

---

## 八、安全考虑

### 8.1 数据传输安全

- **HTTPS加密**：生产环境强制HTTPS
- **请求签名**：敏感操作添加签名验证

### 8.2 数据存储安全

- **本地加密**：敏感数据本地存储加密
- **权限控制**：服务端接口添加认证校验

---

## 九、扩展规划

### 9.1 短期目标

1. ~~完成基础CRUD接口~~ ✓
2. ~~实现客户端API服务~~ ✓
3. ~~实现本地数据库缓存~~ ✓
4. ~~实现基础数据同步逻辑~~ ✓

### 9.2 中期目标

1. 实现增量同步（基于时间戳）
2. 添加数据版本管理
3. 实现服务端推送更新（WebSocket）
4. 添加数据变更日志

### 9.3 长期目标

1. 实现多端数据同步（手机/平板/Web）
2. 添加数据冲突解决机制
3. 实现离线模式完整支持
4. 添加数据备份与恢复功能

---

## 附录：数据模型

### Figure（人物）

| 字段 | 类型 | 说明 |
|------|------|------|
| name | String | 人物名称（唯一） |
| era | String | 所处朝代 |
| eraOrder | Number | 朝代排序号 |
| description | String | 简介 |
| bio | String | 详细传记 |
| coreThoughts | Array | 核心思想列表 |
| works | Array | 著作列表 |
| isActive | Boolean | 是否启用 |

### Sect（派系）

| 字段 | 类型 | 说明 |
|------|------|------|
| name | String | 派系名称（唯一） |
| dynasty | String | 所处朝代 |
| practice | String | 修行方式 |
| description | String | 简介 |
| info | Array | 核心信息（键值对） |
| representatives | Array | 代表人物列表 |
| isActive | Boolean | 是否启用 |