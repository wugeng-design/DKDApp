import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

  // 调用大模型API查询人物信息
  static Future<Map<String, dynamic>> getFigureInfo(String name) async {
    try {
      final prompt = '请详细介绍道教人物 $name 的生平和贡献，包括：1. 生平简介 2. 核心思想 3. 主要著作 4. 历史影响';
      
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
        final content = data['choices'][0]['message']['content'];
        
        // 解析返回的内容，提取各个部分
        return {
          'bio': content,
          'coreThoughts': [],
          'works': []
        };
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('查询人物信息失败: $e');
      // 如果API调用失败，返回默认信息
      return {
        'bio': '$name是道教的重要人物，对道教的发展做出了重要贡献。',
        'coreThoughts': ['道教思想'],
        'works': []
      };
    }
  }

  // 根据照片生成道家真言
  static Future<String> getQuoteFromImage(File image) async {
    try {
      // 实际项目中，这里应该将图片转换为base64并发送到API
      // 暂时使用模拟数据
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络延迟
      
      // 模拟生成的道家真言
      final quotes = [
        '天地与我并生，而万物与我为一。',
        '道生一，一生二，二生三，三生万物。',
        '夫物芸芸，各复归其根。归根曰静，静曰复命。',
        '大音希声，大象无形。',
        '万物负阴而抱阳，冲气以为和。',
        '道之尊，德之贵，夫莫之命而常自然。',
        '知足者富，强行者有志。',
        '致虚极，守静笃。万物并作，吾以观复。',
        '上善若水，水善利万物而不争。',
        '飘风不终朝，骤雨不终日。'
      ];
      
      // 随机选择一条名言
      final random = Random();
      return quotes[random.nextInt(quotes.length)];
    } catch (e) {
      // 如果API调用失败，返回默认名言
      return '道可道，非常道；名可名，非常名。';
    }
  }
}

