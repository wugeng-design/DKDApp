import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/services/database_service.dart';
import 'package:dao_app/services/api_service.dart';

class FigureDetailScreen extends StatefulWidget {
  final String figureName;

  const FigureDetailScreen({super.key, required this.figureName});

  @override
  State<FigureDetailScreen> createState() => _FigureDetailScreenState();
}

class _FigureDetailScreenState extends State<FigureDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _figure;

  @override
  void initState() {
    super.initState();
    _loadFigureDetail();
  }

  Future<void> _loadFigureDetail() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? figure;

    try {
      figure = await ApiService.fetchFigureByName(widget.figureName);
    } catch (e) {
      print('从API获取人物详情失败: $e');
    }

    if (figure == null) {
      try {
        figure = await DatabaseService().getFigureByName(widget.figureName);
      } catch (e) {
        print('从本地数据库获取人物详情失败: $e');
      }
    }

    if (figure == null) {
      figure = {
        'name': widget.figureName,
        'era': '',
        'bio': '未找到该人物信息',
        'coreThoughts': [],
        'works': [],
      };
    }

    setState(() {
      _figure = figure;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人物详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _figure == null
              ? const Center(child: Text('加载失败'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_figure!['name'], style: AppTheme.titleStyle),
                      const SizedBox(height: 8.0),
                      Text(_figure!['era'] ?? '', style: AppTheme.captionStyle),
                      const SizedBox(height: 16.0),
                      Text('简介', style: AppTheme.subtitleStyle),
                      const SizedBox(height: 8.0),
                      Text(_figure!['bio'] ?? '', style: AppTheme.bodyStyle),
                      const SizedBox(height: 16.0),
                      if (_figure!['coreThoughts'] != null &&
                          (_figure!['coreThoughts'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('核心思想', style: AppTheme.subtitleStyle),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              children: (_figure!['coreThoughts'] as List).map<Widget>((thought) {
                                return Chip(
                                  label: Text(thought),
                                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                  labelStyle: TextStyle(color: AppTheme.accentColor),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      if (_figure!['works'] != null &&
                          (_figure!['works'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('著作', style: AppTheme.subtitleStyle),
                            const SizedBox(height: 8.0),
                            ...(_figure!['works'] as List).map<Widget>((work) {
                              return Text('• $work', style: AppTheme.bodyStyle);
                            }).toList(),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
