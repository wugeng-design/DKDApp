import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/services/database_service.dart';

class FigureScreen extends StatefulWidget {
  final String? figureName;
  
  const FigureScreen({super.key, this.figureName});

  @override
  State<FigureScreen> createState() => _FigureScreenState();
}

class _FigureScreenState extends State<FigureScreen> {
  late List<Map<String, dynamic>> figures;
  int _currentPage = 0;
  final int _pageSize = 5;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFigures();
  }
  
  Future<void> _loadFigures() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 从数据库加载人物数据
      figures = await DatabaseService().getAllFigures();
    } catch (e) {
      print('加载人物数据失败: $e');
      figures = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      // 如果有figureName参数，直接展示该人物的详情
      if (widget.figureName != null) {
        final figure = figures.firstWhere(
          (fig) => fig['name'] == widget.figureName,
          orElse: () => {
            'name': widget.figureName!,
            'era': '',
            'bio': '正在加载人物信息...',
            'coreThoughts': [],
            'works': []
          }
        );
        _showFigureDetail(figure);
      }
    }
  }

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
              Text(figure['era'], style: AppTheme.captionStyle),
              const SizedBox(height: 16.0),
              Text('简介', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(figure['bio'], style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
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
              Text('著作', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              ...figure['works'].map<Widget>((work) {
                return Text('• $work', style: AppTheme.bodyStyle);
              }).toList(),
              const SizedBox(height: 32.0),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _currentPageFigures {
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, figures.length);
    return figures.sublist(startIndex, endIndex);
  }

  int get _totalPages => (figures.length / _pageSize).ceil();

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人物'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : figures.isEmpty
              ? const Center(
                  child: Text('暂无人物数据'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _currentPageFigures.length,
                        itemBuilder: (context, index) {
                          final figure = _currentPageFigures[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            child: InkWell(
                              onTap: () => _showFigureDetail(figure),
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
                                          figure['name'],
                                          style: AppTheme.subtitleStyle.copyWith(
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(figure['name'], style: AppTheme.subtitleStyle),
                                          Text(figure['era'], style: AppTheme.captionStyle),
                                          const SizedBox(height: 8.0),
                                          Text(figure['description'], style: AppTheme.bodyStyle),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            child: const Text('上一页'),
                          ),
                          const SizedBox(width: 16.0),
                          Text('第 ${_currentPage + 1} / $_totalPages 页'),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                            child: const Text('下一页'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}