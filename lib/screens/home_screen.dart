import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String todayQuote = '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。';
  bool _showAIExplanation = false;
  final String aiExplanation = '这句话的意思是：可以用言语表达的道，不是永恒的道；可以用名称界定的名，不是永恒的名。无是天地的本始，有是万物的根源。它强调了道的超越性和不可言说性，同时指出了有无相生的辩证关系。';

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

            // AI解读按钮
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAIExplanation = !_showAIExplanation;
                  });
                },
                child: Text(_showAIExplanation ? '收起解读' : 'AI解读'),
              ),
            ),
            const SizedBox(height: 16.0),

            // AI解释卡片
            if (_showAIExplanation)
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
                        Text(aiExplanation, style: AppTheme.bodyStyle),
                        const SizedBox(height: 12.0),
                        Text('AI生成内容', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showAIExplanation) const SizedBox(height: 24.0),

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