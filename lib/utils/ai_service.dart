import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 智谱AI API配置
  static const String apiKey = '8c77f319f8be4f2cb276c2083ce144cf.dnxfej0bJb2nAKYS'; // 替换为你的智谱API Key
  static const String apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4.7-flash'; // 选择合适的模型

  // 调用大模型API进行解读
  static Future<String> getExplanation(String text, {String style = 'default'}) async {
    try {
      String prompt = '';
      switch (style) {
        case 'concise':
          prompt = '请简洁解读这句话：$text\n要求：语言精炼，直击要点，不超过100字';
          break;
        case 'detailed':
          prompt = '请详细解读这句话：$text\n要求：1. 逐字解释含义\n2. 深入分析哲学思想\n3. 提供历史背景\n4. 与其他哲学思想对比\n5. 语言详尽全面';
          break;
        case 'modern':
          prompt = '请用现代视角解读这句话：$text\n要求：1. 结合现代科学和哲学\n2. 用通俗易懂的语言\n3. 联系现实生活\n4. 提供实用的启示';
          break;
        default:
          prompt = '请详细解读这句话：$text\n要求：1. 解释句子的含义\n2. 分析其哲学思想\n3. 提供现代视角的理解\n4. 语言简洁明了';
      }
      
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
          'temperature': 0.7,
          'max_tokens': 1000
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // 如果API调用失败，返回默认解释
      return '这句话的意思是：可以用言语表达的道，不是永恒的道；可以用名称界定的名，不是永恒的名。无是天地的本始，有是万物的根源。它强调了道的超越性和不可言说性，同时指出了有无相生的辩证关系。';
    }
  }
}
