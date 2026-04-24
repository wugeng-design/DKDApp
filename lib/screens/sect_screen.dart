import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/utils/ai_service.dart';
import 'package:dao_app/services/database_service.dart';

class SectScreen extends StatefulWidget {
  const SectScreen({super.key});

  @override
  State<SectScreen> createState() => _SectScreenState();
}

class _SectScreenState extends State<SectScreen> {
  // 朝代顺序映射
  final Map<String, int> dynastyOrder = {
    '东汉': 1,
    '魏晋': 2,
    '隋唐': 3,
    '北宋': 4,
    '南宋': 5,
    '元': 6,
    '明': 7,
    '清': 8,
  };

  late List<Map<String, dynamic>> sects;
  int currentPage = 1;
  final int itemsPerPage = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSects();
  }

  // 从数据库加载派系数据
  Future<void> _loadSects() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // 从数据库加载派系数据
      sects = await DatabaseService().getAllSects();
      // 按朝代排序
      _sortSectsByDynasty();
    } catch (e) {
      print('加载派系数据失败: $e');
      sects = [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 按朝代排序派系
  void _sortSectsByDynasty() {
    sects.sort((a, b) {
      int orderA = dynastyOrder[a['dynasty']] ?? 999;
      int orderB = dynastyOrder[b['dynasty']] ?? 999;
      return orderA.compareTo(orderB);
    });
  }

  // 获取当前页的派系数据
  List<Map<String, dynamic>> getCurrentPageSects() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > sects.length) {
      endIndex = sects.length;
    }
    return sects.sublist(startIndex, endIndex);
  }

  // 计算总页数
  int get totalPages {
    return (sects.length / itemsPerPage).ceil();
  }

  // 切换到上一页
  void _prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  // 切换到下一页
  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  // 处理代表人物点击
  void _handleRepresentativeTap(String name) async {
    // 调用大模型API查询人物信息
    Map<String, dynamic> figureInfo = await AIService.getFigureInfo(name);
    
    // 保存人物信息到数据库
    await DatabaseService().saveFigureWithDetails(name, figureInfo['bio'], figureInfo['coreThoughts'], figureInfo['works']);
    
    // 直接显示人物详情
    _showFigureDetail({
      'name': name,
      'era': '',
      'bio': figureInfo['bio'],
      'coreThoughts': figureInfo['coreThoughts'],
      'works': figureInfo['works']
    });
  }

  void _showSectDetail(Map<String, dynamic> sect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sect['name'], style: AppTheme.titleStyle),
              Text('朝代：${sect['dynasty']} | 修行：${sect['practice']}', style: AppTheme.captionStyle),
              const SizedBox(height: 16.0),
              Text('简介', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(sect['description'], style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              Text('核心信息', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              ...sect['info'].entries.map<Widget>((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key}: ', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                      Expanded(child: Text(entry.value, style: AppTheme.bodyStyle)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16.0),
              Text('代表人物', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: sect['representatives'].map<Widget>((rep) {
                  return InkWell(
                    onTap: () => _handleRepresentativeTap(rep),
                    child: Chip(
                      label: Text(rep),
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppTheme.accentColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        );
      },
    );
  }

  // 显示人物详情
  void _showFigureDetail(Map<String, dynamic> figure) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(figure['name'], style: AppTheme.titleStyle),
              Text(figure['era'] ?? '', style: AppTheme.captionStyle),
              const SizedBox(height: 16.0),
              Text('简介', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(figure['bio'] ?? '', style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              if (figure['coreThoughts'] != null && figure['coreThoughts'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('核心思想', style: AppTheme.subtitleStyle),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: figure['coreThoughts'].map<Widget>((thought) {
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
              if (figure['works'] != null && figure['works'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('著作', style: AppTheme.subtitleStyle),
                    const SizedBox(height: 8.0),
                    ...figure['works'].map<Widget>((work) {
                      return Text('• $work', style: AppTheme.bodyStyle);
                    }).toList(),
                    const SizedBox(height: 16.0),
                  ],
                ),
              const SizedBox(height: 32.0),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('派系'),
          centerTitle: true,
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final currentPageSects = getCurrentPageSects();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('派系'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: currentPageSects.length,
              itemBuilder: (context, index) {
                final sect = currentPageSects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: InkWell(
                    onTap: () => _showSectDetail(sect),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.cardPadding),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                sect['name'],
                                style: AppTheme.subtitleStyle.copyWith(
                                  color: AppTheme.accentColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sect['name'], style: AppTheme.subtitleStyle),
                                Text('${sect['dynasty']} | ${sect['practice']}', style: AppTheme.captionStyle),
                                const SizedBox(height: 8.0),
                                Text(sect['description'], style: AppTheme.bodyStyle),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 分页控件
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.textSecondaryColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.chevron_left),
                    disabledColor: AppTheme.textSecondaryColor,
                  ),
                  Text(
                    '$currentPage / $totalPages',
                    style: AppTheme.bodyStyle,
                  ),
                  IconButton(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.chevron_right),
                    disabledColor: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}