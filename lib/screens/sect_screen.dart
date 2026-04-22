import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';

class SectScreen extends StatefulWidget {
  const SectScreen({super.key});

  @override
  State<SectScreen> createState() => _SectScreenState();
}

class _SectScreenState extends State<SectScreen> {
  final List<Map<String, dynamic>> sects = [
    {
      'id': '1',
      'name': '全真派',
      'practice': '清修',
      'description': '全真派是道教的重要派别之一，主张性命双修，强调内心的修炼和精神的超越。',
      'info': {
        '修行方式': '内丹修炼、清修',
        '理念': '全真而仙',
      },
      'representatives': ['王重阳', '丘处机', '马钰']
    },
    {
      'id': '2',
      'name': '正一道',
      'practice': '符箓',
      'description': '正一道是道教的主要派别之一，注重符箓法术，强调通过仪式和法术来达到修仙的目的。',
      'info': {
        '修行方式': '符箓、斋醮',
        '理念': '驱邪避凶、祈福禳灾',
      },
      'representatives': ['张道陵', '张衡', '张鲁']
    },
  ];

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
              Text('修行：${sect['practice']}', style: AppTheme.captionStyle),
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
                  return Chip(
                    label: Text(rep),
                    backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppTheme.accentColor),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('派系'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sects.length,
        itemBuilder: (context, index) {
          final sect = sects[index];
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
                          Text('修行：${sect['practice']}', style: AppTheme.captionStyle),
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
    );
  }
}