import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AiModel {
  final String id;
  final String name;
  final String apiUrl;
  final String defaultModel;
  final String description;

  AiModel({
    required this.id,
    required this.name,
    required this.apiUrl,
    required this.defaultModel,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'apiUrl': apiUrl,
      'defaultModel': defaultModel,
      'description': description,
    };
  }

  static AiModel fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'],
      name: json['name'],
      apiUrl: json['apiUrl'],
      defaultModel: json['defaultModel'],
      description: json['description'],
    );
  }
}

class AiModelConfig {
  final String modelId;
  final String appKey;
  final String? customModel;

  AiModelConfig({
    required this.modelId,
    required this.appKey,
    this.customModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'appKey': appKey,
      'customModel': customModel,
    };
  }

  static AiModelConfig fromJson(Map<String, dynamic> json) {
    return AiModelConfig(
      modelId: json['modelId'],
      appKey: json['appKey'],
      customModel: json['customModel'],
    );
  }
}

class AiModelConfigService {
  static const String _configKey = 'ai_model_config';

  static List<AiModel> supportedModels = [
    AiModel(
      id: 'zhipu',
      name: '智谱AI',
      apiUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
      defaultModel: 'glm-4.7-flash',
      description: '智谱AI提供的大模型服务，支持多种模型',
    ),
    AiModel(
      id: 'openai',
      name: 'OpenAI',
      apiUrl: 'https://api.openai.com/v1/chat/completions',
      defaultModel: 'gpt-3.5-turbo',
      description: 'OpenAI提供的GPT系列大模型',
    ),
    AiModel(
      id: 'baidu',
      name: '百度文心一言',
      apiUrl: 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions',
      defaultModel: 'completions',
      description: '百度文心一言大模型服务',
    ),
    AiModel(
      id: 'alibaba',
      name: '阿里通义千问',
      apiUrl: 'https://dashscope.aliyuncs.com/api/text/chat',
      defaultModel: 'qwen-turbo',
      description: '阿里巴巴通义千问大模型服务',
    ),
    AiModel(
      id: 'tencent',
      name: '腾讯混元',
      apiUrl: 'https://api.tencentai.tencentcs.com/api/text/chat',
      defaultModel: 'hunyuan',
      description: '腾讯混元大模型服务',
    ),
  ];

  static AiModel getModelById(String modelId) {
    return supportedModels.firstWhere(
      (model) => model.id == modelId,
      orElse: () => supportedModels[0],
    );
  }

  static Future<AiModelConfig?> getConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configKey);
      if (configString != null) {
        final configJson = json.decode(configString);
        return AiModelConfig.fromJson(configJson);
      }
      return null;
    } catch (e) {
      print('获取AI模型配置失败: $e');
      return null;
    }
  }

  static Future<void> saveConfig(AiModelConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, json.encode(config.toJson()));
    } catch (e) {
      print('保存AI模型配置失败: $e');
    }
  }

  static Future<void> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
    } catch (e) {
      print('清除AI模型配置失败: $e');
    }
  }

  static Future<bool> hasConfig() async {
    final config = await getConfig();
    return config != null && config.appKey.isNotEmpty;
  }
}