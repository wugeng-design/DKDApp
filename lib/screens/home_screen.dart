import 'package:flutter/material.dart';
import 'dart:math';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/utils/ai_service.dart';
import 'package:dao_app/screens/photo_quote_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String todayQuote = '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。';
  bool _showAIExplanation = false;
  String aiExplanation = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _explanationStyle = 'default'; // default, concise, detailed, modern
  List<String> daoQuotes = [];
  bool _hasFetchedExtraQuotes = false;
  SharedPreferences? _prefs;

  // 初始10条道家名言
  final List<String> defaultDaoQuotes = [
    '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。',
    '天下皆知美之为美，斯恶已；皆知善之为善，斯不善已。',
    '有无相生，难易相成，长短相较，高下相倾，音声相和，前后相随。',
    '是以圣人处无为之事，行不言之教。',
    '万物作焉而不辞，生而不有，为而不恃，功成而弗居。',
    '夫唯弗居，是以不去。',
    '不尚贤，使民不争；不贵难得之货，使民不为盗；不见可欲，使民心不乱。',
    '是以圣人之治，虚其心，实其腹，弱其志，强其骨。',
    '常使民无知无欲，使夫智者不敢为也。为无为，则无不治。',
    '道冲，而用之或不盈。渊兮，似万物之宗。'
  ];

  // 动画控制器
  late AnimationController _refreshController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initQuotes();
    // 初始化动画控制器
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // 初始化名言数据
  Future<void> _initQuotes() async {
    _prefs = await SharedPreferences.getInstance();
    final storedQuotes = _prefs?.getStringList('daoQuotes');
    
    if (storedQuotes == null || storedQuotes.isEmpty) {
      // 首次使用，存储默认名言
      await _prefs?.setStringList('daoQuotes', defaultDaoQuotes);
      daoQuotes = defaultDaoQuotes;
    } else {
      daoQuotes = storedQuotes;
    }
    
    // 随机选择一条名言作为今日一言
    _randomQuote();
  }

  // 随机选择一条名言
  void _randomQuote() {
    if (daoQuotes.isNotEmpty) {
      final randomIndex = Random().nextInt(daoQuotes.length);
      setState(() {
        todayQuote = daoQuotes[randomIndex];
      });
    }
  }

  // 保存名言到本地存储
  Future<void> _saveQuotes() async {
    await _prefs?.setStringList('daoQuotes', daoQuotes);
  }

  // 请求大模型补充名言
  Future<void> _fetchExtraQuotes() async {
    try {
      // 这里应该调用实际的大模型API
      // 暂时使用模拟数据
      final extraQuotes = [
        '挫其锐，解其纷，和其光，同其尘。',
        '湛兮，似或存。吾不知谁之子，象帝之先。',
        '天地不仁，以万物为刍狗；圣人不仁，以百姓为刍狗。',
        '天地之间，其犹橐龠乎？虚而不屈，动而愈出。',
        '多言数穷，不如守中。',
        '谷神不死，是谓玄牝。玄牝之门，是谓天地根。',
        '绵绵若存，用之不勤。',
        '天长地久。天地所以能长且久者，以其不自生，故能长生。',
        '是以圣人后其身而身先，外其身而身存。',
        '非以其无私邪？故能成其私。'
      ];
      
      // 添加到现有名言列表
      daoQuotes.addAll(extraQuotes);
      await _saveQuotes();
      _hasFetchedExtraQuotes = true;
    } catch (e) {
      print('获取额外名言失败: $e');
    }
  }

  // 刷新名言
  Future<void> _refreshQuote() async {
    // 第一次刷新时，请求大模型补充名言
    if (!_hasFetchedExtraQuotes) {
      await _fetchExtraQuotes();
    }
    // 随机选择一条名言
    _randomQuote();
    // 如果AI解读已显示，重置解读状态
    if (_showAIExplanation) {
      setState(() {
        _showAIExplanation = false;
      });
    }
  }

  // 构建刷新按钮
  Widget _buildRefreshButton() {
    return ElevatedButton(
      onPressed: () async {
        // 启动旋转动画
        _refreshController.forward(from: 0);
        // 执行刷新操作
        await _refreshQuote();
      },
      child: RotationTransition(
        turns: _rotationAnimation,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }

  // 刷新解读
  void _refreshExplanation() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      final explanation = await AIService.getExplanation(todayQuote, style: _explanationStyle);
      setState(() {
        aiExplanation = explanation;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '获取AI解读失败，请稍后重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<Map<String, String>> recommendedFigures = [
    {'name': '老子', 'era': '春秋', 'description': '道家创始人'},
    {'name': '庄子', 'era': '战国', 'description': '道家代表人物'},
    {'name': '列子', 'era': '战国', 'description': '道家思想家'},
  ];

  final List<Map<String, String>> recommendedThoughts = [
    {'name': '道', 'description': '宇宙万物的本原'},
    {'name': '无为', 'description': '顺应自然的处世方式'},
    {'name': '阴阳', 'description': '对立统一的哲学概念'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dao · 道'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日一言
            const Text('今日一言', style: AppTheme.titleStyle),
            const SizedBox(height: 16.0),
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                child: Text(
                  todayQuote,
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 按钮组：AI解读、刷新和照片
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_showAIExplanation) {
                        setState(() {
                          _showAIExplanation = false;
                        });
                      } else {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                          _errorMessage = '';
                        });
                        
                        try {
                          final explanation = await AIService.getExplanation(todayQuote, style: _explanationStyle);
                          setState(() {
                            aiExplanation = explanation;
                            _showAIExplanation = true;
                          });
                        } catch (e) {
                          setState(() {
                            _hasError = true;
                            _errorMessage = '获取AI解读失败，请稍后重试';
                          });
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_showAIExplanation ? '收起解读' : 'AI解读'),
                  ),
                  const SizedBox(width: 16.0),
                  _buildRefreshButton(),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PhotoQuoteScreen()),
                      );
                    },
                    child: const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 错误提示
            if (_hasError)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8.0),
                            Text('错误', style: AppTheme.subtitleStyle),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(_errorMessage, style: AppTheme.bodyStyle),
                      ],
                    ),
                  ),
                ),
              ),
            if (_hasError) const SizedBox(height: 24.0),

            // AI解释卡片
            if (_showAIExplanation && !_hasError)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                            const SizedBox(width: 8.0),
                            Text('AI解读', style: AppTheme.subtitleStyle),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(aiExplanation.isNotEmpty ? aiExplanation : '这句话的意思是：可以用言语表达的道，不是永恒的道；可以用名称界定的名，不是永恒的名。无是天地的本始，有是万物的根源。它强调了道的超越性和不可言说性，同时指出了有无相生的辩证关系。', style: AppTheme.bodyStyle),
                        const SizedBox(height: 12.0),
                        Text('AI生成内容', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showAIExplanation && !_hasError) const SizedBox(height: 16.0),
            
            // 解读风格选择和刷新按钮
            if (_showAIExplanation && !_hasError)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 解读风格选择
                  DropdownButton<String>(
                    value: _explanationStyle,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _explanationStyle = newValue;
                          // 自动刷新解读
                          _refreshExplanation();
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('默认解读'),
                      ),
                      DropdownMenuItem(
                        value: 'concise',
                        child: Text('简洁版'),
                      ),
                      DropdownMenuItem(
                        value: 'detailed',
                        child: Text('详细版'),
                      ),
                      DropdownMenuItem(
                        value: 'modern',
                        child: Text('现代视角'),
                      ),
                    ],
                  ),
                  // 刷新按钮
                  IconButton(
                    onPressed: _refreshExplanation,
                    icon: const Icon(Icons.refresh),
                    tooltip: '刷新解读',
                  ),
                ],
              ),
            if (_showAIExplanation && !_hasError) const SizedBox(height: 24.0),

            // 推荐人物
            const Text('推荐人物', style: AppTheme.subtitleStyle),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 2.5,
              ),
              itemCount: recommendedFigures.length,
              itemBuilder: (context, index) {
                final figure = recommendedFigures[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                        [
                        Text(figure['name']!, style: AppTheme.subtitleStyle),
                        Text(figure['era']!, style: AppTheme.captionStyle),
                        Text(figure['description']!, style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32.0),

            // 推荐思想
            const Text('推荐思想', style: AppTheme.subtitleStyle),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3.0,
              ),
              itemCount: recommendedThoughts.length,
              itemBuilder: (context, index) {
                final thought = recommendedThoughts[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thought['name']!, style: AppTheme.subtitleStyle),
                        Text(thought['description']!, style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}