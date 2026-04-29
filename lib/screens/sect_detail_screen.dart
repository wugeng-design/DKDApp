import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/figure_detail_screen.dart';
import 'package:dao_app/services/database_service.dart';
import 'package:dao_app/services/api_service.dart';

class SectDetailScreen extends StatefulWidget {
  final String sectName;

  const SectDetailScreen({super.key, required this.sectName});

  @override
  State<SectDetailScreen> createState() => _SectDetailScreenState();
}

class _SectDetailScreenState extends State<SectDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _sect;

  @override
  void initState() {
    super.initState();
    _loadSectDetail();
  }

  Future<void> _loadSectDetail() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? sect;

    try {
      sect = await ApiService.fetchSectByName(widget.sectName);
    } catch (e) {
      print('从API获取派系详情失败: $e');
    }

    if (sect == null) {
      try {
        List<Map<String, dynamic>> allSects = await DatabaseService().getAllSects();
        sect = allSects.firstWhere(
          (s) => s['name'] == widget.sectName,
          orElse: () => {},
        );
      } catch (e) {
        print('从本地数据库获取派系详情失败: $e');
      }
    }

    if (sect == null || sect.isEmpty) {
      sect = {
        'name': widget.sectName,
        'dynasty': '',
        'practice': '',
        'description': '未找到该派系信息',
        'info': {},
        'representatives': [],
      };
    }

    setState(() {
      _sect = sect;
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
        title: const Text('派系详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sect == null || _sect!.isEmpty
              ? const Center(child: Text('加载失败'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sect!['name'] ?? '', style: AppTheme.titleStyle),
                      const SizedBox(height: 8.0),
                      Text(
                        '朝代：${_sect!['dynasty'] ?? ''} | 修行：${_sect!['practice'] ?? ''}',
                        style: AppTheme.captionStyle,
                      ),
                      const SizedBox(height: 16.0),
                      Text('简介', style: AppTheme.subtitleStyle),
                      const SizedBox(height: 8.0),
                      Text(_sect!['description'] ?? '', style: AppTheme.bodyStyle),
                      const SizedBox(height: 16.0),
                      if (_sect!['info'] != null && (_sect!['info'] as Map).isNotEmpty) ...[
                        Text('核心信息', style: AppTheme.subtitleStyle),
                        const SizedBox(height: 8.0),
                        ...(_sect!['info'] as Map).entries.map<Widget>((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Expanded(child: Text(entry.value.toString(), style: AppTheme.bodyStyle)),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16.0),
                      ],
                      if (_sect!['representatives'] != null &&
                          (_sect!['representatives'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('代表人物', style: AppTheme.subtitleStyle),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              children: (_sect!['representatives'] as List).map<Widget>((rep) {
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