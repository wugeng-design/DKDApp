import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0;
  bool _isLoading = false;
  SearchResult? _searchResult;
  String? _errorMessage;

  final List<String> _history = ['老子', '道', '无为', '全真派'];
  final List<String> _hotKeywords = ['庄子', '阴阳', '五行', '正一道'];

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResult = null;
    });

    final result = await SearchService.search(query);

    setState(() {
      _isLoading = false;
      _searchResult = result;
      if (!result.isComplete && result.errorMessage == null) {
        _errorMessage = '搜索结果可能不完整，请注意鉴别';
      }
    });
  }

  void _showResultDetail(SearchResult result) {
    if (result.type == SearchResultType.unknown || !result.isComplete) {
      _showIncompleteDetail(result);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (result.type == SearchResultType.figure) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.name, style: AppTheme.titleStyle),
                Text(result.details['era'] ?? '', style: AppTheme.captionStyle),
                const SizedBox(height: 16.0),
                Text('简介', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Text(result.details['bio'] ?? '', style: AppTheme.bodyStyle),
                const SizedBox(height: 16.0),
                Text('核心思想', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  children: (result.details['coreThoughts'] as List?)
                      ?.map<Widget>((thought) {
                    return Chip(
                      label: Text(thought),
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppTheme.accentColor),
                    );
                  }).toList() ?? [],
                ),
                const SizedBox(height: 16.0),
                Text('著作', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                ...(result.details['works'] as List?)
                    ?.map<Widget>((work) {
                  return Text('• $work', style: AppTheme.bodyStyle);
                }).toList() ?? [],
                if (!_searchResult!.isComplete) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'AI生成内容，建议结合其他资料核实',
                            style: AppTheme.captionStyle.copyWith(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32.0),
              ],
            ),
          );
        } else if (result.type == SearchResultType.thought) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.name, style: AppTheme.titleStyle),
                const SizedBox(height: 16.0),
                Text('概念解释', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Text(result.details['content'] ?? '', style: AppTheme.bodyStyle),
                const SizedBox(height: 16.0),
                Text('现实案例', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Text(result.details['example'] ?? '', style: AppTheme.bodyStyle),
                if (!_searchResult!.isComplete) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'AI生成内容，建议结合其他资料核实',
                            style: AppTheme.captionStyle.copyWith(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32.0),
              ],
            ),
          );
        } else if (result.type == SearchResultType.sect) {
          final info = result.details['info'] as Map<String, dynamic>? ?? {};
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.name, style: AppTheme.titleStyle),
                Text('修行：${result.details['practice'] ?? ''}', style: AppTheme.captionStyle),
                const SizedBox(height: 16.0),
                Text('简介', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Text(result.details['description'] ?? result.description, style: AppTheme.bodyStyle),
                const SizedBox(height: 16.0),
                Text('核心信息', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                ...info.entries.map<Widget>((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key}: ', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                        Expanded(child: Text(entry.value.toString(), style: AppTheme.bodyStyle)),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16.0),
                Text('代表人物', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  children: (result.details['representatives'] as List?)
                      ?.map<Widget>((rep) {
                    return Chip(
                      label: Text(rep),
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppTheme.accentColor),
                    );
                  }).toList() ?? [],
                ),
                if (!_searchResult!.isComplete) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'AI生成内容，建议结合其他资料核实',
                            style: AppTheme.captionStyle.copyWith(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32.0),
              ],
            ),
          );
        } else {
          return _buildUnknownDetail(result);
        }
      },
    );
  }

  void _showIncompleteDetail(SearchResult result) {
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
              Row(
                children: [
                  Icon(Icons.search, color: AppTheme.accentColor),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '关于 "${result.name}" 的搜索结果',
                      style: AppTheme.titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8.0),
                        Text(
                          '温馨提示',
                          style: AppTheme.subtitleStyle.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'AI搜索返回的信息可能不完整或不准确。'
                      '以下内容仅供参考，建议通过其他渠道核实相关信息。',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Text('搜索内容', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              if (result.details.isNotEmpty && result.details['content'] != null)
                Text(result.details['content'], style: AppTheme.bodyStyle)
              else
                Text(result.description, style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        '您可以尝试搜索更具体的关键词，如 "老子"、"道家思想" 等',
                        style: AppTheme.captionStyle.copyWith(color: Colors.amber.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnknownDetail(SearchResult result) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppTheme.accentColor),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  '关于 "${result.name}" ',
                  style: AppTheme.titleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 8.0),
                    Text(
                      '未找到匹配的类型',
                      style: AppTheme.subtitleStyle.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  result.description.isNotEmpty
                      ? result.description
                      : '抱歉，未能找到与 "${result.name}" 相关的人物、思想或派系信息。',
                  style: AppTheme.bodyStyle,
                ),
              ],
            ),
          ),
          if (result.details.isNotEmpty && result.details['content'] != null) ...[
            const SizedBox(height: 16.0),
            Text('相关信息', style: AppTheme.subtitleStyle),
            const SizedBox(height: 8.0),
            Text(result.details['content'], style: AppTheme.bodyStyle),
          ],
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    '建议：尝试搜索更具体的内容，如 "老子"、"无为而治"、"全真派" 等',
                    style: AppTheme.captionStyle.copyWith(color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

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
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _performSearch(value);
                }
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
                            _searchResult = null;
                            _errorMessage = null;
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

            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '正在搜索...',
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchResult != null)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildTab(0, '全部'),
                        _buildTab(1, '人物'),
                        _buildTab(2, '思想'),
                        _buildTab(3, '派系'),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTheme.captionStyle.copyWith(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _buildSearchResultCard(),
                    ),
                  ],
                ),
              )
            else if (_searchQuery.isEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            _performSearch(item);
                          },
                          child: Chip(
                            label: Text(item),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24.0),
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
                            _performSearch(item);
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '输入关键词开始搜索',
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard() {
    final result = _searchResult!;

    bool shouldShow = _activeTab == 0 ||
        (_activeTab == 1 && result.type == SearchResultType.figure) ||
        (_activeTab == 2 && result.type == SearchResultType.thought) ||
        (_activeTab == 3 && result.type == SearchResultType.sect);

    if (!shouldShow) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              '当前分类下没有搜索结果',
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
      );
    }

    String typeLabel = '';
    switch (result.type) {
      case SearchResultType.figure:
        typeLabel = '人物';
        break;
      case SearchResultType.thought:
        typeLabel = '思想';
        break;
      case SearchResultType.sect:
        typeLabel = '派系';
        break;
      case SearchResultType.unknown:
        typeLabel = '未知';
        break;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: InkWell(
              onTap: () => _showResultDetail(result),
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
                        typeLabel,
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
                          Text(result.name, style: AppTheme.subtitleStyle),
                          Text(result.description, style: AppTheme.captionStyle),
                        ],
                      ),
                    ),
                    if (!result.isComplete)
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8.0),
                    const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
                  ],
                ),
              ),
            ),
          ),
          if (!result.isComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '点击查看详情，AI生成内容仅供参考',
                      style: AppTheme.captionStyle.copyWith(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}