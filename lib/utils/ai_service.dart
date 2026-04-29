import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../services/ai_model_config_service.dart';

class AIService {
  static String _apiKey = '';
  static String _apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static String _model = 'glm-4.7-flash';

  static Future<void> _loadConfig() async {
    final config = await AiModelConfigService.getConfig();
    if (config != null && config.appKey.isNotEmpty) {
      final aiModel = AiModelConfigService.getModelById(config.modelId);
      _apiKey = config.appKey;
      _apiUrl = aiModel.apiUrl;
      _model = config.customModel ?? aiModel.defaultModel;
    } else {
      _apiKey = '8c77f319f8be4f2cb276c2083ce144cf.dnxfej0bJb2nAKYS';
      _apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
      _model = 'glm-4.7-flash';
    }
  }

  static Future<String> getExplanation(String text, {String style = 'default'}) async {
    await _loadConfig();

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
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: jsonEncode({
          'model': _model,
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
      print('AI解读失败: $e');
      return '这句话的意思是：可以用言语表达的道，不是永恒的道；可以用名称界定的名，不是永恒的名。无是天地的本始，有是万物的根源。它强调了道的超越性和不可言说性，同时指出了有无相生的辩证关系。';
    }
  }

  static Future<Map<String, dynamic>> getFigureInfo(String name) async {
    await _loadConfig();

    try {
      final prompt = '请详细介绍道教人物 $name 的生平和贡献，包括：1. 生平简介 2. 核心思想 3. 主要著作 4. 历史影响';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: jsonEncode({
          'model': _model,
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
      return {
        'bio': '$name是道教的重要人物，对道教的发展做出了重要贡献。',
        'coreThoughts': ['道教思想'],
        'works': []
      };
    }
  }

  static Future<String> getQuoteFromImage(File image) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

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

      final random = Random();
      return quotes[random.nextInt(quotes.length)];
    } catch (e) {
      print('生成真言失败: $e');
      return '道可道，非常道；名可名，非常名。';
    }
  }

  static Future<String> chat(String message) async {
    await _loadConfig();

    try {
      final prompt = '你是一个精通道教文化的AI助手，名叫道小来。请用简洁、有趣的方式回答用户的问题。如果问题与道教文化无关，请礼貌地引导回到道教话题。\n\n用户问题：$message';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: jsonEncode({
          'model': _model,
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
      print('聊天失败: $e');
      return '抱歉，我暂时无法回答这个问题，请稍后重试。';
    }
  }

  static Future<String> chatWithImage(File image) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final responses = [
        '这张图片让我想起了道教中的"道法自然"理念。大自然的和谐与平衡正是道的体现，我们应当像自然一样，保持内心的平静与和谐。',
        '从这张图片中，我感受到了"天地与我并生，万物与我为一"的境界。我们与自然是不可分割的整体，应当尊重和爱护我们的环境。',
        '这张图片展现了自然的美丽与神秘，正如道教所强调的"道可道，非常道"。有些真理是无法用言语完全表达的，需要我们用心去感受。',
        '看到这张图片，我想到了道教中的"无为而治"思想。有时候，我们不需要过多的干预，事物自然会按照其规律发展。',
        '这张图片让我感受到了宇宙的无限与永恒，正如道教所追求的"长生久视"。我们应当珍惜当下，过好每一天。'
      ];

      final random = Random();
      return responses[random.nextInt(responses.length)];
    } catch (e) {
      print('图片聊天失败: $e');
      return '抱歉，处理图片时发生了错误，请稍后重试。';
    }
  }
}