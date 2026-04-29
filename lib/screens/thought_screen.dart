import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/services/database_service.dart';
import 'package:dao_app/services/api_service.dart';

class ThoughtScreen extends StatefulWidget {
  const ThoughtScreen({super.key});

  @override
  State<ThoughtScreen> createState() => _ThoughtScreenState();
}

class _ThoughtScreenState extends State<ThoughtScreen> {
  late List<Map<String, dynamic>> concepts;
  int currentPage = 1;
  final int itemsPerPage = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConcepts();
  }

  Future<void> _loadConcepts() async {
    setState(() {
      isLoading = true;
    });

    try {
      concepts = await DatabaseService().getAllThoughtConcepts();
      
      if (concepts.isEmpty) {
        await _tryLoadFromApi();
      }
    } catch (e) {
      print('加载本地思想概念数据失败: $e');
      await _tryLoadFromApi();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _tryLoadFromApi() async {
    try {
      List<Map<String, dynamic>>? apiConcepts = await ApiService.fetchThoughtConcepts();
      
      if (apiConcepts != null && apiConcepts.isNotEmpty) {
        concepts = apiConcepts;
        await _syncToLocal(apiConcepts);
      } else {
        concepts = [];
      }
    } catch (e) {
      print('从API获取思想概念数据失败: $e');
      concepts = [];
    }
  }

  Future<void> _syncToLocal(List<Map<String, dynamic>> apiConcepts) async {
    try {
      for (var concept in apiConcepts) {
        await DatabaseService().saveThoughtConcept(
          concept['name'],
          concept['content'] ?? '',
          concept['example'] ?? '',
          List<String>.from(concept['representatives'] ?? []),
        );
      }
    } catch (e) {
      print('同步思想概念数据到本地失败: $e');
    }
  }

  List<Map<String, dynamic>> getCurrentPageConcepts() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > concepts.length) {
      endIndex = concepts.length;
    }
    return concepts.sublist(startIndex, endIndex);
  }

  int get totalPages {
    return (concepts.length / itemsPerPage).ceil();
  }

  void _prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _handleRepresentativeTap(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FigureScreen(figureName: name),
      ),
    );
  }

  void _showConceptDetail(Map<String, dynamic> concept) {
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
              Text(concept['name'], style: AppTheme.titleStyle),
              const SizedBox(height: 16.0),
              Text('概念解释', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(concept['content'] ?? '', style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              Text('现实案例', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(concept['example'] ?? '', style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              if (concept['representatives'] != null &&
                  (concept['representatives'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('代表人物', style: AppTheme.subtitleStyle),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: (concept['representatives'] as List).map<Widget>((rep) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentPageConcepts = getCurrentPageConcepts();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: currentPageConcepts.length,
              itemBuilder: (context, index) {
                final concept = currentPageConcepts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: InkWell(
                    onTap: () => _showConceptDetail(concept),
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
                                concept['name'],
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
                                Text(concept['name'], style: AppTheme.subtitleStyle),
                                const SizedBox(height: 8.0),
                                Text(
                                  concept['content'] ?? '',
                                  style: AppTheme.bodyStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    onPressed: currentPage > 1 ? _prevPage : null,
                    icon: const Icon(Icons.chevron_left),
                    disabledColor: AppTheme.textSecondaryColor,
                  ),
                  Text(
                    '$currentPage / $totalPages',
                    style: AppTheme.bodyStyle,
                  ),
                  IconButton(
                    onPressed: currentPage < totalPages ? _nextPage : null,
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