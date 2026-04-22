import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';

class FigureScreen extends StatefulWidget {
  const FigureScreen({super.key});

  @override
  State<FigureScreen> createState() => _FigureScreenState();
}

class _FigureScreenState extends State<FigureScreen> {
  final List<Map<String, dynamic>> figures = [
    {
      'id': '1',
      'name': '老子',
      'era': '春秋',
      'description': '道家学派创始人，著有《道德经》',
      'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。',
      'coreThoughts': ['无为', '道法自然', '小国寡民'],
      'works': ['道德经']
    },
    {
      'id': '2',
      'name': '庄子',
      'era': '战国',
      'description': '道家代表人物，著有《庄子》',
      'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。',
      'coreThoughts': ['逍遥游', '齐物论', '相对主义'],
      'works': ['庄子']
    },
    {
      'id': '3',
      'name': '列子',
      'era': '战国',
      'description': '道家思想家，著有《列子》',
      'bio': '列子，名御寇，战国时期郑国人。他是道家学派的重要代表人物，其思想强调虚静无为，顺应自然。《列子》一书包含了许多寓言故事，富有哲理。',
      'coreThoughts': ['虚静', '无为', '自然'],
      'works': ['列子']
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人物'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: figures.length,
        itemBuilder: (context, index) {
          final figure = figures[index];
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
    );
  }
}