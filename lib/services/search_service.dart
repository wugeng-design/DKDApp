import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

enum SearchResultType { figure, thought, sect, unknown }

// 本地备用搜索数据
const Map<String, Map<String, dynamic>> _localSearchData = {
  '老子': {
    'type': '人物',
    'name': '老子',
    'era': '春秋',
    'description': '道家学派创始人',
    'bio': '老子，姓李名耳，字聃，春秋时期思想家，道家学派创始人。他的思想对中国哲学、文化产生了深远影响。',
    'coreThoughts': ['道', '无为', '道法自然'],
    'works': ['道德经']
  },
  '庄子': {
    'type': '人物',
    'name': '庄子',
    'era': '战国',
    'description': '道家代表人物',
    'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。',
    'coreThoughts': ['逍遥游', '齐物论', '相对主义'],
    'works': ['庄子']
  },
  '张道陵': {
    'type': '人物',
    'name': '张道陵',
    'era': '东汉',
    'description': '道教创始人',
    'bio': '张道陵，字辅汉，东汉时期沛国人。他是道教的创始人，被尊为张天师。',
    'coreThoughts': ['道教学说', '符箓法术', '道教组织'],
    'works': ['老子想尔注']
  },
  '道': {
    'type': '思想',
    'name': '道',
    'description': '宇宙万物的本原',
    'content': '道是宇宙万物的本原和规律，是道家哲学的核心概念。它超越一切具体存在，是万物产生和发展的根源。',
    'example': '就像自然界的四季更替，万物生长，都是道的体现。在现代生活中，遵循道意味着顺应自然规律，不强行干预事物的发展。'
  },
  '无为': {
    'type': '思想',
    'name': '无为',
    'description': '道家核心思想',
    'content': '无为不是消极不作为，而是不违背自然规律的作为。它强调顺应自然，不强行干预，让事物按照自身规律发展。',
    'example': '在管理中，领导者如果能够充分信任团队成员，给予他们足够的空间，往往能取得更好的效果，这就是无为而治的体现。'
  },
  '全真派': {
    'type': '派系',
    'name': '全真派',
    'description': '主张清修的道教派别',
    'practice': '清修',
    'info': {'修行方式': '清修', '理念': '性命双修', '创立时间': '金代'},
    'representatives': ['王重阳', '丘处机', '马钰']
  },
  '正一道': {
    'type': '派系',
    'name': '正一道',
    'description': '道教主要派别之一',
    'practice': '符箓',
    'info': {'修行方式': '符箓、斋醮', '理念': '驱邪避凶、祈福禳灾', '创立时间': '东汉'},
    'representatives': ['张道陵', '张衡', '张鲁']
  }
};

class SearchResult {
  final SearchResultType type;
  final String name;
  final String description;
  final Map<String, dynamic> details;
  final bool isComplete;
  final String? errorMessage;

  SearchResult({
    required this.type,
    required this.name,
    required this.description,
    required this.details,
    this.isComplete = true,
    this.errorMessage,
  });

  factory SearchResult.empty() {
    return SearchResult(
      type: SearchResultType.unknown,
      name: '',
      description: '',
      details: {},
      isComplete: false,
      errorMessage: '未找到相关信息',
    );
  }

  factory SearchResult.error(String message, {String name = ''}) {
    return SearchResult(
      type: SearchResultType.unknown,
      name: name,
      description: '',
      details: {},
      isComplete: false,
      errorMessage: message,
    );
  }

  bool get hasDetails => details.isNotEmpty;
}

class SearchService {
  static const String apiKey = '8c77f319f8be4f2cb276c2083ce144cf.dnxfej0bJb2nAKYS';
  static const String apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4.7-flash';

  static Future<SearchResult> search(String query) async {
    if (query.trim().isEmpty) {
      return SearchResult.error('请输入搜索关键词');
    }

    // 首先尝试使用本地备用数据
    final localData = _localSearchData[query.trim()];
    if (localData != null) {
      return _parseLocalData(localData, query);
    }

    final prompt = '''
请搜索关于"$query"的信息，并返回结构化的JSON数据。

你必须返回以下JSON格式之一（根据搜索内容自动判断类型）：

人物类型：
{
  "type": "人物",
  "name": "人物名称",
  "era": "所属时代",
  "description": "简短描述（50字内）",
  "bio": "人物生平简介",
  "coreThoughts": ["核心思想1", "核心思想2", "核心思想3"],
  "works": ["著作1", "著作2"]
}

思想类型：
{
  "type": "思想",
  "name": "思想名称",
  "description": "简短描述（50字内）",
  "content": "概念的详细解释",
  "example": "现代生活中的实际案例"
}

派系类型：
{
  "type": "派系",
  "name": "派系名称",
  "description": "简短描述（50字内）",
  "practice": "主要修行方式",
  "info": {
    "修行方式": "具体修行方法",
    "理念": "主要理念"
  },
  "representatives": ["代表人物1", "代表人物2", "代表人物3"]
}

如果搜索内容不明确或不属于以上三类，返回：
{
  "type": "unknown",
  "name": "搜索关键词",
  "description": "无法确定类型的说明",
  "content": "提供一些相关信息"
}

重要要求：
1. 只返回JSON数据，不要有其他文字
2. 确保JSON格式正确，可以被解析
3. 如果信息不完整，仍需返回JSON但标记可能的缺失字段
4. coreThoughts和works至少包含1个元素
5. representatives至少包含1个元素
''';

    try {
      // 设置超时时间为10秒
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 2000
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('API请求超时，请检查网络连接');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseSearchResult(content, query);
      } else {
        // API失败时使用本地数据（如果有）
        return _createUnknownResult(query, '搜索服务暂时不可用，使用本地数据');
      }
    } catch (e) {
      // 网络错误时使用本地数据
      return _createUnknownResult(query, '网络连接失败，使用本地数据');
    }
  }

  // 解析本地数据
  static SearchResult _parseLocalData(Map<String, dynamic> data, String query) {
    final type = data['type'] as String;
    final name = data['name'] as String? ?? query;
    final description = data['description'] as String? ?? '';

    SearchResultType resultType;
    Map<String, dynamic> details = {};

    if (type == '人物') {
      resultType = SearchResultType.figure;
      details = {
        'era': data['era'] as String? ?? '未知',
        'bio': data['bio'] as String? ?? '',
        'coreThoughts': (data['coreThoughts'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        'works': (data['works'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
      };
    } else if (type == '思想') {
      resultType = SearchResultType.thought;
      details = {
        'content': data['content'] as String? ?? '',
        'example': data['example'] as String? ?? '',
      };
    } else if (type == '派系') {
      resultType = SearchResultType.sect;
      details = {
        'practice': data['practice'] as String? ?? '',
        'description': data['description'] as String? ?? description,
        'info': (data['info'] as Map<String, dynamic>?) ?? {},
        'representatives': (data['representatives'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
      };
    } else {
      resultType = SearchResultType.unknown;
      details = {
        'content': data['content'] as String? ?? '',
      };
    }

    final isComplete = _checkDataCompleteness(resultType, details);

    return SearchResult(
      type: resultType,
      name: name,
      description: description,
      details: details,
      isComplete: isComplete,
    );
  }

  // 创建未知类型的结果
  static SearchResult _createUnknownResult(String query, String errorMessage) {
    return SearchResult(
      type: SearchResultType.unknown,
      name: query,
      description: errorMessage,
      details: {
        'content': '抱歉，未能获取到关于 "$query" 的详细信息。请尝试搜索其他关键词，或检查网络连接后重试。',
      },
      isComplete: false,
    );
  }

  static SearchResult _parseSearchResult(String content, String query) {
    try {
      String jsonStr = content.trim();

      int jsonStart = jsonStr.indexOf('{');
      if (jsonStart == -1) {
        return SearchResult.error('未找到有效的搜索结果', name: query);
      }

      jsonStr = jsonStr.substring(jsonStart);

      int braceCount = 0;
      int jsonEnd = jsonStr.length;
      for (int i = 0; i < jsonStr.length; i++) {
        if (jsonStr[i] == '{') braceCount++;
        if (jsonStr[i] == '}') braceCount--;
        if (braceCount == 0 && i > jsonStart) {
          jsonEnd = i + 1;
          break;
        }
      }

      jsonStr = jsonStr.substring(0, jsonEnd);
      final jsonData = jsonDecode(jsonStr);

      final type = jsonData['type'] as String;
      final name = (jsonData['name'] as String?)?.isNotEmpty == true ? jsonData['name'] as String : query;
      final description = jsonData['description'] as String? ?? '';

      SearchResultType resultType;
      Map<String, dynamic> details = {};

      if (type == '人物') {
        resultType = SearchResultType.figure;
        details = {
          'era': jsonData['era'] as String? ?? '未知',
          'bio': jsonData['bio'] as String? ?? '',
          'coreThoughts': (jsonData['coreThoughts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
          'works': (jsonData['works'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        };
      } else if (type == '思想') {
        resultType = SearchResultType.thought;
        details = {
          'content': jsonData['content'] as String? ?? '',
          'example': jsonData['example'] as String? ?? '',
        };
      } else if (type == '派系') {
        resultType = SearchResultType.sect;
        details = {
          'practice': jsonData['practice'] as String? ?? '',
          'description': jsonData['description'] as String? ?? description,
          'info': (jsonData['info'] as Map<String, dynamic>?) ?? {},
          'representatives': (jsonData['representatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        };
      } else {
        resultType = SearchResultType.unknown;
        details = {
          'content': jsonData['content'] as String? ?? '',
        };
      }

      final isComplete = _checkDataCompleteness(resultType, details);

      return SearchResult(
        type: resultType,
        name: name,
        description: description,
        details: details,
        isComplete: isComplete,
      );
    } catch (e) {
      return SearchResult.error('搜索结果解析失败，请稍后再试', name: query);
    }
  }

  static bool _checkDataCompleteness(SearchResultType type, Map<String, dynamic> details) {
    switch (type) {
      case SearchResultType.figure:
        final bio = details['bio'] as String?;
        final thoughts = details['coreThoughts'] as List?;
        return (bio != null && bio.isNotEmpty) && (thoughts != null && thoughts.isNotEmpty);

      case SearchResultType.thought:
        final content = details['content'] as String?;
        return (content != null && content.isNotEmpty);

      case SearchResultType.sect:
        final info = details['info'] as Map?;
        final reps = details['representatives'] as List?;
        return (info != null && info.isNotEmpty) && (reps != null && reps.isNotEmpty);

      case SearchResultType.unknown:
        return details.isNotEmpty;
    }
  }
}