import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/utils/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadSects();
  }

  // 从本地存储加载派系数据
  Future<void> _loadSects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sectsJson = prefs.getString('sects');
      if (sectsJson != null) {
        // 从本地存储加载数据
        final List<dynamic> sectsList = jsonDecode(sectsJson);
        sects = List<Map<String, dynamic>>.from(sectsList);
      } else {
        // 初始化默认数据
        sects = [
          {
            'id': '1',
            'name': '正一道',
            'dynasty': '东汉',
            'practice': '符箓',
            'description': '正一道是道教的主要派别之一，由张道陵创立于东汉末年。注重符箓法术，强调通过仪式和法术来达到修仙的目的。',
            'info': {
              '修行方式': '符箓、斋醮、科仪',
              '理念': '驱邪避凶、祈福禳灾',
              '经典': '《道德经》、《太平经》',
              '圣地': '龙虎山、青城山'
            },
            'representatives': ['张道陵', '张衡', '张鲁']
          },
          {
            'id': '2',
            'name': '上清派',
            'dynasty': '魏晋',
            'practice': '存思',
            'description': '上清派是道教的重要派别之一，以《上清经》为主要经典，强调存思守一的修炼方法。由魏华存创立。',
            'info': {
              '修行方式': '存思、服气、内丹',
              '理念': '上清道妙、存思成仙',
              '经典': '《上清大洞真经》',
              '圣地': '茅山、天台山'
            },
            'representatives': ['魏华存', '杨羲', '许谧']
          },
          {
            'id': '3',
            'name': '灵宝派',
            'dynasty': '魏晋',
            'practice': '斋醮',
            'description': '灵宝派是道教的重要派别之一，以《灵宝经》为主要经典，强调斋醮科仪的重要性。由葛玄创立。',
            'info': {
              '修行方式': '斋醮、符箓、诵经',
              '理念': '超度亡灵、积累功德',
              '经典': '《灵宝无量度人上品妙经》',
              '圣地': '阁皂山'
            },
            'representatives': ['葛玄', '葛洪', '陆修静']
          },
          {
            'id': '4',
            'name': '茅山派',
            'dynasty': '隋唐',
            'practice': '符箓',
            'description': '茅山派是道教的重要派别之一，以茅山为圣地，注重符箓法术和内丹修炼。由陶弘景发展壮大。',
            'info': {
              '修行方式': '符箓、内丹、斋醮',
              '理念': '济世度人、修道成仙',
              '经典': '《真诰》、《登真隐诀》',
              '圣地': '茅山'
            },
            'representatives': ['陶弘景', '司马承祯', '吴筠']
          },
          {
            'id': '5',
            'name': '全真派',
            'dynasty': '北宋',
            'practice': '清修',
            'description': '全真派是道教的重要派别之一，由王重阳创立，主张性命双修，强调内心的修炼和精神的超越。',
            'info': {
              '修行方式': '内丹修炼、清修、戒律',
              '理念': '全真而仙、三教合一',
              '经典': '《道德经》、《清静经》',
              '圣地': '终南山、昆嵛山'
            },
            'representatives': ['王重阳', '丘处机', '马钰']
          },
          {
            'id': '6',
            'name': '净明道',
            'dynasty': '南宋',
            'practice': '忠孝',
            'description': '净明道是道教的重要派别之一，强调忠孝伦理，融合儒家思想与道教修炼。由许逊创立。',
            'info': {
              '修行方式': '忠孝伦理、内丹修炼',
              '理念': '净明忠孝、仙道合一',
              '经典': '《净明忠孝全书》',
              '圣地': '西山万寿宫'
            },
            'representatives': ['许逊', '刘玉', '黄元吉']
          },
          {
            'id': '7',
            'name': '龙门派',
            'dynasty': '元',
            'practice': '清修',
            'description': '龙门派是全真派的重要支派，由丘处机创立，强调严格的清修戒律和内丹修炼。',
            'info': {
              '修行方式': '内丹修炼、清修戒律',
              '理念': '龙门心法、全真传承',
              '经典': '《邱祖全书》',
              '圣地': '白云观、崂山'
            },
            'representatives': ['丘处机', '尹志平', '李志常']
          },
          {
            'id': '8',
            'name': '正一派',
            'dynasty': '明',
            'practice': '符箓',
            'description': '正一派是道教的主要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。',
            'info': {
              '修行方式': '符箓、斋醮、科仪',
              '理念': '驱邪避凶、祈福禳灾',
              '经典': '《正统道藏》',
              '圣地': '龙虎山'
            },
            'representatives': ['张正常', '张宇初', '张继禹']
          },
          {
            'id': '9',
            'name': '青城派',
            'dynasty': '清',
            'practice': '内丹',
            'description': '青城派是道教的重要派别之一，以青城山为圣地，注重内丹修炼和武术。',
            'info': {
              '修行方式': '内丹修炼、武术',
              '理念': '青城仙道、内外兼修',
              '经典': '《青城秘录》',
              '圣地': '青城山'
            },
            'representatives': ['杜光庭', '陈清觉', '刘沅']
          },
        ];
        // 保存到本地存储
        await _saveSects();
      }
      // 按朝代排序
      _sortSectsByDynasty();
      setState(() {});
    } catch (e) {
      print('加载派系数据失败: $e');
      // 加载失败时使用默认数据
      sects = [
        {
          'id': '1',
          'name': '正一道',
          'dynasty': '东汉',
          'practice': '符箓',
          'description': '正一道是道教的主要派别之一，注重符箓法术，强调通过仪式和法术来达到修仙的目的。',
          'info': {
            '修行方式': '符箓、斋醮',
            '理念': '驱邪避凶、祈福禳灾',
          },
          'representatives': ['张道陵', '张衡', '张鲁']
        },
        {
          'id': '2',
          'name': '全真派',
          'dynasty': '北宋',
          'practice': '清修',
          'description': '全真派是道教的重要派别之一，主张性命双修，强调内心的修炼和精神的超越。',
          'info': {
            '修行方式': '内丹修炼、清修',
            '理念': '全真而仙',
          },
          'representatives': ['王重阳', '丘处机', '马钰']
        },
      ];
      _sortSectsByDynasty();
      setState(() {});
    }
  }

  // 保存派系数据到本地存储
  Future<void> _saveSects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sectsJson = jsonEncode(sects);
      await prefs.setString('sects', sectsJson);
    } catch (e) {
      print('保存派系数据失败: $e');
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
    String figureInfo = await AIService.getExplanation(
      '请详细介绍道教人物 $name 的生平和贡献',
      style: 'detailed'
    );
    
    // 保存人物信息到本地存储
    await _saveFigureInfo(name, figureInfo);
    
    // 跳转到人物篇
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FigureScreen()),
    );
  }

  // 保存人物信息到本地存储
  Future<void> _saveFigureInfo(String name, String info) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final figuresJson = prefs.getString('figures');
      List<Map<String, dynamic>> figures;
      
      if (figuresJson != null) {
        final List<dynamic> figuresList = jsonDecode(figuresJson);
        figures = List<Map<String, dynamic>>.from(figuresList);
      } else {
        figures = [];
      }
      
      // 检查是否已存在该人物
      int existingIndex = figures.indexWhere((fig) => fig['name'] == name);
      if (existingIndex >= 0) {
        // 更新现有人物信息
        figures[existingIndex]['bio'] = info;
      } else {
        // 添加新人物
        figures.add({
          'id': (figures.length + 1).toString(),
          'name': name,
          'era': '',
          'description': '',
          'bio': info,
          'coreThoughts': [],
          'works': []
        });
      }
      
      // 保存到本地存储
      await prefs.setString('figures', jsonEncode(figures));
    } catch (e) {
      print('保存人物信息失败: $e');
    }
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
                      onDeleted: () {},
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

  @override
  Widget build(BuildContext context) {
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
                borderTop: Border.all(color: AppTheme.borderColor),
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