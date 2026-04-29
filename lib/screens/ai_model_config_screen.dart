import 'package:flutter/material.dart';
import '../services/ai_model_config_service.dart';
import '../utils/app_theme.dart';

class AiModelConfigScreen extends StatefulWidget {
  const AiModelConfigScreen({super.key});

  @override
  State<AiModelConfigScreen> createState() => _AiModelConfigScreenState();
}

class _AiModelConfigScreenState extends State<AiModelConfigScreen> {
  String? _selectedModelId;
  final TextEditingController _appKeyController = TextEditingController();
  final TextEditingController _customModelController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _appKeyController.dispose();
    _customModelController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final config = await AiModelConfigService.getConfig();
      if (config != null) {
        setState(() {
          _selectedModelId = config.modelId;
          _appKeyController.text = config.appKey;
          _customModelController.text = config.customModel ?? '';
        });
      }
    } catch (e) {
      print('加载配置失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    final appKey = _appKeyController.text.trim();
    if (_selectedModelId == null || appKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择模型并输入AppKey')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final customModel = _customModelController.text.trim();
      final config = AiModelConfig(
        modelId: _selectedModelId!,
        appKey: appKey,
        customModel: customModel.isNotEmpty ? customModel : null,
      );
      await AiModelConfigService.saveConfig(config);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置保存成功')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _clearConfig() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除配置'),
        content: const Text('确定要清除当前配置吗？将使用默认的AI模型服务。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await AiModelConfigService.clearConfig();
              setState(() {
                _selectedModelId = null;
                _appKeyController.clear();
                _customModelController.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配置已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _clearAppKey() {
    _appKeyController.clear();
  }

  void _clearCustomModel() {
    _customModelController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('大模型配置'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '配置说明',
                                style: AppTheme.subtitleStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '配置大模型服务后，首页的AI解读和AI对话功能将使用您配置的模型。如果不配置，将使用默认的测试服务。',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('选择大模型', style: AppTheme.subtitleStyle),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Column(
                      children: AiModelConfigService.supportedModels
                          .map((model) => RadioListTile<String>(
                                title: Text(model.name),
                                subtitle: Text(model.description),
                                value: model.id,
                                groupValue: _selectedModelId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModelId = value;
                                    if (_customModelController.text.isEmpty) {
                                      _customModelController.text = model.defaultModel;
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('AppKey', style: AppTheme.subtitleStyle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _appKeyController,
                    decoration: InputDecoration(
                      hintText: '请输入您的AppKey',
                      hintStyle: AppTheme.captionStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _appKeyController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearAppKey,
                            )
                          : null,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AppKey是您在对应平台注册获取的API密钥，请妥善保管',
                    style: AppTheme.captionStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('自定义模型名称（可选）', style: AppTheme.subtitleStyle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customModelController,
                    decoration: InputDecoration(
                      hintText: '留空则使用默认模型',
                      hintStyle: AppTheme.captionStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _customModelController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearCustomModel,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveConfig,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '保存配置',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _appKeyController.text.isEmpty ? null : _clearConfig,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        ),
                      ),
                      child: const Text(
                        '清除配置',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}