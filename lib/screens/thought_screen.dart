import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';

class ThoughtScreen extends StatefulWidget {
  const ThoughtScreen({super.key});

  @override
  State<ThoughtScreen> createState() => _ThoughtScreenState();
}

class _ThoughtScreenState extends State<ThoughtScreen> {
  final List<Map<String, dynamic>> thoughts = [
    {
      'id': '1',
      'name': '道',
      'content': '道是宇宙万物的本原和规律，是道家哲学的核心概念。它超越一切具体存在，是万物产生和发展的根源。',
      'example': '就像自然界的四季更替，万物生长，都是道的体现。在现代生活中，遵循道意味着顺应自然规律，不强行干预事物的发展。'
    },
    {
      'id': '2',
      'name': '无为',
      'content': '无为不是消极不作为，而是不违背自然规律的作为。它强调顺应自然，不强行干预，让事物按照自身规律发展。',
      'example': '在管理中，领导者如果能够充分信任团队成员，给予他们足够的空间，往往能取得更好的效果，这就是无为而治的体现。'
    },
    {
      'id': '3',
      'name': '阴阳',
      'content': '阴阳是中国古代哲学中的一对基本范畴，代表着事物的两个方面，如明暗、寒热、善恶等。它们相互对立又相互依存，相互转化。',
      'example': '在现代医学中，阴阳平衡的理念被应用于健康管理，强调身心的平衡状态对健康的重要性。'
    },
    {
      'id': '4',
      'name': '五行',
      'content': '五行指金、木、水、火、土五种基本元素，它们之间存在相生相克的关系，构成了宇宙万物的变化规律。',
      'example': '在传统中医中，五行理论被用于诊断和治疗疾病，认为人体各器官与五行相对应，保持五行平衡是健康的关键。'
    },
  ];

  void _showThoughtDetail(Map<String, dynamic> thought) {
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
              Text(thought['name'], style: AppTheme.titleStyle),
              const SizedBox(height: 16.0),
              Text('概念解释', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(thought['content'], style: AppTheme.bodyStyle),
              const SizedBox(height: 16.0),
              Text('现实案例', style: AppTheme.subtitleStyle),
              const SizedBox(height: 8.0),
              Text(thought['example'], style: AppTheme.bodyStyle),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: thoughts.length,
        itemBuilder: (context, index) {
          final thought = thoughts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: InkWell(
              onTap: () => _showThoughtDetail(thought),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          thought['name'],
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
                          Text(thought['name'], style: AppTheme.subtitleStyle),
                          const SizedBox(height: 8.0),
                          Text(
                            thought['content'],
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
    );
  }
}