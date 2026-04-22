# Dao · 道 App

一款以东方哲学为核心的文化类应用，通过极简设计与 AI 解读，帮助用户理解道教思想，并在现代生活中应用。

## 项目概述

Dao · 道 是一款专注于东方哲学，特别是道教思想的文化类应用。应用通过现代语言解释传统思想，提供可阅读、可思考的内容体验，打造"文化 + AI"的轻应用。

## 技术栈

- **框架**: Flutter 3.38.5
- **语言**: Dart 3.10.4
- **支持平台**: iOS、Android、Web

## 功能模块

### 首页
- 今日一言（道德经语录）
- AI 解读功能
- 推荐内容（人物/思想）

### 思想模块
- 概念列表（道、无为、阴阳、五行）
- 详情页（概念解释、现实案例）

### 人物模块
- 人物列表（老子、庄子、列子）
- 详情页（简介、核心思想、著作）

### 派系模块
- 派系列表（全真派、正一道）
- 详情页（简介、核心信息、代表人物）

### 搜索模块
- 全局搜索功能
- 分类筛选（全部、人物、思想、派系）
- 历史记录和热门推荐

## 开始使用

### 环境要求
- Flutter SDK 3.10.4 或更高版本
- Dart SDK 3.10.4 或更高版本

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# iOS/Android
flutter run

# Web
flutter run -d web

# 指定设备
flutter run -d <device_id>
```

### 构建应用
```bash
# iOS
flutter build ios

# Android
flutter build apk

# Web
flutter build web
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── screens/               # 页面屏幕
│   ├── home_screen.dart   # 首页
│   ├── thought_screen.dart # 思想模块
│   ├── figure_screen.dart  # 人物模块
│   ├── sect_screen.dart    # 派系模块
│   └── search_screen.dart  # 搜索模块
├── utils/
│   └── app_theme.dart      # 主题配置
└── models/               # 数据模型（待实现）
```

## 设计规范

### 颜色
- 主色：#0D0D0D
- 强调色：#C6A86E
- 背景：#FFFFFF
- 卡片：#F7F7F7

### 字体
- 标题：22-28px
- 正文：16px
- 辅助：13px

### 卡片样式
- 圆角：16
- 阴影：轻微
- 内边距：16

## 版本规划

### V1
- 首页
- 人物
- 派系
- 搜索
- AI 解读

### V2
- 登录
- 收藏
- 分享

### V3
- 会员系统
- 深度内容

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提交 Issue 或 Pull Request。