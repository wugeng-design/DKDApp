import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = '8c77f319f8be4f2cb276c2083ce144cf.dnxfej0bJb2nAKYS';
  const apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  
  try {
    print('测试API连接...');
    
    // 简单的测试请求
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({
        'model': 'glm-4.7-flash',
        'messages': [
          {
            'role': 'user',
            'content': '你好，测试连接'
          }
        ],
        'temperature': 0.7,
        'max_tokens': 100
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('API请求超时');
      },
    );

    print('状态码: ${response.statusCode}');
    print('响应: ${response.body}');
  } catch (e) {
    print('错误: $e');
  }
}