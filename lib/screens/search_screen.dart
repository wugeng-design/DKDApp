import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0;

  final List<String> _history = ['老子', '道', '无为', '全真派'];
  final List<String> _hotKeywords = ['庄子', '阴阳', '五行', '正一道'];

  final List<Map<String, dynamic>> _searchResults = [
    {
      'type': '人物',
      'name': '老子',
      'description': '道家学派创始人'
    },
    {
      'type': '思想',
      'name': '道',
      'description': '宇宙万物的本原'
    },
    {
      'type': '派系',
      'name': '全真派',
      'description': '主张清修的道教派别'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '搜索人物、思想、派系',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // 搜索结果或历史/热门
            if (_searchQuery.isEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 历史记录
                    const Text('历史记录', style: AppTheme.subtitleStyle),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _history.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = item;
                            setState(() {
                              _searchQuery = item;
                            });
                          },
                          child: Chip(
                            label: Text(item),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24.0),

                    // 热门推荐
                    const Text('热门推荐', style: AppTheme.subtitleStyle),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _hotKeywords.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = item;
                            setState(() {
                              _searchQuery = item;
                            });
                          },
                          child: Chip(
                            label: Text(item),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // 分类标签
                    Row(
                      children: [
                        _buildTab(0, '全部'),
                        _buildTab(1, '人物'),
                        _buildTab(2, '思想'),
                        _buildTab(3, '派系'),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 搜索结果
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          if (_activeTab == 0 ||
                              (_activeTab == 1 && result['type'] == '人物') ||
                              (_activeTab == 2 && result['type'] == '思想') ||
                              (_activeTab == 3 && result['type'] == '派系')) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.cardPadding),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        result['type'],
                                        style: TextStyle(
                                          color: AppTheme.accentColor,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(result['name'], style: AppTheme.subtitleStyle),
                                          Text(result['description'], style: AppTheme.captionStyle),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: _activeTab == index ? AppTheme.accentColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _activeTab == index ? AppTheme.backgroundColor : AppTheme.textColor,
            fontWeight: _activeTab == index ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}