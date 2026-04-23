import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FigureScreen extends StatefulWidget {
  const FigureScreen({super.key});

  @override
  State<FigureScreen> createState() => _FigureScreenState();
}

class _FigureScreenState extends State<FigureScreen> {
  late List<Map<String, dynamic>> figures;
  int _currentPage = 0;
  final int _pageSize = 5;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _defaultFigures = [
    {
      'id': '1',
      'name': '老子',
      'era': '春秋',
      'eraOrder': 1,
      'description': '道家学派创始人，著有《道德经》',
      'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。',
      'coreThoughts': ['无为', '道法自然', '小国寡民'],
      'works': ['道德经']
    },
    {
      'id': '2',
      'name': '孔子',
      'era': '春秋',
      'eraOrder': 1,
      'description': '儒家学派创始人，被尊为孔圣人',
      'bio': '孔子，名丘，字仲尼，春秋时期鲁国人。他是儒家学派的创始人，提出了仁、义、礼、智、信等核心思想，对中国乃至东亚文化产生了深远影响。',
      'coreThoughts': ['仁', '义', '礼', '智', '信'],
      'works': ['论语']
    },
    {
      'id': '3',
      'name': '墨子',
      'era': '战国',
      'eraOrder': 2,
      'description': '墨家学派创始人，主张兼爱非攻',
      'bio': '墨子，名翟，战国时期宋国人。他是墨家学派的创始人，主张兼爱、非攻、尚贤等思想，对中国古代哲学产生了重要影响。',
      'coreThoughts': ['兼爱', '非攻', '尚贤', '尚同'],
      'works': ['墨子']
    },
    {
      'id': '4',
      'name': '孟子',
      'era': '战国',
      'eraOrder': 2,
      'description': '儒家代表人物，被尊为亚圣',
      'bio': '孟子，名轲，战国时期邹国人。他是儒家学派的重要代表人物，继承和发展了孔子的思想，提出了性善论、仁政等观点。',
      'coreThoughts': ['性善论', '仁政', '民贵君轻'],
      'works': ['孟子']
    },
    {
      'id': '5',
      'name': '庄子',
      'era': '战国',
      'eraOrder': 2,
      'description': '道家代表人物，著有《庄子》',
      'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。',
      'coreThoughts': ['逍遥游', '齐物论', '相对主义'],
      'works': ['庄子']
    },
    {
      'id': '6',
      'name': '列子',
      'era': '战国',
      'eraOrder': 2,
      'description': '道家思想家，著有《列子》',
      'bio': '列子，名御寇，战国时期郑国人。他是道家学派的重要代表人物，其思想强调虚静无为，顺应自然。《列子》一书包含了许多寓言故事，富有哲理。',
      'coreThoughts': ['虚静', '无为', '自然'],
      'works': ['列子']
    },
    {
      'id': '7',
      'name': '荀子',
      'era': '战国',
      'eraOrder': 2,
      'description': '儒家代表人物，主张性恶论',
      'bio': '荀子，名况，战国时期赵国人。他是儒家学派的重要代表人物，主张性恶论，强调后天教育的重要性，对儒家思想的发展做出了重要贡献。',
      'coreThoughts': ['性恶论', '隆礼重法', '天人相分'],
      'works': ['荀子']
    },
    {
      'id': '8',
      'name': '韩非子',
      'era': '战国',
      'eraOrder': 2,
      'description': '法家代表人物，集法家思想之大成',
      'bio': '韩非子，战国末期韩国人。他是法家学派的代表人物，集法家思想之大成，主张以法治国，对中国古代政治思想产生了深远影响。',
      'coreThoughts': ['法治', '术治', '势治'],
      'works': ['韩非子']
    },
    {
      'id': '9',
      'name': '董仲舒',
      'era': '西汉',
      'eraOrder': 3,
      'description': '汉代儒家代表人物，提出天人感应学说',
      'bio': '董仲舒，西汉时期广川人。他是汉代儒家的代表人物，提出了天人感应、大一统等学说，对汉代及后世的政治思想产生了重要影响。',
      'coreThoughts': ['天人感应', '大一统', '罢黜百家，独尊儒术'],
      'works': ['春秋繁露']
    },
    {
      'id': '10',
      'name': '王充',
      'era': '东汉',
      'eraOrder': 4,
      'description': '东汉思想家，批判谶纬迷信',
      'bio': '王充，东汉时期会稽上虞人。他是东汉时期的思想家，批判谶纬迷信，主张无神论，对中国古代唯物主义思想的发展做出了重要贡献。',
      'coreThoughts': ['无神论', '唯物主义', '疾虚妄'],
      'works': ['论衡']
    },
    {
      'id': '11',
      'name': '郭象',
      'era': '魏晋',
      'eraOrder': 5,
      'description': '魏晋玄学代表人物，注《庄子》',
      'bio': '郭象，魏晋时期河南人。他是魏晋玄学的代表人物，注《庄子》，提出了独化论等思想，对魏晋玄学的发展做出了重要贡献。',
      'coreThoughts': ['独化论', '玄冥', '自然'],
      'works': ['庄子注']
    },
    {
      'id': '12',
      'name': '韩愈',
      'era': '唐代',
      'eraOrder': 6,
      'description': '唐代文学家、思想家，倡导古文运动',
      'bio': '韩愈，唐代河南河阳人。他是唐代著名的文学家、思想家，倡导古文运动，提出了道统说，对宋明理学的产生有重要影响。',
      'coreThoughts': ['道统说', '文以载道', '复古'],
      'works': ['韩昌黎集']
    },
    {
      'id': '13',
      'name': '朱熹',
      'era': '宋代',
      'eraOrder': 7,
      'description': '宋代理学集大成者，主张格物致知',
      'bio': '朱熹，宋代徽州婺源人。他是宋代理学的集大成者，主张格物致知、存天理灭人欲，对中国后期封建社会的思想产生了深远影响。',
      'coreThoughts': ['格物致知', '存天理灭人欲', '理气论'],
      'works': ['四书章句集注']
    },
    {
      'id': '14',
      'name': '王阳明',
      'era': '明代',
      'eraOrder': 8,
      'description': '明代心学集大成者，主张知行合一',
      'bio': '王阳明，明代浙江余姚人。他是明代心学的集大成者，主张心即理、知行合一、致良知，对中国后期封建社会的思想产生了重要影响。',
      'coreThoughts': ['心即理', '知行合一', '致良知'],
      'works': ['传习录']
    },
    {
      'id': '15',
      'name': '王夫之',
      'era': '明末清初',
      'eraOrder': 9,
      'description': '明末清初思想家，批判程朱理学',
      'bio': '王夫之，明末清初湖南衡阳人。他是明末清初的思想家，批判程朱理学，主张气一元论、经世致用，对中国近代思想的发展产生了重要影响。',
      'coreThoughts': ['气一元论', '经世致用', '动静观'],
      'works': ['船山遗书']
    },
  ]..sort((a, b) => a['eraOrder'].compareTo(b['eraOrder']));
  
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
      final prefs = await SharedPreferences.getInstance();
      final figuresJson = prefs.getString('figures');
      if (figuresJson != null) {
        final List<dynamic> figuresList = json.decode(figuresJson);
        setState(() {
          figures = figuresList.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        // 首次加载，使用默认数据
        figures = _defaultFigures;
        await _saveFigures();
      }
    } catch (e) {
      // 加载失败，使用默认数据
      figures = _defaultFigures;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveFigures() async {
    final prefs = await SharedPreferences.getInstance();
    final figuresJson = json.encode(figures);
    await prefs.setString('figures', figuresJson);
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