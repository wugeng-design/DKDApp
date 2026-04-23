import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = '8c77f319f8be4f2cb276c2083ce144cf.dnxfej0bJb2nAKYS';
  const apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  const model = 'glm-4.7-flash';
  
  final prompt = '''
请搜索关于"张道陵"的信息，并返回结构化的JSON数据。

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
    print('开始调用API...');
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
    );

    print('API响应状态码: ${response.statusCode}');
    print('API响应内容: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      print('\n解析的内容: $content');
    } else {
      print('API调用失败');
    }
  } catch (e) {
    print('异常: $e');
  }
}