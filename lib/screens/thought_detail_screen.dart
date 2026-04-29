import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/figure_detail_screen.dart';
import 'package:dao_app/services/database_service.dart';
import 'package:dao_app/services/api_service.dart';

class ThoughtDetailScreen extends StatefulWidget {
  final String conceptName;

  const ThoughtDetailScreen({super.key, required this.conceptName});

  @override
  State<ThoughtDetailScreen> createState() => _ThoughtDetailScreenState();
}

class _ThoughtDetailScreenState extends State<ThoughtDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _concept;

  @override
  void initState() {
    super.initState();
    _loadConceptDetail();
  }

  Future<void> _loadConceptDetail() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? concept;

    try {
      concept = await ApiService.fetchThoughtConceptByName(widget.conceptName);
    } catch (e) {
      print('从API获取思想概念详情失败: $e');
    }

    if (concept == null) {
      try {
        List<Map<String, dynamic>> allConcepts = await DatabaseService().getAllThoughtConcepts();
        concept = allConcepts.firstWhere(
          (c) => c['name'] == widget.conceptName,
          orElse: () => {},
        );
      } catch (e) {
        print('从本地数据库获取思想概念详情失败: $e');
      }
    }

    if (concept == null || concept.isEmpty) {
      concept = {
        'name': widget.conceptName,
        'content': '未找到该思想概念信息',
        'example': '',
        'representatives': [],
      };
    }

    setState(() {
      _concept = concept;
      _isLoading = false;
    });
  }

  void _handleRepresentativeTap(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FigureDetailScreen(figureName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('思想详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _concept == null || _concept!.isEmpty
              ? const Center(child: Text('加载失败'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_concept!['name'] ?? '', style: AppTheme.titleStyle),
                      const SizedBox(height: 16.0),
                      Text('概念解释', style: AppTheme.subtitleStyle),
                      const SizedBox(height: 8.0),
                      Text(_concept!['content'] ?? '', style: AppTheme.bodyStyle),
                      const SizedBox(height: 16.0),
                      Text('现实案例', style: AppTheme.subtitleStyle),
                      const SizedBox(height: 8.0),
                      Text(_concept!['example'] ?? '', style: AppTheme.bodyStyle),
                      const SizedBox(height: 16.0),
                      if (_concept!['representatives'] != null &&
                          (_concept!['representatives'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('代表人物', style: AppTheme.subtitleStyle),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              children: (_concept!['representatives'] as List).map<Widget>((rep) {
                                return InkWell(
                                  onTap: () => _handleRepresentativeTap(rep.toString()),
                                  child: Chip(
                                    label: Text(rep.toString()),
                                    backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                    labelStyle: TextStyle(color: AppTheme.accentColor),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}